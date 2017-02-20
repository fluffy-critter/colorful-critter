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
    }
}

return poses
