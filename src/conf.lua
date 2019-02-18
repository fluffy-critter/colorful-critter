--[[
Colorful Critter

(c)2017 fluffy @ beesbuzz.biz. Please see the LICENSE file for license information.

conf.lua - initial configuration

]]

function love.conf(t)
    t.modules.joystick = false
    t.modules.physics = false
    t.window.resizable = true
    t.window.height = 512
    t.window.width = t.window.height*3/2
    -- t.window.vsync = false
    -- vertical padding for letterboxish thing
    t.window.height = t.window.height + 40
    t.version = "11.2"

    t.window.title = "Colorful Critter"
end
