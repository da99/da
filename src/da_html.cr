
# require "da_html_escape"

require "./da_html/page"

module DA_HTML

  # SEGMENT_ATTR_ID    = /([a-z0-9\_\-]{1,15})/
  # SEGMENT_ATTR_CLASS = /[a-z0-9\ \_\-]{1,50}/
  # SEGMENT_ATTR_HREF  = /[a-z0-9\ \_\-\/\.]{1,50}/

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
    page = Page.new
    with page yield
    page.to_html
  end # === def self.to_html

end # === module DA_HTML

# require "./da_html/exception"
# require "./da_html/format"

