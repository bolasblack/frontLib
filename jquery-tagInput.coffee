$.fn.extend
  tagControl: (options, tags) ->
    defOpt =
      inputSelector: ""
      originData: null # {name: "xxx", value: "xxx"} || [...]
      inputHandler: null # function(inputValue) {/* code */; return {name: "xxx", value: "xxx"};}

    opts = $.extend defOpt, options
    checkReg = /[^A-Za-z0-9_\u4E00-\u9FA5]+/gi # 匹配非法字符
    _tags = []

    $tagInputer = $ opts.inputSelector
    inputName = $tagInputer.attr "name"
    $tagInputer.removeAttr "name"
    $reallyInputElem = $("<input>", name: inputName, type: "hidden").appendTo this

    createTag = (name, value) =>
      insertInput = (resultTag) ->
        try
        catch error
          $reallyInputElem.val "#{resultTag}"

      if ~_tags.indexOf value
        return @trigger "tagExist.tagInput"
      $span = $('<span>', class: "tag")
        .append("<strong>#{name}</strong>")
        .append "<a>X</a>"
      @append $span
      _tags.push value
      $reallyInputElem.val _tags
      @trigger "tagInserted.tagInput"

    addTag = (value) ->
      name = value
      inputHandlerCallback = (result) ->
        if $.isPlainObject(result) \
          then {name, value} = result \
          else name = value = result
        createTag name, value
      unless $.isPlainObject value
        opts.inputHandler? value, inputHandlerCallback
      else
        name = value["name"]
        value = value["value"]
        createTag name, value

    removeTag = (tagObj) ->
      tagContent = tagObj.find('strong').text()
      tagObj.remove()
      tagIndex = _tags.indexOf tagContent
      unless !~tagIndex
        _tags = _tags.slice(0, tagIndex).concat _tags.slice tagIndex + 1
        $reallyInputElem.val _tags

    if opts.originData?
      originData = opts.originData
      if $.isArray originData
        addTag(item) for item in originData
      else if $.isPlainObject originData
        addTag originData

    $tagInputer.off ".tagInput"
    @off ".tagInput"

    # 初始化標籤輸入框
    # TODO: 为什么 keydown 事件返回 false 后依旧会让 firefox 里的表单提交
    # Firefox中OnKeyDown/OnKeyPress和Form的关系: 
    #   http://www.cnblogs.com/0417/archive/2010/08/30/1812494.html
    #   var txt = document.getElementById("txtOrder");
    #   txt.onkeyup=function(){
    #       alert("OnKeyUp 触发");
    #   };
    #   txt.onkeypress=function(){
    #       alert("OnKeyPress 触发");
    #   };
    #   txt.onkeydown=function(){
    #       alert("OnKeyDown 触发");
    #   };
    # 如上代码，chrome 里按顺序触发，但是 keyup 在这样的代码下不会被触发
    # 如果移到了最下面就可以正常触发
    # 在 firefox 下，up > down > press
    $tagInputer.on "keydown.tagInput keypress.tagInput keyup.tagInput", (event) ->
      if event.keyCode is 13
        event.preventDefault()
        event.stopPropagation()
        value = $tagInputer.val().replace /\s+/gi, ""
        if value isnt ""
          _match = value.match checkReg
          unless _match
            addTag value
            $tagInputer.val("").focus()
        false

    @on "click.tagInput", "span.tag a", (e) ->
      removeTag $(this).parent 'span.tag'

    this
