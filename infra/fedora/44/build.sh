#!/usr/bin/sh
set -euo pipefail

PREFIX=".target/install"
#configure --prefix="$PREFIX" 
make -j"$(nproc)"
make install
