#!/bin/bash
#
# Hemera - Intelligent System
# Copyright (C) 2010-2020 Bertrand Benoit <hemerais@bertrand-benoit.net>
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
CATEGORY="make"
source "$currentDir/setEnvironment.sh"

declare -r CONFIG_KEY="environment"
declare -r buildAntFile="$installDir/engineering/hemeraBuild.xml"

# Gets environment configuration
manageJavaHome || exit $ERROR_ENVIRONMENT
manageAntHome || exit $ERROR_ENVIRONMENT

declare -r ANT="$ANT_HOME/bin/ant"

#########################
## FUNCTIONS

#########################
## INSTRUCTIONS
declare -r target="${1:-all}"

# Checks if only initialization must be done -> meaning
#  only structure preparation (useful for tests).
if [ "$target" = "init" ]; then
  # Checks all existing PID files (allowing to remove potential PID files from previous run).
  checkAllProcessFromPIDFiles "$h_pidDir"

  # Ensures Hemera is not running (checking PID file).
  isHemeraComponentStarted && errorMessage "Hemera is running (found PID file(s)). You must stop Hemera before [re]init" $ERROR_ENVIRONMENT

  # Environment setup has already been done when this script sourced setEnvironment.sh.
  writeMessageSL "Making Hemera target: $target ... "
  ! initRecoCmdMode && errorMessage "Unable to initialize recognition command mode." $ERROR_ENVIRONMENT
  ! initializeCommandMap && errorMessage "Unable to initialize command map." $ERROR_ENVIRONMENT
  ! cleanNotManagedInput && errorMessage "Unable to clean remaining input." $ERROR_ENVIRONMENT
  echo "done"
  exit 0
fi

# Special management for "clean" target.
if [ "$target" = "clean" ]; then
  # Checks all existing PID files (allowing to remove potential PID files from previous run).
  checkAllProcessFromPIDFiles "$h_pidDir"

  # Ensures Hemera is not running (checking PID file).
  isHemeraComponentStarted && errorMessage "Hemera is running (found PID file(s)). You must stop Hemera before cleaning." $ERROR_ENVIRONMENT

  # Cleans any working directories.
  writeMessageSL "Cleaning queue and temporary directories ."
  for dirToClean in "$h_queueDir" "$h_tmpDir"; do
    rm -Rf "$dirToClean" >>"$LOG_FILE" 2>&1
    echo -ne "."
  done
  echo " done"
fi

writeMessageSL "Making Hemera target: $target ... "
! "$ANT" -v -f "$buildAntFile" "$target" >> "$LOG_FILE" 2>&1 && echo -e "error (See $LOG_FILE)" && exit 1

# Ensures the log file still exists (it won't be the case after "cleaning").
[ ! -f "$LOG_FILE" ] && echo "done" || echo "done" |tee -a "$LOG_FILE"

# All is completed.
exit 0
