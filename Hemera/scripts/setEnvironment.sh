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
# Description: provides lots of utilities functions.
#
# This script must NOT be directly called.
# installDir variable must be defined.

#########################
## Global variables
# Ensures installDir is defined; then ensured sub directory scripts is available.
# It may NOT be the case if user has NOT installed GNU version of which and launched scripts
#  with particular $PWD (for instance launching setupHemera.sh being in the scripts sub directory).
[ -z "$installDir" ] && echo -e "This script must NOT be directly called. installDir variable not defined" >&2 && exit 1
[ ! -d "$installDir/scripts" ] && [ $( LANG=C which --version 2>&1|head -n 1 |grep -cw "GNU" ) -ne 1 ] && echo -e "\E[31m\E[4mERROR\E[0m: failure in path management; you MUST have a GNU version of 'which' tool (check Hemera documentation)." && exit 1
source "$installDir/scripts/utilities.sh"

# Ensures environment is OK.
checkEnvironment || $ERROR_ENVIRONMENT
checkOSLocale || $ERROR_ENVIRONMENT

# Updates configuration.
declare -rx h_libDir="$installDir/lib"

# Defines global configuration file.
# It is NOT mandatory to have a global configuration file to allow user with NO privileges access to use Hemera.
declare -rx h_globalConfFile="/etc/hemera.conf"

# Safe-guard: ensures HOME variable is defined and corresponding path exists.
! isRootUser && [ -z "${HOME:-}" ] && errorMessage "HOME environment variable must be defined." $ERROR_ENVIRONMENT
! isRootUser && [ ! -d "$HOME" ] && errorMessage "Home directory '$HOME' must exist (update your HOME environment variable)." $ERROR_ENVIRONMENT

# Defines configuration file, and ensures the system has been configured.
declare -r configDir="$( pruneSlash $HOME )/.hemera"
updateStructure "$configDir"
declare -rx h_configurationFileSample="$installDir/config/hemera.conf.sample"
declare -rx h_configurationFile="$configDir/hemera.conf"
! isRootUser && [ ! -f "$h_configurationFile" ] && errorMessage "$h_configurationFile NOT found. You must create it to configure the system (See $h_configurationFileSample)." $ERROR_ENVIRONMENT

# Safe-guard: at least one configuration file must exist.
if [ ! -f "$h_globalConfFile" ] && [ ! -f "$h_configurationFile" ]; then
  errorMessage "There is no global configuration file neither a user configuration file. Hemera must be setup." $ERROR_ENVIRONMENT
fi

# Prepares variable defining minimal configuration is OK.
minConfigOK=1

# Defines Third-party directory, and ensures it is available.
checkAndSetConfig "hemera.thirdParty.path" "$CONFIG_TYPE_PATH" "$installDir"
declare -rx h_tpDir="$h_lastConfig"
if [[ "$h_tpDir" == "$CONFIG_NOT_FOUND" ]]; then
  _message="Hemera must be setup (contact admin), or update one of configuration files to define third-party tools root directory. See documentation: https://sourceforge.net/apps/mediawiki/hemerais/index.php?title=Install_Hemera"
  [ $checkConfAndQuit -eq 0 ] && errorMessage "$_message" $ERROR_ENVIRONMENT
  warning "$_message"
  minConfigOK=0
fi

# Updates environment path if needed.
checkAndSetConfig "hemera.path.bin" "$CONFIG_TYPE_OPTION"
if [[ "$h_lastConfig" != "$CONFIG_NOT_FOUND" ]]; then
  formattedPaths=$( checkAndFormatPath "$h_lastConfig" )
  export PATH=$formattedPaths:$PATH
else
  minConfigOK=0
fi

checkAndSetConfig "hemera.path.lib" "$CONFIG_TYPE_OPTION"
if [[ "$h_lastConfig" != "$CONFIG_NOT_FOUND" ]]; then
  formattedPaths=$( checkAndFormatPath "$h_lastConfig" )
  export LD_LIBRARY_PATH=$formattedPaths:$LD_LIBRARY_PATH
else
  minConfigOK=0
fi

# Hemera language.
checkAndSetConfig "hemera.language" "$CONFIG_TYPE_OPTION"
if [ ! -z "$h_lastConfig" ] && [[ "$h_lastConfig" != "$CONFIG_NOT_FOUND" ]]; then
  h_language="$h_lastConfig"
else
  [ -z "$h_lastConfig" ] && warning "'hemera.language' must be defined with no-empty value (using 'en' as default language)."
  h_language="en"
  minConfigOK=0
fi

declare -rx h_language
declare -rx h_i18nFile="$installDir/i18n/hemera-i18n.$h_language"
[ ! -f "$h_i18nFile" ] && errorMessage "$h_i18nFile NOT found. You must configure the language (See $h_configurationFile.sample)." $ERROR_BAD_CLI
source "$h_i18nFile"

# Updates some internationalized constants.
declare -rx H_SUPPORTED_RECO_CMD_MODES_I18N=( "$H_RECO_CMD_MODE_NORMAL_I18N" "$H_RECO_CMD_MODE_SECURITY_I18N" "$H_RECO_CMD_MODE_PARROT_I18N" )

# Defines some global variables about directories.
declare -rx h_daemonDir="$installDir/scripts/daemon"
declare -rx h_coreDir="$installDir/scripts/core"

## Checks if current user is root, in which case there is
#   no specific configuration of following elements which are user specific.
if isRootUser; then
  # If 'check config and quit' mode  is not activated yet (like when a script is launched with -X option),
  #  ensures that it will be performing short-circuit tests on arguments.
  [ $checkConfAndQuit -eq 0 ] && [ $( echo "$*" |grep -wEc "\-X|\-Xh|\-hX" ) -eq 0 ] && errorMessage "root user can only use -X and -h options with this command." $ERROR_ENVIRONMENT

  # Completes minimal configuration needed to perform check config of all components.
  declare -rx h_minConfigOK="$minConfigOK"
  declare -rx h_logDir="$H_DEFAULT_WORK_DIR/$( whoami )/log"
  declare -rx h_pidDir="$H_DEFAULT_WORK_DIR"
  return 0
fi

## N.B.: checkAndSetConfig will fail on fatal error if config is NOT found; but if checkConfig has been launched
#  in which case, fatal error is replaced by a warning; in this case the value is $CONFIG_NOT_FOUND, in which case
#  structure must NOT be updated/created.

checkAndSetConfig "hemera.run.log" "$CONFIG_TYPE_PATH" "$installDir" 0
declare -rx h_logDir="$h_lastConfig"
checkForbiddenPath "$h_logDir" || errorMessage "For security reason, '$h_logDir' is a forbidden path. Update 'hemera.run.log' configuration." $ERROR_ENVIRONMENT
if [[ "$h_logDir" != "$CONFIG_NOT_FOUND" ]]; then
  updateStructure "$h_logDir"
else
  minConfigOK=0
fi

# Structure:
#  [queue]/new    new input
#  [queue]/cur    input under processing
#  [queue]/err    input with unknown type or error occurs while processing
#  [queue]/done   input managed
checkAndSetConfig "hemera.run.queue" "$CONFIG_TYPE_PATH" "$installDir" 0
declare -rx queueDir="$h_lastConfig"
checkForbiddenPath "$queueDir" || errorMessage "For security reason, '$queueDir' is a forbidden path. Update 'hemera.run.queue' configuration." $ERROR_ENVIRONMENT
if [[ "$queueDir" != "$CONFIG_NOT_FOUND" ]]; then
  declare -rx h_newInputDir="$queueDir/new"
  declare -rx h_curInputDir="$queueDir/cur"
  declare -rx h_errInputDir="$queueDir/err"
  declare -rx h_doneInputDir="$queueDir/done"
  updateStructure "$h_newInputDir"
  updateStructure "$h_curInputDir"
  updateStructure "$h_errInputDir"
  updateStructure "$h_doneInputDir"
else
  minConfigOK=0
fi

# Structure:
#  [tmp]/cache  main Hemera process files
#  [tmp]/pid    PID files
#  [tmp]/work   temporary files
checkAndSetConfig "hemera.run.temp" "$CONFIG_TYPE_PATH" "$installDir" 0
declare -rx tmpDir="$h_lastConfig"
checkForbiddenPath "$tmpDir" || errorMessage "For security reason, '$tmpDir' is a forbidden path. Update 'hemera.run.temp' configuration." $ERROR_ENVIRONMENT
if [[ "$tmpDir" != "$CONFIG_NOT_FOUND" ]]; then
  declare -rx h_cacheDir="$tmpDir/cache"
  declare -rx h_pidDir="$tmpDir/pid"
  declare -rx h_workDir="$tmpDir/work"
  updateStructure "$h_cacheDir"
  updateStructure "$h_pidDir"
  updateStructure "$h_workDir"
else
  minConfigOK=0
fi

# Further environment set is no more needed for 'check configuration and quit' mode.
declare -rx h_minConfigOK="$minConfigOK"
if [ $checkConfAndQuit -eq 1 ]; then
  declare -x h_logFile="$H_DEFAULT_LOG.checkConfig-$( whoami )"
  return 0
fi

## Defines some other global variables.
declare -rx h_fileDate=$(date +"%s.%N")

# Hemera running log file.
declare -rx h_runningLogFile="$h_logDir/runningHemera.log"

# Hemera start time.
declare -rx h_startTime="$h_cacheDir/starttime"

# Hemera recognized commands mode.
declare -rx h_recoCmdModeFile="$h_cacheDir/recoCmdMode"

# Hemera command list.
declare -rx h_commandMap="$h_cacheDir/commandMap"

# inputMonitor/ioProcessor.
declare -rx h_inputList="$h_cacheDir/inputList"

# Hemera monitoring.
declare -rx h_monitor="$h_cacheDir/monitor"

# processInput
declare -rx h_speechRunningLockFile="$h_cacheDir/runningSpeech.lck"
declare -rx h_speechRunningPIDFile="$h_pidDir/runningSpeech.pid"
declare -rx h_speechToPlayList="$h_cacheDir/speechToPlay"

# Defines the log file if not already done (e.g. if it has the default value).
if [[ "$h_logFile" == "$H_DEFAULT_LOG" ]]; then
  # IMPORTANT: $h_logFile is NOT read-only allowing to generate specific log file for some components
  #  like speech recognition which need post-processing (like log analyzing); which will be more efficient
  #  on little log.

  # Checks if the caller must continue in same log file (usually it is the case
  #  of the main Hemera script).
  if [ $continueLogFile -eq 1 ]; then
    declare -x h_logFile="$h_runningLogFile"
    messagePrefix="continue"
  else
    declare -x h_logFile="$h_logDir/"$(date +"%Y-%m-%d-%H-%M-%S")"-$category.log"
    messagePrefix="new"
  fi

  # Doesn't inform in 'checkConfigAndQuit' mode.
  [ $checkConfAndQuit -eq 0 ] && writeMessage "$messagePrefix LogFile: $h_logFile"
fi
