
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
        if (y.length === 0) { return; }

        if (y.indexOf("#") === 0) {
          let attr = doc.createAttribute("id");
          attr.value = y.split("#")[1];
          ele.setAttributeNode(attr);
          return;
        }

        classes.push(y);
      });
      classes = classes.join(" ");
      if (classes.length > 0) {
        let attr = doc.createAttribute("class");
        attr.value = classes;
        ele.setAttributeNode(attr);
      }
      return this;
    } // if

    if (typeof o === "object") {
      for (const [k, v] of Object.entries(o)) {
        let attr = doc.createAttribute(k);
        attr.value = v;
        ele.setAttributeNode(attr);
      }
    } // if

    return this;
  } // function
} // class

export class DA_HTML {

  constructor(page) {
    if (page && (page.window || page.document)) {
      if (page.window) {
        this.dom = page;
        this.window = this.dom.window;
      } else {
        this.dom = null;
        this.window = page;
      }
      this.document = this.dom.window.document;
    } else {
      throw new Error("No valid page found.")
    }

    this.document = this.window.document;
    this._fragment = this.document.createDocumentFragment();
    this.current = [this._fragment];
    this.is_finish = false;
  }

  new_tag(name, ...args) {
    if (this.is_finish) { throw new Error("No more nodes/elements allowed."); }
    let target = this.target();
    let element = this.document.createElement(name);
    this.current.push(element);
    let this_o = this;

    // process args
    args.forEach(function (x, i) {
      if (typeof x === "string" && i === 0 && (x.indexOf('#') == 0 || x.indexOf('.') === 0)) {
          this_o.set_attributes(x);
      } else if (typeof x === "string") {
        element.appendChild(this_o.text_node(x));
      } else if (typeof x === "function") {
        x(this_o);
      } else if (typeof x === "object" && x.wholeText) { // it's a TextNode
        element.appendChild(x);
      } else if (typeof x === "object") { // it's a TextNode
        this_o.set_attributes(x);
      } else {
        throw new Error("Invalid argument for new tag: " + x);
      }
    });

    target.appendChild(this.current.pop());
    return this;
  } // function

  target() {
    return this.current[this.current.length - 1];
  } // function

  set_attributes(x) {
    let ele = new DA_Element(this, this.target());
    ele.attributes(x);
    return this;
  } // function

  to_element(x) {
    if (!x || x === true) {
      return null;
    }
    switch(typeof x) {
      case "string":
        return(this.text_node(x));

      case "number":
        return(this.text_node(x.toString()));

      case "object":
        return(x);
    }
    return null;
  } // function


  finish(selector) {
    this.is_finish = true;
    return;
  }

  map(arr, f) {
    let new_arr = [];
    arr.forEach((x) => {
      new_arr.push(f(x));
    })
    return new_arr;
  }

  append_child(x) {
    let target = this.target();

    if (!x || x === true) { return; }

    if (Array.isArray(x)) {
      x.eachFor((y) => {
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

    error();
  } // function

  title(raw_text) {
    let title = this.document.querySelectorAll("title")[0];
    while(title.firstChild) {
      title.removeChild(title.firstChild);
    }
    title.appendChild(this.text_node(raw_text));
    return title;
  }

  link(attrs) {
    let l = new DA_Element(this, "link");
    l.attributes(attrs);
    this.document.querySelector("head").appendChild(l.element);
    return l.element;
  }

  meta(attrs) {
    let m;
    if (attrs["charset"]) {
      m = new DA_Element(this, this.document.querySelector("meta[charset]") || "meta");
      m.attributes(attrs);
    } else {
      m = new DA_Element(this, "meta");
      m.attributes(attrs);
      this.document.querySelector("head").appendChild(m.element);
    }
    return m.element;
  } // method

  serialize() {
    if (this._fragment.firstElementChild) {
      let e = this.document.createElement("div");
      e.appendChild(this._fragment);
      return e.innerHTML;
    } else if (this.dom) {
      return this.dom.serialize();
    }
  } // method

  fragment(func) {
    if (func) {
      this.current.push(this._fragment);
      func(this);
      this.current.pop();
      return this;
    } else {
      return this._fragment;
    }
  } // method

  body(...args) {
    let doc = this.document.querySelector("body");
    this.current.push(doc);
    let ele = new DA_Element(this, doc);
    let this_o = this;
    args.forEach(function (x) {
      if (typeof x === "function") {
        x(this_o);
      } else {
        if (typeof x === "string" || typeof x === "object") {
          ele.attributes(x);
        } else {
          throw new Error(`Unknown argument type: ${typeof x} -> ${x}`);
        }
      }
    });
    this.current.pop();
    return this;
  } // method

  script(...args) {
    return this.new_tag("script", ...args);
  } // function

  div(...args) {
    return this.new_tag("div", ...args);
  } // function

  text_node(raw_txt) {
    return this.document.createTextNode(raw_txt);
  } /// function

  strong(...args) {
    return this.new_tag("strong", ...args);
  } // function

  a(...args) {
    return this.new_tag("a", ...args);
  } // method

} // class


