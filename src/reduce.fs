uniform vec2 size; // texture size, in texels

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
    vec2 ss = vec2(1.5, 1.5)/size;

    // unrolls brought to you by wanting to support GLSL ES 1.0
    vec4 val0 = Texel(texture, texture_coords);
    vec4 val1 = Texel(texture, texture_coords + vec2(ss.x,0));
    vec4 val2 = Texel(texture, texture_coords - vec2(ss.x,0));
    vec4 val3 = Texel(texture, texture_coords + vec2(0,ss.y));
    vec4 val4 = Texel(texture, texture_coords - vec2(0,ss.y));

    int count0 = (val0 == val1 ? 1 : 0)
        + (val0 == val2 ? 1 : 0)
        + (val0 == val3 ? 1 : 0)
        + (val0 == val4 ? 1 : 0);
    int count1 = (val1 == val2 ? 1 : 0)
        + (val1 == val3 ? 1 : 0)
        + (val1 == val4 ? 1 : 0);
    int count2 = (val2 == val3 ? 1 : 0)
        + (val2 == val4 ? 1 : 0);
    int count3 = (val3 == val4 ? 1 : 0);

    return color*(count3 > count2 && count3 > count1 && count3 > count0 ? val3 :
        (count2 > count1 && count2 > count0 ? val2 :
            (count1 > count0 ? val1 : val0)));
}
