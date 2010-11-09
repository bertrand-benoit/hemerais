#!/bin/bash
#
# Author: Bertrand BENOIT <projettwk@users.sourceforge.net>
# Version: 1.0
# Description: creates lexical and language models.

#########################
## CONFIGURATION
currentDir=$( dirname "$( which $0 )" )
binDir="$currentDir/bin"

# Checks if the --copy option has been given.
[ $# -ge 1 ] && [ "$1" = "--copy" ] && copyModel=1 || copyModel=0

# Ensures various tools are installed.
echo -ne "Checking SRILM availability ... "
srilmBinDir=$( ls -1d $binDir/srilm*/bin*/i686* 2>&1 )
[ $? -ne 0 ] && echo -e "unable to find compiled directory corresponding to pattern: $binDir/srilm*/bin*/i686*" && exit 1
echo "found $srilmBinDir"

echo -ne "Checking lia_phon availability ... "
liaPhonDir=$( ls -1d $binDir/lia_phon* 2>&1 )
[ $? -ne 0 ] && echo -e "unable to find directory corresponding to pattern: $binDir/lia_phon*" && exit 1
echo "found $liaPhonDir"

echo -ne "Checking sphinxbase availability ... "
sphinxBaseDir=$( ls -1d $binDir/sphinxbase* 2>&1 )
[ $? -ne 0 ] && echo -e "unable to find directory corresponding to pattern: $binDir/sphinxbase*" && exit 1
echo "found $sphinxBaseDir"

echo -ne "Checking Sphinx3 availability ... "
sphinx3Dir=$( ls -1d $binDir/sphinx3* 2>&1 )
[ $? -ne 0 ] && echo -e "unable to find directory corresponding to pattern: $binDir/sphinx3*" && exit 1
echo "found $sphinx3Dir"

# Updates environment consequently.
echo -ne "Updating enviroment ... "
export LIA_PHON_REP="$liaPhonDir"
export LIA_PHON_LEX="lex80k"
export LD_LIBRARY_PATH="$sphinxBaseDir/src/libsphinxbase/.libs:$LD_LIBRARY_PATH"
echo "done"

# Defines additional variables.
buildDir="build"
mkdir -p "$buildDir"

lmFileTmp="$buildDir/lm.arpa.tmp"
lmFileTmpSorted="$lmFileTmp.sorted"
lmFileTmpSortedDummy="$lmFileTmp.sorted.dummy"
lmFile="data/hemera.DMP.utf8"

lexicalWordList="$buildDir/wordsList.tmp"
lexicalWordPhonesTmp="$buildDir/wordsPhones.tmp"
lexicalWordPhones="$buildDir/wordsPhones.tmp.utf8"
lexicalWordDic="data/hemera_dic.utf8"

#########################
## FUNCTIONS

# usage: manageModelCopyToMainProject <model file> <destination dir>
# Checks if the --copy has been used, inform about it if it is not the case.
function manageModelCopyToMainProject() {
  local _sourceFile="$1" _destinationFile="$2"
  # Manages potential models copy.
  if [ $copyModel -eq 0 ]; then
    # Informs about the option (at the end instead of the beginning otherwise the user may not see the information).
    echo -e "\nYou can use the --copy option for this script to automagically copy successfully created models to hemera main project (which must be in the same root directory), in corresponding sub-directories."
  else
    # Ensures Hemera main project is available.
    hemeraMainDir=$( dirname "$currentDir" )"/hemera"
    [ ! -d "$hemeraMainDir" ] && echo -e "Unable to find hemera main project ($hemeraMainDir)" && return 1

    # Ensures the destination file does not already exist.
    destinationFilePath="$hemeraMainDir/$_destinationFile/"$( basename "$_sourceFile" )
    echo -ne "Manging copy of model $_sourceFile ... "
    [ -f "$destinationFilePath" ] && echo -ne "creating backup of existing model ... " && mv -f "$destinationFilePath" "$destinationFilePath".bak
    echo -ne "copying ... " && cp -f "$_sourceFile" "$destinationFilePath" && echo "done (as $destinationFilePath)" && return 0
    return 1
  fi
}

#########################
## INSTRUCTIONS
# sphinx3_lm_convert needs relative path, so moves to the current directory.
cd "$currentDir"

# Ensures transcript source file is available, and prepares the transcript file for work.
transcriptSource="data/hemeraTranscript.txt"
transcript="build/hemeraTranscript.txt.cleaned"
echo -ne "Preparing source transcript file ($transcript) ... "
[ ! -f "$transcriptSource" ] && echo -e "$transcriptSource not FOUND" && exit 1
! $( cat "$transcriptSource" |grep -v "^#" | grep -v "^[ \t]*$" > "$transcript" ) && echo -e "error" && exit 1
echo "done"

echo -e "\n***** Language model *****"
echo -e "Creating ARPA raw language model file ($lmFileTmp)"
$srilmBinDir/ngram-count -tolower -order 3 -text "$transcript" -lm "$lmFileTmp" || exit 1

echo -e "\nSorting language model file ($lmFileTmpSorted)"
$( cat "$lmFileTmp" | awk -f $srilmBinDir/sort-lm > "$lmFileTmpSorted" ) || exit 1

echo -e "Adding add-dummy-bows to language model file ($lmFileTmpSortedDummy)"
$( cat "$lmFileTmpSorted" | awk -f $srilmBinDir/add-dummy-bows > "$lmFileTmpSortedDummy" ) || exit 1

echo -e "\nConverting to DMP format ($lmFile)"
"$sphinx3Dir/src/programs/sphinx3_lm_convert" -i "$lmFileTmpSortedDummy" -ienc utf8 -o "$lmFile" -oenc utf8 || exit 1

echo -e "\n-> Successfully created language model: $lmFile"
manageModelCopyToMainProject "$lmFile" "thirdParty/speechRecognition/data/models/language"


echo -e "\n***** Linguistic model *****"
# IMPORTANT: lia works in ISO8859-1, not in UTF-8
echo -e "Creating lexical words ($lexicalWordList)"
$( iconv -f utf8 -t ISO8859-1 "$transcript" |"$LIA_PHON_REP/script/lia_nett" > "$lexicalWordList" ) || exit 1

echo -e "Creating phones ($lexicalWordPhonesTmp)"
$( cat "$lexicalWordList" |"$LIA_PHON_REP/script/lia_lex2phon" > "$lexicalWordPhonesTmp" ) || exit 1

echo -e "Converting phones to utf8 ($lexicalWordPhones)"
$( iconv -f ISO8859-1 -t utf8 $lexicalWordPhonesTmp > "$lexicalWordPhones" ) || exit 1

echo -e "Creating words dic for sphinx3 ($lexicalWordDic)"
$( "$currentDir"/convertToSphinx3Format.pl "$lexicalWordPhones" |sort -u > "$lexicalWordDic" ) || exit 1

echo -e "\n-> Successfully created lexical model: $lexicalWordDic"
manageModelCopyToMainProject "$lexicalWordDic" "thirdParty/speechRecognition/data/models/lexical"
