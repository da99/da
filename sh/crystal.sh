#!/usr/bin/env sh
# You can use this script in case
#   "da bin compile" fails to compile "da" itself.
#
set -u -e

export SHARDS_INSTALL_PATH="$PWD/.shards/.install"
export CRYSTAL_PATH="/progs/crystal/current/share/crystal/src:$PWD/.shards/.install"

set -x
case "$@" in
  "bin compile")
    crystal build bin/__.cr -o bin/da
    ;;
  *)
    $@
    ;;
esac

