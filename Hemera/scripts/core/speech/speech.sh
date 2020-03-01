#!/bin/bash
#
# Hemera - Intelligent System
# Copyright (C) 2010-2020 Bertrand Benoit <hemerais@bertrand-benoit.net>
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
# Version: 1.1
# Description: manages command line and uses configured tool to perform text to speech.
#
# Usage: see usage function.

#########################
## CONFIGURATION
# general
currentDir=$( dirname "$( which "$0" )" )
installDir=$( dirname "$( dirname "$( dirname "$currentDir" )" )" )
CATEGORY="speech"

# Ensures $installDir/scripts/setEnvironment.sh is reachable.
# It may NOT be the case if user has NOT installed GNU version of which and launched scripts
#  with particular $PWD (for instance launching setupHemera.sh being in the scripts sub directory).
[ ! -f "$installDir/scripts/setEnvironment.sh" ] && echo -e "\E[31m\E[4mERROR\E[0m: failure in path management. Ensure you have a GNU version of 'which' tool (check Hemera documentation)." && exit 1
source "$installDir/scripts/setEnvironment.sh"

declare -r CONFIG_KEY="hemera.core.speech"
declare -r SUPPORTED_MODE="espeak espeak+mbrola"

#########################
## Functions
# usage: usage
function usage() {
  echo -e "Usage: $0 [-t <text>|-f <file>|-i] [-o <output speech file>] [-l language] [-hvX]"
  echo -e "<text>\ttext/sentences to speech"
  echo -e "<file>\tfile to read"
  echo -e "-i\tinteractive mode (generate and play speech file of each written line - CTRL+D to stop)"
  echo -e "-l\tuse another language"
  echo -e "-X\tcheck configuration and quit"
  echo -e "-v\tactivate the verbose mode"
  echo -e "-h\tshow this usage"

  echo -e "\nYou must either use option -t, -u, -f, -d or -i."

  exit $ERROR_USAGE
}

# usage: startInteractiveMode
function startInteractiveMode() {
  while read line; do
    speechSentence "$line" || exit $ERROR_SPEECH
  done
}

# usage: readURLContents
function readURLContents() {
  local urlContentsFile="$h_workDir/$h_fileDate-urlContents.tmp"
  getURLContents "$url" "$urlContentsFile" || exit $ERROR_EXTERNAL_TOOL

  speechFileContents "$urlContentsFile"
}

# usage: readFileContents
function readFileContents() {
  speechFileContents "$filePath"
}

#########################
## Command line management
MODE_TEXT=1
MODE_FILE=3
MODE_INTERACTIVE=10

# Defines VERBOSE to 0 if not already defined.
VERBOSE=${VERBOSE:-0}
language=""
speechOutput=""
while getopts "Xt:f:io:l:vh" opt
do
 case "$opt" in
        X)      MODE_CHECK_CONFIG=1;;
        t)      mode=$MODE_TEXT;text="$OPTARG";;
        f)      mode=$MODE_FILE;filePath="$OPTARG";;
        i)      mode=$MODE_INTERACTIVE;;
        l)      language="$OPTARG";;
        o)      speechOutput="$OPTARG";;
        v)      VERBOSE=1;;
        h|[?]) usage;;
 esac
done

## Configuration check.
checkAndSetConfig "$CONFIG_KEY.mode" "$CONFIG_TYPE_OPTION"
declare -r moduleMode="$LAST_READ_CONFIG"
# Ensures configured mode is supported, and then it is implemented.
if ! checkAvailableValue "$SUPPORTED_MODE" "$moduleMode"; then
  # It is not a fatal error if in "MODE_CHECK_CONFIG" mode.
  _message="Unsupported mode: $moduleMode. Update your configuration."
  ! isCheckModeConfigOnly && errorMessage "$_message"
  warning "$_message"
else
  # It is not a fatal error if in "MODE_CHECK_CONFIG" mode.
  # "Not yet implemented" message to help adaptation with potential futur mode.
  if [[ "$moduleMode" != "espeak" ]] && [[ "$moduleMode" != "espeak+mbrola" ]]; then
    _message="Not yet implemented mode: $moduleMode"
    ! isCheckModeConfigOnly && errorMessage "$_message" $ERROR_MODE
    warning "$_message"
  fi
fi

checkAndSetConfig "$CONFIG_KEY.espeak.language" "$CONFIG_TYPE_OPTION"
declare -r DEFAULT_LANGUAGE="$LAST_READ_CONFIG"
[ -z "$language" ] && language="$DEFAULT_LANGUAGE"

# Checks sound player only if no output has been specified.
if [ -z "$speechOutput" ]; then
  checkAndSetConfig "$CONFIG_KEY.soundPlayer.path" "$CONFIG_TYPE_BIN"
  declare -r soundPlayerBin="$LAST_READ_CONFIG"
  checkAndSetConfig "$CONFIG_KEY.soundPlayer.options" "$CONFIG_TYPE_OPTION"
  declare -r soundPlayerOptions="$LAST_READ_CONFIG"
fi

# Gets functions specific to mode.
# N.B.: specific configuration will be checked asap the script is sourced.
declare -r specModScript="$currentDir/speech_$moduleMode"
if [ -f "$specModScript" ]; then
  isCheckModeConfigOnly && writeMessage "Checking configuration specific to mode '$moduleMode' ..."
  source "$specModScript"
elif ! isCheckModeConfigOnly; then
  errorMessage "Unable to find the core module sub-script '$specModScript'" $ERROR_MODE
fi

isCheckModeConfigOnly && exit 0

## Command line arguments check.
# Ensures mode is defined.
[ -z "${mode:-}" ] && usage

# Defines default speechOutput if needed.
[ -z "$speechOutput" ] && speechOutput="-"

#########################
## INSTRUCTIONS

case "$mode" in
  $MODE_TEXT)           speechSentence "$text";;
  $MODE_FILE)           readFileContents;;
  $MODE_INTERACTIVE)    startInteractiveMode;;
  [?])  usage;;
esac
