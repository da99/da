
function should_be_array(x) {
  if (typeof(x) === "object" && x.prototype === ([]).prototype) {
    return true;
  }
  throw(new Error("not an array: " + Object.prototype.toString.call(x)));
};

function should_be_object(x) {
  if (typeof(x) === "object" && x.prototype === ({"a": "b"}).prototype) {
    return true;
  }
  throw(new Error("not an object: " + Object.prototype.toString.call(x)));
};
