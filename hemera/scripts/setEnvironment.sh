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
# Description: provides lots of utilities functions.
#
# This script must NOT be directly called.
# installDir variable must be defined.

#########################
## Global variables
# Ensures installDir is defined.
[ -z "$installDir" ] && echo -e "This script must NOT be directly called. installDir variable not defined" >&2 && exit 1
source "$installDir/scripts/utilities.sh"

# Updates configuration.
h_libDir="$installDir/lib"

# Defines configuration file, and ensures the system has been configured.
h_configurationFile="$installDir/config/hemera.conf"
[ ! -f "$h_configurationFile" ] && errorMessage "$h_configurationFile NOT found. You must configure the system (See $h_configurationFile.sample)."

# Updates environment path if needed.
additionalBinPath=$( getConfigValue "hemera.path.bin" ) || exit 100
additionalLibPath=$( getConfigValue "hemera.path.lib" ) || exit 100
[ ! -z "$additionalBinPath" ] && export PATH=$additionalBinPath:$PATH
[ ! -z "$additionalLibPath" ] && export LD_LIBRARY_PATH=$additionalLibPath:$LD_LIBRARY_PATH

# Defines some global variables about directories.
h_daemonDir="$installDir/scripts/daemon"
h_logDir=$( getConfigPath "hemera.run.log" ) || exit 100
updateStructure "$h_logDir"

# Structure:
#  queue/input/new    new input
#  queue/input/cur    input under processing
#  queue/input/err    input with unknown type or error occurs while processing
#  queue/input/done   input managed
queueDir=$( getConfigPath "hemera.run.queue" ) || exit 100
inputDir="$queueDir/input"
h_newInputDir="$inputDir/new"
h_curInputDir="$inputDir/cur"
h_errInputDir="$inputDir/err"
h_doneInputDir="$inputDir/done"
updateStructure "$h_newInputDir"
updateStructure "$h_curInputDir"
updateStructure "$h_errInputDir"
updateStructure "$h_doneInputDir"

# Structure:
#  tmp/work   temporary files
#  tmp/pid    PID files
tmpDir=$( getConfigPath "hemera.run.temp" ) || exit 100
h_workDir="$tmpDir/work"
h_pidDir="$tmpDir/pid"
updateStructure "$h_workDir"
updateStructure "$h_pidDir"

# Defines some other global variables.
h_inputList="$h_logDir/inputList"
h_fileDate=$(date +"%s")

## Terminology.
# Each input file name begins with a sub string giving the type of input:
#  recordedSpeech_: recorded speech (-> usually needs speech recognition)
#  recognitionResult_: speech recognition result (-> according to mode, must be printed or speech)
#  speech_: test to speech result (-> according to mode, speech recognition can be needed)
SUPPORTED_TYPE="recordedSpeech recognitionResult speech"

# Defines some constants.
UNKNOWN_COMMAND="Commande incomprise !"

# Defines the log file if not already done.
if [ -z "$h_logFile" ]; then
  export h_logFile="$h_logDir/"$(date +"%Y-%m-%d-%H-%M-%S")"-$category.log"
  writeMessage "LogFile: $h_logFile"
fi
