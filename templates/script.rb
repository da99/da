#!/usr/bin/env ruby
# frozen_string_literal: true

cmd = ARGV.join(' ')
prog = __FILE__.split('/').last

case cmd
when '-h', '--help', 'help'
  puts "#{prog} -h|--help|help  --  Show this message."
else
  warn "!!! Unknown command: #{cmd}"
  exit 1
end # case
