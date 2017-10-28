
require "../../src/da_html/parser"

{% begin %}
  {% files = system("find #{__DIR__} -mindepth 2 -type f -name parser.cr").split("\n").reject { |x| x.strip.empty? } %}
  {% for x in files %}
    require "{{x.gsub(/#{__DIR__}/, ".").id}}"
  {% end %}

  describe "DA_HTML::Parser" do
  {% for x in files %}
    {% klass = x.split("/")[-2].upcase.gsub(/^\d+\./, "").gsub(/\./, "_") %}
    Dir.glob("specs/parser/*/").each do |x|
      test_name  = File.basename(x).gsub(/^\d+|\./, " ").strip
      input_file = "#{x}input.html"
      expected   = File.read("#{x}expected.html")

      it test_name do
        actual = {{klass.id}}.new(input_file).to_html
        should_eq strip(actual), strip(expected)
      end # === it "#{x.gsub(".", " ")}"
    end
  {% end %}
  end # === desc "#{File.basename x}"
{% end %}
