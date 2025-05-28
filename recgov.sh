#! /bin/bash

APPNAME=${BASH_SOURCE##*/}
BASEURL=https://www.recreation.gov
MLR_TYPE=( --j2p )
CURL=(
    curl
    --silent
    --user-agent 'Mozilla/5.0 (Linux; Android 12; SM-S906N Build/QP1A.190711.020; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/80.0.3987.119 Mobile Safari/537.36'
    --compressed
)

usage() {
cat <<__EOF__
usage: $APPNAME [-h] [OPTION]* <command> <arg>+

    -c              output csv format
    -h              this help

    command:
    --------

    search <keywords>
    list <campground_id> <yyyy-mm | mm>
    list-ticket-facility <facility_id> <yyyy-mm-dd> [tour_id]

    ex:
    ---

    $APPNAME search jenny lake
    $APPNAME list 247664 2023-06

__EOF__

    exit 0
}

while getopts hc c
do
    case $c in
        c)      MLR_TYPE=( --j2c );;
        *)      usage;;
    esac
done
shift $((OPTIND - 1))

searchKeywords() {
    encoded_keywords=$(jq -R -r @uri <<< "$*")
    url="$BASEURL/api/search?q=${encoded_keywords}&exact=false&size=30"

    jq_recipe='.results[]'
    jq_recipe+='|{entity_id, entity_type, name, city, state_code}'

    "${CURL[@]}" "$url" \
        | jq "$jq_recipe" \
        | mlr $MLR_TYPE cat
}

listCampground() {
    campground=$1
    datespec=$2

    [[ ! "$campground" =~ ^[0-9]+$ ]] && usage

    if [[ "$datespec" =~ ^([0-9]{1,2})$|([0-9]{4})-([0-9]{2})$ ]]; then
        yyyy=${BASH_REMATCH[2]}
        mm=${BASH_REMATCH[1]}${BASH_REMATCH[3]}
        mm=$(printf '%02d' ${mm#0})
        start_date=${yyyy:-$(date +%Y)}-${mm:-$(date +%m)}-01
        url="$BASEURL/api/camps/availability/campground/$campground/month?start_date=${start_date}T00%3A00%3A00.000Z"
    else
        usage
    fi

    jq_recipe='['
    jq_recipe+='.campsites'
    jq_recipe+='| to_entries'
    jq_recipe+='| .[].value'
    jq_recipe+='| . as { $site, $loop, $campsite_id, $campsite_type }'
    jq_recipe+='| [ .availabilities'
    jq_recipe+='    | to_entries'
    jq_recipe+='    | .[]'
    jq_recipe+='    | select(.value=="Available")'
    jq_recipe+='    | .key'
    jq_recipe+='  ] '
    jq_recipe+='| select(length >0)'
    jq_recipe+='| {'
    jq_recipe+='    $campsite_id, $site, $loop, $campsite_type,'
    jq_recipe+='    "dates":([ .[] | capture("-(?<mm>[0-9]+)-(?<dd>[0-9]+)T") | "\(.mm)/\(.dd)" ] | join(","))'
    jq_recipe+='  }'
    jq_recipe+=']'

    "${CURL[@]}" "$url" \
        | jq "$jq_recipe" \
        | mlr $MLR_TYPE sort -f dates,campsite_type,loop
}

listTicketFacility() {
    facility=$1
    datespec=$2
    tour=$3
    
    [[ ! "$facility" =~ ^[0-9]+$ ]] && usage
    [[ ! "$datespec" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]] && usage

    url="$BASEURL/api/ticket/availability/facility/$facility?date=$datespec"

    mlr_recipe=(
        flatten
        then cut -o -f tour_id,tour_start_timestamp,inventory_count.ANY,reservation_count.ANY
        then put "'\$reservable = \${inventory_count.ANY} - \${reservation_count.ANY}'"
    )

    [[ "$tour" =~ ^[0-9]+$ ]] && {
        mlr_recipe+=( then filter "'\$tour_id==$tour'" )
    }

    "${CURL[@]}" "$url" \
        | mlr $MLR_TYPE "${mlr_recipe[@]}"
}

[ $# -lt 2 ] && usage

command=$1
shift

case $command in
    search)
        searchKeywords "$*"
        ;;

    list)
        listCampground $1 $2
        ;;

    list-ticket-facility)
        listTicketFacility $1 $2 $3
        ;;

    *)
        usage;;
esac
