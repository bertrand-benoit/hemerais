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
category="TSearch."
verbose=1


# Defines priorly log file to avoid erasing while cleaning potential previous launch.
export h_logFile="/tmp/"$( date +'%s' )"-$category.log"

source "$installDir/scripts/setEnvironment.sh"

# Informs about log file now that functions are available.
writeMessage "LogFile: $h_logFile"

SEARCH_STRINGS=( "Intelligence Artificielle" ) #"Conscience" "Compréhension" "Language" )

#########################
## FUNCTIONS

#########################
## INSTRUCTIONS
writeMessage "Test system will ensure Hemera is not running"
"$scripstDir/hemera.sh" -K

# Cleans everything, ensuring tests works on new "empty" structure.
"$scripstDir/makeHemera.sh" clean
"$scripstDir/makeHemera.sh" init

# Starts inputMonitor.
writeMessage "Test system will start some daemons"
"$h_daemonDir/inputMonitor.sh" -S

# We want all information about input management.
# export verbose=1
export noconsole=0

# Starts IO processor.
"$h_daemonDir/ioprocessor.sh" -S

# Waits a little, everything is well started.
sleep 2

## Performs tests.
inputIndex=1
for searchStringRaw in "${SEARCH_STRINGS[@]}"; do
  searchString=$( echo "$searchStringRaw" |sed -e 's/€/ /g;' )
  # Launch search.
  echo "${SEARCH_CMD_PATTERN_I18N[0]} $searchString" > "$h_newInputDir/recognitionResult_test$inputIndex.txt"

  # Wait some times.
  sleep 10

  # Requests stop, and wait until all is managed.
  echo "stop" > "$h_newInputDir/recognitionResult_test$inputIndex-2.txt"
  waitUntilAllInputManaged

  let inputIndex++
done

# Stops IO processor, and input monitor.
"$h_daemonDir/ioprocessor.sh" -K
"$h_daemonDir/inputMonitor.sh" -K
