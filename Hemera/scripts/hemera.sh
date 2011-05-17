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
source "$installDir/scripts/setEnvironment.sh"

CONFIG_KEY="hemera.run"
SUPPORTED_MODE="local client server"

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
}

#########################
## Command line management
# Defines verbose to 0 if not already defined.
verbose=${verbose:-0}
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
hemeraMode="$h_lastConfig"
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
inputMonitorActivation="$h_lastConfig"
checkAndSetConfig "$CONFIG_KEY.activation.ioProcessor" "$CONFIG_TYPE_OPTION"
ioProcessorActivation="$h_lastConfig"
checkAndSetConfig "$CONFIG_KEY.activation.soundRecorder" "$CONFIG_TYPE_OPTION"
soundRecorderActivation="$h_lastConfig"
checkAndSetConfig "$CONFIG_KEY.activation.tomcat" "$CONFIG_TYPE_OPTION"
tomcatActivation="$h_lastConfig"

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
      version=$( getVersion )
      writeMessage "Hemera version: $version"

      # Informs about uptime.
      uptime=$( getUptime )
      writeMessage "Hemera uptime: $uptime"
      
      # Informs about current Hemera mode.
      writeMessage "Hemera mode: $hemeraMode"

      # Informs about recognized commands mode.
      if [ -f "$h_recoCmdModeFile" ]; then
        recoCmdMode=$( getRecoCmdMode ) || exit $ERROR_ENVIRONMENT
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

  # Initializes.
  [ "$action" = "start" ] && ! initialization && exit $ERROR_ENVIRONMENT

  # According to components activation.
  [ "$inputMonitorActivation" = "localhost" ] && "$h_daemonDir/inputMonitor.sh" $option
  [ "$ioProcessorActivation" = "localhost" ] && "$h_daemonDir/ioprocessor.sh" $option
  [ "$soundRecorderActivation" = "localhost" ] && "$h_daemonDir/soundRecorder.sh" $option

  # Ensures there is no more PID files (like "runningSpeech" for instance, otherwise cleaning could not be done).
  [ "$action" = "stop" ] && rm -f "$h_pidDir"/* >/dev/null 2>&1

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
        writeMessage "Apache Tomcat $action ... " 0
        "$tomcatBin" >> "$h_logFile" 2>&1 && echo "ok" || echo "failed"
      fi
    fi
  fi
fi
