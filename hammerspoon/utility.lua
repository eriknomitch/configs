-- ==============================================
-- HAMMERSPOON->UTILITY =========================
-- ==============================================

log = hs.logger.new("Hammerspoon")
log.setLogLevel("debug")

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
function moveWindowOneSpace(win, direction)
	local activeSpace = hs.spaces.activeSpaceOnScreen(win:screen())

	local spaces = hs.spaces.windowSpaces(win)

	local allSpaces = hs.spaces.allSpaces()

	-- log.i("win screen: " .. hs.inspect(win:screen():id))

	-- Log the spaces
	log.i("Spaces: " .. hs.inspect(spaces))
	log.i("Active Space: " .. hs.inspect(activeSpace))
	log.i("All Spaces: " .. hs.inspect(allSpaces))

	local nextSpace = nil

	if direction == "left" then
		-- nextSpace = hs.fnutils.find(spaces, function(space)
		-- 	return space.x < activeSpace.x
		-- end)
	elseif direction == "right" then
		-- nextSpace = hs.fnutils.find(spaces, function(space)
		-- 	return space.x > activeSpace.x
		-- end)
	end

	-- local mouseOrigin = hs.mouse.getAbsolutePosition()
	-- local win = hs.window.focusedWindow()
	-- local clickPoint = win:zoomButtonRect()
	--
	-- clickPoint.x = clickPoint.x + clickPoint.w + 5
	-- clickPoint.y = clickPoint.y + (clickPoint.h / 2)
	--
	-- local mouseClickEvent = hs.eventtap.event.newMouseEvent(hs.eventtap.event.types.leftmousedown, clickPoint)
	-- mouseClickEvent:post()
	-- hs.timer.usleep(150000)
	--
	-- local nextSpaceDownEvent = hs.eventtap.event.newKeyEvent({ "ctrl" }, direction, true)
	-- nextSpaceDownEvent:post()
	-- hs.timer.usleep(150000)
	--
	-- local nextSpaceUpEvent = hs.eventtap.event.newKeyEvent({ "ctrl" }, direction, false)
	-- nextSpaceUpEvent:post()
	-- hs.timer.usleep(150000)
	--
	-- local mouseReleaseEvent = hs.eventtap.event.newMouseEvent(hs.eventtap.event.types.leftmouseup, clickPoint)
	-- mouseReleaseEvent:post()
	-- hs.timer.usleep(150000)
	--
	-- mouse.setAbsolutePosition(mouseOrigin)
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

	local progressBar = string.rep("", completedLength) .. string.rep("", barLength - completedLength)

	return progressBar

	-- return progressBar .. " " .. math.floor(percentage * 100) .. "%"
end

-- function createProgressBar(percentage)
-- 	local barLength = 20
-- 	local completedLength = math.floor(barLength * percentage)
-- 	local progressBar = string.rep("#", completedLength) .. string.rep("-", barLength - completedLength)
--
-- 	return progressBar .. " " .. math.floor(percentage * 100) .. "%"
-- end

function padInteger(num, width, paddingChar)
	-- Convert the integer to a string
	local numStr = tostring(num)

	-- Calculate the number of padding characters needed
	local paddingLength = width - #numStr

	-- Ensure the padding length is non-negative
	if paddingLength < 0 then
		paddingLength = 0
	end

	-- Create the padding string
	local paddingStr = string.rep(paddingChar, paddingLength)

	-- Concatenate the padding string with the integer string
	local paddedStr = paddingStr .. numStr

	return paddedStr
end

function changeVolume(diff)
	return function()
		local current = hs.audiodevice.defaultOutputDevice():volume()
		local new = math.min(100, math.max(0, math.floor(current + diff)))

		-- Mute the audio if the new volume is 0
		hs.audiodevice.defaultOutputDevice():setMuted(new == 0)

		local progressBar = createProgressBar(new / 100)

		local endChar = ""

		-- Adjust prefix and suffix based on volume levels
		local prefix = new == 0 and "" or ""
		local suffix = new == 100 and "" or ""

		local displayPercentage = false

		local message = prefix .. progressBar .. suffix

		local percentageSuffix = " " .. padInteger(new, 3, " ") .. "%"

		if displayPercentage then
			message = message .. percentageSuffix
		end

		hs.alert.closeAll(0.0)

		-- Adjust the text color based on the volume level
		local textColor = { alpha = 1, red = 1 - (100 - new) / 100, green = (100 - new) / 100, blue = 0 }
		local fillColor = { alpha = 1, red = 1 - (100 - new) / 100, green = (100 - new) / 100, blue = 0, alpha = 0.9 }

		-- strokeAlpha should be 0 until the volume is high
		local strokeAlpha = new >= 90 and 0.5 or 0

		hs.alert.show(message, {
			textSize = 24,
			height = 50,
			-- textColor = { white = 1, alpha = (100 - new) / 100 },
			textColor = { white = 1, alpha = 1 },
			-- textColor = { white = 1, alpha = 1 },
			-- textColor = textColor,
			-- strokeWidth = new >= 80 and 5 or 0,
			strokeWidth = 6,
			strokeColor = textColor,
			-- strokeColor = { red = 1, alpha = strokeAlpha },
			fillColor = fillColor,
			radius = 10,
			atScreenEdge = 1,
			padding = 10,
			-- margins = { top = 20, bottom = 20, left = 0, right = 0 },
		}, 2.0)

		hs.audiodevice.defaultOutputDevice():setVolume(new)
	end
end

-- Binding the key combination
-- hs.hotkey.bind({ "cmd", "shift" }, "Up", changeVolume(10))
-- hs.hotkey.bind({ "cmd", "shift" }, "Down", changeVolume(-10))
-- hs.hotkey.bind({ "cmd", "shift" }, "Left", changeVolume(-5))
-- hs.hotkey.bind({ "cmd", "shift" }, "Right", changeVolume(5))
