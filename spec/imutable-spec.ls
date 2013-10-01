'use strict'
require! {
  '../src/imutable'
  expect: \chai .expect
}
# expect = require \chai .use (require \sinon-chai) .expect

that = it
var ImClass, im-obj, im-proto, dep

describe 'on imutable class' ->
  describe 'w/ no modifiers' ->
    before-each ->
      ImClass := imutable class
        @value = \value
        (@v=0, @dep=value:0) ->
        vv: -> @v * 2
        method: -> \method-result
        dep-value:~
          -> @dep.value
          (v) -> @dep.value = v
    common-tests!
    describe 'outbound properties' ->
      before-each ->
        dep := value: 10
        im-obj := new ImClass 0, dep
      that 'getter returns depending object\'s value' ->
        expect im-obj.dep-value .to.eql dep.value
      that 'setter modifies depending object' ->
        im-obj.dep-value = 12
        expect im-obj.dep-value .to.eql 12

  describe 'w/ strict modifier' ->
    before-each ->
      ImClass := imutable \strict class
        @value = \value
        (@v=0, @dep=value:0) ->
        vv: -> @v * 2
        method: -> \method-result
        dep-value:~
          -> @dep.value
          (v) -> @dep.value = v
    common-tests!
    describe 'outbound properties' ->
      before-each ->
        dep := value: 10
        im-obj := new ImClass 0, dep
      that 'getter returns depending object\'s value' ->
        expect im-obj.dep-value .to.eql dep.value
      that 'setter is removed' ->
        set-property = -> im-obj.dep-value = 12
        expect set-property .to.throw /cannot set property/i

  describe 'w/ recursive modifier' ->
    before-each ->
      ImClass := imutable \recursive class
        @value = \value
        @nested = value: \nested-value
        (@v=0, @dep=value:0) ->
          Object.define-property @, \hiddenNested, value: value: \hidden-value
        vv: -> @v * 2
        method: -> \method-result
        dep-value:~
          -> @dep.value
          (v) -> @dep.value = v
    common-tests!
    that 'class nested value are readonly' ->
      expect (-> ImClass.nested.value = \other) .to.throw Error
    describe 'outbound properties' ->
      before-each ->
        dep := value: 10
        im-obj := new ImClass 0, dep
      that 'getter returns depending object\'s value' ->
        expect im-obj.dep-value .to.eql dep.value
      that 'depending object has __imutable__ flag' ->
        expect dep.__imutable__ .to.be.true
      that 'depending object property is readonly' ->
        change-dep-property = -> dep.value = \other
        expect change-dep-property .to.throw /read only/
    describe 'nested recursion' ->
      before-each ->
        dep := nested: value: 10
        im-obj := new ImClass 0, dep
      that 'nested object has __imutable__ flag' ->
        expect dep.nested.__imutable__ .to.be.true
      that 'nested object\'s property is readonly' ->
        set-nested-value = -> dep.nested.value = 13
        expect set-nested-value .to.throw /read only/
      that.skip 'hidden nested property has __imutable__ flag' ->
        expect im-obj.hidden-nested.__imutable__ .to.be.true

function common-tests
  that 'class __imutable__ flag is on' ->
    expect ImClass.__imutable__ .to.be.true
  that 'class values are accesible' ->
    expect ImClass.value .to.eql \value
  that 'class values are readonly' ->
    expect (-> ImClass.value = \other) .to.throw \value
  describe 'instance' ->
    before-each ->
      im-obj := new ImClass 1
    that 'has __imutable__ flag set' ->
      expect im-obj.__imutable__ .to.be.true
    that 'value properties are accesible' ->
      expect im-obj.v .to.eql 1
    that 'value properties are readonly' ->
      expect (-> im-obj.v = 2) .to.throw /read only/
    that 'value properties cannot be redefined' ->
      redefine-property = ->
        Object.define-property im-obj, \v, value: 3
      expect redefine-property .to.throw /cannot redefine/i
    that 'methods are callable' ->
      expect im-obj.vv! .to.eql 2
    that 'methods cannot be changed' ->
      expect (-> im-obj.vv = -> void) .to.throw /read only/
    that 'new fields cannot be added' ->
      expect (-> im-obj.new-field = 1) .to.throw /not extensible/
  describe 'prototype' ->
    before-each ->
      im-proto := ImClass::
    that 'has __imutable__ flag set' ->
      expect im-obj.__imutable__ .to.be.true
    that 'methods are callable' ->
      expect im-proto.method! .to.eql \method-result
    that 'methods cannot be changed' ->
      expect (-> im-proto.method = -> void) .to.throw /read only/
    that 'new fields cannot be added' ->
      expect (-> im-proto.new-field = 1) .to.throw /not extensible/
