--[[Colorful Critter

(c)2017 fluffy @ beesbuzz.biz. Please see the LICENSE file for license information.

poses.lua - critter poses

When a pose is selected, tables are treated as lists of images to load as textures, and numbers are
just copied into the critter object.

]]

local poses = {
    default = {
        eyeCX = 500/2,
        eyeCY = 172/2,
        eyeMinY = -5,
        eyeMaxY = 2,
        texCoords = {
            "poses/default/uvmap.png",
            },
        overlays = {"poses/default/overlay.png"},
        blush = {"poses/default/blush.png"},
        pupils = {"poses/default/pupils.png"},
        halo = {},
    },
    anxious = {
        eyeCX = 500/2,
        eyeCY = 172/2,
        eyeMinY = -5,
        eyeMaxY = 2,
        texCoords = {
            "poses/anxious/uvmap.png",
            },
        overlays = {"poses/anxious/overlay.png"},
        blush = {"poses/anxious/blush.png"},
        pupils = {"poses/anxious/pupils.png"},
        halo = {},
    },
    angry = {
        eyeCX = 500/2,
        eyeCY = 172/2,
        eyeMinY = -2,
        eyeMaxY = 2,
        texCoords = {
            "poses/angry/uvmap.png",
            },
        overlays = {"poses/angry/overlay.png"},
        blush = {"poses/angry/blush.png"},
        pupils = {"poses/angry/pupils.png"},
        halo = {},
    },
    aroused = {
        eyeCX = 500/2,
        eyeCY = 172/2,
        eyeMinY = -5,
        eyeMaxY = 2,
        texCoords = {
            "poses/aroused/uvmap.png",
            },
        overlays = {"poses/aroused/overlay.png"},
        blush = {"poses/aroused/blush.png"},
        pupils = {"poses/aroused/pupils.png"},
        halo = {},
    },
    orgasm = {
        texCoords = {
            "poses/aroused/orgasm-uvmap.png",
            },
        overlays = {"poses/aroused/orgasm-overlay.png"},
        blush = {"poses/aroused/blush.png"},
        pupils = {},
        halo = {},
    },
    hyperorgasm = {
        texCoords = {
            "poses/aroused/hyperorgasm-uvmap.png"
            },
        overlays = {"poses/aroused/hyperorgasm-overlay.png"},
        blush = {"poses/aroused/blush.png"},
        pupils = {},
        halo = {"poses/aroused/halo.png"},
    },
    frustrated = {
        texCoords = {
            "poses/frustrated/uvmap.png"
            },
        overlays = {"poses/frustrated/overlay.png"},
        blush = {"poses/frustrated/blush.png"},
        pupils = {},
        halo = {},
    },
    relaxed = {
        texCoords = {
            "poses/relaxed/uvmap.png"
            },
        overlays = {"poses/relaxed/overlay.png"},
        blush = {"poses/relaxed/blush.png"},
        pupils = {},
        halo = {},
    },
    refractory = {
        texCoords = {
            "poses/relaxed/uvmap.png"
            },
        overlays = {
            "poses/relaxed/overlay.png",
            "poses/relaxed/refractory.png"
        },
        blush = {
            "poses/relaxed/blush.png"
        },
        pupils = {},
        halo = {},
    },
    hyperrefractory = {
        texCoords = {
            "poses/relaxed/uvmap.png"
            },
        overlays = {
            "poses/relaxed/overlay.png",
            "poses/relaxed/refractory.png"
        },
        blush = {
            "poses/relaxed/blush.png",
        },
        pupils = {},
        halo =  {"poses/relaxed/refractory-halo.png"},
    },
    squirm = {
        eyeCX = 500/2,
        eyeCY = 172/2,
        eyeMinY = -2,
        eyeMaxY = 2,
        texCoords = {
            "poses/squirm/uvmap.png"
            },
        overlays = {"poses/squirm/overlay.png"},
        blush = {"poses/squirm/blush.png"},
        pupils = {"poses/squirm/pupils.png"},
        halo = {},
    },
}

return poses
