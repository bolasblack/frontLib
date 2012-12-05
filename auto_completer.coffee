if (not ($ = @jQuery)?.fn?) and require?
  $ = require 'jquery'
return unless $?.fn?

lastIndexOf = Array::lastIndexOf or (searchvalue, start) ->
  for i in [@length...1] when (item = this[i]) is searchvalue
    return i
  -1

getInt = (str) -> parseInt str, 10

###
 * selector {String|Element|jQuery instance} textarea, 可以是选择器，jquery对象，DOM对象
 * options {Hash}
    debugMode:       {Boolean} 是否启动 debug 模式，会显示 mirror 元素, 默认为 false
    mirrorContainer: {String|jQuery instance} mirror 的容器，默认为 textarea 的父元素
    cloneStyle:      {Array} 要从 textarea 克隆的样式，默认见 AutoCompleter::cloneStyle
    flags:           {Array} 会触发 ac.trigger 的符号，默认见 AutoCompleter::flags
    hiddenChars:     {Array} 会触发 ac.hidden 的符号，默认见 AutoCompleter::hiddenChars
    checkEvents":    {Array} 会触发检查行为的事件，默认见 AutoCompleter::checkEvents
    mirrorStyle:     {Hash} mirror 的额外样式，默认见 AutoCompleter::mirrorStyle
###
class AutoCompleter
  cloneStyle: [
    "font-size", "font-family", "line-height", "text-align"
    "letter-spacing", "word-wrap", "width", "box-sizing"
    # firefox cann't get $el.css("padding")
    "padding-left", "padding-right", "padding-top", "padding-bottom"
    # firefox cann't get $el.css("border-width")
    "border-left-width", "border-right-width"
    "border-top-width", "border-bottom-width"
  ]

  checkEvents: ["keydown", "keyup", "click", "focus"]
  hiddenChars: ["\n", " "]
  flags: ["@"]
  mirrorStyle:
    "position": "absolute"
    "z-index": "-1000"
    "visibility": "hidden"
    "background-color": "#aaa"

  triggerd: false
  _lastHeight: null

  constructor: (selector, options) ->
    if typeof selector is "string" or (selector? and selector.nodeType is 1)
      $textarea = $ selector
    else if selector instanceof $
      $textarea = selector
    else
      $textarea = []
    unless $textarea.length
      throw new Error "not support selector"
    unless $textarea[0].tagName is "textarea".toUpperCase()
      throw new Error "not support element"

    @$textarea = $textarea
    @_processOption options
    @$textarea.data "AutoCompleter", this
    @startObserve()

  triggerHidden: ->
    return if @disposed
    @$textarea.trigger "ac.hidden"

  escapeContent: (content) ->
    content
      .replace(/\r\n/g, "<br>")
      .replace /\n/g, "<br/>"

  checkTriggerShow: (event) =>
    @$mirror = @_createMirror()
    triggerdPos = -1
    triggerdChar = ""
    if (lastTrigger = @_checkTrigger())
      @triggerd = true
      triggerdChar = lastTrigger.char
      triggerdPos = lastTrigger.pos
      triggerHtml = $("<span>", class: "ac-flags").text triggerdChar
      otherHtml = @escapeContent @$textarea.val().substring 0, triggerdPos - 1
      @$mirror.html(otherHtml).append triggerHtml
    #else unless @triggerd
      #@$mirror.html ""

    return unless @triggerd
    @_adjustMirror()
    @_trigger triggerdChar, triggerdPos

  computeContentHeight: (event={}) ->
    @$mirror = @_createMirror()
    content = @_forecastContent @$textarea.val(), event
    @$mirror.html @escapeContent content
    paddingTop = getInt @$mirror.css "padding-top"
    paddingBottom = getInt @$mirror.css "padding-bottom"
    height = paddingTop + paddingBottom + @$mirror.height()
    if @_lastHeight isnt height
      event = $.Event "ac.resize"
      event.height = height
      @$textarea.trigger event
    @_lastHeight = height

  startObserve: ->
    return if @disposed
    events = _(@checkEvents).map((event) -> "#{event}.acdefined").join " "
    @$textarea
      .on(events, $.proxy @checkTriggerShow, this)
      .on "keyup.acdefined keydown.acdefined", $.proxy @computeContentHeight, this

  finishObserve: ->
    return if @disposed
    @$textarea.off ".acdefined"
    @triggerHidden()
    @triggerd = false

  disposed: false
  dispose: ->
    return if @disposed

    @finishObserve()
    @$textarea.data "AutoCompleter", null
    @$mirror?.remove()
    for attr in ["$mirrorContainer", "$textarea", "$mirror"]
      delete this[attr]

    @disposed = true
    Object.freeze? this

  getCursor: -> @constructor.getCursor @$textarea
  setCursor: (pos) -> @constructor.setCursor @$textarea, pos
  getSelected: -> @constructor.getSelected @$textarea
  insertCursor: (value) -> @constructor.insertCursor @$textarea, value
  getInputed: (triggerdPos) -> @constructor.getInputed @$textarea, triggerdPos
  getLastTrigger: (cursorPos) ->
    @constructor.getLastTrigger @$textarea, cursorPos, @flags, @hiddenChars

  _forecastContent: (content, event) ->
    # enter key, too late if work in keyup
    if event.type is "keydown" and event.keyCode is 13
      content += "\n"
    content + "1"

  _trigger: (triggerdChar, triggerdPos) ->
    return if @disposed
    event = jQuery.Event "ac.trigger"
    event.trigger = triggerdChar
    event.inputed = @getInputed triggerdPos
    event.offset = @$mirror.find(".ac-flags").offset()
    event.triggerdPos = triggerdPos
    @$textarea.trigger event

  _checkTrigger: ->
    lastTrigger = @getLastTrigger()
    unless lastTrigger.pos
      @triggerHidden()
      @triggerd = false
      return false
    lastTrigger

  _processOption: (options) ->
    return unless options
    selector = options.mirrorContainer
    @$mirrorContainer = if selector instanceof $ then selector \
      else if typeof selector is "string" then $ selector
      else @$textarea.parent()

    optionsName = [
      "cloneStyle", "flags", "hiddenChars"
      "mirrorStyle", "checkEvents"
    ]
    for argName in optionsName
      this[argName] = options[argName] if options[argName]?
    @options = options

  _adjustMirror: ->
    containerOffset = @$mirrorContainer.offset()
    offset = @$textarea.offset()

    originalHtml = @$mirror.html()
    @$mirror.html "&nbsp;"
    shim = parseInt @$mirror.outerHeight(), 10
    @$mirror.html originalHtml

    @$mirror.css
      "top": offset.top - containerOffset.top + shim
      "left": offset.left - containerOffset.left

  _createMirror: ->
    @$mirror.remove() if @$mirror?
    mirrorID = $.now()
    $mirror = $ "<div>", class: "ac-mirrors ac-mirror#{mirrorID}"
    targetStyle = $.extend {}, @mirrorStyle
    for styleName in @cloneStyle
      targetStyle[styleName] = @$textarea.css styleName
    @$mirrorContainer.css "position", "relative"
    $mirror.css(targetStyle).appendTo @$mirrorContainer
    if @options.debugMode
      $mirror.css "visibility": "visible", "z-index": "1"
    $mirror

  @isW3C = $("<textarea>")[0].selectionStart?
  # w3c http://www.w3.org/TR/2009/WD-html5-20090423/editing.html#selection
  # document.selection http://qingfeng825.iteye.com/blog/259099

  # from http://js8.in/466.html
  @getCursor = ($textarea) ->
    caretPos = 0
    if @isW3C
      caretPos = $textarea[0].selectionStart
    else if document.selection
      $textarea.focus()
      range = document.selection.createRange()
      range.moveStart "character", -$textarea.val().length
      caretPos = range.text.length
    caretPos

  @setCursor = ($textarea, pos) ->
    if @isW3C
      $textarea.focus()
      $textarea[0].setSelectionRange pos, pos
    else if $textarea[0].createTextRange
      range = $textarea.createTextRange()
      range.collapse true
      range.moveEnd "character", pos
      range.moveStart "character", pos
      range.select()

  # from http://js8.in/538.html
  @insertCursor = ($textarea, value) ->
    textarea = $textarea[0]
    if @isW3C
      startPos = textarea.selectionStart
      endPos = textarea.selectionEnd
      scrollTop = textarea.scrollTop
      content = $textarea.val()

      contentLength = content.length
      prefixContent = content.substring 0, startPos
      postfixContent = content.substring endPos, contentLength
      selectedContent = content.substring startPos, endPos
      finalContent = prefixContent + value + selectedContent + postfixContent

      $textarea.val(finalContent).focus()
      textarea.selectionStart = startPos + value.length
      textarea.selectionEnd = endPos + value.length
      textarea.scrollTop = scrollTop
    else if document.selection
      $textarea.focus()
      range = document.selection.createRange()
      range.text = value
      $textarea.focus()
    else
      textarea.value += value
      $textarea.focus()

  @getSelected = ($textarea) ->
    textarea = $textarea[0]
    if @isW3C
      startPos = textarea.selectionStart
      endPos = textarea.selectionEnd
      selectedContent = $textarea.val().substring startPos, endPos
    else
      $textarea.focus()
      range = document.selection.createRange()
      selectedContent = range.text
    selectedContent

  @getLastTrigger = ($textarea, cursorPos, flags, hiddenChars) ->
    cursorPos or= @getCursor $textarea
    flags or= this::flags
    hiddenChars or= this::hiddenChars

    currentContent = $textarea.val()
    lastTrigger = char: "", pos: -1
    lastHiddenChar = -1
    for flag in flags
      # cursorPos 表明的是 cursor 的位置，是 content.length + 1
      flagPos = lastIndexOf.call currentContent, flag, cursorPos - 1
      continue if flagPos < lastTrigger.pos
      lastTrigger.pos = flagPos
      lastTrigger.char = flag
    for hiddenChar in hiddenChars
      hiddenCharPos = lastIndexOf.call currentContent, hiddenChar, cursorPos - 1
      if hiddenCharPos > lastHiddenChar and cursorPos isnt hiddenCharPos
        lastHiddenChar = hiddenCharPos
    lastTrigger = char: "", pos: -1 if lastHiddenChar > lastTrigger.pos
    char: lastTrigger.char, pos: lastTrigger.pos + 1

  @getInputed = ($textarea, triggerdPos) ->
    currentContent = $textarea.val()
    triggerdPos or= @getCursor $textarea
    currentContent.substring triggerdPos, currentContent.length


if module?.exports?
  module.exports = AutoCompleter
else
  @AutoCompleter = AutoCompleter
