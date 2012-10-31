do (_, Backbone) ->
  return unless Backbone?

  one = (args..., handler) ->
    fn = =>
      @off args..., fn
      handler.apply this, arguments

    @on args..., fn

  return if Backbone.Events.one?
  Backbone.Events.one = one
  for objName in ["Model", "Collection", "View", "Router", "History"]
    return if Backbone[objName]::one?
    _.extend Backbone[objName].prototype, Backbone.Events
