
import { describe, it, assert, DA_HTML, JSDOM } from "./helper";
import { default as partial01 } from "./_partial.01";

describe("DA_HTML#partial", function () {
  it("renders content from given file", function () {
    let h = new DA_HTML((new JSDOM()).window);
    partial01(h);
    assert.equal(h.serialize(), `<div class="first"><p>empty paragraph</p></div>`);
  }); // it
}); // describe
