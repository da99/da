# turu
Run functions in the browser based on an Object (kv structure).

Don't use this because you probably want async features, which
is not included here.


# Example:

```javascript

<script src="../path/to/turu.js"></script>

Turu.push(function (data) {
  if (!_.isMatch(data, {action: "hello"}))
    return;

   # ... do some stuff
   data.new_val = 5;
   data.old_val = undefined;
   return data;
});

Turu.push(function () {});
Turu.push(function () {});
Turu.push(function () {});
Turu.push(function () {});

Turu.run({action: 'hello', old_val: 5});

```

# Useless Facts:
Named after a [Jonny Quest episode](http://jqdb.wikia.com/wiki/Turu_the_Terrible)
because you can travel pretty far if you rode on a pteranodon.
