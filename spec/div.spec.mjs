
import { describe, it, assert, DA_HTML, new_window, to_html } from "./helper.mjs";

describe("DA_HTML.div", function() {

  it("adds a div element to the fragment", function() {
    let h = new DA_HTML(new_window());

    h.div("hello");
    assert.equal(to_html(h), "<div>hello</div>");
  });

  it("adds an id", function () {
    let h = new DA_HTML(new_window());

    h.div("#main");
    assert.equal(to_html(h), `<div id="main"></div>`);
  });

  it("adds id and class attributes", function () {
    let h = new DA_HTML(new_window());

    h.div("#main.warning");
    assert.equal(to_html(h), `<div id="main" class="warning"></div>`);
  });

  it("adds an id, class attributes and a text node", function () {
    let h = new DA_HTML(new_window());

    h.div("#main.mellow", "hello world");
    assert.equal(to_html(h), `<div id="main" class="mellow">hello world</div>`);
  });

});
