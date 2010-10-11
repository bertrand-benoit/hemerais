#!/bin/bash
#
# Hemera - Intelligent System (https://sourceforge.net/projects/hemerais)
# Copyright (C) 2010 Bertrand Benoit <projettwk@users.sourceforge.net>
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
# Description: starts/status/stops Hemera components according to configuration.

#########################
## CONFIGURATION
currentDir=$( dirname "$( which "$0" )" )
installDir=$( dirname "$currentDir" )
category="start"
source "$installDir/scripts/setEnvironment.sh"

CONFIG_KEY="hemera.run"
SUPPORTED_MODE="local client server"

# Gets the mode, and ensures it is a supported one.
hemeraMode=$( getConfigValue "$CONFIG_KEY.mode" ) || exit $ERROR_CONFIG_VARIOUS
checkAvailableValue "$SUPPORTED_MODE" "$hemeraMode" || errorMessage "Unsupported mode: $hemeraMode"

# "Not yet implemented" message to help adaptation with potential futur other speech tools.
[[ "$hemeraMode" != "local" ]] && errorMessage "Not yet implemented mode: $hemeraMode"

# Gets activation information.
inputMonitorActivation=$( getConfigValue "$CONFIG_KEY.activation.inputMonitor" ) || exit $ERROR_CONFIG_VARIOUS
ioProcessorActivation=$( getConfigValue "$CONFIG_KEY.activation.ioProcessor" ) || exit $ERROR_CONFIG_VARIOUS
soundRecorderActivation=$( getConfigValue "$CONFIG_KEY.activation.soundRecorder" ) || exit $ERROR_CONFIG_VARIOUS

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

  exit $ERROR_USAGE
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
  [ "$inputMonitorActivation" = "localhost" ] && "$h_daemonDir/inputMonitor.sh" $option
  [ "$ioProcessorActivation" = "localhost" ] && "$h_daemonDir/ioprocessor.sh" $option
  [ "$soundRecorderActivation" = "localhost" ] && "$h_daemonDir/soundRecorder.sh" $option
fi
