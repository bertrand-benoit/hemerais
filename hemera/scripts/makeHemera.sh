#!/bin/bash
#
# Author: Bertrand BENOIT <projettwk@users.sourceforge.net>
# Version: 1.0
# Description: makes Hemera (documentation, source code management ...).

#########################
## CONFIGURATION
currentDir=$( dirname "$( which "$0" )" )
installDir=$( dirname "$currentDir" )
source "$installDir/scripts/setEnvironment.sh"

category="make"
CONFIG_KEY="environment"
buildAntFile="$installDir/engineering/hemeraBuild.xml"

# Gets environment configuration
manageJavaHome || exit 102
manageAntHome || exit 102

ANT="$ANT_HOME/bin/ant"

#########################
## FUNCTIONS
# usage: makeLibraries
function makeLibraries() {
  "$ANT" -v -f "$buildAntFile" libraries >> "$logFile" 2>&1
}

#########################
## INSTRUCTIONS
writeMessage "Creating Hemera librairies ... " 0
makeLibraries && echo "done" || echo "error (See $logFile)"
