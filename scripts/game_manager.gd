extends Node

var score = 0
@onready var score_label: Label = $ScoreLabel

func add_score(point):
	score += point
	score_label.text = "You collected " + str(score) + " coins."
