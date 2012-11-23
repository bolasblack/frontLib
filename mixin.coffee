###
usage:

```coffeescript
class Model extends Backbone.Model
  _initializeCallStack: undefined
  _inited: false

  mixinObjects: undefined
  mixin: (object) ->
    mixin this, object,
      instead: true
      beforeMixin: (property, value) =>
        return if property isnt "initialize"
        if @_inited
          value? this, @options
        else
          @_initializeCallStack.push value
        false

  constructor: (attributes) ->
    @_initializeCallStack = []
    @mixin(mixinObj) for mixinObj in @mixinObjects or []

    initialize = @initialize
    @initialize = (options) =>
      for fu in @_initializeCallStack
        fn.apply this, arguments
      initialize.apply this, arguments
      @_inited = true

    super
```
###

module.exports = mixin = (target, source, options) ->
  options = $.extend
    runFuncBeforeAll: true
    beforeMixin: noop
    instead: false
  , options

  noop = ->

  mixinFunction = (property, value, oldValue) ->
    target[property] = (args...) ->
      if options.runFuncBeforeAll
        result = value.apply target, args.concat oldValue
        return result if options.instead
        (oldValue ? noop).apply target, args
      else
        result = (oldValue ? noop).apply target, args
        if options.instead
          value.apply target, args.concat oldValue
        else
          result

  mixinValue = (property, value, oldValue) ->
    target[property] = value
    if oldValue? and not options.instead
      target["old_#{property}"] = oldValue

  for own property, value of source
    result = options.beforeMixin property, value
    continue if result is false
    mixinMethod = if _.isFunction(value) then mixinFunction else mixinValue
    mixinMethod property, value, target[property]
