#!/bin/bash
#
# Author: Bertrand BENOIT <bertrand.benoit@bsquare.no-ip.org>
# Version: 1.0
# Description: uses speech core module to generate speech file from specified text, and speechRecognition core module to decode it.
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
  echo -e "Usage: $0 -t <text> [-I <count>] [-vh]"
  echo -e "<text>\ttext/sentences to speech"
  echo -e "<count>\ttext->speech->text iteration count (default: 1)"
  echo -e "-v\tactivate the verbose mode"
  echo -e "-h\tshow this usage"
  
  exit 1
}


#########################
## Command line management
verbose=0
iterationCount=1
while getopts "t:I:vh" opt
do
 case "$opt" in
        t)      text="$OPTARG";;
        v)      verbose=1;;
        I)      iterationCount="$OPTARG";;
        h|[?]) usage;;
 esac
done

[ -z "$text" ] && usage

#########################
## INSTRUCTIONS
thirdPartyDir="$installDir/thirdParty"
speechDir="$thirdPartyDir/speech"
speechRecognitionDir="$thirdPartyDir/speechRecognition"
additionalOptions=""
[ $verbose -eq 1 ] && additionalOptions="-v"

# We need a specific log file for each iteration for speech recognition
#  core module result log analyzer to see only result of regarded iteration.
# Inform the user.
mainLogFile="$logFile"
echo "See $mainLogFile-X iteration log files" > "$mainLogFile"

textToSpeech="$text"
iteration=1

while [ $iteration -le $iterationCount ]; do
  speechSoundFile="$workDir/$fileDate-speech2Recognition-$iteration.wav"
  speechRecognitionResultFile="$workDir/$fileDate-speech2Recognition-$iteration-result.txt"
  logFile="$mainLogFile-$iteration"

  category="speech2Recognition"
  writeMessage "Iteration $iteration/$iterationCount, text to speech then recognize is '$textToSpeech'"

  # Generates the speech sound file.
  "$speechDir/scripts/speech.sh" $additionalOptions -t "$text" -o "$speechSoundFile" || exit 11

  # Launches speech recognition from wav file.
  "$speechRecognitionDir/scripts/speechRecognition.sh" $additionalOptions -f "$speechSoundFile" -R "$speechRecognitionResultFile"
  
  # Prepares for potential next iteration.
  iteration=$( expr $iteration + 1 )
  textToSpeech=$( cat "$speechRecognitionResultFile" |sed -e 's/[ \t]*([^(]*)$//;' )
done

category="speech2Recognition"
writeMessage "After $iterationCount iterations, text to speech '$text' -> '$textToSpeech'"
