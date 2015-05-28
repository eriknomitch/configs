slate.configAll({
  "defaultToCurrentScreen": true,
  "nudgePercentOf": "screenSize",
  "resizePercentOf": "screenSize",
  "checkDefaultsOnLoad": true
});

var fullscreen = slate.operation("move", {
  "x" : "screenOriginX",
  "y" : "screenOriginY",
  "width" : "screenSizeX",
  "height" : "screenSizeY"
});

slate.bind("f:ctrl;cmd", fullscreen);

/*
# Layouts
layout laptopLayout 'Preview':REPEAT ${full}
layout laptopLayout 'Terminal':REPEAT ${full}

default laptopLayout count:1

bind 8:ctrl layout laptopLayout
*/

var laptopLayout = slate.layout("laptopLayout", {
  "Terminal": {
    "operations": [fullscreen],
    "repeat": true
  }
});

slate.bind("8:ctrl", slate.operation("layout", { "name" : laptopLayout }));

slate.default(["2880x1800"], laptopLayout);

slate.on("appOpened", function(event, app) {
  if (app.name() === "Terminal") {
    slate.operation("layout", { "name" : "laptopLayout" });
  }
});

/*
slate.on("windowOpened", function(event, win) {
  if (win.app().name() === "Terminal") {
    slate.operation("layout", { "name" : "laptopLayout" });
  }
});
*/

/*
# Resize Bindings
bind right:alt       resize +10% +0
bind left:alt        resize -10% +0
bind up:alt          resize +0   -10%
bind down:alt        resize +0   +10%
bind right:ctrl;alt  resize -10% +0 bottom-right
bind left:ctrl;alt   resize +10% +0 bottom-right
bind up:ctrl;alt     resize +0   +10% bottom-right
bind down:ctrl;alt   resize +0   -10% bottom-right

# Push Bindings
bind right:ctrl;cmd  push right bar-resize:screenSizeX/3
bind left:ctrl;cmd   push left  bar-resize:screenSizeX/3
bind up:ctrl;cmd     push up    bar-resize:screenSizeY/2
bind down:ctrl;cmd   push down  bar-resize:screenSizeY/2

# Nudge Bindings
bind right:shift;alt nudge +10% +0
bind left:shift;alt  nudge -10% +0
bind up:shift;alt    nudge +0   -10%
bind down:shift;alt  nudge +0   +10%

# Throw Bindings
bind 1:ctrl;alt         throw 0 resize
bind 2:ctrl;alt         throw 1 resize
bind 3:ctrl;alt         throw 2 resize
bind right:ctrl;alt;cmd throw right resize
bind left:ctrl;alt;cmd  throw left  resize
bind up:ctrl;alt;cmd    throw up    resize
bind down:ctrl;alt;cmd  throw down  resize

# Focus Bindings
bind right:cmd    focus right
bind left:cmd     focus left
bind up:cmd       focus up
bind down:cmd     focus down
bind up:cmd;alt   focus behind
bind down:cmd;alt focus behind

# Window Hints
bind esc:cmd hint

*/
