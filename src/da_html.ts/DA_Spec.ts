
const RESET = "\x1b[0m";

// Colors from: https://stackoverflow.com/questions/9781218/how-to-change-node-jss-console-font-color
const DA_Spec = {
  "BOLD" : "\x1b[1m",
  "RED": "\x1b[31m",
  "GREEN": "\x1b[32m",
  "YELLOW": "\x1b[33m"
}; // const

const WHITESPACE = /(\s+)/; 

function standard_keys(raw : string) {
  return raw.split(WHITESPACE).filter((e) => e !== "" );
}

function color(color, ...args) {
  const new_color = standard_keys(color).map((x) => DA_Spec[x]).join(" ");
  return `${new_color}${args.join(" ")}${RESET}`;
}

function bold(txt) {
  return color("BOLD", txt);
}

function green(txt) {
  return color("GREEN", txt);
}

function red(txt) {
  return color("RED", txt);
}

function yellow(txt) {
  return color("YELLOW", txt);
}

green.bold  = function (...args) { return color("GREEN BOLD", args); };
red.bold    = function (...args) { return color("RED BOLD", args); };
yellow.bold = function (...args) { return color("YELLOW BOLD", args); };

export function describe(name, f) {
  console.error(bold("Describe: ") + yellow(name));
  f();
} // function

export function it(name, f) {

  try {
    f();
    console.error(bold("  - ") + green.bold("✓ " + name));
  } catch (err) {
    console.error(bold("  - ") + red.bold("✗ " + name));
    throw err;
  }
} // function

import { strict as assert } from "assert";
export { assert };

