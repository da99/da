const ASTERISK = "*";
const WHITESPACE = /(\s+)/;
class DA_Event {
    constructor() {
        this._events = {};
    }
    on(raw_key, func) {
        let new_key = this._standard_msg(raw_key);
        if (!this._events[new_key]) {
            this._events[new_key] = [];
        }
        this._events[new_key].push(func);
    }
    has(raw_key) {
        const key = this._standard_msg(raw_key);
        if (this._events[ASTERISK]) {
            return ASTERISK;
        }
        if (this._events[key]) {
            return key;
        }
        return null;
    }
    emit(raw_key, ...args) {
        let msg = this._standard_msg(raw_key);
        if (msg === ASTERISK) {
            return;
        }
        this._emit("*", msg, ...args);
        this._emit(msg, ...args);
    }
    _standard_msg(raw) {
        return raw.split(WHITESPACE).filter((e) => e !== "").join(" ");
    }
    _emit(msg, ...args) {
        if (this._events[msg]) {
            this._events[msg].forEach((f) => {
                f(...args);
            });
        }
    }
}
export { DA_Event };
