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
# Description: light Java Sound Player.
#
# Usage: see usage function.

#########################
## CONFIGURATION
# general
currentDir=$( dirname "$( which "$0" )" )
installDir=$( dirname "$currentDir" )
source "$installDir/scripts/setEnvironment.sh"

#########################
## Functions
# usage: usage
function usage() {
  echo -e "Usage: $0 -f <sound file> [-hv]"
  echo -e "<sound file>\tpath to sound file"
  echo -e "-v\tactivate the verbose mode"
  echo -e "-h\tshow this usage"

  exit 1
}

#########################
## Command line management
verbose=0
while getopts "f:vh" opt
do
 case "$opt" in
        f)      filePath="$OPTARG";;
        v)      verbose=1;;
        h|[?]) usage;;
 esac
done

# Checks binaries availability (checks sound player only if speech output is NOT defined).
[ -z "$filePath" ] && errorMessage "You must specify sound file path"

#########################
## INSTRUCTIONS
[ $verbose -eq 1 ] && additionalProperties="-Dhemera.log.verbose=3" || additionalProperties=""
writeMessage "Launching sound player with $filePath ... " 0
launchJavaTool "hemera.tools.LightSoundPlayer" "$additionalProperties" "$filePath" && echo "done" || echo "error (See $logFile)"
