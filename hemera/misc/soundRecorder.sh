#!/bin/bash
#
# Author: Bertrand BENOIT <projettwk@users.sourceforge.net>
# Version: 1.0
# Description: sound recorder daemon.
#
# Usage: see usage function.

#########################
## CONFIGURATION
# general
currentDir=$( dirname "$( which "$0" )" )
installDir=$( dirname "$currentDir" )
source "$installDir/scripts/setEnvironment.sh"

category="soundRecording"
CONFIG_KEY="hemera.core.speechRecognition"

# sound recorder configuration
soundRecorderBin=$( getConfigPath "$CONFIG_KEY.soundRecorder.path" ) || exit 100
soundRecorderOptions=$( getConfigValue "$CONFIG_KEY.soundRecorder.options" ) || exit 100

# Defines the PID file.
pidFile="$pidDir/soundRecording.pid"

#########################
## Functions
# usage: usage
function usage() {
  echo -e "Usage: $0 -S||-K [-hv]"
  echo -e "-S\tstart sound recording daemon"
  echo -e "-K\tstop sound recording daemon"
  echo -e "-v\tactivate the verbose mode"
  echo -e "-h\tshow this usage"
  echo -e "\nYou must either start or stop the sound recording."
  
  exit 1
}

#########################
## Command line management
MODE_START=1
MODE_STOP=2
MODE_DAEMON=11

# N.B.: the -D option must be only internally used.
verbose=0
while getopts "DSKvh" opt
do
 case "$opt" in
        S)      mode=$MODE_START;;
        K)      mode=$MODE_STOP;;
        D)      mode=$MODE_DAEMON;;
        v)      verbose=1;;
        h|[?]) usage;;
 esac
done

# Ensures mode is defined.
[ -z "$mode" ] && usage

# Checks tools.
checkBin "$soundRecorderBin" || exit 126

#########################
## INSTRUCTIONS
case "$mode" in
  $MODE_DAEMON)
    # Starts the process.
    input="$tmpEventDir/speech%3n.wav"
    startProcess "$pidFile" "$soundRecorderBin" $( eval echo "$soundRecorderOptions" )
  ;;

  $MODE_START)
    # Ensures it is not already running.
    isRunningProcess "$pidFile" "$soundRecorderBin" && writeMessage "Sound recorder daemon is already running." && exit 0
    
    # Starts it, launching this script in daemon mode.
    specificLogFile="$logFile.soundRecorder"
    logFile="$specificLogFile" "$0" -D >"$specificLogFile" 2>&1 &
    writeMessage "Launched Sound recorder daemon."
  ;;

  $MODE_STOP)
    # Ensures it is running.
    ! isRunningProcess "$pidFile" "$soundRecorderBin" && writeMessage "Sound recorder daemon is NOT running." && exit 0
  
    # Stops the process.
    stopProcess "$pidFile" "$soundRecorderBin" || errorMessage "Unable to stop sound recorder."  
    writeMessage "Stopped Sound recorder daemon."
  ;;
  
  [?])  usage;;
esac
