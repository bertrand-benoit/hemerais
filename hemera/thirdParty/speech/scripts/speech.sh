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

CONFIG_KEY="hemera.core.speech"
SUPPORTED_MODE="espeak espeak+mbrola X"

# Gets the mode, and ensures it is a supported one.
moduleMode=$( getConfigValue "$CONFIG_KEY.mode" ) || exit 100
checkAvailableValue "$SUPPORTED_MODE" "$moduleMode" || errorMessage "Unsupported mode: $moduleMode"

# "Not yet implemented" message to help adaptation with potential futur other speech tools.
[[ "$moduleMode" != "espeak" ]] && [[ "$moduleMode" != "espeak+mbrola" ]] && errorMessage "Not yet implemented mode: $moduleMode"

# Default.
DEFAULT_LANGUAGE=$( getConfigValue "$CONFIG_KEY.espeak.language" ) || exit 100

# Gets functions specific to mode.
source "$currentDir/speech_$moduleMode"

# sound player configuration
soundPlayerBin=$( getConfigPath "$CONFIG_KEY.soundPlayer.path" ) || exit 100
soundPlayerOptions=$( getConfigValue "$CONFIG_KEY.soundPlayer.options" ) || exit 100

#########################
## Functions
# usage: usage
function usage() {
  echo -e "Usage: $0 [-t <text>|-u <url>|-f <file>|-d <terms> -i] [-o <output speech file>] [-l language] [-hv]"
  echo -e "<text>\ttext/sentences to speech"
  echo -e "<url>\turl of page content to read"
  echo -e "<file>\tfile to read"
  echo -e "<terms>\tterms to define (using Wikipedia)"
  echo -e "-i\tinteractive mode (generate and play speech file of each written line - CTRL+D to stop)"
  echo -e "-l\tuse another language (Default: $DEFAULT_LANGUAGE)"
  echo -e "-v\tactivate the verbose mode"
  echo -e "-h\tshow this usage"

  echo -e "\nYou must either use option -t, -u, -f, -d or -i."

  exit 1
}

# usage: startInteractiveMode
function startInteractiveMode() {
  while read line; do
    speechSentence "$line"
  done
}

# usage: getURLContents <url> <destination file>
function getURLContents() {
  info "Getting contents of URL '$1'"
  ! wget --user-agent="Mozilla/Firefox 3.6" -q "$1" -O "$2" && writeMessage "Error while getting contents of URL '$1'" && return 1
  info "Got contents of URL '$1' with success"
  return 0
}


# usage: readURLContents
function readURLContents() {
  urlContentsFile="$workDir/"$(date +"%s")"-urlContents.tmp"
  getURLContents "$url" "$urlContentsFile" || exit 11

  speechFileContents "$urlContentsFile"
}

# usage: readDefinition
function readDefinition() {
  urlContentsFile="$workDir/"$(date +"%s")"-DefinitionContents.tmp"
  termAsQueryString=$( echo "$termsToDefine" |sed -e 's/[ \t]/+/g;' )
  getURLContents "http://fr.mobile.wikipedia.org/transcode.php?go=$termAsQueryString" "$urlContentsFile" || exit 11
  sed -i 's/^.<a[^>]*>\([^<]*\)<.a>.<br..>//g;s/.*HAWHAW.*//g;' "$urlContentsFile"

  speechFileContents "$urlContentsFile"
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

verbose=0
language="$DEFAULT_LANGUAGE"
while getopts "t:u:f:d:io:l:vh" opt
do
 case "$opt" in
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

# Checks binaries availability (checks sound player only if speech output is NOT defined).
[ -z "$speechOutput" ] && ! checkBin "$soundPlayerBin" && exit 126
checkConfiguration || exit 126

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
