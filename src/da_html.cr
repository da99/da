
require "da_html_escape"
require "./da_html/io_html"

module DA_HTML

  PATTERN_ATTR_ID = /[a-z0-9\_]+/
  PATTERN_ATTR_CLASS = /[a-z0-9\_\-]+/

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


{% if env("IS_DEV_BUILD") %}
  macro inspect!(*args)
    puts \{{*args}}
  end
{% end %}

