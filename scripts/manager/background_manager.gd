extends Node
class_name BackgroundManager
## 背景管理器,管理背景和前景

@onready var background: Sprite2D = %Background
@onready var frontground: Node2D = %Frontground

@onready var home: MainGameHome = %Home
## 泳池
var pool:Pool
## 浓雾
var fog:Fog

## 雨
var rain:MainGameRain

## 雾
const FOG = preload("uid://bs55ei6xiuugg")
const RAIN = preload("uid://cv3iw5srgpusv")


func init_background_manager(game_para:ResourceLevelData):
	init_background(game_para)
	init_frontground(game_para)

## 初始化背景
func init_background(game_para:ResourceLevelData):
	var curr_bg_texture: Texture2D = game_para.GameBgTextureMap[game_para.game_BG]
	background.texture = curr_bg_texture
	home.init_home(game_para.game_BG)
	## 冒险模式行限制: 1-1单行/1-2三行时, 未解锁行铺泥土(仅白天草坪)
	if not game_para.usable_rows.is_empty() and game_para.game_BG == ResourceLevelData.GameBg.FrontDay:
		_apply_row_dirt_cover(game_para.usable_rows)
	if not game_para.is_zombie_can_home:
		print("僵尸无法进房")
		home.disable_home()
	match game_para.game_BG:
		ResourceLevelData.GameBg.Pool, ResourceLevelData.GameBg.Fog:
			pool = background.get_node(^"Pool")
			pool.init_pool(game_para)

## 初始化前景
func init_frontground(game_para:ResourceLevelData):
	if game_para.is_fog:
		fog = FOG.instantiate()
		frontground.add_child(fog)
	if game_para.is_rain:
		rain = RAIN.instantiate()
		frontground.add_child(rain)

func start_next_game_background_manager_update():
	if is_instance_valid(fog):
		fog.fog_outside()

## ===== 行限制草坪: 未解锁行覆盖泥土贴图(参考原版"草皮未铺"观感) =====
## 白天背景纹理行中心y(纹理1400x600, 世界坐标与纹理坐标一一对应)
const BG_ROW_CENTERS:Array[float] = [82.0, 182.0, 282.0, 381.0, 478.0]
const BG_WIDTH := 1400.0

func _apply_row_dirt_cover(usable_rows:Array[int]) -> void:
	var dirt_tex: Texture2D = load("res://assets/image/background/lawn_dirt.png")
	## 行带边界: 顶缘、相邻行中心中点、底缘
	var bounds: Array[float] = [30.0]
	for i in range(BG_ROW_CENTERS.size() - 1):
		bounds.append((BG_ROW_CENTERS[i] + BG_ROW_CENTERS[i + 1]) * 0.5)
	bounds.append(558.0)
	for r in range(BG_ROW_CENTERS.size()):
		if r in usable_rows:
			continue
		var strip := Sprite2D.new()
		strip.texture = dirt_tex
		strip.centered = false
		strip.region_enabled = true
		strip.region_rect = Rect2(0, 0, 320, 128)
		var band_top := bounds[r]
		var band_h := bounds[r + 1] - band_top
		strip.scale = Vector2(BG_WIDTH / 320.0, band_h / 128.0)
		strip.position = Vector2(background.position.x, band_top)
		background.add_child(strip)
