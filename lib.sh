#!/usr/bin/env bash

# this is the only file that needs to know about project structure

LIB_FOLDER="lib"

function is_num {
  "$LIB_FOLDER/is_num.sh" $@
}

function sec_to_time {
  "$LIB_FOLDER/sec_to_time.sh" $@
}

function time_to_sec {
  "$LIB_FOLDER/time_to_sec.sh" $@
}

