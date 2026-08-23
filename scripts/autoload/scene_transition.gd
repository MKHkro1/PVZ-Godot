extends CanvasLayer
## 全局场景切换过渡:淡入淡出,消除场景硬切的僵硬感
## 使用:SceneTransition.change_scene("res://xxx.tscn")
##
## 体验细节:
## - 淡入期间后台线程预载新场景, 切换瞬间不再卡顿
## - 全黑瞬间按映射表即刻切换 BGM, 不等新场景 _ready(旧曲不会拖尾一两秒)
## - 同曲目由 SoundManager 去重, 跨场景音乐无缝衔接

## 主场景入口 BGM 映射(路径 → SoundManager.BGM_TRACKS key)
const SCENE_ENTRY_BGM := {
	"res://scenes/main/01StartMenu.tscn": &"start_menu",
	"res://scenes/main/02AdventureChooesLevel.tscn": &"choose_card",
	"res://scenes/main/03MiniGameChooesLevel.tscn": &"choose_card",
	"res://scenes/main/04PuzzleChooesLevel.tscn": &"choose_card",
	"res://scenes/main/05SurvivalChooesLevel.tscn": &"choose_card",
	"res://scenes/main/06CustomChooesLevel.tscn": &"choose_card",
	"res://scenes/main/MainGame01Front.tscn": &"choose_card",
	"res://scenes/main/MainGame02Back.tscn": &"choose_card",
	"res://scenes/main/MainGame03Roof.tscn": &"choose_card",
	"res://scenes/main/10Garden.tscn": &"garden",
}

var _rect: ColorRect
var _is_transitioning := false

## 音频/切换时序诊断(DSH_DEBUG_SCENE=1 时输出)
static var _dbg: bool = OS.has_environment("DSH_DEBUG_SCENE")

func _dbg_mark(msg: String) -> void:
	if _dbg:
		print("[SCENE_DBG %8d ms] %s" % [Time.get_ticks_msec(), msg])


func _ready() -> void:
	layer = 100
	_rect = ColorRect.new()
	_rect.color = Color(0, 0, 0, 0)
	## 覆盖全屏且初始不挡输入
	_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_rect)


## 带淡入淡出的场景切换
func change_scene(path: String, duration := 0.22) -> void:
	if _is_transitioning:
		return
	_is_transitioning = true
	## 过渡期间挡住输入,防止连点穿透
	_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	_dbg_mark("change_scene 开始: " + path)

	## 点击瞬间即换入场曲(平滑音量过渡), 音乐先于画面响应
	if SCENE_ENTRY_BGM.has(path):
		SoundManager.play_bgm_smooth(SoundManager.BGM_TRACKS[SCENE_ENTRY_BGM[path]])
		_dbg_mark("已触发换曲: " + str(SCENE_ENTRY_BGM[path]))

	## 后台线程预载新场景资源, 与淡入并行
	ResourceLoader.load_threaded_request(path)

	var tween := create_tween()
	tween.tween_property(_rect, "color:a", 1.0, duration)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	await tween.finished
	_dbg_mark("淡入完成(全黑)")

	## 黑屏期间等待预载完成(通常此刻已就绪)
	while ResourceLoader.load_threaded_get_status(path) == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
		await get_tree().process_frame

	var packed: PackedScene = null
	if ResourceLoader.load_threaded_get_status(path) == ResourceLoader.THREAD_LOAD_LOADED:
		packed = ResourceLoader.load_threaded_get(path)
	_dbg_mark("预载就绪")

	if packed != null:
		get_tree().change_scene_to_packed(packed)
	else:
		## 预载失败兜底: 回退同步切换
		printerr("[SceneTransition] 场景线程加载失败, 回退同步切换: ", path)
		get_tree().change_scene_to_file(path)
	_dbg_mark("change_scene_to_packed 返回(实例化+_ready 完成)")

	## 等两帧让新场景完成布局后再淡出
	await get_tree().process_frame
	await get_tree().process_frame
	tween = create_tween()
	tween.tween_property(_rect, "color:a", 0.0, duration)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	await tween.finished

	_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_is_transitioning = false
