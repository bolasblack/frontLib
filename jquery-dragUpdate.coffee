$dragArea = undefined

# firefox 是 window.URL, chrome 是 window.webkitURL
# http://blog.bingo929.com/renren-drag-drop-photo-filereader-formdata.html
urlObject = if window.URL then window.URL else window.webkitURL

handleFileList = (config, fileList) ->
  $imgArea = $ config.imgArea
  return if fileList.length is 0
  if config.mulitPic isnt true # 如果只允许存在一张图片
    $existImg = $imgArea.find ".dragImg"
    destroyImg $existImg if $existImg.length > 0
  $imgList = $ createImg fileList
  $imgArea.append $imgList.addClass "dragImg"

createImg = (fileList) ->
  imgList = []
  img = undefined
  $.map fileList, (imgFile, index) ->
    return if !~imgFile.type.indexOf 'image'
    imgUrl = urlObject.createObjectURL imgFile
    imgTag = $('<img>', src: imgUrl, draggable: true)[0]
    imgTag.file = imgFile
    imgList.push imgTag
  imgList

destroyImg = ($imgElem) ->
  $imgElem.each (index, imgElem) ->
    urlObject.revokeObjectURL imgElem.file
  $imgElem.detach()

dropHandler = (e) ->
  e.preventDefault()
  config = e.data
  handleFileList config, e.dataTransfer.files

dragEnterHandler = (e) ->
  $dragArea.addClass "dragEnter"

dragLeaveHandler = (e) ->
  $dragArea.removeClass "dragLeave"

bindInputEvent = (config) ->
  $dragArea.on "change", config.inputElem, (e) ->
    handleFileList config, this.files

jQuery.fn.dragUpdateImage = (config) ->
  jQuery.event.props.push "dataTransfer"

  $dragArea = this
    .on("dragover", (e) -> e.preventDefault())
    .on("drop", config, dropHandler)
    .on("dragenter", dragEnterHandler)
    .on("dragleave", dragLeaveHandler)
    .on "dblclick", "#{config.imgArea} .dragImg", (e) ->
      destroyImg $ e.srcElement

  bindInputEvent config if config.inputElem?
