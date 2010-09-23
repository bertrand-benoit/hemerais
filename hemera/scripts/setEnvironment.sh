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

# Defines configuration file.
configurationFile="$installDir/config/hemera.conf"

# Updates environment path if needed.
additionalBinPath=$( getConfigValue "hemera.path.bin" )
additionalLibPath=$( getConfigValue "hemera.path.lib" )
[ ! -z "$additionalBinPath" ] && export PATH=$additionalBinPath:$PATH
[ ! -z "$additionalLibPath" ] && export LD_LIBRARY_PATH=$additionalLibPath:$LD_LIBRARY_PATH

# Defines some global variables about directories.
logDir=$( getConfigPath "hemera.run.log" )
queueDir=$( getConfigPath "hemera.run.queue" )
updateStructure "$logDir"
updateStructure "$queueDir"

# Structure:
#  tmp/work   temporary files
#  tmp/event  event under creation
#  tmp/pid    PID files
tmpDir=$( getConfigPath "hemera.run.temp" )
workDir="$tmpDir/work"
tmpEventDir="$tmpDir/event"
pidDir="$tmpDir/pid"
updateStructure "$workDir"
updateStructure "$tmpEventDir"
updateStructure "$pidDir"

# Defines some other global variables.
fileDate=$(date +"%s")

# Ensures the system has been configured.
[ ! -f "$configurationFile" ] && errorMessage "$configurationFile NOT found. You must configure the system (See $configurationFile.sample)."

# Defines the log file if not already done.
if [ -z "$logFile" ]; then
  export logFile="$logDir/"$(date +"%y-%m-%d-%H-%M-%S")"-Hemera.log"
  writeMessage "LogFile: $logFile"
fi
