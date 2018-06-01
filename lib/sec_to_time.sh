#!/usr/bin/env bash

# s_to_time convert a floating point number of seconds into a time string
# usage s_to_time <float>
# outputs time string
# errors EINVAL

SOURCE_FILE="$(readlink -f "$BASH_SOURCE")"
. "${SOURCE_FILE%/*/*}/lib.sh"

# parse args
[ "$#" -ne "1" ] &&
  echo "incorrect number of arguments, expected 1, got $#" >&2 &&
  exit 22
[ ! "$(is_num "$1" "f")" ] && echo "argument is not a float" >&2 &&
  exit 22

TIME_LEFT="$1"

# handle negative input, by converting to positive and flagging
NEGATIVE=""
[ ! "$(bc <<< "$TIME_LEFT < 0")" ] &&
  TIME_LEFT="${TIME_LEFT:1}" &&
  NEGATIVE="_"

# remove chunks of decending units of time from TIME_LEFT
DAYS="$(bc <<< "scale=0; ($TIME_LEFT / (60 * 60 * 24))")"
TIME_LEFT="$(bc <<< "scale=0; $TIME_LEFT % (60 * 60 * 24)")"

HOURS="$(bc <<< "scale=0; ($TIME_LEFT / (60 * 60))")"
TIME_LEFT="$(bc <<< "scale=0; $TIME_LEFT % (60 * 60)")"

MINUTES="$(bc <<< "scale=0; ($TIME_LEFT / 60)")"
TIME_LEFT="$(bc <<< "scale=0; $TIME_LEFT % 60")"

SECS="$TIME_LEFT" # NOTE the variable SECONDS is reserved by the shell

# output string segments
NEGATIVE_STR=""
DAY_STR=""
HOUR_STR=""
MINUTE_STR=""
SECOND_STR=""

# handle negative input
[ "$NEGATIVE" ] && NEGATIVE_STR="-"

WRITE=""

# only have a non null string if a previous string was non null or
# corresponding value is non zero (that way we don't write large units
# at all for small values of time
[ -n "$WRITE" ] || [ "$DAYS" -gt "0" ] && WRITE="_"
[ -n "$WRITE" ] && DAY_STR="$(printf '%.0fd ' "${NEGATIVE_STR}${DAYS}")"

[ -n "$WRITE" ] || [ "$HOURS" -gt "0" ] && WRITE="_"
[ -n "$WRITE" ] && HOUR_STR="$(printf '%.0fh ' "${NEGATIVE_STR}${HOURS}")"

[ -n "$WRITE" ] || [ "$MINUTES" -gt "0" ] && WRITE="_"
[ -n "$WRITE" ] && MINUTE_STR="$(printf '%.0fm ' "${NEGATIVE_STR}${MINUTES}")"

# keep seconds as a floating point number, and always write them
SCALE="$(bc <<< "scale($SECS)")"
SECOND_STR="$(printf "%.${SCALE}fs" "${NEGATIVE_STR}${SECS}")"

echo "${DAY_STR}${HOUR_STR}${MINUTE_STR}${SECOND_STR}"
exit 0

