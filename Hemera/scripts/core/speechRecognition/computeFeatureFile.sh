#!/bin/bash
#
# Hemera - Intelligent System (http://hemerais.bertrand-benoit.net)
# Copyright (C) 2010-2015 Bertrand Benoit <hemerais@bertrand-benoit.net>
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
# Description: computes sound feature file, needed by sphinx3.
#
# Usage: see usage function.

#########################
## CONFIGURATION
# general
currentDir=$( dirname "$( which "$0" )" )
installDir=$( dirname "$( dirname "$( dirname "$currentDir" )" )" )
CATEGORY="featureFile"

# Ensures $installDir/scripts/setEnvironment.sh is reachable.
# It may NOT be the case if user has NOT installed GNU version of which and launched scripts
#  with particular $PWD (for instance launching setupHemera.sh being in the scripts sub directory).
[ ! -f "$installDir/scripts/setEnvironment.sh" ] && echo -e "\E[31m\E[4mERROR\E[0m: failure in path management. Ensure you have a GNU version of 'which' tool (check Hemera documentation)." && exit 1
source "$installDir/scripts/setEnvironment.sh"

declare -r CONFIG_KEY="hemera.core.speechRecognition"

#########################
## Functions
# usage: usage
function usage() {
  echo -e "Usage: $0 -X||-f <sound file> [-vh]"
  echo -e "<file>\tthe sound file to manage"
  echo -e "-X\tcheck configuration and quit"
  echo -e "-v\t\tactivate the verbose mode"
  echo -e "-h\t\tshow this usage"

  exit $ERROR_USAGE
}


#########################
## Command line management
# Defines VERBOSE to 0 if not already defined.
VERBOSE=${VERBOSE:-0}
while getopts "Xf:vh" opt
do
 case "$opt" in
        X)      MODE_CHECK_CONFIG=1;;
        f)      soundFile="$OPTARG";;
        v)      VERBOSE=1;;
        h|[?]) usage;;
 esac
done

## Configuration check.
checkAndSetConfig "$CONFIG_KEY.soundFeatureCreator.path" "$CONFIG_TYPE_BIN"
declare -r soundFeatureCreatorBin="$LAST_READ_CONFIG"
checkAndSetConfig "$CONFIG_KEY.soundFeatureCreator.options" "$CONFIG_TYPE_OPTION"
declare -r soundFeatureCreatorOptions="$LAST_READ_CONFIG"

isCheckModeConfigOnly && exit 0

## Command line arguments check.
[ -z "${soundFile:-}" ] && usage
[ ! -f "$soundFile" ] && errorMessage "$soundFile not found." $ERROR_BAD_CLI

#########################
## INSTRUCTIONS
# Defines input and output.
declare -r input="$soundFile"
declare -r output="$soundFile".mfc

# Launches the tool, evaluating the options (variables will be replaced).
"$soundFeatureCreatorBin" $( eval echo $soundFeatureCreatorOptions )
