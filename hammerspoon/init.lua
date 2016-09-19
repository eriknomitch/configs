--hs.hotkey.bind({"cmd", "alt", "ctrl"}, "W", function()
  --hs.notify.new({title="Hammerspoon", informativeText="Hello World"}):send()
--end)

local movement = {"cmd", "ctrl"}
local hyper    = {"shift", "cmd", "alt", "ctrl"}

hs.window.animationDuration = 0

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
  local win    = hs.window.focusedWindow()
  local f      = win:frame()
  local screen = win:screen()
  local max    = screen:frame()

  f.x = max.x
  f.y = max.y
  f.w = max.w
  f.h = max.h

  win:setFrame(f)
end

hs.hotkey.bind(movement, "Up", fullscreen)

-----------------------------------------------
-- Reload config on write
-----------------------------------------------
function reload_config(files)
  hs.reload()
end
hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", reload_config):start()

-----------------------------------------------
-- Hyper i to show window hints
-----------------------------------------------

hs.hotkey.bind(movement, "h", function()
  hs.hints.windowHints()
end)


local layouts = {
  {
    name = {"Kiwi for Gmail"},
    func = function(index, win)
      win:maximize()
    end
  }
}

function watchWindow(win, initializing)
  hs.alert.show("Window")
  --local appWindows = watchers[win:application():pid()].windows
  --if win:isStandard() and not appWindows[win:id()] then
    --local watcher = win:newWatcher(handleWindowEvent, {pid=win:pid(), id=win:id()})
    --appWindows[win:id()] = watcher

    --watcher:start({events.elementDestroyed, events.windowResized, events.windowMoved})

    --if not initializing then
      --hs.alert.show('window created: '..win:id()..' with title: '..win:title())
    --end
  --end
end

function handleAppEvent(element, event)
  hs.alert.show(element)

  if event == events.windowCreated then
    watchWindow(element)
  elseif event == events.focusedWindowChanged then
    -- Handle window change
    
    --if app.name == "iTerm2" then
      --fullscreen()
    --end


  end
end

function handleGlobalAppEvent(name, event, app)
  if event == hs.application.watcher.launched then
    hs.alert.show("App launched")

    local watcher = app:newWatcher(handleAppEvent)
    watcher:start({events.windowCreated, events.focusedWindowChanged})
  end
end


local watcher = hs.application.watcher.new(handleGlobalAppEvent)
watcher:start()


hs.alert.show("Config loaded")


--local events = hs.uielement.watcher

--watchers = {}

--function init()
  --appsWatcher = hs.application.watcher.new(handleGlobalAppEvent)
  --appsWatcher:start()

  ------ Watch any apps that already exist
  ----local apps = hs.application.runningApplications()
  ----for i = 1, #apps do
    ----if apps[i]:title() ~= "Hammerspoon" then
      ----watchApp(apps[i], true)
    ----end
  ----end
--end

--function handleGlobalAppEvent(name, event, app)
  --if     event == hs.application.watcher.launched then
    --watchApp(app)
  --elseif event == hs.application.watcher.terminated then
    ---- Clean up
    --local appWatcher = watchers[app:pid()]
    --if appWatcher then
      --appWatcher.watcher:stop()
      --for id, watcher in pairs(appWatcher.windows) do
        --watcher:stop()
      --end
      --watchers[app:pid()] = nil
    --end
  --end
--end

--function watchApp(app, initializing)
  --if watchers[app:pid()] then return end

  --local watcher = app:newWatcher(handleAppEvent)
  --watchers[app:pid()] = {watcher = watcher, windows = {}}

  --watcher:start({events.windowCreated, events.focusedWindowChanged})

  ---- Watch any windows that already exist
  --for i, window in pairs(app:allWindows()) do
    --watchWindow(window, initializing)
  --end
--end

--function handleAppEvent(element, event)
  --if event == events.windowCreated then
    --watchWindow(element)
  --elseif event == events.focusedWindowChanged then
    ---- Handle window change
  --end
--end


--function handleWindowEvent(win, event, watcher, info)
  --if event == events.elementDestroyed then
    --watcher:stop()
    --watchers[info.pid].windows[info.id] = nil
  --else
    ---- Handle other events...
  --end
  --hs.alert.show('window event '..event..' on '..info.id)
--end

--init()

