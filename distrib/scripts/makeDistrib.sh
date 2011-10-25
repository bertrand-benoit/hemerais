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
# Description: make Hemera distribution.
#
# Note: this script is dedicated to project admins.
# Usage: see usage function.


#########################
## CONFIGURATION
# general
currentDir=$( dirname "$( which "$0" )" )
installDir=$( dirname "$currentDir" )"/../../Hemera"
svnRep="https://hemerais.svn.sourceforge.net/svnroot/hemerais/branches"

# Ensures hemera main project is available in the same root directory.
[ ! -d "$installDir" ] && echo -e "Unable to find hemera main project ($installDir)" && exit 1

# Defines priorly log file to avoid erasing while cleaning potential previous launch.
export h_logFile="/tmp/"$( date +'%s' )"-makeDistrib.log"

source "$installDir/scripts/setEnvironment.sh"

# Informs about log file now that functions are available.
writeMessage "LogFile: $h_logFile"

#########################
## FUNCTIONS
function usage() {
  echo -e "usage: $0 -v <version> -o <destination dir>"
  echo -e "  version\tthe version name, relative to branches folder on SVN repository"
  echo -e "  dir\t\tthe destination directory where to checkout, and create distribution"

  exit $ERROR_USAGE
}

# usage: coProject <name> <subPath> <destName>
function coProject() {
  local _name="$1" _subPath="$2" _destName="$3"

  writeMessage "Checking out $_name project v$version from SVN repository ... " 0
  ! svn -q export "$svnUrl/$_subPath" "$destDir/$_destName" >/dev/null 2>&1 && echo "failed" && exit $ERROR_ENVIRONMENT
  echo "ok"
}

#########################
## Command line management

# Defines verbose to 0 if not already defined.
verbose=${verbose:-0}
while getopts "v:o:" opt
do
 case "$opt" in
        v)      version="$OPTARG";;
        o)      destDir="$OPTARG";;
        h|[?])  usage ;; 
 esac
done

[ -z "$version" ] && usage
[ -z "$destDir" ] && usage

[ ! -d "$destDir" ] && errorMessage "Destination directory $destDir not found." $ERROR_BAD_CLI

svnUrl="$svnRep/$version"
writeMessage "Looking for version $version on SVN repository ... " 0
! svn list "$svnUrl" >/dev/null 2>&1 && echo "failed" && exit $ERROR_ENVIRONMENT
echo "ok"

#########################
## INSTRUCTIONS
coProject "Hemera" "hemera" "Hemera"
coProject "Hemera Tests" "tests" "HemeraTests"
coProject "Hemera Samples" "samples" "HemeraSamples"

# Removes some meta data.
writeMessage "Removing some metadata ... " 0
! find "$destDir" -regextype posix-extended -iregex ".*[.]classpath|.*[.]project" -exec rm -Rf {} \; && echo "failed" && exit $ERROR_ENVIRONMENT
echo "ok"

# Creates distrib.
cd "$destDir"
writeMessage "Creating distribution ... " 0
echo -n "Hemera and Tests ... "
! tar czf "Hemera-v$version.tgz" Hemera HemeraTests  && echo "failed" && exit $ERROR_ENVIRONMENT
echo -n "Hemera samples ... "
! tar cjf "Hemera-samples-v$version.tbz" HemeraSamples && echo "failed" && exit $ERROR_ENVIRONMENT
echo "ok"

writeMessage "Distribution available in $destDir"
