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
# Description: manages sound play/pause/continue/stop action.
#
# Usage: see usage function.

#########################
## CONFIGURATION
# general
currentDir=$( dirname "$( which "$0" )" )
installDir=$( dirname "$currentDir" )
category="manageSound"
source "$installDir/scripts/setEnvironment.sh"

# sound player configuration
soundPlayerBin=$( getConfigPath "hemera.core.speech.soundPlayer.path" ) || exit $ERROR_CONFIG_PATH
soundPlayerOptions=$( getConfigValue "hemera.core.speech.soundPlayer.options" ) || exit $ERROR_CONFIG_VARIOUS

#########################
## Functions
# usage: usage
function usage() {
  echo -e "Usage: $0 -p <pid file> [-f <sound file>] [-P|-C|-S] [-hv]"
  echo -e "<pid file>\tpid file (needed for pause/continue/Stop action)"
  echo -e "<sound file>\tsound file to play"
  echo -e "-P\t\tpause sound played by process corresponding to specified pid file"
  echo -e "-C\t\tcontinue paused sound player process corresponding to specified pid file"
  echo -e "-S\t\tstop played/paused sound player process corresponding to specified pid file"
  echo -e "-v\t\tactivate the verbose mode"
  echo -e "-h\t\tshow this usage"
  echo -e "\nEither sound file or one of the pause/continue/stop action must be specified."

  exit $ERROR_USAGE
}

#########################
## Command line management

# Defines verbose to 0 if not already defined.
verbose=${verbose:-0}
while getopts "PCSp:f:vh" opt
do
 case "$opt" in
        p)      pidFile="$OPTARG";;
        f)      action="play";soundFile="$OPTARG";;
        P)      action="pause";;
        C)      action="continue";;
        S)      action="stop";;
        v)      verbose=1;;
        h|[?])  usage;;
 esac
done

# Checks command line options.
[ -z "$action" ] && usage
[ "$action" = "play" ] && [ ! -f "$soundFile" ] && errorMessage "Sound file '$soundFile' must exist" $ERROR_BAD_CLI

[ -z "$pidFile" ] && usage
[ "$action" != "play" ] && [ ! -s "$pidFile" ] && errorMessage "PID file '$pidFile' must exist and NOT be empty" $ERROR_BAD_CLI

# Checks tools.
checkBin "$soundPlayerBin" || exit $ERROR_CHECK_BIN

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
    [ ! -z "$runningProcessPID" ] && errorMessage "There is already a running manageSound process linked to PID file '$pidFile'. Nothing more to do" $ERROR_ENVIRONMENT

    # Writes the PID file with the PID of this process.
    echo "$$" > "$pidFile"

    # plays the sound.
    exec "$soundPlayerBin" $soundPlayerOptions "$soundFile"
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
