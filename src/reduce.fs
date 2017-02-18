uniform vec2 size; // texture size, in texels

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
    vec2 pos = texture_coords*size;

    vec4 colors[3*3];
    int counts[3*3];
    int allocated = 0;

    int maxCount = 0;
    vec4 maxColor;

    // TODO: unroll?
    for (int x = -1; x <= 1; x++) {
        for (int y = -1; y <= 1; y++) {
            vec2 pos = texture_coords + vec2(x,y)/size;
            vec4 here = Texel(texture, pos);

            int k;
            for (k = 0; k < allocated; k++) {
                if (colors[k] == here) {
                    ++counts[k];
                    break;
                }
            }

            // didn't find it already, allocate a new color cell
            if (k == allocated) {
                colors[k] = here;
                counts[k] = 1;
                ++allocated;
            }

            // check for new winner
            if (counts[k] > maxCount) {
                maxCount = counts[k];
                maxColor = colors[k];
            }
        }
    }

    return maxColor;
}
