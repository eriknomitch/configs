-- ==============================================
-- FOCUS CHANGE HANDLER ===========================
-- ==============================================
-- Handles focus changes between screens:
-- - Optional flash overlay when focus moves screens
-- - Optional mouse warp to follow focus between screens

local M = {}

-- ------------------------------------------------
-- CONFIG -----------------------------------------
-- ------------------------------------------------

M.config = {
	-- Flash overlay on screen change
	flashEnabled = false,
	flashColor = { white = 1, alpha = 0.15 },
	flashDuration = 0.15, -- seconds

	-- Warp mouse to window on screen change
	warpEnabled = true,
}

-- ------------------------------------------------
-- STATE ------------------------------------------
-- ------------------------------------------------

local flashCanvas = nil
local fadeTimer = nil
local windowFilter = nil
local sharedFilter = nil
local isSubscribed = false
local lastFocusedScreenUUID = nil
local log = hs.logger.new("FocusChange", "debug")

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

-- ------------------------------------------------
-- WARP MANAGEMENT --------------------------------
-- ------------------------------------------------

local function warpMouseToWindow(window)
	if not window then
		return
	end

	local frame = window:frame()
	local center = hs.geometry.point(frame.x + frame.w / 2, frame.y + frame.h / 2)
	hs.mouse.absolutePosition(center)

	log:d("Mouse warped to window: " .. (window:title() or "untitled"))
end

-- ------------------------------------------------
-- FOCUS HANDLER ----------------------------------
-- ------------------------------------------------

local function onWindowFocused(window, appName, event)
	if not window then
		return
	end

	local screen = window:screen()
	if not screen then
		return
	end

	local currentScreenUUID = screen:getUUID()
	local screenChanged = lastFocusedScreenUUID and lastFocusedScreenUUID ~= currentScreenUUID

	-- Handle screen change
	if screenChanged then
		-- Flash if enabled
		if M.config.flashEnabled then
			flash(screen)
		end

		-- Warp mouse if enabled
		if M.config.warpEnabled then
			warpMouseToWindow(window)
		end
	end

	lastFocusedScreenUUID = currentScreenUUID
end

-- ------------------------------------------------
-- PUBLIC API -------------------------------------
-- ------------------------------------------------

-- Flash toggle
function M.toggleFlash()
	M.config.flashEnabled = not M.config.flashEnabled
	M.ensureWatchers()

	local status = M.config.flashEnabled and "ON" or "OFF"
	hs.alert.show("Focus Flash: " .. status)
	log:d("Focus flash toggled: " .. status)
end

-- Warp toggle
function M.toggleWarp()
	M.config.warpEnabled = not M.config.warpEnabled
	M.ensureWatchers()

	local status = M.config.warpEnabled and "ON" or "OFF"
	hs.alert.show("Focus Warp: " .. status)
	log:d("Focus warp toggled: " .. status)
end

-- Legacy toggle (for backwards compatibility) - toggles flash
function M.toggle()
	M.toggleFlash()
end

function M.enableFlash()
	M.config.flashEnabled = true
	M.ensureWatchers()
	log:d("Focus flash enabled")
end

function M.disableFlash()
	M.config.flashEnabled = false
	M.ensureWatchers()
	log:d("Focus flash disabled")
end

function M.enableWarp()
	M.config.warpEnabled = true
	M.ensureWatchers()
	log:d("Focus warp enabled")
end

function M.disableWarp()
	M.config.warpEnabled = false
	M.ensureWatchers()
	log:d("Focus warp disabled")
end

function M.setColor(color)
	M.config.flashColor = color
	log:d("Focus flash color updated")
end

function M.setDuration(duration)
	M.config.flashDuration = duration
	log:d("Focus flash duration set to: " .. duration)
end

function M.isFlashEnabled()
	return M.config.flashEnabled
end

function M.isWarpEnabled()
	return M.config.warpEnabled
end

-- Legacy compatibility
function M.isEnabled()
	return M.config.flashEnabled
end

function M.setSharedFilter(filter)
	sharedFilter = filter
end

-- ------------------------------------------------
-- WATCHERS ---------------------------------------
-- ------------------------------------------------

local function startWatchers()
	if isSubscribed then
		return -- Already running
	end

	-- Initialize last focused screen
	local focusedWindow = hs.window.focusedWindow()
	if focusedWindow then
		local screen = focusedWindow:screen()
		if screen then
			lastFocusedScreenUUID = screen:getUUID()
		end
	end

	-- Window focus watcher (use shared filter if available)
	if sharedFilter then
		sharedFilter:subscribe(hs.window.filter.windowFocused, onWindowFocused)
	else
		windowFilter = hs.window.filter.new():setDefaultFilter()
		windowFilter:subscribe(hs.window.filter.windowFocused, onWindowFocused)
	end
	isSubscribed = true

	log:d("Focus change watchers started")
end

local function stopWatchers()
	if isSubscribed then
		local filter = sharedFilter or windowFilter
		if filter then
			filter:unsubscribe(onWindowFocused)
		end
		isSubscribed = false
	end
	if windowFilter then
		windowFilter = nil
	end

	log:d("Focus change watchers stopped")
end

-- Ensure watchers are running if any feature is enabled
function M.ensureWatchers()
	local needWatchers = M.config.flashEnabled or M.config.warpEnabled

	if needWatchers and not isSubscribed then
		startWatchers()
	elseif not needWatchers and isSubscribed then
		stopWatchers()
	end
end

-- ------------------------------------------------
-- INITIALIZATION ---------------------------------
-- ------------------------------------------------

function M.start()
	M.ensureWatchers()
	log:d("Focus change handler started")
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

	log:d("Focus change handler stopped")
end

-- Started from init.lua with shared window filter

return M
