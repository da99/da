#!/usr/bin/env sh
#

set -u -e
exec 2>&1

dir=/deploy/apps/da
bin="$dir/bin/da"

cd "$dir"
echo "=== Starting $bin"
exec chpst -u stager -U stager "$bin" deploy watch
