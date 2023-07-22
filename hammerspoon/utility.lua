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
-- function notify(title, message)
--   hs.notify.new({title=title, informativeText=message}):send()
-- end

function notify(title, message, icon, stayActive)
	icon = icon or ""
	duration = stayActive and 0 or 5
	hs.notify
		.new({
			title = title,
			informativeText = message,
			setIdImage = icon,
			withdrawAfter = duration,
		})
		:send()
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

	local nextSpaceDownEvent = hs.eventtap.event.newKeyEvent({ "ctrl" }, direction, true)
	nextSpaceDownEvent:post()
	hs.timer.usleep(150000)

	local nextSpaceUpEvent = hs.eventtap.event.newKeyEvent({ "ctrl" }, direction, false)
	nextSpaceUpEvent:post()
	hs.timer.usleep(150000)

	local mouseReleaseEvent = hs.eventtap.event.newMouseEvent(hs.eventtap.event.types.leftmouseup, clickPoint)
	mouseReleaseEvent:post()
	hs.timer.usleep(150000)

	mouse.setAbsolutePosition(mouseOrigin)
end

function moveWindowLeft() end

function centerOnScreen()
	toScreen = nil
	inBounds = true
	hs.window.focusedWindow():centerOnScreen(toScreen, inBounds)
end

function middle()
	local win = hs.window.focusedWindow()
	local f = win:frame()
	local screen = win:screen()
	local max = screen:frame()

	f.x = max.x + (max.w * 1 / 8)
	f.y = max.y
	f.w = max.w * 3 / 4
	f.h = max.h

	win:setFrame(f)
end

-- local function sendSystemKey(key)
--     hs.eventtap.event.newSystemKeyEvent(key, true):post()
--     hs.eventtap.event.newSystemKeyEvent(key, false):post()
-- end

-- local volume = {
--     up   = function() sendSystemKey("SOUND_UP") end,
--     down = function() sendSystemKey("SOUND_DOWN") end,
--     mute = function() sendSystemKey("MUTE") end,
-- }

function setVolumeOfCurrent(diff)
	current = hs.audiodevice.current()
	volume = current.volume + diff

	if volume > 100.0 then
		volume = 100.0
	elseif volume < 0.0 then
		volume = 0.0
	end

	current.device:setVolume(volume)
	hs.alert(math.floor(current.volume))
end

-- -- Function to increase volume
-- function increaseVolume()
-- 	os.execute("osascript -e 'set volume output volume (output volume of (get volume settings) + 5)'")
--
-- 	-- Display a hammer notification with the new volume level
-- 	notify("Volume", "Volume increased to " .. hs.audiodevice.defaultOutputDevice():volume() .. "%")
--
-- 	-- .new({
-- 	-- 	title = "Volume",
-- 	-- 	informativeText = "Volume increased to " .. hs.audiodevice.defaultOutputDevice():volume() .. "%",
-- 	-- })
-- 	-- :send()
-- end

function createProgressBar(percentage)
	local barLength = 20
	local completedLength = math.floor(barLength * percentage)
	-- local progressBar = string.rep("▋", completedLength) .. string.rep("░", barLength - completedLength)
	local progressBar = string.rep("▮", completedLength) .. string.rep("▁", barLength - completedLength)

	return progressBar

	-- return progressBar .. " " .. math.floor(percentage * 100) .. "%"
end

function changeVolume(diff)
	return function()
		local current = hs.audiodevice.defaultOutputDevice():volume()
		local new = math.min(100, math.max(0, math.floor(current + diff)))
		if new > 0 then
			hs.audiodevice.defaultOutputDevice():setMuted(false)
		end

		local progressBar = createProgressBar(new / 100)
		local message = progressBar

		hs.alert.closeAll(0.0)
		hs.alert.show(message)
		hs.audiodevice.defaultOutputDevice():setVolume(new)
	end
end

-- Binding the key combination
hs.hotkey.bind({ "cmd", "shift" }, "Up", changeVolume(5))
hs.hotkey.bind({ "cmd", "shift" }, "Down", changeVolume(-5))
