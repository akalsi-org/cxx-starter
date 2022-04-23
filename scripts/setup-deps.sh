# setup-deps.sh

source scripts/utils.sh

VCPKG_DEPS="$(cat "$CXX_MONO_ROOT/vcpkg-deps.lst" | grep -v '^#' | tr '\n' ' ')"

setup_deps() {
    echo "Installing dependencies..."
    for dep in $VCPKG_DEPS; do
        echo "  - $dep"
    done
    dbg "  * writing vpkg dep install logs to $CXX_MONO_LOCAL/vpkg-deps.log"
    vcpkg install $(echo "$VCPKG_DEPS" | xargs) > "$CXX_MONO_LOCAL/vpkg-deps.log" || die "failed to install dependencies"
    for item in $(find "$CXX_MONO_VCPKG_DIR" -type f -executable | grep -v '\.sh$' | grep installed); do
        add_to_path "$(dirname "$item")"
    done
}
