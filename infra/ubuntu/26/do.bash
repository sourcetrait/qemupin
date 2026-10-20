#!/usr/bin/env bash
set -euo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
src="${QEMUPIN_SRC:-/src}"
links="${QEMUPIN_MAX_LINKS:-2}"
if [ "$#" -gt 0 ]; then pins=("$@"); else pins=(now next); fi

build() {
    local pin="$1"
    local qsrc="$src/qemu/$pin"
    local target="$src/.target/ubuntu/26/$pin"
    local want have
    want="$(tr -d '[:space:]' < "$src/PIN.$pin.txt")"
    if [ ! -x "$qsrc/configure" ]; then
        echo "qemupin: no QEMU source at $qsrc; git submodule update --init qemu/$pin" >&2
        return 1
    fi
    have="$(tr -d '[:space:]' < "$qsrc/VERSION")"
    if [ "$have" != "$want" ]; then
        echo "qemupin: qemu/$pin is $have where PIN.$pin.txt pins $want" >&2
        return 1
    fi
    local args
    mapfile -t args < "$here/configure.args.list"
    mkdir -p "$target/build"
    cd "$target/build"
    "$qsrc/configure" --prefix="$target/install" "${args[@]}" -Dbackend_max_links="$links"
    make -j"$(nproc)"
    make install
    echo "qemupin: QEMU $have ($pin) installed in $target/install"
}

built=" "
for pin in "${pins[@]}"; do
    version="$(tr -d '[:space:]' < "$src/PIN.$pin.txt")"
    if [[ "$built" == *" $version "* ]]; then
        echo "qemupin: $pin pins $version, built in this run already; skipped"
        continue
    fi
    build "$pin"
    built="$built$version "
done
