
const ASTERISK = "*";
const WHITESPACE = /(\s+)/;

class DA_Message {

  private _messages : object;

  constructor() {
    this._messages = {};
  } // method

  push (raw_key : string, func : Function) {
    let new_key = this._standard_msg(raw_key);

    if (!this._messages[new_key]) {
      this._messages[new_key] = [];
    }

    this._messages[new_key].push(func);
  } // method

  has (raw_key : string) {
    const key = this._standard_msg(raw_key);

    if (this._messages[ASTERISK]) {
      return ASTERISK;
    }

    if (this._messages[key]) {
      return key;
    }

    return null;
  } // method

  message (raw_key : string, ...args) {
    let msg = this._standard_msg(raw_key);
    if (msg === ASTERISK) {
      return;
    }
    this._run_message("*", msg, ...args);
    this._run_message(msg, ...args);
  } // method

  private _standard_msg(raw : string) {
    return raw.split(WHITESPACE).filter((e) => e !== "" ).join(" ");
  }

  private _run_message (msg : string, ...args) {
    if (this._messages[msg]) {
      this._messages[msg].forEach((f) => {
        f(...args);
      });
    }
  } // method

} // class

export { DA_MESSAGE };

