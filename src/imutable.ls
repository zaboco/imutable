require! \surround-constructor

has-setter = (obj, prop) --> (obj.__lookup-setter__ prop)?
remove-setter = (obj, prop) --> Object.define-property obj, prop, set: void

remove-property-setters = (klass) ->
  proto = klass::
  Object.get-own-property-names proto
    .filter has-setter proto
    .for-each remove-setter proto

freeze-child-objects = (obj) ->
  Object.get-own-property-names @ .for-each ~>
    Object.freeze @[it] if typeof @[it] is \object

imutable = (option, klass) ->
  [klass, option] = [option, ''] if typeof option is \function
  remove-property-setters klass if option is \strict
  Object.freeze klass::
  im-klass = surround-constructor klass, after: ->
    Object.freeze @
    freeze-child-objects @ if option is \recursive
  Object.freeze im-klass <<< imutable: yes

module.exports = imutable
