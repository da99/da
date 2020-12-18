
import { describe, it, assert, DA_HTML, new_dom } from "./helper.mjs";
import { default as partial01 } from "./_partial.01.mjs";

describe("DA_HTML#partial", function () {
  it("renders content from given file", function () {
    let h = new DA_HTML(new_dom());
    h.render(partial01);
    assert.equal(h.serialize(), `<div class="first"><p>empty paragraph</p></div>`);
  }); // it
}); // describe
