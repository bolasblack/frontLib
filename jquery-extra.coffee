(($) ->
    AP = Array.prototype

    $.fn.delete = Array::delete = (startIndex, length=1) ->
      prevPart = this.slice 0, startIndex
      nextPart = this.slice startIndex + length
      prevPart.concat nextPart

    $.fn.indexOf = (el) ->
      AP.indexOf.call this, el

    $.fn.labelFade = (preName='', callback) ->
      @on 'keyup', ->
        forName = preName + @attr 'name'
        forLabel = @parent().find "[for='#{forName}']"
        forLabel["#{if @val() then "fadeOut" else "fadeIn"}"]()
      callback? this
      this

    $.fn.defaultText = (defaultText='', callback) ->
      @on('focus', ->
        @val(defaultText).trigger 'keyup'
      ).on 'blur', ->
        @val('').tigger 'keyup' if @val() and @val() is defaultText
      callback? this
      this

) jQuery

