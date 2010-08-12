#!/bin/bash
#
# Author: Bertrand BENOIT <bertrand.benoit@bsquare.no-ip.org>
# Version: 1.0
# Description: uses sphinx3 and LIMU data files for speech recognition.
#
# Usage: see usage function.

#########################
## CONFIGURATION
# general
mypath=$( dirname "$( which "$0" )" )
installDir=$( dirname "$( dirname "$( dirname "$mypath" )" )" )
source "$installDir/scripts/utilities.sh"
source "$installDir/scripts/setEnvironment.sh"

# data configuration
