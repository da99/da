"use strict";
/* jshint undef: true, unused: true */
/* global Turu, describe, it, expect, beforeEach */ 

describe('Turu: .middle', function () {

  beforeEach(Turu.reset);

  it('runs the code', function () {
    var v = 0;
    Turu.middle(function (data) {
      if (_.isMatch(data, {action: 'family'}))
        v = data.value;
    });
    Turu.run({action: 'family', value: 'Simpsons'});
    expect(v).toEqual('Simpsons');
  });

}); // === describe Turu: .middle

describe('Turu: .bottom:', function () {

  beforeEach(Turu.reset);

  it('runs the code after middle functions', function () {
    var v = [];

    Turu.bottom(function (data) {
      if (_.isMatch(data, {action: 'movie'}))
        v.push(data.value + ' last');
    });

    Turu.middle(function (data) {
      if (_.isMatch(data, {action: 'movie'}))
        v.push(data.value + ' middle');
    });

    Turu.run({action: 'movie', value: 'Simpsons'});
    expect(v).toEqual(['Simpsons middle', 'Simpsons last']);
  });

}); // === describe Turu: .bottom =================


