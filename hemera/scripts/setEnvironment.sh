#!/bin/bash
#
# Author: Bertrand BENOIT <projettwk@users.sourceforge.net>
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
libDir="$installDir/lib"

# Defines configuration file, and ensures the system has been configured.
configurationFile="$installDir/config/hemera.conf"
[ ! -f "$configurationFile" ] && errorMessage "$configurationFile NOT found. You must configure the system (See $configurationFile.sample)."

# Updates environment path if needed.
additionalBinPath=$( getConfigValue "hemera.path.bin" ) || exit 100
additionalLibPath=$( getConfigValue "hemera.path.lib" ) || exit 100
[ ! -z "$additionalBinPath" ] && export PATH=$additionalBinPath:$PATH
[ ! -z "$additionalLibPath" ] && export LD_LIBRARY_PATH=$additionalLibPath:$LD_LIBRARY_PATH

# Defines some global variables about directories.
daemonDir="$installDir/scripts/daemon"
logDir=$( getConfigPath "hemera.run.log" ) || exit 100
updateStructure "$logDir"

# Structure:
#  queue/input/new    new input
#  queue/input/cur    input under processing
#  queue/input/err    input with unknown type or error occurs while processing
#  queue/input/done   input managed
queueDir=$( getConfigPath "hemera.run.queue" ) || exit 100
intputDir="$queueDir/input"
newInputDir="$intputDir/new"
curInputDir="$intputDir/cur"
errInputDir="$intputDir/err"
doneInputDir="$intputDir/done"
updateStructure "$newInputDir"
updateStructure "$curInputDir"
updateStructure "$errInputDir"
updateStructure "$doneInputDir"

# Structure:
#  tmp/work   temporary files
#  tmp/pid    PID files
tmpDir=$( getConfigPath "hemera.run.temp" ) || exit 100
workDir="$tmpDir/work"
pidDir="$tmpDir/pid"
updateStructure "$workDir"
updateStructure "$pidDir"

# Defines some other global variables.
inputList="$logDir/inputList"
fileDate=$(date +"%s")

## Terminology.
# Each input file name begins with a sub string giving the type of input:
#  recordedSpeech_: recorded speech (-> usually needs speech recognition)
#  recognitionResult_: speech recognition result (-> according to mode, must be printed or speech)
#  speech_: test to speech result (-> according to mode, speech recognition can be needed)
SUPPORTED_TYPE="recordedSpeech recognitionResult speech"

# Defines some constants.
UNKNOWN_COMMAND="Commande incomprise !"

# Defines the log file if not already done.
if [ -z "$logFile" ]; then
  export logFile="$logDir/"$(date +"%Y-%m-%d-%H-%M-%S")"-$category.log"
  writeMessage "LogFile: $logFile"
fi
