# compile-proto.sh

source scripts/utils.sh

NAME="$(basename "$CXX_MONO_ROOT")"

_proto_compile() {
    mkdir -p "src/$NAME/protos" "include/$NAME/protos"
    capnp compile \
        -I "$(dirname "$(which capnp)")/../../include" \
        -I capn-protos \
        --src-prefix=capn-protos "-oc++:src/$NAME/protos" \
        "capn-protos/$1.capnp" || return 1
    mv "src/$NAME/protos/$1.capnp.h" "include/$NAME/protos/$1.capnp.h" || return 1
    sed "s/^#include \"$1.capnp.h\"$/#include \"$NAME\/protos\/$1.capnp.h\"/" \
        "include/$NAME/protos/$1.capnp.h" >"include/$NAME/protos/$1.capnp.h.tmp" || return 1
    mv "include/$NAME/protos/$1.capnp.h.tmp" "include/$NAME/protos/$1.capnp.h" || return 1
    mv "src/$NAME/protos/$1.capnp.c++" "src/$NAME/protos/$1.capnp.cc" || return 1
    sed "s/^#include \"$1.capnp.h\"$/#include \"$NAME\/protos\/$1.capnp.h\"/" \
        "src/$NAME/protos/$1.capnp.cc" >"src/$NAME/protos/$1.capnp.cc.tmp" || return 1
    mv "src/$NAME/protos/$1.capnp.cc.tmp" "src/$NAME/protos/$1.capnp.cc" || return 1
}

compile_proto() {
    mkdir -p "include/$NAME/protos" "src/$NAME/protos"
    for item in $(ls -1 capn-protos/*.capnp); do
        _proto_compile "$(basename "$item" | cut -d'.' -f1)" || return 1
    done
}
