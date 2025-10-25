shader_type canvas_item;

uniform sampler2D screen_tex : hint_screen_texture;

uniform vec4 darkest : source_color;
uniform vec4 dark : source_color;
uniform vec4 light : source_color;
uniform vec4 lightest : source_color;

void fragment() {
    vec4 col = texture(screen_tex, SCREEN_UV);
    float rgb_avg = (col.r + col.g + col.b) / 3.0;

    if (rgb_avg < 0.25) {
        COLOR = darkest;
    } else if (rgb_avg < 0.5) {
        COLOR = dark;
    } else if (rgb_avg < 0.75) {
        COLOR = light;
    } else {
        COLOR = lightest;
    }
}
