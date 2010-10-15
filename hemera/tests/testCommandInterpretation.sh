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
# Description: performs command interpretation tests.
#
# Usage: see usage function.

#########################
## CONFIGURATION
# general
currentDir=$( dirname "$( which "$0" )" )
installDir=$( dirname "$currentDir" )
scripstDir="$installDir/scripts"
category="IOProcessorTests"
source "$installDir/scripts/setEnvironment.sh"

#########################
## INSTRUCTIONS
writeMessage "Test system will ensure Hemera is not running"
"$scripstDir/hemera.sh" -K

# Starts inputMonitor.
category="IOProcessorTests"
writeMessage "Test system will start some daemons"
"$scripstDir/daemon/inputMonitor.sh" -S

# We want all information about input management.
# export verbose=1
export noconsole=0

# Starts IO processor.
"$scripstDir/daemon/ioprocessor.sh" -S

## Test 1: Search/Pause/Continue/Stop tests.
writeMessage "Test 1: starting tests on: Search/Pause/Continue/Stop commands"
echo "recherche intelligence artificielle" > "$h_newInputDir/recognitionResult_test1.txt"
sleep 1
echo "pause" > "$h_newInputDir/recognitionResult_test2.txt"
sleep 1
echo "continue" > "$h_newInputDir/recognitionResult_test3.txt"
sleep 1
echo "stop" > "$h_newInputDir/recognitionResult_test4.txt"

waitUntilAllInputManaged 3

# TODO: Mode tests.

# Stops IO processor, and input monitor.
"$scripstDir/daemon/ioprocessor.sh" -K
"$scripstDir/daemon/inputMonitor.sh" -K
