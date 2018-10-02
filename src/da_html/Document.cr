
module DA_HTML
  class Document

    # =============================================================================
    # Class:
    # =============================================================================

    def self.html5_prepend
      <<-HTML5
      <!doctype html>
      <html lang="en">
      HTML5
    end

    def self.close_custom_tags(s : String)
      s
        .sub(/<html>/, html5_prepend)
        .gsub(/\<=([\ a-zA-Z0-9\.\_]+)\>/) { |x, y| "<var>#{y[1]}</var>" }
        .gsub(/\<include\ +"?([^"\>]+)"?\>/) { |x, y| File.read(y[1]) }
        .gsub(/\<template\ +"?([^"\>]+)"?\>/) { |x, y| %[<template>#{File.read y[1]}</template>] }
    end # === def

    # =============================================================================
    # Instance:
    # =============================================================================

    getter origin : String
    getter raw    : String
    getter children = [] of Node

    def initialize(@origin : String)
      @raw   = DA.until_done(@origin) { |x| Document.close_custom_tags(x) }
      parser = Myhtml::Parser.new(@raw)
      children.push DA_HTML.to_tag(parser.root!, index: 0)
    end # === def

    def html
      To_HTML.new(self).to_html
    end # === def

    def javascript
      To_Javascript.new(self).to_javascript
    end

    def crystal
      To_Javascript.new(self).to_crystal
    end

  end # === struct Document
end # === module DA_HTML
