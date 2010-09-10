#!/bin/bash
#
# Author: Bertrand BENOIT <projettwk@users.sourceforge.net>
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
source "$installDir/scripts/setEnvironment.sh"

category="speechRecognition"
CONFIG_KEY="hemera.core.speechRecognition"
SUPPORTED_MODE="sphinx3"
DEFAULT_SPEECH_FILE_PATTEN="*.wav"

# Gets the mode, and ensures it is a supported one.
moduleMode=$( getConfigValue "$CONFIG_KEY.mode" ) || exit 100
checkAvailableValue "$SUPPORTED_MODE" "$moduleMode" || errorMessage "Unsupported mode: $moduleMode"

# "Not yet implemented" message to help adaptation with potential futur other speechRecognition tools.
[[ "$moduleMode" != "sphinx3" ]] && errorMessage "Not yet implemented mode: $moduleMode"

# Gets functions specific to mode.
source "$currentDir/speechRecognition_$moduleMode"

LOG_FILE_END="SPEECH_RECOGNITION_COMPLETED"

# Tool configuration.
soundConverterBin=$( getConfigPath "$CONFIG_KEY.soundConverter.path" ) || exit 100
soundConverterOptions=$( getConfigValue "$CONFIG_KEY.soundConverter.options" ) || exit 100

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
  exit 1
}

# usage: markLogFileEnd
function markLogFileEnd() {
  echo "$LOG_FILE_END" >> "$logFile"
}

# usage: startLogAnalyzer
function startLogAnalyzer() {
  writeMessage "Launching result log analyzer ..."
  logFile="$logFile" "$myPath" -Z "$logFile" & 
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
  ! speechRecognitionFromList "$_preparedSoundFileList" "$_resultFile" && markLogFileEnd && exit 1
  markLogFileEnd
}

#########################
## Command line management
SOURCE_MODE_SOUND_FILE=1
SOURCE_MODE_LIST_FILE=2
SOURCE_MODE_DIR=3
verbose=0
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
  analyzeLog && exit 0 || exit 127
fi

checkBin "$soundConverterBin" || exit 126
checkConfiguration || exit 126

[ -z "$mode" ] && usage
[ -z "$path" ] && usage
[ ! -e "$path" ] && errorMessage "$path not found." 1
[ -z "$speechFilePattern" ] && speechFilePattern="$DEFAULT_SPEECH_FILE_PATTEN"

#########################
## INSTRUCTIONS
# Moves to root because all files are regarded as relative to it.
cd /

# According to the mode, create a sound file list.
sourceSoundFileList="$workDir/$fileDate-sourceSoundFileList.txt"
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
preparedSoundFileList="$workDir/$fileDate-preparedSoundFileList.txt"
prepareSoundFileList "$sourceSoundFileList" "$preparedSoundFileList" || exit 3

# Launches the speech recognition on the list.
manageSpeechRecognition "$preparedSoundFileList" "$resultFile"

# Waits for result log analyzer stop.
analyzeLogStopWait
