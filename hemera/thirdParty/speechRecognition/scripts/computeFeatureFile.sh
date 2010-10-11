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
# Description: computes sound feature file, needed by sphinx3.
#
# Usage: see usage function.

#########################
## CONFIGURATION
# general
currentDir=$( dirname "$( which "$0" )" )
installDir=$( dirname "$( dirname "$( dirname "$currentDir" )" )" )
category="featureFileManagement"
source "$installDir/scripts/setEnvironment.sh"

CONFIG_KEY="hemera.core.speechRecognition"

# Tool configuration.
soundFeatureCreatorBin=$( getConfigPath "$CONFIG_KEY.soundFeatureCreator.path" ) || exit $ERROR_CONFIG_PATH
soundFeatureCreatorOptions=$( getConfigValue "$CONFIG_KEY.soundFeatureCreator.options" ) || exit $ERROR_CONFIG_VARIOUS

#########################
## Functions
# usage: usage
function usage() {
  echo -e "Usage: $0 -f <sound file> [-vh]"
  echo -e "<file>\tthe sound file to manage"
  echo -e "-v\t\tactivate the verbose mode"
  echo -e "-h\t\tshow this usage"

  exit $ERROR_USAGE
}


#########################
## Command line management
verbose=0
while getopts "f:vh" opt
do
 case "$opt" in
        f)      soundFile="$OPTARG";;
        v)      verbose=1;;
        h|[?]) usage;;
 esac
done

[ -z "$soundFile" ] && usage
[ ! -f "$soundFile" ] && echo -e "$soundFile not found." >&2 && exit $ERROR_BAD_CLI

#########################
## INSTRUCTIONS
# Defines input and output.
input="$soundFile"
output="$soundFile".mfc

# Launches the tool, evaluating the options (variables will be replaced).
"$soundFeatureCreatorBin" $( eval echo $soundFeatureCreatorOptions )
