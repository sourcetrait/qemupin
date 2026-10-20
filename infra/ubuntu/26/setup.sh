#!/usr/bin/env bash
set -euo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
mapfile -t packages < "$here/packages.apt.list"
sudo apt-get update
sudo apt-get install -y "${packages[@]}"
