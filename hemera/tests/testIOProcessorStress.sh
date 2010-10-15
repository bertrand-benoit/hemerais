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
# Description: performs stress tests on IOProcessor.
#
# Usage: see usage function.

#########################
## CONFIGURATION
# general
currentDir=$( dirname "$( which "$0" )" )
installDir=$( dirname "$currentDir" )
scripstDir="$installDir/scripts"
category="IOProcessorStressTests"
source "$installDir/scripts/setEnvironment.sh"

INPUT_COUNT_1=500
INPUT_COUNT_2=500
INPUT_COUNT=$( expr $INPUT_COUNT_1 + $INPUT_COUNT_2 )

#########################
## FUNCTIONS
# usage: generateLotsOfInput <first index> <count> [simu]
# simu: keyword to use if inputMonitor is not started.
# This function generates N input, from 1 to N as "index"; allowing to ensure they are ALL managed
#  and in the same order (checking log).
function generateLotsOfInput() {
  local _currentCount=$1 _inputCount=$2

  while [ $_currentCount -le $_inputCount ]; do
    count=$( printf "%04d" "$_currentCount" )
    touch "$h_newInputDir/$count"
    [ "$3" = "simu" ] && echo $count >> "$h_inputList"
    let _currentCount++
  done
}

# usage: checkInputManagement <count>
function checkInputManagement() {
  local _inputCount=$1

  writeMessage "Ensuring $_inputCount input has been managed ... " 0
  managedCount=$( cat "$h_logFile" |grep "input-" |wc -l )
  [ $managedCount -eq $_inputCount ] && echo "ok" || echo "failed ($managedCount instead of $_inputCount)"

  writeMessage "Ensuring index of the last input is $_inputCount ... " 0
  lastManagedIndex=$( cat "$h_logFile" |grep "input-" |tail -n 1 |sed -e 's/.*input-\([0-9][0-9]*\).*$/\1/g;' )
  [ -z "$lastManagedIndex" ] && lastManagedIndex="none"
  awaitedLastIndex=$( printf "%04d" "$_inputCount" )
  [[ "$lastManagedIndex" == "$awaitedLastIndex" ]] && echo "ok" || echo "failed ($lastManagedIndex instead of $awaitedLastIndex)"

  writeMessage "Ensuring each managed input has been seen in good order ... " 0
  badlyManagedInput=$( cat "$h_logFile" |grep "input-" |sed -e 's/.*input-\([0-9][0-9]*\)[^0-9]*\([0-9][0-9]*\)$/\1 \2/g;' |awk '$1 != $2 {print}' )
  [ -z "$badlyManagedInput" ] && echo "ok" || echo -e "failed (format: <ordered input index> <input name index>):\n$badlyManagedInput"
}

# usage: cleanAllNewInput
function cleanAllNewInput() {
  rm -Rf "$h_newInputDir/*"
}

# usage: launchInputGenerationAndCheck [simu]
# simu: keyword to use if inputMonitor is not started.
function launchInputGenerationAndCheck() {
  # Generates lots of event, with a middle pause.
  writeMessage "Generating $INPUT_COUNT input ... "
  generateLotsOfInput 1 $INPUT_COUNT_1 "$1"
  sleep 2
  generateLotsOfInput $( expr 1 + $INPUT_COUNT_1) $( expr $INPUT_COUNT_1 + $INPUT_COUNT_2) "$1"

  # Waits until all input has been managed (timeout: 10 s)
  waitUntilAllInputManaged 10

  # Checks if all input has been well managed.
  checkInputManagement $INPUT_COUNT
}

#########################
## INSTRUCTIONS
writeMessage "Test system will ensure Hemera is not running"
"$scripstDir/hemera.sh" -K

mainLogFile="$h_logFile"

## Test 1
# Stress IOProcessor, without inputMonitor.
h_logFile="$mainLogFile.1"
writeMessage "Test 1: IOProcessor stress without inputMonitor (specific log file: $h_logFile)"

# Cleans all potential remaining "new" input.
cleanAllNewInput

# Resets input list file.
rm -f "$h_inputList" && touch "$h_inputList"
# Starts ioProcessor.
verbose=1 "$scripstDir/daemon/ioprocessor.sh" -S
# Launches input generation and check.
launchInputGenerationAndCheck "simu"
# Stops ioProcessor.
"$scripstDir/daemon/ioprocessor.sh" -K

## Test 2
# Stress IOProcessor, WITH inputMonitor.
h_logFile="$mainLogFile.2"
writeMessage "Test 2: IOProcessor stress WITH inputMonitor (specific log file: $h_logFile)"

# Cleans all potential remaining "new" input.
cleanAllNewInput

# Starts inputMonitor, and ioprocessor.
verbose=1
"$scripstDir/daemon/inputMonitor.sh" -S
"$scripstDir/daemon/ioprocessor.sh" -S
# Launches input generation and check.
launchInputGenerationAndCheck
# Stops inputMonitor, and ioprocessor.
"$scripstDir/daemon/ioprocessor.sh" -K
"$scripstDir/daemon/inputMonitor.sh" -K
