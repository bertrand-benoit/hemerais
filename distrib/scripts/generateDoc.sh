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
# Version: 2.0
# Description: generates static Hemera documentation from local mediaWiki, in which online documentation has been imported.

#########################
## CONFIGURATION
HEMERA_ONLINE_DOC="https://gitlab.com/bertrand-benoit/hemerais/wikis"
HEMERA_BOOK_NAME="HemeraBook"
hemeraDocRootDir="${HEMERA_DOC_DIR:-/tmp/hemeraDoc}"

#########################
## Functions
# usage: usage
function usage() {
  echo -e "usage: $0 [-e||-c] [-o <output>]"
  echo -e "-e\t\texport HemeraBook pages, HemeraBook files and HemeraBook categories information (result file must be manually imported)"
  echo -e "-c\t\tcreate offline version of HemeraBook pages (using the last generated output directory if not specified)"
  echo -e "<output>\tspecify output directory to use (useful to perform incremental export; or to create offline version of already exported version)"
  exit 1
}

# usage: defineNewOutputDir
function defineNewOutputDir() {
  outDir="$hemeraDocRootDir/$( date +'%s' )"
  echo -e "Output directory defined to $outDir"
}

#########################
## Command line management
export=0
create=0
archive=1
while getopts "eco:" opt
do
 case "$opt" in
        e)      export=1;;
        c)      create=1;;
        o)      outDir="$OPTARG";;
        h|[?])  usage;;
 esac
done

# Ensures at least one action has been requested.
[ $export -eq 0 ] && [ $create -eq 0 ] && echo -e "You must at least 'export' or 'create'." >&2 && usage

# Ensures output directory exists if specified.
[ ! -z "$outDir" ] && [ ! -d "$outDir" ] && echo -e "Specify output directory '$outDir' does not exist." >&2 && usage

# Defines output directory if needed.
if [ -z "$outDir" ]; then
  # Checks if export has been requested.
  if [ $export -eq 1 ]; then
    # It is the case, so a new output directory must be created.
    defineNewOutputDir
  else
    # Right there, there is no export, but there is offline documentation creation.
    # Looks for last export.
    if [ ! -d "$hemeraDocRootDir" ]; then
      defineNewOutputDir
    else
      outDir=$( ls -1t "$hemeraDocRootDir" |head -n 1 )
      if [ ! -z "$outDir" ]; then
        outDir="$hemeraDocRootDir/$outDir" && echo -e "Using existing output directory '$outDir'."
      else
        defineNewOutputDir
      fi
    fi
  fi
fi

[ -z "$outDir" ] && echo -e "Output directory must be defined." >&2 && usage

docDir="$outDir/$HEMERA_BOOK_NAME"
tmpDir="$outDir/tmp"
allPagesHtml="$tmpDir/allPages.html"
allFilePagesHtml="$tmpDir/allFilePages.html"
allCatPagesHtml="$tmpDir/allCategoryPages.html"
allPagesExporter="$tmpDir/export.xml"
mkdir -p "$tmpDir"
mkdir -p $( dirname "$docDir" )
cd "$outDir"

generationDate=$( LANG=C TZ=UTC date +'%H:%M, %d %B %Y %Z' )
archiveDate=$( LANG=C date +'%Y-%m-%d' )

#########################
## INSTRUCTIONS

# Manages export, if requested.
if [ $export -eq 1 ]; then
  ## TODO: Export only pages of English version of HemeraBook (should use title=Category:HemeraBook/en)
  # Right now, export all pages (templates are NOT included, use: title=Special:AllPages).
  echo -ne "Defining list of pages to export ... "
  [ ! -f "$allPagesHtml" ] && wget -q "$HEMERA_ONLINE_DOC?title=Special:AllPages" -O "$allPagesHtml"
  allPagesList=$( grep "Appendix" "$allPagesHtml" |sed -e 's/<a[^>]*>\([^<]*\)<\/a>/\1\n/g;' |sed -e 's/^.*>\([^>]*\)$/\1/' |grep -v "All pages" |grep -v "^$" )
  pageCount=$( echo "$allPagesList" |wc -l )
  echo -ne "$pageCount pages found ... "

  [ ! -f "$allFilePagesHtml" ] && wget -q "$HEMERA_ONLINE_DOC?title=Special:ListFiles" -O "$allFilePagesHtml"
  allFilePagesList=$( grep "title=.File:" "$allFilePagesHtml" |sed -e 's/<a[^>]*>\([^<]*\)<\/a>/\1\n/g;' |sed -e 's/^.*>\([^>]*\)$/\1/' |grep -v "(file" |grep -v "^$" |sed -e 's/^/File:/' )
  pageCount=$( echo "$allFilePagesList" |wc -l )
  echo -ne "$pageCount Media description found ... "

  [ ! -f "$allCatPagesHtml" ] && wget -q "$HEMERA_ONLINE_DOC?title=Special:Categories" -O "$allCatPagesHtml"
  allCatPagesList=$( grep "title=.Category:" "$allCatPagesHtml" |sed -e 's/<a[^>]*>\([^<]*\)<\/a>/\1\n/g;' |sed -e 's/^.*>\([^>]*\)$/\1/' |grep -v "&#32;" |grep -v "^$" |sed -e 's/^/Category:/' )
  pageCount=$( echo "$allCatPagesList" |wc -l )
  echo -e "$pageCount Category description found"

  # TODO: removed quick&dirty template addition asap a clean solution is implemented.
  completePageList=$( echo -e "Template:HemeraInternalDiagram\n$allPagesList\n$allFilePagesList\n$allCatPagesList" )

  echo -ne "Exporting pages ... "
  ! wget -q "$HEMERA_ONLINE_DOC?title=Special:Export&action=submit" --post-data="pages=$completePageList" -O "$allPagesExporter" && echo "failed."
  echo "done"

  echo "Online documentation exported to $allPagesExporter"
fi

## Right there, admin should import pages locally -> http://localhost/wiki/index.php/Special:Import?xmlimport=/home/Downloads/hemerais-20110605143729.xml&action=submit  !! Need to be logged

# Manages offline documentation generation, if requested.
if [ $create -eq 1 ]; then
  ## Dumps HTML from mediawiki.
  /usr/bin/php /var/www/html/wiki/extensions/DumpHTML/dumpHTML.php -d "$docDir" -k modern --image-snapshot --force-copy --no-shared-desc

  # Removes useless files.
  echo "Removing useless files"
  rm -Rf "$docDir/dumpHTML.version" "$docDir/raw" "$docDir/skins/offline" "$docDir/skins/vector" "$docDir/skins/monobook"

  # Updates the main.css file.
  echo "Updating stylesheet"
cat >> "$docDir/skins/modern/main.css" << End-of-Message
#p-navigation { display: none; }
#p-search { display: none; }
#p-tb { display: none; }
#p-personal { display: none; }
#p-cactions { display: none; }
#footer { display: none; }
#mw_content { margin: 0 1em 0 1em; }
#mw-imagepage-edit-external { display: none; }
#HemeraBook { color: cyan; }
End-of-Message

  echo "Adding footer to all HTML pages"
  for htmlPageRaw in $( find "$docDir/index.html" "$docDir/articles" -type f -iname "*.html" |sed -e 's/[ ]/€/g;' ); do
    htmlPage=$( echo "$htmlPageRaw" |sed -e 's/€/ /g;' )
    name=$( basename "$htmlPage" )
    echo -ne " ... $name"

    # Removes useless "include" of raw styles.
    sed -i 's/^.*\/raw\/.*$//g;' "$htmlPage"

    # Fixed some broken images links.
    sed -i 's/href="\/wiki\/images/href="..\/..\/images/g;s/src="\/wiki\/images/src="..\/..\/images/g;' "$htmlPage"

    # Removes useless Edit links.
    sed -i 's/(<a[^>]*>Edit this file[^<]*<\/a>[^<]*<a[^>]*>contribs<\/a>)//' "$htmlPage"

    # Removes useless broken links to 'Talk' and 'Contribs' link.
    sed -i 's/(<a[^>]*>Talk<\/a>[^<]*<a[^>]*>contribs<\/a>)//' "$htmlPage"

    # Replaces useless ling to Root user, by projettwk.
    sed -i 's/<a[^>]*>Root<\/a>/projettwk/' "$htmlPage"

    # Adds "Hemera Book" in titles (as link to index page).
    if [ "$name" == "index.html" ]; then
      sed -i 's/<h1 id="firstHeading">/<h1 id="firstHeading">Hemera Book - /' "$htmlPage"
    else
      sed -i 's/<h1 id="firstHeading">/<h1 id="firstHeading"><a id="HemeraBook" href="..\/..\/index.html">Hemera Book<\/a> - /' "$htmlPage"
    fi

    # Removes final line.
    sed -i 's/^.*<\/body><\/html>$//;' "$htmlPage"

  # Appends footer.
cat >> "$htmlPage" << End-of-Message
<div style="text-align:center;">
End-of-Message

  # Adds "go to contents" but on the index.html page itself ...
  if [ "$name" != "index.html" ]; then
cat >> "$htmlPage" << End-of-Message
<h3><a href="../../index.html">Go to Contents page</a></h3>
End-of-Message
  else
cat >> "$htmlPage" << End-of-Message
<br />
End-of-Message
  fi

cat >> "$htmlPage" << End-of-Message
<a href="http://www.mediawiki.org">Powered by MediaWiki</a>, its <a href="http://www.mediawiki.org/wiki/Extension:DumpHTML">DumpHTML extension</a> has been used to generate this offline version of Hemera Book at $generationDate<br />
See updated <a href="https://gitlab.com/bertrand-benoit/hemerais/wikis">online documentation</a>
</div><br />
</body></html>
End-of-Message

  done
  echo "... done"

  echo "Offline documentation generated to exported to $docDir"

  if [ $archive -eq 1 ]; then
    echo -ne "Creating Offline documentation tarball ... "
    cd "$outDir"
    archiveName="$archiveDate-$HEMERA_BOOK_NAME.tgz"
    ! tar czf "$archiveName" "$HEMERA_BOOK_NAME" && echo "failed" && exit 1
    echo "done -> $outDir/$archiveName"
  fi
fi
