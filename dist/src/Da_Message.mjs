class Da_Message {
    constructor() {
        this._messages = {};
    }
    push(msg, func) {
        let key = msg.toString();
        if (!this._messages[key]) {
            if (typeof msg === "string") {
                this._messages[key] = { "key_type": "string", "key": msg, "values": [] };
            }
            else {
                if (typeof msg === "object" && msg.constructor === RegExp) {
                    this._messages[key] = { "key_type": "RegExp", "key": msg, "values": [] };
                }
            }
        }
        this._messages[key].values.push(func);
    }
    message(msg, ...args) {
        let key = msg.toString();
        for (const [_key, meta] of Object.entries(this._messages)) {
            switch (meta.key_type) {
                case "string":
                    if (msg !== key) {
                        continue;
                    }
                    break;
                case "RegExp":
                    if (!msg.match(meta.key)) {
                        continue;
                    }
                    break;
            }
            meta.values.forEach((x) => { x(...args); });
        }
    }
}
const DA_MESSAGE = new Da_Message();
export { Da_Message, DA_MESSAGE };
