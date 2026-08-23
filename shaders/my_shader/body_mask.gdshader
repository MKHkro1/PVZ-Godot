shader_type canvas_item;

uniform float cutoff_y = 0.0; // 基于节点局部坐标的裁剪高度

void fragment() {
    // VERTEX：当前片元在节点局部坐标中的位置
    vec2 local_pos = VERTEX;

    if (local_pos.y > cutoff_y) {
        COLOR.a = 0.0; // 超过阈值的部分透明
    } else {
        COLOR = texture(TEXTURE, UV); // 其他部分正常显示
    }
}
