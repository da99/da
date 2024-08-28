
Why Services and not a programming language?
---------------------------


Ideas to remember, in this order:

  1. the majority of software for the Majority of Humans requires
  customization and settings/options: in other words, configuration
  rather than creating an app. Science and Nintendo-style
  video games require more "power", (ie a programming language).

  2. most of the action in WWW\_Apps is:
  describing things you are doing to the
  stacks... and things you are doing to the 
  values on the stack.

  3. universal problem solving: break up the problems
  into re-usable components by complexing the problem
  and comparing it to similar and different problems.

  4. DSLs/POLs, even if they are a subset of a prog. lang.,
  are stil their own culture/env./prog. lang. Just like
  with anything else, people do not want to learn something
  new unless they see LOTS of other people/companies using it,
  or if it is being talked about a lot (eg XML, Java, etc.).

  5. It doesn't matter if you can play well with others,
  because no one wants to play with you. Hence, the lack of
  good "virtual machine"-based architecture and sandboxing in
  browsers.  Hence, the lack of demand for programming languages
  written using nothing but JSON.

  6. The most important and the most easily mis-understood
  and overlooked: 

    > It's not about solving problems.
    > It's about finding "better" requirements.

    Once the requirements change, you have to re-evaluate
    the design/architecture immediately.

  7. It's hard finding better requirements because of
  familiarity and complexity (quantity and quantity).
  Lazyiness and limited resources help you guide you to
  fulfilling the requirements w/efficiency.

  8. Programmers already have a common runtime:
  HTML, CSS, Javascript, and their preferred server-side
  language. They do not want something easier. They
  want something familiar. Also, "write once, run anywhere"
  is not something programmers want because they want to use
  their own preferred language ...above all else... to generate
  HTMl/CSS/JS. That leaves app-to-app messaging (ie JSON over AJAX).

  9. Most apps/apps are:

    > input -> JSON/AJAX -> Server -> markup

    App/app makers do not neet programming capilities
    outside of Nintendo-like gaming... because they will do
    that in their favorite language on the server, then
    send the final output to the user in the browser.
    The "programming" happens on the server, and the client is
    just a "dumb" GUI to collect and display input/output.

    This is the closest people want to "write once/run everywhere"
    because of their need to stick to their preferred language
    and the limited needs of the consumer and producer (business).

    Most industrial designers also do not want to run their own
    business, but merely constant "experiment" with creating.
    In other words, occasional invention, no innovation, and
    constant experimenting. There is not much of a need, beyond
    my own, of a better Smalltalk/Factor/Xananud system...
    outside of Nintendo-like gaming.

  10. If WWW\_App is going to be a programming language,
  might as well go all the way: make it an abstraction over
  everything (ie HTML/CSS/JS and all server-side langs,
  including Ruby and Lua). A runtime will be created for
  each language.

I originally wanted this to be an abstraction layer over
HTML, JS, CSS. However, during the development of "www\_app",
I realized I could do that w/ just Ruby. In other words,
I would not need a sophisticated runtime in the browser.
Most of the work would be on the server (to generate the HTML, CSS)
and the JS would mainly consist of calling functions in the browser
from my own api/libs.

The need for www\_app was pushed forward, also, because
most people do not need a common way to exchange code in programming
languages. Instead, their needs are configuration,
rather than a programming language or DSL/POL.
This is more higher level than HyperCard:

  > Configure rather than create.

Also, I realized www\_app can become it's own programming
language with the power to replace PHP. It sounds crazy, but
no more crazy than the popularity of garbage like PHP and Wordpress.
It would only require an extra 2 weeks, but this is still too much
time that I can not afford because I am going broke.
