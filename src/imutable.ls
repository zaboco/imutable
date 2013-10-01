require! \surround-constructor

has-setter = (obj, prop) --> (obj.__lookup-setter__ prop)?
remove-setter = (obj, prop) --> Object.define-property obj, prop, set: void

remove-property-setters = (klass) ->
  proto = klass::
  Object.get-own-property-names proto
    .filter has-setter proto
    .for-each remove-setter proto

make-imutable = (obj, recursive=false) ->
  make-children-imutable obj, true if recursive
  obj.__imutable__ = yes
  Object.freeze obj

function make-children-imutable obj, recursive=false
  property-names = Object.keys obj
  property-names.for-each ~>
    make-imutable obj[it], recursive if typeof obj[it] is \object

imutable = (option, klass) ->
  [klass, option] = [option, ''] if typeof option is \function
  remove-property-setters klass if option is \strict
  make-imutable klass::
  im-klass = surround-constructor klass, after: ->
    make-imutable @, option is \recursive
    make-children-imutable @ if option is \recursive
  make-imutable im-klass, option is \recursive

module.exports = imutable
