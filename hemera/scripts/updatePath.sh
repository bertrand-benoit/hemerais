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
# Description: updates PATH environment variable for better Hemera accessibility.
# This script must NOT be directly called.
# installDir variable must be defined.

# Ensures installDir variable is defined.
[ -z "$installDir" ] && exit 0

# Adds each script sub-directory to PATH.
additionalPath="$installDir/misc"
for scriptsDirRaw in $( find "$installDir" -type d -name "scripts" |sed -e 's/[ \t]/£/g;' ); do
  scriptsDir=$( echo "$scriptsDirRaw" |sed -e 's/£/ /g;' )
  additionalPath="$additionalPath:$scriptsDir"
done

export PATH=$additionalPath:$PATH
