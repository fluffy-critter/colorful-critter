--[[sound.lua - sound stuff

Colorful Critter

(c)2017 fluffy @ beesbuzz.biz. Please see the LICENSE file for license information.


NOTE: If two sounds end up sharing the same source, they should be set up as mappings to the same object

]]

local sound = {
    pencil = love.audio.newSource("sound/pencil.ogg", "static"),

    radius = love.audio.newSource("sound/noiseclick.ogg", "static"),
    colorPicker = love.audio.newSource("sound/c3.ogg", "static"),
    reset = love.audio.newSource("sound/c2.ogg", "static"),
    eyeDropper = love.audio.newSource("sound/c4.ogg", "static"),
}

return sound
