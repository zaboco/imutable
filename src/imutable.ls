require! \surround-constructor

has-setter = (obj, prop) --> (obj.__lookup-setter__ prop)?
remove-setter = (obj, prop) --> Object.define-property obj, prop, set: void

remove-property-setters = (klass) ->
  klass::
    Object.get-own-property-names ..
      .filter has-setter ..
      .for-each remove-setter ..

function make-imutable obj, {recursive=false, hidden=false} = {}
  make-children-imutable obj, {+recursive, hidden} if recursive
  obj.__imutable__ = yes
  Object.freeze obj

function make-children-imutable obj, {recursive=false, hidden=false} = {}
  property-names = switch
    | hidden => Object.get-own-property-names obj
    | _ => Object.keys obj
  property-names.for-each ~>
    make-imutable obj[it], {recursive, hidden} if typeof obj[it] is \object

imutable = (option, klass) ->
  [klass, option] = [option, ''] if typeof option is \function
  recursive = option is \recursive
  remove-property-setters klass if option is \strict
  make-imutable klass::
  im-klass = surround-constructor klass, after: ->
    make-imutable @, {recursive, +hidden}
  make-imutable im-klass, {recursive}

module.exports = imutable
