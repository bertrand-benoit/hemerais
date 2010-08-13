#!/bin/bash
#
# Author: Bertrand BENOIT <bertrand.benoit@bsquare.no-ip.org>
# Version: 1.0
# Description: manages speech recognition from specified wav file.
#
# Usage: see usage function.

#########################
## CONFIGURATION
# general
currentDir=$( dirname "$( which "$0" )" )
installDir=$( dirname "$( dirname "$( dirname "$currentDir" )" )" )
source "$installDir/scripts/setEnvironment.sh"

# Binary configuration.
soundConverter="sox"

#########################
## Functions
# usage: usage
function usage() {
  echo -e "Usage: $0 -f <sound file> [-vh]"
  echo -e "<file>\tthe sound file to decode"
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
        f)      wavFile="$OPTARG";;
        v)      verbose=1;;
        h|[?]) usage;;
 esac
done

[ -z "$wavFile" ] && usage
[ ! -f "$wavFile" ] && echo -e "$wavFile not found." >&2 && exit 1

#########################
## INSTRUCTIONS
rawFile="$wavFile".raw

# Modus operandi
#  1- converts the wav file to signed 16-bit little endian raw file
writeMessage "Converting sound file ... " 0
! "$soundConverter" "$wavFile" -s -r 16000 -c 1 "$rawFile" >> "$logFile" 2>&1 && echo -e "error" >&2 && exit 1
echo "done"

#  2- computes the corresponding feature file
writeMessage "Creating feature sound sound file ... " 0
! "$currentDir/computeFeatureFile.sh" -f "$rawFile" >> "$logFile" 2>&1 && echo -e "error" >&2 && exit 1
echo "done"

#  3- launches the speech recognition on this raw file
resultFile="$workDir/speechRecognitionResult.txt"
writeMessage "Launching speech recognition (result file: $resultFile)... " 0
! "$currentDir/speechRecognition.sh" -ctlcount 1 -utt "$rawFile" -hyp "$resultFile" >> "$logFile" 2>&1 && echo -e "error" >&2 && exit 1
echo "done"
writeMessage "Result: " 0
cat "$resultFile"
