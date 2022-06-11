-- ==============================================
-- HAMMERSPOON->UTILITY =========================
-- ==============================================

local logger = hs.logger.new("utility")

logger.i("Loading utility.lua")

-- ------------------------------------------------
-- CONFIG -----------------------------------------
-- ------------------------------------------------
configValues = {}

function setConfigForUtility(config)
    for key, value in pairs(config) do
        configValues[key] = value
    end
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
-- UTILITY ---------------------------------------
-- -----------------------------------------------

-- Display a notification
function notify(title, message)
  hs.notify.new({title=title, informativeText=message}):send()
end

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

function moveWindowLeft()
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

