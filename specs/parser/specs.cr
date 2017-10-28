
require "../../src/da_html/parser"

{% begin %}
  {% files = system("find #{__DIR__} -mindepth 2 -type f -name parser.cr").split("\n").reject { |x| x.strip.empty? } %}
  {% for x in files %}
    require "{{x.gsub(/#{__DIR__}/, ".").id}}"
  {% end %}
{% end %}
