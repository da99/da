"use strict";
/* jshint undef: true, unused: true */
/* global _ */
/* exported is_numeric */

var Turu = {

  reset: function () {
    this.functions = {
      top: [],
      middle: [],
      bottom: []
    };
    return this;
  }, // === func reset

  top:    function (f) { this.functions.top.push(f); return this; },
  middle: function (f) { this.functions.middle.push(f); return this; },
  bottom: function (f) { this.functions.bottom.push(f); return this; },

  inspect: function (o) {
    return '(' + typeof(o) + ') "' + o + '"' ;
  },

  run: function (origin) {
    var data = _.clone(origin);

    _.each(this.functions, function (arr, arr_type) {
      _.each(arr, function (f, i) {
        f(data);
      });
    });
  }

};

Turu.reset();

