#!/usr/bin/env bash
#
#
set -u -e -o pipefail


case "$*" in
  "-h"|"--help"|"help")
    echo "$0 -h|--help|help -- Show this message."
    echo
    ;;
  *)
    echo "!!! Unknown command: $*" >&2
    exit 1
    ;;
esac
