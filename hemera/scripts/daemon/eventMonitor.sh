#!/bin/bash
#
# Author: Bertrand BENOIT <projettwk@users.sourceforge.net>
# Version: 1.0
# Description: temporary event monitor daemon (checks for event created in temporary directory, e.g. speech sound file).
#
# Usage: see usage function.

#########################
## CONFIGURATION
# general
currentDir=$( dirname "$( which "$0" )" )
installDir=$( dirname "$( dirname "$currentDir" )" )
source "$installDir/scripts/setEnvironment.sh"

category="eventMonitor"
CONFIG_KEY="hemera.event.fsNotifier"
daemonName="temporary event monitor"

# tool configuration
notifierBin=$( getConfigPath "$CONFIG_KEY.path" ) || exit 100
notifierOptions=$( getConfigValue "$CONFIG_KEY.options" ) || exit 100

# Defines the PID file.
pidFile="$pidDir/tmpEventMonitor.pid"

#########################
## Command line management

# N.B.: the -D option must be only internally used.
verbose=0
while getopts "DSTKvh" opt
do
 case "$opt" in
        S)
          action="start"
          outputFile="$logDir/eventsToManage"
          newLogFile="$logFile"          
        ;;
        T)      action="status";;
        K)      action="stop";;
        D)      
          action="daemon"
          input="$tmpEventDir/"
          options=$( eval echo "$notifierOptions" )
        ;;
        v)      verbose=1;;
        h|[?])  daemonUsage "$daemonName" ;;
 esac
done

# Ensures action is defined.
[ -z "$action" ] && daemonUsage "$daemonName"

# Checks tools.
checkBin "$notifierBin" || exit 126

#########################
## INSTRUCTIONS

# Manages daemon.
manageDaemon "$action" "$daemonName" "$pidFile" "$notifierBin" "$newLogFile" "$outputFile" "$options"
