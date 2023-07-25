-- ==============================================
-- HAMMERSPOON->CONFIG ==========================
-- ==============================================

-- ------------------------------------------------
-- REQUIRE->LOCAL ---------------------------------
-- ------------------------------------------------
--{{{

require("utility")

--}}}

-- ------------------------------------------------
-- WHAMMY -----------------------------------------
-- ------------------------------------------------
--{{{

local wm = {}

-- require('wm.os').setup()

-- local controller = require('wm.controller')

-- wm.controller = controller:new()

--}}}

-- ===============================================
-- CONFIGURATION =================================
-- ===============================================
--{{{

-- Apps
-- -----------------------------------------------
local appsToCenter = { "Finder", "Home Assistant", "Messages", "Gmail", "Unraid", "Unraid NAS", "Unraid PC" }
local defaultBrowserName = "Google Chrome"
local defaultTerminalName = "Kitty"
local secondaryBrowserName = "Firefox Developer Edition"

-- Adjustments
-- -----------------------------------------------
local sizeDelta = 0.07

-- Hotkey Prefixes
-- -----------------------------------------------
local movement = { "cmd", "ctrl" }
local movementSecondary = { "cmd", "ctrl", "shift" }
local movementWindowAdjustment = { "cmd", "ctrl", "alt" }

local movementApplicationLaunchOrFocus = { "cmd", "ctrl" }
local movementApplicationLaunchOrFocusSecondary = { "cmd", "ctrl", "shift" }
local movementApplicationLaunchOrFocusTertiary = { "ctrl", "alt", "shift" }

-- Spoons
-- -----------------------------------------------
local spoonNames = {
	"SpoonInstall",
	"ReloadConfiguration",
	"Emojis",
}

-- FROM: https://github.com/stephlm2dev/wildcard.conf/blob/71c17a660d25cfad6a5a4664065c62938db77d26/configuration/hammerspoon/init.lua#L8-L16
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
-- -----------------------------------------------
local hostname = hs.host.localizedName()

-- Hammerspoon
-- -----------------------------------------------
hs.application.enableSpotlightForNameSearches(true)

-- log
-- -----------------------------------------------
log = hs.logger.new("Hammerspoon")
log.setLogLevel("debug")

--}}}

-- -----------------------------------------------
-- WINDOW-TRACKER --------------------------------
-- -----------------------------------------------
--{{{
-- local windowtracker = require('wm.windowtracker')

-- wm.windowtracker = windowtracker:new(
--   {windowtracker.windowCreated, windowtracker.windowDestroyed, windowtracker.mainWindowChanged},
-- function(win, event)
--     log:d(win)
--     log:d(event)
-- end)

-- windowtracker:start()
--}}}

-- -----------------------------------------------
-- SET-CONFIG ------------------------------------
-- -----------------------------------------------
--{{{

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

--}}}

-- -----------------------------------------------
-- DEPENDENCIES ----------------------------------
-- -----------------------------------------------
--{{{

local application = {}
local uielement = {}

local audioVolume = require("audio.volume")
local fnutils = require("hs.fnutils")

hammerspoonConfigDir = os.getenv("HOME") .. "/.hammerspoon/"

application.watcher = require("hs.application.watcher")
uielement.watcher = require("hs.uielement.watcher")

--}}}

-- -----------------------------------------------
-- SPOONS ----------------------------------------
-- -----------------------------------------------
--{{{

-- Load Spoons
-- -----------------------------------------------
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

--}}}

-- -----------------------------------------------
-- STYLING ---------------------------------------
-- -----------------------------------------------
--{{{
-- Make the alerts look nicer.
hs.alert.defaultStyle.strokeColor = { white = 1, alpha = 0.2 }
hs.alert.defaultStyle.fillColor = { white = 0.05, alpha = 0.75 }
hs.alert.defaultStyle.radius = 10
hs.alert.defaultStyle.textSize = 24
hs.alert.defaultStyle.textFont = "Hack Nerd Font Mono"

hs.alert.defaultStyle.textColor = { white = 1, alpha = 1 }

hs.alert.defaultStyle.fadeInDuration = 0.0
hs.alert.defaultStyle.fadeOutDuration = 0.0

-- Disable the slow default window animations.
hs.window.animationDuration = 0
hs.window.setShadows(false)

--}}}

-- -----------------------------------------------
-- STYLING->SWITCHER -----------------------------
-- -----------------------------------------------
--{{{

local filter = hs.window.filter.new(false):setAppFilter("iTerm2", false)
local switcher = hs.window.switcher.new() -- default windowfilter: only visible windows, all Spaces

switcher.ui.highlightColor = { 0, 0, 0, 0.5 }
-- switcher.ui.thumbnailSize = 128
switcher.ui.thumbnailSize = 400
-- switcher.ui.selectedThumbnailSize = 384
switcher.ui.selectedThumbnailSize = 500
switcher.ui.backgroundColor = { 0.125, 0.125, 0.125, 0.8 }
-- switcher.ui.textSize = 12
-- switcher.ui.fontName = "SF Pro"
switcher.ui.titleBackgroundColor = { 0, 0, 0, 0.2 }
switcher.ui.showTitles = false
switcher.ui.showSelectedTitle = false
switcher.ui.showSelectedThumbnail = false

--}}}

-- -----------------------------------------------
-- HINTS/EXPOSE ----------------------------------
-- -----------------------------------------------
--{{{

hs.hints.fontSize = 34
hs.hints.style = "vimperator"
-- hs.hints.showTitleThreshold = 1
-- hs.hints.titleMaxSize = 20
-- hs.hints.titleMaxSize = -1
-- hs.hints.iconAlpha = 0.8

hs.hotkey.bind(movementApplicationLaunchOrFocus, ";", function()
	hs.hints.windowHints()
end)

hs.hotkey.bind(movementApplicationLaunchOrFocusSecondary, "'", function()
	local options = {
		showThumbnails = true,
		showTitles = false,
		includeOtherSpaces = false,
		includeNonVisible = false,
		highlightThumbnailAlpha = 1,
		highlightThumbnailStrokeWidth = 4,
		highlightColor = { 0.9, 0.9, 0.9, 0.5 },
		backgroundColor = { 0, 0, 0, 0.8 },
	}

	local filter = hs.window.filter.new(false):setAppFilter("iTerm2", false)

	-- filter.ignoreAlways['iTerm'] = true
	-- filter:rejectApp('iTerm')

	local expose = hs.expose.new(filter, options)

	expose:toggleShow()
end)

--}}}

-- -----------------------------------------------
-- WATCHERS --------------------------------------
-- -----------------------------------------------
--{{{

-- Wi-Fi Watcher
-- -----------------------------------------------
-- When the Wi-Fi network changes, display the name of the new one
function wifiListener(watcher, message, interface)
	local currentNetwork = hs.wifi.currentNetwork(interface)
	log:d("Wi-Fi network changed to " .. currentNetwork)

	if not currentNetwork then
		return
	end

	notify("Wi-Fi", currentNetwork, icons.network, true)

	-- hs.alert("Wi-Fi: " .. currentNetwork)
end

wifiWatcher = hs.wifi.watcher.new(wifiListener)
wifiWatcher:watchingFor({ "SSIDChange" })

wifiWatcher:stop()
wifiWatcher:start()

-- Screen Watcher
-- -----------------------------------------------
-- Get list of screens and refresh that list whenever screens are (un)plugged
local screens = hs.screen.allScreens()

local screenwatcher = hs.screen.watcher.new(function()
	screens = hs.screen.allScreens()
	log:d("screens: " .. screens)
end)

screenwatcher:start()

-- Audio Device Watcher
-- -----------------------------------------------
function handleAudioDeviceChange(data)
	-- https://www.hammerspoon.org/docs/hs.audiodevice.watcher.html#setCallback
	if data == "dOut" then
		log:d("Audio device changed: " .. data)

		device = hs.audiodevice.defaultOutputDevice()
		level = 0

		if device:name() == "FiiO BTR5" then
			hs.alert("Skipping: FiiO BTR5")
			return
			-- level = 100
		end

		-- device:setMuted(false)
		-- device:setOutputVolume(level)
		-- device:setBalance(0.5)

		hs.inspect.inspect(device)

		local text = hs.styledtext.new("Output\n" .. device:name(), {
			color = { hex = "#FFFFFF", alpha = 1 },
			font = { size = 30 },
		})

		hs.alert(text) -- "OUTPUT: " .. device:name())

		-- for _, device in pairs(hs.audiodevice.allInputDevices()) do
		--   device:setInputMuted(state)
		-- end
	end
end

if not hs.audiodevice.watcher.isRunning() then
	hs.audiodevice.watcher.setCallback(function(data)
		handleAudioDeviceChange(data)
	end)

	hs.audiodevice.watcher.stop()
	hs.audiodevice.watcher.start()
end

-- Application Watcher
-- -----------------------------------------------
local function appWatcherCallback(name, event, app)
	log:d(name)
	log:d(event)
	log:d(app)
	if event == hs.application.watcher.activated then
		log:d("App activated: " .. name)

		if hasValue(appsToCenter, name) then
			log:d("Centering: " .. name)

			hs.application.get(name):focusedWindow():centerOnScreen(nil, true)

			--       hs.window.frontmostWindow():centerOnScreen(nil, true)
		end
	end
end

local globalAppWatcher = application.watcher.new(appWatcherCallback)

log:d("appWatcher:")
log:d(globalAppWatcher)

globalAppWatcher:start()

--
-- -----------------------------------------------
-- local function uiElementWatcherCallback(name, event, element)
--   log:d(event)
-- end

-- local globalUiElementWatcher = uielement.watcher.new(uiElementWatcherCallback)

-- if globalUiElementWatcher.isRunning then
--   globalUiElementWatcher:stop()
-- end

-- globalUiElementWatcher:start()

-- ReloadConfiguration
-- -----------------------------------------------
spoon.ReloadConfiguration:start()

--}}}

-- -----------------------------------------------
-- SHORTCUTS -------------------------------------
-- -----------------------------------------------
--{{{

function bindApplicationFocus(key, title)
	hs.hotkey.bind(movementApplicationLaunchOrFocus, key, function()
		hs.application.launchOrFocus(title)
	end)
end

function bindApplicationFocusWithConfirmation(key, title)
	hs.hotkey.bind(movementApplicationLaunchOrFocus, key, function()
		confirmOnEnter(title)
	end)
end

function bindApplicationFocusSecondaryWithConfirmation(key, title)
	hs.hotkey.bind(movementApplicationLaunchOrFocusSecondary, key, function()
		confirmOnEnter(title)
	end)
end

function bindApplicationFocusSecondary(key, title)
	hs.hotkey.bind(movementApplicationLaunchOrFocusSecondary, key, function()
		hs.application.launchOrFocus(title)
	end)
end

function triggerAfterConfirmation(question, action)
	hs.timer.doAfter(0, function()
		hs.focus()

		local answer = hs.dialog.blockAlert(question, "", "Confirm", "Cancel")

		if answer == "Confirm" then
			action()
		end
	end)
end

function launchOrFocusIfRunning(hint)
	local app = hs.application.find(hint)

	if not app then
		return
	end

	hs.application.launchOrFocus(app)
end

function confirmOnEnter(appName)
	message = "Launch?"
	informativeText = "info"

	if not hs.application.find(appName) then
		triggerAfterConfirmation(appName, function()
			hs.application.launchOrFocus(appName)
		end)
	else
		hs.application.launchOrFocus(appName)
	end

	-- hs.dialog.blockAlert(message, informativeText)
	-- hs.alert.show("Messages")
	-- hs.timer.doAfter(0, function() hs.focus(); hs.dialog.textPrompt("Main message.", "Please enter something:") end)
end

--}}}

-- -----------------------------------------------
-- SHORTCUTS->BINDINGS ---------------------------
-- -----------------------------------------------
--{{{

hs.hotkey.bind(movementApplicationLaunchOrFocus, "M", function()
	confirmOnEnter("Messages")
end)
hs.hotkey.bind(movementApplicationLaunchOrFocusSecondary, "S", function()
	confirmOnEnter("Slack")
end)
hs.hotkey.bind(movementApplicationLaunchOrFocusSecondary, "W", function()
	confirmOnEnter("WhatsApp")
end)

hs.hotkey.bind(movementApplicationLaunchOrFocusTertiary, "S", function()
	confirmOnEnter("Stable Diffusion")
end)

-- Center window
hs.hotkey.bind({ "ctrl", "cmd" }, "0", function()
	hs.window.focusedWindow():centerOnScreen(nil, true)
end)

hs.hotkey.bind(movement, "Left", function()
	local win = hs.window.focusedWindow()
	local f = win:frame()
	local screen = win:screen()
	local max = screen:frame()

	f.x = max.x
	f.y = max.y
	f.w = max.w / 2
	f.h = max.h
	win:setFrame(f)
end)

hs.hotkey.bind(movement, "Right", function()
	local win = hs.window.focusedWindow()
	local f = win:frame()
	local screen = win:screen()
	local max = screen:frame()

	f.x = max.x + (max.w / 2)
	f.y = max.y
	f.w = max.w / 2
	f.h = max.h
	win:setFrame(f)
end)

function fullscreen()
	local win = hs.window.focusedWindow()
	local f = win:frame()
	local screen = win:screen()
	local max = screen:frame()

	f.x = max.x
	f.y = max.y
	f.w = max.w
	f.h = max.h

	win:setFrame(f)
end

--}}}

-- -----------------------------------------------
-- HOTKEYS ---------------------------------------
-- -----------------------------------------------
-- {{{

-- Applications
-- -----------------------------------------------
bindApplicationFocus("I", defaultBrowserName)
bindApplicationFocusSecondary("I", secondaryBrowserName)
bindApplicationFocus("T", "Todoist")
bindApplicationFocus("P", "Preview")
bindApplicationFocusSecondary("P", "Adobe Photoshop (Beta)")
-- hs.hotkey.bind(launchOrFocus, "P", function() confirmOnEnter("Adobe Photoshop (Beta)") end)
bindApplicationFocus("F", "Finder")
bindApplicationFocus("C", "ChatGPT")
bindApplicationFocusSecondaryWithConfirmation("F", "FaceTime")
bindApplicationFocusWithConfirmation("Z", "zoom.us")
bindApplicationFocus("D", "Drive")
bindApplicationFocus("A", "Audio MIDI Setup")
bindApplicationFocus("W", "WLED")
hs.hotkey.bind(movementApplicationLaunchOrFocusSecondary, "D", function()
	confirmOnEnter("Discord")
end)
bindApplicationFocus("E", "Obsidian")
bindApplicationFocusSecondary("E", "Element")
bindApplicationFocusSecondary("V", "Visual Studio Code")
bindApplicationFocus("V", "IINA")
bindApplicationFocus("G", "Gmail")
bindApplicationFocus("U", "Unraid")
bindApplicationFocus("N", "Notion")
bindApplicationFocus("H", "Home Assistant")
bindApplicationFocusSecondary("H", "Home Assistant")
-- bindApplicationFocusSecondary("S", "Stable Diffusion")
-- bindApplicationFocus("D", "Stable Diffusion")
bindApplicationFocus("S", function()
	confirmOnEnter("Spotify")
end)

-- Special
-- -----------------------------------------------
hs.hotkey.bind({ "ctrl" }, "Space", function()
	hs.application.launchOrFocus("iTerm")
end)

-- Switcher
-- -----------------------------------------------
hs.hotkey.bind({ "cmd", "ctrl" }, "'", function()
	switcher:next()
end)
hs.hotkey.bind({ "cmd", "ctrl", "shift" }, "'", function()
	switcher:previous()
end)

-- Displays
-- -----------------------------------------------
local hyperShift = { "ctrl", "cmd", "shift" }
hs.hotkey.bind(hyperShift, "m", function()
	local screen = hs.mouse.getCurrentScreen()
	local nextScreen = screen:next()
	local rect = nextScreen:fullFrame()
	local center = hs.geometry.rectMidPoint(rect)
	hs.mouse.setAbsolutePosition(center)

	-- Display alerts on both screens
	hs.alert.show("Moved Mouse To Other Screen", { textSize = 24 }, screen)
	hs.alert.show("Moved Mouse HERE: " .. nextScreen:name(), { textSize = 24 }, nextScreen)
end)

-- }}}

-- -----------------------------------------------
-- HOTKEYS->VOLUME -------------------------------
-- -----------------------------------------------
--{{{
hs.hotkey.bind({ "shift", "cmd", "ctrl" }, "Up", function()
	setVolumeOfCurrent(10.0)
end)

hs.hotkey.bind({ "shift", "cmd", "ctrl" }, "Down", function()
	setVolumeOfCurrent(-10.0)
end)
--}}}

-- -----------------------------------------------
-- HOTKEYS->WINDOW -------------------------------
-- -----------------------------------------------
-- {{{

function getAdjustmentSizes()
	local win = hs.window.focusedWindow()
	local f = win:frame()
	local screen = win:screen()
	local max = screen:frame()

	local sizes = {
		w = max.w * sizeDelta,
		h = max.h * sizeDelta,
	}

	return sizes
end

function modifyWindowHeight(delta, direction)
	local win = hs.window.focusedWindow()
	local f = win:frame()
	local screen = win:screen()
	local max = screen:frame()

	local sizes = getAdjustmentSizes()

	if direction == "shrink" then
		f.h = f.h - sizes.h
	else
		f.h = f.h + sizes.h
	end

	win:setFrame(f)
	win:centerOnScreen(nil, true)
end

function modifyWindowWidth(delta, direction)
	local win = hs.window.focusedWindow()
	local f = win:frame()
	local screen = win:screen()
	local max = screen:frame()

	local sizes = getAdjustmentSizes()

	if direction == "shrink" then
		f.w = f.w - sizes.w
	else
		f.w = f.w + sizes.w
	end

	win:setFrame(f)
	win:centerOnScreen(nil, true)
end

function modifyWindowSize(delta, direction)
	modifyWindowHeight(delta, direction)
	modifyWindowWidth(delta, direction)
end

-- -----------------------------------------------

hs.hotkey.bind(movement, "Up", fullscreen)
hs.hotkey.bind(movement, "Down", middle)

hs.hotkey.bind({ "ctrl", "cmd" }, "0", function()
	hs.window.focusedWindow():centerOnScreen(nil, true)
end)

hs.hotkey.bind({ "ctrl", "cmd", "alt" }, "0", function()
	hs.window.focusedWindow():centerOnScreen(nil, true)
end)

hs.hotkey.bind(movementWindowAdjustment, "Left", function()
	modifyWindowWidth(sizeDelta, "shrink")
end)

hs.hotkey.bind(movementWindowAdjustment, "Right", function()
	modifyWindowWidth(sizeDelta, "expand")
end)

hs.hotkey.bind(movementWindowAdjustment, "Up", function()
	modifyWindowHeight(sizeDelta, "expand")
end)

hs.hotkey.bind(movementWindowAdjustment, "Down", function()
	modifyWindowHeight(sizeDelta, "shrink")
end)

-- Shrink Window
hs.hotkey.bind(movementWindowAdjustment, "-", function()
	-- Shrink the current window by a percentage of the original size
	-- in proportion to the screen size
	local win = hs.window.focusedWindow()
	local f = win:frame()
	local screen = win:screen()
	local max = screen:frame()

	f.w = f.w - max.w * sizeDelta
	f.h = f.h - max.h * sizeDelta

	f.x = max.x + (max.w - f.w) / 2
	f.y = max.y + (max.h - f.h) / 2

	win:setFrame(f)
end)

-- Expand Window
hs.hotkey.bind(movementWindowAdjustment, "=", function()
	-- Expand the current window by a percentage of the original size
	-- in proportion to the screen size
	local win = hs.window.focusedWindow()
	local f = win:frame()
	local screen = win:screen()
	local max = screen:frame()

	f.w = f.w + max.w * sizeDelta
	f.h = f.h + max.h * sizeDelta

	f.x = max.x + (max.w - f.w) / 2
	f.y = max.y + (max.h - f.h) / 2

	-- If the new window size exceeds the screen size, fit it to the screen
	if f.w > max.w then
		f.w = max.w
		f.x = 0
	end

	if f.h > max.h then
		f.h = max.h
		f.y = 0
	end

	win:setFrame(f)
end)

--}}}

--------------------------------------------------
-- ALERT->CONFIG-LOADED --------------------------
--------------------------------------------------
--{{{

hs.alert("Hammerspon Config Loaded")

--}}}
