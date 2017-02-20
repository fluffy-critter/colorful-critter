--[[

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

local states = {
    default = {
        pose = "default",
        nextState = (function(c)
            if c.anxiety < 5 and c.itchy < 5 then
                return "relaxed"
            elseif c.anxiety > 100 then
                return "anxious"
            elseif c.itchy > 12 then
                return "itchy"
            elseif c.estrus > 0.8 then
                return "aroused"
            end
        end)
    },

    relaxed = {
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
        nextState = (function(c)
            if c.anxiety < 80 and c.estrus <= 1.0 then
                return "default"
            elseif c.estrus > 0.5 then
                return "frustrated"
            end
        end)
    },

    aroused = {
        nextState = (function(c)
            if c.estrus > 1.5 then
                return "orgasm"
            elseif c.estrus < 0.5 then
                return "default"
            elseif c.itchy > 10 then
                return "frustrated"
            end
        end)
    },

    orgasm = {
        nextState = (function(c)
            if c.estrus < 0.9 then
                return "refractory"
            elseif c.estrus > 2.0 then
                return "hyperorgasm"
            end
        end)
    },

    hyperorgasm = {
        nextstate = (function(c)
            if c.estrus < 1.0 then
                return "refractory"
            end
        end)
    },

    itchy = {
        nextState = (function(c)
            if c.anxiety > 200 or c.estrus > 0.8 then
                return "frustrated"
            elseif c.itchy < 1 then
                return "default"
            end
        end)
    },

    frustrated = {
        nextState = (function(c)
            if c.estrus > 1.8 then
                return "orgasm"
            elseif c.anxiety < 30 and c.itchy < 3 then
                return "default"
            end
        end)
    },

    refractory = {
        nextState = (function(c)
            if c.anxiety > 50 or c.itchy > 10 then
                return "squirm"
            elseif c.estrus < 0.3 then
                return "resetting"
            end
        end)
    },

    resetting = {
        onEnterState = (function(c)
            c.setPattern()
        end),
        nextState = (function(c)
            if c.estrus < 0.1 then
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
