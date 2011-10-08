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
# Description: sound recorder daemon.
#
# Usage: see usage function.

#########################
## CONFIGURATION
# general
currentDir=$( dirname "$( which "$0" )" )
installDir=$( dirname "$( dirname "$currentDir" )" )
category="soundRecorder"

# Ensures $installDir/scripts/setEnvironment.sh is reachable.
# It may NOT be the case if user has NOT installed GNU version of which and launched scripts
#  with particular $PWD (for instance launching setupHemera.sh being in the scripts sub directory).
[ ! -f "$installDir/scripts/setEnvironment.sh" ] && echo -e "\E[31m\E[4mERROR\E[0m: failure in path management. Ensure you have a GNU version of 'which' tool (check Hemera documentation)." && exit 1
source "$installDir/scripts/setEnvironment.sh"

declare -r CONFIG_KEY="hemera.core.speechRecognition"
declare -r daemonName="sound recorder"

# Defines the PID file.
declare -r pidFile="$h_pidDir/soundRecording.pid"

#########################
## Command line management

# N.B.: the -D option must be only internally used.
# Defines verbose to 0 if not already defined.
verbose=${verbose:-0}
newLogFile=""
outputFile=""
options=""
while getopts "XDSTKvh" opt
do
 case "$opt" in
        X) checkConfAndQuit=1;;
        S)
          action="start"
          outputFile="$h_logFile.soundRecorder"
          newLogFile="$outputFile"
        ;;
        T)      action="status";;
        K)      action="stop";;
        D)      action="daemon";;
        v)      verbose=1;;
        h|[?])  daemonUsage "$daemonName" ;;
 esac
done

## Configuration check.
checkAndSetConfig "$CONFIG_KEY.soundRecorder.path" "$CONFIG_TYPE_BIN"
declare -r soundRecorderBin="$h_lastConfig"
checkAndSetConfig "$CONFIG_KEY.soundRecorder.options" "$CONFIG_TYPE_OPTION"
declare -r soundRecorderOptions="$h_lastConfig"

[ $checkConfAndQuit -eq 1 ] && exit 0

## Command line arguments check.
# Ensures action is defined.
[ -z "${action:-}" ] && daemonUsage "$daemonName"

#########################
## INSTRUCTIONS

if [ "$action" = "daemon" ]; then
  declare -r output="$h_newInputDir/recordedSpeech_.wav"
  declare -r options=$( eval echo "$soundRecorderOptions" )
fi

# Manages daemon.
manageDaemon "$action" "$daemonName" "$pidFile" "$soundRecorderBin" "$newLogFile" "$outputFile" "$options"
