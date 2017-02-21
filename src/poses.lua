--[[Colorful Critter

(c)2017 fluffy @ beesbuzz.biz, all rights reserved

poses.lua - critter poses

When a pose is selected, tables are treated as lists of images to load as textures, and numbers are
just copied into the critter object.

]]

local poses = {
    default = {
        eyeCX = 500/4,
        eyeCY = 172/4,
        texCoords = {
            "poses/default/uv4.png",
            "poses/default/uv3.png",
            "poses/default/uv2.png",
            "poses/default/uv1.png"
            },
        overlays = {"poses/default/overlay.png"},
        blush = {"poses/default/blush.png"},
        pupils = {"poses/default/pupils.png"}
    },
    anxious = {
        eyeCX = 500/4,
        eyeCY = 172/4,
        texCoords = {
            "poses/anxious/uv4.png",
            "poses/anxious/uv3.png",
            "poses/anxious/uv2.png",
            "poses/anxious/uv1.png"
            },
        overlays = {"poses/anxious/overlay.png"},
        blush = {"poses/anxious/blush.png"},
        pupils = {"poses/anxious/pupils.png"}
    },
    aroused = {
        eyeCX = 500/4,
        eyeCY = 172/4,
        texCoords = {
            "poses/aroused/uv4.png",
            "poses/aroused/uv3.png",
            "poses/aroused/uv2.png",
            "poses/aroused/uv1.png"
            },
        overlays = {"poses/aroused/overlay.png"},
        blush = {"poses/aroused/blush.png"},
        pupils = {"poses/aroused/pupils.png"}
    },
    orgasm = { -- TODO eyes closed, hands on chest
        eyeCX = 500/4,
        eyeCY = 172/4,
        texCoords = {
            "poses/aroused/uv4.png",
            "poses/aroused/uv3.png",
            "poses/aroused/uv2.png",
            "poses/aroused/uv1.png"
            },
        overlays = {"poses/aroused/overlay.png"},
        blush = {"poses/orgasm/blush.png"},
        pupils = {"poses/aroused/pupils.png"}
    },
    hyperorgasm = { -- TODO eyes closed, hands on chest
        eyeCX = 500/4,
        eyeCY = 172/4,
        texCoords = {
            "poses/aroused/uv4.png",
            "poses/aroused/uv3.png",
            "poses/aroused/uv2.png",
            "poses/aroused/uv1.png"
            },
        overlays = {"poses/aroused/overlay.png"},
        blush = {
            "poses/orgasm/blush.png",
            "poses/orgasm/halo.png"
        },
        pupils = {"poses/aroused/pupils.png"}
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
        pupils = {}
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
        pupils = {}
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
        pupils = {}
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
            "poses/relaxed/refractory-halo.png"
        },
        pupils = {}
    },
}

return poses
