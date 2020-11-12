

require "microtest"

module Microtest
  module DSL
    macro describe(cls, focus = :nofocus, &block)
      class {{cls.camelcase.gsub(/[^a-z0-9]/i, "_").id}}Test < Microtest::Test
        {{block.body}}
      end
    end
  end
  module TestClassDSL
    macro test(name = "anonymous", focus = :nofocus, &block)
      {%
       testname = name.gsub(/[^a-z0-9]/i, "_").id
      focus_str = focus == :focus ? "f" : ""
      %}

      def __test{{focus_str.id}}__{{testname}}
        {% if block %}
          {{block.body}}
        {% else %}
          skip "not implemented"
        {% end %}
      end
    end
  end
end # Microtest

class Spec_Git
  DIR = Dir.current
  def self.dir
    "/tmp/da_git_spec"
  end
  def self.da_bin
    File.join DIR, "bin/da"
  end # def
end # === class
include Microtest::DSL
Microtest.run!
