#!/bin/bash
site="boydhanaleiako.me"
sitemap="https://$site/sitemap.xml"
tmpcurl="$HOME/tmp/tmpcurl.txt"
curl="$HOME/tmp/curl.txt"

function CRAWL {
	for page in $( curl $1 2> /dev/null| sed 's/>/>\n/g' | sed 's/</\n</g' | egrep -e "^http" ); do
		printf "%s\n" $page >> $tmpcurl
		CRAWL $page
	done
}

function AGGREGATE {
	for map in $( curl $sitemap 2> /dev/null| sed 's/>/>\n/g' | sed 's/</\n</g' | egrep -e "^http" ); do
		printf "%s\n" $map >> $tmpcurl
		CRAWL $map
	done
}

function ORGANIZE {
	sort $tmpcurl | uniq > $curl
}

function ARCHIVEORG {
	for url in $(cat $curl); do
		curl https://web.archive.org/save/$url 2> /dev/null
		sleep 30
	done
}

function CLEANUP {
	rm -f $tmpcurl
	rm -f $curl
}

function PREP {
	for file in $tmpcurl; do
		dir="$(dirname $file)"
		if [ ! -d "$dir" ]; then
			mkdir -p $dir
		fi
		if [ ! -f "$file" ]; then
			touch $file
		fi
	done
}

function ARCHIVEIT {
	PREP
	AGGREGATE
	ORGANIZE 
	ARCHIVEORG
	CLEANUP 

}
ARCHIVEIT
