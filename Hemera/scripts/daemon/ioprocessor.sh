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
# Description: input/output processor daemon (controls various Hemera [core] modules according to input).
#
# Usage: see usage function.

#########################
## CONFIGURATION
# general
currentDir=$( dirname "$( which "$0" )" )
installDir=$( dirname "$( dirname "$currentDir" )" )
category="IOProcessor"
source "$installDir/scripts/setEnvironment.sh"

CONFIG_KEY="hemera.core.iomanager.ioProcessorMonitor"
daemonName="input/output processor"

# tool configuration
ioprocessorBin="$0"

# Defines the PID file.
pidFile="$h_pidDir/ioProcessor.pid"

# Defines path to various scripts.
processInputScript="$h_coreDir/system/processInput.sh"

#########################
## Command line management

# N.B.: the -D (for daemon) option must be only internally used.
# N.B.: the -R (for run) option must be only internally used.
# Defines verbose to 0 if not already defined.
verbose=${verbose:-0}
while getopts "XSTKDRvh" opt
do
 case "$opt" in
        X) checkConfAndQuit=1;;
        S)
          # Removes potential speech running lock file, and speech to play list.
          rm -f "$h_speechRunningLockFile" "$h_speechToPlayList"
          action="start"
          newLogFile="$h_logFile"
          outputFile="$newLogFile"
        ;;
        T)      action="status";;
        K)      action="stop";;
        D)      action="daemon";;
        R)      action="run";;

        v)      verbose=1;;
        h|[?])  daemonUsage "$daemonName" ;; 
 esac
done

## Configuration check.
checkAndSetConfig "$CONFIG_KEY.path" "$CONFIG_TYPE_BIN"
monitorBin="$h_lastConfig"
checkAndSetConfig "$CONFIG_KEY.options" "$CONFIG_TYPE_OPTION"
monitorOptions="$h_lastConfig"

[ $checkConfAndQuit -eq 1 ] && exit 0

## Command line arguments check.
# Ensures action is defined.
[ -z "$action" ] && daemonUsage "$daemonName"

#########################
## INSTRUCTIONS

if [ "$action" = "daemon" ]; then
  # Launches this script as daemon, used the -R option for core to run.
  options="$DAEMON_SPECIAL_RUN_ACTION"
fi

# Manages all action.
manageDaemon "$action" "$daemonName" "$pidFile" "$ioprocessorBin" "$newLogFile" "$outputFile" "$options"

# Exists but if in "run" action.
[[ "$action" != "run" ]] && exit 0

# Defines varibales.
input="$h_inputList"
options=$( eval echo "$monitorOptions" )

# This script IS the daemon which must perform action.
inputIndex=1
while [ 1 ]; do
  # Waits for another input (checking write on the input list).
  # N.B.: new input may have been created while the system was managing last ones, so checks 
  #  if the count of input in the list is lower than the count of managed input, otherwise does NOT wait.
  [ $( cat $h_inputList |wc -l ) -lt $inputIndex ] && "$monitorBin" $options

  # For each new input (from the last managed one) in list file.
  for input in $( getLastLinesFromN "$h_inputList" "$inputIndex" ); do
    inputName=$( basename "$input" )
    inputType=${inputName/_*/}
    inputPath="$h_newInputDir/$input"
    inputString="input-"$( printf "%04d" "$inputIndex" )

    # Checks it is a known/supported type.
    if ! checkAvailableValue "$SUPPORTED_TYPE" "$inputType"; then
      writeMessage "$inputString: unsupported type: $inputType"

      # Moves the input into error input directory.
      mv -f "$inputPath" "$h_errInputDir"
    elif [ ! -f "$inputPath" ]; then
      writeMessage "$inputString: $inputName not found"
    else
      # Launches background process on this input.
      # N.B.: to have one log specific to each input -> h_logFile="$h_logFile.$inputString"
      h_logFile="$h_logFile" "$processInputScript" -i "$inputName" -S "$inputString" &
    fi

    # Memorizes a new input has been managed or ignored.
    let inputIndex++
  done
done
