#!/bin/bash
#
# Hemera - Intelligent System (https://sourceforge.net/projects/hemerais)
# Copyright (C) 2010 Bertrand Benoit <projettwk@users.sourceforge.net>
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
# Description: processes the specified input and moves it to err/done according to result.
#
# Usage: see usage function.

#########################
## CONFIGURATION
# general
currentDir=$( dirname "$( which "$0" )" )
installDir=$( dirname "$currentDir" )
category="processInput"
source "$installDir/scripts/setEnvironment.sh"

speechRecognitionScript="$installDir/thirdParty/speechRecognition/scripts/speechRecognition.sh"
speechScript="$installDir/thirdParty/speech/scripts/speech.sh"

#########################
## Functions
# usage: usage
function usage() {
  echo -e "Usage: $0 -i <input name> [-S <input string>] [-hv]"
  echo -e "<input name>\tthe name of the input to process (relative to the new input directory)"
  echo -e "<input string>\tthe string presentation to use in message"
  echo -e "-v\tactivate the verbose mode"
  echo -e "-h\tshow this usage"

  exit 1
}

# usage: notifyProcessInput <input name>
function notifyProcessInput() {
  info "$inputString: moving from new to processing input directory"
  mv -f "$newInputDir/$inputName" "$curInputDir"
}


# usage: notifyProcessInput <input name>
function notifyDoneInput() {
  info "$inputString: moving from processing input directory to done one"
  mv -f "$curInputDir/$inputName" "$doneInputDir"
  exit 0
}

# usage: notifyErrInput <input name>
function notifyErrInput() {
  info "$inputString: moving from processing input directory to error one"
  mv -f "$curInputDir/$inputName" "$errInputDir"
  exit 1
}

# usage: manageRecognitionResult <input path>
function manageRecognitionResult() {
  local _inputPath="$1"

  # Removes wav file information from input file.
  # If there is finally nothing to say, replace with an default speech.
  sed -i 's/([^)]*)$//' "$_inputPath"
  sed -i "$( echo "s/^$/${UNKNOWN_COMMAND}/" )" "$_inputPath"

  # TODO: interpret potential command.

  # Speech.
  logFile="$logFile" noconsole=1 "$speechScript" -f "$_inputPath" && notifyDoneInput || notifyErrInput
}

#########################
## Command line management

verbose=0
while getopts "i:S:vh" opt
do
 case "$opt" in
        i)      inputName="$OPTARG";;
        S)      inputString="$OPTARG";;
        v)      verbose=1;;
        h|[?])  usage ;; 
 esac
done

[ -z "$inputName" ] && usage
[ -z "$inputString" ] && inputString="undefinedInput"

# Ensures the input (still) exists.
[ ! -f "$newInputDir/$inputName" ] && errorMessage "$inputString: $inputName not found"

#########################
## INSTRUCTIONS

writeMessage "$inputString: managing supported input $inputName (specific log file: $logFile)"
notifyProcessInput
curInputPath="$curInputDir/$inputName"

# According to the type
inputType=${inputName/_*/}
case "$inputType" in
  recordedSpeech)
    writeMessage "$inputString: launching speech recognition on $inputName"
    logFile="$logFile" noconsole=1 "$speechRecognitionScript" -F -f "$curInputPath" -R "$newInputDir/recognitionResult_$inputName.txt" && notifyDoneInput || notifyErrInput
  ;;

  recognitionResult)
    writeMessage "$inputString: launching speech on $inputName"
    manageRecognitionResult "$curInputPath"
  ;;

  [?]) errorMessage "$inputString: unknow type, $inputName will be ignored";;
esac
