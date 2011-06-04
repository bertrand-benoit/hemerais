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
# Version: 1.1
# Description: manages command line and uses configured tool to perform speech recognition.
#
# Usage: see usage function.

#########################
## CONFIGURATION
# general
myPath="$( which "$0" )"
currentDir=$( dirname "$myPath" )
installDir=$( dirname "$( dirname "$( dirname "$currentDir" )" )" )
category="speechRecognition"
source "$installDir/scripts/setEnvironment.sh"

CONFIG_KEY="hemera.core.speechRecognition"
SUPPORTED_MODE="sphinx3"
DEFAULT_SPEECH_FILE_PATTEN="*.wav"

LOG_FILE_END="SPEECH_RECOGNITION_COMPLETED"

#########################
## Functions
# usage: usage
function usage() {
  echo -e "Usage: $0 [-f <sound file>|-l <list file>|-d <sound files dir>] [-P <pattern>] [-R <result file>] [-FTvhX]"
  echo -e "<sound file>\tthe sound file to decode"
  echo -e "<list file>\tthe file containing the list of sound files to decode (must only contain ABSOLUTE paths)"
  echo -e "<s. files dir>\tthe directory containing sound files to decode"
  echo -e "<pattern>\tthe speech sound file pattern (Default: $DEFAULT_SPEECH_FILE_PATTEN)"
  echo -e "<result file>\tpath to result file"
  echo -e "-X\t\tcheck configuration and quit"
  echo -e "-C\t\tdisable sound conversion from wav to raw (useless if source has already a 16 kHz sample rate)"
  echo -e "-F\t\tforce [re]creation of intermediate files"
  echo -e "-v\t\tactivate the verbose mode"
  echo -e "-h\t\tshow this usage"
  echo -e "\nYou must use one of the following option: -f, -l or -d."
  exit $ERROR_USAGE
}

# usage: getAbsolutePath <path>
function getAbsolutePath() {
  local _path="$1"

  # Checks if it is already an absolute path.
  isAbsolutePath "$_path" && echo "$_path" && return 0

  # Prefixes with current directory.
  echo "$PWD/$_path"
}

# usage: markLogFileEnd
function markLogFileEnd() {
  echo "$LOG_FILE_END" >> "$h_logFile"
}

# usage: startLogAnalyzer
function startLogAnalyzer() {
  writeMessage "Launching result log analyzer ..."
  h_logFile="$h_logFile" "$myPath" -Z "$h_logFile" &
}

# usage: manageSpeechRecognition <prepared sound file list> [<result file>]
function manageSpeechRecognition() {
  local _preparedSoundFileList="$1"
  local _resultFile="$2"

  # Ensures the prepared sound file list is not empty.
  [ ! -s "$_preparedSoundFileList" ] && return 1

  #  3- launches log analyzer.
  startLogAnalyzer

  #  4- launches the speech recognition on the prepared sound file list.
  writeMessage "Launching speech recognition on prepared sound list file $_preparedSoundFileList ..."
  ! speechRecognitionFromList "$_preparedSoundFileList" "$_resultFile" && markLogFileEnd && errorMessage "Speech recognition failed on prepared sound list file $_preparedSoundFileList" $ERROR_CORE_MODULE
  markLogFileEnd
}

#########################
## Command line management
SOURCE_MODE_SOUND_FILE=1
SOURCE_MODE_LIST_FILE=2
SOURCE_MODE_DIR=3
# Defines verbose to 0 if not already defined.
verbose=${verbose:-0}
force=0
convert=1
# N.B.: -Z is an hidden option allowing to analyze specified log file;
#  it must be used for internal purposes only.
while getopts "f:l:d:Z:P:R:CFvhX" opt
do
 case "$opt" in
        X)      checkConfAndQuit=1;;
        f)      mode=$SOURCE_MODE_SOUND_FILE; path="$OPTARG";;
        l)      mode=$SOURCE_MODE_LIST_FILE; path="$OPTARG";;
        d)      mode=$SOURCE_MODE_DIR; path="$OPTARG";;
        P)      speechFilePattern="$OPTARG";;
        R)      resultFile="$OPTARG";;
        C)      convert=0;;
        F)      force=1;;
        v)      verbose=1;;
        Z)      logToAnalyze="$OPTARG";;
        h|[?])  usage;;
 esac
done

## Configuration check.
checkAndSetConfig "$CONFIG_KEY.mode" "$CONFIG_TYPE_OPTION"
moduleMode="$h_lastConfig"
# Ensures configured mode is supported, and then it is implemented.
if ! checkAvailableValue "$SUPPORTED_MODE" "$moduleMode"; then
  # It is not a fatal error if in "checkConfAndQuit" mode.
  _message="Unsupported mode: $moduleMode. Update your configuration."
  [ $checkConfAndQuit -eq 0 ] && errorMessage "$_message"
  warning "$_message"
else
  # It is not a fatal error if in "checkConfAndQuit" mode.
  # "Not yet implemented" message to help adaptation with potential futur mode.
  if [[ "$moduleMode" != "sphinx3" ]]; then
    _message="Not yet implemented mode: $moduleMode"
    [ $checkConfAndQuit -eq 0 ] && errorMessage "$_message" $ERROR_MODE
    warning "$_message"
  fi
fi

checkAndSetConfig "$CONFIG_KEY.soundConverter.path" "$CONFIG_TYPE_BIN"
soundConverterBin="$h_lastConfig"
checkAndSetConfig "$CONFIG_KEY.soundConverter.options" "$CONFIG_TYPE_OPTION"
soundConverterOptions="$h_lastConfig"

# Gets functions specific to mode.
# N.B.: specific configuration will be checked asap the script is sourced.
specModScript="$currentDir/speechRecognition_$moduleMode"
if [ -f "$specModScript" ]; then
  [ $checkConfAndQuit -eq 1 ] && writeMessage "Checking configuration specific to mode '$moduleMode' ..."
  source "$specModScript"
elif [ $checkConfAndQuit -eq 0 ]; then
  errorMessage "Unable to find the core module sub-script '$specModScript'" $ERROR_MODE
fi

[ $checkConfAndQuit -eq 1 ] && exit 0

## Command line arguments check.
# Checks if special mode or analyzing log file.
if [ ! -z "$logToAnalyze" ]; then
  analyzeLog && exit 0 || exit $ERROR_SR_ANALYZE
fi

[ -z "$mode" ] && usage
[ -z "$path" ] && usage
[ ! -e "$path" ] && errorMessage "$path not found." $ERROR_BAD_CLI
[ -z "$speechFilePattern" ] && speechFilePattern="$DEFAULT_SPEECH_FILE_PATTEN"

#########################
## INSTRUCTIONS
# According to the mode, create a sound file list.
sourceSoundFileList="$h_workDir/$h_fileDate-sourceSoundFileList.txt"
rm -f "$sourceSoundFileList"
case "$mode" in
  $SOURCE_MODE_SOUND_FILE)
    # Adds path (ensuring it is an absolute one) to the list.
    getAbsolutePath "$path" > "$sourceSoundFileList";;
  $SOURCE_MODE_LIST_FILE)
    # Removes each path of the list which is NOT absolute.
    for sFilePathRaw in $( cat "$path" |sed -e 's/[ \t]/€/g;' ); do
      sFilePath=$( echo "$sFilePathRaw" |sed 's/€/ /g;' )

      ! isAbsolutePath "$sFilePath" && warning "Ignoring $sFilePath because it is NOT an absolute path." && continue
      echo "$sFilePath" >> "$sourceSoundFileList"
    done;;
  $SOURCE_MODE_DIR)
    # Creates the list of ABSOLUTE paths to the list.
    rm -f "$sourceSoundFileList"
    for rawFileRaw in $( find $( getAbsolutePath "$path" ) -type f -name "$speechFilePattern" |sed -e 's/[ \t]/£/g;' ); do
      rawFile=$( echo "$rawFileRaw" |sed 's/£/ /g;' )
      echo "$rawFile" >> "$sourceSoundFileList"
    done;;
  [?])  usage;;
esac

# Ensures there is at least one file to manage.
[ ! -f "$sourceSoundFileList" ] && errorMessage "There is no sound file to manage." $ERROR_BAD_CLI

# Prepares the destination sound file list.
preparedSoundFileList="$h_workDir/$h_fileDate-preparedSoundFileList.txt"
prepareSoundFileList "$sourceSoundFileList" "$preparedSoundFileList" $convert || exit $ERROR_SR_PREPARE

# Launches the speech recognition on the list.
manageSpeechRecognition "$preparedSoundFileList" "$resultFile"

# Waits for result log analyzer stop.
analyzeLogStopWait
