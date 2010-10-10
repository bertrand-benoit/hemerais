#!/bin/bash
#
# Author: Bertrand BENOIT <projettwk@users.sourceforge.net>
# Version: 1.0
# Description: creates linguistic and language models.

#########################
## CONFIGURATION

currentDir=$( dirname "$( which $0 )" )
binDir="$currentDir/bin"

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

lmConvertBin="/home/bsquare/programmation/projects/hemera/hemeraFiles/fromSource/sphinx3/src/programs/sphinx3_lm_convert"


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
"$lmConvertBin" -i "$lmFileTmpSortedDummy" -ienc utf8 -o "$lmFile" -oenc utf8 || exit 1

echo -e "\n-> Successfully created language model: $lmFile"

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

echo -e "\n-> Successfully created linguistic model: $lexicalWordDic"
