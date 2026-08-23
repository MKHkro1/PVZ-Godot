shader_type canvas_item;

// 定义 uniforms（外部可调节的参数）
uniform sampler2D mask_texture;  // 遮罩贴图（通常是一张黑白图，控制透明度）

void fragment() {
    // 1. 采样精灵节点本身的纹理颜色（TEXTURE 是 Godot 内置变量）
    vec4 sprite_color = texture(TEXTURE, UV);

    // 2. 采样遮罩贴图（mask_texture 的 R 通道决定透明度）
    vec4 mask_sample = texture(mask_texture, UV);

    // 3. 应用遮罩裁剪（用 mask 的 R 值乘以原透明度）
    sprite_color.a *= mask_sample.r;

    // 4. 输出最终颜色（COLOR 是 Godot 要求的输出变量）
    COLOR = sprite_color;
}