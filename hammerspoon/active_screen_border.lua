-- ==============================================
-- INACTIVE SCREEN BORDER =========================
-- ==============================================
-- Draws subtle colored borders around inactive
-- screens, helping identify displays that don't
-- have keyboard focus on multi-monitor setups.

local M = {}

-- ------------------------------------------------
-- CONFIG -----------------------------------------
-- ------------------------------------------------

M.config = {
	enabled = false,
	borderColor = { red = 0.3, green = 0.6, blue = 1.0, alpha = 0.5 },
	borderWidth = 3,
}

-- ------------------------------------------------
-- STATE ------------------------------------------
-- ------------------------------------------------

local borders = {} -- screen UUID -> canvas
local windowFilter = nil
local screenWatcher = nil
local log = hs.logger.new("ScreenBorder", "debug")

-- ------------------------------------------------
-- BORDER MANAGEMENT ------------------------------
-- ------------------------------------------------

local function createBorder(screen)
	local frame = screen:fullFrame()

	local canvas = hs.canvas.new(frame)
	canvas:level(hs.canvas.windowLevels.overlay)
	canvas:behavior(hs.canvas.windowBehaviors.canJoinAllSpaces)
	canvas:clickActivating(false)

	-- Draw border as four rectangles (top, bottom, left, right)
	local bw = M.config.borderWidth
	local color = M.config.borderColor

	canvas:appendElements(
		-- Top border
		{
			type = "rectangle",
			action = "fill",
			fillColor = color,
			frame = { x = 0, y = 0, w = frame.w, h = bw },
		},
		-- Bottom border
		{
			type = "rectangle",
			action = "fill",
			fillColor = color,
			frame = { x = 0, y = frame.h - bw, w = frame.w, h = bw },
		},
		-- Left border
		{
			type = "rectangle",
			action = "fill",
			fillColor = color,
			frame = { x = 0, y = bw, w = bw, h = frame.h - bw * 2 },
		},
		-- Right border
		{
			type = "rectangle",
			action = "fill",
			fillColor = color,
			frame = { x = frame.w - bw, y = bw, w = bw, h = frame.h - bw * 2 },
		}
	)

	return canvas
end

local function clearBorders()
	for uuid, canvas in pairs(borders) do
		if canvas then
			canvas:delete()
		end
	end
	borders = {}
end

local function updateBorders()
	if not M.config.enabled then
		clearBorders()
		return
	end

	local screens = hs.screen.allScreens()

	-- Only show borders when there are multiple screens
	if #screens <= 1 then
		clearBorders()
		return
	end

	-- Get the screen with the focused window
	local focusedWindow = hs.window.focusedWindow()
	local activeScreen = nil

	if focusedWindow then
		activeScreen = focusedWindow:screen()
	else
		activeScreen = hs.screen.mainScreen()
	end

	local activeScreenUUID = activeScreen and activeScreen:getUUID() or nil

	-- Build set of current screen UUIDs
	local currentScreenUUIDs = {}
	for _, screen in ipairs(screens) do
		currentScreenUUIDs[screen:getUUID()] = screen
	end

	-- Remove borders for screens that no longer exist
	for uuid, canvas in pairs(borders) do
		if not currentScreenUUIDs[uuid] then
			canvas:delete()
			borders[uuid] = nil
		end
	end

	-- Update borders for each screen
	for _, screen in ipairs(screens) do
		local uuid = screen:getUUID()
		local isActive = (uuid == activeScreenUUID)

		if isActive then
			-- Remove border from active screen
			if borders[uuid] then
				borders[uuid]:hide()
			end
		else
			-- Create or show border on inactive screens
			if not borders[uuid] then
				borders[uuid] = createBorder(screen)
			else
				-- Update frame in case screen resolution changed
				local frame = screen:fullFrame()
				borders[uuid]:frame(frame)
			end
			borders[uuid]:show()
		end
	end

	log:d("Borders updated, active screen: " .. (activeScreen and activeScreen:name() or "none"))
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
	hs.alert.show("Inactive Screen Border: " .. status)
	log:d("Screen border toggled: " .. status)
end

function M.enable()
	M.config.enabled = true
	M.start()
	log:d("Screen border enabled")
end

function M.disable()
	M.config.enabled = false
	M.stop()
	log:d("Screen border disabled")
end

function M.setColor(color)
	M.config.borderColor = color
	if M.config.enabled then
		clearBorders()
		updateBorders()
	end
	log:d("Screen border color updated")
end

function M.setWidth(width)
	M.config.borderWidth = width
	if M.config.enabled then
		clearBorders()
		updateBorders()
	end
	log:d("Screen border width set to: " .. width)
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
		updateBorders()
	end)

	-- Screen configuration watcher
	screenWatcher = hs.screen.watcher.new(function()
		log:d("Screen configuration changed")
		hs.timer.doAfter(0.5, function()
			updateBorders()
		end)
	end)
	screenWatcher:start()

	log:d("Screen border watchers started")
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

	log:d("Screen border watchers stopped")
end

-- ------------------------------------------------
-- INITIALIZATION ---------------------------------
-- ------------------------------------------------

function M.start()
	if not M.config.enabled then
		return
	end

	startWatchers()
	updateBorders()
	log:d("Screen border started")
end

function M.stop()
	stopWatchers()
	clearBorders()
	log:d("Screen border stopped")
end

return M
