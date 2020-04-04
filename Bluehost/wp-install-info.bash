#!/usr/bin/bash
wwwdir="$1"
wpcliphar="$HOME/GIT/Linux_Scripts/Bluehost/wp-cli.phar"

if [ -z "$wwwdir" ]; then
	printf "Please state the Web Directory to check.\n"
	exit 1
fi

for config in $(find $wwwdir -type f -name "wp-config.php"); do
	installdir="$(dirname $config)"
	printf "\n=== %s ===\n" "$config"
	ls -l $config
	lsattr $config
	php -c $HOME/GIT/Linux_Scripts/Bluehost/php.ini -f $wpcliphar config list --path="$installdir" 
done
