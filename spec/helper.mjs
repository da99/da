

import { JSDOM } from "jsdom";
import { DA_HTML } from "../src/index.mjs";
import { describe, it, assert } from "da_spec";

const HTML5 = `<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <title></title>
  </head>
  <body></body>
</html>`;

export function new_dom() {
  return new JSDOM(HTML5);
} // function

export function new_window() {
  const dom = new JSDOM(HTML5);
  return dom.window;
} // function


export { DA_HTML, describe, it, assert };

