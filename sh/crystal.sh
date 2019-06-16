#!/usr/bin/env sh
# You can use this script in case
#   "da bin compile" fails to compile "da" itself.
#
set -u -e

set -x
case "$@" in
  "bin compile")
    crystal env
    crystal build bin/__.cr -o bin/da
    ;;
  *)
    $@
    ;;
esac

