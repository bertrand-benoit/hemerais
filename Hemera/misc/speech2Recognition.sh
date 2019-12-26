#!/bin/bash
#
# Hemera - Intelligent System (https://github.com/bertrand-benoit/hemerais)
# Copyright (C) 2010-2020 Bertrand Benoit <hemerais@bertrand-benoit.net>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, see http://www.gnu.org/licenses
# or write to the Free Software Foundation,Inc., 51 Franklin Street,
# Fifth Floor, Boston, MA 02110-1301  USA
#
# Version: 1.0
# Description: uses speech core module to generate speech file from specified text, and speechRecognition core module to decode it.
#
# Usage: see usage function.

#########################
## CONFIGURATION
# general
currentDir=$( dirname "$( which "$0" )" )
installDir=$( dirname "$currentDir" )
CATEGORY="speech2Recognition"

# Ensures $installDir/scripts/setEnvironment.sh is reachable.
# It may NOT be the case if user has NOT installed GNU version of which and launched scripts
#  with particular $PWD (for instance launching setupHemera.sh being in the scripts sub directory).
[ ! -f "$installDir/scripts/setEnvironment.sh" ] && echo -e "\E[31m\E[4mERROR\E[0m: failure in path management. Ensure you have a GNU version of 'which' tool (check Hemera documentation)." && exit 1
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

  exit $ERROR_USAGE
}


#########################
## Command line management
# Defines VERBOSE to 0 if not already defined.
VERBOSE=${VERBOSE:-0}
iterationCount=1
while getopts "t:I:vh" opt
do
 case "$opt" in
        t)      text="$OPTARG";;
        v)      VERBOSE=1;;
        I)      iterationCount="$OPTARG";;
        h|[?]) usage;;
 esac
done

[ -z "${text:-}" ] && usage

#########################
## INSTRUCTIONS
speechDir="$h_coreDir/speech"
speechRecognitionDir="$h_coreDir/speechRecognition"
additionalOptions=""
[ $VERBOSE -eq 1 ] && additionalOptions="-v"

# We need a specific log file for each iteration for speech recognition
#  core module result log analyzer to see only result of regarded iteration.
# Inform the user.
mainLogFile="$LOG_FILE"
echo "See $mainLogFile"."X iteration log files" > "$mainLogFile"

textToSpeech="$text"
iteration=1

while [ $iteration -le $iterationCount ]; do
  speechSoundFile="$h_workDir/$h_fileDate-speech2Recognition-$iteration.wav"
  speechRecognitionResultFile="$h_workDir/$h_fileDate-speech2Recognition-$iteration-result.txt"
  LOG_FILE="$mainLogFile.$iteration"

  CATEGORY="speech2Recognition"
  writeMessage "Iteration $iteration/$iterationCount, text to speech then recognize is '$textToSpeech'"

  # Generates the speech sound file.
  "$speechDir/speech.sh" $additionalOptions -t "$text" -o "$speechSoundFile" || exit $ERROR_CORE_MODULE

  # Launches speech recognition from wav file.
  "$speechRecognitionDir/speechRecognition.sh" $additionalOptions -f "$speechSoundFile" -R "$speechRecognitionResultFile" || exit $ERROR_CORE_MODULE

  # Ensures there was a result file.
  [ ! -f "$speechRecognitionResultFile" ] && errorMessage "Speech recognition produces NO result file." $ERROR_CORE_MODULE

  # Prepares for potential next iteration.
  let iteration++
  textToSpeech=$( cat "$speechRecognitionResultFile" |sed -e 's/[ \t]*([^(]*)$//;' )
done

CATEGORY="speech2Recognition"
writeMessage "After $iterationCount iterations, text to speech '$text' -> '$textToSpeech'"
