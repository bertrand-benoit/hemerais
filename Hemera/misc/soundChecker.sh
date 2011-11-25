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
# Description: checks sound recorder and player according to your configuration.
#
# Usage: see usage function.

#########################
## CONFIGURATION
# general
currentDir=$( dirname "$( which "$0" )" )
installDir=$( dirname "$currentDir" )
category="soundChecker"

# Ensures $installDir/scripts/setEnvironment.sh is reachable.
# It may NOT be the case if user has NOT installed GNU version of which and launched scripts
#  with particular $PWD (for instance launching setupHemera.sh being in the scripts sub directory).
[ ! -f "$installDir/scripts/setEnvironment.sh" ] && echo -e "\E[31m\E[4mERROR\E[0m: failure in path management. Ensure you have a GNU version of 'which' tool (check Hemera documentation)." && exit 1
source "$installDir/scripts/setEnvironment.sh"

#########################
## Functions
# usage: usage
function usage() {
  echo -e "Usage: $0 [-vh]"
  echo -e "-v\tactivate the verbose mode"
  echo -e "-h\tshow this usage"

  exit $ERROR_USAGE
}

#########################
## Command line management
# Defines verbose to 0 if not already defined.
verbose=${verbose:-0}
while getopts "vh" opt
do
 case "$opt" in
        v)      verbose=1;;
        h|[?]) usage;;
 esac
done

## Configuration check.
checkBin "inotifywait"
checkAndSetConfig "hemera.core.speechRecognition.soundRecorder.path" "$CONFIG_TYPE_BIN"
declare -r soundRecorderBin="$h_lastConfig"
checkAndSetConfig "hemera.core.speechRecognition.soundRecorder.options" "$CONFIG_TYPE_OPTION"
declare -r soundRecorderOptions="$h_lastConfig"
checkAndSetConfig "hemera.core.speech.soundPlayer.path" "$CONFIG_TYPE_BIN"
declare -r soundPlayerBin="$h_lastConfig"
checkAndSetConfig "hemera.core.speech.soundPlayer.options" "$CONFIG_TYPE_OPTION"
declare -r soundPlayerOptions="$h_lastConfig"

#########################
## INSTRUCTIONS

pidFile="/tmp/soundChecker.pid"
wDir="/tmp/"$( date +'%s' )"-soundChecker"
output="$wDir/recordedSound.wav"
options=$( eval echo "$soundRecorderOptions" )

mkdir -p "$wDir"
rm -f "$pidFile"

# Manages daemon.
outputFile="$h_logFile.soundRecorder"
writeMessage "Starting sound recorder ... "
( manageDaemon "daemon" "soundChecker" "$pidFile" "$soundRecorderBin" "$outputFile" "$outputFile" "$options" ) &

# Ensures everything is stopped in same time of this script.
trap 'manageDaemon "stop" "soundChecker" "$pidFile" "$soundRecorderBin" "$outputFile" "$outputFile" "$options"; exit 0' INT

writeMessage "At any time you can stop the test with CTRL+C"

# The only way to quit is to CTRL+C.
inputIndex=1
while [ 1 ]; do
  # Important: sounds recorded (and closed) during current sound playing will be ignored, because
  #  inotifywait won't be processing during this time.
  # It is a known limitation which is acceptable -> usually if lots of recorded wav files are created
  #  in few seconds, it means there is a configuration issue.
  # If ever, we want to fix this limitation, it is enough to implement equivalent to:
  #  - inputMonitor which watches for new recorded files and updates corresponding file h_inputList
  #  - ioprocessor which watches h_inputList and manage files one after the other.  

  writeMessage "Speak in your microphone (then ensure there is silence when you have finished)"
  newSoundFile=$( inotifywait -q --format '%f' -e close_write "$wDir" )

  writeMessage "Successfully recorded '$newSoundFile', system will play it"
  input="$wDir/$newSoundFile"
  playerOptions=$( eval echo "$soundPlayerOptions" )
  "$soundPlayerBin" $playerOptions

  sleep 1
done
