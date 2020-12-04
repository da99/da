
import { DA_HTML, new_window, to_html } from "./helper.js";

describe("DA_HTML.div", function() {

  it("adds a div element to the fragment", function() {
    let h = new DA_HTML(new_window());

    h.div("hello");
    expect(to_html(h)).toBe("<div>hello</div>");
  });

  it("adds an id", function () {
    let h = new DA_HTML(new_window());

    h.div("#main");
    expect(to_html(h)).toBe(`<div id="main"></div>`);
  });

  it("adds id and class attributes", function () {
    let h = new DA_HTML(new_window());

    h.div("#main.warning");
    expect(to_html(h)).toBe(`<div id="main" class="warning"></div>`);
  });

  it("adds an id, class attributes and a text node", function () {
    let h = new DA_HTML(new_window());

    h.div("#main.mellow", "hello world");
    expect(to_html(h)).toBe(`<div id="main" class="mellow">hello world</div>`);
  });

});
