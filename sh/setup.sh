#!/usr/bin/env sh
#
#
set -u -e -x

for x in /apps /progs ; do
  if ! test -e "$x" ; then
    echo "!!! Setup $x first" >&2
    exit 1
  fi
done

  ## ==============================================================================
  #set -x
  ## ==============================================================================
  ##
  ## === Install packages needed by crystal:
  #sudo xbps-install -S \
  #     crystal \
  #     libgcc-devel    \
  #     libevent-devel  \
  #     libevent-devel  \
  #     gc              \
  #     gc-devel        \
  #     lzo-devel       \
  #     libmcrypt-devel \
  #     libgcrypt-devel \
  #     libressl-devel || :

  #relative_file_path="$(
  #wget -qO- "https://github.com/crystal-lang/crystal/releases/latest" \
  #  | grep -P "releases/download.+linux-x86_64.+" \
  #  | tr -s ' ' \
  #  | cut -d' ' -f3 \
  #  | sort --version-sort \
  #  | tail -n1 \
  #  | cut -d'"' -f2
  #  )"

  #if test -z "$relative_file_path" ; then
  #  echo "!!! Could not find latest url for Crystal." >&2
  #  exit 2
  #fi


  #file_url="$relative_file_path"
  #if  ! test "$file_url" = *"://"* ; then
  #  file_url="https://github.com$relative_file_path"
  #fi

  #file_name="$(basename "$file_url")"
  #file_basename="$(basename "$file_name" -linux-x86_64.tar.gz)"
  #echo "=== File to get: $file_url"
  #echo "=== Basename:    $file_basename"
  #echo "=== File name:   $file_name"

  #cd /tmp
  #if ! test -e "$file_name" ; then
  #  wget "$file_url"
  #fi
  #if ! test -d "$file_basename" ; then
  #  tar -zxf "$file_name"
  #fi
  #rm -rf /progs/crystal
  #mv "$file_basename" /progs/crystal
# ================================================================



# ============================================
# Compile bin/da
# ============================================
cd /apps/da
crystal env
shards build -- --warnings all --release

echo "====== DONE ====="
