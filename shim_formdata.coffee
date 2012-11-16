class ShimFormData
  constructor: (key, value) ->
    @_boundary = "------oldformdata#{$.now()}"
    if $.isPlainObject key
      # new ShimFormData {k: v, k: v}
      $.map key, (value, key) => @append key, value
    else
      # new ShimFormData k: v
      @append key, value

  append: (key, value) ->
    @_datas or= {}
    @_datas[key] = value

  build: (success, failure) ->
    promiseArray = $.map @_datas, (value, key) => @_promiseValue key, value
    $.when.apply($, promiseArray).then (args...) =>
      data = [""]
      data.push value for value in args
      formData = data.join "--#{@_boundary}\r\n"
      formData += "--#{@_boundary}--"
      success? @_boundary, @_getBinary formData
    , (args...) ->
      failure? args...

  _generateDispositionData: (key, originValue, strValue) ->
    disposition = []
    dispositionStr = "Content-Disposition: form-data; name=\"#{key}\""
    if originValue instanceof File
      disposition.push dispositionStr + "; filename=\"#{originValue.name}\""
      disposition.push "Content-Type: #{originValue.type}"
    else
      disposition.push dispositionStr
    disposition.push ""
    disposition.push strValue
    disposition.push ""
    disposition.join "\r\n"

  _promiseValue: (key, value) ->
    deferred = $.Deferred()
    if value instanceof File
      @_readFile value, (fileData) =>
        deferred.resolve @_generateDispositionData key, value, fileData
      , (event) ->
        deferred.reject event
    else
      deferred.resolve @_generateDispositionData key, value, value
    deferred.promise()

  _getBinary: (datastr) ->
    ords = Array::map.call datastr, (x) ->
      x.charCodeAt(0) & 0xFF
    uint8Arr = new Uint8Array ords
    # Chrome 22 suggest return `ArrayBufferView` instead `ArrayBuffer`
    # http://updates.html5rocks.com/2012/07/Arrived-xhr-send-ArrayBufferViews
    uint8Arr.buffer

  _readFile: (file, success, failure) ->
    reader = new FileReader()
    reader.onload = (event) ->
      success? event.target.result
    reader.onerror = (event) ->
      failure? event
    reader.readAsBinaryString file
