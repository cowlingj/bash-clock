#!/bin/bash

# timer.sh a text based timer
# usage timer.sh [-i|--interval interval] [-p|--precision precision] [-h|--help] time...
# outputs time remaining on the same line
# errors: EINVAL

START_TIME="$(date "+%s.%N")"

SOURCE_FILE="$(readlink -f "$BASH_SOURCE")"
. "${SOURCE_FILE%/*}/lib.sh"

PROGRAM="$0"
DEFAULT_INTERVAL="1s"

function usage {
  echo "$PROGRAM [-i|--interval interval] "\
    "[-p|--precision precision] [-h|--help] time..."
  return 0
}

function graceful_exit {
  echo ""
  exit 0
}

INTERVAL=""
TIME=()
PRECISION=""

# parse args
while [ "$#" -gt "0" ]; do
  case "$1" in
    "-h") ;&
    "--help")
      usage
      exit 0
      ;;
    "-p") ;&
    "--precision")
      if [ "${#TIME[@]}" -ne "0" ] || [ ! -z "$PRECISION" ]; then
        usage
        exit 22
      fi
      
      if [ ! "$(is_num "$2" "ud")" ]; then usage; exit 22; fi
      PRECISION="$2"
      shift 2
      ;;
    "-i") ;&
    "--interval")
      if [ "${#TIME[@]}" -ne "0" ] || [ ! -z "$INTERVAL" ]; then
        usage
        exit 22
      fi
      
      if [ ! "$(is_num "$2" "udt")" ]; then usage; exit 22; fi
      INTERVAL="$2"
      shift 2
      ;;
    *)
      if [ ! "$(is_num "$1" "ut")" ]; then usage; exit 22; fi
      TIME+=("$1")
      shift
      ;;
  esac
done
[ "${#TIME[@]}" -eq "0" ] && usage && exit 22
[ -z "$INTERVAL" ] && INTERVAL="$DEFAULT_INTERVAL"

# handle SIGINT
trap graceful_exit SIGINT

# keep track internally using only seconds
TIME_LEFT="$(time_to_sec ${TIME[@]})"
INTERVAL_SECS="$(time_to_sec "$INTERVAL")"
END_TS="$(bc <<< "$START_TIME + $TIME_LEFT")"
[ -z "$PRECISION" ] && PRECISION="$(bc <<< "scale($INTERVAL_SECS)")"

# each interval:
# set time left to end time - time elapsed since the start of execution
# print time as a formatted string on the same line
# stop when seconds <= 0
while true; do
  CURR_TS="$(date "+%s.%N")"
  TIME_LEFT="$(bc <<< "scale=$PRECISION; ($END_TS - $CURR_TS)/1")"
  [ "$(bc <<< "$TIME_LEFT <= 0")" -eq "1" ] && TIME_LEFT="0"
  echo -ne "\r$(sec_to_time "$TIME_LEFT")\e[0K"
  [ "$TIME_LEFT" == "0" ] && graceful_exit
  sleep "$INTERVAL"
done

