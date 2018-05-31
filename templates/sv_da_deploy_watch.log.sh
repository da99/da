#!/bin/sh
#
#

set -u -e
sv_name=da_watch
dir=/var/log

mkdir -p         $dir/$sv_name
exec svlogd -ttt $dir/$sv_name
