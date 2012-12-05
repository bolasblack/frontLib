return if $().placeholder?

$.fn.placeholder = (options) ->
  return if Modernizr.input.placeholder is true

  $("html").addClass "no-placeholder"
  @each (index, elem) =>
    return if elem.tagName.toLowerCase() isnt "input"
    return unless ($elem = @eq index).attr "placeholder"

    if options? and not options
      $container = $elem
        .off(".placeholder")
        .parents ".placeholder-container"

      $container
        .find(".placeholder")
        .off ".placeholder"

      return

    $p = $("<p>", class: "placeholder-container").css
      "position": "relative", "padding": 0, "margin": 0, "overflow": "hidden"
      "display": $elem.css("display"), "float": $elem.css("float")

    $label = $ "<label>", for: $elem.attr("id") or "", class: "placeholder"

    debugger
    $label.text($elem.attr "placeholder").css
      position: "absolute"
      top: $elem.css("padding-top")
      left: $elem.css("padding-left")
      color: $elem.css("color")
      "font-size": $elem.css("font-size")

    $elem.wrap($p).before($label).on "keyup.placeholder", (event) ->
      $label[`$elem.val()? "hide": "show"`]()

    $label.on "mousedown.placeholder", (event) -> $elem.focus()
