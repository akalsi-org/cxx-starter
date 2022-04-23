#!/bin/sh

mod="$1"

root="$(git rev-parse --show-toplevel)"
name="$(basename "$root")"

mkdir -p "include/$name/$mod" "src/$name/$mod" "test/$name/$mod"

cat <<EOF >> "CMakeLists.txt"

# -- $mod
define_lib(${mod} "")
EOF
