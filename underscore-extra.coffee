result = _.result
entryMap =
  escape:
    '&': '&amp;'
    '<': '&lt;'
    '>': '&gt;'
    '"': '&quot;'
    "'": '&#x27;'
    '/': '&#x2F;'

entryMap.unescape = _.invert entryMap.escape

_.mixin
  in: (elem, obj) ->
    return false unless elem?
    return false unless obj?
    _elem = _ elem
    _obj = _ _(obj).result()
    if $.isPlainObject obj
      `elem in obj`
    else if _obj.isArray() or _obj.isString()
      !!~_obj.indexOf elem
    else
      false

  escape: (string, ignoreChar=[]) ->
    return '' unless string?
    keys = _(entryMap.escape).keys()
    _(ignoreChar).each (char) -> keys = _(keys).arrayDel char
    ('' + string).replace ///[#{keys.join ''}]///g, (match) ->
      entryMap.escape[match]

  unescape: (string, ignoreChar=[]) ->
    return '' unless string?
    keys = _(entryMap.escape).keys()
    _(ignoreChar).each (char) -> keys = _(keys).arrayDel entryMap.escape[char]
    ('' + string).replace ///[#{keys.join ''}]///g, (match) ->
      entryMap.unescape[match]

  result: (object, property) ->
    return result.apply _, arguments if object? and property?
    if _(object).isFunction() then object() else object

  sum: (array) ->
    _array = _ array
    return unless _array.isArray()
    _array.reduce (result, number) ->
      result + number

  hasProp: (obj, attrList, any) ->
    _(attrList).chain().map((attr) ->
      _(obj).has(attr) and obj[attr]?
    )[`any? "any": "all"`](_.identity).value()

  arrayDel: (array, obj) ->
    index = _(array).indexOf obj
    return if !~index
    newArray = _.clone array
    newArray.splice index, 1
    newArray

  split: (obj, spliter) ->
    return obj.split(spliter) if _.isString obj
    return [] unless _.isArray obj
    memo = []
    cloneThis = _(obj).clone()
    cloneThis.push spliter
    _(cloneThis).chain().map (elem) ->
      if _(elem).isEqual spliter
        [clone, memo] = [memo, []]
        return clone
      else
        memo.push elem
        return
    .filter (elem) ->
      elem? and elem.length
    .value()

  resultWithArgs: (obj, property, args, context) ->
    return unless obj?
    value = obj[property]
    context or= obj
    if _.isFunction value
      value.apply context, args
    else
      value
