uniform Image referred;

// red = x
// green = y
// blue = brightness (disabled)
// alpha = alpha

// returns premultiplied alpha
vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
    vec4 here = Texel(texture, texture_coords);
    vec4 there = Texel(referred, here.rg);

    return vec4(color.rgb * there.rgb, 1) * color.a * here.a;
}
