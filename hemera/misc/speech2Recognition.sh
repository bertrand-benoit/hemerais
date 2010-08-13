#!/bin/bash
#
# Author: Bertrand BENOIT <bertrand.benoit@bsquare.no-ip.org>
# Version: 1.0
# Description: uses speech module to generate specified text, and speechRecognition module to decode it.
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
  echo -e "Usage: $0 -t <text> [-vh]"
  echo -e "<text>\ttext/sentences to speech"
  echo -e "-v\t\tactivate the verbose mode"
  echo -e "-h\t\tshow this usage"
  
  exit 1
}


#########################
## Command line management
verbose=0
while getopts "t:vh" opt
do
 case "$opt" in
        t)      text="$OPTARG";;
        v)      verbose=1;;
        h|[?]) usage;;
 esac
done

[ -z "$text" ] && usage

#########################
## INSTRUCTIONS
thirdPartyDir="$installDir/thirdParty"
speechDir="$thirdPartyDir/speech"
speechRecognitionDir="$thirdPartyDir/speechRecognition"
speechSoundFile="$workDir/$fileDate-speech2Recognition.wav"
additionalOptions=""
[ $verbose -eq 1 ] && additionalOptions="-v"

# Generates the sound.
writeMessage "Generating speech sound file ... " 0
! "$speechDir/scripts/speech.sh" $additionalOptions -t "$text" -o "$speechSoundFile" >> "$logFile" 2>&1 && echo -e "error" >&2 && exit 1

# Launches speech recognition from wav file.
! "$speechRecognitionDir/scripts/speechRecognitionFromWavFile.sh" $additionalOptions -f "$speechSoundFile"
