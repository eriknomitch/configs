-- ==============================================
-- ACTIVE SCREEN BORDER ===========================
-- ==============================================
-- Draws a colored border around the screen with
-- keyboard focus, helping identify the active
-- display on multi-monitor setups.

local M = {}

-- ------------------------------------------------
-- CONFIG -----------------------------------------
-- ------------------------------------------------

M.config = {
	enabled = false,
	borderColor = { red = 0.3, green = 0.6, blue = 1.0, alpha = 0.7 },
	borderWidth = 4,
}

-- ------------------------------------------------
-- STATE ------------------------------------------
-- ------------------------------------------------

local borderCanvas = nil
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

local function clearBorder()
	if borderCanvas then
		borderCanvas:delete()
		borderCanvas = nil
	end
end

local function updateBorder()
	if not M.config.enabled then
		clearBorder()
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

	if not activeScreen then
		clearBorder()
		return
	end

	-- Check if border needs to move to a different screen
	if borderCanvas then
		local currentFrame = borderCanvas:frame()
		local activeFrame = activeScreen:fullFrame()

		if currentFrame.x == activeFrame.x and currentFrame.y == activeFrame.y
			and currentFrame.w == activeFrame.w and currentFrame.h == activeFrame.h then
			-- Border is already on the correct screen
			return
		end
	end

	-- Recreate border on the active screen
	clearBorder()
	borderCanvas = createBorder(activeScreen)
	borderCanvas:show()

	log:d("Border moved to screen: " .. activeScreen:name())
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
	hs.alert.show("Screen Border: " .. status)
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
		clearBorder()
		updateBorder()
	end
	log:d("Screen border color updated")
end

function M.setWidth(width)
	M.config.borderWidth = width
	if M.config.enabled then
		clearBorder()
		updateBorder()
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
		updateBorder()
	end)

	-- Screen configuration watcher
	screenWatcher = hs.screen.watcher.new(function()
		log:d("Screen configuration changed")
		hs.timer.doAfter(0.5, function()
			updateBorder()
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
	updateBorder()
	log:d("Screen border started")
end

function M.stop()
	stopWatchers()
	clearBorder()
	log:d("Screen border stopped")
end

return M
