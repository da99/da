
import { describe, it, assert, DA_HTML, new_dom, to_html } from "./helper.mjs";

describe("DA_HTML#title", function() {
  it("updates the title", function () {
    const dom = new_dom();
    let h = new DA_HTML(dom.window);
    h.title("new title");
    assert.equal(dom.window.document.getElementsByTagName('title')[0].innerHTML, "new title");
  }); // it
}); // describe

describe("DA_HTML#link", function() {
  it("creates a LINK element in HEAD", function () {
    const dom = new_dom();
    let h = new DA_HTML(dom.window);
    h.link({href: "print.css", rel: "stylesheet", media: "print"});
    assert.equal(dom.window.document.getElementsByTagName('link')[0].outerHTML, `<link href="print.css" rel="stylesheet" media="print">`);
  }); // it
}); // describe

describe("DA_HTML#meta", function() {
  it("creates a META element in HEAD", function () {
    const dom = new_dom();
    let h = new DA_HTML(dom.window);
    h.meta({content: "/style.css", "http-equiv": "default-style"});
    assert.equal(
      dom.window.document.querySelectorAll('meta')[1].outerHTML,
      `<meta content="/style.css" http-equiv="default-style">`
    );
  }); // it

  it("updates meta charset", function() {
    const dom = new_dom();
    let h = new DA_HTML(dom.window);
    h.meta({charset: "utf-16"});
    assert.equal(
      dom.window.document.querySelector('meta').outerHTML,
      `<meta charset="utf-16">`
    );
  });
}); // describe
