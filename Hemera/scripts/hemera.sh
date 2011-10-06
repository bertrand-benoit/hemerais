#!/bin/bash
#
# Hemera - Intelligent System (https://sourceforge.net/projects/hemerais)
# Copyright (C) 2010-2011 Bertrand Benoit <projettwk@users.sourceforge.net>
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
# Description: starts/status/stops Hemera components according to configuration.

#########################
## CONFIGURATION
currentDir=$( dirname "$( which "$0" )" )
installDir=$( dirname "$currentDir" )
category="hemera"
# Each call to this main script must log in same logFile.
continueLogFile=1
source "$currentDir/setEnvironment.sh"

declare -r CONFIG_KEY="hemera.run"
declare -r SUPPORTED_MODE="local client server"

#########################
## FUNCTIONS
# usage: usage
function usage() {
  echo -e "Usage: $0 -S||-T||-K [-hvX]"
  echo -e "-S\tstart Hemera components (like daemons) according to configuration"
  echo -e "-T\tstatus Hemera components (like daemons) according to configuration"
  echo -e "-K\tstop Hemera components (like daemons) according to configuration"
  echo -e "-X\tcheck configuration and quit"
  echo -e "-v\tactivate the verbose mode"
  echo -e "-h\tshow this usage"
  echo -e "\nYou must either start, status or stop Hemera components."

  exit $ERROR_USAGE
}

# usage: initialization
function initialization() {
  initializeCommandMap
  initializeStartTime
  initializeMonitor
}

# usage: finalization
function finalization() {
  finalizeStartTime

  # Ensures there is no more PID files (like "runningSpeech" for instance, otherwise cleaning could not be done).
  rm -f "$h_pidDir"/* >> "$h_logFile" 2>&1

  # Moves the running logFile.
  if [ -f "$h_logFile" ]; then
    newLogName=$( basename "$h_logFile" )
    newLogPath="$h_logDir/"$(date +"%Y-%m-%d-%H-%M-%S")"-$newLogName"
    writeMessageSL "Moving LogFile to '$newLogPath' ... "
    # Does not log in log file because ... we have just moved it !
    mv -f "$h_logFile" "$newLogPath" && echo "done" || echo -e "\E[31mFAILED\E[0m"
  fi

  finalizeMonitor

  # Resets the input list.
  rm -f "$h_inputList" && touch "$h_inputList"
}

#########################
## Command line management
# Defines verbose to 0 if not already defined.
verbose=${verbose:-0}
action=""
while getopts "STKvhX" opt
do
 case "$opt" in
        X)      checkConfAndQuit=1;;
        S)      action="start";;
        T)      action="status";;
        K)      action="stop";;
        v)      verbose=1;;
        h|[?])  usage;; 
 esac
done

## Configuration check.
checkAndSetConfig "$CONFIG_KEY.mode" "$CONFIG_TYPE_OPTION"
declare -r hemeraMode="$h_lastConfig"
# Ensures configured mode is supported, and then it is implemented.
if ! checkAvailableValue "$SUPPORTED_MODE" "$hemeraMode"; then
  # It is not a fatal error if in "checkConfAndQuit" mode.
  _message="Unsupported mode: $hemeraMode. Update your configuration."
  [ $checkConfAndQuit -eq 0 ] && errorMessage "$_message"
  warning "$_message"
else
  # It is not a fatal error if in "checkConfAndQuit" mode.
  # "Not yet implemented" message to help adaptation with potential futur mode.
  if [[ "$hemeraMode" != "local" ]]; then
    _message="Not yet implemented mode: $hemeraMode"
    [ $checkConfAndQuit -eq 0 ] && errorMessage "$_message" $ERROR_MODE
    warning "$_message"
  fi
fi

checkAndSetConfig "$CONFIG_KEY.activation.inputMonitor" "$CONFIG_TYPE_OPTION"
declare -r inputMonitorActivation="$h_lastConfig"
checkAndSetConfig "$CONFIG_KEY.activation.ioProcessor" "$CONFIG_TYPE_OPTION"
declare -r ioProcessorActivation="$h_lastConfig"
checkAndSetConfig "$CONFIG_KEY.activation.soundRecorder" "$CONFIG_TYPE_OPTION"
declare -r soundRecorderActivation="$h_lastConfig"
checkAndSetConfig "$CONFIG_KEY.activation.tomcat" "$CONFIG_TYPE_OPTION"
declare -r tomcatActivation="$h_lastConfig"

[ $checkConfAndQuit -eq 1 ] && exit 0

## Command line arguments check.
# Ensures action is defined.
[ -z "$action" ] && usage

#########################
## INSTRUCTIONS

# According to Hemera mode.
if [ "$hemeraMode" = "local" ]; then
  # Defines option to use according to action.
  case "$action" in
    start)
      # Initializes recognized commands mode.
      initRecoCmdMode || exit $ERROR_ENVIRONMENT
      option="-S"
    ;;

    status)
      # Informs about version.
      declare -r version=$( getDetailedVersion )
      writeMessage "Hemera version: $version"

      # Informs about uptime.
      declare -r uptime=$( getUptime )
      writeMessage "Hemera uptime: $uptime"
      
      # Informs about current Hemera mode.
      writeMessage "Hemera mode: $hemeraMode"

      # Informs about recognized commands mode.
      if [ -f "$h_recoCmdModeFile" ]; then
        declare -r recoCmdMode=$( getRecoCmdMode ) || exit $ERROR_ENVIRONMENT
        writeMessage "Recognized commands mode: $recoCmdMode"
      fi

      # Prepares to inform about all daemons status.
      option="-T"
    ;;

    stop)
      option="-K"
    ;;

    h|[?])
      errorMessage "Unknown action: $action" $ERROR_BAD_CLI
    ;; 
  esac

  # Adds verbose if needed.
  [ $verbose -eq 1 ] && option="-v $option"

  # Initializes if not already done (e.g. if NOT isHemeraComponentStarted).
  if [ "$action" = "start" ]; then
    # Checks all existing PID files (allowing to remove potential PID files from previous run).
    checkAllProcessFromPIDFiles

    # Performs initialization only if there is not already a running component.
    ! isHemeraComponentStarted && ! initialization && exit $ERROR_ENVIRONMENT
  fi

  # According to components activation.
  [ "$inputMonitorActivation" = "localhost" ] && "$h_daemonDir/inputMonitor.sh" $option
  [ "$ioProcessorActivation" = "localhost" ] && "$h_daemonDir/ioprocessor.sh" $option
  [ "$soundRecorderActivation" = "localhost" ] && "$h_daemonDir/soundRecorder.sh" $option

  if [ "$tomcatActivation" = "localhost" ] && [ "$action" != "status" ]; then
    manageTomcatHome || exit $ERROR_ENVIRONMENT

    case "$action" in
      start)
        tomcatBin="$h_tomcatDir/bin/startup.sh";;
      stop)
        tomcatBin="$h_tomcatDir/bin/shutdown.sh";;
      *)
        tomcatBin="";;
    esac

    # Checks if a command has been specified.
    if [ ! -z "$tomcatBin" ]; then
      if [ ! -x "$tomcatBin" ]; then
        warning "Unable to find $tomcatBin, or the current user has not the execute privilege on it. Tomcat management will not be done."
      else
        writeMessageSL "Apache Tomcat $action ... "
        "$tomcatBin" >> "$h_logFile" 2>&1 && echo "ok" || echo -e "\E[31mFAILED\E[0m"
      fi
    fi
  fi

  # Finalizes.
  [ "$action" = "stop" ] && ! finalization && exit $ERROR_ENVIRONMENT
fi
