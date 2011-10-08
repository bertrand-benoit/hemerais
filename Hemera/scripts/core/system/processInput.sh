#!/bin/bash
#
# Hemera - Intelligent System (https://sourceforge.net/projects/hemerais)
# Copyright (C) 2010-2011 Bertrand Benoit <projettwk@users.sourceforge.net>
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
installDir="$currentDir/../../../"
category="processInput"

# Ensures $installDir/scripts/setEnvironment.sh is reachable.
# It may NOT be the case if user has NOT installed GNU version of which and launched scripts
#  with particular $PWD (for instance launching setupHemera.sh being in the scripts sub directory).
[ ! -f "$installDir/scripts/setEnvironment.sh" ] && echo -e "\E[31m\E[4mERROR\E[0m: failure in path management. Ensure you have a GNU version of 'which' tool (check Hemera documentation)." && exit 1
source "$installDir/scripts/setEnvironment.sh"

# Defines path to various scripts.
speechRecognitionScript="$h_coreDir/speechRecognition/speechRecognition.sh"
speechScript="$h_coreDir/speech/speech.sh"
commandScriptDir="$h_coreDir/command"
manageSoundScript="$currentDir/manageSound.sh"

#########################
## Functions
# usage: usage
function usage() {
  echo -e "Usage: $0 -i <input name> [-S <input string>] [-hvX]"
  echo -e "<input name>\tthe name of the input to process (relative to the new input directory)"
  echo -e "<input string>\tthe string presentation to use in message"
  echo -e "-X\tcheck configuration and quit"
  echo -e "-v\tactivate the verbose mode"
  echo -e "-h\tshow this usage"

  exit $ERROR_USAGE
}

# usage: notifyProcessInput
function notifyProcessInput() {
  writeMessage "$inputString: managing supported input $inputName"
  mv -f "$h_newInputDir/$inputName" "$h_curInputDir"
}

# usage: notifyDoneInput ["noExit"]
# Manages input as "done" and then exits script, but if "noExit" is specified.
function notifyDoneInput() {
  local _argument="${1:-}"

  writeMessage "$inputString: successfully managed input $inputName"
  mv -f "$h_curInputDir/$inputName" "$h_doneInputDir"
  [[ "$_argument" == "noExit" ]] && return 0 || exit 0
}

# usage: notifyErrInput ["noExit"]
# Manages input as "error" and then exits script, but if "noExit" is specified.
function notifyErrInput() {
  local _argument="${1:-}"

  writeMessage "$inputString: error while managing input $inputName"
  mv -f "$h_curInputDir/$inputName" "$h_errInputDir"
  # N.B.: if "noExit" is specified, it is very important to return 0, otherwise
  #  a "ko" status of the test will be regarded by the caller, like there was an error.
  [[ "$_argument" == "noExit" ]] && return 0 || exit $ERROR_INPUT_PROCESS
}

# usage: extractRecognitionResult <input path>
function extractRecognitionResult() {
  head -n 1 "$1"
}

# usage: extractRecognitionResultCommand <input path>
function extractRecognitionResultCommand() {
  local _inputPath="$1"
  extractRecognitionResult "$_inputPath" |awk '{print $1}'
}

# usage: extractRecognitionResultArgument <input path>
function extractRecognitionResultArgument() {
  local _inputPath="$1"
  extractRecognitionResult "$_inputPath" |sed -e 's/^[^ \t]*[ \t]//'
}

# usage: extractRecognitionResultWordCount <input path>
function extractRecognitionResultWordCount() {
  local _inputPath="$1"
  extractRecognitionResult "$_inputPath" |wc -w
}

# usage: extractRecognitionResultArgumentN  <input path> [<argument number>]
# If not defined, regarded argument number is 1.
function extractRecognitionResultArgumentN() {
  local _inputPath="$1" argumentNumber=${2:-1}
  extractRecognitionResult "$_inputPath" |awk "{print \$$argumentNumber}"
}

# usage: manageRecognitionResult <input path>
function manageRecognitionResult() {
  local _inputPath="$1"

  # Gets recognized commands mode.
  recoCmdMode=$( getRecoCmdMode ) || exit $ERROR_ENVIRONMENT
 
  # Removes wav file information from input file.
  # If there is finally nothing to say, replace with a default speech.
  sed -i 's/([^)]*)$//' "$_inputPath"

  # Checks if there is still something recognized.
  if [ $( cat "$_inputPath" |grep -vcre "^$" ) -eq 0 ]; then
    logMonitor "/!\ $NOT_RECOGNIZED_COMMAND_I18N"
    speechToSay "$NOT_RECOGNIZED_COMMAND_I18N" "$_inputPath"
    notifyErrInput
  fi

  # Checks if the first word correspond to a command.
  potentialCommand=$( extractRecognitionResultCommand "$_inputPath" )
  wordsCount=$( extractRecognitionResultWordCount "$_inputPath" )

  # Manages special commands like "mode" (e.g. to allow stopping 'parrot' mode).
  if matchesOneOf "${MODE_CMD_PATTERN_I18N[*]}" "$potentialCommand"; then
    source "$commandScriptDir/mode"
    checkCoherence "$_inputPath" "$wordsCount" || notifyErrInput
    execute "$_inputPath" "$inputString" && notifyDoneInput || notifyErrInput
  fi

  # Checks if 'parrot' mode is activated.
  if [ "$recoCmdMode" = "$H_RECO_CMD_MODE_PARROT" ]; then
    speechToSay "$(extractRecognitionResult $_inputPath)" "$_inputPath" "$H_MONITOR_SPEECH_PARROT" && notifyDoneInput || notifyErrInput
    return 0
  fi

  # Attempts to get corresponding mapped command script.
  commandScript=$( getMappedCommand "$potentialCommand" )

  # Manages case command is not found.
  if [ -z "$commandScript" ]; then
    notFoundCommand=$( cat "$_inputPath" |tr -d '\n' )
    errorToSay="$( eval echo "$NOT_FOUND_COMMAND_I18N" )"
    logMonitor "/!\ $errorToSay"
    speechToSay "$errorToSay" "$_inputPath"
    notifyErrInput
    return 0
  fi

  # All is OK, manages the corresponding command script.
  logMonitor "$H_MONITOR_CMD $(extractRecognitionResult $_inputPath)"
  source "$commandScript"
  checkCoherence "$_inputPath" "$wordsCount" || notifyErrInput
  execute "$_inputPath" "$inputString" && notifyDoneInput || notifyErrInput
}

# usage: speechToSay <text> <input path> [<monitor log>]
# input path will be used to produce next input corresponding to what must be said.
# The caller MUST manage final input move (done or error).
function speechToSay() {
  local _text="$1" _inputPath="$2" _monitorMessage="${3:-$H_MONITOR_SPEECH}"
  logMonitor "$_monitorMessage $_text"
  h_logFile="$h_logFile" noconsole=1 "$speechScript" -t "$_text" -o "$h_newInputDir/speech_"$( basename "$_inputPath" )".wav"
}

# usage: speechListPut
function speechListPut() {
  # Puts the current input information in the speech list.
  echo "$inputString£$inputName" >> "$h_speechToPlayList"
}

# usage: speechListGet
function speechListGet() {
  # Gets thex next no-empty speech from the speech list.
  nextSpeech=$( cat "$h_speechToPlayList" |grep -v "^$" |head -n 1 )

  # Checks if it is no-empty (it can be empty if there is no more speech to play).
  if [ ! -z "$nextSpeech" ]; then
    # Removes it from the list.
    setCommand="s/^$nextSpeech$//"
    sed -i "$setCommand" "$h_speechToPlayList"
  fi

  echo "$nextSpeech"
}

# usage: manageSpeech <input path>
# It is important to avoid several speech to be played simultaneously.
function manageSpeech() {
  local _inputPath="$1"

  # Checks if there is already running speech.
  if [ -f "$h_speechRunningLockFile" ]; then
    writeMessage "$inputString: Hemera is already speaking, this input will be managed later"

    # Adds this speech file to the list.
    speechListPut
  else
    # "Locks" to specify speech "is running" (with the pid of this main script
    #  for pause/continue/stop management, and ensures it will be removed
    #  when script is exiting.
    touch "$h_speechRunningLockFile"

    # Manages this speech (and potential following ones).
    while [ 1 ]; do
      "$manageSoundScript" -p "$h_speechRunningPIDFile" -f "$_inputPath" && notifyDoneInput "noExit" || notifyErrInput "noExit"

       # Checks if there is more speech to play (list must exist, and it must not be empty).
       [ ! -s "$h_speechToPlayList" ] && break

       # Extracts the next one, and restores input string and name like they were when
       #  the first management of this input has been requested.
       # It will be played the next iteration.
       nextSpeech=$( speechListGet )
       [ -z "$nextSpeech" ] && break

       export inputString=$( echo "$nextSpeech" |sed -e 's/£.*$//' )
       export inputName=$( echo "$nextSpeech" |sed -e 's/^.*£//' )
       _inputPath="$h_curInputDir/$inputName"
       writeMessage "$inputString: Hemera stops speaking, playing speech awaiting $inputName"
    done

    # Finally removes lock file.
    rm -f "$h_speechRunningLockFile"

    # Removes the list which is now empty.
    rm -f "$h_speechToPlayList"
  fi
}

#########################
## Command line management

# Defines verbose to 0 if not already defined.
verbose=${verbose:-0}
while getopts "i:S:vhX" opt
do
 case "$opt" in
        X)      checkConfAndQuit=1;;
        i)      inputName="$OPTARG";;
        S)      inputString="$OPTARG";;
        v)      verbose=1;;
        h|[?])  usage ;; 
 esac
done

## Configuration check.
# Nothing specific to check.
[ $checkConfAndQuit -eq 1 ] && exit 0

## Command line arguments check.
[ -z "${inputName:-}" ] && usage
[ -z "${inputString:-}" ] && inputString="undefinedInput"

# Ensures the input (still) exists.
[ ! -f "$h_newInputDir/$inputName" ] && errorMessage "$inputString: $inputName not found" $ERROR_BAD_CLI

#########################
## INSTRUCTIONS

notifyProcessInput
curInputPath="$h_curInputDir/$inputName"

# According to the type
inputType=${inputName/_*/}
case "$inputType" in
  mode)
    requestedMode=$( head -n 1 "$curInputPath" |awk '{print $1}' )
    writeMessage "$inputString: updating mode to '$requestedMode'"
    logMonitor "$H_MONITOR_CMD_MODE $requestedMode"
    updateRecoCmdMode "$requestedMode" && notifyDoneInput || notifyErrInput
  ;;

  recordedSpeech)
    writeMessage "$inputString: launching speech recognition on $inputName"
    # N.B.: uses a specific log file to improve efficiencies while post-processing speech recognition.
    logMonitor "$H_MONITOR_SPEECH_RECO" "$inputString"

    # Creates a link to the input, in the temporary directory
    #  (such a way raw and feature files will be created in the temporary directory instead of queue one).
    tmpFileToManage="$h_workDir/$inputName"
    ln -s "$curInputPath" "$tmpFileToManage"
    h_logFile="$h_logFile.$inputString" noconsole=1 "$speechRecognitionScript" -F -f "$tmpFileToManage" -R "$h_newInputDir/recognitionResult_$inputName.txt" && notifyDoneInput || notifyErrInput
  ;;

  recognitionResult)
    writeMessage "$inputString: launching recognition interpretation on $inputName"
    manageRecognitionResult "$curInputPath"
  ;;

  speech)
    writeMessage "$inputString: playing speech $inputName"
    manageSpeech "$curInputPath"
  ;;

  [?]) errorMessage "$inputString: unknow type, $inputName will be ignored" $ERROR_BAD_CLI;;
esac
