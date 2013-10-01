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
      # im-obj.dep-value = 2


function common-tests
  that 'class imutable flag is on' ->
    expect ImClass.imutable .to.be.true
  that 'class values are accesible' ->
    expect ImClass.value .to.eql \value
  that 'class values are readonly' ->
    expect (-> ImClass.value = \other) .to.throw \value
  describe 'instance' ->
    before-each ->
      im-obj := new ImClass 1
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
    that 'methods are callable' ->
      expect im-proto.method! .to.eql \method-result
    that 'methods cannot be changed' ->
      expect (-> im-proto.method = -> void) .to.throw /read only/
    that 'new fields cannot be added' ->
      expect (-> im-proto.new-field = 1) .to.throw /not extensible/
