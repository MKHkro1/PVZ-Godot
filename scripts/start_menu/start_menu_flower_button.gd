extends TextureButton
class_name StartMenuFlowerButton

@export var fall_time := 5
@export var fall_distance := 20.0
@export var sway_amplitude_range:= Vector2(3,10)
var sway_amplitude := 3.0
@export var sway_speed := 5.0

var petal_sprite: Sprite2D
var age := 0.0
var is_falling := false

func _ready():
	# 连接按下信号
	self.pressed.connect(_on_pressed)
	sway_amplitude = randf_range(sway_amplitude_range.x, sway_amplitude_range.y)

func _on_pressed() -> void:
	if is_falling:
		return

	# --- 1. 创建一个 Sprite2D，使用当前 Button 的图像 ---
	petal_sprite = Sprite2D.new()
	petal_sprite.texture = self.texture_normal    # ← 使用按钮当前的贴图
	petal_sprite.position = global_position       # 放在按钮位置
	petal_sprite.scale = scale                    # 同步缩放
	petal_sprite.centered = false                    # 同步缩放
	#petal_sprite.rotation = randf() * TAU         # 随机初始旋转

	get_tree().root.add_child(petal_sprite)       # 加到最上层 Canvas

	# --- 2. 隐藏按钮 ---
	visible = false

	# --- 3. 开始动画 ---
	age = 0.0
	is_falling = true
	set_process(true)


func _process(delta):
	if not is_falling:
		return

	age += delta
	var t = age / fall_time

	if t >= 1.0:
		# 动画结束：删除花瓣
		petal_sprite.queue_free()
		is_falling = false
		set_process(false)
		visible = true
		return

	# ---- 花瓣动画 ----

	# 下落
	var y = t * fall_distance

	# 左右摆动
	var x = sin(t * sway_speed * TAU) * sway_amplitude * (1.0 - t)

	# 旋转
	petal_sprite.rotation += delta * (1.0 + (randf()-0.5) * 4.0)

	# 透明度渐隐
	var col = petal_sprite.modulate
	col.a = 1.0 - t
	petal_sprite.modulate = col

	petal_sprite.position += Vector2(x, y) * delta * 60
