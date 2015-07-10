"use strict";
/* jshint undef: true, unused: true */
/* global Turu, describe, it, expect, beforeEach */ 

describe('Turu: data.like', function () {

  beforeEach(Turu.reset);

  it('returns true on a match', function () {
    var v = 0;
    Turu.push(function (data) {
      if (data.like({action: 'family'})) {
        v = data.value;
      }
    });
    Turu.run({action: 'family', value: 'Simpsons'});
    expect(v).toEqual('Simpsons');
  });

  it('returns false on a mis-match', function () {
    var v = 0;
    Turu.push(function (data) {
      if (data.like({action: 'tv'})) {
        v = data.value;
      }
    });
    Turu.run({action: 'movie', value: 'Die Hard'});
    expect(v).toEqual(0);
  });

}); // === describe Turu


describe('Turu: data.not_like', function () {

  beforeEach(Turu.reset);

  it('returns true on a mis-match', function () {
    var v = 0;
    Turu.push(function (data) {
      v = data.not_like({place: 'La Forge'});
    });
    Turu.run({place: 'Grand Canyon'});
    expect(v).toEqual(true);
  });

  it('returns false on a match', function () {
    var v = 0;
    Turu.push(function (data) {
      v = data.not_like({place: 'Vineyard'});
    });
    Turu.run({place: 'Vineyard'});
    expect(v).toEqual(false);
  });

}); // === describe Turu
