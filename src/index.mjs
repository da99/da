
import chalk from "chalk";

export function describe(name, f) {
  console.error("Desribe: " + chalk.yellow.bold(name));
  f();
} // function

export function it(name, f) {
  process.stderr.write("  - it ");
  process.stderr.write(chalk.yellow.bold(name));
  try {
    f();
  } catch (err) {
    console.error(chalk.red.bold(" ✗"));
    throw err;
  }
  console.error(chalk.green.bold(" ✓"));
} // function

import assert from 'assert/strict';
export { assert, chalk };
