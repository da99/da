#!/usr/bin/env sh
#
#
set -u -e -o pipefail

log() { echo "--- $*" >&2; }

case "$*" in
  "-h"|"--help")
    echo "$0 -h|--help -- This message."
    ;;

  *)
    echo "!!! Unknown command: $*" >&2
    exit 1
    ;;
esac
