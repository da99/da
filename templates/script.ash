#!/usr/bin/env ash
#
#
set -u -e -o pipefail


case "$*" in
  "-h"|"--help")
    echo "$0 -h|--help -- This message."
    ;;
  *)
    echo "!!! Unknown command: $*" >&2
    exit 1
    ;;
esac
