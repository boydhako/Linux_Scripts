#!/bin/bash -xv
wd="$(dirname $0)"
cn="$(echo $1 | tr '[:upper:]' '[:lower:]')"
day="$(date +%d%b%Y)"

function prep() {
    if [ -z "$cn" ]; then
        echo "Usage: $0 <Fully Qualified Domain Name>"
        exit 1
    else
        if [[ "$cn" != *.* ]]; then
            echo "Error: The Common Name (CN) must be a Fully Qualified Domain Name (FQDN)."
            exit 1
        fi
    fi  
}

function gen_certs() {
    prep
    scn="$(echo $cn | awk -F. '{print $1}')"
    destdir="$wd/certs/$scn"
    keyfile="$destdir/$scn-$day-ssl.key"
    csrfile="$destdir/$scn-$day-ssl.csr"
    mkdir -p "$destdir"
    openssl genrsa -out "$keyfile" 4096
    openssl req -new -key "$keyfile" -out "$csrfile" -subj "/CN=$cn"
}

gen_certs