
ENV["IS_TEST"] = "yes"

require "../src/da"
require "da_spec"

# the da binary needs to be up-to-date for certain specs,
#   like "da is dev"
DA::Crystal.bin_compile

extend DA_SPEC

if !ARGV.empty?
  DA_SPEC.pattern /#{ARGV.join ' '}/
  DA.orange! "=== {{Pattern}}: #{DA_SPEC.pattern.inspect}"
end

def reset_file_system
  `rm -rf   /tmp/specs_deploy`
  `mkdir -p /tmp/specs_deploy/var/service`
  `mkdir -p /tmp/specs_deploy/etc/sv`
  Dir.cd("/tmp/specs_deploy") {
    yield
  }
end # === def reset_file_system


require "./DA"
require "./Colorize"
require "./Release"
require "./App"
require "./Git"
require "./Process"
require "./is_dev"
require "./File_System"
require "./file_sections"
require "./sql_sections"
require "./Runit"
require "./Runit.install"
require "./Runit.link"
require "./human_time"

