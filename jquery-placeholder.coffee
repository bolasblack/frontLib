return if $().placeholder?

$.fn.placeholder = ->
  return if Modernizr.input.placeholder is true

  $("html").addClass "no-placeholder"
  @each (index, elem) =>
    return if elem.tagName.toLowerCase() isnt "input"
    $elem = @eq index

    $p = $("<p>", class: "placeholder-container").css
      "position": "relative", "padding": 0, "margin": 0

    $label = $ "<label>", for: $elem.attr("id") or ""
    $label.text($elem.attr "placeholder").css
      position: "absolute"
      top: $elem.css("padding-top")
      left: $elem.css("padding-left")
      color: $elem.css("color")
      "font-size": $elem.css("font-size")

    $elem.wrap($p).before($label).on "keyup", (event) ->
      $label[`$elem.val()? "hide": "show"`]()

    $label.on "mousedown", (event) -> $elem.focus()
