--[[Colorful Critter

(c)2017 fluffy @ beesbuzz.biz, all rights reserved

poses.lua - critter poses

When a pose is selected, tables are treated as lists of images to load as textures, and numbers are
just copied into the critter object.

]]

local poses = {
    default = {
        eyeCX = 500/2,
        eyeCY = 172/2,
        texCoords = {
            "poses/default/uv4.png",
            "poses/default/uv3.png",
            "poses/default/uv2.png",
            "poses/default/uv1.png"
            },
        overlays = {"poses/default/overlay.png"},
        blush = {"poses/default/blush.png"},
        pupils = {"poses/default/pupils.png"},
        halo = {},
    },
    anxious = {
        eyeCX = 500/2,
        eyeCY = 172/2,
        texCoords = {
            "poses/anxious/uv4.png",
            "poses/anxious/uv3.png",
            "poses/anxious/uv2.png",
            "poses/anxious/uv1.png"
            },
        overlays = {"poses/anxious/overlay.png"},
        blush = {"poses/anxious/blush.png"},
        pupils = {"poses/anxious/pupils.png"},
        halo = {},
    },
    aroused = {
        eyeCX = 500/2,
        eyeCY = 172/2,
        texCoords = {
            "poses/aroused/uv4.png",
            "poses/aroused/uv3.png",
            "poses/aroused/uv2.png",
            "poses/aroused/uv1.png"
            },
        overlays = {"poses/aroused/overlay.png"},
        blush = {"poses/aroused/blush.png"},
        pupils = {"poses/aroused/pupils.png"},
        halo = {},
    },
    orgasm = {
        texCoords = {
            "poses/aroused/uv4.png",
            "poses/aroused/uv3.png",
            "poses/aroused/uv2.png",
            "poses/aroused/orgasm-uv1.png"
            },
        overlays = {"poses/aroused/orgasm-overlay.png"},
        blush = {"poses/aroused/blush.png"},
        pupils = {},
        halo = {},
    },
    hyperorgasm = {
        texCoords = {
            "poses/aroused/uv4.png",
            "poses/aroused/uv3.png",
            "poses/aroused/uv2.png",
            "poses/aroused/orgasm-uv1.png"
            },
        overlays = {"poses/aroused/orgasm-overlay.png"},
        blush = {"poses/aroused/blush.png"},
        pupils = {},
        halo = {"poses/aroused/halo.png"},
    },
    frustrated = {
        texCoords = {
            "poses/frustrated/uv4.png",
            "poses/frustrated/uv3.png",
            "poses/frustrated/uv2.png",
            "poses/frustrated/uv1.png"
            },
        overlays = {"poses/frustrated/overlay.png"},
        blush = {"poses/frustrated/blush.png"},
        pupils = {},
        halo = {},
    },
    relaxed = {
        texCoords = {
            "poses/relaxed/uv4.png",
            "poses/relaxed/uv3.png",
            "poses/relaxed/uv2.png",
            "poses/relaxed/uv1.png"
            },
        overlays = {"poses/relaxed/overlay.png"},
        blush = {"poses/relaxed/blush.png"},
        pupils = {},
        halo = {},
    },
    refractory = {
        texCoords = {
            "poses/relaxed/uv4.png",
            "poses/relaxed/uv3.png",
            "poses/relaxed/uv2.png",
            "poses/relaxed/uv1.png"
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
            "poses/relaxed/uv4.png",
            "poses/relaxed/uv3.png",
            "poses/relaxed/uv2.png",
            "poses/relaxed/uv1.png"
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
}

return poses
