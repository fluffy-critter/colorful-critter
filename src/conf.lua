--[[
Colorful Critter

(c)2017 fluffy @ beesbuzz.biz, all rights reserved

conf.lua - initial configuration

]]

function love.conf(t)
    t.modules.joystick = false
    t.modules.physics = false
    t.window.resizable = true
    t.window.height = 512
    t.window.width = t.window.height*3/2
    -- vertical padding for letterboxish thing
    t.window.height = t.window.height + 40
    t.version = "0.10.2"

    t.window.title = "Colorful Critter"
end
