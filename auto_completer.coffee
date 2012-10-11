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

  isW3C: true
  triggerd: false

  constructor: (textareaSelector, options) ->
    return unless textareaSelector
    $textarea = $ textareaSelector
    return unless $textarea.length
    @isW3C = $textarea[0].selectionStart?

    @processOption options, ["cloneStyle", "flags", "hiddenChars", "mirrorStyle"]
    @_createMirror $textarea
    $textarea.data "AutoCompleter", this
    @startObserve $textarea

  getLastTrigger: ($textarea, cursorPos) ->
    currentContent = $textarea.val()
    cursorPos or= @getCursor $textarea
    lastTrigger = char: "", pos: -1
    lastHiddenChar = -1
    for flag in @flags
      # cursorPos 表明的是 cursor 的位置，是 content.length + 1
      flagPos = lastIndexOf.call currentContent, flag, cursorPos - 1
      continue if flagPos < lastTrigger.pos
      lastTrigger.pos = flagPos
      lastTrigger.char = flag
    for hiddenChar in @hiddenChars
      hiddenCharPos = lastIndexOf.call currentContent, hiddenChar, cursorPos - 1
      lastHiddenChar = hiddenCharPos if hiddenCharPos > lastHiddenChar and cursorPos isnt hiddenCharPos
    lastTrigger = char: "", pos: -1 if lastHiddenChar > lastTrigger.pos
    char: lastTrigger.char, pos: lastTrigger.pos + 1

  getInputed: ($textarea, triggerdPos) ->
    currentContent = $textarea.val()
    triggerdPos or= @getCursor $textarea
    currentContent.substring triggerdPos, currentContent.length

  triggerHidden: ($textarea) ->
    $textarea.trigger "ac.hidden"

  trigger: ($textarea, triggerdChar, triggerdPos) ->
    $mirror = $textarea.data "acMirror"
    event = jQuery.Event "ac.trigger"
    event.trigger = triggerdChar
    event.inputed = @getInputed $textarea, triggerdPos
    event.offset = $mirror.find("#ac-flags").offset()
    $textarea.trigger event

  checkTrigger: ($textarea) ->
    lastTrigger = @getLastTrigger $textarea
    unless lastTrigger.pos
      @triggerHidden $textarea
      @triggerd = false
      return false
    lastTrigger

  adjustMirror: ($textarea) ->
    $mirror = $textarea.data "acMirror"
    offset = $textarea.offset()

    originalHtml = $mirror.html()
    $mirror.html "&nbsp;"
    shim = parseInt $mirror.outerHeight(), 10
    $mirror.html originalHtml

    $mirror.css
      "top": offset.top + shim
      "left": offset.left

  startObserve: ($textarea) ->
    $mirror = $textarea.data "acMirror"
    return new Error("textarea hasn't init") unless $mirror
    triggerdPos = -1
    triggerdChar = ""
    $textarea.on "keyup.acdefined click.acdefined", (event) =>
      if (lastTrigger = @checkTrigger $textarea)
        @triggerd = true
        triggerdChar = lastTrigger.char
        triggerdPos = lastTrigger.pos
        $mirror.html $textarea.val().substring(0, triggerdPos - 1).replace /\n/g, "<br/>"
        $mirror.append $("<span>", id: "ac-flags").text triggerdChar
      else if not @triggerd
        $mirror.html ""
        return

      return unless @triggerd
      @adjustMirror $textarea
      @trigger $textarea, triggerdChar, triggerdPos

  finishObserve: ($textarea) ->
    $textarea.off ".acdefined"
    @triggerHidden $textarea
    @triggerd = false

  processOption: (options, argNames) ->
    return unless options
    for argName in argNames
      this[argName] = options[argName] if options[argName]?

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

      contentLength = $textarea.val().length
      prefixContent = $textarea.val().substring(0, startPos)
      postfixContent = $textarea.val().substring(endPos, contentLength)

      $textarea.val(prefixContent + value + postfixContent).focus()
      textarea.selectionStart = startPos + value.length
      textarea.selectionEnd = startPos + value.length
      textarea.scrollTop = scrollTop
    else if document.selection
      $textarea.focus()
      range = document.selection.createRange()
      range.text = value
      $textarea.focus()
    else
      textarea.value += value
      $textarea.focus()

  _getTimestamp: -> (new Date).getTime()

  _createMirror: ($textarea) ->
    mirrorID = @_getTimestamp()
    $mirror = $ "<div>", class: "ac-mirrors ac-mirror#{mirrorID}"
    targetStyle = $.extend {}, @mirrorStyle
    for styleName in @cloneStyle
      targetStyle[styleName] = $textarea.css styleName
    $mirror.css(targetStyle).appendTo "body"
    $textarea.data "acMirror", $mirror
    $mirror

if module?.exports?
  module.exports = AutoCompleter
else
  @AutoCompleter = AutoCompleter
