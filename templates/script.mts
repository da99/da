#!/usr/bin/env bun
import { $ } from "bun";

const bin = Bun.argv[1].split('/').at(-1);
const cmd = Bun.argv.slice(2).join(' ');

switch (cmd) {
  case '-h':
  case '--help':
  case 'help':
    console.log(`${bin} -h|--help|help -- Print this message.`)
    break;

  case '':
    console.log('Not implemented.')
    process.exit(0)

  default:
    console.warn(`!!! Unknown  command arguments for '${bin}': ${cmd}`)
    process.exit(1)
} // switch

