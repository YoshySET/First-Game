extends CanvasLayer

## タッチでInputアクションをシミュレートする

@onready var btn_left: Button = $Control/LeftButton
@onready var btn_right: Button = $Control/RightButton
@onready var btn_jump: Button = $Control/JumpButton

func _ready() -> void:
	# ボタンの入力イベントを消費しない（ゲームに届ける）
	btn_left.mouse_filter = Control.MOUSE_FILTER_STOP
	btn_right.mouse_filter = Control.MOUSE_FILTER_STOP
	btn_jump.mouse_filter = Control.MOUSE_FILTER_STOP

	btn_left.button_down.connect(_on_left_pressed)
	btn_left.button_up.connect(_on_left_released)
	btn_right.button_down.connect(_on_right_pressed)
	btn_right.button_up.connect(_on_right_released)
	btn_jump.button_down.connect(_on_jump_pressed)
	btn_jump.button_up.connect(_on_jump_released)

func _send_action(action: StringName, pressed: bool) -> void:
	var ev := InputEventAction.new()
	ev.action = action
	ev.pressed = pressed
	Input.parse_input_event(ev)

func _on_left_pressed() -> void:
	_send_action(&"move_left", true)

func _on_left_released() -> void:
	_send_action(&"move_left", false)

func _on_right_pressed() -> void:
	_send_action(&"move_right", true)

func _on_right_released() -> void:
	_send_action(&"move_right", false)

func _on_jump_pressed() -> void:
	_send_action(&"jump", true)

func _on_jump_released() -> void:
	_send_action(&"jump", false)
