
DA.HTML
==============

```js
  import { JSDOM } from "jsdom";
  import { DA } from "da";
  const html = new DA.HTML(window);
  html.div(".first", () => {
      html.p("empty paragraph");
  });
  const str = html.serialize();
  html.fragment();

```
