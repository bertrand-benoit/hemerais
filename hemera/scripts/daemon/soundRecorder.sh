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
installDir=$( dirname "$( dirname "$currentDir" )" )
source "$installDir/scripts/setEnvironment.sh"

category="soundRecording"
CONFIG_KEY="hemera.core.speechRecognition"
daemonName="sound recorder"

# sound recorder configuration
soundRecorderBin=$( getConfigPath "$CONFIG_KEY.soundRecorder.path" ) || exit 100
soundRecorderOptions=$( getConfigValue "$CONFIG_KEY.soundRecorder.options" ) || exit 100

# Defines the PID file.
pidFile="$pidDir/soundRecording.pid"

#########################
## Command line management

# N.B.: the -D option must be only internally used.
verbose=0
while getopts "DSTKvh" opt
do
 case "$opt" in
        S)
          action="start"
          outputFile="$logFile.soundRecorder"
          newLogFile="$outputFile"
        ;;
        T)      action="status";;
        K)      action="stop";;
        D)      
          action="daemon"
          input="$tmpEventDir/speech%3n.wav"
          options=$( eval echo "$soundRecorderOptions" )
        ;;
        v)      verbose=1;;
        h|[?])  daemonUsage "$daemonName" ;;
 esac
done

# Ensures action is defined.
[ -z "$action" ] && daemonUsage "$daemonName"

# Checks tools.
checkBin "$soundRecorderBin" || exit 126

#########################
## INSTRUCTIONS

# Manages daemon.
manageDaemon "$action" "$daemonName" "$pidFile" "$soundRecorderBin" "$newLogFile" "$outputFile" "$options"
