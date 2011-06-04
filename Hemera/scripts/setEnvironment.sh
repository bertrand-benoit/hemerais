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
# Ensures installDir is defined.
[ -z "$installDir" ] && echo -e "This script must NOT be directly called. installDir variable not defined" >&2 && exit 1
source "$installDir/scripts/utilities.sh"

# Ensures environment is OK.
checkEnvironment || $ERROR_ENVIRONMENT
checkOSLocale || $ERROR_ENVIRONMENT

# Defines Third-party directory, and ensures it is available.
h_tpDir="$installDir/../HemeraThirdParty"
[ ! -d "$h_tpDir" ] && errorMessage "$h_tpDir NOT found. You must get Third Party project. See documentation: https://sourceforge.net/apps/mediawiki/hemerais/index.php?title=Install_Hemera" $ERROR_ENVIRONMENT

# Updates configuration.
h_libDir="$installDir/lib"

# Defines configuration file, and ensures the system has been configured.
configDir="${HOME/%\//}/.hemera"
updateStructure "$configDir"
h_configurationFileSample="$installDir/config/hemera.conf.sample"
h_configurationFile="$configDir/hemera.conf"
[ ! -f "$h_configurationFile" ] && errorMessage "$h_configurationFile NOT found. You must create it to configure the system (See $h_configurationFileSample)." $ERROR_ENVIRONMENT

# Updates environment path if needed.
checkAndSetConfig "hemera.path.bin" "$CONFIG_TYPE_OPTION"
if [ ! -z "$h_lastConfig" ]; then
  formattedPaths=$( checkAndFormatPath "$h_lastConfig" )
  export PATH=$formattedPaths:$PATH
fi

checkAndSetConfig "hemera.path.lib" "$CONFIG_TYPE_OPTION"
if [ ! -z "$h_lastConfig" ]; then
  formattedPaths=$( checkAndFormatPath "$h_lastConfig" )
  export LD_LIBRARY_PATH=$formattedPaths:$LD_LIBRARY_PATH
fi

# Hemera language.
checkAndSetConfig "hemera.language" "$CONFIG_TYPE_OPTION"    
h_language="$h_lastConfig"
h_i18nFile="$installDir/i18n/hemera-i18n.$h_language"
[ ! -f "$h_i18nFile" ] && errorMessage "$h_i18nFile NOT found. You must configure the language (See $h_configurationFile.sample)." $ERROR_BAD_CLI
source "$h_i18nFile"

# Updates some internationalized constants.
H_SUPPORTED_RECO_CMD_MODES_I18N=( "$H_RECO_CMD_MODE_NORMAL_I18N" "$H_RECO_CMD_MODE_SECURITY_I18N" "$H_RECO_CMD_MODE_PARROT_I18N" )

# Defines some global variables about directories.
h_daemonDir="$installDir/scripts/daemon"
h_coreDir="$installDir/scripts/core"
h_logDir=$( getConfigPath "hemera.run.log" "$installDir" ) || exit $ERROR_CONFIG_PATH
updateStructure "$h_logDir"

# Structure:
#  queue/input/new    new input
#  queue/input/cur    input under processing
#  queue/input/err    input with unknown type or error occurs while processing
#  queue/input/done   input managed
queueDir=$( getConfigPath "hemera.run.queue" "$installDir" ) || exit $ERROR_CONFIG_PATH
inputDir="$queueDir/input"
h_newInputDir="$inputDir/new"
h_curInputDir="$inputDir/cur"
h_errInputDir="$inputDir/err"
h_doneInputDir="$inputDir/done"
updateStructure "$h_newInputDir"
updateStructure "$h_curInputDir"
updateStructure "$h_errInputDir"
updateStructure "$h_doneInputDir"

# Structure:
#  tmp/work   temporary files
#  tmp/pid    PID files
tmpDir=$( getConfigPath "hemera.run.temp" "$installDir" ) || exit $ERROR_CONFIG_PATH
h_workDir="$tmpDir/work"
h_pidDir="$tmpDir/pid"
updateStructure "$h_workDir"
updateStructure "$h_pidDir"

## Defines some other global variables.
h_fileDate=$(date +"%s")

# Hemera start time.
h_startTime="$h_workDir/starttime"

# Hemera recognized commands mode.
h_recoCmdModeFile="$h_workDir/mode"

# Hemera command list.
h_commandMap="$h_workDir/commandMap"

# inputMonitor/ioProcessor.
h_inputList="$h_logDir/inputList"

# processInput
h_speechRunningLockFile="$h_workDir/runningSpeech.lck"
h_speechRunningPIDFile="$h_pidDir/runningSpeech.pid"
h_speechToPlayList="$h_workDir/speechToPlay"

# Defines the log file if not already done.
if [ -z "$h_logFile" ]; then
  export h_logFile="$h_logDir/"$(date +"%Y-%m-%d-%H-%M-%S")"-$category.log"
  # Doesn't inform in 'checkConfigAndQuit' mode.
  [ $checkConfAndQuit -eq 0 ] && writeMessage "LogFile: $h_logFile"
fi
