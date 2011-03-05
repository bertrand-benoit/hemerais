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
# Description: setups Hemera.

#########################
## CONFIGURATION
currentDir=$( dirname "$( which "$0" )" )
installDir=$( dirname "$currentDir" )
source "$installDir/scripts/utilities.sh"

category="setup"
if [ -d "/etc/sysconfig" ]; then
  sysconfigFile="/etc/sysconfig/hemera"
elif [ -d "/etc/default" ]; then
  sysconfigFile="/etc/default/hemera"
else
  errorMessage "Unable to find system config directory (/etc/sysconfig and /etc/default not found" $ERROR_ENVIRONMENT
fi

profileFile="/etc/profile.d/hemera.sh"
h_configurationFile="$installDir/config/hemera.conf"

#########################
## INSTRUCTIONS
# Ensures user is root.
[ "$( whoami )" != "root" ] && errorMessage "Setup must be launched by root superuser." $ERROR_ENVIRONMENT
checkEnvironment || $ERROR_ENVIRONMENT

writeMessage "Defined installDir=$installDir"

# Writes the sysconfig file.
writeMessage "Managing System configuration file '$sysconfigFile' ... " 0
if [ -f "$sysconfigFile" ]; then
  echo "ignored (already exist)."
else
cat > $sysconfigFile << End-of-Message
# Installation directory.
installDir="$installDir"
End-of-Message

  echo "created."
fi

# Writes the profile file.
writeMessage "Managing Profile file '$profileFile' ... " 0
if [ -f "$profileFile" ]; then
  echo "ignored (already exist)."
else
cat > $profileFile << End-of-Message
# Ensures the configuration file exists.
if [ -f "$sysconfigFile" ]; then
  # Gets installation directory.
  source "$sysconfigFile"

  # Updates the path.
  source "$installDir/scripts/updatePath.sh"
fi
End-of-Message
  chmod +x "$profileFile"

  echo "created."

  writeMessage "Hemera main binary/script will be available after next reboot (source $profileFile for immediate effect in your shell)."
fi

# Checks if Hemera has been configured.
[ ! -f "$h_configurationFile" ] && writeMessage "You might begin configuring Hemera creating $h_configurationFile file from sample."
