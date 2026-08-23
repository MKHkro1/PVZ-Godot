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
	## 冒险模式行限制: 1-1单行/1-2三行时裁剪草坪贴图(仅白天草坪)
	if not game_para.usable_rows.is_empty() and game_para.game_BG == ResourceLevelData.GameBg.FrontDay:
		_apply_row_band_crop(game_para.usable_rows)
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

## ===== 行限制草坪裁剪(原版1-1单行/1-2三行观感) =====
## 白天背景纹理行中心y(纹理1400x600, 世界坐标与纹理坐标一一对应)
const BG_ROW_CENTERS:Array[float] = [82.0, 182.0, 282.0, 381.0, 478.0]
const BG_WIDTH := 1400.0
const BG_HEIGHT := 600.0
const BAND_MARGIN := 24.0
const EDGE_SLIVER := 8.0

## 只保留可用行所在的横向条带, 条带外的上下区域用紧邻边缘的草皮切片拉伸填充
func _apply_row_band_crop(usable_rows:Array[int]) -> void:
	var lo:int = usable_rows.min()
	var hi:int = usable_rows.max()
	## 条带上界: 与上一行的中点; 若含第0行则贴纹理顶缘留边
	var top: float = 30.0 if lo == 0 else (BG_ROW_CENTERS[lo] + BG_ROW_CENTERS[lo - 1]) * 0.5 - BAND_MARGIN
	## 条带下界: 与下一行的中点; 若含第4行则贴纹理底缘留边
	var bottom: float = BG_HEIGHT - 40.0 if hi == 4 else (BG_ROW_CENTERS[hi] + BG_ROW_CENTERS[hi + 1]) * 0.5 + BAND_MARGIN
	top = clampf(top, 0.0, BG_HEIGHT)
	bottom = clampf(bottom, top + 10.0, BG_HEIGHT)

	background.region_enabled = true
	background.region_rect = Rect2(0, top, BG_WIDTH, bottom - top)
	## 保持纹理像素与世界坐标一致: 区域起点对齐到 world y = top
	background.position.y = top

	_fill_edge_strip(true, top)
	_fill_edge_strip(false, bottom)

## 在条带上侧/下侧用 8px 草皮切片纵向拉伸, 铺满剩余可视区域
func _fill_edge_strip(is_top: bool, edge_y: float) -> void:
	var strip := Sprite2D.new()
	strip.texture = background.texture
	strip.centered = false
	strip.region_enabled = true
	strip.show_behind_parent = true
	## background 自身 position.y 已被平移到 edge 对齐, 子节点需补偿父位移
	if is_top:
		## 覆盖世界 y ∈ [0, top]: 取条带顶缘内侧切片向下拉伸
		strip.region_rect = Rect2(0, edge_y, BG_WIDTH, EDGE_SLIVER)
		strip.scale = Vector2(1.0, edge_y / EDGE_SLIVER)
		strip.position = Vector2(0.0, -edge_y)
	else:
		## 覆盖世界 y ∈ [bottom, BG_HEIGHT]: 取条带底缘内侧切片向下拉伸
		var fill_h := BG_HEIGHT - edge_y
		strip.region_rect = Rect2(0, edge_y - EDGE_SLIVER, BG_WIDTH, EDGE_SLIVER)
		strip.scale = Vector2(1.0, fill_h / EDGE_SLIVER)
		strip.position = Vector2(0.0, edge_y - background.position.y)
	background.add_child(strip)
