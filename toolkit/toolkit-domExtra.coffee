((window, G) ->
  G.extend
    addEvent: (elem, eventName, callback) ->
      if elem.addEventListener?
        elem.addEventListener eventName, (e) ->
          e.srcElement or= e.target
          keepBubble = callback? e
          if keepBubble is false
            e.stopPropagation()
            e.preventDefault()
        , false
      else if elem.attachEvent?
        elem.attachEvent "on#{eventName}", ->
          e = window.event
          e.target = e.srcElement
          keepBubble = callback? e
          if keepBubble is false
            window.event.cancelBubble = !keepBubble
            window.event.returnValue = keepBubble
      elem

    removeEvent: (elem, eventName, handler) ->
      if elem.removeEventListener?
        elem.removeEventListener eventName, handler
      else if elem.detachEvent?
        elem.detachEvent "on#{eventName}", handler
      elem
) window, window.G
