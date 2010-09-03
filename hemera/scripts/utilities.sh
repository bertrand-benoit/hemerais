#!/bin/bash
#
# Author: Bertrand BENOIT <bertrand.benoit@bsquare.no-ip.org>
# Version: 1.0
# Description: provides lots of utilities functions.

#########################
## Global variables
verbose=0
category="general"

#########################
## Functions - various

# usage: writeMessage <message> [<0 or 1>]
# 0: keep on the same line
# 1: move to next line
function writeMessage() {
  local message="$1"
  messageTime=$(date +"%d/%m/%y %H:%M.%S")

  echoOption="-e"
  [ ! -z "$2" ] && [ "$2" -eq 0 ] && echoOption="-ne"

  echo $echoOption "$messageTime  [$category]  $message"
}

# usage: info <message> [<0 or 1>]
# Shows message only if verbose is ON.
function info() {
  [ $verbose -eq 0 ] && return 0
  local message="$1"
  shift
  writeMessage "$message" $*
}

# usage: errorMessage <message> [<exit code>]
# Shows error message and exits.
function errorMessage() {
  local message="$1"
  messageTime=$(date +"%d/%m/%y %H:%M.%S")
  echo -e "$messageTime  [$category]  \E[31m\E[4mERROR\E[0m: $message" >&2
  exit ${2:-100}
}

# usage: checkBin <binary name/path> [<binary name/path2> ... <binary name/path>N]
function checkBin() {
  info "Checking binary: $1"
  which "$1" >/dev/null 2>&1 && return 0
  writeMessage "Unable to find binary $1."
  return 1
}

#########################
## Functions - configuration

# usage: getConfigValue <config key>
function getConfigValue() {
  value=$( grep -re "^$1=" "$configurationFile" |sed -e 's/^[^=]*=//;s/"//g;' )
  [ -z "$value" ] && errorMessage "$1 configuration key not found"
  echo "$value"
}

# usage: getConfigValue <supported values> <value to check>
function checkAvailableValue() {
  [ $( echo "$1" |grep -w "$2" |wc -l ) -eq 1 ]
}
