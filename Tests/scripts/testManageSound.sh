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
# Description: performs sound manager tests.
#
# Usage: see usage function.

# Ensures everything is stopped in same time of this script.
trap 'writeMessage "Interrupting all tests"; "$scripstDir/hemera.sh" -K; exit 0' INT

#########################
## CONFIGURATION
# general
currentDir=$( dirname "$( which "$0" )" )
installDir=$( dirname "$currentDir" )"/../Hemera"

# Ensures hemera main project is available in the same root directory.
[ ! -d "$installDir" ] && echo -e "Unable to find hemera main project ($installDir)" && exit 1

# completes configuration.
scripstDir="$installDir/scripts"
CATEGORY="TsoundManage"
source "$installDir/scripts/setEnvironment.sh"

speechScript="$h_coreDir/speech/speech.sh"
manageSoundScript="$h_coreDir/system/manageSound.sh"

speechSoundFile="/tmp/ia.wav"
speechSoundPIDFile="/tmp/ia.pid"

#########################
## INSTRUCTIONS
rm -f "$speechSoundFile" "$speechSoundPIDFile"
writeMessage "Generate speech sound file"
"$speechScript" -t "Ceci est un test de gestion du son avec un texte suffisamment long, afin de pouvoir le mettre en pause, le relancer, et enfin le couper définitivement. En final, l'utilisateur n'entendra pas la fin de ce texte." -o "$speechSoundFile"

# Launches sound play.
"$manageSoundScript" -p "$speechSoundPIDFile" -f "$speechSoundFile" &
sleep 4

# Pauses the sound.
"$manageSoundScript" -p "$speechSoundPIDFile" -P
sleep 5

# Continues the sound.
"$manageSoundScript" -p "$speechSoundPIDFile" -C
sleep 2

# Stops the sound.
"$manageSoundScript" -p "$speechSoundPIDFile" -S
