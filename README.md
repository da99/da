
da\_html.cr
=========

My personal Crystal shard to create sanitized HTML.

Quick Intro:
======

```Crystal
  require "da_html"
  DA_HTML.to_html {
    p {
      strong { "hello" }
    }
  }
```

Custom Tags:
=============

```Crystal
  class My_Page

    include DA_HTML::Base

    def my_tag(*args)
      args.each { |x|
        # sanitize args
      }

      raw! "<my_tag"
      args.each { |x|
        attr! :some_key, x
      }
      raw! '>'

      text? {
        with self yield self
      }

      raw! "</my_tag>"
    end

  end # === class My_Page

  My_Page.to_html {
    my_tag { "some text" }
  }
```



