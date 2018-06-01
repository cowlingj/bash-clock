#!/usr/bin/env bash

# time_to_s.sh converts a time string to seconds
# usage time_to_s.sh time_string...
# outputs floating point number
# errors EINVAL

SOURCE_FILE="$(readlink -f "$BASH_SOURCE")"
. "${SOURCE_FILE%/*/*}/lib.sh"

[ "$#" -eq "0" ] && echo "$0 no arguments specified" >&2 && exit 22

TOT="0"
while [ "$#" -gt "0" ]; do
  [ -z "$1" ] || [ ! "$(is_num "$1" "t")" ] &&
    echo "invalid time string $1" >&2 && exit 22
  VAL="$(echo "$1" | sed -E "s/([\+-]?[0-9]*\.?[0-9]+)([shmd]?)/\\1/")"
  UNIT="$(echo "$1" | sed -E "s/([\+-]?[0-9]*\.?[0-9]+)([shmd]?)/\\2/")"
  EXPR="$VAL"
  case "$UNIT" in
    "d") EXPR+=" * 24";&
    "h") EXPR+=" * 60" ;&
    "m") EXPR+=" * 60";;
  esac
  
  TOT=$(bc <<< "$TOT + ( $EXPR )")
  shift
done
echo "$TOT"
exit 0

