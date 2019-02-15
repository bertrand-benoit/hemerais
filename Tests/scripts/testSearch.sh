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
# Description: performs command interpretation tests.
#
# Usage: see usage function.

# Ensures everything is stopped in same time of this script.
trap 'writeMessage "Interrupting all tests"; "$scripstDir/hemera.sh" -K; exit 0' INT

#########################
## CONFIGURATION
# general
currentDir=$( dirname "$( which "$0" )" )
installDir=$( dirname "$currentDir" )"/../Hemera"

# Ensures hemera main project is available in the same root directory.
[ ! -d "$installDir" ] && echo -e "Unable to find hemera main project ($installDir)" && exit 1

# completes configuration.
scripstDir="$installDir/scripts"
CATEGORY="TSearch."

# Defines priorly log file to avoid erasing while cleaning potential previous launch.
export LOG_FILE="/tmp/"$( date +'%s' )"-$CATEGORY.log"

source "$installDir/scripts/setEnvironment.sh"

# Informs about log file now that functions are available.
writeMessage "LogFile: $LOG_FILE"

# Defines some additionals variables.
speechScript="$h_coreDir/speech/speech.sh"

SEARCH_STRINGS=( "Intelligence Artificielle" "Conscience" "Compréhension" "Langage" "Logique" "Psychologie" "Sentiment" "Sensation" "Désir" "Evolution" "Monde" )
# English version: SEARCH_STRINGS=( "Artificial Intelligence" "Consciousness" "Understanding" "Language" "Logic" "Psychology" "Sentiment" "Sensation" "Desire" "Evolution" "World" )

#########################
## FUNCTIONS

# usage: simulateSearchPlugin <search term>
function simulateSearchPlugin() {
  local _term="$1"

  writeMessage "Simulating search definition plugin for: $_term"

  # Gets the corresponding URL.
  input=$( echo "$_term" |sed -e 's/[ \t]/%20/g;' )
  urlContentsFile="$h_workDir/$h_language-$_term-DefinitionContents.tmp"
  completeUrl="http://$h_language.mobile.wikipedia.org/transcode.php?go=$input"
  [ ! -s "$urlContentsFile" ] && ! getURLContents "$completeUrl" "$urlContentsFile" && errorMessage "Unable to get HTML file for definition of '$_term'" $ERROR_EXTERNAL_TOOL

  # Parses HTML.
  _destFile="$urlContentsFile.txt"
  _srcfile="$urlContentsFile"
  _tmpFile="$_srcfile.pruned"
  html2textRCFile="$h_coreDir/command/search_definition.mobile.wikipedia.rc"
  # Removes lots of things (VERY IMPORTANT: one-line substitution MUST be done before multi-line substituion to avoid bad positive):
  #  - any kind of thumb image -> div with class="thumbcaption" or class="thumbinner"
  #  - any part ('Bandeau' in French) requesting collaboration for definition
  #  - homonymy part (same line + multi line) ('homonymie' in French, 'disambiguation' in English)
  #  - See also part (same line + multi line)
  #  - language selector
  #  - any form (e.g. search)
  #  - any single image (e.g. <img ... Logo />)
  #  - any button (e.g. show/hidden)
  #  - any reference (e.g. <sup ...>[1]...</sup>) / one version with </span>, one without
  #  - any Navigation Head/Content (when one article links to several others)
  #  - any table
  #  - any remaining <tr> and <td> tags (can happen if there is nested <table>/</table>).
  #  - cut after 'footer'
  cat "$_srcfile" | sed \
    -e '/<div[ ]*class="thumbcaption"[^>]*>/,/<\/div>/d;/<div[ ]*class="thumbinner"[^>]*>/,/<\/div>/d;' \
    -e '/<table[^>]*><tr><td[^>]*class="bandeau-icone">/,/<\/table>/d;' \
    -e 's/<div[^>]*class="homonym.*"[^>]*>.*>[^<]*[Hh]omonym.*<\/a>[^<]*<\/div>//g;/<div[^>]*class="homonym.*"[^>]*>/,/<\/div>/d;' \
    -e 's/<div[^>]*class="dablink"[^>]*>.*>[^<]*[Dd]isambiguation.*<\/a>[^<]*<\/div>//g;/<div[ ]*class="dablink"[^>]*>/,/<\/div>/d;' \
    -e 's/<div[^>]*class="[^"]*seealso"[^>]*>See also.*<\/a>[^<]*<\/div>//g;/<div[^>]*class="[^"]*seealso"[^>]*>/,/<\/div>/d;' \
    -e '/<div[ ]*id="languageselectionsection[^>]*>/,/<\/div>/d;' \
    -e '/<form/,/<\/form>/d;' \
    -e 's/<img[^>]*\/>//g;' \
    -e 's/<button[^>]*>[^<]*<\/button>//g;' \
    -e 's/<div[^>]*class="section_anchors"[^>]*>[^<]*<a[^>]*>[^<]*<\/a><\/div>//g;' \
    -e 's/<sup[^[]*[[][^]]*[]]<\/span><\/a><\/sup>//g;s/<sup[^[]*[[][^]]*[]]<\/a><\/sup>//g;' \
    -e 's/<div[^>]*class="NavHead"[^>]*>.*<\/div>//g;/<div[^>]*class="NavHead"[^>]*>/,/<\/div>/d;' \
    -e 's/<div[^>]*class="NavContent"[^>]*>.*<\/div>//g;/<div[^>]*class="NavContent"[^>]*>/,/<\/div>/d;' \
    -e 's/<\/table>/<\/table>\n/g;/<table/,/<\/table>/d;' \
    -e 's/<tr[^>]*>.*<\/tr[^>]*>//g;s/<td[^>]*>.*<\/td[^>]*>//g;' \
    -e '/<div id=.footer.>/,//d' \
  > "$_tmpFile"

  # Converts HTML to text, with dedicated rcfile.
  # Then, performs some post processing:
  #  - cut anything since "Reference" part
  #  - removes empty lines
  #  - show at maximum 2 headings, and show only 1 heading, if there is more than N lines.
  echo -n "$SEARCH_CMD_DEF_OF_I18N" > "$_destFile"
  ! html2text -nobs -rcfile "$html2textRCFile" "$_tmpFile" |sed \
    -e '/^@@*R[eé]f[eé]rences/Q' | \
    grep -v "^$" | \
    awk '/@@@*/{head++; printSomething=0}; head >= 3 {exit}; head == 2 && NR >= 8 && !printSomething {exit}; { print $0; printSomething=1 }' | \
    sed -e 's/^@@@*\([^@]*\)$/\1.\n/g;' \
  >> "$_destFile" && errorMessage "Unable to convert HTML of file '$_srcfile'" -1 && return 1

  echo -e "***** RESULT - $_term - BEGIN *****"
  cat "$_destFile"
  echo -e "***** RESULT - $_term - END *****\n"

  # Uses the speech core module to read the produced file.
  LOG_FILE="$LOG_FILE" LOG_CONSOLE_OFF=${LOG_CONSOLE_OFF:-1} "$speechScript" -f "$_destFile" -o "$h_newInputDir/speech_$h_language-$input.wav"

  return 0
}

#########################
## INSTRUCTIONS
writeMessage "Test system will ensure Hemera is not running"
"$scripstDir/hemera.sh" -K

# Cleans everything, ensuring tests works on new "empty" structure.
"$scripstDir/makeHemera.sh" clean
"$scripstDir/makeHemera.sh" init

# Starts inputMonitor.
writeMessage "Test system will start some daemons"
"$h_daemonDir/inputMonitor.sh" -S

# We want all information about input management.
# export VERBOSE=1
export LOG_CONSOLE_OFF=0

# Starts IO processor.
export VERBOSE=1
"$h_daemonDir/ioprocessor.sh" -S
export VERBOSE=0

# Waits a little, everything is well started.
sleep 2

## Performs tests.
inputIndex=1
for searchStringRaw in "${SEARCH_STRINGS[@]}"; do
  searchString=$( echo "$searchStringRaw" |sed -e 's/€/ /g;' )
  # Launch search.
  simulateSearchPlugin "$searchString"

  # Wait some times.
  sleep 10

  # Requests stop, and wait until all is managed.
  writeMessage "Stopping speech synthesis of definition of: $searchString"
  echo "stop" > "$h_newInputDir/recognitionResult_test$inputIndex-2.txt"
  waitUntilAllInputManaged

  let inputIndex++
done

# Stops IO processor, and input monitor.
"$h_daemonDir/ioprocessor.sh" -K
"$h_daemonDir/inputMonitor.sh" -K
