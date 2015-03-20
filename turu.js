"use strict";
/* jshint undef: true, unused: true */
/* global _, log */ 
/* exported is_numeric */ 

var Turu = {
  posts: []
};

// === Start scope =======================================
(function () {

  // ==============================================================
  // === Start of helper functions ================================
  // ==============================================================
  function every(val, func) {
    if (!_.isArray(val))
      throw new Error("Value is not an array: " + typeof val);

    if (_.isEmpty(val))
      return false;

    return _.every(val, func);
  }

  function inspect(o) {
    return '(' + typeof(o) + ') "' + o + '"' ;
  }
  // ==============================================================
  // === End of helper functions ==================================
  // ==============================================================

  var actions = [];
  var posts   = [];
  var is_running = false;

  function is_action_for_data(action) {
    log(posts);
    var arr_of_data = _.last(posts).data;
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

  function run_action_on_data(act) {
    var data = _.last(posts).data;
    return act.func.apply(data, [data]);
  }

  function run() {
    if (is_running) { return Turu; }


    function run_post() {
      var post      = _.last(posts);
      var data      = post.data;
      var act_found = false;

      _.each(actions, function (act) {
        if (!is_action_for_data(act, data))
          return;

        run_action_on_data(act, data);
        act_found = true;
      }); // == each

      if (!act_found) {
        if (_.isEqual(['not found', _.last(data)], data))
          throw new Error('No Turu action found for: ' + inspect(data));
        else {
          Turu.post('not found', data);
        }
      } // == if
    }

    is_running = true;
    while (!_.isEmpty(posts)) {
      run_post();
      posts.pop();
    }
    is_running = false;

    return Turu;
  }


  Turu.reset = function () {
    actions = [];
    posts   = [];
    return Turu;
  }; // === func reset


  Turu.on = function () {
    var args = _.toArray(arguments);
    var func = args.pop();
    var act  = {matchers: args, func: func};

    if (_.isEmpty(posts)) {
      actions.push(act);
      return Turu;
    }

    if (is_action_for_data(act)) {
      _.last(posts).on_count += 1;
      run_action_on_data(act);
      _.last(posts).on_count -= 1;
    }

    return Turu;
  }; // === func Turu.on ===


  Turu.post = function () {
    posts.unshift({
      post      : true,
      actions   : actions,
      data      : _.toArray(arguments),
      nested_on : -1,
    });

    run();
  }; // === func Turu.post ===


})();
// === End scope =========================================

