#!/bin/sh
# This script downloads the muster release files for the different architecture/os combinations and calculates the sha256sum
# Paste the output into 'source_hashes' in the flake.nix

version="$1"

for system in "linux-amd64" "linux-arm64" "darwin-amd64" "darwin-arm64"; do
    wget -q https://github.com/giantswarm/muster/releases/download/v${version}/muster-${system} -O download
    hash=$(sha256sum download | cut -f1 -d" " | xxd -r -p | base64)
    echo "            \"$system\" = \"$hash\";"
    rm download
done
