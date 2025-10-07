shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform float intensity : hint_range(0.0, 1.0) = 0.0;
uniform float darken_factor : hint_range(0.0, 1.0) = 0.5;
uniform float pulse_value : hint_range(0.0, 1.0) = 0.0;

void fragment() {
    vec4 tex = texture(SCREEN_TEXTURE, SCREEN_UV);

    // Escurece a tela conforme a sanidade
    vec3 darkened = tex.rgb * (1.0 - darken_factor * intensity);

    // Pulso preto — escurece temporariamente nas batidas
    float pulse_effect = 1.0 - (pulse_value * intensity);

    COLOR = vec4(darkened * pulse_effect, tex.a);
}
