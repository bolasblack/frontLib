(($) ->
    AP = Array.prototype

    $.fn.indexOf = (el) ->
        AP.indexOf.call this, el

) jQuery

