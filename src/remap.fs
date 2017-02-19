uniform Image referred;

// red = x
// green = y
// blue = brightness
// alpha = alpha
vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
    vec4 here = Texel(texture, texture_coords);
    vec4 there = Texel(referred, here.rg/here.a);

    return color
        * here.a
        * vec4(there.rgb * here.b, 1)*here.a;
}
