#!/bin/bash
wwwdir="$1"
wpphar="$HOME/GIT/Linux_Scripts/Bluehost/wp-cli.phar"

function PREP {
	if [ -z "$wwwdir" ]; then
		printf "Please state the www directory to update.\n"
		exit 1
	fi
}
function MAIN {
	PREP
	for cfg in $(find $wwwdir -maxdepth 5 -type f -name "wp-config.php"); do
		dir="$(dirname $cfg)"
		printf "===\tUPDATING %s\t===\n\n" "$dir"
		printf "Updating core files in %s.\n" "$dir"
		$HOME/GIT/Linux_Scripts/Bluehost/wp-cli.phar core update --path="$dir"
		printf "Updating database for %s.\n" "$dir"
		$HOME/GIT/Linux_Scripts/Bluehost/wp-cli.phar core update-db --path="$dir"
		printf "Updating plugins for %s.\n" "$dir"
		$HOME/GIT/Linux_Scripts/Bluehost/wp-cli.phar plugin update --all --path="$dir"
		printf "Updating themes for %s.\n" "$dir"
		$HOME/GIT/Linux_Scripts/Bluehost/wp-cli.phar theme update --all --path="$dir"
		printf "Verifiying file checksums in %s.\n" "$dir"
		$HOME/GIT/Linux_Scripts/Bluehost/wp-cli.phar core verify-checksums --path="$dir"
		printf "Flushing cache for %s.\n" "$dir"
		$HOME/GIT/Linux_Scripts/Bluehost/wp-cli.phar cache flush --path="$dir"
		printf "======\n\n\n" "$dir"
	done
}
MAIN
