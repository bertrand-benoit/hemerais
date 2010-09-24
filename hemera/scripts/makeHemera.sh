#!/bin/bash
#
# Author: Bertrand BENOIT <projettwk@users.sourceforge.net>
# Version: 1.0
# Description: makes Hemera (documentation, source code management ...).

#########################
## CONFIGURATION
currentDir=$( dirname "$( which "$0" )" )
installDir=$( dirname "$currentDir" )
category="make"
source "$installDir/scripts/setEnvironment.sh"

CONFIG_KEY="environment"
buildAntFile="$installDir/engineering/hemeraBuild.xml"

# Gets environment configuration
manageJavaHome || exit 102
manageAntHome || exit 102

ANT="$ANT_HOME/bin/ant"

#########################
## FUNCTIONS

#########################
## INSTRUCTIONS
target="${1:-libraries}"
writeMessage "Making Hemera target: $target ... " 0
"$ANT" -v -f "$buildAntFile" "$target" >> "$logFile" 2>&1 && echo "done" || echo "error (See $logFile)"
