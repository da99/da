
const jsdom = require("jsdom");
const { JSDOM } = jsdom;
const dom = new JSDOM(`<!DOCTYPE html><html lang="en"></html>`);
const document = dom.window.document;

class HTML {
  constructor(window) {
    this.window = window;
    this.document = this.window.document;
  }
  new_tag(name, ...args) {
    return this.append_children(this.document.createElement(name), ...args);
  } // function

  set_attributes(target, obj) {
    for (const [key, v] of Object.entries(obj)) {
      let a = this.document.createAttribute(key);
      a.value = v;
      target.setAttributeNode(a);
    }
    return target;
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


  body(...args) {
    return this.append_children(this.document.querySelector("body"), ...args);
  }

  head(...args) {
    return this.append_children(this.document.querySelector("head"), ...args);
  }

  map(arr, f) {
    let new_arr = [];
    arr.forEach((x) => {
      new_arr.push(f(x));
    })
    return new_arr;
  }

  append_children(target, ...args) {
    args.forEach((x) => {
      if (!x || x === true) {
        return;
      }
      if (Array.isArray(x)) {
        return this.append_children(target, ...x);
      }
      if (typeof x == "function") {
        return this.append_children(target, x(target));
      } else {
        if (Object.getPrototypeOf(x) == Object.prototype) {
          this.set_attributes(target, x);
        } else {
          let y = this.to_element(x);
          if (y) {
            target.appendChild(y);
          }
        }
      }
    });
    return target;
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


// body.appendChild(
//   div({id: "d1", class: "warning"},
//     strong("hello"),
//     (true) && strong("big"),
//     strong("world")
//   )
// );

// console.log(dom.window.document.querySelector("p").attributes["data-spacing"].value = "yo \" yo"); // "Hello world"

let html = new HTML(dom.window);

html.head(html.title("Hello Page"));
html.body(
  html.div(
    {id: "main", class: "warning"},
    "yum",
    false,
    undefined,
    html.strong({class: "mellow"}, "Hello"),
    html.strong("World")
  )
);

function my_partial( x ) {
  return html.div(add_3(x));
}
function add_3(x) {
  return html.div(x + 3);
}
      // html.map([1,2,3], (x) => { return html.div(html.map( [5,6,7], (y) => {
      //   return html.div(y + x);
      // }
      // ));})
html.body(
  html.div(
    html.div(
      [1,2,3].map(x => my_partial(x))
    )
  )
);

console.log(dom.serialize()); // "Hello world"

function a() {
  console.log(this.boy);
}

a.apply({boy: "the objeect"});

