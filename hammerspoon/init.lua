-- ==============================================
-- HAMMERSPOON->CONFIG ==========================
-- ==============================================

-- ------------------------------------------------
-- CONFIG -----------------------------------------
-- ------------------------------------------------
--{{{
local enableWindowResizeKeybindings = true
--}}}

-- ------------------------------------------------
-- REQUIRE->LOCAL ---------------------------------
-- ------------------------------------------------
--{{{

require("utility")
require("external_display_handler")
local displayDimmer = require("inactive_display_dimmer")

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
local appsToCenter = { "Finder", "Home Assistant", "Messages" }
-- local defaultBrowserName = "Google Chrome"
local defaultBrowserName = "Arc"
-- local defaultTerminalName = "Tabby"
-- local defaultTerminalName = "Alacritty"
local defaultTerminalName = "Ghostty"
local secondaryBrowserName = "Firefox Developer Edition"

-- local defaultAiChatName = "ChatGPT"
local defaultAiChatName = "ChatGPT"
local secondaryAiChatName = "Claude"

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
hs.alert.defaultStyle.strokeColor = { white = 0, alpha = 0 }
-- fill is #202020 with 1 alpha
hs.alert.defaultStyle.fillColor = { white = 0.1, alpha = 1 }
hs.alert.defaultStyle.radius = 10
hs.alert.defaultStyle.textSize = 20
hs.alert.defaultStyle.textFont = "FiraCode Nerd Font"

hs.alert.defaultStyle.textColor = { white = 0.9, alpha = 1 }

hs.alert.defaultStyle.fadeInDuration = 0.0
hs.alert.defaultStyle.fadeOutDuration = 0.0

-- Disable the slow default window animations.
hs.window.animationDuration = 0
hs.window.setShadows(false)

-- Put them near the bottom of the screen but not too far.
hs.alert.defaultStyle.atScreenEdge = 2
hs.alert.defaultStyle.textInset = 20
hs.alert.defaultStyle.padding = 5
hs.alert.defaultStyle.radius = 10

-- Add a margin to the bottom of the screen.
-- hs.alert.defaultStyle.textInset = 20

--}}}

-- -----------------------------------------------
-- STYLING->SWITCHER -----------------------------
-- -----------------------------------------------
--{{{

local filter = hs.window.filter.new(false):setAppFilter(defaultTerminalName, false)
local switcher = hs.window.switcher.new() -- default windowfilter: only visible windows, all Spaces

switcher.ui.highlightColor = { 0, 0, 0, 1 }
-- switcher.ui.thumbnailSize = 128
switcher.ui.thumbnailSize = 400
-- switcher.ui.selectedThumbnailSize = 384
switcher.ui.selectedThumbnailSize = 500
-- (32,32,32) is the default background color
switcher.ui.backgroundColor = { 1, 0, 0, 1 }
-- switcher.ui.textSize = 12
-- switcher.ui.fontName = "SF Pro"
-- switcher.ui.titleBackgroundColor = { 0, 0, 0, 0.2 }
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

	local filter = hs.window.filter.new(false):setAppFilter(defaultTerminalName, false)

	-- filter.ignoreAlways[defaultTerminalName] = true
	-- filter:rejectApp(defaultTerminalName)

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

	if not currentNetwork then
		log:d("Wi-Fi network changed to <none>")
		return
	end

	log:d("Wi-Fi network changed to " .. currentNetwork)

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
	log:d("screens: " .. #screens .. " connected")
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

		skip_devices = { "FiiO K7", "FiiO K7 (eqMac)", "FiiO K7 (eqMac2)" }

		-- If the device is in the skip list, then skip it
		if hasValue(skip_devices, device:name()) then
			return
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

-- Window Watcher for Centering Apps
-- -----------------------------------------------
local function centerWindow(win)
	if win and hasValue(appsToCenter, win:application():name()) then
		win:centerOnScreen(nil, true)
	end
end

local windowWatchers = {}

for _, appName in ipairs(appsToCenter) do
	windowWatchers[appName] = hs.window.filter.new(appName)
	windowWatchers[appName]:subscribe(hs.window.filter.windowCreated, function(win)
		centerWindow(win)
	end)
	windowWatchers[appName]:subscribe(hs.window.filter.windowFocused, function(win)
		centerWindow(win)
	end)
end

log:d("Window watchers created for apps to center")

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

-- Audio Volume Checker with AnyBar Integration
-- -----------------------------------------------
local lastVolume = -1
local lastMuted = false

local function setAnyBarColor(color)
	os.execute(string.format("bash -c 'echo -n \"%s\" > /dev/udp/localhost/1738'", color))
end

local function getColorForVolume(volume, isMuted)
	if isMuted or volume == 0 then
		return "black"
	elseif volume <= 25 then
		return "green"
	elseif volume <= 50 then
		return "yellow"
	elseif volume <= 75 then
		return "orange"
	else
		return "red"
	end
end

local function checkAudioVolume()
	local device = hs.audiodevice.defaultOutputDevice()
	if device then
		local volume = device:outputVolume()
		local isMuted = device:muted()

		if volume and (volume ~= lastVolume or isMuted ~= lastMuted) then
			local roundedVolume = math.floor(volume)
			hs.alert.closeAll()

			local statusText = isMuted and "Muted" or (roundedVolume .. "%")
			hs.alert.show("Volume: " .. statusText, { textSize = 16 }, 1)

			local color = getColorForVolume(roundedVolume, isMuted)
			setAnyBarColor(color)

			lastVolume = volume
			lastMuted = isMuted
		end
	end
end

-- Create and start the timer
local volumeChecker = hs.timer.new(1, checkAudioVolume)
volumeChecker:start()

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
		launchOrFocusWithConfirmation(title)
	end)
end

function bindApplicationFocusSecondaryWithConfirmation(key, title)
	hs.hotkey.bind(movementApplicationLaunchOrFocusSecondary, key, function()
		launchOrFocusWithConfirmation(title)
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

function launchOrFocusWithConfirmation(appName)
	-- If the application is already running, focus it
	if hs.application.find(appName) then
		hs.application.launchOrFocus(appName)
	else
		message = "Open"
		fullMessage = message .. " " .. appName .. "?"

		-- If the application is not running, ask for confirmation
		triggerAfterConfirmation(fullMessage, function()
			hs.application.launchOrFocus(appName)
		end)
	end
end

-- hs.application.launchOrFocus(appName)
-- message = "Launch?"
-- informativeText = "info"
--
-- if not hs.application.find(appName) then
-- 	triggerAfterConfirmation(appName, function()
-- 		hs.application.launchOrFocus(appName)
-- 	end)
-- else
-- 	hs.application.launchOrFocus(appName)
-- end
--
--
--
--
-- hs.dialog.blockAlert(message, informativeText)
-- hs.alert.show("Messages")
-- hs.timer.doAfter(0, function() hs.focus(); hs.dialog.textPrompt("Main message.", "Please enter something:") end)
-- end

--}}}

-- -----------------------------------------------
-- SHORTCUTS->BINDINGS ---------------------------
-- -----------------------------------------------
--{{{

hs.hotkey.bind(movementApplicationLaunchOrFocus, "M", function()
	launchOrFocusWithConfirmation("Messages")
end)
hs.hotkey.bind(movementApplicationLaunchOrFocusSecondary, "S", function()
	launchOrFocusWithConfirmation("Slack")
end)
hs.hotkey.bind(movementApplicationLaunchOrFocusSecondary, "W", function()
	launchOrFocusWithConfirmation("WhatsApp")
end)

hs.hotkey.bind(movementApplicationLaunchOrFocusTertiary, "S", function()
	launchOrFocusWithConfirmation("Stable Diffusion")
end)

--}}}

-- -----------------------------------------------
-- HOTKEYS ---------------------------------------
-- -----------------------------------------------
-- {{{

-- Applications
-- -----------------------------------------------
bindApplicationFocus("I", defaultBrowserName)
bindApplicationFocusSecondary("I", secondaryBrowserName)
bindApplicationFocus("L", "Linear")

bindApplicationFocus("P", "Preview")
bindApplicationFocusSecondaryWithConfirmation("P", "Adobe Photoshop 2025")
bindApplicationFocus("F", "Finder")
bindApplicationFocus("C", defaultAiChatName)
bindApplicationFocusSecondary("C", secondaryAiChatName)
bindApplicationFocus("B", "BoltAI")
bindApplicationFocusSecondaryWithConfirmation("F", "FaceTime")
bindApplicationFocusWithConfirmation("Z", "zoom.us")
bindApplicationFocus("D", "Drive")
bindApplicationFocus("A", "Audio MIDI Setup")
bindApplicationFocus("W", "WLED")
bindApplicationFocusSecondaryWithConfirmation("D", "Discord")
bindApplicationFocus("E", "Obsidian")
bindApplicationFocusSecondary("E", "Element")
bindApplicationFocusSecondary("V", "Visual Studio Code")
bindApplicationFocus("V", "IINA")
bindApplicationFocus("U", "Unraid")
bindApplicationFocus("N", "Notion")
bindApplicationFocus("H", "Home Assistant")

-- Special
-- -----------------------------------------------
hs.hotkey.bind({ "ctrl" }, "Space", function()
	hs.application.launchOrFocus(defaultTerminalName)
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

-- Toggle display dimmer (dims inactive screens)
hs.hotkey.bind(movementWindowAdjustment, "D", function()
	displayDimmer.toggle()
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

function generateCheatSheetContent()
	return [[
Window Management Cheat Sheet:

Center window:         ctrl + cmd + 0
Fullscreen:            cmd + ctrl + Up
Middle (3/4 width):    cmd + ctrl + Down
Left half:             cmd + ctrl + Left
Right half:            cmd + ctrl + Right

Centered windows:
  Small:               cmd + ctrl + 1
  Medium:              cmd + ctrl + 2
  Large:               cmd + ctrl + 3
  Full:                cmd + ctrl + 4

Resize:
  Shrink width:        cmd + ctrl + alt + Left
  Expand width:        cmd + ctrl + alt + Right
  Expand height:       cmd + ctrl + alt + Up
  Shrink height:       cmd + ctrl + alt + Down
  Shrink both:         cmd + ctrl + alt + -
  Expand both:         cmd + ctrl + alt + =

Application Shortcuts:
  Browser (Arc):       cmd + ctrl + I
  Firefox Dev:         cmd + ctrl + shift + I
  Linear:              cmd + ctrl + L
  Preview:             cmd + ctrl + P
  Photoshop:           cmd + ctrl + shift + P
  Finder:              cmd + ctrl + F
  ChatGPT:             cmd + ctrl + C
  Claude:              cmd + ctrl + shift + C
  BoltAI:              cmd + ctrl + B
  FaceTime:            cmd + ctrl + shift + F
  Zoom:                cmd + ctrl + Z
  Drive:               cmd + ctrl + D
  Audio MIDI Setup:    cmd + ctrl + A
  WLED:                cmd + ctrl + W
  Discord:             cmd + ctrl + shift + D
  Obsidian:            cmd + ctrl + E
  Element:             cmd + ctrl + shift + E
  VS Code:             cmd + ctrl + shift + V
  IINA:                cmd + ctrl + V
  Unraid:              cmd + ctrl + U
  Notion:              cmd + ctrl + N
  Home Assistant:      cmd + ctrl + H
  Messages:            cmd + ctrl + M
  Slack:               cmd + ctrl + shift + S
  WhatsApp:            cmd + ctrl + shift + W
  Stable Diffusion:    ctrl + alt + shift + S

Special:
  Terminal:            ctrl + Space
  Window Switcher:     cmd + ctrl + '
  Reverse Switcher:    cmd + ctrl + shift + '
  Move Mouse to Screen:cmd + ctrl + shift + M

Audio:
  Volume Up:           shift + cmd + ctrl + Up
  Volume Down:         shift + cmd + ctrl + Down

Display:
  Toggle Dim Inactive: cmd + ctrl + alt + D

Utilities:
  Reload Hammerspoon:  cmd + alt + ctrl + R
  Toggle Cheat Sheet:  cmd + alt + ctrl + /
  Window Hints:        cmd + ctrl + ;
  Window Expose:       cmd + ctrl + shift + '
    ]]
end

local cheatSheet = nil

function toggleCheatSheet()
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

-- New hotkeys for centered window positions
hs.hotkey.bind(movement, "1", function()
	local win = hs.window.focusedWindow()
	local positions = getCommonWindowPositions()
	win:setFrame(positions.centerSmall)
end)

hs.hotkey.bind(movement, "2", function()
	local win = hs.window.focusedWindow()
	local positions = getCommonWindowPositions()
	win:setFrame(positions.centerMedium)
end)

hs.hotkey.bind(movement, "3", function()
	local win = hs.window.focusedWindow()
	local positions = getCommonWindowPositions()
	win:setFrame(positions.centerLarge)
end)

hs.hotkey.bind(movement, "4", function()
	local win = hs.window.focusedWindow()
	local positions = getCommonWindowPositions()
	win:setFrame(positions.centerFull)
end)

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

function fullscreen()
	local win = hs.window.focusedWindow()
	if win == nil then
		return
	end
	local f = win:frame()
	local screen = win:screen()
	local max = screen:frame()

	f.x = max.x
	f.y = max.y
	f.w = max.w
	f.h = max.h

	win:setFrame(f)
end

-- -----------------------------------------------

if enableWindowResizeKeybindings then
	-- Window halves
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

	-- Fullscreen and middle
	hs.hotkey.bind(movement, "Up", fullscreen)
	hs.hotkey.bind(movement, "Down", middle)

	hs.hotkey.bind({ "ctrl", "cmd" }, "0", function()
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
end

--}}}

--------------------------------------------------
-- ALERT->CONFIG-LOADED --------------------------
--------------------------------------------------
--{{{

hs.alert("Hammerspon Config Loaded")

--}}}
