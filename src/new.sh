#!/usr/bin/env bash
#
#
set -u -e -o pipefail


case "$@" in
  '--help'|help|'-h')
    echo "$DA_SCRIPT_NAME $MAIN_CMD .zsh|.rb|.bash|tmp/run FILE_NAME"
    ;;

  ".zsh "*|".rb "*|".bash "*|"tmp/run "*)
    file_type="$1"
    new_file="$2"

    if test -e "$new_file" ; then
      echo "=== Already exists: $new_file" >&2
      exit 0
    fi

    case "$file_type" in
      ".zsh")
        cp -i "${DA_DIR}/templates/script.zsh" "$new_file"
        ;;
      ".bash")
        cp -i "${DA_DIR}/templates/script.bash" "$new_file"
        ;;
      "tmp/run")
        cp -i "${DA_DIR}/templates/tmp.run.zsh" "$new_file"
        ;;
      ".rb")
        cp -i "${DA_DIR}/templates/script.rb" "$new_file"
        ;;
    esac
    chmod +x "$new_file"
    echo "=== Created: $new_file" >&2
    ;;
  *)
    echo "!!! Unknown file types: $*" >&2
    exit 2
    ;;
esac
