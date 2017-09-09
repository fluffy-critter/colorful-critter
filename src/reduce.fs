uniform vec2 size; // texture size, in texels

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
    vec2 ss = vec2(1.0, 1.0)/size;

    vec4 val[5] = vec4[5](
        Texel(texture, texture_coords),
        Texel(texture, texture_coords + vec2(ss.x,0)),
        Texel(texture, texture_coords - vec2(ss.x,0)),
        Texel(texture, texture_coords + vec2(0,ss.y)),
        Texel(texture, texture_coords - vec2(0,ss.y))
    );

    // silly unrolling, necessary for older GPUs
    int count[4] = int[4](
        (val[0] == val[1] ? 1 : 0)
        + (val[0] == val[2] ? 1 : 0)
        + (val[0] == val[3] ? 1 : 0)
        + (val[0] == val[4] ? 1 : 0),
        (val[1] == val[2] ? 1 : 0)
        + (val[1] == val[3] ? 1 : 0)
        + (val[1] == val[4] ? 1 : 0),
        (val[2] == val[3] ? 1 : 0)
        + (val[2] == val[4] ? 1 : 0),
        (val[3] == val[4] ? 1 : 0));

    int maxc = 0;
    maxc = (count[1] > count[maxc]) ? 1 : maxc;
    maxc = (count[2] > count[maxc]) ? 2 : maxc;
    maxc = (count[3] > count[maxc]) ? 3 : maxc;

    return color*val[maxc];
}
