-- ==============================================
-- HAMMERSPOON->CONFIG ==========================
-- ==============================================

-- -----------------------------------------------
-- APP-CONFIG ------------------------------------
-- -----------------------------------------------

-- Apps
-- -----------------------------------------------
local appsToCenter = { "Finder", "Home Assistant", "Messages", "Gmail", "Unraid" }
local default_browser_name = "Google Chrome Beta"
local secondary_browser_name = "Firefox Developer Edition"

-- Adjustments
-- -----------------------------------------------
local windowAdjustmentDelta = 80

-- Hotkey Prefixes
-- -----------------------------------------------
local movement  = {"cmd", "ctrl"}
local movementSecondary = {"cmd", "ctrl", "shift"}
local movementWindowAdjustment = {"cmd", "ctrl", "alt"}

local movementAppplicationLaunchOrFocus = {"cmd", "ctrl"}
local movementAppplicationLaunchOrFocusSecondary = {"cmd", "ctrl", "shift"}

-- -----------------------------------------------
-- GLOBALS ---------------------------------------
-- -----------------------------------------------
local application = {}

local audioVolume = require("audio.volume")
local fnutils = require "hs.fnutils"

hostname = hs.host.localizedName()

logger = hs.logger.new('main')

hs_config_dir = os.getenv("HOME") .. "/.hammerspoon/"

application.watcher = require "hs.application.watcher"

-- -----------------------------------------------
-- SPOONS ----------------------------------------
-- -----------------------------------------------
function installAll()
  Install:updateRepo('default')

  Install:installSpoonFromRepo('ReloadConfiguration')
  Install:installSpoonFromRepo('Emojis')
end

-- Load Spoons
-- -----------------------------------------------
hs.loadSpoon("SpoonInstall")

spoon.SpoonInstall.use_syncinstall = true
local Install=spoon.SpoonInstall

hs.loadSpoon("Emojis")
hs.loadSpoon("ReloadConfiguration")

-- -----------------------------------------------
-- STYLING ---------------------------------------
-- -----------------------------------------------
--{{{
-- Make the alerts look nicer.
hs.alert.defaultStyle.strokeColor = {white = 1, alpha = 0}
hs.alert.defaultStyle.fillColor = {white = 0.05, alpha = 0.75}
hs.alert.defaultStyle.radius = 5

-- Disable the slow default window animations.
hs.window.animationDuration = 0
hs.window.setShadows(false)

--}}}

-- -----------------------------------------------
-- UTILITY ---------------------------------------
-- -----------------------------------------------

-- Display a notification
function notify(title, message)
  hs.notify.new({title=title, informativeText=message}):send()
end

-- -----------------------------------------------
-- UTILITY ---------------------------------------
-- -----------------------------------------------
function hasValue(tab, val)
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
function handleAudioDeviceChange(data)

  -- https://www.hammerspoon.org/docs/hs.audiodevice.watcher.html#setCallback
  if data == "dOut" then
    logger:w("Audio device changed: " .. data)

    device = hs.audiodevice.defaultOutputDevice()
    level = 0

    if device:name() == "FiiO BTR5" then
      hs.alert("Skipping: FiiO BTR5")
      return
      -- level = 100
    end

    device:setMuted(false)
    device:setOutputVolume(level)
    device:setBalance(0.5)

    hs.inspect.inspect(device)

    local text = hs.styledtext.new("Output\n" .. device:name(), {
        color = { hex = "#FFFFFF", alpha = 1},
        font = { size = 30 },
    })

    hs.alert(text) -- "OUTPUT: " .. device:name())

    -- for _, device in pairs(hs.audiodevice.allInputDevices()) do
    --   device:setInputMuted(state)
    -- end
  end

end

-- -----------------------------------------------
-- WATCHERS --------------------------------------
-- -----------------------------------------------

-- Get list of screens and refresh that list whenever screens are (un)plugged
local screens = hs.screen.allScreens()
local screenwatcher = hs.screen.watcher.new(function()
    screens = hs.screen.allScreens()
    logger:w("screens: " .. screens)
end)
screenwatcher:start()

-- Audio Device
-- -----------------------------------------------
if not hs.audiodevice.watcher.isRunning() then
  hs.audiodevice.watcher.setCallback(function(data)
    handleAudioDeviceChange(data)
  end)

  hs.audiodevice.watcher.stop()
  hs.audiodevice.watcher.start()
end


-- Application
-- -----------------------------------------------
globalAppWatcher = false

local function appCallback(name, event, app)
  if event == hs.application.watcher.activated then
    logger:w("App activated: " .. name)

    if hasValue(appsToCenter, name) then
      logger:w("Centering: " .. name)

      toScreen = nil
      inBounds = true
      hs.window.focusedWindow():centerOnScreen(toScreen, inBounds)
    end
  end
end

if not globalAppWatcher then
  globalAppWatcher = application.watcher.new(appCallback)

  if globalAppWatcher.isRunning then
    globalAppWatcher:stop()
  end

  globalAppWatcher:start()
end

-- ReloadConfiguration
-- -----------------------------------------------
spoon.ReloadConfiguration:start()

-- -----------------------------------------------
-- -----------------------------------------------
-- -----------------------------------------------
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

hs.hotkey.bind(movementAppplicationLaunchOrFocus, ";", function()
    hs.hints.windowHints()
end)

-- -----------------------------------------------
-- WINDOW-HINTS ----------------------------------
-- -----------------------------------------------
hs.hotkey.bind(movementAppplicationLaunchOrFocus, ";", hs.hints.windowHints)

-- -----------------------------------------------
-- EXPOSE ----------------------------------------
-- -----------------------------------------------
hs.hotkey.bind(movementAppplicationLaunchOrFocusSecondary,';', function()
  local options = {
    showThumbnails = true,
    showTitles = false,
    includeOtherSpaces=false,
    includeNonVisible=false,
    highlightThumbnailAlpha = 1,
    highlightThumbnailStrokeWidth = 4,
    highlightColor = {0.9,0.9,0.9,0.5},
    backgroundColor = {0, 0, 0, 0.8},
  }

  local filter = hs.window.filter.new(false):setAppFilter('iTerm2', false)

  -- filter.ignoreAlways['iTerm'] = true
  -- filter:rejectApp('iTerm')

  local expose = hs.expose.new(filter, options)

  expose:toggleShow()
end)

-- -----------------------------------------------
-- SWITCHER --------------------------------------
-- -----------------------------------------------
--{{{
-- set up your windowfilter

local filter = hs.window.filter.new(false):setAppFilter('iTerm2', false)
local switcher = hs.window.switcher.new() -- default windowfilter: only visible windows, all Spaces

switcher.ui.highlightColor = {0,0,0,0.5}
-- switcher.ui.thumbnailSize = 128
switcher.ui.thumbnailSize = 400
-- switcher.ui.selectedThumbnailSize = 384
switcher.ui.selectedThumbnailSize = 500
switcher.ui.backgroundColor = {0.125, 0.125, 0.125, 0.8}
-- switcher.ui.textSize = 12
switcher.ui.fontName = 'SF Pro'
switcher.ui.titleBackgroundColor = {0,0,0,0.2}
switcher.ui.showTitles = false
switcher.ui.showSelectedTitle = false
switcher.ui.showSelectedThumbnail = false

--}}}

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


-- Center window
hs.hotkey.bind({"ctrl", "cmd"}, "0", function()
  toScreen = nil
  inBounds = true
  hs.window.focusedWindow():centerOnScreen(toScreen, inBounds)
end)

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

function centerOnScreen()
  toScreen = nil
  inBounds = true
  hs.window.focusedWindow():centerOnScreen(toScreen, inBounds)
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

-- -----------------------------------------------
-- WINDOW-ADJUSTMENT -----------------------------
-- -----------------------------------------------
function modifyWindowHeight(delta)
  local win = hs.window.focusedWindow()
  local f = win:frame()
  local screen = win:screen()
  local max = screen:frame()

  f.y = f.y - math.floor(delta/2)
  f.h = f.h + delta
  win:setFrame(f)
end

function modifyWindowWidth(delta)
  local win = hs.window.focusedWindow()
  local f = win:frame()
  local screen = win:screen()
  local max = screen:frame()

  f.x = f.x - math.floor(delta/2)
  f.w = f.w + delta
  win:setFrame(f)
end

function modifyWindowSize(delta)
  modifyWindowWidth(delta)
  modifyWindowHeight(delta)
end

function getWindowAdjustmentDelta(delta)
  local win = hs.window.focusedWindow()
  local screen = win:screen()
  local max = screen:frame()

  local screenWidth = max.w;
  local screenHeight = max.h;

  local deltaWidth = screenWidth / windowAdjustmentDelta;
  local deltaHeight = screenHeight / windowAdjustmentDelta;

  return deltaWidth, deltaHeight;
end

-- local values = {getWindowAdjustmentDelta(windowAdjustmentDelta)}

-- -----------------------------------------------
-- HOTKEYS ---------------------------------------
-- -----------------------------------------------

-- Applications
-- -----------------------------------------------
bindApplicationFocus("I", default_browser_name)
bindApplicationFocusSecondary("I", secondary_browser_name)
bindApplicationFocus("T", "Todoist")
bindApplicationFocus("P", "Preview")
hs.hotkey.bind(movementAppplicationLaunchOrFocusSecondary, "P", function() confirmOnEnter("Adobe Photoshop 2022") end)
bindApplicationFocus("F", "Finder")
bindApplicationFocusSecondary("F", "Figma")
bindApplicationFocus("Z", "zoom.us")
hs.hotkey.bind(movementAppplicationLaunchOrFocusSecondary, "D", function() confirmOnEnter("Discord") end)
-- bindApplicationFocus("E", "Obsidian")
bindApplicationFocusSecondary("E", "Element")
bindApplicationFocusSecondary("V", "Visual Studio Code")
bindApplicationFocus("V", "IINA")
bindApplicationFocus("G", "Gmail")
bindApplicationFocus("U", "Unraid")
bindApplicationFocus("H", "Home Assistant")
bindApplicationFocusSecondary("H", "Home Assistant")

-- Special
-- -----------------------------------------------
hs.hotkey.bind({"ctrl"}, "Space", function() hs.application.launchOrFocus("iTerm") end)

-- Switcher
-- -----------------------------------------------
hs.hotkey.bind({"cmd", "ctrl"}, ";", function()switcher:next()end)
hs.hotkey.bind({"cmd", "ctrl", "shift"}, ";", function()switcher:previous()end)


-- -----------------------------------------------
-- -----------------------------------------------
-- -----------------------------------------------
hs.hotkey.bind(movement, "Up", fullscreen)
hs.hotkey.bind(movement, "Down", middle)

hs.hotkey.bind({"ctrl", "cmd"}, "0", centerOnScreen)

hs.hotkey.bind(movementWindowAdjustment, "Left", function()
  modifyWindowWidth(-windowAdjustmentDelta)
end)

hs.hotkey.bind(movementWindowAdjustment, "Right", function()
  modifyWindowWidth(windowAdjustmentDelta)
end)

hs.hotkey.bind(movementWindowAdjustment, "Up", function()
  modifyWindowHeight(windowAdjustmentDelta)
end)

hs.hotkey.bind(movementWindowAdjustment, "Down", function()
  modifyWindowHeight(-windowAdjustmentDelta)
end)

hs.hotkey.bind(movementWindowAdjustment, "=", function()
  modifyWindowSize(windowAdjustmentDelta)
end)

hs.hotkey.bind(movementWindowAdjustment, "-", function()
  modifyWindowSize(-windowAdjustmentDelta)
end)

--------------------------------------------------
-- ALERT->CONFIG-LOADED --------------------------
--------------------------------------------------
hs.alert("Hammerspon Config Loaded")
