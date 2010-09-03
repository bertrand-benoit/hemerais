#!/bin/bash
#
# Author: Bertrand BENOIT <bertrand.benoit@bsquare.no-ip.org>
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

configurationFile="$installDir/config/hemera.conf"

workDir="/tmp/Hemera"
logDir="$workDir/Logs"
fileDate=$(date +"%s")

# Ensures various directories exists.
mkdir -p "$workDir" "$logDir"

# Ensures the system has been configured.
[ ! -f "$configurationFile" ] && errorMessage "$configurationFile NOT found. You must configure the system (See $configurationFile.sample)."

# Defines the log file if not already done.
if [ -z "$logFile" ]; then
  export logFile="$logDir/"$(date +"%y-%m-%d-%H-%M-%S")"-Hemera.log"
  writeMessage "LogFile: $logFile"
fi
