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
# Version: 1.1
# Description: manages command line and uses configured tool to perform text to speech.
#
# Usage: see usage function.

#########################
## CONFIGURATION
# general
currentDir=$( dirname "$( which "$0" )" )
installDir=$( dirname "$( dirname "$( dirname "$currentDir" )" )" )
category="speech"
source "$installDir/scripts/setEnvironment.sh"

declare -r CONFIG_KEY="hemera.core.speech"
declare -r SUPPORTED_MODE="espeak espeak+mbrola"

#########################
## Functions
# usage: usage
function usage() {
  echo -e "Usage: $0 [-t <text>|-u <url>|-f <file>|-d <terms> -i] [-o <output speech file>] [-l language] [-hvX]"
  echo -e "<text>\ttext/sentences to speech"
  echo -e "<url>\turl of page content to read"
  echo -e "<file>\tfile to read"
  echo -e "<terms>\tterms to define (using Wikipedia)"
  echo -e "-i\tinteractive mode (generate and play speech file of each written line - CTRL+D to stop)"
  echo -e "-l\tuse another language (Default: $DEFAULT_LANGUAGE)"
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

# usage: parseHTML <source URL> <source file> <destination file>
function parseHTML() {
  local _srcURL="$1" _srcfile="$2" _destFile="$3"
  local _txtFile="$_destFile.tmp"

  # Converts HTML to text.
  "$htmlConverter" -o "$_txtFile" "$_srcfile" >>"$h_logFile" 2>&1 || errorMessage "Unable to convert HTML of file '$_srcfile'" $ERROR_EXTERNAL_TOOL

  # Additional parsing according to search URL.
  if [[ "$_srcURL" =~ ".*mobile.wikipedia.*" ]]; then
    # Extracts contents part (will be in file numbered 1).
    # TODO: use -2 instead of 0, but manage error case where there is not enough lines.
    "$fileSplitter" -n 1 -qz -f "$_destFile" "$_txtFile" "/========/1" "/========/0" >>"$h_logFile" 2>&1 || errorMessage "Unable to split file '$_txtFile'" $ERROR_EXTERNAL_TOOL

    # Final parsing:
    #  - removes line containing only element in brackets
    #  - replaces all "_" by space
    #  - adds a space at the end of each line, and then removes line break
    #  - removes words in bracket, taking care of potential "bug" like "[roue] s,"
    #  - replaces some remaining html code (e.g. &quot;)
    cat "$_destFile"1 \
      |sed -e 's/^[[].*[]]$//g;s/\([^-]\)$/\1 /g;s/^[ \t]*D[ée]finition[ \t]*$//g;' |tr -d '\n' \
      |sed -e 's/[[]\([^]]*\)[]][ ]s\([[:punct:]]\)/\1s\2/g;s/[[]\([^]]*\)[]]/\1/g;' \
      |sed -e 's/&quot;/"/g;s/_/ /g;' \
    > "$_destFile"
  else
    warning "There is currently no additional parsing for source URL '$_srcURL' (result may not be good). Contact Hemera team to implement it."
    mv -f "$_txtFile" "$_destFile" 
  fi
}

# usage: readDefinition
function readDefinition() {
  local urlContentsFile="$h_workDir/$h_fileDate-DefinitionContents.tmp"
  input=$( echo "$termsToDefine" |sed -e 's/[ \t]/%20/g;' )
  getURLContents $( eval echo "$searchURL" ) "$urlContentsFile" || exit $ERROR_EXTERNAL_TOOL
  parseHTML "$searchURL" "$urlContentsFile" "$urlContentsFile.txt"

  speechFileContents "$urlContentsFile.txt"
}

# usage: readFileContents
function readFileContents() {
  speechFileContents "$filePath"
}

#########################
## Command line management
MODE_TEXT=1
MODE_URL=2
MODE_FILE=3
MODE_DEFINITION=4
MODE_INTERACTIVE=10

# Defines verbose to 0 if not already defined.
verbose=${verbose:-0}
language=""
speechOutput=""
while getopts "Xt:u:f:d:io:l:vh" opt
do
 case "$opt" in
        X)      checkConfAndQuit=1;;
        t)      mode=$MODE_TEXT;text="$OPTARG";;
        u)      mode=$MODE_URL;url="$OPTARG";;
        f)      mode=$MODE_FILE;filePath="$OPTARG";;
        d)      mode=$MODE_DEFINITION;termsToDefine="$OPTARG";;
        i)      mode=$MODE_INTERACTIVE;;
        l)      language="$OPTARG";;
        o)      speechOutput="$OPTARG";;
        v)      verbose=1;;
        h|[?]) usage;;
 esac
done

## Configuration check.
checkAndSetConfig "$CONFIG_KEY.mode" "$CONFIG_TYPE_OPTION"
declare -r moduleMode="$h_lastConfig"
# Ensures configured mode is supported, and then it is implemented.
if ! checkAvailableValue "$SUPPORTED_MODE" "$moduleMode"; then
  # It is not a fatal error if in "checkConfAndQuit" mode.
  _message="Unsupported mode: $moduleMode. Update your configuration."
  [ $checkConfAndQuit -eq 0 ] && errorMessage "$_message"
  warning "$_message"
else
  # It is not a fatal error if in "checkConfAndQuit" mode.
  # "Not yet implemented" message to help adaptation with potential futur mode.
  if [[ "$moduleMode" != "espeak" ]] && [[ "$moduleMode" != "espeak+mbrola" ]]; then
    _message="Not yet implemented mode: $moduleMode"
    [ $checkConfAndQuit -eq 0 ] && errorMessage "$_message" $ERROR_MODE
    warning "$_message"
  fi
fi

checkAndSetConfig "$CONFIG_KEY.espeak.language" "$CONFIG_TYPE_OPTION"
declare -r DEFAULT_LANGUAGE="$h_lastConfig"
[ -z "$language" ] && language="$DEFAULT_LANGUAGE"

# Checks sound player only if no output has been specified.
if [ -z "$speechOutput" ]; then
  checkAndSetConfig "$CONFIG_KEY.soundPlayer.path" "$CONFIG_TYPE_BIN"
  declare -r soundPlayerBin="$h_lastConfig"
  checkAndSetConfig "$CONFIG_KEY.soundPlayer.options" "$CONFIG_TYPE_OPTION"
  declare -r soundPlayerOptions="$h_lastConfig"
fi

checkAndSetConfig "hemera.core.command.general.htmlConverter.path" "$CONFIG_TYPE_BIN"
declare -r htmlConverter="$h_lastConfig"
checkAndSetConfig "hemera.core.command.general.fileSplitter.path" "$CONFIG_TYPE_BIN"
declare -r fileSplitter="$h_lastConfig"
checkAndSetConfig "hemera.core.command.search.url" "$CONFIG_TYPE_OPTION"
declare -r searchURL="$h_lastConfig"

# Gets functions specific to mode.
# N.B.: specific configuration will be checked asap the script is sourced.
declare -r specModScript="$currentDir/speech_$moduleMode"
if [ -f "$specModScript" ]; then
  [ $checkConfAndQuit -eq 1 ] && writeMessage "Checking configuration specific to mode '$moduleMode' ..."
  source "$specModScript"
elif [ $checkConfAndQuit -eq 0 ]; then
  errorMessage "Unable to find the core module sub-script '$specModScript'" $ERROR_MODE
fi

[ $checkConfAndQuit -eq 1 ] && exit 0

## Command line arguments check.
# Ensures mode is defined.
[ -z "$mode" ] && usage

# Defines default speechOutput if needed.
[ -z "$speechOutput" ] && speechOutput="-"

#########################
## INSTRUCTIONS

case "$mode" in
  $MODE_TEXT)		speechSentence "$text";;
  $MODE_URL) 		readURLContents;;
  $MODE_DEFINITION) 	readDefinition;;
  $MODE_FILE) 		readFileContents;;
  $MODE_INTERACTIVE)	startInteractiveMode;;
  [?])	usage;;
esac
