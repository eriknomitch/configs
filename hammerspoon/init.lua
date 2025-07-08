-- ==============================================
-- HAMMERSPOON->CONFIG ==========================
-- ==============================================

-- ------------------------------------------------
-- CONFIG -----------------------------------------
-- ------------------------------------------------
local enableWindowResizeKeybindings = true

-- ------------------------------------------------
-- REQUIRE->LOCAL ---------------------------------
require("utility")
require("external_display_handler")

-- ------------------------------------------------
-- WHAMMY -----------------------------------------
local wm = {}

-- ===============================================
-- CONFIGURATION =================================
-- ===============================================

-- Apps
local appsToCenter = { "Finder", "Home Assistant", "Messages" }
local defaultBrowserName = "Arc"
local defaultTerminalName = "iTerm"
local secondaryBrowserName = "Firefox Developer Edition"
local defaultAiChatName = "ChatGPT"
local secondaryAiChatName = "Claude"

-- Adjustments
local sizeDelta = 0.07

-- Hotkey Prefixes
local movement = { "cmd", "ctrl" }
local movementSecondary = { "cmd", "ctrl", "shift" }
local movementWindowAdjustment = { "cmd", "ctrl", "alt" }

local movementApplicationLaunchOrFocus = { "cmd", "ctrl" }
local movementApplicationLaunchOrFocusSecondary = { "cmd", "ctrl", "shift" }
local movementApplicationLaunchOrFocusTertiary = { "ctrl", "alt", "shift" }

local hyperShift = { "ctrl", "cmd", "shift" }

-- Spoons
local spoonNames = {
	"SpoonInstall",
	"ReloadConfiguration",
	"Emojis",
}

icons = {
	default = "/Applications/Hammerspoon.app/Contents/Resources/AppIcon.icns",
	alert = "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/Actions.icns",
	mac = "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/com.apple.macbookpro-15-retina-touchid-silver.icns",
	network = "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/AirDrop.icns",
	photo = "/Applications/Polarr Photo Editor.app/Contents/Resources/AppIcon-Lite.icns",
	skype = "/Applications/Skype.app/Contents/Resources/Skype.icns",
	zoom = "/Applications/zoom.us.app/Contents/Resources/ZPLogo.icns",
}

-- Inferrable
local hostname = hs.host.localizedName()
hs.application.enableSpotlightForNameSearches(true)

-- log
log = hs.logger.new("Hammerspoon")
log.setLogLevel("debug")

-- ------------------------------------------------
-- SET-CONFIG ------------------------------------
setConfigForUtility({
	sizeDelta = sizeDelta,
	appsToCenter = appsToCenter,
	defaultBrowserName = defaultBrowserName,
	secondaryBrowserName = secondaryBrowserName,
	movement = movement,
	movementSecondary = movementSecondary,
	movementWindowAdjustment = movementWindowAdjustment,
	movementApplicationLaunchOrFocus = movementApplicationLaunchOrFocus,
	movementApplicationLaunchOrFocusSecondary = movementApplicationLaunchOrFocusSecondary,
	spoonNames = spoonNames,
})

-- ------------------------------------------------
-- SPOONS ----------------------------------------
hs.loadSpoon("SpoonInstall")
spoon.SpoonInstall.use_syncinstall = true
local Install = spoon.SpoonInstall

hs.loadSpoon("Emojis")
hs.loadSpoon("ReloadConfiguration")

function installSpoons(spoonNames)
	Install:updateRepo("default")
	for _, spoonName in ipairs(spoonNames) do
		Install:installSpoon(spoonName)
	end
end

-- ------------------------------------------------
-- SHORTCUT HELPERS ------------------------------
function triggerAfterConfirmation(question, action)
	hs.timer.doAfter(0, function()
		hs.focus()
		local answer = hs.dialog.blockAlert(question, "", "Confirm", "Cancel")
		if answer == "Confirm" then
			action()
		end
	end)
end

function launchOrFocusWithConfirmation(appName)
	if hs.application.find(appName) then
		hs.application.launchOrFocus(appName)
	else
		triggerAfterConfirmation("Open " .. appName .. "?", function()
			hs.application.launchOrFocus(appName)
		end)
	end
end

-- ------------------------------------------------
-- APPLICATION BINDINGS --------------------------
local appBindings = {
	{ key = "I", app = defaultBrowserName },
	{ key = "I", app = secondaryBrowserName, modifiers = movementApplicationLaunchOrFocusSecondary },
	{ key = "L", app = "Linear", confirm = true },
	{ key = "P", app = "Preview" },
	{ key = "P", app = "Adobe Photoshop 2025", modifiers = movementApplicationLaunchOrFocusSecondary, confirm = true },
	{ key = "F", app = "Finder" },
	{ key = "F", app = "FaceTime", modifiers = movementApplicationLaunchOrFocusSecondary, confirm = true },
	{ key = "C", app = defaultAiChatName },
	{ key = "C", app = secondaryAiChatName, modifiers = movementApplicationLaunchOrFocusSecondary },
	{ key = "B", app = "BoltAI" },
	{ key = "Z", app = "zoom.us", confirm = true },
	{ key = "D", app = "Drive" },
	{ key = "A", app = "Audio MIDI Setup" },
	{ key = "W", app = "WLED" },
	{ key = "D", app = "Discord", modifiers = movementApplicationLaunchOrFocusSecondary, confirm = true },
	{ key = "E", app = "Obsidian" },
	{ key = "E", app = "Element", modifiers = movementApplicationLaunchOrFocusSecondary },
	{ key = "V", app = "IINA" },
	{ key = "V", app = "Visual Studio Code", modifiers = movementApplicationLaunchOrFocusSecondary },
	{ key = "U", app = "Unraid" },
	{ key = "N", app = "Notion" },
	{ key = "H", app = "Home Assistant" },
	{ key = "H", app = "Home Assistant", modifiers = movementApplicationLaunchOrFocusSecondary },
	{ key = "S", app = "Stable Diffusion", modifiers = movementApplicationLaunchOrFocusTertiary, confirm = true },
}

local function getModifiers(entry)
	return entry.modifiers or movementApplicationLaunchOrFocus
end

for _, entry in ipairs(appBindings) do
	local modifiers = getModifiers(entry)
	local key = entry.key
	local app = entry.app
	local confirm = entry.confirm
	local handler = entry.handler

	if handler then
		hs.hotkey.bind(modifiers, key, handler)
	elseif confirm then
		hs.hotkey.bind(modifiers, key, function()
			launchOrFocusWithConfirmation(app)
		end)
	else
		hs.hotkey.bind(modifiers, key, function()
			hs.application.launchOrFocus(app)
		end)
	end
end

-- ------------------------------------------------
-- WINDOW SIZE + POSITION BINDINGS --------------
if enableWindowResizeKeybindings then
	hotkeys = {
		{
			key = "0",
			mods = movement,
			action = function()
				hs.window.focusedWindow():centerOnScreen(nil, true)
			end,
		},
		{
			key = "1",
			mods = movement,
			action = function()
				hs.window.focusedWindow():moveToUnit(hs.layout.left50)
			end,
		},
		{
			key = "2",
			mods = movement,
			action = function()
				hs.window.focusedWindow():moveToUnit(hs.layout.right50)
			end,
		},
		{
			key = "Up",
			mods = movement,
			action = function()
				hs.window.focusedWindow():maximize()
			end,
		},
		{
			key = "Left",
			mods = movementWindowAdjustment,
			action = function()
				local win = hs.window.focusedWindow()
				local f = win:frame()
				f.w = f.w - (f.w * sizeDelta)
				win:setFrame(f)
			end,
		},
		{
			key = "Right",
			mods = movementWindowAdjustment,
			action = function()
				local win = hs.window.focusedWindow()
				local f = win:frame()
				f.w = f.w + (f.w * sizeDelta)
				win:setFrame(f)
			end,
		},
	}

	for _, hk in ipairs(hotkeys) do
		hs.hotkey.bind(hk.mods, hk.key, hk.action)
	end
end

-- ------------------------------------------------
-- VOLUME BINDINGS -------------------------------
hs.hotkey.bind({ "shift", "cmd", "ctrl" }, "Up", function()
	setVolumeOfCurrent(10.0)
end)

hs.hotkey.bind({ "shift", "cmd", "ctrl" }, "Down", function()
	setVolumeOfCurrent(-10.0)
end)

-- ------------------------------------------------
-- CHEAT SHEET -----------------------------------
local cheatSheet = nil

local function generateCheatSheetContent()
	return [[
Hammerspoon Cheat Sheet:

App Shortcuts:
  Browser       - cmd+ctrl+I
  ChatGPT       - cmd+ctrl+C
  FaceTime      - cmd+ctrl+shift+F

Window Mgmt:
  Center Window - cmd+ctrl+0
  Maximize      - cmd+ctrl+Up
  Left 50%      - cmd+ctrl+1
  Right 50%     - cmd+ctrl+2

Volume:
  Volume Up     - shift+cmd+ctrl+Up
  Volume Down   - shift+cmd+ctrl+Down
	]]
end

local function toggleCheatSheet()
	if cheatSheet then
		cheatSheet:delete()
		cheatSheet = nil
	else
		local mainScreen = hs.screen.mainScreen()
		local mainRes = mainScreen:fullFrame()
		local rect = hs.geometry.rect(mainRes.w / 4, mainRes.h / 4, mainRes.w / 2, mainRes.h / 2)

		cheatSheet = hs.canvas.new(rect)
		cheatSheet:appendElements({
			type = "rectangle",
			action = "fill",
			fillColor = { alpha = 0.95, white = 0 },
			roundedRectRadii = { xRadius = 10, yRadius = 10 },
		}, {
			type = "text",
			text = generateCheatSheetContent(),
			textFont = "Courier",
			textSize = 16,
			textColor = { white = 1 },
			textLineBreak = "truncateMiddle",
		})
		cheatSheet:show()
	end
end

hs.hotkey.bind({ "cmd", "alt", "ctrl" }, "/", toggleCheatSheet)

-- ------------------------------------------------
-- FINAL -----------------------------------------
hs.hotkey.bind({ "ctrl" }, "Space", function()
	hs.application.launchOrFocus(defaultTerminalName)
end)

hs.alert("Hammerspon Config Loaded")
