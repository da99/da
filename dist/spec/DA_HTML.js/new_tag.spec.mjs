import { assert, describe, it, DA, JSDOM } from "./helper.mjs";
describe("DA.HTML.new_tag", function () {
    it("adds an element to the fragment", function () {
        let h = new DA.HTML((new JSDOM()).window);
        h.new_tag("strong", "hello");
        assert.equal(h.serialize(), "<strong>hello</strong>");
    });
    it("adds an id", function () {
        let h = new DA.HTML((new JSDOM()).window);
        h.new_tag("p", "#main");
        assert.equal(h.serialize(), `<p id="main"></p>`);
    });
    it("adds id and class attributes", function () {
        let h = new DA.HTML((new JSDOM()).window);
        h.new_tag("div", "#main.warning");
        assert.equal(h.serialize(), `<div id="main" class="warning"></div>`);
    });
    it("adds an id, class attributes and a text node", function () {
        let h = new DA.HTML((new JSDOM()).window);
        h.new_tag("div", "#main.mellow", "hello world");
        assert.equal(h.serialize(), `<div id="main" class="mellow">hello world</div>`);
    });
});
