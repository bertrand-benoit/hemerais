#!/bin/bash
#
# Author: Bertrand BENOIT <projettwk@users.sourceforge.net>
# Version: 1.0
# Description: light Java Sound Player.
#
# Usage: see usage function.

#########################
## CONFIGURATION
# general
currentDir=$( dirname "$( which "$0" )" )
installDir=$( dirname "$currentDir" )
source "$installDir/scripts/setEnvironment.sh"

#########################
## Functions
# usage: usage
function usage() {
  echo -e "Usage: $0 -f <sound file> [-hv]"
  echo -e "<sound file>\tpath to sound file"
  echo -e "-v\tactivate the verbose mode"
  echo -e "-h\tshow this usage"
  
  exit 1
}

#########################
## Command line management
verbose=0
while getopts "f:vh" opt
do
 case "$opt" in
        f)      filePath="$OPTARG";;
        v)      verbose=1;;
        h|[?]) usage;;
 esac
done

# Checks binaries availability (checks sound player only if speech output is NOT defined).
[ -z "$filePath" ] && errorMessage "You must specify sound file path"

#########################
## INSTRUCTIONS
[ $verbose -eq 1 ] && additionalProperties="-Dhemera.log.verbose=3" || additionalProperties=""
writeMessage "Launching sound player with $filePath ... " 0
launchJavaTool "hemera.tools.LightSoundPlayer" "$additionalProperties" "$filePath" && echo "done" || echo "error (See $logFile)"
