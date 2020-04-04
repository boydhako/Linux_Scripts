#!/usr/bin/bash
date="$(date)"
wwwdir="$1"
db="$2"

function PREP {
	if [ -z "$wwwdir" ]; then
		printf "Please specify the directory to check.\n"
		exit 1
	fi
	if [ -z "$db" ]; then
		db="$HOME/GIT/Linux_Scripts/Bluehost/$(basename $0 | awk -F\. '{printf $1}').db"
	fi
	printf "Cheking %s ...\nDatabase:%s\n" "$wwwdir" "$db"
	if [ ! -f "$db" ]; then
		sqlite3 $db "CREATE TABLE FILEINFO(checksum TEXT NOT NULL, file TEXT PRIMARY KEY NOT NULL, date_added TEXT, date_modified TEXT);"
		sqlite3 $db "CREATE TABLE BADINSERT(checksum TEXT NOT NULL, file TEXT NOT NULL, date_found TEXT, note TEXT);"
	fi
}

function ADDNEWFILE {
	for file in $(find $wwwdir -type f \( ! -path "*/wp-content/bps-backup/*" \)); do
		chksum="$(shasum -a 512 $file | awk '{printf $1}')"
		if [ "$(sqlite3 $db "SELECT checksum FROM FILEINFO WHERE file = \"$file\";" | wc -l)" -lt "1" ]; then
			sqlite3 $db "INSERT INTO FILEINFO (checksum,file,date_added) VALUES(\"$chksum\",\"$file\",\"$date\");" 2>/dev/null
			addstat="$?"
			if [ "$addstat" == "19" ]; then
				sqlite3 $db "INSERT INTO BADINSERT (checksum,file,date_found,note) VALUES(\"$chksum\",\"$file\",\"$date\",\"Checksum is not unique.\");"
			elif [ "$addstat" != "0" ]; then
				exit 1
			fi
		fi
	done
}
function CHKBADINS {
	for badsum in $(sqlite3 $db "SELECT checksum FROM BADINSERT;"); do
		for loggedfile in $(sqlite3 $db "SELECT FILEINFO.file FROM FILEINFO CROSS JOIN BADINSERT ON FILEINFO.checksum = BADINSERT.checksum WHERE BADINSERT.checksum = \"$badsum\";" | sort | uniq); do
			printf "LOGGEDFILE:%s\n" "$loggedfile"
			for badfile in $(sqlite3 $db "SELECT BADINSERT.file FROM FILEINFO CROSS JOIN BADINSERT ON FILEINFO.checksum = BADINSERT.checksum WHERE BADINSERT.checksum = \"$badsum\";" | sort | uniq); do
				printf "\tMATCHING_CHECKSUM:%s\n" "$badfile"
			done
		done
	done
}

function FILEINTCHK {
	PREP
	ADDNEWFILE
	CHKBADINS
}
FILEINTCHK
