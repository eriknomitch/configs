-- ==============================================
-- CURSOR LOCATOR =================================
-- ==============================================
-- Shows animated pulse circles around the cursor
-- when triggered via hotkey, helping locate the
-- cursor on multi-display setups.

local M = {}

-- ------------------------------------------------
-- CONFIG -----------------------------------------
-- ------------------------------------------------

M.config = {
	pulseColor = { red = 0.3, green = 0.6, blue = 1.0, alpha = 0.8 },
	pulseCount = 3,
	maxRadius = 80,
	duration = 0.5, -- Total animation duration in seconds
}

-- ------------------------------------------------
-- STATE ------------------------------------------
-- ------------------------------------------------

local canvas = nil
local animationTimer = nil
local log = hs.logger.new("CursorLocator", "debug")

-- ------------------------------------------------
-- ANIMATION --------------------------------------
-- ------------------------------------------------

local function showPulse()
	-- Clean up any existing animation
	if canvas then
		canvas:delete()
		canvas = nil
	end
	if animationTimer then
		animationTimer:stop()
		animationTimer = nil
	end

	local mousePos = hs.mouse.absolutePosition()
	local screen = hs.mouse.getCurrentScreen()
	local screenFrame = screen:fullFrame()

	-- Create canvas centered on cursor, large enough for the animation
	local canvasSize = M.config.maxRadius * 2 + 20
	local canvasFrame = {
		x = mousePos.x - canvasSize / 2,
		y = mousePos.y - canvasSize / 2,
		w = canvasSize,
		h = canvasSize,
	}

	canvas = hs.canvas.new(canvasFrame)
	canvas:level(hs.canvas.windowLevels.overlay + 1)
	canvas:behavior(hs.canvas.windowBehaviors.canJoinAllSpaces)
	canvas:clickActivating(false)

	-- Add pulse circle elements
	for i = 1, M.config.pulseCount do
		canvas:appendElements({
			type = "circle",
			action = "stroke",
			strokeColor = { red = M.config.pulseColor.red, green = M.config.pulseColor.green, blue = M.config.pulseColor.blue, alpha = 0 },
			strokeWidth = 3,
			center = { x = canvasSize / 2, y = canvasSize / 2 },
			radius = 0,
		})
	end

	canvas:show()

	-- Animation parameters
	local startTime = hs.timer.secondsSinceEpoch()
	local frameInterval = 1 / 60 -- 60 FPS

	animationTimer = hs.timer.doEvery(frameInterval, function()
		local elapsed = hs.timer.secondsSinceEpoch() - startTime
		local progress = elapsed / M.config.duration

		if progress >= 1 then
			-- Animation complete
			if canvas then
				canvas:delete()
				canvas = nil
			end
			if animationTimer then
				animationTimer:stop()
				animationTimer = nil
			end
			return
		end

		-- Update each pulse circle with staggered timing
		for i = 1, M.config.pulseCount do
			local pulseDelay = (i - 1) / M.config.pulseCount * 0.3
			local pulseProgress = math.max(0, (progress - pulseDelay) / (1 - pulseDelay))

			if pulseProgress > 0 and pulseProgress < 1 then
				local radius = pulseProgress * M.config.maxRadius
				local alpha = M.config.pulseColor.alpha * (1 - pulseProgress)

				canvas[i].radius = radius
				canvas[i].strokeColor = {
					red = M.config.pulseColor.red,
					green = M.config.pulseColor.green,
					blue = M.config.pulseColor.blue,
					alpha = alpha,
				}
				canvas[i].strokeWidth = 3 * (1 - pulseProgress * 0.5)
			else
				canvas[i].strokeColor.alpha = 0
			end
		end
	end)

	log:d("Cursor locator pulse triggered")
end

-- ------------------------------------------------
-- PUBLIC API -------------------------------------
-- ------------------------------------------------

function M.show()
	showPulse()
end

function M.setColor(color)
	M.config.pulseColor = color
	log:d("Cursor locator color updated")
end

function M.setMaxRadius(radius)
	M.config.maxRadius = radius
	log:d("Cursor locator max radius set to: " .. radius)
end

function M.setDuration(duration)
	M.config.duration = duration
	log:d("Cursor locator duration set to: " .. duration)
end

-- ------------------------------------------------
-- CLEANUP ----------------------------------------
-- ------------------------------------------------

function M.stop()
	if canvas then
		canvas:delete()
		canvas = nil
	end
	if animationTimer then
		animationTimer:stop()
		animationTimer = nil
	end
	log:d("Cursor locator stopped")
end

return M
