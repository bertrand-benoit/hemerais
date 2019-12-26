#!/bin/bash
#
# Hemera - Intelligent System (https://github.com/bertrand-benoit/hemerais)
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
# Description: checks Hemera tools configuration.

#########################
## CONFIGURATION
currentDir=$( dirname "$( which "$0" )" )
installDir=$( dirname "$currentDir" )
checkConfAndQuit=1
category="check"
source "$currentDir/setEnvironment.sh"

#########################
## INSTRUCTIONS
# Ensures work directory is defined (it can be NOT defined if configuration files have not been created yet).
[ -z "${h_workDir:-}" ] && h_workDir="$H_DEFAULT_WORK_DIR/$( whoami )"
mkdir -p "$h_workDir"

## Checks i18n files.
writeMessage "Checking internationalization files (BEGIN)"
declare -r refI18nFile="$installDir/i18n/hemera-i18n.fr"
declare -r refI18nFilePurified="$h_workDir/checkConfig_$( basename "$refI18nFile" ).purified"
extractI18Nelement "$refI18nFile" "$refI18nFilePurified"
cat "$refI18nFilePurified" |sed -e 's/=.*$//g;' |sort > "$refI18nFilePurified.keys"
for i18nFile in $( find "$installDir/i18n" -maxdepth 1 -type f -regextype posix-extended -regex ".*\/hemera-i18n[.][^~]*" ); do
  i18nFileName=$( basename "$i18nFile" )
  i18nFilePurified="$h_workDir/checkConfig_$i18nFileName.purified"

  # Extracts i18n elements.
  [[ "$i18nFile" != "$refI18nFile" ]] && extractI18Nelement "$i18nFile" "$i18nFilePurified"

  # Checks each definition.
  for i18nElementRaw in $( grep -re "^[ \t]*[^#]" "$i18nFile" |sed -e 's/[ \t]/€/g;' ); do
    i18nElement=$( echo "$i18nElementRaw" |sed -e 's/€/ /g;' )

    # Checks if there is a variable into this definition.
    if [ $( echo "$i18nElement" |grep -cE "[$]" ) -gt 0 ]; then
      # Ensures special characters are escaped.
      if [ $( echo "$i18nElement" |grep -cE "[^\\]['$]" ) -gt 0 ]; then
        warning "($i18nFileName) some characters should be escaped in: $i18nElement"
      fi
    else
      # Ensures there is NO escaped characters.
      if [ $( echo "$i18nElement" |grep -cE "\\\\" ) -gt 0 ]; then
        warning "($i18nFileName) some characters should NOT be escaped in: $i18nElement"
      fi
    fi
  done

  # Checks if it is the reference i18n file in which case there is nothing more to do.
  [[ "$i18nFile" == "$refI18nFile" ]] && continue

  # Ensures there is the same i18n elements of the reference file.
  cat "$i18nFilePurified" |sed -e 's/=.*$//g;' |sort > "$i18nFilePurified.keys"
  diff "$refI18nFilePurified.keys" "$i18nFilePurified.keys" > "$i18nFilePurified.keys.diff"
  missingI18NElements=$( grep -re "^<" "$i18nFilePurified.keys.diff" |sed -e 's/</,/g;' |tr -d '\n' |sed -e 's/^,[ ]//' )
  [ ! -z "$missingI18NElements" ] &&  warning "($i18nFileName) missing following i18n definition: $missingI18NElements"

  unknownI18NElements=$( grep -re "^>" "$i18nFilePurified.keys.diff" |sed -e 's/>/,/g;' |tr -d '\n' |sed -e 's/^,[ ]//' )
  [ ! -z "$unknownI18NElements" ] &&  warning "($i18nFileName) following i18n definition are unknown: $unknownI18NElements"
done
writeMessage "Checking internationalization files (END)"

## Checks environment configuration.
manageJavaHome || exit $ERROR_ENVIRONMENT
manageAntHome || exit $ERROR_ENVIRONMENT

checkAndSetConfig "hemera.run.activation.tomcat" "$CONFIG_TYPE_OPTION"
declare -r tomcatActivation="$h_lastConfig"
if [ "$tomcatActivation" = "localhost" ]; then
  manageTomcatHome || exit $ERROR_ENVIRONMENT
fi

## Ensures minimal configuration has been done before requesting various Hemera components.
# If third-party tools directory, or hemera log, run or tmp directories are not defined,
#  there is no sense to check config -> it will fail for each script because the -X option
#  will not have been managed yet (defining checkConfAndQuit flag), and setEnvironment will fail.
if [ $h_minConfigOK -eq 0 ]; then
  warning "Hemera must be setup and configured for advanced configuration check."
  exit $ERROR_CHECK_CONFIG  
fi

## Requests configuration check to Hemera main script.
"$installDir/scripts/hemera.sh" -X

## Requests configuration check to each daemon and core module.
for scriptRaw in $( find "$h_daemonDir" -maxdepth 1 -type f -perm /u+x ! -name "*~" |sort |sed -e 's/[ \t]/£/g;' ); do
  script=$( echo "$scriptRaw" |sed -e 's/£/ /g;' )
  "$script" -X
done

## Requests configuration check to core module/system scripts.
for scriptRaw in $( find "$h_coreDir" -maxdepth 2 -type f -perm /u+x ! -name "*~" |sort |sed -e 's/[ \t]/£/g;' ); do
  script=$( echo "$scriptRaw" |sed -e 's/£/ /g;' )
  "$script" -X
done

## Requests configuration check to any plugin.
for scriptRaw in $( find "$h_coreDir/command" -maxdepth 1 -type f ! -name "*~" ! -iname "*.txt" |sort |sed -e 's/[ \t]/£/g;' ); do
  script=$( echo "$scriptRaw" |sed -e 's/£/ /g;' )

  # Ensures it is a plugin script (checking there is a checkConfig function).
  [ $( head -n 30 "$script" |grep -wc "checkConfig" ) -lt 1 ] && continue

  # Sources corresponding plugin and calls checkConfig function.
  category="plugin:${script/*\//}"
  source "$script"
  checkConfig
done
