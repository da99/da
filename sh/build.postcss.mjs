#!/usr/bin/env node
"use strict";

import * as fs from "fs";
import * as path from "path";
import { execSync } from "child_process";

import stylelint from "stylelint";
import postcss from "postcss";
import precss from "precss";
import autoprefixer from "autoprefixer";
import postcss_reporter from "postcss-reporter";

const plugins = [
  precss,
  autoprefixer,
  stylelint({
    "config": {
      "extends": "stylelint-config-standard"
    }
  }),
  postcss_reporter({ clearReportedMessages: true })
];

function build_style_files(src) {
  const files = execSync(`find "${src}" -mindepth 2 -type f -name '*.css' -print `).toString().trim().split("\n");
  files.forEach(function (x) {
    const raw = fs.readFileSync(x);
    const dest_file = x;
    postcss(plugins)
      .process(raw, { from: x, to: dest_file })
      .then(result => {
        fs.writeFileSync(dest_file, result.css);
      });
  });
} // function


build_style_files("dist/Public/apps/");
