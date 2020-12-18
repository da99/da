
import { describe, it, assert, DA_HTML, new_window } from "./helper.mjs";


describe("DA_HTML#a", function () {
  it("allows string based id attributes", function () {
    let h = new DA_HTML(new_window());
    h.fragment(function () {
      h.a("#alert.red", {href: "/"}, "click here");
    });
    let actual = h.fragment().querySelector("a").getAttribute("id");
    assert.equal(actual, "alert");
  }); // it

  it("allows string based class attributes", function () {
    let h = new DA_HTML(new_window());
    h.fragment(function () {
      h.a("#alert.red.scare", {href: "/"}, "click here");
    });
    let actual = h.fragment().querySelector("a").getAttribute("class");
    assert.equal(actual, "red scare");
  }); // it

  it("accepts text nodes as strings", function () {
    let h = new DA_HTML(new_window());
    h.fragment(function () {
      h.a("#alert.red.scare", {href: "/"}, "click here");
    });
    let actual = h.fragment().querySelector("a").innerHTML;
    assert.equal(actual, "click here");
  }); // it
}); // describe
