
module DA_HTML


  def html5_prepend
    <<-HTML5
      <!doctype html>
      <html lang="en">
    HTML5
  end

  def cleanup(s : String)
    s
      .sub(/<html>/, html5_prepend)
      .gsub(/\<=([\ a-zA-Z0-9\.\_]+)\>/) { |x, y| "<var>#{y[1]}</var>" }
      .gsub(/\<include\ +"?([^"\>]+)"?\>/) { |x, y| File.read(y[1]) }
      .gsub(/\<template\ +"?([^"\>]+)"?\>/) { |x, y| %[<template>#{File.read y[1]}</template>] }
  end # === def

  def to_document(raw : String)
    doc    = Deque(Node).new
    html   = DA.until_done(raw) { |x| DA_HTML.cleanup(x) }
    parser = Myhtml::Parser.new(html)

    doc.push DA_HTML.to_tag(parser.root!)

    doc
  end # === def

  def body(doc : Document)
    body = DA_HTML.find_tag_name(doc, "html > body")
    case body
    when Tag
      return body
    else
      raise Exception.new("Tag not found: body")
    end
  end # === def

end # === module DA_HTML
