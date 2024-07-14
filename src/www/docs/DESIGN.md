
Current Design:
=================

MOPs - Message Oriented Pipelines - If you do not like this (or find
    it confusing) then just read about: 
Alan Kay's Real OOP, Erlang Process/Message/OTP, and biological systems.
MOPs is focused on experiments, recovering from those failed experiments,
     and flexibility. I should be able to create a Ruby Rack, Elixir Plug,
     or GUI-interaction system with just a few concepts.

![Message Oriented Pipelines](./docs/MOPs.png?raw=true)

For the specs...
=================
Someone beat me to this: [https://twitter.com/d0rc/status/685544307533545472](https://twitter.com/d0rc/status/685544307533545472)
    ![Example in erlang](./docs/CYJSUDfWcAU9dVQ.png?raw=true)


Extremes:
=========

* Pipelines: server-side (data processing) + client-side (GUIs)
* Visualize GUI + prepare GUI elements
  * Associate functions to elements, run those functions
* State between functions
* Foms - before/after/on submit
* Mouse & keyboard events
* HTML -> JS (function)
* Toggles: bool -> function
* Logic as a value
  * Markup -> Logic Preview -> Templates
* Standardization of messages:
  * AJAX request/response -> message -> processed data structure
  * message -> processed data structure (inspiration Mustache)
  * processed data structure -> markup/view

1 - Previous designs:
==================
```javascript
    computer('push', 'dom-change', my_func);
    computer('push', '!dom-change', my_func);
    computer('push', 'dom-change?', my_func);
    computer('run', {dom_change: true});

    data-do="is_factor   my_func"
    data-do="is_factor?  my_func"
    data-do="my_func!    arg1 arg2"
    data-if="is_factor   my_func"
    data-key="is_factor  my_func"
```

The previous designs were prone to creating matching DSLs on messages.
Anytime you have to introduce mini-languages/DSLs and clever tricks, you are limiting
flexibility and creating future dead-ends. It adds more things to learn and more complexity
to the implementation of `da_standard`.


2 - Previous design:
==============
Basically an array of functions. Each function
handles it's own message matching and allows for simplicity while adding flexibity.

```javascript
    data-do="my_func  arg1  arg2 ..."
    function my_func(msg) {
      if (!msg_match(pattern, msg))
        return;

      computer('push', function my_func_with_closure(msg) {
          if (!msg_match(my_other_pattern, msg))
            return;
      });
    }
    computer('run', {my_key: true});
```

There is no "name of message"/"type of message". This allows the functions
flexibility to handle messages and avoid creating a limiting/inflexible
DSL to associate messages w/functions.



