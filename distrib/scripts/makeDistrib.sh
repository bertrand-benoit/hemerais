#!/bin/bash
#
# Hemera - Intelligent System (http://hemerais.bertrand-benoit.net)
# Copyright (C) 2010-2015 Bertrand Benoit <hemerais@bertrand-benoit.net>
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
repoDir=$( dirname "$currentDir" )"/.."
installDir="$repoDir/Hemera"

# Ensures hemera main project is available in the same root directory.
[ ! -d "$installDir" ] && echo -e "Unable to find hemera main project ($installDir)" && exit 1

# Defines priorly log file to avoid erasing while cleaning potential previous launch.
export LOG_FILE="/tmp/"$( date +'%s' )"-makeDistrib.log"

source "$installDir/scripts/setEnvironment.sh"

# Ensures git repository is currently on master branch, to have up-to-date gitattributes information.
cd "$repoDir"
[ $( git branch |grep -c "* master" ) -ne 1 ] && errorMessage "'master' branch of GIT repository must be checkout (ensuring having up to date gitattributes)." $ERROR_ENVIRONMENT

# Informs about log file now that functions are available.
writeMessage "LogFile: $LOG_FILE"

#########################
## FUNCTIONS
function usage() {
  echo -e "usage: $0 -n <name> [-v <version> -o <destination dir> -ST]"
  echo -e "  name\t\tthe name (suffix) of release to create (e.g. 0.1.5)"
  echo -e "  version\tthe GIT ID (e.g. master, HEAD, Hemera-0.1.1); default: master"
  echo -e "  dir\t\tthe destination directory where to checkout, and create distribution; default: /tmp (or directory defined by environment variable HEMERA_DISTRIB_DIR)"
  echo -e "  -S\t\tactivate samples archive creation, in addition to release one"
  echo -e "  -T\t\tactivate tests archive creation, in addition to release one"

  exit $ERROR_USAGE
}

# usage: createArchive <name> <prefix> <archiveFile>
function createArchive() {
  local _name="$1" _prefix="$2" _archiveFile="$3"

  # N.B.: using a symbolic link to have the good root directory name.

  writeMessage "Creating archive '$_prefix' from '$version' ... " 0
  ln -s "$_name" "$_prefix"
  ! tar  --exclude=".project" -czf "$_archiveFile" "$_prefix"/* && echo "failed" && exit 1
  echo "successfully created release file: $_archiveFile"
  rm "$_prefix"
}

#########################
## Command line management

# Defines VERBOSE to 0 if not already defined.
VERBOSE=${VERBOSE:-0}
createSamplesArchive=0
createTestsArchive=0
while getopts "v:o:n:ST" opt
do
 case "$opt" in
        n)      name="$OPTARG";;
        v)      version="$OPTARG";;
        o)      destDir="$OPTARG";;
        S)      createSamplesArchive=1;;
        T)      createTestsArchive=1;;
        h|[?])  usage ;;
 esac
done

[ -z "${name:-}" ] && usage
[ -z "${version:-}" ] && writeMessage "Using default version 'master'" && version="master"
[ -z "${destDir:-}" ] && destDir="${HEMERA_DISTRIB_DIR:-/tmp}" && writeMessage "Using default output directory '$destDir'"

[ ! -d "$destDir" ] && errorMessage "Destination directory '$destDir' not found." $ERROR_BAD_CLI

writeMessage "Looking for version '$version' on GIT repository ... " 0
! git describe $version --always >/dev/null 2>&1 && echo "failed" && exit $ERROR_ENVIRONMENT
writeOK

#########################
## INSTRUCTIONS
releaseName="Hemera-$name"
releaseFile="$destDir/$releaseName".tgz
writeMessage "Creating release '$releaseName' from '$version' ... " 0
! git archive --format=tar --worktree-attributes --prefix="Hemera-$name/" "$version" | gzip >"$releaseFile" && echo "failed" && exit 1
echo "successfully created release file: $releaseFile"

# Creates additional archive according to options.
[ $createSamplesArchive -eq 1 ] && createArchive "Samples" "Hemera-samples-$name" "$destDir/Hemera-samples-$name.tgz"
[ $createTestsArchive -eq 1 ] && createArchive "Tests" "Hemera-tests-$name" "$destDir/Hemera-tests-$name.tgz"
