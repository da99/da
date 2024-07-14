
// external NaN, TypeError, Error, process, require, window, arguments, Object, RegExp;


function console_log() {
  if (!is_dev()) {
    return null;
  }
  return console.log.apply(console, arguments);
};

function keys(v) {
  let arr = [];
  for (let x in v) {
    if (v.hasOwnProperty(x))
      arr.push(x);
  }
  return arr;
}

function is_dev() {
  if (typeof process !== 'undefined' && (process.env.IS_DEVELOPMENT || process.env.IS_DEV)) {
    return true;
  }

  if (typeof window !== 'undefined') {
    var addr = window.location.href;
    return window.console && (addr.indexOf("localhost") > -1 ||
      addr.indexOf("file:///") > -1 ||
      addr.indexOf("127.0.0.1") > -1)
    ;
  }
  return false;
}

function is_positive(v) {
  return typeof v === 'number' && is_finite(v) && v > 0;
}

function is_finite(v) {
  return (typeof v === 'number') && (v !== NaN);
}

function is_plain_object(v) {
  return typeof(v) === "object" && v.constructor === {}.constructor;
}

function is_object(v) {
  return typeof(v) === "object";
}

function is_string(v) {
  return typeof v === "string";
}

function is_num(v) {
  return typeof v === 'number' && v !== NaN;
}

function is_boolean(v) {
  return typeof v === 'boolean';
}

function is_true(v) {
  return v === true;
}

function is_array(v) {
  var a = [];
  return typeof(v) == "object" && v.constructor === a.constructor;
}


function is_function(v) {
  return typeof v === 'function';
}

function is_regexp(val) {
  return(val instanceof RegExp);
}


function is_null(v) {
  return v === null || typeof(v) === "null";
}


function is_undefined(v) {
  return v === undefined || typeof(v) === "undefined";
}


function is_enumerable(v) {
  return is_string(v) ||
    is_array(v)         ||
    is_plain_object(v)  ||
    (is_something(v) && is_finite(v.length));
}



function is_error(v) {
  return is_object(v) && (
    v.constructor === Error ||
    (!is_plain_object(v) && is_string(v.stack) && is_string(v.message))
  );
}


function is_nothing(v) {
  return v === null || v === undefined;
}

function is_null_or_undefined(v) {
  return v === null || v === undefined;
}


function is_empty(string str) {
  return str.length === 0;
}

function is_empty(v) {
  if (v && is_finite(v.length))
    return v.length === 0;

  if (is_plain_object(v))
    return keys(v).length === 0;

  throw new Error("Invalid value for is_empty: " + to_string(v));
} // === func

function is_something(v) {
  if (arguments.length !== 1)
    throw new Error("arguments.length !== 1: " + to_string(v));
  return v !== null && v !== undefined;
}

function is_arguments(v) {
  return Object.prototype.toString.call( v ) === '[object Arguments]';
}

function inspect(arg) {
  return to_string(arg);
}

function to_string(arg) {
  if (arg === null)
    return 'null';

  if (arg === undefined)
    return 'undefined';

  if (is_function(arg))
    return arg.toString().replace("function (){return(", "").replace(/\)?;\}$/, '');

  if (arg === true)
    return 'true';

  if (arg === false)
    return 'false';

  if (is_string(arg)) {
    return '"' + arg + '"';
  }

  if (is_function(arg))
    return (arg.name) ? arg.name + ' (function)' : arg.toString();

  if (is_error(arg))
    return '[Error] ' + to_string(arg.message);

  if (typeof arg === "object" ) {

    if (is_array(arg) || is_arguments(arg)) {
      string[] fin = [];
      foreach ( var x in arg ) {
        fin.push(to_string(x));
      }
      string fin_str = fin.join(",");

      if (is_arguments(arg))
        return "arguments[" + fin_str + "]";
      else
        return "[" + fin_str + "]";
    }

    string[] fin = [];
    for(var x in arg) {
      if (arg.hasOwnProperty(x)) {
        fin.push(to_string(x) + ":" + to_string(arg[x]));
      }
    }
    string fin_str = "{" + fin.join(",") + "}";
    return fin_str;
  }

  var _inspect = (typeof window == "undefined") ? require('util').inspect : function (v) { return "" + v; };
  return _inspect(arg);
} // === string to_string

function own_property(string raw_name, v) {
  string name = trim(raw_name);
  if (!v.hasOwnProperty(name))
    return undefined;
  return v[name];
} // === func own_property

function return_arguments(...args) { return arguments; }
function to_arguments() { return arguments; }

function to_array(val) {
  if (!is_array(val) && val.constructor != arguments.constructor)
    throw new Error("Invalid value for to_array: " + to_string(val));

  var arr = [];
  int len = val.length;
  for (int i = 0; i < len; i++) {
    arr.push(val[i]);
  }
  return arr;
} // === func

// Removes begining slash, if any.
function to_var_name(string val) {
  return to_var_name(val, "_");
}

function to_var_name(string val, string delim) {
  return val.replace(/^[\/]+/, "").replace(/[^a-zA-Z-0-9\_\-]+/g, delim);
}

function repeat(unsigned short num, func) {
  for (var i = 0; i < num; i++) { func(); }
  return true;
}


