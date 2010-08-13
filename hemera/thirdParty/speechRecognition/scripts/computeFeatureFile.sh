#!/bin/bash
#
# Author: Bertrand BENOIT <bertrand.benoit@bsquare.no-ip.org>
# Version: 1.0
# Description: computes sound feature file, needed by sphinx3.
#
# Usage: see usage function.

#########################
## CONFIGURATION
# general
currentDir=$( dirname "$( which "$0" )" )
installDir=$( dirname "$( dirname "$( dirname "$currentDir" )" )" )
source "$installDir/scripts/setEnvironment.sh"

# Binary configuration.
soundConverter="$currentDir/../bin/wave2feat"

#########################
## Functions
# usage: usage
function usage() {
  echo -e "Usage: $0 -f <sound file> [-vh]"
  echo -e "<file>\tthe sound file to manage"
  echo -e "-v\t\tactivate the verbose mode"
  echo -e "-h\t\tshow this usage"
  
  exit 1
}


#########################
## Command line management
verbose=0
while getopts "f:vh" opt
do
 case "$opt" in
        f)      soundFile="$OPTARG";;
        v)      verbose=1;;
        h|[?]) usage;;
 esac
done

[ -z "$soundFile" ] && usage
[ ! -f "$soundFile" ] && echo -e "$soundFile not found." >&2 && exit 1

#########################
## INSTRUCTIONS
"$soundConverter" -i "$soundFile" -o "$soundFile".mfc -raw yes # -srate 16000 -lowerf 130 -upperf 6800 -dither yes -feat sphinx
