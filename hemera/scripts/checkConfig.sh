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
# Description: checks Hemera tools configuration.

#########################
## CONFIGURATION
currentDir=$( dirname "$( which "$0" )" )
installDir=$( dirname "$currentDir" )
category="check"
source "$installDir/scripts/setEnvironment.sh"

showError=0

#########################
## INSTRUCTIONS
# Checks all path defined in configuration file.
for pathKey in $( grep -re "^[^#][a-zA-Z.]*[.]path=" "$configurationFile" |sed -e 's/^\([^=]*\)=.*/\1/' ); do
  writeMessage "Checking '$pathKey' ... " 0
  pathValue=$( getConfigPath "$pathKey" )
  [ $? -ne 0 ] && echo "failed" && continue

  echo -ne "existence ... "
  ! checkBin "$pathValue" && echo -e "$pathValue \E[31mNOT found\E[0m" && continue
  echo "OK"
done
