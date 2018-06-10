#!/bin/bash

# stopwatch.sh a text based stopwatch
# usage stopwatch.sh [-i|--interval interval] [-p|--precision precision] [-h|--help]
# outputs time elapsed on the same line
# errors: EINVAL

START_TIME="$(date "+%s.%N")"

SOURCE_FILE="$(readlink -f "$BASH_SOURCE")"
. "${SOURCE_FILE%/*}/lib.sh"

PROGRAM="$0"
DEFAULT_INTERVAL="1s"

function usage {
  echo "$PROGRAM [-i|--interval interval] [-p|--precision] " \
    "[-h --help] [-g|--gui]"
  return 0
}

function graceful_stop {
  echo ""
  exit 0
}

INTERVAL=""
PRECISION=""
GUI=1

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
    "-g") ;&
    "--gui")
      if [ "${#TIME[@]}" -ne "0" ] || [ "$GUI" -eq "0" ]; then usage; exit 22; fi
      zenity --version > "/dev/null"
      GUI=$?
      [ "$GUI" -ne "0" ] && echo "warn: zenity interface not supported, continuing without"
      shift
      ;;
    *)
      usage;
      exit 22;
      ;;
  esac
done
[ -z "$INTERVAL" ] && INTERVAL="$DEFAULT_INTERVAL"

# handle SIGINT
trap graceful_stop SIGINT

# keep track of time internally using only seconds
TIME="0"
INTERVAL_SECS="$(time_to_sec "$INTERVAL")"
[ -z "$PRECISION" ] && PRECISION="$(bc <<< "scale($INTERVAL_SECS)")"

# set time to the time elapsed since the start of execution every INTERVAL
# print time as a string on the same line each interval
[ "$GUI" -eq "0" ] &&
(
  echo "100"
  while true; do
    CURR_TS="$(date "+%s.%N")"
    TIME="$(bc <<< "scale=$PRECISION; ($CURR_TS - $START_TIME)/1")"
    echo "#$(sec_to_time "$TIME")"
    sleep "$INTERVAL"
  done
) | zenity --progress --title="$0" --pulsate --no-cancel --ok-label="stop" 2>"/dev/null"
[ "$GUI" -eq "0" ] && graceful_stop

[ "$GUI" -ne "0" ] && while true; do
  CURR_TS="$(date "+%s.%N")"
  TIME="$(bc <<< "scale=$PRECISION; ($CURR_TS - $START_TIME)/1")"
  echo -ne "\r$(sec_to_time "$TIME")\e[0K"
  sleep "$INTERVAL"
done
