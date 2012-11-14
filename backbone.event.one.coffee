do (_, Backbone) ->
  return unless Backbone?

  one = (events, handler, context, whenFilter) ->
    if _.isFunction(context)
      whenFilter = context
      context = this

    context ?= this
    whenFilter ?= -> true

    fn = =>
      return unless whenFilter.apply context, arguments
      @off events, fn, context
      handler.apply context, arguments

    @on events, fn, context

  return if Backbone.Events.one?
  Backbone.Events.one = one
  for objName in ["Model", "Collection", "View", "Router", "History"]
    return if Backbone[objName]::one?
    _.extend Backbone[objName].prototype, Backbone.Events
