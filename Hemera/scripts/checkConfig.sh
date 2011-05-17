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
# Description: checks Hemera tools configuration.

#########################
## CONFIGURATION
currentDir=$( dirname "$( which "$0" )" )
installDir=$( dirname "$currentDir" )
checkConfAndQuit=1
category="check"
source "$installDir/scripts/setEnvironment.sh"

#########################
## INSTRUCTIONS
## Checks locale files.
writeMessage "Checking locale files (BEGIN)"
refLocaleFile="$installDir/locale/hemera-i18n.fr"
refLocaleFilePurified="$h_workDir/checkConfig_$( basename "$refLocaleFile" ).purified"
extractI18Nelement "$refLocaleFile" "$refLocaleFilePurified"
cat "$refLocaleFilePurified" |sed -e 's/=.*$//g;' > "$refLocaleFilePurified.keys"
for localeFile in $( find "$installDir/locale" -maxdepth 1 -type f -regextype posix-extended -regex ".*\/hemera-i18n[.][^~]*" ); do
  localFileName=$( basename "$localeFile" )
  localFilePurified="$h_workDir/checkConfig_$localFileName.purified"

  # Extracts i18n elements.
  [[ "$localeFile" != "$refLocaleFile" ]] && extractI18Nelement "$localeFile" "$localFilePurified"

  # Checks each definition.
  for i18nElementRaw in $( grep -re "^[ \t]*[^#]" "$localeFile" |sed -e 's/[ \t]/€/g;' ); do
    i18nElement=$( echo "$i18nElementRaw" |sed -e 's/€/ /g;' )

    # Checks if there is a variable into this definition.
    if [ $( echo "$i18nElement" |grep -E "[$]" |wc -l ) -gt 0 ]; then
      # Ensures special characters are escaped.
      if [ $( echo "$i18nElement" |grep -E "[^\\]['$]" |wc -l ) -gt 0 ]; then
        warning "($localFileName) some characters should be escaped in: $i18nElement"
      fi
    else
      # Ensures there is NO escaped characters.
      if [ $( echo "$i18nElement" |grep -E "\\\\" |wc -l ) -gt 0 ]; then
        warning "($localFileName) some characters should NOT be escaped in: $i18nElement"
      fi
    fi
  done

  # Checks if it is the reference locale file in which case there is nothing more to do.
  [[ "$localeFile" == "$refLocaleFile" ]] && continue

  # Ensures there is the same i18n elements of the reference locale file.
  cat "$localFilePurified" |sed -e 's/=.*$//g;' > "$localFilePurified.keys"
  diff "$refLocaleFilePurified.keys" "$localFilePurified.keys" > "$localFilePurified.keys.diff"
  missingI18NElements=$( grep -re "^<" "$localFilePurified.keys.diff" |sed -e 's/</,/g;' |tr -d '\n' |sed -e 's/^,[ ]//' )
  [ ! -z "$missingI18NElements" ] &&  warning "($localFileName) missing following i18n definition: $missingI18NElements"

  unknownI18NElements=$( grep -re "^>" "$localFilePurified.keys.diff" |sed -e 's/>/,/g;' |tr -d '\n' |sed -e 's/^,[ ]//' )
  [ ! -z "$unknownI18NElements" ] &&  warning "($localFileName) following i18n definition are unknown: $unknownI18NElements"
done
writeMessage "Checking locale files (END)"

## Checks environment configuration.
manageJavaHome || exit $ERROR_ENVIRONMENT
manageAntHome || exit $ERROR_ENVIRONMENT

checkAndSetConfig "hemera.run.activation.tomcat" "$CONFIG_TYPE_OPTION"
tomcatActivation="$h_lastConfig"
if [ "$tomcatActivation" = "localhost" ]; then
  manageTomcatHome || exit $ERROR_ENVIRONMENT
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
