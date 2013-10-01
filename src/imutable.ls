require! \surround-constructor

has-setter = (obj, prop) --> (obj.__lookup-setter__ prop)?
remove-setter = (obj, prop) --> Object.define-property obj, prop, set: void

remove-property-setters = (klass) ->
  proto = klass::
  Object.get-own-property-names proto
    .filter has-setter proto
    .for-each remove-setter proto

make-imutable = (obj) ->
  obj.__imutable__ = yes
  Object.freeze obj

freeze-child-objects = (obj) ->
  Object.get-own-property-names obj .for-each ~>
    make-imutable obj[it] if typeof obj[it] is \object

imutable = (option, klass) ->
  [klass, option] = [option, ''] if typeof option is \function
  remove-property-setters klass if option is \strict
  make-imutable klass::
  im-klass = surround-constructor klass, after: ->
    Object.freeze @
    freeze-child-objects @ if option is \recursive
  make-imutable im-klass

module.exports = imutable
