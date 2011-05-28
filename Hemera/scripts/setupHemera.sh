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

userSysfile="${HOME/%\//}/.hemera/hemera.sys"
h_configurationFile="${HOME/%\//}/.hemera/hemera.conf"
userBashfile="${HOME/%\//}/.bashrc"

#########################
## FUNCTIONS
# usage: usage
function usage() {
  echo -e "Usage: $0 [-fshv]"
  echo -e "-f\t\tforce file update"
  echo -e "-s\t\tinstall Hemera service (will automatically start at boot)"
  echo -e "-v\t\tactivate the verbose mode"
  echo -e "-h\t\tshow this usage"
  echo -e "\nBy default the system check if files already exist in which case it does nothing, you can use the -f option to force file update."
  exit $ERROR_USAGE
}

# usage: warnPermission
function warnPermission() {
  warning "Current user '"$( whoami )"' has not enough permission. Launch this script with 'sudo' or another user (or root) having enough permission."
}

# usage: writeSysconfigFile
function writeSysconfigFile() {
  if [ -d "/etc/sysconfig" ]; then
    sysconfigFile="/etc/sysconfig/hemera"
  elif [ -d "/etc/default" ]; then
    sysconfigFile="/etc/default/hemera"
  else
    warningMessage "Unable to find system config directory (/etc/sysconfig and /etc/default not found"
    return $ERROR_ENVIRONMENT
  fi

  createSysFile "$sysconfigFile"
}

# usage: checkSysFile <sys file>
# <sys file> can be the global system file, or the use system file.
# Checks if the file exists, and if the defined installDir still corresponds
#  to the installDir of this setup.
function checkSysFile() {
  local _sysFile="$1"

  # Checks if it exists.
  [ ! -f "$_sysFile" ] && return 1

  info "Found system file '$_sysFile'"

  # Checks if update if forced.
  [ $force -eq 1 ] && info "You have forced update of file '$_sysFile'" && return 1

  # Gets corresponding installation directory.
  confInstallDir=$( grep "^installDir=" "$_sysFile" |sed -e 's/^[^=]*=//;s/"//g;' )
  [ -z "$confInstallDir" ] && confInstallDir="NONE"

  # Ensures it is the same.
  [[ "$installDir" == "$confInstallDir" ]] && return 0

  writeMessage "Configured install directory '$confInstallDir' is NOT the same of this setup '$installDir', do you want to update ? [y/n] " 0
  read -n 1 answer
  echo ""
  [[ "$answer" != "y" ]]
}

# usage: checkSysFile <sys file>
# <sys file> can be the global system file, or the use system file.
function createSysFile() {
  local _sysFile="$1"

  # Writes the sysconfig file.
  writeMessage "Managing System configuration file '$_sysFile' ... " 0
  if [ ! -w "$( dirname "$_sysFile" )" ]; then
    echo "FAILED"
    warnPermission
  else
cat > "$_sysFile" << End-of-Message
# Installation directory.
installDir="$installDir"
# Localization and encoding.
LANG="${LANG:-en_US.UTF-8}"
End-of-Message

    echo "created/updated"
  fi
}

# usage: checkUserBashrc <file>
function checkUserBashrc() {
  local _userFile="$1"

  # Checks if it exists.
  [ ! -f "$_userFile" ] && return 1

  info "Found user bashrc file '$_userFile'"

  # Checks if there is already the instruction to update path.
  [ $( grep "emera" "$_userFile" |grep "updatePath" |wc -l ) -ge 1 ]
}

# usage: checkUserBashrc <file>
function updateUserBashrc() {
  local _userFile="$1"

  writeMessage "Managing user bashrc file '$_userFile' ... " 0
  if [ ! -w "$( dirname "$_userFile" )" ]; then
    echo "FAILED"
    warnPermission
  else
cat >> "$_userFile" << End-of-Message

# Updates PATH to make Hemera components available.
[ -f "$userSysfile" ] && source "$userSysfile" && source "\$installDir/scripts/updatePath.sh"
End-of-Message

    echo "updated"
  fi
}

#########################
## Command line management
# Defines verbose to 0 if not already defined.
verbose=${verbose:-0}
force=0
service=0
while getopts "fsvh" opt
do
 case "$opt" in
        f)      force=1;;
        s)      service=1;;
        v)      verbose=1;;
        h|[?])  usage;;
 esac
done

#########################
## INSTRUCTIONS
checkEnvironment || $ERROR_ENVIRONMENT

info "Install directory is '$installDir'"

## Manages user system file.
checkSysFile "$userSysfile" || createSysFile "$userSysfile"

## Manages user .bashrc file.
checkUserBashrc "$userBashfile" || updateUserBashrc "$userBashfile"

## Manages ssyconfig and service files.

## Manages Hemera Web module deploy.

## Checks if Hemera has been configured.
[ ! -f "$h_configurationFile" ] && writeMessage "You might begin configuring Hemera creating $h_configurationFile file from sample."

## Informs.
writeMessage "Hemera completed successfully."
