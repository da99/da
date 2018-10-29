
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

Partials:
=========

```Crystal
  class My_Partial
    include DA_HTML::Base
    def my_tag
      raw! "<my_tag></my_tag>"
    end
  end

  DA_HTML.to_html { |page|
    div { }
    My_Partial.partial(page) {
      my_tag
    }
  }
```

Security:
=========
```crystal
  # Handle this "window.opener API." security vulnerability:
  #  https://news.ycombinator.com/item?id=15685324
  #  https://www.jitbit.com/alexblog/256-targetblank---the-most-underestimated-vulnerability-ever/
  #  https://developer.mozilla.org/en-US/docs/Web/HTML/Element/a
  it "adds rel=\"nofollow noopener noreferrer\" when target attr is used" do
```




