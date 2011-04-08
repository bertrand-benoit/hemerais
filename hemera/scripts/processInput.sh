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
installDir=$( dirname "$currentDir" )
category="processInput"
source "$installDir/scripts/setEnvironment.sh"

# Defines path to various core module main script.
speechRecognitionScript="$installDir/thirdParty/speechRecognition/scripts/speechRecognition.sh"
speechScript="$installDir/thirdParty/speech/scripts/speech.sh"
manageSoundScript="$installDir/scripts/manageSound.sh"

#########################
## Functions
# usage: usage
function usage() {
  echo -e "Usage: $0 -i <input name> [-S <input string>] [-hv]"
  echo -e "<input name>\tthe name of the input to process (relative to the new input directory)"
  echo -e "<input string>\tthe string presentation to use in message"
  echo -e "-v\tactivate the verbose mode"
  echo -e "-h\tshow this usage"

  exit $ERROR_USAGE
}

# usage: notifyProcessInput
function notifyProcessInput() {
  info "$inputString: moving from new to processing input directory"
  mv -f "$h_newInputDir/$inputName" "$h_curInputDir"
}


# usage: notifyDoneInput [noExit]
# noExit: disable exist after input move.
function notifyDoneInput() {
  info "$inputString: moving from processing input directory to done one"
  mv -f "$h_curInputDir/$inputName" "$h_doneInputDir"
  # N.B.: if the function does not exit, it is very important to return 0, otherwise
  #  the "ko" status of the test will be regarded by the caller, like there was an error.
  [ "$1" != "noExit" ] && exit 0 || return 0
}

# usage: notifyErrInput [noExit]
# noExit: disable exist after input move.
function notifyErrInput() {
  info "$inputString: moving from processing input directory to error one"
  mv -f "$h_curInputDir/$inputName" "$h_errInputDir"
  # N.B.: if the function does not exit, it is very important to return 0, otherwise
  #  the "ko" status of the test will be regarded by the caller, like there was an error.
  [ "$1" != "noExit" ] && exit $ERROR_INPUT_PROCESS || return 0
}

# usage: extractRecognitionResultCommand <input path>
function extractRecognitionResultCommand() {
  local _inputPath="$1"
  head -n 1 "$_inputPath" |awk '{print $1}'
}

# usage: extractRecognitionResultArgument <input path>
function extractRecognitionResultArgument() {
  local _inputPath="$1"
  head -n 1 "$_inputPath" |sed -e 's/^[^ \t]*[ \t]//'
}

# usage: extractRecognitionResultWordCount <input path>
function extractRecognitionResultWordCount() {
  local _inputPath="$1"
  head -n 1 "$_inputPath" |wc -w
}

# usage: extractRecognitionResultArgumentN  <input path> [<argument number>]
# If not defined, regarded argument number is 1.
function extractRecognitionResultArgumentN() {
  local _inputPath="$1" argumentNumber=${2:-1}
  head -n 1 "$_inputPath" |awk "{print \$$argumentNumber}"
}

# usage: manageRecognitionResult <input path>
function manageRecognitionResult() {
  local _inputPath="$1"

  # Gets Hemera mode.
  hemeraMode=$( getHemeraMode ) || exit $ERROR_ENVIRONMENT
 
  # Removes wav file information from input file.
  # If there is finally nothing to say, replace with a default speech.
  sed -i 's/([^)]*)$//' "$_inputPath"

  # Checks if there is still something recognized.
  if [ $( cat "$_inputPath" |grep -v "^$" |wc -l ) -eq 0 ]; then
    speechToSay "$NOT_RECOGNIZED_COMMAND_I18N" "$_inputPath"
    notifyErrInput
  fi

  # Checks if the first word correspond to a command.
  potentialCommand=$( extractRecognitionResultCommand "$_inputPath" )
  wordsCount=$( extractRecognitionResultWordCount "$_inputPath" )

  # Checks if the first argument matches one of the internationalized command.
  if matchesOneOf "${MODE_CMD_PATTERN_I18N[*]}" "$potentialCommand"; then
    # Ensures there is at least but no more than one argument.
    if [ $wordsCount -ne 2 ]; then
      speechToSay "$MODE_CMD_BAD_USE_I18N" "$_inputPath"
      notifyErrInput
    else
      writeMessage "$inputString: MODE command detected -> checking requested mode"

      # Gets the requested mode and ensures it is a supported one.
      requestedMode=$( extractRecognitionResultArgumentN "$_inputPath" 2 )
      if ! checkAvailableValue "${HEMERA_SUPPORTED_MODES_I18N[*]}" "$requestedMode"; then
        badMode="$requestedMode"
        supportedMode=$( echo "${HEMERA_SUPPORTED_MODES_I18N[*]}" |sed -e 's/[ ]/; /g;' )
        speechToSay "$( eval echo "$MODE_CMD_BAD_MODE_I18N" )" "$_inputPath"
        notifyErrInput
      else
        # Generates a new input defining the mode -> it is important that existing new/current input are managed before this mode is
        #  activated.
        writeMessage "$inputString: mode $requestedMode supported -> preparing mode update"
        modeToActivate "$requestedMode" "$_inputPath" && notifyDoneInput || notifyErrInput
      fi
    fi
  elif matchesOneOf "${SAY_CMD_PATTERN_I18N[*]}" "$potentialCommand"; then
    # Ensures Hemera is not in parrot mode (in which case there is nothing to do there).
    if [[ "$hemeraMode" != "$HEMERA_MODE_PARROT" ]]; then
      # Ensures there is at least one argument.
      if [ $wordsCount -lt 2 ]; then
        speechToSay "$SAY_CMD_BAD_USE_I18N" "$_inputPath"
        notifyErrInput
      else
        whatToSay=$( extractRecognitionResultArgument "$_inputPath" )
        writeMessage "$inputString: SAY command detected -> preparing what to say: $whatToSay"
        speechToSay "$whatToSay" "$_inputPath" && notifyDoneInput || notifyErrInput
      fi
    fi
  elif matchesOneOf "${SEARCH_CMD_PATTERN_I18N[*]}" "$potentialCommand"; then
    # Ensures Hemera is not in parrot mode (in which case there is nothing to do there).
    if [[ "$hemeraMode" != "$HEMERA_MODE_PARROT" ]]; then
      # Ensures there is at least one argument.
      if [ $wordsCount -lt 2 ]; then
        speechToSay "$SEARCH_CMD_BAD_USE_I18N" "$_inputPath"
        notifyErrInput
      else
        termToDefine=$( extractRecognitionResultArgument "$_inputPath" )
        writeMessage "$inputString: SEARCH command detected -> starting definition search about: $termToDefine"
        h_logFile="$h_logFile" noconsole=1 "$speechScript" -d "$termToDefine" -o "$h_newInputDir/speech_"$( basename "$_inputPath" )".wav" && notifyDoneInput || notifyErrInput
      fi
    fi
  elif matchesOneOf "${PAUSE_CMD_PATTERN_I18N[*]}" "$potentialCommand"; then
    # Ensures Hemera is not in parrot mode (in which case there is nothing to do there).
    if [[ "$hemeraMode" != "$HEMERA_MODE_PARROT" ]]; then
      # Ensures there is no argument.
      if [ $wordsCount -ne 1 ]; then
        speechToSay "$PAUSE_CMD_BAD_USE_I18N" "$_inputPath"
        notifyErrInput
      else
        writeMessage "$inputString: PAUSE command detected -> pausing current speech, if any"
        "$manageSoundScript" -p "$h_speechRunningPIDFile" -P && notifyDoneInput || notifyErrInput
      fi
    fi
  elif matchesOneOf "${CONTINUE_CMD_PATTERN_I18N[*]}" "$potentialCommand"; then
    # Ensures Hemera is not in parrot mode (in which case there is nothing to do there).
    if [[ "$hemeraMode" != "$HEMERA_MODE_PARROT" ]]; then
      # Ensures there is no argument.
      if [ $wordsCount -ne 1 ]; then
        speechToSay "$CONTINUE_CMD_BAD_USE_I18N" "$_inputPath"
        notifyErrInput
      else
        writeMessage "$inputString: CONTINUE command detected -> continuing last paused speech, if any"
        "$manageSoundScript" -p "$h_speechRunningPIDFile" -C && notifyDoneInput || notifyErrInput
      fi
    fi
  elif matchesOneOf "${STOP_CMD_PATTERN_I18N[*]}" "$potentialCommand"; then
    # Ensures Hemera is not in parrot mode (in which case there is nothing to do there).
    if [[ "$hemeraMode" != "$HEMERA_MODE_PARROT" ]]; then
      # Ensures there is no argument.
      if [ $wordsCount -ne 1 ]; then
        speechToSay "$STOP_CMD_BAD_USE_I18N" "$_inputPath"
        notifyErrInput
      else
        writeMessage "$inputString: STOP command detected -> stopping last paused speech, if any"
        "$manageSoundScript" -p "$h_speechRunningPIDFile" -S && notifyDoneInput || notifyErrInput
      fi
    fi
  fi

  # If no command has been found:
  #  - in parrot mode, speech recognition must be speech by Hemera
  #  - otherwise, an error must be produced.
  if [ "$hemeraMode" = "$HEMERA_MODE_PARROT" ]; then
    h_logFile="$h_logFile" noconsole=1 "$speechScript" -f "$_inputPath" -o "$h_newInputDir/speech_"$( basename "$_inputPath" )".wav" && notifyDoneInput || notifyErrInput
  else
    notFoundCommand=$( cat "$_inputPath" |tr -d '\n' )
    speechToSay "$( eval echo "$NOT_FOUND_COMMAND_I18N" )" "$_inputPath"
    notifyErrInput
  fi
}

# usage: modeToActivate <mode> <input path>
function modeToActivate() {
  local _mode="$1" _inputPath="$2"

  # Generates an input for informing of the update of the mode.
  speechToSay "Activation du mode $_mode" "$_inputPath"

  # Generates an input for updating the mode.
  echo "$_mode" > "$h_newInputDir/mode_"$( basename "$_inputPath" )".txt"
}

# usage: speechToSay <text> <input path>
# input path will be used to produce next input corresponding to what must be said.
function speechToSay() {
  h_logFile="$h_logFile" noconsole=1 "$speechScript" -t "$1" -o "$h_newInputDir/speech_"$( basename "$2" )".wav"
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

    # Manages this speech (and potential following ones).
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
[ ! -f "$h_newInputDir/$inputName" ] && errorMessage "$inputString: $inputName not found" $ERROR_BAD_CLI

#########################
## INSTRUCTIONS

writeMessage "$inputString: managing supported input $inputName (specific log file: $h_logFile)"
notifyProcessInput
curInputPath="$h_curInputDir/$inputName"

# According to the type
inputType=${inputName/_*/}
case "$inputType" in
  mode)
    requestedMode=$( head -n 1 "$curInputPath" |awk '{print $1}' )
    writeMessage "$inputString: updating mode to '$requestedMode'"
    updateHemeraMode "$requestedMode" && notifyDoneInput || notifyErrInput
  ;;

  recordedSpeech)
    writeMessage "$inputString: launching speech recognition on $inputName"
    h_logFile="$h_logFile" noconsole=1 "$speechRecognitionScript" -F -f "$curInputPath" -R "$h_newInputDir/recognitionResult_$inputName.txt" && notifyDoneInput || notifyErrInput
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
