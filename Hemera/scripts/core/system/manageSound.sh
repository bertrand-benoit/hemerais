#!/bin/bash
#
# Hemera - Intelligent System (http://hemerais.bertrand-benoit.net)
# Copyright (C) 2010-2015 Bertrand Benoit <hemerais@bertrand-benoit.net>
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
# Description: manages sound play/pause/continue/stop action.
#
# Usage: see usage function.

#########################
## CONFIGURATION
# general
currentDir=$( dirname "$( which "$0" )" )
installDir="$currentDir/../../../"
CATEGORY="manageSound"

# Ensures $installDir/scripts/setEnvironment.sh is reachable.
# It may NOT be the case if user has NOT installed GNU version of which and launched scripts
#  with particular $PWD (for instance launching setupHemera.sh being in the scripts sub directory).
[ ! -f "$installDir/scripts/setEnvironment.sh" ] && echo -e "\E[31m\E[4mERROR\E[0m: failure in path management. Ensure you have a GNU version of 'which' tool (check Hemera documentation)." && exit 1
source "$installDir/scripts/setEnvironment.sh"

runningProcessPID=""

#########################
## Functions
# usage: usage
function usage() {
  echo -e "Usage: $0 -p <pid file> [-f <sound file>] [-P|-C|-S] [-hvX]"
  echo -e "<pid file>\tpid file (needed for pause/continue/Stop action)"
  echo -e "<sound file>\tsound file to play"
  echo -e "-P\t\tpause sound played by process corresponding to specified pid file"
  echo -e "-C\t\tcontinue paused sound player process corresponding to specified pid file"
  echo -e "-S\t\tstop played/paused sound player process corresponding to specified pid file"
  echo -e "-X\tcheck configuration and quit"
  echo -e "-v\t\tactivate the verbose mode"
  echo -e "-h\t\tshow this usage"
  echo -e "\nEither sound file or one of the pause/continue/stop action must be specified."

  exit $ERROR_USAGE
}

#########################
## Command line management

# Defines VERBOSE to 0 if not already defined.
VERBOSE=${VERBOSE:-0}
while getopts "PCSp:f:vhX" opt
do
 case "$opt" in
        X)      MODE_CHECK_CONFIG_AND_QUIT=1;;
        p)      pidFile="$OPTARG";;
        f)      action="play";soundFile="$OPTARG";;
        P)      action="pause";;
        C)      action="continue";;
        S)      action="stop";;
        v)      VERBOSE=1;;
        h|[?])  usage;;
 esac
done

## Configuration check.
checkAndSetConfig "hemera.core.speech.soundPlayer.path" "$CONFIG_TYPE_BIN"
declare -r soundPlayerBin="$LAST_READ_CONFIG"
checkAndSetConfig "hemera.core.speech.soundPlayer.options" "$CONFIG_TYPE_OPTION"
declare -r soundPlayerOptions="$LAST_READ_CONFIG"

[ $MODE_CHECK_CONFIG_AND_QUIT -eq 1 ] && exit 0

## Command line arguments check.
[ -z "${action:-}" ] && usage
[ "$action" = "play" ] && [ ! -f "$soundFile" ] && errorMessage "Sound file '$soundFile' must exist" $ERROR_BAD_CLI

[ -z "${pidFile:-}" ] && usage
[ "$action" != "play" ] && [ ! -s "$pidFile" ] && errorMessage "PID file '$pidFile' must exist and NOT be empty" $ERROR_BAD_CLI

#########################
## INSTRUCTIONS

# Checks if pid file has already been created.
if [ -s "$pidFile" ]; then
  runningProcessPID=$( getPIDFromFile $pidFile )

  # Checks if the process still exists.
  # If it is not the case, remove the PID file, and if an only if the action is not "play", the system exists (because none of
  #  the other action has sense if the process has completed).
  if ! isRunningProcess "$pidFile" "$soundPlayerBin"; then
    rm -f "$pidFile"
    writeMessage "manageSound process with PID '$runningProcessPID' has completed. Removed corresponding pid file. Requested action is $action."

    # Resets the running process PID because it has completed (otherwise potential play action could not be done).
    runningProcessPID=""

    # Exists only if NOT play action.
    [ $action != "play" ] && exit 0
  fi
fi

# According to the action.
case $action in
  play)
    # Ensures there is not already a running sound manage corresponding to this pid file.
    [ -n "$runningProcessPID" ] && errorMessage "There is already a running manageSound process linked to PID file '$pidFile'. Nothing more to do" $ERROR_ENVIRONMENT

    # Writes the PID file with the PID of this process.
    writePIDFile "$pidFile" "$soundPlayerBin" || return 1

    # plays the sound.
    input="$soundFile"
    playerOptions=$( eval echo "$soundPlayerOptions" )    
    exec "$soundPlayerBin" $playerOptions
  ;;

  pause)
    writeMessage "Pausing process with PID '$runningProcessPID'"
    kill -s STOP "$runningProcessPID"
  ;;

  continue)
    writeMessage "Continuing process with PID '$runningProcessPID'"
    kill -s CONT "$runningProcessPID"
  ;;

  stop)
    writeMessage "Stopping process with PID '$runningProcessPID'"
    kill -s TERM "$runningProcessPID"

    # Removes the pid file.
    rm -f $pidFile
  ;;

  ?) errorMessage "Unknown action '$action'" $ERROR_BAD_CLI;;
esac
