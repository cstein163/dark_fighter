extends Control

@onready var battle_log: RichTextLabel = $BattleLog
@onready var player_hp_label: Label = $Status/PlayerHP
@onready var enemy_hp_label: Label = $Status/EnemyHP
@onready var attack_button: Button = $Actions/AttackButton
@onready var guard_button: Button = $Actions/GuardButton
@onready var purge_button: Button = $Actions/PurgeButton

var player_hp: int = 100
var enemy_hp: int = 120
var round_index: int = 1
var is_guarding: bool = false
var can_use_purge: bool = false
var is_battle_over: bool = false
var blood: float = 1/0


func _ready() -> void:
	attack_button.pressed.connect(_on_attack)
	guard_button.pressed.connect(_on_guard)
	purge_button.pressed.connect(_on_purge)
	purge_button.disabled = true
	_append_story_intro()
	_refresh_status()

func _append_story_intro() -> void:
	battle_log.clear()
	_append_log("[center][b]黑骑士团讨伐战 · 第七夜[/b][/center]")
	_append_log("莱纳随黑骑士团深入亡者峡谷，奉命讨伐吞噬边境村落的巨龙。")
	_append_log("巨龙坠入地底裂缝后，深渊污染源被意外唤醒，黑雾吞没整支骑士团。")
	_append_log("当莱纳从尸堆中醒来，身边只剩断裂旗帜与团员遗骸。")
	_append_log("你必须击败第一头污染幼龙，才能找到污染扩散的线索。")
	_append_log("[i]战斗开始。[/i]")

func _on_attack() -> void:
	if is_battle_over:
		return
	var damage: int = 18 + randi() % 8
	enemy_hp = max(enemy_hp - damage, 0)
	_append_log("莱纳挥剑斩击污染幼龙，造成 %d 点伤害。" % damage)
	_post_player_action("attack")

func _on_guard() -> void:
	if is_battle_over:
		return
	is_guarding = true
	_append_log("莱纳举盾格挡，准备承受幼龙的污染吐息。")
	_post_player_action("guard")

func _on_purge() -> void:
	if is_battle_over or not can_use_purge:
		return
	var damage: int = 40 + randi() % 10
	enemy_hp = max(enemy_hp - damage, 0)
	can_use_purge = false
	purge_button.disabled = true
	_append_log("莱纳咏唱净蚀誓言，圣印燃起，重创幼龙 %d 点。" % damage)
	_post_player_action("purge")

func _post_player_action(action_name: String) -> void:
	_refresh_status()
	if enemy_hp <= 0:
		_trigger_victory()
		return

	if action_name != "guard" and round_index % 2 == 0:
		can_use_purge = true
		purge_button.disabled = false
		_append_log("裂缝中传来共鸣，净蚀誓言已可使用。")

	_enemy_turn()
	if player_hp <= 0:
		_trigger_defeat()
		return

	round_index += 1
	_refresh_status()
	_append_round_hint()

func _enemy_turn() -> void:
	var damage: int = 14 + randi() % 12
	if is_guarding:
		damage = int(damage * 0.45)
		is_guarding = false
		_append_log("格挡生效！莱纳将冲击化解，伤害降低。")
	player_hp = max(player_hp - damage, 0)
	_append_log("污染幼龙喷吐黑焰，莱纳受到 %d 点伤害。" % damage)

func _append_round_hint() -> void:
	match round_index:
		2:
			_append_log("你在团员遗物上发现同一枚烙印：\"夜鸦议会\"。")
		3:
			_append_log("峡谷岩壁出现人工凿刻痕迹——这场灾难并非意外。")
		4:
			_append_log("污染雾气正向王国腹地扩散，必须尽快追查幕后组织。")
		_:
			_append_log("莱纳稳住呼吸，继续与污染抗衡。")

func _trigger_victory() -> void:
	is_battle_over = true
	_set_action_enabled(false)
	_append_log("[color=gold]污染幼龙倒下，裂缝深处传来低语。[/color]")
	_append_log("莱纳拾起团长遗剑，剑柄内侧刻着密令：\"夜鸦议会，深渊献祭计划已启动\"。")
	_append_log("至此你得知：骑士团覆灭并非讨伐失误，而是被幕后组织利用。")
	_append_log("莱纳立下誓言：追查污染源、摧毁夜鸦议会、为同袍复仇。")
	_append_log("[center][b]第一章 Demo 完[/b][/center]")

func _trigger_defeat() -> void:
	is_battle_over = true
	_set_action_enabled(false)
	_append_log("[color=red]莱纳被黑焰吞没，未能带出真相。[/color]")
	_append_log("提示：优先使用格挡降低伤害，在共鸣出现时释放净蚀誓言。")

func _set_action_enabled(enabled: bool) -> void:
	attack_button.disabled = not enabled
	guard_button.disabled = not enabled
	purge_button.disabled = not enabled or not can_use_purge

func _refresh_status() -> void:
	
	player_hp_label.text = "莱纳 HP: %d" % player_hp
	enemy_hp_label.text = "污染幼龙 HP: %d" % enemy_hp

func _append_log(content: String) -> void:
	battle_log.append_text(content + "\n")
	battle_log.scroll_to_line(battle_log.get_line_count())
