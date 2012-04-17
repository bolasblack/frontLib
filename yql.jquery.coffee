jQuery.extend
    yql: (args) ->
        defaultArgs =
            url: ''
            data: {}
            format: 'json'
            yqlInfo: false
        argsDict = $.extend defaultArgs, args
        queryURL = argsDict["url"] + '?' + $.param argsDict["data"]
        console.log 'queryURL', queryURL
        queryResult = $.ajax
            url: "http://query.yahooapis.com/v1/public/yql"
            crossDomain: true
            scriptCharset: "UTF-8"
            dataType: "jsonp"
            data:
                q: "SELECT * FROM #{argsDict["format"]} WHERE url='#{queryURL}'"
                format: 'json'
                diagnostics: true
            success: (data) ->
                callback = argsDict["callback"]
                if callback?
                    if argsDict["yqlInfo"]
                        resultData = data
                    else
                        resultData = if data.results? then data.results else data.query.results.json
                    callback resultData
