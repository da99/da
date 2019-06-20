#!/usr/bin/env zsh
#
#
set -u -e -o pipefail
local +x THE_ARGS="$@"

local current="/progs/crystal"
local current_version=""

if [[ -e "$current" ]]; then
  current_version="$(cat "$current/share/crystal/src/VERSION")"
  if [[ -z "$current_version" ]]; then
    echo "!!! Could not get current version." >&2
    exit 2
  fi
fi

local latest_version="$(wget -qO- "https://api.github.com/repos/crystal-lang/crystal/releases/latest" | grep -Po '"tag_name": "\K.*?(?=")')"

if [[ -z "$latest_version" ]]; then
  echo "!!! Could not get latest version." >&2
  exit 2
fi

if [[ "$current_version" == "$latest_version" ]]; then
  echo "=== Already have the latest version: $current_version == $latest_version"
  crystal --version
  exit 0
fi


# ==============================================================================
set -x
# ==============================================================================
#
# === Install packages needed by crystal:
sudo xbps-install -S \
     crystal \
     libgcc-devel    \
     libevent-devel  \
     libevent-devel  \
     gc              \
     gc-devel        \
     lzo-devel       \
     libmcrypt-devel \
     libgcrypt-devel \
     libressl-devel || :

local relative_file_path="$(
wget -qO- "https://github.com/crystal-lang/crystal/releases/latest" \
  | grep -P "releases/download.+linux-x86_64.+" \
  | tr -s ' ' \
  | cut -d' ' -f3 \
  | sort --version-sort \
  | tail -n1 \
  | cut -d'"' -f2
  )"

if [[ -z "$relative_file_path" ]]; then
  echo "!!! Could not find latest url for Crystal." >&2
  exit 2
fi


local file_url="$relative_file_path"
if [[ "$file_url" != *"://"* ]]; then
  file_url="https://github.com$relative_file_path"
fi

local file_name="$(basename "$file_url")"
local file_basename="$(basename "$file_name" -linux-x86_64.tar.gz)"
echo "=== File to get: $file_url"
echo "=== Basename:    $file_basename"
echo "=== File name:   $file_name"

cd /tmp
if [[ ! -e "$file_name" ]]; then
  wget "$file_url"
fi
if [[ ! -d "$file_basename" ]]; then
  tar -zxf "$file_name"
fi
rm -rf /progs/crystal
mv "$file_basename" /progs/crystal


