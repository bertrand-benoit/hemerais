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
# Description: sound recorder daemon.
#
# Usage: see usage function.

#########################
## CONFIGURATION
# general
currentDir=$( dirname "$( which "$0" )" )
installDir=$( dirname "$( dirname "$currentDir" )" )
category="soundRecorder"
source "$installDir/scripts/setEnvironment.sh"

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
          input="$newInputDir/recordedSpeech_.wav"
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
