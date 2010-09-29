#!/bin/bash
#
# Author: Bertrand BENOIT <projettwk@users.sourceforge.net>
# Version: 1.0
# Description: input/output processor daemon (controls various Hemera [core] modules according to input).
#
# Usage: see usage function.

#########################
## CONFIGURATION
# general
currentDir=$( dirname "$( which "$0" )" )
installDir=$( dirname "$( dirname "$currentDir" )" )
category="IOProcessor"
source "$installDir/scripts/setEnvironment.sh"

CONFIG_KEY="hemera.core.iomanager.ioProcessorMonitor"
daemonName="input/output processor"

# tool configuration
monitorBin=$( getConfigPath "$CONFIG_KEY.path" ) || exit 100
monitorOptions=$( getConfigValue "$CONFIG_KEY.options" ) || exit 100

# tool configuration
ioprocessorBin="$0"

# Defines the PID file.
pidFile="$pidDir/ioProcessor.pid"

#########################
## Command line management

# N.B.: the -D (for daemon) option must be only internally used.
# N.B.: the -R (for run) option must be only internally used.
verbose=0
while getopts "STKDRvh" opt
do
 case "$opt" in
        S)
          action="start"
          newLogFile="$logFile"
          outputFile="$newLogFile"
        ;;
        T)      action="status";;
        K)      action="stop";;
        D)
          action="daemon"
          # Launches this script as daemon, used the -R option for core to run.
          options="$DAEMON_SPECIAL_RUN_ACTION"
        ;;
        R)      action="run";;

        v)      verbose=1;;
        h|[?])  daemonUsage "$daemonName" ;; 
 esac
done

# Ensures action is defined.
[ -z "$action" ] && daemonUsage "$daemonName"

# Checks tools.
checkBin "$ioprocessorBin" || exit 126
checkBin "$monitorBin" || exit 126

#########################
## INSTRUCTIONS

# Manages all action.
manageDaemon "$action" "$daemonName" "$pidFile" "$ioprocessorBin" "$newLogFile" "$outputFile" "$options"

# Exists but if in "run" action.
[[ "$action" != "run" ]] && exit 0

# Defines varibales.
input="$inputList"
options=$( eval echo "$monitorOptions" )


## Terminology.
# Each input file name begins with a sub string giving the type of input:
#  recordedSpeech_: recorded speech (-> usually needs speech recognition)
#  recognitionResult_: speech recognition result (-> according to mode, must be printed or speech)
#  speech_: test to speech result (-> according to mode, speech recognition can be needed)
SUPPORTED_TYPE="recordedSpeech recognitionResult speech"

speechRecognitionScript="$installDir/thirdParty/speechRecognition/scripts/speechRecognition.sh"
speechScript="$installDir/thirdParty/speech/scripts/speech.sh"

# This script IS the daemon which must perform action.
managedInput=0
while [ 1 ]; do
  # Waits for another input (checking write on the input list).
  "$monitorBin" $options

  # For each new input (from the last managed one) in list file.
  for input in $( getLastLinesFromN "$inputList" "$managedInput" ); do
    inputName=$( basename "$input" )
    inputType=${inputName/_*/}

    # Checks it is a known/supported type.
    if ! checkAvailableValue "$SUPPORTED_TYPE" "$inputType"; then
      writeMessage "Unsupported event: $inputName"

      # Moves the input into error input directory.
      mv "$newInputDir/$input" "$errInputDir"
    else
      writeMessage "Managing new (supported) input $inputName"
      # Moves the input to processing directory.
      inputPath="$curInputDir/$input"
      mv "$newInputDir/$input" "$inputPath"

      # According to the type
      case "$inputType" in
	recordedSpeech)
	  writeMessage "Launching speech recognition on $inputName"
	  "$speechRecognitionScript" -f "$inputPath" -R "$newInputDir/recognitionResult_$inputName.txt"
	;;

	recognitionResult)
	  writeMessage "Launching speech on $inputName"
	  "$speechScript" -f "$inputPath"
	;;

	[?]) writeMessage "Unknow event type, $inputName will be ignored";;
      esac
    fi

    # Memorizes a new input has been managed or ignored.
    let managedInput++
  done
done
