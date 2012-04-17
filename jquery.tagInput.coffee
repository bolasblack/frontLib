$.fn.extend
    # 標籤控件
    # 功能：按Enter或Tab或失去焦點確定標籤輸入完畢，雙擊文字可以編輯該標籤，單擊叉叉（×）表示刪除該標籤
    # tabControl:function
    # 參數說明：
    # inputSelector 输入框选择器
    # tags:string 初始化的標籤內容，以逗號為間隔；
    tagControl: (options, tags) ->
        defOpt = inputSelector: ""

        opts = $.extend defOpt, options
        checkReg = /[^A-Za-z0-9_\u4E00-\u9FA5]+/gi # 匹配非法字符
        _tags = []

        $tagInputer = $ opts.inputSelector

        if tags?
            # 將非中英文、數字、下劃絲、逗號的其他字符都去掉，且不能以逗號開頭與結束
            tags = tags.replace(/[^A-Za-z0-9_,\u4E00-\u9FA5]+/gi, "").replace(/^,+|,+$/gi, "")
            _tags = tags.split ','

        inputName = $tagInputer.attr "name"
        $tagInputer.removeAttr "name"
        $reallyInput = $("<input>", name: inputName, type: "hidden").appendTo this

        addTag = (value) =>
            $span = $('<span>', class: "tag").append("<strong>#{value}</strong>").append("<a>X</a>")
            @append($span)
            _tags.push value
            $reallyInput.val _tags

        removeTag = (tagObj) ->
            tagContent = tagObj.find('strong').text()
            tagObj.remove()
            tagIndex = _tags.indexOf tagContent
            console.log tagIndex
            unless !~tagIndex
                _tags = _tags.slice(0, tagIndex).concat _tags.slice tagIndex + 1
                $reallyInput.val _tags

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
        $tagInputer.on "keypress", (event) ->
            if event.keyCode is 13
                event.preventDefault()
                event.stopPropagation()
                # value = $.trim($(this).val())
                value = $tagInputer.val().replace(/\s+/gi, "")
                unless value is ""
                    _match = value.match(checkReg)
                    unless _match
                        addTag value
                        $tagInputer.val("").focus()
                false

        @on "click", "span.tag a", (e) ->
            removeTag $(@).parent('span.tag')

        this
