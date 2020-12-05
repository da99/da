
import { assert, describe, it, DA_HTML, new_window, to_html } from "./helper.mjs";

describe("DA_HTML.new_tag", function() {

  it("adds an element to the fragment", function() {
    let h = new DA_HTML(new_window());

    h.new_tag("strong", "hello");
    assert.equal(to_html(h), "<strong>hello</strong>");
  });

  it("adds an id", function () {
    let h = new DA_HTML(new_window());

    h.new_tag("p", "#main");
    assert.equal(to_html(h), `<p id="main"></p>`);
  });

  it("adds id and class attributes", function () {
    let h = new DA_HTML(new_window());

    h.new_tag("div", "#main.warning");
    assert.equal(to_html(h), `<div id="main" class="warning"></div>`);
  });

  it("adds an id, class attributes and a text node", function () {
    let h = new DA_HTML(new_window());

    h.new_tag("div", "#main.mellow", "hello world");
    assert.equal(to_html(h), `<div id="main" class="mellow">hello world</div>`);
  });

});
