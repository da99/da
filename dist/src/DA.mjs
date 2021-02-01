import { DA_Event } from "./DA_Event.mjs";
import { DA_HTML } from "./DA_HTML.mjs";
const WHITESPACE_PATTERN = /\s+/;
const DA = {
    HTML: DA_HTML,
    Event: DA_Event,
    split_whitespace: function (x) {
        return x.split(WHITESPACE_PATTERN).filter((x) => x.length != 0);
    }
};
export { DA };
