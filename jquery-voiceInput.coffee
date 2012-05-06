jQuery.fn.voiceInput = (userOptions) ->
    if jQuery.browser.webkit
        defaultOptions =
        	# 外部的容器的 class
            wrapperElem: 'voice-input-area'
            # 真正起作用的元素
            textElem: 'need-voice-input'
            # 话筒（其实也就是 input 标签）的 class
            inputElem: 'voice-input'
            isWrapper: false

        options = $.extend defaultOptions, userOptions

        if options['isWrapper']
            wrapper = @
        else
            wrapperTpl = "<span class='#{options['wrapperElem']}'>"
            wrapper = @wrap(wrapperTpl).parent ".#{options['wrapperElem']}"

        wrapper.append "<input class='#{options['inputElem']}' type='text' x-webkit-speech='x-webkit-speech' />"
        textElem = wrapper.find(".#{options['textElem']}")
        inputElem = wrapper.find(".#{options['inputElem']}")
        				   .css
                               border: "none"
                               color: "transparent"
                               width: -> $(@).css "font-size"
        inputElem.on 'webkitspeechchange', =>
            textElem.append inputElem.val()