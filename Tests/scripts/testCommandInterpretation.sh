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
# Description: performs command interpretation tests.
#
# Usage: see usage function.

# Ensures everything is stopped in same time of this script.
trap 'writeMessage "Interrupting all tests"; "$scripstDir/hemera.sh" -K; exit 0' INT

#########################
## CONFIGURATION
# general
currentDir=$( dirname "$( which "$0" )" )
installDir=$( dirname "$currentDir" )"/../Hemera"

# Ensures hemera main project is available in the same root directory.
[ ! -d "$installDir" ] && echo -e "Unable to find hemera main project ($installDir)" && exit 1

# completes configuration.
scripstDir="$installDir/scripts"
category="TCmdInterp."
verbose=1

# Defines priorly log file to avoid erasing while cleaning potential previous launch.
export h_logFile="/tmp/"$( date +'%s' )"-$category.log"

source "$installDir/scripts/setEnvironment.sh"

# Informs about log file now that functions are available.
writeMessage "LogFile: $h_logFile"

# Defines some additionals variables.
speechScript="$h_coreDir/speech/speech.sh"

STRING1="Ceci est un test."
STRING2="Perroquet, perroquet, perroquet."
STRING2b="dire quelque chose"
STRING3="rechercher la vérité absolue"
STRING4="pause"
STRING5="continue"
STRING6="stop"
STRING7="Les commandes suivantes doivent êtres répétées, et non interprétées"
STRING8="Je ne suis plus censée répéter ce que l'on me dit"

#########################
## FUNCTIONS

# usage: waitForMode <mode> <timeout>
function waitForMode() {
  local _mode="$1" _remainingTime=${2:-10}
  writeMessage "Waiting until recognized command mode is changed to '$_mode' (timeout: $_remainingTime seconds)"
  while [ 1 ]; do
    # Checks if there is remaining time.
    [ $_remainingTime -eq 0 ] && break

    # Checks if the awaited mode is reached.
    recoCmdMode=$( getRecoCmdMode ) || return $ERROR_ENVIRONMENT
    [ "$recoCmdMode" = "$_mode" ] && break

    sleep 1
    let _remainingTime--
  done

  # Checks if the awaited mode is reached.
  recoCmdMode=$( getRecoCmdMode ) || return $ERROR_ENVIRONMENT
  [[ "$recoCmdMode" != "$_mode" ]] && errorMessage "Recognized command mode is broken"
}

# usage: test1
# Search/Pause/Continue/Stop tests.
function test1() {
  writeMessage "Test 1: starting tests on: Search/Pause/Continue/Stop commands"
  writeMessage "Test 1: launching search"
  echo "recherche intelligence artificielle" > "$h_newInputDir/recognitionResult_test1.txt"

  # Waits until this input has been managed, which means it is neither in "new", neiter in "cur" directories.
  while [ -f "$h_newInputDir/recognitionResult_test1.txt" ] || [ -f "$h_curInputDir/recognitionResult_test1.txt" ]; do
    sleep 1
  done

  # From there, the speech starts playing, lets it during few seconds.
  sleep 3

  writeMessage "Test 1: pause for 3 seconds"
  echo "pause" > "$h_newInputDir/recognitionResult_test2.txt"
  sleep 3
  writeMessage "Test 1: continue"
  echo "continue" > "$h_newInputDir/recognitionResult_test3.txt"
  sleep 3
  writeMessage "Test 1: stop"
  echo "stop" > "$h_newInputDir/recognitionResult_test4.txt"

  waitUntilAllInputManaged
}

# usage: test2
# mode tests.
function test2() {
  writeMessage "Test 2: starting recognized command mode tests"
  writeMessage "Test 2: activating parrot recognized command mode"
  echo "mode perroquet" > "$h_newInputDir/recognitionResult_test1.txt"
  waitForMode "$H_RECO_CMD_MODE_PARROT"

  writeMessage "Test 2: must repeat '$STRING1'"
  echo "$STRING1" > "$h_newInputDir/recognitionResult_test2.txt"
  sleep 2
  writeMessage "Test 2: must repeat '$STRING2'"
  echo "$STRING2" > "$h_newInputDir/recognitionResult_test3.txt"
  sleep 2
  writeMessage "Test 2: must repeat '$STRING2b'"
  echo "$STRING2b" > "$h_newInputDir/recognitionResult_test3b.txt"
  sleep 2

  writeMessage "Test 2: inform about what must happen ($STRING7 : $STRING3, $STRING4, $STRING5, $STRING6)"
  "$speechScript" -t "$STRING7" -o "$h_newInputDir/speech_test4.wav"
  waitUntilAllInputManaged
  echo "$STRING3" > "$h_newInputDir/recognitionResult_test5.txt"
  echo "$STRING4" > "$h_newInputDir/recognitionResult_test6.txt"
  echo "$STRING5" > "$h_newInputDir/recognitionResult_test7.txt"
  echo "$STRING6" > "$h_newInputDir/recognitionResult_test8.txt"
  
  waitUntilAllInputManaged
}

# usage: test3
# command error tests.
function test3() {
  writeMessage "Test 2: activating normal mode"
  echo "mode normal" > "$h_newInputDir/recognitionResult_test9.txt"
  waitForMode "$H_RECO_CMD_MODE_NORMAL"

  writeMessage "Test 2: inform about what must happen ($STRING8)"
  "$speechScript" -t "$STRING8" -o "$h_newInputDir/speech_test10.wav"
  waitUntilAllInputManaged
  "$speechScript" -t "Les commandes suivantes doivent produire une erreur, et ne doivent pas êtres répétées" -o "$h_newInputDir/speech_test11.wav"
  echo "dire" > "$h_newInputDir/recognitionResult_error_test11b.txt" # must produce an error because this command requires an argument
  echo "rechercher" > "$h_newInputDir/recognitionResult_error_test12.txt" # must produce an error because this command requires an argument
  echo "pause quelque chose" > "$h_newInputDir/recognitionResult_error_test13.txt" # must produce an error because this command supports NO argument
  echo "continue quelque chose" > "$h_newInputDir/recognitionResult_error_test14.txt" # must produce an error because this command supports NO argument
  echo "stop quelque chose" > "$h_newInputDir/recognitionResult_error_test15.txt" # must produce an error because this command supports NO argument
  echo "" > "$h_newInputDir/recognitionResult_error_test16.txt" # must produce an error because it simulates a bad speech recognition
  echo "commandNonTrouvée" > "$h_newInputDir/recognitionResult_error_test17.txt" # must produce an error because this command is not found

  waitUntilAllInputManaged
}

#########################
## INSTRUCTIONS
writeMessage "Test system will ensure Hemera is not running"
"$scripstDir/hemera.sh" -K

# Cleans everything, ensuring tests works on new "empty" structure.
"$scripstDir/makeHemera.sh" clean

# Starts inputMonitor.
writeMessage "Test system will start some daemons"
"$h_daemonDir/inputMonitor.sh" -S

# Initializes Hemera mode.
# N.B.: tests system must do it because the usual Hemera start system (which performs this initialization) is not used.
# N.B.: starts inputMonitor BEFORE this initialization for environment to be created.
initRecoCmdMode || exit $ERROR_ENVIRONMENT
initializeCommandMap || exit $ERROR_ENVIRONMENT

# We want all information about input management.
# export verbose=1
export noconsole=0

# Starts IO processor.
"$h_daemonDir/ioprocessor.sh" -S

# Waits a little, everything is well started.
sleep 2

## Test 1: Search/Pause/Continue/Stop tests.
test1

## Test 2: Mode tests.
test2

## Test 3: Command error tests.
test3

# Stops IO processor, and input monitor.
"$h_daemonDir/ioprocessor.sh" -K
"$h_daemonDir/inputMonitor.sh" -K
