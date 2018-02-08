
require "da_html_escape"
require "da_uri"
require "./da_html/DA_Helpers"
require "./da_html/tag/*"
require "./da_html/base"
require "./da_html/exception"

module DA_HTML

  class Default_Page
    include Base
  end # === struct Page

  def self.prettify(str : String)
    indent = 0
    str.gsub( /\>\<([a-z\/])/ ) { |s, x|
      case x[1]
      when "/"
        indent -= 1
        ">\n#{" " * (indent)}</"
      else
        indent += 1
        ">\n#{" " * indent}<#{x[1]}"
      end
    }
  end # === def pretty_html

  def self.to_html
    page = Default_Page.new
    with page yield
    page.to_html
  end # === def self.to_html

end # === module DA_HTML
