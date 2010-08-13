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

workDir="/tmp/ia"
logDir="/tmp/ia/Logs"
fileDate=$(date +"%s")

# Ensures various directories exists.
mkdir -p "$workDir" "$logDir"

# Defines the log file if not already done.
if [ -z "$logFile" ]; then
  logFile="$logDir/"$(date +"%y-%m-%d-%H-%M-%S")"-Hemera.log"
  writeMessage "LogFile: $logFile"
fi
