import { describe, it, assert, DA, JSDOM } from "./helper.mjs";
describe("DA.HTML#div", function () {
    it("adds a div element to the fragment", function () {
        let h = new DA.HTML((new JSDOM()).window);
        h.div("hello");
        assert.equal(h.serialize(), "<div>hello</div>");
    });
    it("adds an id", function () {
        let h = new DA.HTML((new JSDOM()).window);
        h.div("#main");
        assert.equal(h.serialize(), `<div id="main"></div>`);
    });
    it("adds id and class attributes", function () {
        let h = new DA.HTML((new JSDOM()).window);
        h.div("#main.warning");
        assert.equal(h.serialize(), `<div id="main" class="warning"></div>`);
    });
    it("adds an id, class attributes and a text node", function () {
        let h = new DA.HTML((new JSDOM()).window);
        h.div("#main.mellow", "hello world");
        assert.equal(h.serialize(), `<div id="main" class="mellow">hello world</div>`);
    });
});
