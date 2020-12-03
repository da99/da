

const jsdom = require("jsdom");
const { JSDOM } = jsdom;

function new_window() {
  const dom = new JSDOM("<!DOCTYPE html>");
  return dom.window;
} // function

function to_html(x) {
  const dom = new JSDOM("<!DOCTYPE html>");
  let e = dom.window.document.createElement("div");
  e.appendChild(x.fragment);
  return e.innerHTML;
} // function

module.exports = {
  new_window: new_window,
  to_html: to_html
};

