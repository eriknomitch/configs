-- ==============================================
-- HAMMERSPOON->CONFIG ==========================
-- ==============================================

-- -----------------------------------------------
-- -----------------------------------------------
-- -----------------------------------------------
require("audio.volume")

hs.loadSpoon("ReloadConfiguration")
spoon.ReloadConfiguration:start()

-- -----------------------------------------------
-- -----------------------------------------------
-- -----------------------------------------------
-- Make the alerts look nicer.
hs.alert.defaultStyle.strokeColor = {white = 1, alpha = 0}
hs.alert.defaultStyle.fillColor = {white = 0.05, alpha = 0.75}
hs.alert.defaultStyle.radius = 5

-- Disable the slow default window animations.
hs.window.animationDuration = 0
hs.window.setShadows(false)

-- -----------------------------------------------
-- -----------------------------------------------
-- -----------------------------------------------

-- Display a notification
function notify(title, message)
  hs.notify.new({title=title, informativeText=message}):send()
end

-- Some useful global variables
hostname = hs.host.localizedName()
logger = hs.logger.new('main')
hs_config_dir = os.getenv("HOME") .. "/.hammerspoon/"
default_browser_name = "Google Chrome Beta"

-- -----------------------------------------------
-- UTILITY ---------------------------------------
-- -----------------------------------------------
function hasValue (tab, val)
  for index, value in ipairs(tab) do
    if value == val then
      return true
    end
  end

  return false
end

-- -----------------------------------------------
-- -----------------------------------------------
-- -----------------------------------------------
function setMute(state)
  device = hs.audiodevice.defaultOutputDevice()
  device:setOutputVolume(0)
  -- for _, device in pairs(hs.audiodevice.allInputDevices()) do
  --   device:setInputMuted(state)
  -- end

  hs.alert("Muted")
end

hs.audiodevice.watcher.setCallback(function()
  setMute(true)
end)

hs.audiodevice.watcher.stop()
hs.audiodevice.watcher.start()

-- -----------------------------------------------
-- -----------------------------------------------
-- -----------------------------------------------
local movement  = {"cmd", "ctrl"}
local movement2 = {"cmd", "ctrl", "shift"}

local movementAppplicationLaunchOrFocus = {"cmd", "ctrl"}
local movementAppplicationLaunchOrFocusSecondary = {"cmd", "ctrl", "shift"}

applicationHotkeyDefinitions = {}

function bindApplicationFocus(key, title)
  hs.hotkey.bind(movementAppplicationLaunchOrFocus, key, function() hs.application.launchOrFocus(title) end)
end

function bindApplicationFocusSecondary(key, title)
  hs.hotkey.bind(movementAppplicationLaunchOrFocusSecondary, key, function() hs.application.launchOrFocus(title) end)
end

-- -----------------------------------------------
-- SHORTCUTS -------------------------------------
-- -----------------------------------------------
function triggerAfterConfirmation(question, action)
    hs.timer.doAfter(0, function()
        hs.focus()

        local answer = hs.dialog.blockAlert(question, "", "Confirm", "Cancel")

        if answer == "Confirm" then action() end
    end)
end

function launchOrFocusIfRunning(hint)
  local app = hs.application.find(hint)

  if not app then return end

  hs.application.launchOrFocus(app)
end

function confirmOnEnter(appName)
  message = "Launch?"
  informativeText = "info"

  if not hs.application.find(appName) then
    triggerAfterConfirmation(appName, function() hs.application.launchOrFocus(appName) end)
  else
    hs.application.launchOrFocus(appName)
  end

  -- hs.dialog.blockAlert(message, informativeText)
  -- hs.alert.show("Messages")
  -- hs.timer.doAfter(0, function() hs.focus(); hs.dialog.textPrompt("Main message.", "Please enter something:") end)
end

-- -----------------------------------------------
-- -----------------------------------------------
-- -----------------------------------------------
hs.hotkey.bind(movementAppplicationLaunchOrFocus, "M", function() confirmOnEnter("Messages") end)
hs.hotkey.bind(movementAppplicationLaunchOrFocusSecondary, "S", function() confirmOnEnter("Slack") end)

hs.hotkey.bind({"ctrl"}, "Space", function() hs.application.launchOrFocus("iTerm") end)

bindApplicationFocus("I", default_browser_name)
bindApplicationFocus("T", "Todoist")
bindApplicationFocus("P", "Preview")
bindApplicationFocus("F", "Finder")
bindApplicationFocus("Z", "zoom.us")
hs.hotkey.bind(movementAppplicationLaunchOrFocusSecondary, "D", function() confirmOnEnter("Discord") end)
bindApplicationFocus("E", "Obsidian")
bindApplicationFocus("O", "Obsidian")
bindApplicationFocus("C", "Remote Control")
bindApplicationFocus("R", "Remote Control")
bindApplicationFocus("V", "IINA")

-- Secondary
-- -----------------------------------------------
bindApplicationFocusSecondary("E", "Evernote")
-- bindApplicationFocusSecondary("I", "Firefox")
bindApplicationFocusSecondary("W", "Ulysses")
bindApplicationFocusSecondary("P", "Adobe Photoshop 2021")
bindApplicationFocusSecondary("H", "Home Assistant")
-- bindApplicationFocusSecondary("F", "FIgma")
bindApplicationFocusSecondary("F", "FaceTime")

-- Special
-- -----------------------------------------------
-- hs.hotkey.bind({"ctrl"}, "Space", function() hs.application.launchOrFocus("iTerm") end)

-- -----------------------------------------------
-- MOVEMENT --------------------------------------
-- -----------------------------------------------
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

-------------------------------------------------
-- LAYOUTS --------------------------------------
-------------------------------------------------
-- hs.hotkey.bind(movement2, "Left", function()
--   local win    = hs.window.focusedWindow()
--   local app    = win:application()
--   local screen = win:screen()

--   if app:title() == "Google Chrome" then
--     local devTools     = app:findWindow("Developer Tools")
--     local tabsOutliner = app:findWindow("Tabs Outliner")
--     local main         = app:mainWindow()
--     main:focus()
--     local chromeDeveloperLayout = {
--       {"Google Chrome", main:title(),         screen, hs.layout.left75,  nil, nil},
--       {"Google Chrome", devTools:title(),     screen, hs.layout.right25, nil, nil},
--       {"Google Chrome", tabsOutliner:title(), screen, hs.layout.right25, nil, nil}
--     }

--     hs.layout.apply(chromeDeveloperLayout)
--   end
-- end)

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

  if app:title() == "Tusk" then
    app_fullscreen = true
  end

  if app:title() == "Preview" then
    app_fullscreen = true
  end

  -- if app:title() == "Todoist" then
  --   local win    = hs.window.focusedWindow()
  --   local f      = win:frame()
  --   local screen = win:screen()
  --   local max    = screen:frame()

  --   f.w = max.w / 2
  --   f.h = max.h

  --   f.x = max.x - (max.x - f.w) / 2
  --   f.y = max.y

  --   win:setFrame(f)
  -- end

  -- ---------------------------------------------
  if app_fullscreen == true then
    fullscreen()
  end
end

--------------------------------------------------
-- ALERT->CONFIG-LOADED --------------------------
--------------------------------------------------
hs.alert("Hammerspon Config Loaded")
