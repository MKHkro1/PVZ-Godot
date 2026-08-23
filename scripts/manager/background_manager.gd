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
