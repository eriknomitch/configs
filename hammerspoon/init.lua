function YesNoDialogBox(ActionFunc)
  test = hs.chooser.new(ActionFunc)
  test:rows(2)
  test:choices({{["text"] = "Yes", ["subText"] = "", ["id"] = "yes"},
  {["text"] = "No", ["subText"] = "", ["id"] = "no"}})
  test:show()
end

function has_value (tab, val)
  for index, value in ipairs(tab) do
    if value == val then
      return true
    end
  end

  return false
end

hs.window.animationDuration = 0
hs.window.setShadows(false)

local movement  = {"cmd", "ctrl"}
local movement2 = {"cmd", "ctrl", "shift"}

local movementAppplicationLaunchOrFocus = {"cmd", "ctrl"}
local movementAppplicationLaunchOrFocusSecondary = {"cmd", "ctrl", "shiift"}

applicationHotkeyDefinitions = {}

hs.hotkey.bind(movement, "Z", function()
  hs:appfinder()
end)

function bindApplicationFocus(key, title)
  hs.hotkey.bind(movementAppplicationLaunchOrFocus, key, function() hs.application.launchOrFocus(title) end)
end

function bindApplicationFocusSecondary(key, title)
  hs.hotkey.bind(movementAppplicationLaunchOrFocusSecondary, key, function() hs.application.launchOrFocus(title) end)
end

-- -----------------------------------------------
-- SHORTCUTS -------------------------------------
-- -----------------------------------------------
bindApplicationFocus("i", "Google Chrome")
bindApplicationFocus("d", "FirefoxDeveloperEdition")
bindApplicationFocus("M", "Messages")
bindApplicationFocus("W", "Wavebox")
bindApplicationFocus("E", "Evernote")
bindApplicationFocus("T", "Todoist")
bindApplicationFocus("Y", "YakYak")
bindApplicationFocus("P", "Preview")
bindApplicationFocus("F", "Finder")
bindApplicationFocus("H", "Helium")
bindApplicationFocus("S", "Slack")

--- bindApplicationFocusSecondary("I", "FirefoxDeveloperEdition")

hs.hotkey.bind({"cmd", "ctrl", "shift", "P"}, "P", function() confirmThenOpenApplication("Adobe Photoshop CC 2018") end)

-- -----------------------------------------------
-- -----------------------------------------------
-- -----------------------------------------------
function confirmThenOpenApplication(name)
  YesNoDialogBox(function() hs.application.launchOrFocus(name) end)
end

function confirmForPhotoshop()
  YesNoDialogBox(function() hs.application.launchOrFocus("Adobe Photoshop CC 2018") end)
end

hs.hotkey.bind({"ctrl"}, "Space", function() hs.application.launchOrFocus("iTerm") end)

hs.hotkey.bind(movement, "Left", function()
  local win = hs.window.focusedWindow()
  local f = win:frame()
  local screen = win:screen()
  local max = screen:frame()

  f.x = max.x
  f.y = max.y
  f.w = max.w / 2
  f.h = max.h
  win:setFrame(f)
end)

hs.hotkey.bind(movement, "Right", function()
  local win    = hs.window.focusedWindow()
  local f      = win:frame()
  local screen = win:screen()
  local max    = screen:frame()

  f.x = max.x + (max.w / 2)
  f.y = max.y
  f.w = max.w / 2
  f.h = max.h
  win:setFrame(f)
end)

function fullscreen()
  local win    = hs.window.focusedWindow()
  local f      = win:frame()
  local screen = win:screen()
  local max    = screen:frame()

  f.x = max.x
  f.y = max.y
  f.w = max.w
  f.h = max.h

  win:setFrame(f)
end

function middle()
  local win    = hs.window.focusedWindow()
  local f      = win:frame()
  local screen = win:screen()
  local max    = screen:frame()

  f.x = max.x + (max.w * 1/8)
  f.y = max.y
  f.w = max.w * 3/4
  f.h = max.h

  win:setFrame(f)
end

hs.hotkey.bind(movement, "Up", fullscreen)
hs.hotkey.bind(movement, "Down", middle)

-----------------------------------------------
-- LAYOUTS
-----------------------------------------------
hs.hotkey.bind(movement2, "Left", function()
  local win    = hs.window.focusedWindow()
  local app    = win:application()
  local screen = win:screen()

  if app:title() == "Google Chrome" then
    local devTools     = app:findWindow("Developer Tools")
    local tabsOutliner = app:findWindow("Tabs Outliner")
    local main         = app:mainWindow()
    main:focus()
    local chromeDeveloperLayout = {
      {"Google Chrome", main:title(),         screen, hs.layout.left75,  nil, nil},
      {"Google Chrome", devTools:title(),     screen, hs.layout.right25, nil, nil},
      {"Google Chrome", tabsOutliner:title(), screen, hs.layout.right25, nil, nil}
    }

    hs.layout.apply(chromeDeveloperLayout)
  end
end)

-----------------------------------------------
-- WINDOW->MOVEMENT ---------------------------
-----------------------------------------------
function moveWindowOneSpace(direction)
   local mouseOrigin = mouse.getAbsolutePosition()
   local win = hs.window.focusedWindow()
   local clickPoint = win:zoomButtonRect()

   clickPoint.x = clickPoint.x + clickPoint.w + 5
   clickPoint.y = clickPoint.y + (clickPoint.h / 2)

   local mouseClickEvent = hs.eventtap.event.newMouseEvent(hs.eventtap.event.types.leftmousedown, clickPoint)
   mouseClickEvent:post()
   hs.timer.usleep(150000)

   local nextSpaceDownEvent = hs.eventtap.event.newKeyEvent({"ctrl"}, direction, true)
   nextSpaceDownEvent:post()
   hs.timer.usleep(150000)

   local nextSpaceUpEvent = hs.eventtap.event.newKeyEvent({"ctrl"}, direction, false)
   nextSpaceUpEvent:post()
   hs.timer.usleep(150000)

   local mouseReleaseEvent = hs.eventtap.event.newMouseEvent(hs.eventtap.event.types.leftmouseup, clickPoint)
   mouseReleaseEvent:post()
   hs.timer.usleep(150000)

   mouse.setAbsolutePosition(mouseOrigin)
end

-----------------------------------------------
-- WINDOW->ON-CREATED -------------------------
-----------------------------------------------
function handleWindowCreated(win, event)

  app_fullscreen = false
  app        = win:application()

  if app:title() == "draw.io" then
    app_fullscreen = true
  end

  if app:title() == "Napkin" then
    app_fullscreen = true
  end

  if app:title() == "Evernote" then
    app_fullscreen = true
  end

  if app:title() == "Preview" then
    app_fullscreen = true
  end

  --if app:title() == "LastPass" then
    --app_fullscreen = true
  --end

  -- ---------------------------------------------
  if app_fullscreen == true then
    fullscreen()
  end
end

windows = hs.window.filter.new(nil)
windows:subscribe(hs.window.filter.windowCreated, handleWindowCreated)

-----------------------------------------------
-- Reload config on write
-----------------------------------------------
function reload_config(files)
  hs.reload()
end

hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", reload_config):start()

--------------------------------------------------
-- ALERT->CONFIG-LOADED --------------------------
--------------------------------------------------
hs.alert.show("Config loaded")

