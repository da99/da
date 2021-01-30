declare class DA_Message {
    private _messages;
    constructor();
    push(raw_key: string, func: Function): void;
    has(raw_key: string): string | null;
    message(raw_key: string, ...args: any[]): void;
    private _standard_msg;
    private _run_message;
}
export { DA_Message };
