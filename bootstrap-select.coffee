return if $().bootSelect?

$.fn.bootSelect = (options) ->
  throw new Error("element must be select") unless @is "select"

  invalidLink = "javascript:void(0);"
  caret = "<span class='caret'></span>"
  randomName = (prefix) -> prefix + $.now()

  unbindEvent = ($btnGroup, $select) ->
    $btnGroup.off ".bootSelect"
    $select.off ".bootSelect"

  destroyListItems = ($items) ->
    $items.each (index) ->
      $item = $items.eq index
      $li = $item.data "li"
      $item.removeData "li"
      $li.removeData "option"
      $li.remove()

  bindEvent = ($btnGroup, $select) ->
    $btnGroup.on "click.bootSelect", ".dropdown-menu li", (event) ->
      $li = $ event.currentTarget
      $btnGroup.find(".dropdown-toggle").html $li.find("a").text() + caret
      $select.val $li.data("option").val()
      $select.trigger "change"

    $select.on "change:dom.bootSelect", (event) ->
      $selectedItem = $select.find "option:selected"
      $listItems = generateListItems $select.find "option"
      $btnGroup.find(".dropdown-menu").empty().append $listItems
      $btnGroup.find(".dropdown-toggle").html $selectedItem.text() + caret

  generateListItems = ($items) ->
    $items.map (index) ->
      $item = $items.eq index
      $li = $("<li>").append $("<a>", href: invalidLink).text $item.text()
      $li.data "option", $item
      $item.data "li", $li
      $li[0]

  generateDropdownMenu = ($items) ->
    $list = $ "<ul>", class: "dropdown-menu"
    $listItems = generateListItems $items
    $list.append $listItem for $listItem in $listItems

  if options is false
    # dispose
    @show().each (index, elem) =>
      $this = @eq index
      $items = $this.find "option"
      $btnGroup = $this.data("btnGroup").removeData "select"
      $this.removeData("btnGroup").removeAttr "data-select"

      unbindEvent $btnGroup, $this
      destroyListItems $items
      $btnGroup.remove()

  else

    @hide().each (index, elem) =>
      $this = @eq index
      $items = $this.find "option"
      selectName = randomName "select"

      $btnGroup = $ "<div>",
        class: "btn-group #{$this.data "bs-class"}"
        "data-select": selectName
      .data "select", $this

      $this.attr("data-select", selectName).data "btnGroup", $btnGroup

      $toggler = $ "<button>",
        class: "btn dropdown-toggle"
        "data-toggle": "dropdown"
      .html $this.find(":selected").text() + caret

      $dropdownMenu = generateDropdownMenu $items
      $btnGroup.append($toggler).append $dropdownMenu
      $this.before $btnGroup
      $toggler.dropdown()

      bindEvent $btnGroup, $this
