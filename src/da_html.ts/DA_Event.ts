
const ASTERISK = "*";
const WHITESPACE = /(\s+)/;

class DA_Event {

  private _events : object;

  constructor() {
    this._events = {};
  } // method

  on (raw_key : string, func : Function) {
    let new_key = this._standard_msg(raw_key);

    if (!this._events[new_key]) {
      this._events[new_key] = [];
    }

    this._events[new_key].push(func);
  } // method

  has (raw_key : string) {
    const key = this._standard_msg(raw_key);

    if (this._events[ASTERISK]) {
      return ASTERISK;
    }

    if (this._events[key]) {
      return key;
    }

    return null;
  } // method

  emit (raw_key : string, ...args) {
    let msg = this._standard_msg(raw_key);
    if (msg === ASTERISK) {
      return;
    }
    this._emit("*", msg, ...args);
    this._emit(msg, ...args);
  } // method

  private _standard_msg(raw : string) {
    return raw.split(WHITESPACE).filter((e) => e !== "" ).join(" ");
  }

  private _emit (msg : string, ...args) {
    if (this._events[msg]) {
      this._events[msg].forEach((f) => {
        f(...args);
      });
    }
  } // method

} // class

export { DA_Event };

