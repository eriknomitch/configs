-- Function to set the default audio output device
local function setDefaultAudioDevice(deviceName)
	local devices = hs.audiodevice.allOutputDevices()
	for _, device in ipairs(devices) do
		if device:name() == deviceName then
			device:setDefaultOutputDevice()
			hs.alert("Audio output changed to " .. deviceName)
			print("Audio output changed to " .. deviceName)
			return
		end
	end
	print("Device not found: " .. deviceName)
end

-- Function to handle screen changes
local function screenChangedCallback()
	local screens = hs.screen.allScreens()

	-- Change the number based on how many screens you usually have
	if #screens == 1 then -- assuming this is when the external screen is disconnected
		setDefaultAudioDevice("MacBook Air Speakers") -- Replace with the name of your internal audio device
	else
		setDefaultAudioDevice("Desk Speakers") -- Replace with the name of your external audio device
	end
end

-- Create screen watcher
local screenWatcher = hs.screen.watcher.new(screenChangedCallback)
screenWatcher:start() -- Start watching for screen changes

local function testScreenChange()
	hs.alert("Testing screen change")
	local screens = hs.screen.allScreens()

	-- Change the number based on how many screens you usually have
	if #screens == 1 then -- assuming this is when the external screen is disconnected
		setDefaultAudioDevice("MacBook Air Speakers") -- Replace with the name of your internal audio device
	else
		setDefaultAudioDevice("Desk Speakers") -- Replace with the name of your external audio device
	end
end

-- Bind this function to a hotkey
hs.hotkey.bind({ "cmd", "alt", "ctrl" }, "R", testScreenChange)
