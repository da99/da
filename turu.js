"use strict";
/* jshint undef: true, unused: true */
/* global _ */
/* exported is_numeric */

var Turu = {
  posts: []
};

// === Start scope =======================================
(function () {

  // ==============================================================
  // === Start of helper functions ================================
  // ==============================================================

  function inspect(o) {
    return '(' + typeof(o) + ') "' + o + '"' ;
  }

  function by_method(name, arr) {
    return _.select(arr, function (v) {
      return _[name](v);
    });
  }

  function strings(arr) {
    return by_method('isString', arr).sort();
  } // === func strings

  function arrays(arr) {
    // get arrays and sort each them,
    // and sort the final array
    return _.map( by_method('isArray', arr), function (v) {
      return v.sort();
    }).sort();
  } // === func arrays

  function objects(arr) {
    return by_method('isPlainObject', arr).sort();
  } // === func objects

  // ==============================================================
  // === End of helper functions ==================================
  // ==============================================================

  var actions = [];
  var posts   = [];
  var is_running = false;

  function is_action_for_data(action) {

    var is_found    = true;
    var meta        = _.last(posts);
    var posted      = meta.origin;

    if (meta.nested_ons > 0) {
      posted = objects(posted);
    }

    var strs        = strings(action.matchers);
    var posted_strs = strings(posted);

    if (!_.isEqual(strs, posted_strs))
      return false;

    var arrs        = arrays(action.matchers);
    var posted_arrs = arrays(posted);

    if (!_.isEqual(arrs, posted_arrs))
      return false;

    var objs        = objects(action.matchers);
    var posted_objs = objects(posted);

    if (_.size(posted_objs) > 1) {
      throw new Error('Only one plain object allowed to be POST-ed.');
    }

    var funcs = by_method('isFunction', posted);

    if (_.size(funcs) > 0 && _.isEmpty(objs))
      return false;

    _.detect(funcs, function (f) {
      if (!f(objs[0], _.last(posts)))
        is_found = false;
      return !is_found;
    });

    return is_found;
  }

  function run_action_on_data(act) {
    var data = objects(_.last(posts).origin)[0];
    return act.func(data, _.last(posts));
  }

  function run() {
    if (is_running) { return Turu; }


    function run_post() {
      var post      = _.last(posts);
      var data      = post.origin;
      var act_found = false;

      _.each(actions, function (act) {
        if (!is_action_for_data(act))
          return;

        run_action_on_data(act);
        act_found = true;
      }); // == each

      if (!act_found) {
        if ('not found' === data[0]) {
          var origin = _.map(_.last(data).origin, function (v) { return inspect(v); }).join(", ");
          throw new Error('No Turu action found for: ' + origin);
        } else {
          Turu.post('not found', {origin: post.origin});
        }
      } // == if
    }

    is_running = true;
    while (!_.isEmpty(posts)) {
      _.last(posts).nested_ons += 1;
      run_post();
      _.last(posts).nested_ons -= 1;
      posts.pop();
    }
    is_running = false;

    return Turu;
  }


  Turu.reset = function () {
    actions = [];
    posts   = [];
    is_running = false;
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

    _.last(posts).nested_ons += 1;
    if (is_action_for_data(act))
      run_action_on_data(act);
    _.last(posts).nested_ons -= 1;

    return Turu;
  }; // === func Turu.on ===


  Turu.post = function () {
    posts.unshift({
      post      : true,
      actions   : actions,
      origin    : _.toArray(arguments),
      nested_ons : -1,
    });

    run();
  }; // === func Turu.post ===


})();
// === End scope =========================================

