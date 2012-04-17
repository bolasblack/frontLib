( ($) ->
  defaults =
    triggerSelector: ""
    containerID: "menuContainer"
    mainMenuClassName: "mainMenu"
    subMenuClassName: "subMenu"
    itemClassName: "menuItem"
    menuData: []
    beforeContextMenuShow: (contextMenuEvent) ->
    afterItemSelected: (clickEvent) ->

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

      $(document).on 'mousedown', (event) =>
        @hideMenu() unless !!~$trigger.children().indexOf event.target

      $menu.on 'mousedown', "#{opt.itemClass}", (e) ->
        opt.afterItemSelected? e

      $trigger.on 'contextmenu', (e) =>
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

    createMenuItem: (itemData) ->
      $elem = $("<li>", class: opt.itemClassName).text itemData.name
      if [handler = itemData.handler][0]?
        for eventType, callback of handler
          $elem.on eventType, callback if handler.hasOwnProperty eventType
      $elem

    createSubMenu: (menuData) ->
      $subMenu = $ "<ul>", class: opt.subMenuClassName
      for item in menuData
        $childElem = @createMenuItem item
        $childElem.append @createSubMenu(item["items"]) if $.isArray item["items"]
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

    #  Disable context menu(s)
    disableContextMenu: ->
      $trigger.data('contextMenu').isEnabled = false

    #  Enable context menu(s)
    enableContextMenu: ->
      $trigger.data('contextMenu').isEnabled = true

    #  Destroy context menu(s)
    destroyContextMenu: ->
      $trigger.removeData 'contextMenu'

) jQuery if jQuery?
