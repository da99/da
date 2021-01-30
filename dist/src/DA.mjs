import { DA_Message } from "./DA_Message.mjs";
import { DA_HTML } from "./DA_HTML.mjs";
const WHITESPACE_PATTERN = /\s+/;
const DA = {
    HTML: DA_HTML,
    Message: DA_Message,
    split_whitespace: function (x) {
        return x.split(WHITESPACE_PATTERN).filter((x) => x.length != 0);
    }
};
export { DA };
