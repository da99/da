

class DA_HTML {
  constructor(window) {
    this.window = window;
    this.document = this.window.document;
    this.fragment = this.document.createDocumentFragment();
    this.current = [this.fragment];
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
      if (typeof x === "string") {
        if (i === 0 && (x.indexOf('#') === 0 || x.indexOf('.') === 0)) {
          this_o.set_attributes(x);
          return;
        }
      } // if
      this_o.append_child(x);
    });

    target.appendChild(this.current.pop());
    return this;
  } // function

  target() {
    return this.current[this.current.length - 1];
  } // function

  set_attributes(x) {
    let target = this.target();
    if (typeof x === "string") {
      let classes = [];
      x.split(".").forEach((y) => {
        if (y.length === 0) { return; }

        if (y.indexOf("#") === 0) {
          let attr = this.document.createAttribute("id");
          attr.value = y.split("#")[1];
          target.setAttributeNode(attr);
          return;
        }

        classes.push(y);
      });
      classes = classes.join(" ");
      if (classes.length > 0) {
        let attr = this.document.createAttribute("class");
        attr.value = classes;
        target.setAttributeNode(attr);
      }
      return this;
    } // if

    for (const [k, v] of Object.entries(x)) {
      let attr = this.document.createAttribute(k);
      attr.value = v;
      target.setAttributeNode(attr);
    }

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
    this.document.querySelector(selector).appendChild(this.fragment);
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

  title(...args) {
    return this.new_tag("title", ...args);
  }

  div(...args) {
    return this.new_tag("div", ...args);
  } // function

  text_node(raw_txt) {
    return this.document.createTextNode(raw_txt);
  } /// function

  strong(...args) {
    return this.new_tag("strong", ...args);
  } // function
} // class

module.exports = DA_HTML;
