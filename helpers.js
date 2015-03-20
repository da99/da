"use strict";


function array_in_array(small, big) {
  if (!_.isArray(small))
    throw new Error("Invalid data type for small array: " + inspect(small));
  if (!_.isArray(big))
    throw new Error("Invalid data type for big array: " + inspect(big));
  return every(small, function (v) { return _.includes(big, v); });
}

function is_request(o) {
  return _.isString(o) || _.isPlainObject(o) || _.isArray(o);
}

function is_numeric(val) {
  return _.isNumber(val) && !_.isNaN(val);
}

function log() {
  if (window.console)
    console['log'].apply(console, arguments);
}
