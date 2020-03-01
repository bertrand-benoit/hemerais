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
# Description: updates configuration file.

#########################
## CONFIGURATION
currentDir=$( dirname "$( which "$0" )" )
installDir=$( dirname "$currentDir" )
category="configUpdater"
source "$currentDir/setEnvironment.sh"

#########################
## FUNCTIONS
# usage: usage
function usage() {
  echo -e "Usage: $0 [-c <config file>] [-o <new config file>] [-hv]"
  echo -e "<config file>\t\tthe base configuration file (default: $h_configurationFileSample)"
  echo -e "<new config file>\tthe new configuration file (default: $h_configurationFile), a backup of existing file is created"
  echo -e "-v\t\t\tactivate the verbose mode"
  echo -e "-h\t\t\tshow this usage"
  echo -e "\nThis script compares <config file> to current '$h_configurationFile', and creates <new config file>"
  echo -e "Such a way, the <new config file> will contain any new potential configuration elements, and keep your configuration"

  exit $ERROR_USAGE
}

#########################
## Command line management
# Defines verbose to 0 if not already defined.
srcConfFile="$h_configurationFileSample"
dstConfFile="$h_configurationFile"
verbose=${verbose:-0}
while getopts "c:o:vh" opt
do
 case "$opt" in
        c)      srcConfFile="$OPTARG";;
        o)      dstConfFile="$OPTARG";;
        v)      verbose=1;;
        h|[?])  usage;; 
 esac
done

[ ! -f "$srcConfFile" ] && errorMessage "'$srcConfFile' not found." $ERROR_BAD_CLI
[ ! -f "$dstConfFile" ] && errorMessage "'$dstConfFile' not found." $ERROR_BAD_CLI

#########################
## INSTRUCTIONS

# Backups existing destination if any.
backupFile="$dstConfFile.backup."$( date +'%Y-%m-%d-%H.%M.%S' )
writeMessageSL "Creating backup '$backupFile' ... "
! cp "$dstConfFile" "$backupFile" && echo "FAILED"|tee -a "$h_logFile" && exit 1
echo "OK"|tee -a "$h_logFile"

# For each lines of the source config file.
writeMessageSL "Checking change ... "
tmpDstFile="$dstConfFile.new."$( date +'%s' )
rm -f "$tmpDstFile"
keyChangeCount=0
for lineRaw in $( cat "$srcConfFile" |sed -e 's/[ \t]/€/g;s/^$/EmptY/g;' ); do
  line=$( echo "$lineRaw" |sed -e 's/€/ /g;' )

  # Manages empty line.
  [[ "$line" == "EmptY" ]] && echo "" >> "$tmpDstFile" && continue

  # Checks if it is a comment, and appends it to temporary destination file if it is the case.
  [ $( echo "$line" |grep -ce "^[ \t]*#" ) -eq 1 ] && echo "$line" >> "$tmpDstFile" && continue

  # It is a configuration element, extracts the key.
  sourceKey=$( echo "$line" |sed -e 's/^\([^=]*\)=.*$/\1/g;' )

  # Checks if configuration element already exists.
  if [ $( grep -cre "^$sourceKey=" "$dstConfFile" 2>/dev/null ) -ge 1 ]; then    
    # Gets value of destination.
    dstValue=$( grep -re "^$sourceKey=" "$dstConfFile" 2>/dev/null|sed -e 's/^[^=]*=//;' |tail -n 1 )
    echo "$sourceKey=$dstValue" >> "$tmpDstFile"
  else
    echo -ne "new key $sourceKey ... "|tee -a "$h_logFile"
    let keyChangeCount++    
    # Adds the line of the "source file".
    echo "$line" >> "$tmpDstFile"
  fi
done
echo "done"|tee -a "$h_logFile"

# Computes count of changed comments.
commentChangeCount=$( diff "$dstConfFile" "$tmpDstFile" |grep -cre ">[ \t]*#" )

# Exists if there was no change.
[ $keyChangeCount -eq 0 ] && [ $commentChangeCount -eq 0 ] && writeMessage "Nothing to update." && rm -f "$tmpDstFile" && exit 0

# Moves the temporary file to the destination file.
mv -f "$tmpDstFile" "$dstConfFile"
writeMessage "$keyChangeCount keys changed and $commentChangeCount comments changed."
