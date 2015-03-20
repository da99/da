"use strict";
/* jshint undef: true, unused: true */
/* global Turu, describe, it, expect, beforeEach */ 

var on   = Turu.on;
var post = Turu.post;

describe('Tufu', function () {

  beforeEach(Turu.reset);

  it('runs the code on a match', function () {
    var r = 0;
    on('something', function () { r = 5; return true; });

    post('something');
    expect(r).toEqual(5);
  }); // === it runs the code

  it('runs "not found" when no matcher is found', function () {
    var r = 0;
    on('not found', function () { r = 10; return true;  });

    post('something');
    expect(r).toEqual(10);
  }); // === it runs the code

  it('runs funcs on any match', function () {
    var r = [];
    function add(i) {
      return function () { r.push(i); }
    }
    on(['news'],          add(1));
    on(['news', 'hello'], add(2));
    on(['news', 'hello'], add(3));
    post('news', 'hello');
    expect(r).toEqual([2,3]);
  }); // === it runs funcs on any match

  it('matches on String, Array, Object', function () {
    var r = false;
    on('news', ['good', 'happy'], {read: 7, comments: 9}, function () {
      r = true;
      return r;
    });

    post('news', ['good','happy'], {read: 7, comments: 9, body: 'happy news'});
    expect(r).toEqual(true);
  }); // === it matches on String, Array, Object

}); // === describe Tufu =================

describe('Object matching:', function () {

  it('matches objects', function () {
    var r = false;
    on({harry:'Sally', sam:'Diane'}, function () { r = 'found'; return true;});
    post({harry:'Sally', sam:'Diane', scott:'Jean Grey'});
    expect(r).toEqual('found');
  });

}); // === describe Object matching =================

describe('Array matching:', function () {

  beforeEach(Turu.reset);

  it('matches on Array', function () {
    var r = false;
    on(['good', 'happy'], function () {
      r = true;
      return r;
    });

    post(['good','happy']);

    expect(r).toEqual(true);
  }); // === it matches on Array

  it('does not match if posted Array has extra values', function () {
    var r = [];
    on(['good', 'happy'], function () {
      r.push('one');
      return r;
    });
    on(['good', 'happy', 'positive'], function () {
      r.push('positive');
      return r;
    });

    post(['good','happy', 'positive']);

    expect(r).toEqual(['positive']);
  }); // === it does not match if posted Array has extra values

}); // === describe Array matching =================


describe('Custom Matchers', function () {

  beforeEach(Turu.reset);

  it('matches when returns true', function () {
    var r = false;
    $('#the_stage').html('<div class="hermitage"></div>');
    function has_class(c) {
      return function (data) {
        return data.hasClass && data.hasClass(c);
      };
    }
    on(has_class('hermitage'), function () {
      r = true;
      return true;
    });

    post($('#the_stage div'));

    expect(r).toEqual(true);
  }); // === it matches when returns true

  it('does not match when func returns false', function () {
    var r = [];
    var f = function () { return false; };
    on(f,   function () { r.push('f'); return true; });
    on('a', function () { r.push('a'); return true; });
    post('a');
    expect(r).toEqual(['a']);
  }); // === it does not match when func returns false

}); // === describe Custom Matchers =================


describe('inner on:', function () {

  it('runs :on defined in callbacks based on matches', function () {

    var r = [];

    on('news', function (data) {
      r.push('news');
      on('good', function () {
        r.push('good');
        on('very', function () { r.push('very'); });
      });
    }); // === on

    post('news', {tags: ['news', 'good', 'very']});

    expect(r).toEqual(['news', 'good', 'very']);
  }); // === it runs :on defined in callbacks based on matches

}); // === describe inner on =================
