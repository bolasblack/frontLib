return if $().bootSelect?

$.fn.bootSelect = (options) ->
  throw new Error("element must be select") unless @is "select"

  caret = "<span class='caret'></span>"

  randomName = (prefix) ->
    prefix + new Date().getTime()

  bindEvent = ($btnGroup, $select) ->
    $btnGroup.on "click", ".dropdown-menu li", (event) ->
      $li = $ event.currentTarget
      $btnGroup.find(".dropdown-toggle").html $li.find("a").text() + caret
      $select.val $li.data("option").val()

    $select.on "change:dom", (event) ->
      $btnGroup.find(".dropdown-menu").empty().append generateListItems $select.find "option"

  generateListItems = ($items) ->
    $items.map (index) ->
      $item = $items.eq index
      $li = $("<li>").append $("<a>", href: "javascript:;").text $item.text()
      $li.data "option", $item
      $item.data "li", $li
      $li[0]

  generateDropdownMenu = ($items) ->
    $list = $ "<ul>", class: "dropdown-menu"
    $listItems = generateListItems $items
    $list.append $listItem for $listItem in $listItems

  @hide().each (index, elem) =>
    $this = @eq index
    $items = $this.find "option"
    selectName = randomName "select"

    $btnGroup = $("<div>", class: "btn-group", "data-select": selectName).data "select", $this
    $this.attr("data-select", selectName).data "btnGroup", $btnGroup

    $toggler = $("<button>", {class: "btn dropdown-toggle", "data-toggle": "dropdown"})
      .html $this.find(":selected").text() + caret

    $dropdownMenu = generateDropdownMenu $items
    $btnGroup.append($toggler).append $dropdownMenu
    $this.before $btnGroup
    $toggler.dropdown()

    bindEvent $btnGroup, $this
