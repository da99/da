#!/usr/bin/env ruby
# frozen_string_literal: true


CMD = ENV['CMD'] || ENV['DA_CMD']
BOLD = `tput bold`
NORMAL = `tput sgr0`

def replace_cmd(str)
  str.sub('CMD', FORMATED_CMD).strip
end

def replace_options(str)
  str.gsub %r{\[([^\]]+)\]} do |x|
    "\e[33m#{x}\e[0m"
   end
end

def format_cmd(x)
  main, *cmd = x.split(/\s+/)
  return "#{BOLD}#{main}#{NORMAL}" if cmd.empty?

  "#{BOLD}#{main}#{NORMAL}#{cmd.join ' '}"
end

PREFIX_DOC = %r{^\s*(#|//)\s+doc:\s+}
FORMATED_CMD = format_cmd(CMD)

ARGV.each do |file_path|
  intro = `"#{file_path}" help intro line 2>/dev/null`.strip
  puts('-' * 70)
  puts intro unless intro.empty?
  contents = File.read(file_path)
  contents.each_line do |raw_line|
    next unless raw_line.strip[PREFIX_DOC]
    line = raw_line.sub(PREFIX_DOC, '')
    puts replace_cmd(replace_options(line))
  end
end
