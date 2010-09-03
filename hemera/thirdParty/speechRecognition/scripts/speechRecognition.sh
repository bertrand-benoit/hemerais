#!/bin/bash
#
# Author: Bertrand BENOIT <bertrand.benoit@bsquare.no-ip.org>
# Version: 1.0
# Description: uses sphinx3 and LIMU data files for speech recognition.
#
# Usage: see usage function.

#########################
## CONFIGURATION
# general
currentDir=$( dirname "$( which "$0" )" )
installDir=$( dirname "$( dirname "$( dirname "$currentDir" )" )" )
source "$installDir/scripts/setEnvironment.sh"
category="speechRecognition"

# Binary configuration.
speechDecoder="sphinx3_decode"
checkBin "$speechDecoder" || exit 126

# data configuration
lexicalModel="lium/words_dict.utf8"
fillersModel="lium/fillers_dict.utf8"
languageModel="lium/3g/trigram_LM.DMP.utf8"

acousticModelName="F0"

acousticModel="lium/architecture/$acousticModelName.5500.mdef"
acousticMeans="lium/parameters/$acousticModelName/means"
acousticVariances="lium/parameters/$acousticModelName/variances"
acousticMixtureWeights="lium/parameters/$acousticModelName/mixture_weights"
acousticTransitionMatrices="lium/parameters/$acousticModelName/transition_matrices"

export LANG=fr_FR.iso88591
export LC_ALL=fr_FR.iso88591
"$speechDecoder" \
    -mdef "$currentDir/../data/models/acoustic/$acousticModel"  \
    -mean "$currentDir/../data/models/acoustic/$acousticMeans"  \
    -var "$currentDir/../data/models/acoustic/$acousticVariances" \
    -mixw "$currentDir/../data/models/acoustic/$acousticMixtureWeights"  \
    -tmat "$currentDir/../data/models/acoustic/$acousticTransitionMatrices"  \
    -lm "$currentDir/../data/models/language/$languageModel"  \
    -dict "$currentDir/../data/models/lexical/$lexicalModel"  \
    -fdict "$currentDir/../data/models/lexical/$fillersModel"  \
    -agc max \
    -wlen 0.0256 \
    -lowerf 130 \
    -upperf 6800 \
    -silprob 0.01 \
    -fillprob 0.02 \
    $* >> "$logFile" 2>&1

# to specify ? -input_endian

# Changed parameters:
#    -wlen 0.0256    -> default: 0.025625
#     -lowerf 130    -> default: 133.33334
#     -upperf 6800   -> default: 6855.4976
#     -silprob 0.01  -> default: 0.1
#     -fillprob 0.02 -> default: 0.1

# Default parameters:
#     -varnorm no \
#     -cmn current \
#     -feat 1s_c_d_dd \
#     -alpha 0.97 \
#     -samprate 16000 \
#     -frate 100 \
#     -nfft 512 \
#     -nfilt 40 \
#     -ncep 13 \
#     -lw 9.5 \
