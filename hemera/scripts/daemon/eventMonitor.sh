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

# tool configuration
notifierBin=$( getConfigPath "$CONFIG_KEY.path" ) || exit 100
notifierOptions=$( getConfigValue "$CONFIG_KEY.options" ) || exit 100

# Defines the PID file.
pidFile="$pidDir/tmpEventMonitor.pid"

#########################
## Functions
# usage: usage
function usage() {
  echo -e "Usage: $0 -S||-K [-hv]"
  echo -e "-S\tstart temporary event monitor daemon"
  echo -e "-K\tstop temporary event monitor daemon"
  echo -e "-v\tactivate the verbose mode"
  echo -e "-h\tshow this usage"
  echo -e "\nYou must either start or stop the temporary event monitor daemon."
  
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
checkBin "$notifierBin" || exit 126

#########################
## INSTRUCTIONS
case "$mode" in
  $MODE_DAEMON)
    # Starts the process.
    input="$tmpEventDir/"
    startProcess "$pidFile" "$notifierBin" $( eval echo "$notifierOptions" )
  ;;

  $MODE_START)
    # Ensures it is not already running.
    isRunningProcess "$pidFile" "$notifierBin" && writeMessage "temporary event monitor daemon is already running." && exit 0
    
    # Starts it, launching this script in daemon mode.
    specificLogFile="$logDir/eventsToManage"
    logFile="$logFile" "$0" -D >"$specificLogFile" 2>&1 &
    writeMessage "Launched temporary event monitor daemon."
  ;;

  $MODE_STOP)
    # Ensures it is running.
    ! isRunningProcess "$pidFile" "$notifierBin" && writeMessage "temporary event monitor daemon is NOT running." && exit 0
  
    # Stops the process.
    stopProcess "$pidFile" "$notifierBin" || errorMessage "Unable to stop temporary event monitor daemon."  
    writeMessage "Stopped temporary event monitor daemon."
  ;;
  
  [?])  usage;;
esac
