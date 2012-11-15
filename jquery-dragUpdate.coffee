do ($) ->
  return unless Modernizr.draganddrop
  toString = Object::toString

  # firefox4+, chrome8+ 是 window.URL, chrome 另一种是 window.webkitURL
  # https://developer.mozilla.org/en-US/docs/DOM/window.URL.createObjectURL
  # http://blog.bingo929.com/renren-drag-drop-photo-filereader-formdata.html
  urlObject = if window.URL then window.URL else window.webkitURL

  isFileList = (obj) ->
    return false unless obj?
    toString.call(obj) is "[object FileList]"

  handleFileList = (config, fileList) ->
    return unless fileList.length
    imageData = imagesObject if config.mulitPic then fileList else fileList[0]
    return unless imageData.length
    event = $.Event "dragupload.image"
    event.files = imageData
    @trigger event

  processFileList = (fileList, fn) ->
    fileList = [fileList] unless isFileList fileList
    for imageFile in fileList when !!~imageFile.type.indexOf 'image'
      fn? imageFile

  imagesObject = (fileList) ->
    processFileList fileList, (imageFile) ->
      file: imageFile, url: urlObject.createObjectURL imageFile

  imagesRevoke = (fileList) ->
    processFileList fileList, (imageFile) ->
      urlObject.revokeObjectURL imageFile

  dropHandler = (event) ->
    event.preventDefault()
    config = event.data
    handleFileList.call $(event.currentTarget), config, event.dataTransfer.files
    dragLeaveHandler event
    return

  dragEnterHandler = (event) ->
    $(event.currentTarget).addClass "drag-enter"
    return

  dragLeaveHandler = (event) ->
    $(event.currentTarget).removeClass "drag-enter"
    return

  dispose = ->
    return unless @expando and @$el
    @$el.off ".#{@expando}"
    delete @$el
    delete @expando

  dragUploadImage = (config={}) ->
    @dragUploadImage.dispose()
    config = $.extend {mulitPic: false}, config
    $.event.props.push "dataTransfer"
    expando = "dragUpload#{$.now()}"
    @dragUploadImage.expando = expando
    @dragUploadImage.$el = this

    @on("drop.#{expando}", config, dropHandler)
    .on("dragenter.#{expando}", dragEnterHandler)
    .on("dragleave.#{expando}", dragLeaveHandler)
    .on "dragover.#{expando}", (event) ->
      event.preventDefault()
      return

  staticMethods = {imagesObject, imagesRevoke, urlObject, dispose}
  $.fn.dragUploadImage = $.extend dragUploadImage, staticMethods
