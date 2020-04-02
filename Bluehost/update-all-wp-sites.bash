#!/bin/bash
wpphar="/home4/boydhana/scripts/wp-cli.phar"
wpcomp="/home4/boydhana/scripts/wp-completion.bash"

function PREP {
	alias wp="$wpphar"
}
function MAIN {
	PREP
	for cfg in $(find $HOME/www/ -type f -name "wp-config.php"); do
		dir="$(dirname $cfg)"
		printf "===\tUPDATING %s\t===\n\n" "$dir"
		printf "Updating core files in %s.\n" "$dir"
		/home4/boydhana/scripts/wp-cli.phar core update --path="$dir"
		printf "Updating database for %s.\n" "$dir"
		/home4/boydhana/scripts/wp-cli.phar core update-db --path="$dir"
		printf "Updating plugins for %s.\n" "$dir"
		/home4/boydhana/scripts/wp-cli.phar plugin update --all --path="$dir"
		printf "Updating themes for %s.\n" "$dir"
		/home4/boydhana/scripts/wp-cli.phar theme update --all --path="$dir"
		printf "Verifiying file checksums in %s.\n" "$dir"
		/home4/boydhana/scripts/wp-cli.phar core verify-checksums --path="$dir"
		printf "Flushing cache for %s.\n" "$dir"
		/home4/boydhana/scripts/wp-cli.phar cache flush --path="$dir"
		printf "======\n\n\n" "$dir"
	done
}
MAIN
