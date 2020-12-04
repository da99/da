
import { DA_HTML, new_window, to_html } from "./helper.js";

describe("DA_HTML.new_tag", function() {

  it("adds an element to the fragment", function() {
    let h = new DA_HTML(new_window());

    h.new_tag("strong", "hello");
    expect(to_html(h)).toBe("<strong>hello</strong>");
  });

  it("adds an id", function () {
    let h = new DA_HTML(new_window());

    h.new_tag("p", "#main");
    expect(to_html(h)).toBe(`<p id="main"></p>`);
  });

  it("adds id and class attributes", function () {
    let h = new DA_HTML(new_window());

    h.new_tag("div", "#main.warning");
    expect(to_html(h)).toBe(`<div id="main" class="warning"></div>`);
  });

  it("adds an id, class attributes and a text node", function () {
    let h = new DA_HTML(new_window());

    h.new_tag("div", "#main.mellow", "hello world");
    expect(to_html(h)).toBe(`<div id="main" class="mellow">hello world</div>`);
  });

});
