
require "spec"
require "../src/da_html"
require "../src/da_html/tags/*"

class Basic_Spec_HTML
  include DA_HTML::DOCTYPE
  include DA_HTML::HTML
  include DA_HTML::HEAD
  include DA_HTML::TITLE
  include DA_HTML::BODY
  include DA_HTML::SPAN
  include DA_HTML::P
  include DA_HTML::DIV
  include DA_HTML::TEMPLATE

  getter :io
  @io : DA_HTML::INPUT_OUTPUT | DA_HTML::TEMPLATE::INPUT_OUTPUT
  def initialize
    @io = DA_HTML::INPUT_OUTPUT.new
  end # === def initalize

  def self.render
    h = new
    with h yield
    h.io.to_html
  end

  def to_html
    @io.to_html
  end # === def to_html
end # === class HTML


macro should_eq(actual, expected)
  {{actual}}.should eq({{expected}})
end # === macro should_eq

macro strip(str)
  {{str}}.strip.gsub("\n", "").gsub(/>\s+</, "><")
end

macro render(&blok)
  Basic_Spec_HTML.render {
    {{blok.body}}
  }
end

require "./00.basics"
require "./01.template"
