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

    int count[5] = int[5](0,0,0,0,0);

    for (int i = 0; i < 4; i++) {
        for (int j = i + 1; j < 5; j++) {
            count[i] += (val[i] == val[j]) ? 1 : 0;
        }
    }

    int maxc = 0;
    for (int i = 1; i < 5; i++) {
        maxc = (count[i] > count[maxc]) ? i : maxc;
    }

    return color*val[maxc];
}
