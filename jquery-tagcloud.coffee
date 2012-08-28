###
 * jquery-tagcloud.coffee
 * A Simple Tag Cloud Plugin for JQuery
 *
 * modified from https://github.com/addywaddy/jquery.tagcloud.js
###

(($) ->
  "use strict"

  compareWeights = (a, b) -> a - b

  # Converts hex to an RGB array
  toRGB = (code) ->
    code = jQuery.map(/\w+/.exec(code), (el) -> el + el).join "" if code.length is 4
    hex = /(\w{2})(\w{2})(\w{2})/.exec code
    [parseInt(hex[1], 16), parseInt(hex[2], 16), parseInt(hex[3], 16)]

  # Converts an RGB array to hex
  toHex = (ary) ->
    "#" + jQuery.map(ary, (i) ->
      hex = i.toString(16)
      `(hex.length === 1) ? "0" + hex : hex`
    ).join ""

  colorIncrement = (color, range) ->
    jQuery.map toRGB(color.end), (n, i) ->
      (n - toRGB(color.start)[i])/range

  tagColor = (color, increment, weighting) ->
    rgb = jQuery.map toRGB(color.start), (n, i) ->
      ref = Math.round n + increment[i] * weighting
      `ref > 255 ? 255 : ref < 0 ? 0 : ref`
    toHex rgb

  $.fn.tagcloud = (options) ->
    opts = $.extend {}, $.fn.tagcloud.defaults, options
    $parent = @parent().css position: "relative"

    tagWeights = @map -> $(this).attr opts.weightAttr
    tagWeights = jQuery.makeArray(tagWeights).sort compareWeights
    lowest = tagWeights[0]
    highest = tagWeights.pop()
    range = highest - lowest
    range = 1 if range is 0

    # Sizes
    fontIncr = (opts.size.end - opts.size.start)/range if opts.size
    fontSize = (weighting) ->
      opts.size.start + (weighting * fontIncr) + opts.size.unit

    # Colors
    colorIncr = colorIncrement opts.color, range if opts.color

    times = [0..tagWeights.length]
    sortBy = (int) -> (a, b) ->  - (Math.abs(a - int) - Math.abs(b - int))
    containerWidth = parseInt $parent.css("width"), 10
    containerHeight = parseInt $parent.css("height"), 10
    randomLeftArray = (containerWidth * Math.random() for i in times)
    randomTopArray = (containerHeight * Math.random() for i in times)
    randomLeftArray.sort sortBy containerHeight/2
    randomTopArray.sort sortBy containerWidth/2

    this.each ->
      weightStr = ($this = $ this).attr opts.weightAttr
      weighting = weightStr - lowest
      index = tagWeights.indexOf weightStr
      $this.css fontSize: fontSize(weighting) if opts.size
      $this.css color: tagColor(opts.color, colorIncr, weighting) if opts.color
      $this.css
        position: "absolute"
        top: randomTopArray[index]
        left: randomLeftArray[index]

  $.fn.tagcloud.defaults =
    size: {start: 12, end: 20, unit: "px"}
    weightAttr: "data-weight"

) jQuery
