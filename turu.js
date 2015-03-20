"use strict";
/* jshint undef: true, unused: true */
/* global _ */ 
/* exported is_numeric */ 

var Turu = {};

// === Start scope =======================================
(function () {

  function log() {
    if (window.console)
      console['log'].apply(console, arguments);
  }

  function is_numeric(val) {
    return _.isNumber(val) && !_.isNaN(val);
  }

  function every(val, func) {
    if (!_.isArray(val))
      throw new Error("Value is not an array: " + typeof val);

    if (_.isEmpty(val))
      return false;

    return _.every(val, func);
  }

  function array_in_array(small, big) {
    if (!_.isArray(small))
      throw new Error("Invalid data type for small array: " + inspect(small));
    if (!_.isArray(big))
      throw new Error("Invalid data type for big array: " + inspect(big));
    return every(small, function (v) { return _.includes(big, v); });
  }

  function inspect(o) {
    return '(' + typeof(o) + ') "' + o + '"' ;
  }

  function is_request(o) {
    return _.isString(o) || _.isPlainObject(o) || _.isArray(o);
  }

  function is_action_for_data(action, arr_of_data) {
    var result = every(action.matchers, function (m) {
      if (_.isString(m)){
        return _.detect(arr_of_data, function (d) {
          return _.isString(d) && d === m;
        });

      } else if (_.isArray(m)) {
        return _.detect(arr_of_data, function (data) {
          return _.isArray(data) && _.isEqual(m.sort(), data.sort());
        });

      } else if (_.isPlainObject(m)) {
        return _.detect(arr_of_data, function (d) {
          return _.isPlainObject(d) && _.isEqual(m, _.pick(d, _.keys(m)));
        });

      } else if (_.isFunction(m)) {
        return _.detect(arr_of_data, m);
      } else
        throw new Error("Unknown value for matching: " + typeof m);
    });

    return result;
  }

  function run_action_on_data(act, data) {
    return act.func(data);
  }

  var actions = [];

  Turu.on = function () {
    var args = _.toArray(arguments);
    var func = args.pop();
    actions.push({matchers: args, func: func});

    return Turu;
  }; // === func Turu.on

  Turu.post = function () {
    var data      = _.toArray(arguments);
    var act_found = false;

    _.each(actions, function (act) {
      if (!is_action_for_data(act, _.clone(data)))
        return;

      run_action_on_data(act, _.clone(data));
      act_found = true;
    }); // == each

    if (!act_found) {
      if (_.isEqual(['not found', _.last(data)], data))
        throw new Error('No Turu action found for: ' + inspect(data));
      else {
        Turu.post('not found', data);
      }
    } // == if

    return Turu;
  }; // === func Turu.post

  Turu.reset = function () {
    actions = [];
    return Turu;
  }; // function

})();
// === End scope =========================================

