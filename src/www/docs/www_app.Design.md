
A
=========================

If :href is a Symbol
  onclick, cancel default event
  and run event named in
  :href Symbol.

Buttons
=========================

```
   button.^(:submit) { 'Save" }
   button.^(:cancel, :red) { 'Cancel" }
   button.^(:blue, :yell) { 'Save" }
```

This behavior is special to buttons:
  All buttons
    when clicked
    run each event from class names
    ignore if event does not exist.

Input
=========================

```
  input(:text, :my_name, 'Robert')
  input(:text, 'Robert')
  input(:pass_phrase)
```

This behaviour is special to inputs:
  when :input is in 
    fieldset with one or more class names:
      the first class name is the default name.
      if class name is :password,
        type is set to :password
        if first arg is Symbol,
          name is set to first arg.
      else
        type is set to :text
      if last arg is String,
        value is set to last arg.
  else
    return super

Attaching Events to Tags and Parents
====================================

```
  div {
    observe :submit
    form.action('...') {
      button.^(:submit)
    }
```

If no parent observes action name:
  then attach to nearest :form tag.
  else attach to tag (in this case, :button)

CSS + JS
========

```
  div {

    on(:click) {

      border '1px solid #fff'

      when_eq :my_var, 'some js' do
        emit :my_box_was_clicked
      end

      if_not_then do
        emit :dont_know_what
      end

    }

  }
```

JS Templates
============

```ruby
  div.*(:mine) {

    observe :record

    span.^(:empty) { 'No records.' }

    div.^(:list).template(:record, records) { |o|

      div.^(:record) do

        border_width '1px'

        on(:delete) {
          background 'some image'
          server :delete
        }

        span.^(:title) { o[:title] }
        a.href(:delete) { 'Delete' }
      end
    }

  }
```
1) Parent and selectors.
2) Passing the message to target + observers.
3) Default message receivers:
   Current tag, -> Parents -> Form





