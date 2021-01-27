class Da_Message {
    constructor() {
        this._messages = {};
    }
    push(msg, func) {
        if (!this._messages[msg]) {
            this._messages[msg] = [];
        }
        this._messages[msg].push(func);
    }
    message(msg, ...args) {
        if (!this._messages[msg]) {
            return this;
        }
        this._messages[msg].forEach((x) => {
            x(...args);
        });
    }
}
const DA_MESSAGE = new Da_Message();
export { Da_Message, DA_MESSAGE };
