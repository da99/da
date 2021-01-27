
class Da_Message {
  private _messages : object;
  constructor() {
    this._messages = {};
  }

  push (msg : string, func) {
    if (!this._messages[msg]) {
      this._messages[msg] = [];
    }
    this._messages[msg].push(func);
  }

  message (msg : string, ...args) {
    if (!this._messages[msg]) {
      return this;
    }
    this._messages[msg].forEach((x) => {
      x(...args);
    });
  }
} // class

const DA_MESSAGE = new Da_Message();

export { Da_Message, DA_MESSAGE };
