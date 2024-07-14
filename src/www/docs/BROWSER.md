
Message Standardization:
=======================

* `{ ok : true, ... }`
* `{ err: true, err_server|err_user: true, msg: "string", ... }`

Browsers:
========================

```html
  <script src="/bower_components/da_standard/build/browser.js"></script>

  <!-- on load -->
  <script>
    App('send message', {'dom-change': true});
  </script>
```

*NOTE*: The `browser.js` build contains all the require libs: `lodash`, `jquery`, etc.

`da_standard` works by sending messages (ie objects) to a `server` like object: `App`:

```javascript
   App("send message", {"dom-change": true});
   App("send message", {"name": "Bruce Timm"});
```

This `server` like object holds state.
It has nothing to do with a web server. It merely holds state
that needs to be accessed by various functions.
Later, counters and other Redis-like functionality will
be added.

To add functionality, create a function to be executed:

```javascript
  App("create message function", function (msg) {
   if (!msg_match({"dom-change": true}, msg)
       return;
  });
```

Each message function gets run on every message. You can stop
execution of the function with an `if` and `return` on the messages you
do not want to process.  The function, `msg_match`, is provided to
let you compare the messages using an object that "looks like" the message
you want to process.

Suggestion for function design:
===============================

```html
   <p data-do="my_func [my_other_func [with optional args]]"></p>
```

The easiest so far I could find is to think in terms of associations:

  * You are associating a tag (ie `p`) with a function `my_func`.
  * That function is associated with another: `my_other_func`.

This is the usual pattern. However, you are free to design your functions based on
need and intuitiveness (ie case-by-case basis).

data-do is the only pre-installed message function:
============================
It is actually named `process_data_dos` inside
the App object:
[source code](https://github.com/da99/da_standard.jspp/blob/master/src/browser/data-do/_.bottom.js).

You associate DOM elements with the `data-do` attribute:

```html
  <div data-do="my_func with args;  my_other_func with other args; simply_my_func">Test</div>
```

You can associate multiple functions by separating them with `;`. The "arguments" will be
split on whitespace and pass to the function inside the message (ie object). For example:

```javascript
  function my_func(msg) {
    // msg is
    {
      on_dom: true,
      dom_id: dom_id_of_element, // auto-generated and assigned to element if element does not have one.
      args  : ["with", "args"]
    }
  }
```

You can manipulate the message, but the changes won't be passed on to the other functions.
The message is always a copy. If you want to propagate changes to the message, send it as
a new message: `App('send message', my_new_message)`. This is intentionally restrictive to
help create predictable functionality.

Currently, there is no way to stop processing the message like you would in `Ruby Rack` or
in event emitters. The need has not come up.

Simplicity and power come from:

  * creating and sending message: `App('send message', {...})`
  * creating message processing functions: `App('create message function', function ({...}) {...})`
  * HTML that describes behaviour: `<div data-do="show is_hot ; ...`


Specs:
======

  1. Specs run in the browser if `window` and `#THE_STAGE` are defined.

  2. Use [js\_setup upgrade](https://github.com/da99/js_setup) to upgrade bower components.
      *NOTE*: Use version numbers in `package.json`, and `latest` for bower.json.
      The `latest` version only works with `bower`, not `npm`.  However, `js_setup upgrade`
      upgrades both versions. It also notifies you if there are newer versions available.

