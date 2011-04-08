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

# Gets the mode, and ensures it is a supported one.
moduleMode=$( getConfigValue "$CONFIG_KEY.mode" ) || exit $ERROR_CONFIG_VARIOUS
checkAvailableValue "$SUPPORTED_MODE" "$moduleMode" || errorMessage "Unsupported mode: $moduleMode" $ERROR_MODE

# "Not yet implemented" message to help adaptation with potential futur other speechRecognition tools.
[[ "$moduleMode" != "sphinx3" ]] && errorMessage "Not yet implemented mode: $moduleMode" $ERROR_MODE

# Gets functions specific to mode.
source "$currentDir/speechRecognition_$moduleMode"

LOG_FILE_END="SPEECH_RECOGNITION_COMPLETED"

# Tool configuration.
soundConverterBin=$( getConfigPath "$CONFIG_KEY.soundConverter.path" ) || exit $ERROR_CONFIG_PATH
soundConverterOptions=$( getConfigValue "$CONFIG_KEY.soundConverter.options" ) || exit $ERROR_CONFIG_VARIOUS

#########################
## Functions
# usage: usage
function usage() {
  echo -e "Usage: $0 [-f <sound file>|-l <list file>|-d <sound files dir>] [-P <pattern>] [-R <result file>] [-Fvh]"
  echo -e "<sound file>\tthe sound file to decode"
  echo -e "<list file>\tthe file containing the list of sound files to decode"
  echo -e "<s. files dir>\tthe directory containing sound files to decode"
  echo -e "<pattern>\tthe speech sound file pattern (Default: $DEFAULT_SPEECH_FILE_PATTEN)"
  echo -e "<result file>\tpath to result file"
  echo -e "-F\t\tforce [re]creation of intermediate files"
  echo -e "-v\t\tactivate the verbose mode"
  echo -e "-h\t\tshow this usage"
  echo -e "\nYou must use one of the following option: -f, -l or -d."
  exit $ERROR_USAGE
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
  ! speechRecognitionFromList "$_preparedSoundFileList" "$_resultFile" && markLogFileEnd && exit $ERROR_CORE_MODULE
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
# N.B.: -Z is an hidden option allowing to analyze specified log file;
#  it must be used for internal purposes only.
while getopts "f:l:d:Z:P:R:Fvh" opt
do
 case "$opt" in
        f)      mode=$SOURCE_MODE_SOUND_FILE; path="$OPTARG";;
        l)      mode=$SOURCE_MODE_LIST_FILE; path="$OPTARG";;
        d)      mode=$SOURCE_MODE_DIR; path="$OPTARG";;
        P)      speechFilePattern="$OPTARG";;
        R)      resultFile="$OPTARG";;
        F)      force=1;;
        v)      verbose=1;;
        Z)      logToAnalyze="$OPTARG";;
        h|[?])  usage;;
 esac
done

# Checks if special mode or analyzing log file.
if [ ! -z "$logToAnalyze" ]; then
  analyzeLog && exit 0 || exit $ERROR_SR_ANALYZE
fi

checkBin "$soundConverterBin" || exit $ERROR_CHECK_BIN
checkConfiguration || exit $ERROR_CHECK_CONFIG

[ -z "$mode" ] && usage
[ -z "$path" ] && usage
[ ! -e "$path" ] && errorMessage "$path not found." $ERROR_BAD_CLI
[ -z "$speechFilePattern" ] && speechFilePattern="$DEFAULT_SPEECH_FILE_PATTEN"

#########################
## INSTRUCTIONS
# Moves to root because all files are regarded as relative to it.
cd /

# According to the mode, create a sound file list.
sourceSoundFileList="$h_workDir/$h_fileDate-sourceSoundFileList.txt"
rm -f "$sourceSoundFileList"
case "$mode" in
  $SOURCE_MODE_SOUND_FILE)
    echo "$path" > "$sourceSoundFileList";;
  $SOURCE_MODE_LIST_FILE)
    cat "$path" > "$sourceSoundFileList";;
  $SOURCE_MODE_DIR)
    rm -f "$sourceSoundFileList"
    for rawFileRaw in $( find "$path" -type f -name "$speechFilePattern" |sed -e 's/[ \t]/£/g;' ); do
      rawFile=$( echo "$rawFileRaw" |sed 's/£/ /g;' )
      echo "$rawFile" >> "$sourceSoundFileList"
    done;;
  [?])  usage;;
esac

# Prepares the destination sound file list.
preparedSoundFileList="$h_workDir/$h_fileDate-preparedSoundFileList.txt"
prepareSoundFileList "$sourceSoundFileList" "$preparedSoundFileList" || exit $ERROR_SR_PREPARE

# Launches the speech recognition on the list.
manageSpeechRecognition "$preparedSoundFileList" "$resultFile"

# Waits for result log analyzer stop.
analyzeLogStopWait
