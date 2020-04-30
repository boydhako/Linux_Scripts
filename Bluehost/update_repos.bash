#!/usr/bin/bash

for git_dir in $(find $HOME -type d -name ".git" 2>/dev/null); do
	base_dir="$(dirname $git_dir)"
	printf "=== %s ===\n" "$base_dir"
	cd $base_dir
	git pull origin master
done
