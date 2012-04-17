###
@Description: function, remove part of string

@Param: start
@Param: length

@return String
###
String::remove = (index, length=1) ->
    deltaStr = @substr index, length
    @replace deltaStr, ''

###
@Description: function, up case part of string

@Param: start
@Param: length

@return String
###
String::charUpperCase = (index, length=1) ->
    strList = @split ''
    for i in [0...length]
        newIndex = index + i
        strList[newIndex] = strList[newIndex].toUpperCase()
    strList.join ''

###
@Description: function, deff two string

@Param: old_str
@Param: new_str

@return Array
###
getDelta = (oldStr, newStr) ->
    resultList = []
    delta = ''
    delingIndex = 0
    contr = (oldStr, newStr, index) ->
        while newStr[index] isnt oldStr[index]
            delta += newStr[index]
            newStr = newStr.remove index
    deling = (oldStr, newStr, index) ->
        if newStr[index] not in oldStr
            oldStr = oldStr.remove(delingIndex)
            newStr = newStr.remove(index)
            deling index
    for i in newStr
        deling i if oldStr.length
    [oldStr, newStr]

jQuery.fn.labelFade = (preName='', callback) ->
    @on 'keyup', ->
        forName = preName + @attr 'name'
        forLabel = @parent().find "[for='#{forName}']"
        forLabel["#{if @val() then "fadeOut" else "fadeIn"}"]()
    callback @ if callback?
    @

jQuery.fn.defaultText = (defaultText='', callback) ->
    @on('focus', ->
        @val(defaultText).trigger 'keyup'
    ).on 'blur', ->
        @val('').tigger 'keyup' if @val() and @val() is defaultText
    callback @ if callback?
    @
