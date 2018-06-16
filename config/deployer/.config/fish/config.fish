
# This is usually set by /etc/profile,
# but FiSH Shell doesn't not handle that file.
# From: https://forum.voidlinux.eu/t/solved-xbps-query-suddenly-requires-root-permission-to-query-a-repo/1665/10
if status --is-login
  umask 022
end


if  status --is-interactive
  abbr --add pi "sudo xbps-install -S"
  abbr --add pq "xbps-query -Rs"
  abbr --add pr "sudo xbps-remove -R"
end # if set -q os_name

set PATH $PATH "$HOME/bin"

