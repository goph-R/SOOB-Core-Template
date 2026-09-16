-- Entry script. The host runs this once at startup, then calls onStart().
--
-- engine.scene owns the on* hooks: installHooks wires onUpdate / onRender /
-- onKeyDown / onKeyUp / onTextInput / onMouseDown / onMouseUp / onMouseMove
-- into the scene stack, so a scene only defines the methods it cares about.
-- A scene is a plain table; missing methods are no-ops.
--
-- Coordinates everywhere are the virtual canvas: origin at the screen centre,
-- Y growing DOWN, UI_VIRTUAL_H (480) units tall, width scaling with the
-- window's aspect ratio. viewSize() reports the current extent.

local scene = require "engine.scene"

scene.installHooks(_G)

local title = {}

function title:update(dt)
    self.t = (self.t or 0) + dt
end

function title:render()
    local _, vh = viewSize()
    drawText("SOOB TEMPLATE", 0, -20, {
        align = ALIGN_CENTER + ALIGN_MIDDLE,
        scale = 2,
        color = { 1, 1, 1 },
    })
    drawText("edit scripts/main.lua to begin", 0, 20, {
        align = ALIGN_CENTER + ALIGN_MIDDLE,
        color = { 0.62, 0.70, 0.82 },
    })
end

function title:keyDown(name)
    -- Esc is not special-cased by the engine; quitting is the game's call.
    if name == "escape" then requestQuit() end
end

function onStart()
    scene.push(title)
end
