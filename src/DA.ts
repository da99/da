
import { DA_Message } from "./DA_Message";
import { DA_HTML } from "./DA_HTML";

const WHITESPACE_PATTERN = /\s+/
const DA = {
  HTML : DA_HTML,
  Message : DA_Message,
  split_whitespace : function (x : string) {
    const arr : string[] = [];
    x.split(WHITESPACE_PATTERN).forEach((x) => {
      const str = x.trim();
      if (str && str.length != 0) {
        arr.push(str);
      }
    });
    return arr;
  }
}; // const DA


export { DA };
