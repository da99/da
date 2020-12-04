

import { JSDOM } from "jsdom";
import { DA_HTML } from "../src/main.js";

export function new_window() {
  const dom = new JSDOM("<!DOCTYPE html>");
  return dom.window;
} // function

export function to_html(x) {
  const dom = new JSDOM("<!DOCTYPE html>");
  let e = dom.window.document.createElement("div");
  e.appendChild(x.fragment);
  return e.innerHTML;
} // function

export { DA_HTML };

