#!/usr/bin/env bash
#
#
set -u -e -o pipefail


case "$*" in
  # doc: CMD -h|--help|help -- Show this message.
  "-h"|"--help"|"help")
    CMD="$0" da_doc "$0"
    echo
    ;;
  *)
    echo "!!! Unknown command: $*" >&2
    exit 1
    ;;
esac
