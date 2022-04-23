# setup.sh

CXX_MONO_ROOT="$(git rev-parse --show-toplevel)"
cd "$CXX_MONO_ROOT" || exit 1

source scripts/utils.sh

mkdir -p .local

source scripts/setup-vcpkg.sh

setup_vcpkg || die "failed to setup vcpkg"
dbg "vcpkg setup complete"

source scripts/setup-deps.sh

setup_deps || die "failed to setup dependencies"
dbg "dependencies setup complete"

if [ "$(cat .local/cached_schema)" != "$(ls -1 capn-protos/*.capnp | sort | xargs -n1 cat | sha1sum -)" ]; then
    source scripts/compile-proto.sh
    compile_proto || die "failed to compile proto"
    dbg "proto compilation complete"
    (ls -1 capn-protos/*.capnp | sort | xargs -n1 cat | sha1sum -) >.local/cached_schema
    dbg "caching proto schema hash"
else
    dbg "proto compilation skipped - cached artifacts are up to date"
fi
