
Features:
======

  * `_.file.html` vs `file.html`
  * `{{MY}}` scoping
  * `locals`
  * `paste` and removing duplicate `script`, `meta`, `link` tags
  * concat/create/link `SCRIPT` tags to `script.js` file.
  * copy files (.css, .js, .png, etc) to output dir

  * files relative to the template file are turn into `locals`:
    ```
      |- my.template.html
      |- style.css   ->  {{style_css}}
      |- script.js   ->  {{script_js}}
    ```

  * `to-global` has *no* `to-local` counterpart.
  * globals & locals must be on the top:
    ```html
      <local name="name" value="value" />
      <local name="name">value</local>
      <div>
        <local name="this_is_ignored">my value</local>
      </div>
    ```


  * templates:
    ```html
      <template data-do="template data_key  replace|top|bottom">
      </template>
    ```

  * pastes (ie partials):
    ```html
      <paste src="my_file.html" />
    ```

  * Appending/Prepending to other elements is allowed IF the element
  is already defined.
  ```html
    <top    to="my_id">This is an error.</top>
    <div id="my_id">
      content goes around here.
    </div>
    <!-- This is ok: -->
    <top    to="my_id">my content</top>
    <bottom to="my_id">my bottom content</bottom>
  ```



How HTML is processed:
==============

* NodeJS is used to take advantage of the popular Handlebars package.

* Uses `he`. Alternative encode/decode of html entities: https://github.com/substack/node-ent

* `cheerio` is used instead of `jsdom\jquery` because it is a lot
easier to use despite its incompatibility w/ jQuery.  [whacko](https://github.com/inikulin/whacko)
was considered, but it was harder to use when it came to
changing non-standard tags (e.g. `template` to `script` tags).

Specs
=====

```bash
  da_standard.jspp test-html  # All specs.
  da_standard.jspp test-html  src/html/specs/my-dir-of-a-spec
```
