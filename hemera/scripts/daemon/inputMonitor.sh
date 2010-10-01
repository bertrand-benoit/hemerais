#!/bin/bash
#
# Author: Bertrand BENOIT <projettwk@users.sourceforge.net>
# Version: 1.0
# Description: input monitor daemon (checks for input and updates a event list which will be process by ioprocessor).
#
# Usage: see usage function.

#########################
## CONFIGURATION
# general
currentDir=$( dirname "$( which "$0" )" )
installDir=$( dirname "$( dirname "$currentDir" )" )
category="inputMonitor"
source "$installDir/scripts/setEnvironment.sh"

CONFIG_KEY="hemera.core.iomanager.inputMonitor"
daemonName="input monitor"

# tool configuration
monitorBin=$( getConfigPath "$CONFIG_KEY.path" ) || exit 100
monitorOptions=$( getConfigValue "$CONFIG_KEY.options" ) || exit 100

# Defines the PID file.
pidFile="$pidDir/inputMonitor.pid"

#########################
## Command line management

# N.B.: the -D option must be only internally used.
verbose=0
while getopts "DSTKvh" opt
do
 case "$opt" in
        S)
          action="start"

          # Resets the input list.
          rm -f "$inputList" && touch "$inputList"
          outputFile="$inputList"
          newLogFile="$logFile"
        ;;
        T)      action="status";;
        K)      action="stop";;
        D)
          action="daemon"
          input="$newInputDir/"
          options=$( eval echo "$monitorOptions" )
        ;;
        v)      verbose=1;;
        h|[?])  daemonUsage "$daemonName" ;;
 esac
done

# Ensures action is defined.
[ -z "$action" ] && daemonUsage "$daemonName"

# Checks tools.
checkBin "$monitorBin" || exit 126

#########################
## INSTRUCTIONS

# Manages daemon.
manageDaemon "$action" "$daemonName" "$pidFile" "$monitorBin" "$newLogFile" "$outputFile" "$options"
