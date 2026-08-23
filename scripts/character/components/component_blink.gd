extends ComponentNormBase
class_name BlinkComponent

@onready var blink_timer: Timer = $BlinkTimer
## 眨眼间隔时间
@export var blink_time:float = 5
## 眨眼body变化,每个精灵图对应两个纹理图片
@export var all_blink_body_change:Array[ResourceBodyChange]

func _ready() -> void:
	super()
	blink_timer.wait_time = blink_time
	if is_enabling:
		blink_timer.start(blink_time + randf_range(-1,1))


## 眨眼
func _on_blink_timer_timeout() -> void:
	if is_enabling:
		for blink_body_change in all_blink_body_change:
			var blink_sprite = get_node(blink_body_change.sprite_change[0])
			blink_sprite.visible = true
			_do_blink_onc_sprite(blink_sprite, blink_body_change.sprite_change_texture)


## 一个眼睛眨眼(可能有多个眼睛,三线\裂荚)
func _do_blink_onc_sprite(blink_sprite:Sprite2D, blink_sprite_texture:Array[Texture2D]) -> void:
	blink_sprite.texture = blink_sprite_texture[0]
	if is_inside_tree():
		await get_tree().create_timer(0.1).timeout
		if not is_enabling:
			blink_sprite.visible = false
			return
		blink_sprite.texture = blink_sprite_texture[1]
	if is_inside_tree():
		await get_tree().create_timer(0.1).timeout
		if not is_enabling:
			blink_sprite.visible = false
			return
		blink_sprite.texture = blink_sprite_texture[0]
	if is_inside_tree():
		await get_tree().create_timer(0.1).timeout
		if not is_enabling:
			blink_sprite.visible = false
			return
	blink_sprite.visible = false

## 启用组件
func enable_component(is_enable_factor:E_IsEnableFactor):
	super(is_enable_factor)

	if is_enabling:
		blink_timer.start(blink_time + randf_range(-1,1))

## 禁用组件
func disable_component(is_enable_factor:E_IsEnableFactor):
	super(is_enable_factor)
	if not is_enabling:
		blink_timer.stop()
		for blink_body_change in all_blink_body_change:
			var blink_sprite = get_node(blink_body_change.sprite_change[0])
			blink_sprite.visible = false
