# utils.sh

CXX_MONO_ROOT="$(git rev-parse --show-toplevel)"
export CXX_MONO_ROOT

CXX_MONO_LOCAL="$CXX_MONO_ROOT/.local"
export CXX_MONO_LOCAL

add_to_path() {
  local oldpath
  oldpath="$PATH"
  if echo "$oldpath" | grep -q "$1"; then
    return 0
  fi
  export PATH="$1:$oldpath"
}

dbg() {
  >&2 echo "[I] $*"
}

err() {
  >&2 echo "[E] $*"
}

die() {
  err "$*"
  exit 1
}

clean() {
  rm -fr "$CXX_MONO_ROOT/build" "$CXX_MONO_ROOT/install"
  # rm -fr "$CXX_MONO_LOCAL"
}

refresh() {
  clean
  source "$CXX_MONO_ROOT/setup.sh"
}
