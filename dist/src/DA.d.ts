import { DA_Event } from "./DA_Event";
import { DA_HTML } from "./DA_HTML";
declare const DA: {
    HTML: typeof DA_HTML;
    Event: typeof DA_Event;
    split_whitespace: (x: string) => string[];
};
export { DA };
