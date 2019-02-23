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
# Version: 1.1
# Description: uses scripts-common utilities functions and defines specific ones to Hemera.
#
# This script must NOT be directly called.
# installDir variable must be defined.

# Ensures installDir is defined; then ensured sub directory scripts is available.
# It may NOT be the case if user has NOT installed GNU version of which and launched scripts
#  with particular $PWD (for instance launching setupHemera.sh being in the scripts sub directory).
[ -z "$installDir" ] && echo -e "This script must NOT be directly called. installDir variable not defined" >&2 && exit 1
[ ! -d "$installDir/scripts" ] && [ $( LANG=C which --version 2>&1|head -n 1 |grep -cw "GNU" ) -ne 1 ] && echo -e "\E[31m\E[4mERROR\E[0m: failure in path management; you MUST have a GNU version of 'which' tool (check Hemera documentation)." && exit 1
source "$installDir/scripts/defineConstants.sh"

# Uses the former utilities which is now generic, and in dedicated scripts-common project.
source "$installDir/scripts-common/utilities.sh"

# Dumps function call in case of error, or when exiting with something else than status 0.
trap '_status=$?; dumpFuncCall $_status' ERR
trap '_status=$?; [ $_status -ne 0 ] && dumpFuncCall $_status' EXIT

#########################
## Global variables
# Initializes environment variables if not already the case.
ANT_HOME=${ANT_HOME:-}
JAVA_HOME=${JAVA_HOME:-}
LD_LIBRARY_PATH=${LD_LIBRARY_PATH:-}

#########################
## Functions - various
# usage: cleanNotManagedInput
function cleanNotManagedInput() {
  info "Cleaning NOT managed input (new and current)"
  rm -f "$h_newInputDir"/* "$h_curInputDir"/* >/dev/null || exit $ERROR_ENVIRONMENT
}

# usage: waitUntilAllInputManaged [<timeout>]
# Default timeout is 2 minutes.
function waitUntilAllInputManaged() {
  local _remainingTime=${1:-120}
  info "Waiting until all input are managed (timeout: $_remainingTime seconds)"
  while ! isEmptyDirectory "$h_newInputDir" || ! isEmptyDirectory "$h_curInputDir"; do
    [ $_remainingTime -eq 0 ] && break
    sleep 1
    let _remainingTime--
  done
}

#########################
## Functions - PID & Process management
# usage: isHemeraComponentStarted
# returns <true> if at least one component is started (regarding PID files).
function isHemeraComponentStarted() {
  [ $( find "$DEFAULT_PID_DIR" -type f |wc -l ) -gt 0 ]
}

#########################
## Functions - configuration

# usage: checkForbiddenPath <path>
# Ensures specified path is NOT forbidden.
function checkForbiddenPath() {
  local _path="$1"
  [ $( echo "$H_FORBIDDEN_PATH" | grep -wc "$_path" ) -eq 0 ]
}


#########################
## Functions - Recognized Commands mode
# usage: initRecoCmdMode
# Creates hemera mode file with normal mode.
function initRecoCmdMode() {
  updateRecoCmdMode "$H_RECO_CMD_MODE_NORMAL_I18N"
}

# usage: updateRecoCmdMode <i18n mode>
function updateRecoCmdMode() {
  local _newModei18N="$1"

  # Defines the internal mode corresponding to this i18n mode (usually provided by speech recognition).
  local _modeIndex=0
  for availableMode in ${H_SUPPORTED_RECO_CMD_MODES_I18N[*]}; do
    # Checks if this is the specified mode.
    if [ "$_newModei18N" = "$availableMode" ]; then
      # It is the case, writes the corresponding internal mode in the mode file.
      echo "${H_SUPPORTED_RECO_CMD_MODES[$_modeIndex]}" > "$h_recoCmdModeFile"
      return 0
    fi

    let _modeIndex++
  done

  # No corresponding internal mode has been found, it is fatal.
  # It should NEVER happen because mode must have been checked before this call.
  errorMessage "Unable to find corresponding internal mode of I18N mode '$_newModei18N'" $ERROR_ENVIRONMENT
}

# usage: getRecoCmdMode
# Returns the recognized commands mode.
function getRecoCmdMode() {
  # Ensures the mode file exists.
  [ ! -f "$h_recoCmdModeFile" ] && errorMessage "Unable to find Hemera recognized command mode file '$h_recoCmdModeFile'" $ERROR_ENVIRONMENT
  cat "$h_recoCmdModeFile"
}

# usage: initializeMonitor
function initializeMonitor() {
  rm -f "$h_monitor"
  logMonitor "$H_MONITOR_BEGIN_I18N"
}

# usage: logMonitor <i18n message> [<input>]
# <i18n message> must correspond of a i18n element defined in corresponding i18n file.
# <input> in case of plugin activity message (usually the case)
function logMonitor() {
  local _message="$1" _input="${2:-}"

  # TODO: adapt date to language
  local completeMessage="$(date +"%d/%m/%y %H:%M.%S") $_message"
  [ -n "$_input" ] && completeMessage="$completeMessage ($_input)"
  echo "$completeMessage" >> "$h_monitor"
}

# usage: finalizeStartTime
function finalizeMonitor() {
  logMonitor "$H_MONITOR_END_I18N"
}

#########################
## Functions - commands

# usage: initializeCommandMap
function initializeCommandMap() {
  # Removes the potential existing list file.
  rm -f "$h_commandMap"

  # For each available commands.
  for commandRaw in $( find "$h_coreDir/command" -maxdepth 1 -type f ! -name "*~" ! -name "*.txt" ! -name "*.rc" |sort |sed -e 's/[ \t]/£/g;' ); do
    local _command=$( echo "$commandRaw" |sed -e 's/£/ /g;' )
    local _commandName=$( basename "$_command" )

    # Extracts keyword.
    local _keyword=$( head -n 30 "$_command" |grep "^#.Keyword:" |sed -e 's/^#.Keyword:[ \t]*//g;s/[ \t]*$//g;' )
    [ -z "$_keyword" ] && warning "The command '$_commandName' doesn't seem to respect format. It will be ignored." && continue

    # Updates command map file.
    for localizedName in $( grep -e "$_keyword"_"PATTERN_I18N" "$h_i18nFile" |sed -e 's/^[^(]*(//g;s/).*$//g;s/"//g;' ); do
      echo "$localizedName=$_command" >> "$h_commandMap"
    done
  done
}

# usage: getMappedCommand <speech recognition result command>
# <speech recognition result command>: 1 word corresponding to speeched command
# returns the mapped command script if any, empty string otherwise.
function getMappedCommand() {
  local _commandName="$1"

  # Ensures map file exists.
  [ ! -f "$h_commandMap" ] && warning "The command map file has not been initialized." && return 1

  # Attempts to get mapped command script.
  echo $( grep "^$_commandName=" "$h_commandMap" |sed -e 's/^[^=]*=//g;' )
}


#########################
## Functions - source code management

# usage: manageTomcatHome
# Ensures Tomcat environment is ok, and defines h_tomcatDir.
function manageTomcatHome() {
  local tomcatDir="$h_tpDir/webServices/bin/tomcat"
  if [ ! -d "$tomcatDir" ]; then
    # It is a fatal error but in 'MODE_CHECK_CONFIG' mode.
    local _errorMessage="Apache Tomcat '$tomcatDir' not found. You must either disable Tomcat activation (hemera.run.activation.tomcat), or install it/create a symbolic link."
    ! isCheckModeConfigOnly && errorMessage "$_errorMessage" $ERROR_CONFIG_VARIOUS
    warning "$_errorMessage" && return 0
  fi

  export h_tomcatDir="$tomcatDir"

  # Checks the Tomcat version.
  local _version="Apache Tomcat Version [unknown]"
  if [ -f "$tomcatDir/RELEASE-NOTES" ]; then
    _version=$( head -n 30 "$tomcatDir/RELEASE-NOTES" |grep "Apache Tomcat Version" |sed -e 's/^[ \t][ \t]*//g;' )
  elif [ -x "/bin/rpms" ]; then
    _version="Apache Tomcat Version "$( cd -P "$tomcatDir"; /bin/rpm -qf "$PWD" |sed -e 's/^[^-]*-\([0-9.]*\)-.*$/\1/' )
  fi

  writeMessage "Found: $_version"
}

# usage: launchJavaTool <class qualified name> <additional properties> <options>
function launchJavaTool() {
  local _jarFile="$h_libDir/hemera.jar"
  local _className="$1"
  local _additionalProperties="$2"
  local _options="$3"

  # Checks if VERBOSE.
  [ $VERBOSE -eq 0 ] && _additionalProperties="$_additionalProperties -Dhemera.log.noConsole=true"

  # Ensures jar file has been created.
  [ ! -f "$_jarFile" ] && errorMessage "You must build Hemera libraries before using $_className" $ERROR_ENVIRONMENT

  # N.B.: java tools output (standard and error) are append to the logfile; however, some error messages can
  #  be directly printed on output, so output are redirected to logfile too.

  # Launches the tool.
  "$JAVA_HOME/bin/java" -classpath "$_jarFile" \
    -Djava.system.class.loader=hemera.HemeraClassLoader \
    -Dhemera.property.file="$h_configurationFile" \
    -Dhemera.log.file="$LOG_FILE" $_additionalProperties \
    "$_className" \
    $_options >> "$LOG_FILE" 2>&1
}
