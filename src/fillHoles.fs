vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
    vec4 here = Texel(texture, texture_coords);
    if (here.a == 1.0) {
        return here;
    }

    // fill in holes by taking weighted-by-alpha average of 5x5 box
    for (int i = -3; i <= 3; i++) {
        for (int j = -3; j <= 3; j++) {
            vec4 s = Texel(texture, texture_coords + vec2(i,j)/256);
            here += vec4(s.rgb*s.a, s.a)/(i*i + j*j + 1);
        }
    }

    if (here.a > 0.0) {
        here /= here.a;
    }

    return here;
}
