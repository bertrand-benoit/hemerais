#!/bin/bash
#
# Author: Bertrand BENOIT <projettwk@users.sourceforge.net>
# Version: 1.0
# Description: checks Hemera tools configuration.

#########################
## CONFIGURATION
currentDir=$( dirname "$( which "$0" )" )
installDir=$( dirname "$currentDir" )
source "$installDir/scripts/setEnvironment.sh"

category="check"
showError=0

#########################
## INSTRUCTIONS
# Checks all path defined in configuration file.
for pathKey in $( grep -re "^[^#][a-zA-Z.]*[.]path=" "$configurationFile" |sed -e 's/^\([^=]*\)=.*/\1/' ); do
  writeMessage "Checking '$pathKey' ... " 0
  pathValue=$( getConfigPath "$pathKey" )
  [ $? -ne 0 ] && echo "failed" && continue
  
  echo -ne "existence ... "
  ! checkBin "$pathValue" && echo "$pathValue NOT found" && continue
  echo "OK"
done
