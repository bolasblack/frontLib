((window, document)->
  [OP, AP] = [Object.prototype, Array.prototype]
  toString = OP.toString
  hasOwn = OP.hasOwnProperty

  window.G = G = (queryId) ->
    document.getElementById queryId

  tmpObj = {}
  class2type = {}
  
  'Arguments Function Number String Date RegExp Array Boolean Object'.replace /[^, ]+/g, (typeName) ->
    class2type["[object #{typeName}]"] = typeName.toLowerCase()
    G["is#{typeName}"] = (obj) ->
      toString.call(obj) is "[object #{typeName}]"

  G.extend = (target, origin) ->
    [target, origin] = [G, target] unless origin?
    (target[attr] = origin[attr] if origin[attr]?) for attr of origin
    target

  G.extend
    t: (tagName) -> document.getElementsByTagName tagName

    has: (obj, attr) -> hasOwn.call obj, attr
    toType: (obj) -> unless obj? then String obj else class2type[toString.call obj] or "object"

    isWindow: (obj) -> obj is obj.window
    isNode: (obj) -> obj.nodeType?
    isObject: (obj) -> #from jquery 1.7.3 pre
      return false if !obj or G.toType(obj) isnt "object" or obj.nodeType or G.isWindow(obj)
      try
        return false if obj.constructor and !G.has(obj, "constructor") and !G.has(obj.constructor.prototype, "isPrototypeOf")
      catch e
        return false
      key for key of obj
      key is undefined or G.has obj, key

    localStorage: (->
      ls = window.localStorage

      # ls.get ['id1', 'id2', 'id3']
      # ls.get 'id1', 'id2', 'id3'
      get: ->
        args = if G.isArray arguments[1] then arguments[1] else G.toArray(arguments).slice(1)
        return ls[args[0]] if args.length is 1
        result = {}
        for storageKey in args
          result[storageKey] = window.localStorage[storageKey]
        result

      # ls.set {k1: v1, k2: v2, k3: v3}
      # ls.set k1, v1
      set: ->
        if G.isObject arguments[1]
          for key, value of arguments[1]
            ls[key] = value
        else if [key = arguments[1]][0]? and [value = arguments[2]][0]?
          ls[key] = value
        this
    )()

    arr2str: tmpObj.Array2str = (arr) ->
      resultStr = "["
      for v in arr
        resultStr += "#{G.dump v},"
      resultStr.slice(0, -1) + "]"

    obj2str: tmpObj.Object2str = (obj) ->
      resultStr = "{"
      for k, v of obj
        if G.has obj, k
          resultStr += "#{G.dump k}:#{G.dump v},"
      resultStr.slice(0, -1) + "}"

    dump: (obj) ->
      tmpObj["String2str"] = (string) ->
        if G.isString string then '"' + string + '"' else string
      for type in ["Object", "Array", "String"]
        return tmpObj["#{type}2str"] obj if G["is#{type}"] obj
      obj

    param: (obj) ->
      queryArray = []
      tmpStr = ""
      for attr, value of obj
        tmpStr = encodeURIComponent(attr) + "=" + encodeURIComponent(G.dump value)
        queryArray.push tmpStr
      return queryArray.join "&"

    jsonp: (url, queryData, callback) ->
      jsonpTag = document.createElement "script"
      headElem = document.head || document.getElementsByTagName('head')[0] || document.documentElement
      funcName = "jsonp" + new Date().getTime()
      queryStr = ""

      if [queryType = typeof queryData][0] is "object"
        queryStr = @param queryData
      else if typeof queryType is "string"
        queryStr = encodeURIComponent queryData
      else unless callback?
        [callback, queryData] = [queryData, null]

      window[funcName] = (data) -> callback data
      jsonpTag.onload = jsonpTag.onerror = jsonpTag.onreadystatechange = ->
        if /loaded|complete|undefined/.test jsonpTag.readyState
          jsonpTag.onload = jsonpTag.onerror = jsonpTag.onreadystatechange = null
          headElem.removeChild jsonpTag
      queryData["callback"] = funcName
      jsonpTag.type = "text/javascript"
      jsonpTag.src = url + "?" + queryStr
      headElem.appendChild jsonpTag
) window, document
