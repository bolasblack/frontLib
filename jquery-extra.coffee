(($) ->
    AP = Array.prototype

    $.fn.delete = Array::delete = (startIndex, length=1) ->
        prevPart = this.slice 0, startIndex
        nextPart = this.slice startIndex + length
        prevPart.concat nextPart

    $.fn.indexOf = (el) ->
        AP.indexOf.call this, el

) jQuery

