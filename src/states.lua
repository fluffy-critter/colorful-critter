--[[
Colorful Critter

(c)2017 fluffy @ beesbuzz.biz, all rights reserved

states.lua - state transition table for the critter

A state looks like this:

stateName = {
    pose = "poseName",
    onEnterState = (function(c)
        -- stuff to do when the state is entered
    end),
    nextState = (function(c)
        -- returns a string for the state to transition to, if appropriate
    end)
}

]]

local sound = require('sound')

local states = {
    default = {
        pose = "default",
        nextState = (function(c)
            if c.anxiety < 5 and c.itchy < 5 then
                return "relaxed"
            elseif c.anxiety > 70 then
                return "anxious"
            elseif c.itchy > 8 then
                return "itchy"
            elseif c.estrus > 0.8 then
                return "aroused"
            end
        end)
    },

    relaxed = {
        pose = "relaxed",
        onEnterState = (function(c)
            -- love.sound.play("sigh")
        end),
        nextState = (function(c)
            if c.anxiety > 10 or c.itchy > 10 then
                return "default"
            elseif c.estrus > 0.8 then
                return "aroused"
            elseif c.itchy > 10 then
                return "itchy"
            end
        end)
    },

    anxious = {
        pose = "anxious",
        nextState = (function(c)
            if c.anxiety < 80 and c.estrus <= 1.0 then
                return "default"
            elseif c.itchy > 9 then
                return "angry"
            elseif c.estrus > 0.5 then
                return "frustrated"
            end
        end)
    },

    angry = {
        pose = "angry",
        nextState = (function(c)
            if c.estrus > 1.3 then
                return "frustrated"
            elseif c.itchy < 0.5 then
                return "relaxed"
            elseif c.anxiety < 70 then
                return "default"
            end
        end)
    },

    aroused = {
        pose = "aroused",
        nextState = (function(c)
            if c.estrus > 1.5 then
                return "orgasm"
            elseif c.anxiety > 100 then
                return "angry"
            elseif c.estrus < 0.5 or c.itchy > 10 then
                return "frustrated"
            end
        end)
    },

    orgasm = {
        pose = "orgasm",
        nextState = (function(c)
            if c.estrus < 0.9 then
                return "refractory"
            elseif c.estrus > 2.0 then
                return "hyperorgasm"
            end
        end)
    },

    hyperorgasm = {
        pose = "hyperorgasm",
        onEnterState = (function(c)
            c.haloBright = 0.0
        end),
        nextState = (function(c)
            if c.estrus < 1.0 then
                return "hyperrefractory"
            end
        end)
    },

    itchy = {
        pose = "anxious",
        nextState = (function(c)
            if c.anxiety > 200 or c.estrus > 0.8 then
                return "frustrated"
            elseif c.itchy > 10 and c.anxiety > 80 then
                return "angry"
            elseif c.itchy < 1 then
                return "default"
            end
        end)
    },

    frustrated = {
        pose = "frustrated",
        nextState = (function(c)
            if c.estrus > 1.8 then
                return "orgasm"
            elseif c.estrus > 1.0 and c.anxiety < 50 then
                return "aroused"
            elseif c.anxiety < 30 and c.itchy < 3 then
                return "default"
            end
        end)
    },

    refractory = {
        pose = "refractory",
        nextState = (function(c)
            if c.anxiety > 100 or c.itchy > 18 then
                return "squirm"
            elseif c.estrus < 0.3 then
                return "resetting"
            end
        end)
    },

    hyperrefractory = {
        pose = "hyperrefractory",
        nextState = (function(c)
            if c.estrus < 0.08 then
                return "hyperresetting"
            end
        end)
    },

    resetting = {
        onEnterState = (function(c)
            c.resetFrames = 0
            c.resetCount = 1
        end),
        nextState = (function(c)
            c.resetFrames = c.resetFrames + 1
            if c.resetFrames >= c.resetCount*5 and c.resetCount <= 5 then
                c.setPattern()
                c.resetFrames = 0
                c.resetCount = c.resetCount + 1
                sound.reset:rewind()
                sound.reset:play()
            end
            if c.estrus < 0.1 then
                return "relaxed"
            end
        end)
    },

    hyperresetting = {
        onEnterState = (function(c)
            c.resetFrames = 0
            c.resetCount = 1
        end),
        nextState = (function(c)
            c.resetFrames = c.resetFrames + 1
            if c.resetFrames >= c.resetCount*4 and c.resetCount <= 8 then
                c.setPattern()
                c.resetFrames = 0
                c.resetCount = c.resetCount + 1
                sound.reset:rewind()
                sound.reset:play()
            end
            if c.estrus < 0.03 then
                return "relaxed"
            end
        end)
    },

    squirm = {
        nextState = (function(c)
            if c.anxiety < 25 and c.itchy < 8 then
                return "refractory"
            end
        end)
    }
}

return states
