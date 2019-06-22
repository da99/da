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


# binutils - provides 'ar' binary
sudo xbps-install -S \
  htop  \
  xz tree git gcc crystal dpkg archiver dbus \
  ripgrep fzf zsh \
  bspwm \
  xorg \
  wget curl rsync \
  binutils  \
  git neovim \
  dunst bmon \
  void-repo-nonfree \
  ConsoleKit2   || :


current="/progs/crystal"
current_version=""

if test -e "$current" ; then
  current_version="$(cat "$current/share/crystal/src/VERSION")"
  if test -z "$current_version"; then
    echo "!!! Could not get current version." >&2
    exit 2
  fi
fi

latest_version="$(wget -qO- "https://api.github.com/repos/crystal-lang/crystal/releases/latest" | grep -Po '"tag_name": "\K.*?(?=")')"

if test -z "$latest_version" ; then
  echo "!!! Could not get latest version." >&2
  exit 2
fi

if test "$current_version" = "$latest_version" ; then
  echo "=== Already have the latest version: $current_version == $latest_version"
  crystal --version
else
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

  relative_file_path="$(
  wget -qO- "https://github.com/crystal-lang/crystal/releases/latest" \
    | grep -P "releases/download.+linux-x86_64.+" \
    | tr -s ' ' \
    | cut -d' ' -f3 \
    | sort --version-sort \
    | tail -n1 \
    | cut -d'"' -f2
    )"

  if test -z "$relative_file_path" ; then
    echo "!!! Could not find latest url for Crystal." >&2
    exit 2
  fi


  file_url="$relative_file_path"
  if  ! test "$file_url" = *"://"* ; then
    file_url="https://github.com$relative_file_path"
  fi

  file_name="$(basename "$file_url")"
  file_basename="$(basename "$file_name" -linux-x86_64.tar.gz)"
  echo "=== File to get: $file_url"
  echo "=== Basename:    $file_basename"
  echo "=== File name:   $file_name"

  cd /tmp
  if ! test -e "$file_name" ; then
    wget "$file_url"
  fi
  if ! test -d "$file_basename" ; then
    tar -zxf "$file_name"
  fi
  rm -rf /progs/crystal
  mv "$file_basename" /progs/crystal
fi # if current_version == latest_version
# ================================================================



# ================================================================
# Install these after Xorg is running.
# streamlink - provides NHK streams
# alsa-plugins-pulseaudio \ # Provides Master volume control.
# xarchiver lets you browse archive files.
if pgrep xinit ; then
  sudo xbps-install -S \
    bluez \
    nemo \
    mpv smplayer lemonbar sxhkd feh xdo \
    rofi   lynx  git-lfs \
    audacity   qbittorrent \
    streamlink \
    alsa-utils \
    alsa-plugins-pulseaudio \
    gst-plugins-good1 \
    paper-gtk-theme paper-icon-theme \
    faenza-icon-theme faience-icon-theme \
    dfu-programmer \
    lxappearance \
    xtitle wmctrl \
    xarchiver \
    redis \
    xdg-utils || :
fi

# ============================================
# Compile bin/da
# ============================================
cd /apps/da
if ! test -e bin/da ; then
  crystal env
  crystal build --warnings all bin/__.cr -o bin/da
fi