((window, document)->
  [OP, AP] = [Object.prototype, Array.prototype]

  G = (queryId) -> document.getElementById queryId
  G.t = (tagName) -> document.getElementsByTagName tagName

  if window["define"]?
    define (require, exports, module) -> G
  else
    G.old = window.G if window.G?
    window.G = G

  # [[[ utils
  slice = AP.slice
  toString = OP.toString
  hasOwn = OP.hasOwnProperty

  class2type = {} # 用于 G.toType 函数, 根据对象的 toString 输出得到对象的类型
  'Arguments Function Number String Date RegExp Array Boolean Object'.replace /[^, ]+/g, (typeName) ->
    class2type["[object #{typeName}]"] = typeName.toLowerCase()
    G["is#{typeName}"] = (obj) -> toString.call(obj) is "[object #{typeName}]"
  unless G.isArguments arguments
    G.isArguments = (obj) ->
      !!(obj and G.has obj, "callee")

  G.extend = -> #form jquery 1.7.3 pre
    target = arguments[0] or {}
    length = arguments.length
    deep = false
    i = 1
    if G.isBoolean target
      deep = target
      target = arguments[1]
      i = 2
    target = {} if typeof target isnt "object" and not G.isFunction target
    [target, i] = [this, i - 1] if length is i
    for i in [i...arguments.length]
      if (options = arguments[i])?
        for name, copy of options
          src = target[name]
          continue if target is copy
          if deep and copy and (G.isPlainObject(copy) or (copyIsArray = G.isArray copy))
            if copyIsArray
              copyIsArray = false
              clone = src and if G.isArray src then src else []
            else
              clone = src and if G.isPlainObject src then src else {}
            target[name] = G.extend deep, clone, copy
          else if copy isnt undefined
            target[name] = copy
    target

  G.extend
    toType: (obj) -> unless obj? then String obj else class2type[toString.call obj] or "object"

    isWindow: (obj) -> obj? and obj is obj.window
    isNode: (obj) -> obj.nodeType?
    isElement: (obj) -> obj? and obj.nodeType is 1
    isFinite: (obj) -> G.isNumber(obj) and isFinite obj
    isObject: (obj) -> obj is Object obj
    isNaN: (obj) -> obj isnt obj
    isNull: (obj) -> obj is null
    isUndefined: (obj) -> obj is undefined
    isEmpty: (obj) ->
      return true unless obj?
      return obj.length is 0 if G.isArray(obj) or G.isString obj
      (return false if G.has obj, key) for key of obj
      true
    isPlainObject: (obj) -> #from jquery 1.7.3 pre
      return false if !obj or G.toType(obj) isnt "object" or obj.nodeType or G.isWindow(obj)
      try
        return false if obj.constructor and !G.has(obj, "constructor") and !G.has(obj.constructor.prototype, "isPrototypeOf")
      catch e
        return false
      key for key of obj
      key is undefined or G.has obj, key

  G.extend
    has: (obj, attr) -> hasOwn.call obj, attr
    toArray: (obj) -> #form underscore
      return [] unless obj?
      return slice.call obj if G.isArray obj
      return slice.call obj if G.isArguments obj
      return obj.toArray() if obj.toArray? and G.isFunction obj.toArray
      v for k, v of obj
  # ]]]

  # [[[ String
  G.extend
    splTpl: (tpl, data) ->
      tpl.replace /{{(.*?)}}/igm, ($, $1) ->
        if data[$1] then data[$1] else $

    reEscape: (str) ->
      str.replace(/\\/g, "\\\\")
        .replace(/\//g, "\\/").replace(/\,/g, "\\,").replace(/\./g, "\\.")
        .replace(/\^/g, "\\^").replace(/\$/g, "\\$").replace(/\|/g, "\\|")
        .replace(/\?/g, "\\?").replace(/\+/g, "\\+").replace(/\*/g, "\\*")
        .replace(/\[/g, "\\[").replace(/\]/g, "\\]")
        .replace(/\{/g, "\\{").replace(/\}/g, "\\}")
        .replace(/\(/g, "\\(").replace(/\)/g, "\\)")

    charUpperCase: (index, length=1) ->
      strList = @split ''
      for i in [0...length]
        newIndex = index + i
        strList[newIndex] = strList[newIndex].toUpperCase()
      strList.join ''

    getDelta: (oldStr, newStr) ->
      resultList = []
      delta = ''
      delingIndex = 0
      contr = (oldStr, newStr, index) ->
        while newStr[index] isnt oldStr[index]
          delta += newStr[index]
          newStr = newStr.remove index
      deling = (oldStr, newStr, index) ->
        if newStr[index] not in oldStr
          oldStr = oldStr.remove(delingIndex)
          newStr = newStr.remove(index)
          deling index
      for i in newStr
        deling i if oldStr.length
      [oldStr, newStr]
  # ]]]

  # [[[ ajax
  dumpFnDict = {} # 存储 dump 类函数，便于动态调用
  G.extend
    arr2str: dumpFnDict.Array2str = (arr) ->
      resultStr = "["
      for v in arr
        resultStr += "#{G.dump v},"
      resultStr.slice(0, -1) + "]"

    obj2str: dumpFnDict.Object2str = (obj) ->
      resultStr = "{"
      for k, v of obj
        resultStr += "#{G.dump k}:#{G.dump v}," if G.has obj, k
      resultStr.slice(0, -1) + "}"

    dump: (obj) ->
      dumpFnDict["String2str"] = (string) ->
        if G.isString string then '"' + string + '"' else string
      for type in ["Object", "Array", "String"]
        return dumpFnDict["#{type}2str"] obj if G["is#{type}"] obj
      obj

    param: (obj) ->
      ("#{encodeURIComponent key}=#{encodeURIComponent G.dump value}" \
        for key, value of obj).join "&"

    getParam: (url, key) ->
      key = G.reEscape key
      re = new RegExp "\\??" + key + "=([^&]*)", "g"
      result = re.exec url
      if result? and result.length > 1
        decodeURIComponent result[1]
      else
        ""
  # ]]]

  # [[[ stylesheets
  indexOf = AP.indexOf
  classRe = (className) ->
    new RegExp "(\\s+#{className}|\\s+#{className}\\s+|#{className}\\s+)", "g"

  G.extend
    addClass: (elem, className) ->
      elemClass = "#{elem.getAttribute("class") or ""} "
      unless elemClass.match(classRe(className))?
        elem.setAttribute "class", elemClass + className
      this

    removeClass: (elem, className) ->
      elemClass = elem.getAttribute("class") or ""
      elem.setAttribute "class", elemClass.replace classRe(className), ""
      this

    getCSS : (elem, styleName) ->
      elemStyle = if document.defaultView? \
        then document.defaultView.getComputedStyle elem \
        else elem.currentStyle
      unless styleName? then elemStyle else \
        if styleName isnt "float" then elemStyle[styleName] \
          else elemStyle["cssFloat"] or elemStyle["styleFloat"]
      this

    setCSS: (elem, styleName, styleValue) ->
      elemStyle = elem.style
      # TODO: 在 IE6 IE8 中测试
      elemStyle.cssText = elemStyle.cssText.replace new RegExp("#{styleName}\s:.*;+\s", "g"), ""
      elemStyle.cssText += "#{styleName}: #{styleValue};"
      this
  # ]]]

) window, document
