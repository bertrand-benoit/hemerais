#!/bin/bash
#
# Author: Bertrand BENOIT <projettwk@users.sourceforge.net>
# Version: 1.0
# Description: gives some helps and tools description.

#########################
## CONFIGURATION
currentDir=$( dirname "$( which "$0" )" )
installDir=$( dirname "$currentDir" )
source "$installDir/scripts/utilities.sh"

SPACE_COUNT=25

#########################
## FUNCTIONS
# usage: showScriptDescription <dir relative path>
function showScriptDescription() {
  local _scriptDir=$( echo "$1" |sed -e 's/^[.]\///g;' )

  echo -e " in $_scriptDir"
  for scriptRaw in $( find "$_scriptDir" -maxdepth 1 -type f -perm /u+x ! -name "*~" |sort |sed -e 's/[ \t]/£/g;' ); do
    script=$( echo "$scriptRaw" |sed -e 's/£/ /g;' )

    # Ensures it is not an internal script.
    [ $( head "$script" |grep "must NOT be directly called" |wc -l ) -gt 0 ] && continue

    # Extracts the description.
    description=$( head "$script" |grep -re "# Description:" |sed -e 's/# Description: //' )

    printf "   \E[1m%-${SPACE_COUNT}s\E[0m\t%s\n" $( basename "$script" ) "$description"
  done
}

#########################
## INSTRUCTIONS
echo -e "Hemera - Intelligent System - Help"
echo -e "Online documentation: https://sourceforge.net/apps/mediawiki/hemerais/index.php?title=Main_Page"
echo -e "Configuration file: config/hemera.conf"
echo -e "Check your configuration: scripts/checkConfig.sh"
echo -e "See README and INSTALL files."
echo -e "\nAvailable tools"

# Looks for scripts directory everywhere.
cd "$installDir"
for scriptsDirRaw in $( find -regextype posix-extended -type d -regex ".*(scripts|daemon)" |sort |sed -e 's/[ \t]/£/g;' ); do
  scriptsDir=$( echo "$scriptsDirRaw" |sed -e 's/£/ /g;' )
  showScriptDescription "$scriptsDir"
done

# Misc directory contains some tools.
showScriptDescription "misc"
