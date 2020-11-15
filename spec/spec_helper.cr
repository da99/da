
require "da_spec"

# ENV["IS_DEBUG"] = "YES"
  # DA_Spec.pattern "name of test"
  # DA_Spec.pattern /name of test/

require "../src/da/Dev"
require "../src/da/Git"
require "../src/da/Process"
extend DA_SPEC


# require "microtest"

# module Microtest
#   module DSL
#     macro describe(cls, focus = :nofocus, &block)
#       class {{cls.camelcase.gsub(/[^a-z0-9]/i, "_").id}}Test < Microtest::Test
#         {{block.body}}
#       end
#     end
#   end
#   module TestClassDSL
#     macro test(name = "anonymous", focus = :nofocus, &block)
#       {%
#        testname = name.gsub(/[^a-z0-9]/i, "_").id
#       focus_str = focus == :focus ? "f" : ""
#       %}

#       def __test{{focus_str.id}}__{{testname}}
#         {% if block %}
#           {{block.body}}
#         {% else %}
#           skip "not implemented"
#         {% end %}
#       end
#     end
#   end
# end # Microtest

class SPEC

  DIR = Dir.current

  def self.dir
    "/tmp/da_spec"
  end

  def self.da_bin
    File.join DIR, "bin/da"
  end # def

  def self.tmp_dir
    tmp = File.join dir, Time.utc.to_unix.to_s
    `mkdir -p #{tmp}`
    Dir.cd(tmp) {
      yield
    }
    `rm -rf #{tmp}`
  end # def

end # === class

# include Microtest::DSL
# Microtest.run!

