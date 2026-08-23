extends Control

@onready var viewport := $PanelContainer/MarginContainer/SubViewportContainer/SubViewport
@onready var output_display := $TextureRect
@onready var export_button := $Button


func _ready():
	# 设置 Viewport 尺寸和透明背景
	#viewport.size = Vector2i(512, 512)
	viewport.transparent_bg = true

	export_button.pressed.connect(_export_combined_image)


func _export_combined_image():
	var img: Image = viewport.get_texture().get_image()
	var path := "res://combined_result.png"
	img.save_png(path)
	print("图片已保存到: ", path)

#
#extends Node
#
#func apply_mask_and_save():
	## 加载图片资源
	#var base_image = load("res://assets/reanim/CrazyDave_body1.jpg")  # 被遮罩的主图
	#var mask_image = load("res://assets/reanim/CrazyDave_body1_.png")  # 遮罩图（用R通道）
	#
	## 转换为Image类型
	#var base = base_image.get_image()
	#var mask = mask_image.get_image()
		#
	## 2. 转换图片格式（RGBA8支持透明度）
	#base.convert(Image.FORMAT_RGBA8)
	#mask.convert(Image.FORMAT_RGBA8)
	#
	## 确保图片尺寸一致
	#if base.get_size() != mask.get_size():
		#base.resize(mask.get_width(), mask.get_height())
	#
	## 应用遮罩效果
	#for x in base.get_width():
		#for y in base.get_height():
			#var base_pixel = base.get_pixel(x, y)
			#var mask_pixel = mask.get_pixel(x, y)
			##if mask_pixel.r < 0.9:
				#
				## 用mask的R通道控制base的alpha
			#base_pixel.a = mask_pixel.r
			#
			#base.set_pixel(x, y, base_pixel)
	#
	## 保存结果（PNG支持透明度）
	#base.save_png("res://CrazyDave_body1.png")
	#print("保存成功：res://CrazyDave_body1.png")
#
#func _ready():
	#apply_mask_and_save()
