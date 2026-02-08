extends Node

var score := 0
var total_coins := 7  # ステージ内のコイン総数
@onready var score_label: Label = $ScoreLabel

func _ready() -> void:
	_update_score_label()

func add_score(point: int) -> void:
	score += point
	_update_score_label()

func _update_score_label() -> void:
	score_label.text = "Coins: %d/%d" % [score, total_coins]
