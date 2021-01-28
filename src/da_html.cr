
require "da_html_escape"
require "da_uri"
require "da"
require "./da_html/Head"
require "./da_html/Attribute"
require "./da_html/Base"

module DA
  def strip_each_line(s : String)
    s.strip.lines.map { |x| x.strip }.join('\n')
  end # def
end # === module DA

module DA_HTML
  A_REL_COMMON = {"nofollow", "noopener", "noreferrer"}
  extend self

  def known_tag?(tag_name : Symbol)
    { :html, :link, :meta, :base, :style, :title,
      :body, :address, :article, :aside, :footer, :header,
      :h1, :h2, :h3, :h4, :h5, :h6,
      :hgroup, :nav, :section, :blockquote,
      :dd, :dir, :div, :dl, :dt, :figcaption, :figure,
      :hr, :li, :main, :ol, :p, :pre, :ul, :a, :abbr,
      :b, :bdi, :bdo, :br, :cite, :code, :data,
      :dfn, :em, :i, :kbd, :mark, :q, :rb, :rp,
      :rt, :rtc, :ruby, :s, :samp,
      :small, :span, :strong, :sub, :sup, :time, :tt,
      :u, :var, :wbr,
      :noscript, :script,
      :del, :ins, :caption,
      :col, :colgroup, :table, :tbody, :td,
      :tfoot, :th, :thead, :tr, :button,
      :datalist, :fieldset, :form, :input,
      :label, :legend, :meter, :optgroup, :option,
      :output, :progress, :select, :textarea, :details,
      :dialog, :menu, :menuitem, :summary }.includes? tag_name
  end # def

  def void?(tag_name : Symbol)
    {:area, :base, :br, :col, :command, :embed,
     :hr, :img, :input, :keygen, :link, :meta,
     :param, :source, :track, :wbr}.includes? tag_name
  end # === def

  def prettify(str : String)
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

  module Class_Base
    def to_html
      page = new
      with page yield
      page.io.to_s
    end # === def

    def to_html(io)
      page = new
      with page yield
      io << page.io
    end # === def
  end # === module Class_Base

  struct Page
    include Base
    include Head
  end # === struct Page

  def to_html(io)
    page = Page.new
    with page yield
    io << page.io
  end # === def

  def to_html
    page = Page.new
    with page yield
    page.io.to_s
  end # === def

end # === module DA_HTML


