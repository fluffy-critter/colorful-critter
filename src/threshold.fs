uniform float threshold;

// convert non-premultiplied alpha into alpha=1 or 0
vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
    vec4 here = Texel(texture, texture_coords);
    if (here.a > threshold) {
        return vec4(here.rgb, 1.0);
    }

    return vec4(0.0, 0.0, 0.0, 0.0);
}

