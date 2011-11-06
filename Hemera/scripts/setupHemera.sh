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
source "$currentDir/utilities.sh"

category="setup"

declare -r userSysfile="${HOME/%\//}/.hemera/hemera.sys"
declare -r h_globalConfFile="/etc/hemera.conf"
declare -r h_globalConfFileSample="$installDir/config/hemera.conf.global.sample"
declare -r h_configurationFile="${HOME/%\//}/.hemera/hemera.conf"
declare -r userBashfile="${HOME/%\//}/.bashrc"
mkdir -p "${HOME/%\//}/.hemera"

#########################
## FUNCTIONS
# usage: usage
function usage() {
  echo -e "Usage: $0 [-gfshvT]"
  echo -e "-g\t\tperform global setup (only for root or user having enough permission)"
  echo -e "-T\t\tspecify third-party tools directory (default: $H_DEFAULT_TP_DIR)"
  echo -e "-f\t\tforce file update"
  echo -e "-s\t\tinstall Hemera service (only for global setup)"
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
    warningMessage "Unable to find system config directory (/etc/sysconfig and /etc/default not found)"
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
  if [[ "$installDir" == "$confInstallDir" ]]; then
    writeMessage "System file '$_sysFile' is up to date."
    return 0
  fi

  writeMessageSL "Configured install directory '$confInstallDir' is NOT the same of this setup '$installDir', do you want to update ? [y/n] "
  read -n 1 answer
  echo ""
  [[ "$answer" != "y" ]]
}

# usage: checkSysFile <sys file>
# <sys file> can be the global system file, or the use system file.
function createSysFile() {
  local _sysFile="$1"

  # Writes the sysconfig file.
  writeMessageSL "Managing System configuration file '$_sysFile' ... "
  if [ ! -w "$( dirname "$_sysFile" )" ]; then
    echo "FAILED"
    warnPermission
  else
cat > "$_sysFile" << End-of-Message
# Installation directory.
installDir="$installDir"
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
  if [ $( grep "emera" "$_userFile" |grep -c "updatePath" ) -ge 1 ]; then
    writeMessage "User bashrc file '$_userFile' is up to date."
    return 0
  fi

  # User bashrc file must be updated.
  return 1
}

# usage: checkUserBashrc <file>
function updateUserBashrc() {
  local _userFile="$1"

  writeMessageSL "Managing user bashrc file '$_userFile' ... "
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
global=0
tpDirRoot="$H_DEFAULT_TP_DIR"
force=0
service=0
while getopts "gfsvhT:" opt
do
 case "$opt" in
        g)      global=1;;
        T)      tpDirRoot="$OPTARG";;
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

## Checks if global setup.
if [ $global -eq 1 ]; then
  ## Ensures hemera group exist.
  info "Create/check 'hemera' group"
  groupadd -f hemera 2>/dev/null && writeMessage "'hemera' group created/updated." || warnPermission

  ## Creates global configuration file, if needed.
  writeGlobalConfigFile=0
  if [ -f "$h_globalConfFile" ]; then
    info "Found global configuration file '$h_globalConfFile'"
  else
    writeGlobalConfigFile=1
  fi

  [ $writeGlobalConfigFile -eq 0 ] && [ $force -eq 1 ] && writeMessage "You have forced update of global configuration file '$h_globalConfFile'" && writeGlobalConfigFile=1

  if [ $writeGlobalConfigFile -eq 1 ]; then
    [ ! -f "$h_globalConfFileSample" ] && errorMessage "Unable to find global configuration file sample '$h_globalConfFileSample'." $ERROR_ENVIRONMENT

    pathForSed=$( echo "$tpDirRoot" |sed -e 's/\//\\\//g;' )
    cat "$h_globalConfFileSample" |sed -e "s/^hemera.thirdParty.path=.*$/hemera.thirdParty.path=\"$pathForSed\"/" > "$h_globalConfFile" || warnPermission
    chgrp hemera "$h_globalConfFile"
    chmod g+rw "$h_globalConfFile"
    writeMessage "Global configuration file '$h_globalConfFile' created/updated."

    # Creates third-party directories structure.
    updateStructure "$tpDirRoot/_fromSource" || warnPermission
    updateStructure "$tpDirRoot/webServices" || warnPermission
    updateStructure "$tpDirRoot/speech/data/language" || warnPermission
    updateStructure "$tpDirRoot/speech/bin" || warnPermission
    updateStructure "$tpDirRoot/speechRecognition/bin" || warnPermission
    updateStructure "$tpDirRoot/speechRecognition/data/models/language" || warnPermission
    updateStructure "$tpDirRoot/speechRecognition/data/models/acoustic" || warnPermission
    updateStructure "$tpDirRoot/speechRecognition/data/models/lexical" || warnPermission

    chgrp -R hemera "$tpDirRoot"
    chmod -R g+rw "$tpDirRoot"
    find "$tpDirRoot" -type d -exec chmod g+x {} \;

    writeMessage "Third-party tools '$tpDirRoot' structure created/updated."
  fi

  ## Manages sysconfig and service files.
  [ $service -eq 1 ] && writeMessage "Service setup not implemented yet."
else
  # Ensures it is not root.
  isRootUser && errorMessage "User specific setup is NOT allowed for root user (use -g option for global setup)." $ERROR_ENVIRONMENT

  # It is NOT a global setup, manages user specific setup.
  ## Manages user system file.
  checkSysFile "$userSysfile" || createSysFile "$userSysfile"

  ## Manages user .bashrc file.
  checkUserBashrc "$userBashfile" || updateUserBashrc "$userBashfile"

  ## Checks if Hemera has been configured.
  [ ! -f "$h_configurationFile" ] && writeMessage "You might begin configuring Hemera creating $h_configurationFile file from sample."
fi

## Informs.
writeMessage "Hemera completed successfully."
