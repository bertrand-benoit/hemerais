#!/bin/bash
#
# Author: Bertrand BENOIT <bertrand.benoit@bsquare.no-ip.org>
# Version: 1.0
# Description: sets the profile of Hemera; updating the environment.

installDir="/opt/hemera/"

# Adds each script sub-directory to PATH.
additionalPath=""
for scriptsDirRaw in $( find "$installDir" -type d -name "scripts" |sed -e 's/[ \t]/£/g;' ); do
  scriptsDir=$( echo "$scriptsDirRaw" |sed -e 's/£/ /g;' )
  [ ! -z "$additionalPath" ] && additionalPath="$additionalPath:"
  additionalPath="$additionalPath$scriptsDir"
done

export PATH=$additionalPath:$PATH
