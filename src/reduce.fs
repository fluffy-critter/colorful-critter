uniform vec2 size; // texture size, in texels

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
    vec2 pos = texture_coords*size;

    vec3 offsets[9] = vec3[9](
        vec3(0,0,2),
        vec3(1,0,1),
        vec3(0,1,1),
        vec3(-1,0,1),
        vec3(0,-1,1),
        vec3(1,1,.7),
        vec3(1,-1,.7),
        vec3(-1,1,.7),
        vec3(-1,-1,.7)
    );

    vec4 colors[9];
    float counts[9];
    int allocated = 0;

    float maxCount = 0;
    vec4 maxColor;

    // TODO: unroll?
    for (int i = 0; i < 9; i++) {
        vec2 pos = texture_coords + offsets[i].xy/size;
        vec4 here = Texel(texture, pos);
        float weight = offsets[i].z;

        int k;
        for (k = 0; k < allocated; k++) {
            if (colors[k] == here) {
                counts[k] += weight;
                break;
            }
        }

        // didn't find it already, allocate a new color cell
        if (k == allocated) {
            colors[k] = here;
            counts[k] = weight;
            ++allocated;
        }

        // check for new winner
        if (counts[k] > maxCount) {
            maxCount = counts[k];
            maxColor = colors[k];
        }
    }

    return maxColor;
}
