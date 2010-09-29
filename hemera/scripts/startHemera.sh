#!/bin/bash
#
# Author: Bertrand BENOIT <projettwk@users.sourceforge.net>
# Version: 1.0
# Description: starts Hemera components according to configuration.

#########################
## CONFIGURATION
currentDir=$( dirname "$( which "$0" )" )
installDir=$( dirname "$currentDir" )
category="start"
source "$installDir/scripts/setEnvironment.sh"

CONFIG_KEY="hemera.run"
SUPPORTED_MODE="local client server"

# Gets the mode, and ensures it is a supported one.
hemeraMode=$( getConfigValue "$CONFIG_KEY.mode" ) || exit 100
checkAvailableValue "$SUPPORTED_MODE" "$hemeraMode" || errorMessage "Unsupported mode: $hemeraMode"

# "Not yet implemented" message to help adaptation with potential futur other speech tools.
[[ "$hemeraMode" != "local" ]] && errorMessage "Not yet implemented mode: $hemeraMode"

# Gets activation information.
inputMonitorActivation=$( getConfigValue "$CONFIG_KEY.activation.inputMonitor" ) || exit 100
ioProcessorActivation=$( getConfigValue "$CONFIG_KEY.activation.ioProcessor" ) || exit 100
soundRecorderActivation=$( getConfigValue "$CONFIG_KEY.activation.soundRecorder" ) || exit 100

#########################
## FUNCTIONS
# usage: usage
function usage() {
  echo -e "Usage: $0 -S||-T||-K [-hv]"
  echo -e "-S\tstart Hemera components (like daemons) according to configuration"
  echo -e "-T\tstatus Hemera components (like daemons) according to configuration"
  echo -e "-K\tstop Hemera components (like daemons) according to configuration"
  echo -e "-v\tactivate the verbose mode"
  echo -e "-h\tshow this usage"
  echo -e "\nYou must either start, status or stop Hemera components."

  exit 1
}

#########################
## Command line management
verbose=0
while getopts "STKvh" opt
do
 case "$opt" in
        S) 	action="start";;
        T)      action="status";;
        K)      action="stop";;
        v)      verbose=1;;
        h|[?])  usage;; 
 esac
done

# Ensures action is defined.
[ -z "$action" ] && usage

#########################
## INSTRUCTIONS

# According to Hemera mode.
if [ "$hemeraMode" = "local" ]; then
  # Defines option to use according to action.
  case "$action" in
    start)	option="-S";;
    status)	option="-T";;
    stop)	option="-K";;
    h|[?])	errorMessage "Unknown action: $action";; 
  esac

  # Adds verbose if needed.
  [ $verbose -eq 1 ] && option="-v $option"

  # According to components activation.
  [ "$inputMonitorActivation" = "localhost" ] && "$daemonDir/inputMonitor.sh" $option
  [ "$ioProcessorActivation" = "localhost" ] && "$daemonDir/ioprocessor.sh" $option
  [ "$soundRecorderActivation" = "localhost" ] && "$daemonDir/soundRecorder.sh" $option
fi
