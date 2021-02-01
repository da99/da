declare class DA_Event {
    private _events;
    constructor();
    on(raw_key: string, func: Function): void;
    has(raw_key: string): string | null;
    emit(raw_key: string, ...args: any[]): void;
    private _standard_msg;
    private _emit;
}
export { DA_Event };
