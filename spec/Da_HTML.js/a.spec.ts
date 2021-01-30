
import { describe, it, assert, DA_HTML, JSDOM } from "./helper";


describe("DA_HTML#a", function () {
  it("allows string based id attributes", function () {
    let h = new DA_HTML((new JSDOM()).window);
    h.partial(function () {
      h.a("#alert.red", {href: "/"}, "click here");
    });
    let select_a = h.fragment().querySelector("a");
    let actual = (select_a) ? select_a.getAttribute("id") : null;
    assert.equal(actual, "alert");
  }); // it

  it("allows string based class attributes", function () {
    let h = new DA_HTML((new JSDOM()).window);
    h.partial(function () {
      h.a("#alert.red.scare", {href: "/"}, "click here");
    });
    let select_a = h.fragment().querySelector("a");
    let actual = (select_a) ? select_a.getAttribute("class") : null;
    assert.equal(actual, "red scare");
  }); // it

  it("accepts text nodes as strings", function () {
    let h = new DA_HTML((new JSDOM()).window);
    h.partial(function () {
      h.a("#alert.red.scare", {href: "/"}, "click here");
    });
    let select_a = h.fragment().querySelector("a");
    let actual = (select_a) ? select_a.innerHTML : null ;
    assert.equal(actual, "click here");
  }); // it
}); // describe
