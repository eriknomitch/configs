-- ==============================================
-- FOCUS CHANGE FLASH =============================
-- ==============================================
-- Shows a brief flash overlay when keyboard focus
-- moves to a window on a different screen, helping
-- track focus changes on multi-display setups.

local M = {}

-- ------------------------------------------------
-- CONFIG -----------------------------------------
-- ------------------------------------------------

M.config = {
	enabled = false,
	flashColor = { white = 1, alpha = 0.15 },
	flashDuration = 0.15, -- seconds
}

-- ------------------------------------------------
-- STATE ------------------------------------------
-- ------------------------------------------------

local flashCanvas = nil
local fadeTimer = nil
local windowFilter = nil
local lastFocusedScreenUUID = nil
local log = hs.logger.new("FocusFlash", "debug")

-- ------------------------------------------------
-- FLASH MANAGEMENT -------------------------------
-- ------------------------------------------------

local function flash(screen)
	-- Clean up any existing flash
	if flashCanvas then
		flashCanvas:delete()
		flashCanvas = nil
	end
	if fadeTimer then
		fadeTimer:stop()
		fadeTimer = nil
	end

	local frame = screen:fullFrame()

	flashCanvas = hs.canvas.new(frame)
	flashCanvas:level(hs.canvas.windowLevels.overlay)
	flashCanvas:behavior(hs.canvas.windowBehaviors.canJoinAllSpaces)
	flashCanvas:clickActivating(false)

	flashCanvas:appendElements({
		type = "rectangle",
		action = "fill",
		fillColor = M.config.flashColor,
		frame = { x = 0, y = 0, w = frame.w, h = frame.h },
	})

	flashCanvas:show()

	-- Animate fade out
	local startTime = hs.timer.secondsSinceEpoch()
	local frameInterval = 1 / 60 -- 60 FPS
	local startAlpha = M.config.flashColor.alpha

	fadeTimer = hs.timer.doEvery(frameInterval, function()
		local elapsed = hs.timer.secondsSinceEpoch() - startTime
		local progress = elapsed / M.config.flashDuration

		if progress >= 1 then
			-- Animation complete
			if flashCanvas then
				flashCanvas:delete()
				flashCanvas = nil
			end
			if fadeTimer then
				fadeTimer:stop()
				fadeTimer = nil
			end
			return
		end

		-- Ease out fade
		local alpha = startAlpha * (1 - progress)
		if flashCanvas and flashCanvas[1] then
			flashCanvas[1].fillColor = {
				white = M.config.flashColor.white or 1,
				red = M.config.flashColor.red,
				green = M.config.flashColor.green,
				blue = M.config.flashColor.blue,
				alpha = alpha,
			}
		end
	end)

	log:d("Flash triggered on screen: " .. screen:name())
end

local function onWindowFocused(window, appName, event)
	if not M.config.enabled or not window then
		return
	end

	local screen = window:screen()
	if not screen then
		return
	end

	local currentScreenUUID = screen:getUUID()

	-- Only flash if focus moved to a different screen
	if lastFocusedScreenUUID and lastFocusedScreenUUID ~= currentScreenUUID then
		flash(screen)
	end

	lastFocusedScreenUUID = currentScreenUUID
end

-- ------------------------------------------------
-- PUBLIC API -------------------------------------
-- ------------------------------------------------

function M.toggle()
	M.config.enabled = not M.config.enabled

	if M.config.enabled then
		M.start()
	else
		M.stop()
	end

	local status = M.config.enabled and "ON" or "OFF"
	hs.alert.show("Focus Flash: " .. status)
	log:d("Focus flash toggled: " .. status)
end

function M.enable()
	M.config.enabled = true
	M.start()
	log:d("Focus flash enabled")
end

function M.disable()
	M.config.enabled = false
	M.stop()
	log:d("Focus flash disabled")
end

function M.setColor(color)
	M.config.flashColor = color
	log:d("Focus flash color updated")
end

function M.setDuration(duration)
	M.config.flashDuration = duration
	log:d("Focus flash duration set to: " .. duration)
end

function M.isEnabled()
	return M.config.enabled
end

-- ------------------------------------------------
-- WATCHERS ---------------------------------------
-- ------------------------------------------------

local function startWatchers()
	-- Initialize last focused screen
	local focusedWindow = hs.window.focusedWindow()
	if focusedWindow then
		local screen = focusedWindow:screen()
		if screen then
			lastFocusedScreenUUID = screen:getUUID()
		end
	end

	-- Window focus watcher
	windowFilter = hs.window.filter.new():setDefaultFilter()
	windowFilter:subscribe(hs.window.filter.windowFocused, onWindowFocused)

	log:d("Focus flash watchers started")
end

local function stopWatchers()
	if windowFilter then
		windowFilter:unsubscribeAll()
		windowFilter = nil
	end

	log:d("Focus flash watchers stopped")
end

-- ------------------------------------------------
-- INITIALIZATION ---------------------------------
-- ------------------------------------------------

function M.start()
	if not M.config.enabled then
		return
	end

	startWatchers()
	log:d("Focus flash started")
end

function M.stop()
	stopWatchers()

	if flashCanvas then
		flashCanvas:delete()
		flashCanvas = nil
	end
	if fadeTimer then
		fadeTimer:stop()
		fadeTimer = nil
	end

	log:d("Focus flash stopped")
end

return M
