
require "da_html_escape"

module DA_HTML

  SEGMENT_ATTR_ID    = /([a-z0-9\_\-]{1,15})/
  SEGMENT_ATTR_CLASS = /[a-z0-9\ \_\-]{1,50}/
  SEGMENT_ATTR_HREF  = /[a-z0-9\ \_\-\/\.]{1,50}/

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

  macro file_read!(dir, raw)
    File.read(
      File.expand_path(
        File.join({{dir}}, {{raw}}.gsub(/\.+/, ".").gsub(/[^a-z0-9\/\_\-\.]+/, "_"))
      )
    )
  end # === macro file_read!

end # === module DA_HTML

require "./da_html/io_html"
require "./da_html/exception"
require "./da_html/template"
require "./da_html/doc"
require "./da_html/io_html"
require "./da_html/format"
require "./da_html/parser"
require "./da_html/printer"


{% if env("IS_DEV") %}
  macro inspect!(*args)
    begin
      puts(
        \{{args}}.map { |x|
          x.inspect
        }.join(", ")
      )
    end
  end
{% end %}

