define (require, exports, module) ->
    _ = require('underscore')

    # ls.get ['id1', 'id2', 'id3']
    # ls.get 'id1', 'id2', 'id3'
    get: ->
        args = if _.isArray arguments[1] then arguments[1] else _.toArray(arguments).slice(1)
        return window.localStorage[args[0]] if args.length is 1
        result = {}
        _.each args, (storageKey) ->
            result[storageKey] = window.localStorage[storageKey]
        return result

    # ls.set
    #     id1: key1
    #     id2: key2
    #     id3: key3
    set: ->
        if _.isObject arguments[1]
            _.each arguments[1], (value, key) ->
                window.localStorage[key] = value
            @