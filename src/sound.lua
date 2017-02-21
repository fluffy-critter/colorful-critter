--[[sound.lua - sound stuff

Colorful Critter

(c)2017 fluffy @ beesbuzz.biz, all rights reserved


NOTE: If two sounds end up sharing the same source, they should be set up as mappings to the same object

]]

local sound = {
    pencil = love.audio.newSource("sound/pencil.ogg"),

    colorPicker = love.audio.newSource("sound/c2.ogg"),
    reset = love.audio.newSource("sound/c3.ogg"),
    eyeDropper = love.audio.newSource("sound/c4.ogg"),
}

return sound
