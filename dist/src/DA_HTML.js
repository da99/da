class DA_Element {
    constructor(html, tagName) {
        this.element = (typeof tagName == "string") ? html.document.createElement(tagName) : tagName;
        this.html = html;
    }
    attributes(o) {
        let doc = this.html.document;
        let ele = this.element;
        if (typeof o === "string") {
            let classes = [];
            o.split(".").forEach((y) => {
                if (y.length === 0) {
                    return;
                }
                if (y.indexOf("#") === 0) {
                    let attr = doc.createAttribute("id");
                    attr.value = y.split("#")[1];
                    ele.setAttributeNode(attr);
                    return;
                }
                classes.push(y);
            });
            let classes_str = classes.join(" ");
            if (classes_str.length > 0) {
                let attr = doc.createAttribute("class");
                attr.value = classes_str;
                ele.setAttributeNode(attr);
            }
            return this;
        }
        if (typeof o === "object") {
            for (const [k, v] of Object.entries(o)) {
                let attr = doc.createAttribute(k);
                if (typeof v == "string") {
                    attr.value = v;
                }
                ele.setAttributeNode(attr);
            }
        }
        return this;
    }
}
class DA_HTML {
    constructor(window) {
        this.window = window;
        this.document = this.window.document;
        this._fragment = this.document.createDocumentFragment();
        this.current = [this._fragment];
        this.is_finish = false;
    }
    new_tag(name, ...args) {
        if (this.is_finish) {
            throw new Error("No more nodes/elements allowed.");
        }
        let target = this.target();
        let element = this.document.createElement(name);
        this.current.push(element);
        let this_o = this;
        args.forEach(function (x, i) {
            if (typeof x === "string" && i === 0 && (x.indexOf('#') == 0 || x.indexOf('.') === 0)) {
                this_o.set_attributes(x);
            }
            else if (typeof x === "string") {
                element.appendChild(this_o.text_node(x));
            }
            else if (typeof x === "function") {
                x(this_o);
            }
            else if (typeof x === "object" && x.wholeText) {
                element.appendChild(x);
            }
            else if (typeof x === "object") {
                this_o.set_attributes(x);
            }
            else {
                throw new Error("Invalid argument for new tag: " + x);
            }
        });
        let new_child = this.current.pop();
        if (new_child) {
            target.appendChild(new_child);
        }
        return this;
    }
    target() {
        return this.current[this.current.length - 1];
    }
    set_attributes(x) {
        let ele = new DA_Element(this, this.target());
        ele.attributes(x);
        return this;
    }
    to_element(x) {
        if (!x || x === true) {
            return null;
        }
        switch (typeof x) {
            case "string":
                return (this.text_node(x));
            case "number":
                return (this.text_node(x.toString()));
            case "object":
                return (x);
        }
        return null;
    }
    finish(selector) {
        this.is_finish = true;
        return;
    }
    append_child(x) {
        let target = this.target();
        if (!x || x === true) {
            return;
        }
        if (Array.isArray(x)) {
            x.forEach((y) => {
                this.append_child(y);
                return this;
            });
        }
        if (typeof x == "string") {
            this.target().appendChild(this.document.createTextNode(x));
            return this;
        }
        if (typeof x == "function") {
            x(target);
            return this;
        }
        if (Object.getPrototypeOf(x) == Object.prototype) {
            this.set_attributes(x);
            return this;
        }
        throw new Error("Invalid argument for child element.");
    }
    title(raw_text) {
        let title = this.document.querySelectorAll("title")[0];
        while (title.firstChild) {
            title.removeChild(title.firstChild);
        }
        title.appendChild(this.text_node(raw_text));
        return title;
    }
    link(attrs) {
        let l = new DA_Element(this, "link");
        l.attributes(attrs);
        let head = this.document.querySelector("head");
        if (head) {
            head.appendChild(l.element);
        }
        return l.element;
    }
    meta(attrs) {
        let m;
        if (attrs["charset"]) {
            m = new DA_Element(this, this.document.querySelector("meta[charset]") || "meta");
            m.attributes(attrs);
        }
        else {
            m = new DA_Element(this, "meta");
            m.attributes(attrs);
            let head = this.document.querySelector("head");
            if (head) {
                head.appendChild(m.element);
            }
        }
        return m.element;
    }
    serialize() {
        let e = this.document.createElement("div");
        e.appendChild(this._fragment);
        return e.innerHTML;
    }
    fragment(func) {
        if (func) {
            this.current.push(this._fragment);
            func(this);
            this.current.pop();
            return this;
        }
        else {
            return this._fragment;
        }
    }
    body(...args) {
        let doc = this.document.querySelector("body");
        if (!doc) {
            return this;
        }
        this.current.push(doc);
        let ele = new DA_Element(this, doc);
        let this_o = this;
        args.forEach(function (x) {
            if (typeof x === "function") {
                x(this_o);
            }
            else {
                if (typeof x === "string" || typeof x === "object") {
                    ele.attributes(x);
                }
                else {
                    throw new Error(`Unknown argument type: ${typeof x} -> ${x}`);
                }
            }
        });
        this.current.pop();
        return this;
    }
    script(...args) {
        return this.new_tag("script", ...args);
    }
    text_node(raw_txt) {
        return this.document.createTextNode(raw_txt);
    }
    a(...args) {
        return this.new_tag("a", ...args);
    }
    div(...args) { return this.new_tag("div", ...args); }
    p(...args) { return this.new_tag("p", ...args); }
    strong(...args) { return this.new_tag("strong", ...args); }
    textarea(...args) { return this.new_tag("textarea", ...args); }
    input(...args) { return this.new_tag("input", ...args); }
}
export { DA_HTML };
