
DA.Event
===========

```js
  import { DA } from "da";

  let msg = new DA.Event();
  let x = 0;
  msg.on("increase", () => {
      x++;
  });
  msg.emit("increase");

  msg.on("with args", (a, b, c) => {
    console.log(a, b, c);
  });

  msg.emit("with args", "arg 1", "arg 2", "arg 3");

  msg.on("*", () => {
    console.log("This runs on every .emit");
  });
```
