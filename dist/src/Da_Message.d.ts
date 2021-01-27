declare class Da_Message {
    private _messages;
    constructor();
    push(msg: string | RegExp, func: any): void;
    message(msg: string, ...args: any[]): void;
}
declare const DA_MESSAGE: Da_Message;
export { Da_Message, DA_MESSAGE };
