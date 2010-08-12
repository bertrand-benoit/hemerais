#!/bin/bash
#
# Author: Bertrand BENOIT <bertrand.benoit@bsquare.no-ip.org>
# Version: 1.0
# Description: uses espeak as a front-end to Mbrola, to speech specified text.
#
# Usage: see usage function.

#########################
## CONFIGURATION
# general
mypath=$( dirname "$( which "$0" )" )
installDir=$( dirname "$( dirname "$( dirname "$mypath" )" )" )
source "$installDir/scripts/utilities.sh"
source "$installDir/scripts/setEnvironment.sh"

# Default.
DEFAULT_LANGUAGE="mb/mb-fr4"

# espeak configuration
espeakBin="espeak"
additionalEspeakOption=""

# mbrola configuration
mbrolaBin="$mypath/../bin/mbrola"
mbrolaLanguageFile="$mypath/../data/language/fr4"  # must be coherent with selected language (See DEFAULT_LANGUAGE)

# sound player configuration
soundPlayer="aplay -q -r22050 -fS16"

#########################
## Functions
# usage: usage
function usage() {
  echo -e "Usage: $0 [-t <text>|-u <url>|-f <file>|-d <terms> -i] [-o <output speech file>] [-l language] [-v]"
  echo -e "<text>\ttext/sentences to speech"
  echo -e "<url>\turl of page content to read"
  echo -e "<file>\tfile to read"
  echo -e "<terms>\tterms to define (using Wikipedia)"
  echo -e "-i\t\tinteractive mode (generate and play speech file of each written line - CTRL+D to stop)"
  echo -e "-l\t\tuse another language (Default: $DEFAULT_LANGUAGE)"
  echo -e "-v\t\tactivate the verbose mode"
  echo -e "-h\t\tshow this usage"
  
  echo -e "\nYou must either use option -t, -u, -f, -d or -i."
  
  exit 1
}

# Usage: speechSentence <sentence>
function speechSentence() {
  # Checks if a specific language has been specified.
  if [ "$language" != "$DEFAULT_LANGUAGE" ]; then
    # Modus operandi:
    #  - uses espeak to generate speech sound
    #  - uses finally the speech sound player
    info "System will play speech '$1', using only espeak"
    "$espeakBin" -v "$language" -s 130 --stdout $additionalEspeakOption "$1" |$soundPlayer
  else
    # Modus operandi:
    #  - uses espeak to produce "phoneme mnemonics"
    #  - prefixes each line beginning with a space character (not supported by mbrola) by a ';'; as a comment
    #  - uses mbrola to generate speech sound
    #  - uses finally the speech sound player
    info "System will play speech '$1', using espeak, and mbrola"
    [ "$speechOutput" = "-" ] && speechTmpFile="$workDir/"$(date +"%s")"-speechFile.wav" || speechTmpFile="$speechOutput"
    "$espeakBin" -v "$language" -p 45 -s 170 -qxz $additionalEspeakOption "$1" |sed -e 's/^[ ]/; /g;' |"$mbrolaBin" -e "$mbrolaLanguageFile" - "$speechTmpFile"
    [ "$speechOutput" = "-" ] || writeMessage "Generated speech file: $speechTmpFile"
    $soundPlayer "$speechTmpFile"
  fi
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

  additionalEspeakOption="-m -f"
  speechSentence "$urlContentsFile"
}

# usage: readDefinition
function readDefinition() {
  urlContentsFile="$workDir/"$(date +"%s")"-DefinitionContents.tmp"
  termAsQueryString=$( echo "$termsToDefine" |sed -e 's/[ \t]/+/g;' )
  getURLContents "http://fr.mobile.wikipedia.org/transcode.php?go=$termAsQueryString" "$urlContentsFile" || exit 11
  sed -i 's/^.<a[^>]*>\([^<]*\)<.a>.<br..>//g;s/.*HAWHAW.*//g;' "$urlContentsFile"
  
  additionalEspeakOption="-m -f"
  speechSentence "$urlContentsFile"
}


# usage: readFileContents
function readFileContents() {
  additionalEspeakOption="-m -f"
  speechSentence "$filePath"
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
speechOutput="-"
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

[ -z "$mode" ] && usage

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
