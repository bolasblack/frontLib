window.G?.localStorage = ((window) ->
  ls = window.localStorage
  ss = window.sessionStorage
  useCookie = false
  useSession = false
  storageTime = "30d"

  getInt = (str, hex=10) ->
    return 0 if str is ""
    parseInt str, hex

  # s指秒，m指秒，h指小时，d指天数
  # 如30d代表30天，setCookie "name","hayden","20s"
  setCookie = (key, value, time) ->
    getTime = (str) ->
      timeCount = getInt "#{str}".slice 0, -1
      timeUnit = str.substr -1
      useSession = false
      switch timeUnit
        when "s" then timeCount * 1000
        when "m" then timeCount * 60 * 1000
        when "h" then timeCount * 60 * 60 * 1000
        when "d" then timeCount * 24 * 60 * 60 * 1000
        else useSession = true

    outTime = getTime time
    cookieStr = "#{key}=#{escape value}"
    currTime = (exp = new Date()).setTime exp.getTime() + outTime
    cookieStr += ";expires=#{exp.toGMTString()}" unless useSession
    cookieStr += ";path=/"
    document.cookie = cookieStr

  getCookie = (key) ->
    re = new RegExp("\\??" + key + "=([^;]*)", "g")
    if (result = re.exec document.cookie)? then unescape(result[1]) else null

  delCookie = (key) ->
    cookieValue = getCookie key
    setCookie key, cookieValue, "-1d"

  getLocalStorage = (key) ->
    storage = if useSession then ss else ls
    storage[key]
  setLocalStorage = (key, value) ->
    storage = if useSession then ss else ls
    storage[key] = value
  delLocalStorage = (key) ->
    storage = if useSession then ss else ls
    delete storage[key]

  [setMethod, getMethod, delMethod] = if ls? then \
    [setLocalStorage, getLocalStorage, delLocalStorage] else \
    [setCookie, getCookie, delCookie]

  doActionLoop = (actMethod, args) ->
    realArgs = if G.isArray args[0] then args[0] else G.toArray args
    return actMethod realArgs[0] if realArgs.length is 1
    result = {}
    for storageKey in realArgs
      storageValue = actMethod storageKey
      result[storageKey] = storageValue if storageValue?
    result

  # ls.set {k1: v1, k2: v2, k3: v3}
  # ls.set k1, v1
  set: ->
    setMethod = setCookie if useCookie
    if G.isObject arguments[0]
      setMethod key, value, storageTime for key, value of arguments[0]
    else
      [key, value] = arguments
      setMethod key, value, storageTime if key? and value?
    this

  # ls.get ['id1', 'id2', 'id3']
  # ls.get 'id1', 'id2', 'id3'
  get: ->
    getMethod = getCookie if useCookie
    doActionLoop getMethod, arguments

  # same as get()
  del: ->
    delMethod = delCookie if useCookie
    doActionLoop delMethod, arguments
    this

  storageTime: (time) ->
    return `useSession = true, this` if getInt(time) in [0, NaN]
    time = "#{time}s" if G.isNumber time
    return `useSession = false, this` if time.slice(-1) in ["s", "m", "h", "d"]
    [storageTime, useSession] = [time, false]
    this

  useCookie: (boolInput) ->
    return useCookie unless boolInput?
    useCookie = boolInput
    this

) window
