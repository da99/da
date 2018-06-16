#!/usr/bin/env sh
#
#
set -u -e

out_file="tmp/out/bin"
if ! test -f "shard.lock" || test "$(stat --format="%Y" shard.yml)" -gt "$(stat --format="%Y" shard.lock)";
then
  crystal deps update
  crystal deps prune
fi

export SHARDS_INSTALL_PATH="$PWD/.shards/.install"
export CRYSTAL_PATH="/usr/lib/crystal:$PWD/.shards/.install"
mkdir -p $(dirname $out_file)
rm -f $out_file
set -x
crystal build bin/__.cr -o $out_file $@
mv $out_file bin/da


