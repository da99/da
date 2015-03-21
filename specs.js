"use strict";
/* jshint undef: true, unused: true */
/* global Turu, describe, it, expect, beforeEach */ 

var on   = Turu.on;
var post = Turu.post;

describe('Tufu:', function () {

  beforeEach(Turu.reset);

  it('runs the code on a match', function () {
    var r = 0;
    on('something', function () { r = 5; return true; });

    post('something');
    expect(r).toEqual(5);
  }); // === it runs the code

  it('runs "not found" when no matcher is found', function () {
    var r = 0;
    on('not found', function (data) { r = data.origin; return true;  });

    post('something');
    expect(r).toEqual(['something']);
  }); // === it runs the code

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

  beforeEach(Turu.reset);

  it('throws Error if more than one Object', function () {
    var r = false;
    on({harry:'Sally', sam:'Diane'}, function () { r = 'found'; return true;});
    expect(function () {
      post({harry:'Sally', sam:'Diane', scott:'Jean Grey'}, {harry:'Sally', sam:'Diane', scott:'Jean Grey'});
    }).toThrow(new Error('Only one plain object allowed to be POST-ed.'));
  });

  it('passes object to custom matcher', function () {
    var r = [];
    function good(data) {
      return _.includes(data.tags, 'good');
    }
    on('news', good, function () {
      r.push("good news");
    });

    post('news', {headline:'Mets Loose', tags: ['good', 'great']});
    expect(r).toEqual(['good news']);
  }); // === it passes object to custom matcher

}); // === describe Object matching =================

describe('String matching:', function () {

  beforeEach(Turu.reset);

  it('matches if all the strings are also in the POST, but in a different order', function () {
    var r = [];
    on('movie', 'harry', 'sally', function () { r.push('When Harry Met Sally'); });
    post('sally', 'movie', 'harry');

    expect(r).toEqual(['When Harry Met Sally']);
  }); // === it

  it('does not match if POST-ed values contains unknown Strings', function () {
    var r = [];
    on('movie', '2001', function () { r.push('Dave'); });
    expect(function () {
      post('movie', '2001', '2010');
    }).toThrow(new Error('No Turu action found for: (string) "movie", (string) "2001", (string) "2010"'));
  }); // === it does not match if POST-ed values contains unknown Strings

}); // === describe String matching =================

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
    on(['good', 'happy'],             function () { r.push('one'); });
    on(['good', 'happy', 'positive'], function () { r.push('positive'); });

    post(['good','happy', 'positive']);

    expect(r).toEqual(['positive']);
  }); // === it does not match if posted Array has extra values

  it('does not match if POST-ed values include a mix of known, unknown Arrays', function () {
    var r = [];
    on(['good', 'happy'], function () { r.push('one'); });

    expect(function () {
      post(['good', 'happy'], ['one']);
    }).toThrow(new Error("No Turu action found for: (object) \"good,happy\", (object) \"one\""));
  }); // === it does not match if POST-ed values include a mix of known, unknown Arrays

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

    function is(tag) {
      return function (doc, meta) {
        return doc.tags && doc.tags[meta.nested_ons] === tag;
      };
    } // === func news

    on('news', function () {
      r.push('news');
      on(is('good'), function () {
        r.push('good');
        on(is('very'), function () { r.push('very'); });
      });
    }); // === on

    post('news', {tags: ['news', 'good', 'very']});

    expect(r).toEqual(['news', 'good', 'very']);
  }); // === it runs :on defined in callbacks based on matches

}); // === describe inner on =================
