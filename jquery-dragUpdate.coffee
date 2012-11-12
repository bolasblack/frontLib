do ($) ->
  return unless Modernizr.draganddrop

  # firefox4+, chrome8+ 是 window.URL, chrome 另一种是 window.webkitURL
  # https://developer.mozilla.org/en-US/docs/DOM/window.URL.createObjectURL
  # http://blog.bingo929.com/renren-drag-drop-photo-filereader-formdata.html
  urlObject = if window.URL then window.URL else window.webkitURL

  handleFileList = (config, fileList) ->
    return unless fileList.length
    imageData = imagesObject if config.mulitPic then fileList else fileList[0]
    return unless imageData.length
    @trigger "dragupload.image", [imageData]

  processFileList = (fileList, fn) ->
    fileList = [fileList] unless Object::toString.call(fileList) is "[object FileList]"
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

  dragUploadImage = (config) ->
    config = $.extend config, mulitPic: false
    $.event.props.push "dataTransfer"

    @on("drop", config, dropHandler)
    .on("dragenter", dragEnterHandler)
    .on("dragleave", dragLeaveHandler)
    .on "dragover", (event) ->
      event.preventDefault()
      return

  $.fn.dragUploadImage = $.extend dragUploadImage, {imagesObject, imagesRevoke, urlObject}
