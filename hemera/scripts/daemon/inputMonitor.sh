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
monitorBin=$( getConfigPath "$CONFIG_KEY.path" ) || exit $ERROR_CONFIG_PATH
monitorOptions=$( getConfigValue "$CONFIG_KEY.options" ) || exit $ERROR_CONFIG_VARIOUS

# Defines the PID file.
pidFile="$h_pidDir/inputMonitor.pid"

#########################
## Command line management

# N.B.: the -D option must be only internally used.
# Defines verbose to 0 if not already defined.
verbose=${verbose:-0}
while getopts "DSTKvh" opt
do
 case "$opt" in
        S)
          action="start"

          # Resets the input list.
          rm -f "$h_inputList" && touch "$h_inputList"
          outputFile="$h_inputList"
          newLogFile="$h_logFile"
          export noconsole=1
        ;;
        T)      action="status";;
        K)      action="stop";;
        D)
          action="daemon"
          input="$h_newInputDir/"
          options=$( eval echo "$monitorOptions" )
        ;;
        v)      verbose=1;;
        h|[?])  daemonUsage "$daemonName" ;;
 esac
done

# Ensures action is defined.
[ -z "$action" ] && daemonUsage "$daemonName"

# Checks tools.
checkBin "$monitorBin" || exit $ERROR_CHECK_BIN

#########################
## INSTRUCTIONS

# Manages daemon.
manageDaemon "$action" "$daemonName" "$pidFile" "$monitorBin" "$newLogFile" "$outputFile" "$options"
