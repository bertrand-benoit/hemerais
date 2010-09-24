#!/bin/bash
#
# Author: Bertrand BENOIT <projettwk@users.sourceforge.net>
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
soundFeatureCreatorBin=$( getConfigPath "$CONFIG_KEY.soundFeatureCreator.path" ) || exit 100
soundFeatureCreatorOptions=$( getConfigValue "$CONFIG_KEY.soundFeatureCreator.options" ) || exit 100

#########################
## Functions
# usage: usage
function usage() {
  echo -e "Usage: $0 -f <sound file> [-vh]"
  echo -e "<file>\tthe sound file to manage"
  echo -e "-v\t\tactivate the verbose mode"
  echo -e "-h\t\tshow this usage"
  
  exit 1
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
[ ! -f "$soundFile" ] && echo -e "$soundFile not found." >&2 && exit 1

#########################
## INSTRUCTIONS
# Defines input and output.
input="$soundFile"
output="$soundFile".mfc

# Launches the tool, evaluating the options (variables will be replaced).
"$soundFeatureCreatorBin" $( eval echo $soundFeatureCreatorOptions )
