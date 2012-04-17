((window, document)->
  [OP, AP] = [Object.prototype, Array.prototype]
  slice = AP.slice
  toString = OP.toString
  hasOwn = OP.hasOwnProperty

  window.G = G = (queryId) ->
    document.getElementById queryId

  class2type = {} # 用于 G.toType 函数, 根据对象的 toString 输出得到对象的类型
  dumpFnDict = {} # 存储 dump 类函数，便于动态调用
  getInt = (str, hex=10) ->
    return 0 if str = ""
    parseInt str, hex
  
  'Arguments Function Number String Date RegExp Array Boolean Object'.replace /[^, ]+/g, (typeName) ->
    class2type["[object #{typeName}]"] = typeName.toLowerCase()
    G["is#{typeName}"] = (obj) -> toString.call(obj) is "[object #{typeName}]"

  G.extend = (target, origin) ->
    [target, origin] = [G, target] unless origin?
    (target[attr] = origin[attr] if origin[attr]?) for attr of origin
    target

  G.extend
    t: (tagName) -> document.getElementsByTagName tagName

    has: (obj, attr) -> hasOwn.call obj, attr
    toType: (obj) -> unless obj? then String obj else class2type[toString.call obj] or "object"
    toArray: (obj) -> #form underscore
      return [] unless obj?
      return slice.call obj if G.isArray obj
      return slice.call obj if G.isArguments obj
      return obj.toArray() if obj.toArray? and G.isFunction obj.toArray
      v for k, v of obj

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

    arr2str: dumpFnDict.Array2str = (arr) ->
      resultStr = "["
      for v in arr
        resultStr += "#{G.dump v},"
      resultStr.slice(0, -1) + "]"

    obj2str: dumpFnDict.Object2str = (obj) ->
      resultStr = "{"
      for k, v of obj
        if G.has obj, k
          resultStr += "#{G.dump k}:#{G.dump v},"
      resultStr.slice(0, -1) + "}"

    dump: (obj) ->
      dumpFnDict["String2str"] = (string) ->
        if G.isString string then '"' + string + '"' else string
      for type in ["Object", "Array", "String"]
        return dumpFnDict["#{type}2str"] obj if G["is#{type}"] obj
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
          console.log "jsonp state: ", jsonpTag.readyState
          headElem.removeChild jsonpTag
      queryData["callback"] = funcName
      jsonpTag.type = "text/javascript"
      jsonpTag.src = url + "?" + queryStr
      headElem.appendChild jsonpTag

  G.localStorage = ((window)->
    ls = window.localStorage
    cookieDay = 30
    useCookie = false

    getCookie = (key) ->
      re = new RegExp("\\??" + key + "=([^;]*)", "g")
      if [result = re.exec document.cookie][0]? then unescape(result[1]) else []._

    setCookie = (key, value) ->
      cookieStr = "#{key}=#{escape value}"
      [exp = new Date()][0].setTime exp.getTime() + 30 * 24 * 60 * 60 * 1000
      cookieStr += ";expires=#{exp.toGMTString()};path=/"
      document.cookie = cookieStr

    getLocalStorage = (key) -> ls[key]
    setLocalStorage = (key, value) -> ls[key] = value

    [getMethod, setMethod] = if ls? then [getLocalStorage, setLocalStorage] else [getCookie, setCookie]

    # ls.get ['id1', 'id2', 'id3']
    # ls.get 'id1', 'id2', 'id3'
    get: ->
      getMethod = getCookie if useCookie
      args = if G.isArray arguments[0] then arguments[0] else G.toArray arguments
      return getMethod args[0] if args.length is 1
      result = {}
      for storageKey in args
        storageValue = getMethod storageKey
        result[storageKey] = storageValue if storageValue?
      result

    # ls.set {k1: v1, k2: v2, k3: v3}
    # ls.set k1, v1
    set: ->
      setMethod = setCookie if useCookie
      if G.isObject arguments[0]
        setMethod key, value for key, value of arguments[0]
      else
        [key, value] = arguments
        setMethod key, value if key? and value?
      this

    useCookie: (bool) -> useCookie = bool
    cookieDay: (day) -> cookieDay = getInt day
  ) window

) window, document
