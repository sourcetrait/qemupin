#!/usr/bin/env bash
set -euo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
root="$(cd "$here/../../.." && pwd)"
pin="${1:-now}"
src="$root/qemu/$pin"
target="$root/.target/ubuntu/26/$pin"
links="${QEMUPIN_MAX_LINKS:-2}"

if [ ! -x "$src/configure" ]; then
    echo "qemupin: no QEMU source at $src; git submodule update --init qemu/$pin" >&2
    exit 1
fi
mapfile -t args < "$here/configure.args.list"
mkdir -p "$target/build"
cd "$target/build"
"$src/configure" --prefix="$target/install" "${args[@]}" -Dbackend_max_links="$links"
make -j"$(nproc)"
make install
