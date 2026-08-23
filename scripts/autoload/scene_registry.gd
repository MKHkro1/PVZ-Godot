extends Node
## 散落的加载场景


## 花园植物格子
var PLANT_CELL_GARDEN:PackedScene= load("res://scenes/garden/plant_cell_garden.tscn")
## 花园需求气泡
var GARDEN_SPEECH_BUBBLE = load("res://scenes/garden/garden_speech_bubble.tscn")
## 花园花盆
const GARDEN_FLOWER_POT = preload("res://scenes/garden/garden_flower_pot.tscn")


## 戴夫
var CRAZY_DAVE:PackedScene = load("res://scenes/crazy_dave/crazy_dave.tscn")

## 提示信息
const REMINDER_INFORMATION:PackedScene = preload("res://scenes/ui/reminder_information.tscn")

## 钻石、金币、银币、
const COIN_DIAMOND:PackedScene = preload("res://scenes/item/game_scenes_item/drop/coin_diamond.tscn")
const COIN_GOLD:PackedScene = preload("res://scenes/item/game_scenes_item/drop/coin_gold.tscn")
const COIN_SILVER:PackedScene = preload("res://scenes/item/game_scenes_item/drop/coin_silver.tscn")
const PRESENT:PackedScene = preload("res://scenes/item/game_scenes_item/drop/present.tscn")

## 待选卡槽
var CARD_CANDIDATE_CONTAINER = load("res://scenes/ui/all_cards/card_candidate_container.tscn")
## 植物种植特效
const PLANT_START_EFFECT = preload("res://scenes/item/game_scenes_item/plant_effect/plant_start_effect.tscn")
const PLANT_START_EFFECT_WATER = preload("res://scenes/item/game_scenes_item/plant_effect/plant_start_effect_water.tscn")

## 坑洞
const DOOM_SHROOM_CRATER = preload("res://scenes/fx/doom_shroom_crater.tscn")

## 墓碑
var TOMBSTONE = load("res://scenes/item/game_scenes_item/tombstone.tscn")


## 舞王管理器
var JACKSON_MANAGER = load("res://scenes/character/components/jackson_manager.tscn")

## 奖杯
var TROPHY = load("res://scenes/item/game_scenes_item/trophy.tscn")

## 冰冻僵尸特效
const ICE_EFFECT = preload("res://scenes/fx/ice_effect.tscn")
## 泳池水花场景
const SPLASH = preload("res://scenes/item/game_scenes_item/splash.tscn")
## 火焰特效(火爆辣椒\火焰豌豆)
var FIRE = load("res://scenes/fx/fire.tscn")
## 黄油特效
const BUTTER_SPLAT = preload("res://scenes/fx/butter_splat.tscn")

## 阳光
var SUN = load("res://scenes/item/game_scenes_item/sun.tscn")

## 泥土上升特效
const DIRT_RISE_EFFECT = preload("res://scenes/character/item/dirt_rise_effect.tscn")

## 梯子
const LADDER = preload("res://scenes/item/game_scenes_item/ladder.tscn")
