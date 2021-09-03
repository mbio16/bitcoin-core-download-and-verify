#!/bin/bash

APP="bitcoin"
BASE_URL="https://bitcoin.org/bin/"
ARCH="arm-linux-gnueabihf" # Raspberry Pi
ASC_FILE="SHA256SUMS.asc"
CORE_VER="$(curl -sL $BASE_URL | grep -Eo 'bitcoin\-core\-[0-9.]+[0-9]' | sort -V | tail -n 1)"
APP_VER="${CORE_VER/bitcoin-core-/}"
FILE="${APP}-${APP_VER}-${ARCH}.tar.gz"
UNVERIFIED="${FILE}.unverified"
FILE_URL="${BASE_URL}${CORE_VER}/$FILE"
SHA256SUMS="${BASE_URL}${CORE_VER}/${ASC_FILE}"
PGP_KEY="01EA5486DE18A882D4C2684590C8019E36C2E964"

echo "Downloading $SHA256SUMS"
curl -sqO $SHA256SUMS

GNUPGHOME="$(mktemp -d)"
export GNUPGHOME

echo "Importing PGP signing key"
keys=$(gpg --recv-keys --keyserver hkp://keyserver.ubuntu.com "$PGP_KEY")
[ "$?" -ne 0 ] && echo "Unable to import key" && rm -rf "$ASC_FILE" "$GNUPGHOME" && exit 1

echo "Verifying signature"
sig_check=$(gpg --verify "$ASC_FILE")
[ "$?" -ne 0 ] && echo "Signature doesn't match $ASC_FILE" && exit 1

download_file() {
    echo "Downloading $FILE as $UNVERIFIED"
    curl -s $FILE_URL -o $UNVERIFIED

    echo "Checking SHA256 hash of $UNVERIFIED"
    unverified_sum="$(shasum -a 256 $UNVERIFIED)"
    file_sum="${unverified_sum/.unverified/}"
    check_sum=$(grep "$file_sum" "$ASC_FILE")
    if [ "$?" -eq 0 ]; then
        echo "$FILE downloaded and verified"
        mv $UNVERIFIED $FILE
    else
        echo "$FILE failed SHA256 checksum. Renaming to $FILE.BAD"
        mv $UNVERIFIED $FILE.BAD
        exit 1
    fi
}

if [ ! -f "$FILE" ]; then
    download_file
else
    file_sum="$(shasum -a 256 $FILE)"
    check_sum=$(grep "$file_sum" "$ASC_FILE")
    if [ "$?" -ne 0 ]; then
        echo "$FILE corrupted. Downloading a new version"
        download_file
    else
        echo "$FILE is the latest"
    fi
fi

rm -rf "$ASC_FILE" "$GNUPGHOME"

tar -xzf $FILE

rm -rf $FILE
