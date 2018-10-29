
da\_html.cr
=========

My personal Crystal shard to create sanitized HTML.

Currently, Crustal 0.26.1, you have to include the
setup a special `def initialize` on the module to
do the final rendering if you use an intermediary module
instead of including `DA_HTML::Base` directly:

```crystal
   module Something
     include DA_HTML::Base
     def my_tag
       tag(:my_tag) { }
     end
   end

   module B
     include Something
   end

   struct C
     include B

     # Not necessary if you include DA_HTML::Base directly
     # or use an include DA_HTML::Base via included macro:
     def initialize
       super
     end
   end

```

Different designs were designed and implemented before settling
on server-side rendering for *all* HTML. (No client-side rendering, such as in React/JSX)
The reason is to decrease typos and other errors via the Crystal compiler.
Using Crystal to render both on the server-side and client-side was also
dismissed because the complexity in combining Crystal and Javascript contexts.

The *easiest* way (i.e. less code, fewest bugs, cognitive load of the developer) is thus:
  * Render all HTML templates and output on the server.
  * Send content via AJAX calls (and if possible HTTP compression) to browser (i.e. client).
  * Browser adds Javascript events, actions, etc.
  * HTML is added to DOM.


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
  struct My_Page

    include DA_HTML::Base

    def my_tag(*args)
      args.each { |x|
        # sanitize args
      }

      tag :my_tag, args do
        result = yield
        text(result) if result.is_a?(String)
      end

    end # def

    def self.to_html
      page = new
      with page yield
      page.io.to_s
    end # def

  end # === class My_Page

  My_Page.to_html {
    my_tag { "some text" }
  }
```

Partials:
=========

```Crystal
  module My_Partial
    def my_tag
      tag(:my_tag) { }
    end
  end

  struct My_Page
    include DA_HTML::Base
    include My_Partial

    def self.to_html
      page = new
      with page yield
      page.io.to_s
    end # def
  end

  My_Page.to_html { |page|
    div { }
    my_tag
  }
```

Security:
=========
Handle this "window.opener API." security vulnerability:

  * https://news.ycombinator.com/item?id=15685324
  * https://www.jitbit.com/alexblog/256-targetblank---the-most-underestimated-vulnerability-ever/
  *  https://developer.mozilla.org/en-US/docs/Web/HTML/Element/a




