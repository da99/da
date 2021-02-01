
import { DA_Event } from "./DA_Event";
import { DA_HTML } from "./DA_HTML";

const WHITESPACE_PATTERN = /\s+/

const DA = {
  HTML : DA_HTML,
  Event : DA_Event,

  split_whitespace : function (x : string) {
    // The .split method call will not create any null values in the
    // returned array. So no need to filter out null values.
    // We just need to filter out empty strings.
    return x.split(WHITESPACE_PATTERN).filter((x) => x.length != 0);
  } // function

}; // const DA


export { DA };
