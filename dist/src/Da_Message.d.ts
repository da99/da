declare class Da_Message {
    private _messages;
    constructor();
    push(msg: string, func: any): void;
    message(msg: string, ...args: any[]): this | undefined;
}
declare const DA_MESSAGE: Da_Message;
export { Da_Message, DA_MESSAGE };
