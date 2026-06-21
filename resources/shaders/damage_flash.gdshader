shader_type canvas_item;

// Exposes a slider (0.0 to 1.0) and color picker in the Inspector
uniform float flash_modifier : hint_range(0.0, 1.0) = 0.0;
uniform vec4 flash_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);

void fragment() {
    // Get the sprite's original pixel color
    vec4 texture_color = texture(TEXTURE, UV);
    
    // Linearly blend the original color into the flash color based on the modifier
    COLOR.rgb = mix(texture_color.rgb, flash_color.rgb, flash_modifier);
    
    // Maintain the original sprite's transparency boundaries
    COLOR.a = texture_color.a;
}