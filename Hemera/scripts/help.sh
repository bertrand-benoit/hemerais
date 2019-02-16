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
# Description: gives some helps and tools description.

#########################
## CONFIGURATION
currentDir=$( dirname "$( which "$0" )" )
installDir=$( dirname "$currentDir" )
source "$currentDir/utilities.sh"

declare -r SPACE_COUNT=25
declare -r DESCRIPTION_LINE_LIMIT=22
declare -r MUST_NOT_BE_CALLED_LIMIT=25

# Gets offline documentation path if any.
declare -r offlineDocPath=$( getOfflineDocPath )

#########################
## FUNCTIONS
# usage: showScriptDescription <dir relative path>
function showScriptDescription() {
  local _scriptDir=$( echo "$1" |sed -e 's/^[.]\///g;' )

  local _firstScript=1
  for scriptRaw in $( find "$_scriptDir" -maxdepth 1 -type f -perm /u+x ! -name "*~" |sort |sed -e 's/[ \t]/£/g;' ); do
    script=$( echo "$scriptRaw" |sed -e 's/£/ /g;' )

    # Ensures it is not an internal script.
    [ $( head -n $MUST_NOT_BE_CALLED_LIMIT "$script" |grep -c "must NOT be directly called" ) -gt 0 ] && continue

    # Extracts the description.
    description=$( head -n $DESCRIPTION_LINE_LIMIT "$script" |grep -e "# Description:" |sed -e 's/# Description: //' )

    # Prints directory only if it is the first script to be shown.
    [ $_firstScript -eq 1 ] && _firstScript=0 && echo -e " in $_scriptDir"

    printf "   \E[1m%-${SPACE_COUNT}s\E[0m\t%s\n" $( basename "$script" ) "$description"
  done
}

#########################
## INSTRUCTIONS
echo -e "Hemera - Intelligent System - Help"
[ -n "$offlineDocPath" ] && echo -e "Offline documentation:\t$offlineDocPath"
echo -e "Online documentation:\thttp://hemerais.bertrand-benoit.net/doc"
echo -e "Quick Start:\t\thttp://hemerais.bertrand-benoit.net/doc/index.php?title=Hemera:QuickStart"
echo -e "Troubleshooting:\thttp://hemerais.bertrand-benoit.net/doc/index.php?title=Troubleshooting"
echo -e "Request Help:\t\thttps://github.com/bertrand-benoit/hemerais/issues"
echo -e "Check your config.:\tscripts/checkConfig.sh"
echo -e "In case of problem with a command, check the generated log which contains lots of information."
echo -e "\nAvailable tools"

# Looks for scripts directory everywhere.
cd "$installDir"
for scriptsDirRaw in $( find -regextype posix-extended -type d -regex ".*(scripts|daemon|speech|speechRecognition)" |sort |sed -e 's/[ \t]/£/g;' ); do
  scriptsDir=$( echo "$scriptsDirRaw" |sed -e 's/£/ /g;' )
  showScriptDescription "$scriptsDir"
done

# Misc directory contains some tools.
showScriptDescription "misc"
