declare class DA_HTML {
    window: Window;
    document: Document;
    _fragment: DocumentFragment;
    current: Array<DocumentFragment | HTMLElement | HTMLBodyElement>;
    is_finish: boolean;
    constructor(window: any);
    new_tag(name: any, ...args: any[]): this;
    target(): HTMLElement | DocumentFragment | HTMLBodyElement;
    set_attributes(x: any): this;
    to_element(x: any): any;
    finish(selector: any): void;
    append_child(x: any): this | undefined;
    title(raw_text: any): HTMLTitleElement;
    link(attrs: any): HTMLElement;
    meta(attrs: any): any;
    serialize(): string;
    fragment(func: any): DocumentFragment | this;
    body(...args: any[]): this;
    script(...args: any[]): this;
    text_node(raw_txt: any): Text;
    a(...args: any[]): this;
    div(...args: any[]): this;
    p(...args: any[]): this;
    strong(...args: any[]): this;
    textarea(...args: any[]): this;
    input(...args: any[]): this;
}
export { DA_HTML };