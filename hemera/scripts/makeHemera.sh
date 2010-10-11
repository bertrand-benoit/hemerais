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
# Description: makes Hemera (documentation, source code management ...).

#########################
## CONFIGURATION
currentDir=$( dirname "$( which "$0" )" )
installDir=$( dirname "$currentDir" )
category="make"
source "$installDir/scripts/setEnvironment.sh"

CONFIG_KEY="environment"
buildAntFile="$installDir/engineering/hemeraBuild.xml"

# Gets environment configuration
manageJavaHome || exit $ERROR_ENVIRONMENT
manageAntHome || exit $ERROR_ENVIRONMENT

ANT="$ANT_HOME/bin/ant"

#########################
## FUNCTIONS

#########################
## INSTRUCTIONS
target="${1:-libraries}"
writeMessage "Making Hemera target: $target ... " 0
"$ANT" -v -f "$buildAntFile" "$target" >> "$h_logFile" 2>&1 && echo "done" || echo "error (See $h_logFile)"
