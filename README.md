# recgov
recreation.gov CLI

## Introduction
recgov.sh is a command-line tool to find available campsites on
recreation.gov

## Requirements
* curl: command line tool for transferring data with URL syntax
  ```sh
  sudo apt install curl
  ```
* jq: lightweight and flexible command-line JSON processor
  ```sh
  sudo apt install jq
  ```
* mlr: name-indexed data processing tool
  ```sh
  sudo apt install miller
  ```

## Usage
```sh
usage: recgov.sh [-h] [OPTION]* <command> <arg>+

    -c              output csv format
    -h              this help

    command:
    --------

    search <keywords>
    list <campground_id> <yyyy-mm | mm>
    list-ticket-facility <facility_id> <yyyy-mm-dd> [tour_id]

    ex:
    ---

    recgov.sh search jenny lake
    recgov.sh list 247664 2023-06

```

## Example
Suppose we want to find availble campsites at `Jenny Lake Campground` in
Grand Teton National Park for a future trip in September.

First get its campground ID number by passing keywords to the `search`
command.
```sh
$ recgov.sh search jenny grand teton
entity_id entity_type name                                          city    state_code
247664    campground  Jenny Lake Campground                         Alta    Wyoming
247663    campground  Signal Mountain Campground                    Moran   Wyoming
4675342   permit      Grand Teton National Park Backcountry Permits Jackson Wyoming
10246274  campground  Colter Bay Marina End Ties                    Moran   Wyoming
258830    campground  Colter Bay Campground                         Moran   Wyoming
258834    facility    Jenny Lake Visitor Center                     Alta    Wyoming
258837    facility    Jenny Lake Ranger Station                     Moose   Wyoming
```

Use id **247664** for  `Jenny Lake Campground`, list available
campsites for September with the `list` command.
```sh
$ recgov.sh list 247664 09
campsite_id site loop       campsite_type         dates
10099391    29   Jenny Lake TENT ONLY NONELECTRIC 09/01,09/27
10099392    30   Jenny Lake TENT ONLY NONELECTRIC 09/01,09/27
10099395    33   Jenny Lake TENT ONLY NONELECTRIC 09/15,09/25
10099362    1    Jenny Lake TENT ONLY NONELECTRIC 09/22
10099369    8    Jenny Lake TENT ONLY NONELECTRIC 09/22
10099382    21   Jenny Lake TENT ONLY NONELECTRIC 09/23
10099402    40   Jenny Lake TENT ONLY NONELECTRIC 09/23,09/25,09/26
10099371    10   Jenny Lake TENT ONLY NONELECTRIC 09/23,09/27
10099385    24   Jenny Lake TENT ONLY NONELECTRIC 09/23,09/27
10099405    43   Jenny Lake TENT ONLY NONELECTRIC 09/23,09/27
10099383    22   Jenny Lake TENT ONLY NONELECTRIC 09/24
10099363    2    Jenny Lake TENT ONLY NONELECTRIC 09/25
10099367    6    Jenny Lake TENT ONLY NONELECTRIC 09/25
10099377    16   Jenny Lake TENT ONLY NONELECTRIC 09/25
10099379    18   Jenny Lake TENT ONLY NONELECTRIC 09/25
10099387    25a  Jenny Lake TENT ONLY NONELECTRIC 09/25
10099400    38   Jenny Lake TENT ONLY NONELECTRIC 09/26,09/27
10099404    42   Jenny Lake TENT ONLY NONELECTRIC 09/26,09/27
10099366    5    Jenny Lake TENT ONLY NONELECTRIC 09/27
10099368    7    Jenny Lake TENT ONLY NONELECTRIC 09/27
10099374    13   Jenny Lake TENT ONLY NONELECTRIC 09/27
10099384    23   Jenny Lake TENT ONLY NONELECTRIC 09/27
10099386    25   Jenny Lake TENT ONLY NONELECTRIC 09/27
10099388    26   Jenny Lake TENT ONLY NONELECTRIC 09/27
10099394    32   Jenny Lake TENT ONLY NONELECTRIC 09/27
10099403    41   Jenny Lake TENT ONLY NONELECTRIC 09/27
10099406    44   Jenny Lake TENT ONLY NONELECTRIC 09/27
10099412    50   Jenny Lake TENT ONLY NONELECTRIC 09/27
```

## Extended example
Use the `-c` flag to get output in CSV format; then pipe the CSV output
to `mlr` to display available sites for _09/27_.
```sh
$ recgov.sh -c list 247664 09 | mlr --c2p --barred grep dates=.*09/27
+-------------+------+------------+-----------------------+-------------+
| campsite_id | site | loop       | campsite_type         | dates       |
+-------------+------+------------+-----------------------+-------------+
| 10099391    | 29   | Jenny Lake | TENT ONLY NONELECTRIC | 09/01,09/27 |
| 10099392    | 30   | Jenny Lake | TENT ONLY NONELECTRIC | 09/01,09/27 |
| 10099371    | 10   | Jenny Lake | TENT ONLY NONELECTRIC | 09/23,09/27 |
| 10099385    | 24   | Jenny Lake | TENT ONLY NONELECTRIC | 09/23,09/27 |
| 10099405    | 43   | Jenny Lake | TENT ONLY NONELECTRIC | 09/23,09/27 |
| 10099400    | 38   | Jenny Lake | TENT ONLY NONELECTRIC | 09/26,09/27 |
| 10099404    | 42   | Jenny Lake | TENT ONLY NONELECTRIC | 09/26,09/27 |
| 10099366    | 5    | Jenny Lake | TENT ONLY NONELECTRIC | 09/27       |
| 10099368    | 7    | Jenny Lake | TENT ONLY NONELECTRIC | 09/27       |
| 10099374    | 13   | Jenny Lake | TENT ONLY NONELECTRIC | 09/27       |
| 10099384    | 23   | Jenny Lake | TENT ONLY NONELECTRIC | 09/27       |
| 10099386    | 25   | Jenny Lake | TENT ONLY NONELECTRIC | 09/27       |
| 10099388    | 26   | Jenny Lake | TENT ONLY NONELECTRIC | 09/27       |
| 10099394    | 32   | Jenny Lake | TENT ONLY NONELECTRIC | 09/27       |
| 10099403    | 41   | Jenny Lake | TENT ONLY NONELECTRIC | 09/27       |
| 10099406    | 44   | Jenny Lake | TENT ONLY NONELECTRIC | 09/27       |
| 10099412    | 50   | Jenny Lake | TENT ONLY NONELECTRIC | 09/27       |
+-------------+------+------------+-----------------------+-------------+
```
