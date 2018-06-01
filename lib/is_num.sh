#!/usr/bin/env bash

# is_num.sh checks if a given number is a valid number
# usage is_num.sh possible_number [format_specifier]
# outputs 0, if possible_number is a number, else 1
# errors: EINVAL

MATCH="f"
MATCH_STR=""
USE_DATE="false"

[ "$#" -lt "1" ] || [ "$#" -gt "2" ] &&
  echo "invalid number of arguments" >&2 && exit 22

[ ! -z "$2" ] && MATCH="$2"

case "$MATCH" in
  "uf") MATCH_STR="^[0-9]*\.?[0-9]\+$";;
  "f")  MATCH_STR="^[-+]\?[0-9]*\.\?[0-9]\+$";;
  "ud")  MATCH_STR="^[0-9]\+$";;
  "d")  MATCH_STR="^[-+]\?[0-9]\+$";;
  "ut") MATCH_STR="^\([0-9]*\.\?[0-9]\+[smhd]\?\s\?\)\+$";;
  "dt") MATCH_STR="^\([-+]\?[0-9]\+[smhd]\?\s\?\)\+$";;
  "udt") MATCH_STR="^\([0-9]\+[smhd]\?\s\?\)\+$";;
  "t") MATCH_STR="^\([-+]\?[0-9]*\.\?[0-9]\+[smhd]\?\s\?\)\+$";;
  "date") USE_DATE="true";;
  *) echo "invalid number format specifier" >&2 && exit 22 ;;
esac
 
if $( "${USE_DATE}" ); then
  date -u -d "$1" &>/dev/null
  exit "$?"
fi

grep -q "$MATCH_STR" <<< "$1"
echo "$?"

exit 0

