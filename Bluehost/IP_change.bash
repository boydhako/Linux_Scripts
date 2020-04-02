#!/usr/bin/bash -xv
domain="$1"
to="$2"
logdir="$HOME/logs"
log="$logdir/$(basename -s .bash $0).log"
date="$(date +"%F")"

function PREP {
	if [ -z "$domain" ]; then
		printf "You need to specify a domain.\n"
		exit 1
	else
		crntip="$(dig $domain a | awk '$4 == "A" {printf $NF}')"
		if [ -z "$crntip" ]; then
			printf "Could not find %s via DNS lookup.\n" "$domain"
			exit 1
		fi
	fi
	if [ -z "$to" ]; then
		printf "You need to specify to send the email to.\n"
		exit 1
	fi
	for dir in $logdir; do
		if [ ! -d "$dir" ]; then
			mkdir -p $dir
		fi
	done
	for file in $log; do
		if [ ! -f "$file" ]; then
			touch "$file"
		fi
	done
}

function GETLASTIP {
	lastip="$(tail -n 1 $log | awk -F: '{printf $NF}')"
}

function GETCURRENTIP {
	crntip="$(dig +nocomment $domain A | awk -v domain="$domain." '$1 == domain {printf $NF}')"
}

function LOGIP {
	printf "%s:%s\n" "$date" "$crntip" >> $log
}

function CHECKIP {
	PREP
	GETLASTIP
	#GETCURRENTIP
	if [ -z "$lastip" -o "$lastip" != "$crntip" ]; then
	#if [ -z "$lastip" -o "$lastip" == "$crntip" ]; then
		LOGIP
		printf "The IP for %s has changed to %s. You might want to check your config for PIA in Tunnelblick.\n\n" "$domain" "$crntip" | gpg2 --passphrase-file $HOME/.gnupg/pass.txt -ea -r $to --batch | mailx -s "$domain's IP Address has changed." $to
	fi
}
CHECKIP
