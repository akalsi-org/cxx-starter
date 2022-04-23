# setup-vcpkg.sh

source scripts/utils.sh

CXX_MONO_VCPKG_DIR="$CXX_MONO_LOCAL/vcpkg"

setup_vcpkg() {
    if [ ! -d "$CXX_MONO_VCPKG_DIR" ]; then
        mkdir "$CXX_MONO_VCPKG_DIR" || return 1
        dbg "  * writing vcpkg logs to $CXX_MONO_LOCAL/bootstrap-vcpkg.log"
        sh -c "git clone https://github.com/Microsoft/vcpkg.git $CXX_MONO_VCPKG_DIR && \
            $CXX_MONO_VCPKG_DIR/bootstrap-vcpkg.sh > $CXX_MONO_LOCAL/bootstrap-vcpkg.log" || return 1
    fi
    add_to_path "$CXX_MONO_VCPKG_DIR"
}
