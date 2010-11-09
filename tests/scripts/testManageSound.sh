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
# Description: performs sound manager tests.
#
# Usage: see usage function.

#########################
## CONFIGURATION
# general
currentDir=$( dirname "$( which "$0" )" )
installDir=$( dirname "$currentDir" )
scripstDir="$installDir/scripts"
category="IOProcessorTests"
source "$installDir/scripts/setEnvironment.sh"

speechScript="$installDir/thirdParty/speech/scripts/speech.sh"
manageSoundScript="$scripstDir/manageSound.sh"

speechSoundFile="/tmp/ia.wav"
speechSoundPIDFile="/tmp/ia.pid"

#########################
## INSTRUCTIONS
rm -f "$speechSoundFile" "$speechSoundPIDFile"
writeMessage "Generate speech sound file"
"$installDir/thirdParty/speech/scripts/speech.sh" -d "Intelligence Artificielle" -o "$speechSoundFile"

# Launches sound play.
"$manageSoundScript" -p "$speechSoundPIDFile" -f "$speechSoundFile" &
sleep 2

# Pauses the sound.
"$manageSoundScript" -p "$speechSoundPIDFile" -P
sleep 2

# Continues the sound.
"$manageSoundScript" -p "$speechSoundPIDFile" -C
sleep 2

# Stops the sound.
"$manageSoundScript" -p "$speechSoundPIDFile" -S
