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
# Description: defines Hemera constants.
#
# This script must NOT be directly called.

## General constants
# Hemera version.
H_VERSION="0.2b1"

# Configuration element types.
CONFIG_TYPE_OPTION=1
CONFIG_TYPE_BIN=2
CONFIG_TYPE_DATA=3

# Hemera modes.
H_RECO_CMD_MODE_NORMAL="normal"
H_RECO_CMD_MODE_SECURITY="security"
H_RECO_CMD_MODE_PARROT="parrot"
H_SUPPORTED_RECO_CMD_MODES=( "$H_RECO_CMD_MODE_NORMAL" "$H_RECO_CMD_MODE_SECURITY" "$H_RECO_CMD_MODE_PARROT" )

# timeout (in seconds) when stopping process, before killing it.
PROCESS_STOP_TIMEOUT=10
DAEMON_SPECIAL_RUN_ACTION="-R"

## Error code
# Default error message code.
ERROR_DEFAULT=101

# Error code after showing usage.
ERROR_USAGE=102

# Command line syntax not respected.
ERROR_BAD_CLI=103

# Bad/incomplete environment, like:
#  - missing Java or Ant
#  - bad user (e.g. Hemera setup)
#  - permission issue (e.g. while updating structure)
#  - Hemera not built
#  - Cleaning is requested while Hemera is running
ERROR_ENVIRONMENT=104

# Invalid configuration, or path definition.
ERROR_CONFIG_VARIOUS=105
ERROR_CONFIG_PATH=106

# Binary or data configured file not found.
ERROR_CHECK_BIN=107
ERROR_CHECK_CONFIG=108

# Bad/unsupported mode.
ERROR_MODE=109

# External tool fault (like wget).
ERROR_EXTERNAL_TOOL=110

# Error while processing input.
ERROR_INPUT_PROCESS=111

# General core module error.
ERROR_CORE_MODULE=112

# Speech Recognition core module, error while analyzing result.
ERROR_SR_ANALYZE=113

# Speech Recognition core module, error while preparing speech file.
ERROR_SR_PREPARE=114

# Speech core module, error while preparing speech file.
ERROR_SPEECH=115

## Core module constants.
# Each input file name begins with a sub string giving the type of input:
#  mode_: mode to activate (it is important to NOT take care of mode update asap it is requested, all previous input must be managed priorly)
#  recordedSpeech_: recorded speech (-> usually needs speech recognition)
#  recognitionResult_: speech recognition result (-> according to mode, must be printed or speech)
#  speech_: test to speech result (-> according to mode, speech recognition can be needed)
SUPPORTED_TYPE="mode recordedSpeech recognitionResult speech"
