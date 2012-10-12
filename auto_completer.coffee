return unless window.jQuery
$ = window.jQuery
lastIndexOf = Array::lastIndexOf or (searchvalue, start) ->
  for i in [@length...1] when (item = this[i]) is searchvalue
    return i
  -1

class AutoCompleter
  cloneStyle: ["font-size", "font-family", "line-height", "letter-spacing", "word-wrap", "padding", "width", "border"]
  hiddenChars: ["\n", " "]
  flags: ["@"]
  mirrorStyle:
    "position": "absolute"
    "z-index": "-1000"
    "visibility": "hidden"
    "background-color": "#aaa"

  triggerd: false

  constructor: (selector, options) ->
    if typeof selector is "string" or (selector?.nodeType? and selector.nodeType is 1)
      $textarea = $ selector
    else if selector instanceof $
      $textarea = selector
    else
      $textarea = []
    unless $textarea.length
      return new Error "not support selector"
    unless $textarea[0].tagName is "textarea".toUpperCase()
      return new Error "not support element"

    @$textarea = $textarea
    @_processOption options, ["cloneStyle", "flags", "hiddenChars", "mirrorStyle"]
    @$mirror = @_createMirror()
    @$textarea.data "AutoCompleter", this
    @startObserve()

  triggerHidden: ->
    @$textarea.trigger "ac.hidden"

  trigger: (triggerdChar, triggerdPos) ->
    event = jQuery.Event "ac.trigger"
    event.trigger = triggerdChar
    event.inputed = @getInputed @$textarea, triggerdPos
    event.offset = @$mirror.find("#ac-flags").offset()
    @$textarea.trigger event

  startObserve: ->
    return new Error("textarea hasn't init") unless @$mirror
    triggerdPos = -1
    triggerdChar = ""
    @$textarea.on "keyup.acdefined click.acdefined", (event) =>
      if (lastTrigger = @_checkTrigger())
        @triggerd = true
        triggerdChar = lastTrigger.char
        triggerdPos = lastTrigger.pos
        @$mirror.html @$textarea.val().substring(0, triggerdPos - 1).replace /\n/g, "<br/>"
        @$mirror.append $("<span>", id: "ac-flags").text triggerdChar
      else if not @triggerd
        @$mirror.html ""
        return

      return unless @triggerd
      @_adjustMirror()
      @trigger triggerdChar, triggerdPos

  finishObserve: ->
    @$textarea.off ".acdefined"
    @triggerHidden()
    @triggerd = false

  getCursor: -> @constructor.getCursor @$textarea
  setCursor: (pos) -> @constructor.setCursor @$textarea, pos
  insertCursor: (value) -> @constructor.insertCursor @$textarea, value
  getLastTrigger: (cursorPos) -> @constructor.getLastTrigger @$textarea, cursorPos, @flags, @hiddenChars
  getInputed: (triggerdPos) -> @constructor.getInputed @$textarea, triggerdPos

  _checkTrigger: ->
    lastTrigger = @getLastTrigger()
    unless lastTrigger.pos
      @triggerHidden()
      @triggerd = false
      return false
    lastTrigger

  _processOption: (options, argNames) ->
    return unless options
    for argName in argNames
      this[argName] = options[argName] if options[argName]?

  _adjustMirror: ->
    offset = @$textarea.offset()

    originalHtml = @$mirror.html()
    @$mirror.html "&nbsp;"
    shim = parseInt @$mirror.outerHeight(), 10
    @$mirror.html originalHtml

    @$mirror.css
      "top": offset.top + shim
      "left": offset.left

  _getTimestamp: -> (new Date).getTime()

  _createMirror: ->
    mirrorID = @_getTimestamp()
    $mirror = $ "<div>", class: "ac-mirrors ac-mirror#{mirrorID}"
    targetStyle = $.extend {}, @mirrorStyle
    for styleName in @cloneStyle
      targetStyle[styleName] = @$textarea.css styleName
    $mirror.css(targetStyle).appendTo "body"
    @$textarea.data "acMirror", $mirror
    $mirror

AutoCompleter = $.extend AutoCompleter,
  isW3C: $("<textarea>")[0].selectionStart?
  # w3c see also [http://www.w3.org/TR/2009/WD-html5-20090423/editing.html#selection]
  # document.selection see also [http://qingfeng825.iteye.com/blog/259099]

  # from http://js8.in/466.html
  getCursor: ($textarea) ->
    caretPos = 0
    if @isW3C
      caretPos = $textarea[0].selectionStart
    else if document.selection
      $textarea.focus()
      range = document.selection.createRange()
      range.moveStart "character", -$textarea.val().length
      caretPos = range.text.length
    caretPos

  setCursor: ($textarea, pos) ->
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
  insertCursor: ($textarea, value) ->
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

  getLastTrigger: ($textarea, cursorPos, flags, hiddenChars) ->
    cursorPos or= @getCursor $textarea
    flags or= @prototype.flags
    hiddenChars or= @prototype.hiddenChars

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
      lastHiddenChar = hiddenCharPos if hiddenCharPos > lastHiddenChar and cursorPos isnt hiddenCharPos
    lastTrigger = char: "", pos: -1 if lastHiddenChar > lastTrigger.pos
    char: lastTrigger.char, pos: lastTrigger.pos + 1

  getInputed: ($textarea, triggerdPos) ->
    currentContent = $textarea.val()
    triggerdPos or= @getCursor $textarea
    currentContent.substring triggerdPos, currentContent.length


if module?.exports?
  module.exports = AutoCompleter
else
  @AutoCompleter = AutoCompleter
