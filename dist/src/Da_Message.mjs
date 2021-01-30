const ASTERISK = "*";
const WHITESPACE = /(\s+)/;
class Da_Message {
    constructor() {
        this._messages = {};
    }
    push(raw_key, func) {
        let new_key = this._standard_msg(raw_key);
        if (!this._messages[new_key]) {
            this._messages[new_key] = [];
        }
        this._messages[new_key].push(func);
    }
    has(raw_key) {
        const key = this._standard_msg(raw_key);
        if (this._messages[ASTERISK]) {
            return ASTERISK;
        }
        if (this._messages[key]) {
            return key;
        }
        return null;
    }
    message(raw_key, ...args) {
        let msg = this._standard_msg(raw_key);
        if (msg === ASTERISK) {
            return;
        }
        this._run_message("*", msg, ...args);
        this._run_message(msg, ...args);
    }
    _standard_msg(raw) {
        return raw.split(WHITESPACE).filter((e) => e !== "").join(" ");
    }
    _run_message(msg, ...args) {
        if (this._messages[msg]) {
            this._messages[msg].forEach((f) => {
                f(...args);
            });
        }
    }
}
export { Da_Message };
