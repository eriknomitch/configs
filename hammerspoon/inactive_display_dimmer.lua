-- ==============================================
-- INACTIVE DISPLAY DIMMER ======================
-- ==============================================
-- Dims inactive displays when using multiple monitors,
-- helping focus attention on the active screen.

local M = {}

-- ------------------------------------------------
-- CONFIG -----------------------------------------
-- ------------------------------------------------

M.config = {
	enabled = true,
	dimAlpha = 0.3, -- 0.0 (no dim) to 1.0 (black)
}

-- ------------------------------------------------
-- STATE ------------------------------------------
-- ------------------------------------------------

local overlays = {} -- screen UUID -> canvas overlay
local windowFilter = nil
local screenWatcher = nil
local log = hs.logger.new("DisplayDimmer", "debug")

-- ------------------------------------------------
-- OVERLAY MANAGEMENT -----------------------------
-- ------------------------------------------------

local function createOverlay(screen)
	local frame = screen:fullFrame()
	local canvas = hs.canvas.new(frame)

	canvas:appendElements({
		type = "rectangle",
		action = "fill",
		fillColor = { black = 1, alpha = M.config.dimAlpha },
		frame = { x = 0, y = 0, w = frame.w, h = frame.h },
	})

	-- Set canvas to be above normal windows but below alerts
	canvas:level(hs.canvas.windowLevels.overlay)
	canvas:behavior(hs.canvas.windowBehaviors.canJoinAllSpaces)
	canvas:clickActivating(false)

	return canvas
end

local function clearOverlays()
	for uuid, canvas in pairs(overlays) do
		if canvas then
			canvas:delete()
		end
	end
	overlays = {}
end

local function updateDimOverlays()
	if not M.config.enabled then
		clearOverlays()
		return
	end

	local screens = hs.screen.allScreens()

	-- Only dim when there are multiple screens
	if #screens <= 1 then
		clearOverlays()
		return
	end

	-- Get the screen with the focused window
	local focusedWindow = hs.window.focusedWindow()
	local activeScreen = nil

	if focusedWindow then
		activeScreen = focusedWindow:screen()
	else
		-- Fall back to main screen if no window is focused
		activeScreen = hs.screen.mainScreen()
	end

	local activeScreenUUID = activeScreen and activeScreen:getUUID() or nil

	-- Build set of current screen UUIDs
	local currentScreenUUIDs = {}
	for _, screen in ipairs(screens) do
		currentScreenUUIDs[screen:getUUID()] = screen
	end

	-- Remove overlays for screens that no longer exist
	for uuid, canvas in pairs(overlays) do
		if not currentScreenUUIDs[uuid] then
			canvas:delete()
			overlays[uuid] = nil
		end
	end

	-- Update overlays for each screen
	for _, screen in ipairs(screens) do
		local uuid = screen:getUUID()
		local isActive = (uuid == activeScreenUUID)

		if isActive then
			-- Remove overlay from active screen
			if overlays[uuid] then
				overlays[uuid]:hide()
			end
		else
			-- Create or show overlay on inactive screens
			if not overlays[uuid] then
				overlays[uuid] = createOverlay(screen)
			else
				-- Update frame in case screen resolution changed
				local frame = screen:fullFrame()
				overlays[uuid]:frame(frame)
			end
			overlays[uuid]:show()
		end
	end
end

-- ------------------------------------------------
-- PUBLIC API -------------------------------------
-- ------------------------------------------------

function M.toggle()
	M.config.enabled = not M.config.enabled
	updateDimOverlays()

	local status = M.config.enabled and "ON" or "OFF"
	hs.alert.show("Display Dimmer: " .. status)
	log:d("Display dimmer toggled: " .. status)
end

function M.enable()
	M.config.enabled = true
	updateDimOverlays()
	log:d("Display dimmer enabled")
end

function M.disable()
	M.config.enabled = false
	clearOverlays()
	log:d("Display dimmer disabled")
end

function M.setDimLevel(alpha)
	if alpha < 0 then
		alpha = 0
	end
	if alpha > 1 then
		alpha = 1
	end

	M.config.dimAlpha = alpha

	-- Recreate overlays with new alpha
	clearOverlays()
	updateDimOverlays()

	log:d("Display dimmer alpha set to: " .. alpha)
end

function M.isEnabled()
	return M.config.enabled
end

-- ------------------------------------------------
-- WATCHERS ---------------------------------------
-- ------------------------------------------------

local function startWatchers()
	-- Window focus watcher
	windowFilter = hs.window.filter.new():setDefaultFilter()
	windowFilter:subscribe(hs.window.filter.windowFocused, function(window, appName, event)
		updateDimOverlays()
	end)

	-- Screen configuration watcher (connect/disconnect)
	screenWatcher = hs.screen.watcher.new(function()
		log:d("Screen configuration changed")
		-- Small delay to let the system settle
		hs.timer.doAfter(0.5, function()
			updateDimOverlays()
		end)
	end)
	screenWatcher:start()

	log:d("Display dimmer watchers started")
end

local function stopWatchers()
	if windowFilter then
		windowFilter:unsubscribeAll()
		windowFilter = nil
	end

	if screenWatcher then
		screenWatcher:stop()
		screenWatcher = nil
	end

	log:d("Display dimmer watchers stopped")
end

-- ------------------------------------------------
-- INITIALIZATION ---------------------------------
-- ------------------------------------------------

function M.start()
	startWatchers()
	updateDimOverlays()
	log:d("Display dimmer started")
end

function M.stop()
	stopWatchers()
	clearOverlays()
	log:d("Display dimmer stopped")
end

-- Auto-start on require
M.start()

return M
