# imutable
[![Build Status](https://travis-ci.org/zaboco/imutable.png?branch=master)](https://travis-ci.org/zaboco/imutable)

Makes a class and its instances imutable

## Install

```sh
$ npm install imutable [--save]
```

## Usage

```ls
require! \imutable

ImClass = imutable class
  (@value = 0) ->

im-obj = new ImClass 1
console.log im-obj.value # 1

im-obj.value = 2 # does nothing, or throws error in strict mode
console.log im-obj.value # 1, if not in strict mode
```

## Modes

By default, `imutable` [freezes](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Object/freeze) the class, the prototype, as well as any new instance. So, no properties can be changed, removed or added to any of these.

There are also some advanced use cases when a property/method depends on another object. For example:

```ls
dep = value: 1
ImClass = imutable class
  -> @dep = dep
  dep-value:~
    -> @dep.value
    (v) -> @dep.value = v

im-obj = new ImClass

console.log im-obj.dep-value # 1
im-obj.dep-value = 2
console.log im-obj.dep-value # 2 !!!
```
So, this object is not so imutable after all. That's because [`Object.freeze`](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Object/freeze) does not remove property setters.

In this case you can use `imutable \strict`, which does exactly that, removes all setters.

### Strict

In the above example, by creating the class like
```ls
ImClass = imutable \strict class
...
```
the line
```ls
im-obj.dep-value = 2
```
would have no effect (or throw an error if strict)

------
Another example using a depending object is when you use methods for getters and setters instead of property accessors
```ls
dep = value: 1
ImClass = imutable class
  -> @dep = dep
  set-dep-value: (v) -> @dep.value = v
  get-dep-value: -> @dep.value

im-obj = new ImClass

console.log im-obj.get-dep-value! # 1
im-obj.set-dep-value 2
console.log im-obj.get-dep-value! # 2 !!! again
```

Then the solution would be to make all of the children (recursively) imutable. That's what `\recursive` mode does

### Recursive

Creating the class like this
```ls
ImClass = imutable \recursive class
```
makes all the object's successors imutable. So calling `im-obj.set-dep-value 2` would again do nothing.
