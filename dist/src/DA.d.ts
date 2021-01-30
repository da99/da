import { DA_Message } from "./DA_Message";
import { DA_HTML } from "./DA_HTML";
declare const DA: {
    HTML: typeof DA_HTML;
    Message: typeof DA_Message;
    split_whitespace: (x: string) => string[];
};
export { DA };
