#!/bin/bash
#
# Hemera - Intelligent System (https://github.com/bertrand-benoit/hemerais)
# Copyright (C) 2010-2020 Bertrand Benoit <hemerais@bertrand-benoit.net>
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
# Description: monitors Hemera.

#########################
## CONFIGURATION
currentDir=$( dirname "$( which "$0" )" )
installDir=$( dirname "$currentDir" )
CATEGORY="monitor"
source "$currentDir/setEnvironment.sh"

# Safeguard to automagically stop monitor in Hemera file(s) are not available during a "long" time.
declare -r MAX_ERROR_COUNT=10

# Ensures any launched tail command is stopped in same time of this script.
setUpKillChildTrap "$0"

#########################
## FUNCTIONS

# usage: startMonitor <error output file>
function startMonitor() {
  local _errorOutput="$1"

  # Ensures source and destination directories exist.
  # They may have been erased (for instance with a makeHemera clean during monitoring).
  [ ! -d $( dirname "$h_monitor" ) ] && return 1
  [ ! -d $( dirname "$_errorOutput" ) ] && return 1

  # Starts monitor as a background job.
  if [ $count -eq 1 ]; then
    writeMessage "Starting monitor"
  else
    writeMessage "Restarting monitor (the previous one has been killed or stopped because Hemera monitor information has been erased)"
  fi

  (
    # Prepares the error output file to avoid false positive error (and monitor restarting).
    touch "$_errorOutput"

    # Ensures the monitor file exists before launching tail to avoid false positive error (and monitor restarting).
    while [ ! -f "$h_monitor" ]; do
        sleep 1
    done

    # Uses a 'simple' tail (NO --retry, and NO -F option to avoid duplicate output when monitor has
    #  been restarted, in which case, several 'tail' will live until this parent script is stopped).
    LANG=C tail -q -f "$h_monitor" 2>"$_errorOutput"
  ) &
}

#########################
## INSTRUCTIONS

count=1
tailErrorFile="$h_workDir/$h_fileDate-monitorErrorOutput.txt$count"

# Starts monitor.
startMonitor "$tailErrorFile"
lastPID=$!

# Checks error output to detect potential monitor file status change (like no more accessible).
while [ 1 ]; do
  sleep 5

  # Ensures the process is still running.
  # If it is NOT the case, regards it as en error.
  if $( ps -p $lastPID >/dev/null 2>&1 ); then
    # Checks if there was error.
    # If error output file does not exist anymore, it is regarded as an error.
    [ -f "$tailErrorFile" ] && [ $( grep -ce "No such file" "$tailErrorFile" 2>/dev/null ) -eq 0 ] && continue
  fi

  # It is the case, launches another "monitor"; any previous one will stay inactive,
  #  and will be killed when this script is stop (thanks to 'setUpKillChildTrap').
  let count++
  if [ $count -ge $MAX_ERROR_COUNT ]; then
    writeMessage "Automagically stopped monitor because Hemera information are not accessible since some times (Hemera may have been stopped)"
    break
  fi

  tailErrorFile="$h_workDir/$h_fileDate-monitorErrorOutput.txt$count"
  startMonitor "$tailErrorFile"
  lastPID=$!
done

# Any potential launched jobs will be killed thanks to 'setUpKillChildTrap', when this script stops.
