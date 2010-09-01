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
myPath="$( which "$0" )"
currentDir=$( dirname "$myPath" )
installDir=$( dirname "$( dirname "$( dirname "$currentDir" )" )" )
source "$installDir/scripts/setEnvironment.sh"
controlFile="$workDir/$fileDate-controlFile.txt"
resultFile="$workDir/$fileDate-speechRecognitionResult.txt"

SPECIAL_PROCESS_MARK="-- --specialSRLoga=$fileDate-AnalyzerMark"
LOG_FILE_END="SPEECH_RECOGNITION_COMPLETED"

# Binary configuration.
soundConverter="sox"

#########################
## Functions
# usage: usage
function usage() {
  echo -e "Usage: $0 [-f <sound file>|-l <list file>|-d <sound files dir>] [-vhF]"
  echo -e "<sound file>\tthe sound file to decode"
  echo -e "<list file>\tthe file containing the list of sound files to decode"
  echo -e "<s. files dir>\tthe directory containing sound files to decode"
  echo -e "-F\t\tforce raw and mfc file creation even if destination already exist"
  echo -e "-v\t\tactivate the verbose mode"
  echo -e "-h\t\tshow this usage"
  echo -e "\nYou must use one of the following option: -f, -l or -d."
  exit 1
}

# usage: prepareAudioSource <wav sound file> 
function prepareAudioSource() {
  local wavFile="$1"
  local rawFile="$wavFile".raw
  local mfcFile="$rawFile".mfc

  # Checks if destination mfc file alreazdy exists, force is NOT set.
  if [[ -f "$mfcFile" ]] && [[ $force -eq 0 ]]; then
    writeMessage "Found feature sound file '$mfcFile' (use -F to recreate)."
  else
    # Modus operandi
    #  1- converts the wav file to signed 16-bit little endian raw file
    writeMessage "Converting sound file $wavFile ... " 0
    ! "$soundConverter" "$wavFile" -s -r 16000 -c 1 "$rawFile" >> "$logFile" 2>&1 && echo -e "error" >&2 && return 1
    echo "done"

    #  2- computes the corresponding feature file
    writeMessage "Creating feature sound file for $rawFile ... " 0
    ! "$currentDir/computeFeatureFile.sh" -f "$rawFile" >> "$logFile" 2>&1 && echo -e "error" >&2 && return 1
    echo "done"
  fi

  # Adds it to control file.
  echo "$rawFile" >> "$controlFile"
  return 0
}

# usage: markLogFileEnd
function markLogFileEnd() {
  echo "$LOG_FILE_END" >> "$logFile"
}

# usage: manageSpeechRecognition
function manageSpeechRecognition() {
  # Ensures the control file is not empty.
  [ ! -s "$controlFile" ] && return 1
# controlFile=/tmp/Hemera/1271587852-controlFile.txt
# resultFile=/tmp/Hemera/1271587852-speechRecognitionResult.txt
# logFile=/tmp/Hemera/Logs/10-04-18-12-50-52-Hemera.log

  #  3- launches log analyzer (this script with specific hidden options).
  startLogAnalyzer

  #  4- launches the speech recognition on the built control file.
  writeMessage "Launching speech recognition on control file $controlFile ..."
  ! "$currentDir/speechRecognition.sh" -ctl "$controlFile" && markLogFileEnd && exit 1
  markLogFileEnd
}

# usage: manageSoundFileList <sound list file>
function manageSoundFileList() {
  local _soundListFile="$1"

  # For each sound file.
  rm -f "$controlFile"
  for rawFileRaw in $( cat "$_soundListFile" |sed -e 's/[ \t]/£/g;' ); do
    rawFile=$( echo "$rawFileRaw" |sed 's/£/ /g;' )

    prepareAudioSource "$rawFile"
  done

  # Finally manages the speech recognition.
  manageSpeechRecognition
}

# usage: startLogAnalyzer
function startLogAnalyzer() {
  logFile="$logFile" "$myPath" -Z "$logFile" &
}

# usage: analyzeLog
function analyzeLog() {
  local _tmpAnalyzeLog="$workDir/$fileDate-analyzeLog.tmp"
  local _firstStep=1

  # Performs at least one step, and as much needed until the "log file end" is reached.
  rm -f "$_tmpAnalyzeLog"
  while [[ $_firstStep -eq 1 ]] || [[ $( grep "$LOG_FILE_END" "$logToAnalyze" 2>/dev/null|wc -l ) -eq 0 ]]; do
    sleep 1
    _firstStep=0
    for managedSoundFileRaw in $( grep -re "FWDVIT" "$logToAnalyze" |sed -e 's/^FWDVIT: \([^(]*\)(\([^)]*\))/\2/g;s/[ \t]/£/g;' ); do
      managedSoundFile=$( echo "$managedSoundFileRaw" |sed -e 's/£/ /g' )

      # Checks if the sound file has already been managed.
      [ $( grep "$managedSoundFile" "$_tmpAnalyzeLog" 2>/dev/null|wc -l ) -gt 0 ] && continue

      # Memorizes it has been shown.
      echo "$managedSoundFile" >> "$_tmpAnalyzeLog"

      # Shows information.
      writeMessage "Managed sound file '$managedSoundFile':"
      grep -re "$managedSoundFile" "$logToAnalyze" |grep -E "FWDVIT|stat.c" |grep -v "SUMMARY" |sed -e 's/^FWDVIT: \([^(]*\)(\([^)]*\))/  Result: \1/g;s/^INFO:[^:]*:.\([^(]*\)(\([^)]*\))/  Stats: \1/g;s/[]];/]\n       /g;'
    done
  done
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
while getopts "f:l:d:Z:vhF" opt
do
 case "$opt" in
        f)      mode=$SOURCE_MODE_SOUND_FILE; path="$OPTARG";;
        l)      mode=$SOURCE_MODE_LIST_FILE; path="$OPTARG";;
        d)      mode=$SOURCE_MODE_DIR; path="$OPTARG";;
        v)      verbose=1;;
	F)      force=1;;
        Z)      logToAnalyze="$OPTARG";;
        h|[?])  usage;;
 esac
done

# Checks if special mode or analyzing log file.
if [ ! -z "$logToAnalyze" ]; then
  analyzeLog && exit 0 || exit 127
fi

checkBin "$soundConverter" || exit 126

[ -z "$mode" ] && usage
[ -z "$path" ] && usage
[ ! -e "$path" ] && echo -e "$path not found." >&2 && exit 1

#########################
## INSTRUCTIONS
# Moves to root because all files are regarded as relative to it.
cd /

# According to the mode, create a sound file list.
soundFileList="$workDir/$fileDate-soundFileList.txt"
case "$mode" in
  $SOURCE_MODE_SOUND_FILE)
    echo "$path" > "$soundFileList";;
  $SOURCE_MODE_LIST_FILE)
    cat "$path" > "$soundFileList";;
  $SOURCE_MODE_DIR)
    rm -f "$soundFileList"
    for rawFileRaw in $( find "$path" -type f -name "*.wav" |sed -e 's/[ \t]/£/g;' ); do
      rawFile=$( echo "$rawFileRaw" |sed 's/£/ /g;' )
      echo "$rawFile" >> "$soundFileList"
    done;;
  [?])	usage;;
esac

# Finally requests the management of the sound file list.
manageSoundFileList "$soundFileList"
