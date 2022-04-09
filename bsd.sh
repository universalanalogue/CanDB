#!/usr/local/bin/bash
#version=1.08.01
gsed -i "s/sed/gsed/g" candb.sh
gsed -i "s/awk/gawk/g" candb.sh

gsed -i "s/shuf/gshuf/g" utils.sh


gsed -i "s|#!/bin/bash|#!/usr/local/bin/bash|g" candb.sh




printf "\ec"
echo "Game files have been patched for BSD type systems."
