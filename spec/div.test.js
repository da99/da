
const DA_HTML = require("../src/main.js");
const { new_window, to_html } = require("./SpecHelper.js");

describe("DA_HTML.div", function() {

  // beforeEach(function() {
  //   player = new Player();
  //   song = new Song();
  // });

  it("adds a div element to the fragment", function() {
    let h = new DA_HTML(new_window());

    h.div("hello");
    expect(to_html(h)).toBe("<div>hello</div>");
  });

});
