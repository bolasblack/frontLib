( ($) ->
  defaults =
    triggerSelector: ""
    containerID: "menuContainer"
    mainMenuClassName: "mainMenu"
    subMenuClassName: "subMenu"
    itemClassName: "menuItem"
    beforeContextMenuShow: (contextMenuEvent) ->
    afterItemSelected: (clickEvent) ->
    emptyMenuClassName: "emptyMenu"
    emptyMenuContent: "No item"
    eventClass: "simpleContextMenu"
    menuData: []

  opt = {}
  $trigger = $menu = []._

  $.simpleContextMenu =
    init: (o) ->
      opt = $.extend defaults, o
      return unless opt.triggerSelector?

      $menu = $ "<div>", id: opt.containerID unless [$menu = $ "##{opt.containerID}"][0].html()?
      # 把menu移动到body下面，避免计算位置的时候出现问题
      $menu.appendTo('body').hide().data('isMovedToBody', true) unless $menu.data('isMovedToBody') is true
      $menu.empty().append @createSubMenu(opt.menuData).removeClass(opt.subMenuClassName).addClass opt.mainMenuClassName

      $trigger = $(opt.triggerSelector).data 'contextMenu',
        $menu: $menu
        isEnabled: true
        disabledMenuItemIdList: []

      $(document).on "mousedown.#{opt.eventClass}", (event) =>
        @hideMenu() unless !!~$trigger.children().indexOf event.target

      $menu.on "mousedown.#{opt.eventClass}", "#{opt.itemClass}", (e) ->
        opt.afterItemSelected? e

      $trigger.on "contextmenu.#{opt.eventClass}", (e) =>
        contextMenu = $trigger.data 'contextMenu'
        return unless contextMenu?
        return unless contextMenu.isEnabled
        return if opt.beforeContextMenuShow?(e) is false
        @showMenu e
        # 绑定菜单项
        $menu.find('li').removeClass 'disabled'
        disabledMenuItemIdList = contextMenu.disabledMenuItemIdList
        queryStr = 'li'
        if disabledMenuItemIdList.length > 0
          strDisabledMenuItemIdList = $.map(disabledMenuItemIdList, (elem, i) -> "##{elem}").join ","
          $menu.find(strDisabledMenuItemIdList).addClass 'disabled'
          queryStr = "#{queryStr}:not(#{strDisabledMenuItemIdList})"
        false

    createMenuItem: (itemData, className, extraDataName) ->
      itemClass = opt.itemClassName
      itemClass += " #{className}" if className?
      itemClass += " #{dataClassName}" if dataClassName = itemData["className"]
      $elem = $("<li>", class: itemClass).text itemData.name
      $elem.data(extraDataName, itemData[extraDataName]) if extraDataName?
      if [handler = itemData.handler][0]?
        for eventType, callback of handler
          $elem.on "#{eventType}.#{opt.eventClass}", callback if handler.hasOwnProperty eventType
      $elem

    createSubMenu: (menuData, className, extraDataName) ->
      [menuData, className, extraDataName] = [[], menuData, className] unless $.isArray menuData
      if menuData.length < 1
        return @createSubMenu [{name: opt.emptyMenuContent}], opt.emptyMenuClassName
      menuClass = opt.subMenuClassName
      menuClass += " #{className}" if className?
      menuClass += " #{dataClassName}" if dataClassName = menuData["className"]
      $subMenu = $ "<ul>", class: menuClass
      for itemData in menuData
        $childElem = @createMenuItem itemData, "", extraDataName
        if $.isArray itemData["items"]
          $childElem.append @createSubMenu itemData["items"], "", extraDataName
        $subMenu.append $childElem
      $subMenu

    showMenu: (event) ->
      # TODO: 到屏幕边缘时的处理
      $menu.css left: event.pageX, top: event.pageY
      $menu.show() if $menu.css("display") is "none"

    hideMenu: -> $menu.hide()

    # 参数为id数组，如无参数则disable全部
    disableContextMenuItems: (o) ->
      contextMenu = $trigger.data 'contextMenu'
      $menu = contextMenu.$menu
      contextMenu.disabledMenuItemIdList = o or $.map($menu.find('li'), (elem) -> elem.getAttribute 'id')

    #  Enable context menu items on the fly
    enableContextMenuItems: (o) ->
      contextMenu = $trigger.data 'contextMenu'
      contextMenu.disabledMenuItemIdList = if o? \
        then $.grep(contextMenu.disabledMenuItemIdList, (v, i) -> !!~$.inArray v, o) \
        else []

    disableContextMenu: ->
      $trigger.data('contextMenu').isEnabled = false

    enableContextMenu: ->
      $trigger.data('contextMenu').isEnabled = true

    destroyContextMenu: ->
      $trigger.removeData 'contextMenu'

) jQuery if jQuery?
