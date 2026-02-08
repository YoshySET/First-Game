extends CharacterBody2D


const SPEED = 130.0
const JUMP_VELOCITY = -300.0
const COYOTE_TIME := 0.12
const JUMP_BUFFER_TIME := 0.15
const KNOCKBACK_VELOCITY := Vector2(80, -120)
const SCREEN_SHAKE_AMOUNT := 4.0

var is_hurt := false
var blink_timer := 0.0
var coyote_timer := 0.0
var jump_buffer_timer := 0.0
var screen_shake := 0.0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var jump_sound: AudioStreamPlayer2D = $JumpSound
@onready var hit_sound: AudioStreamPlayer2D = $HitSound
@onready var hurt_timer: Timer = $HurtTimer
@onready var camera: Camera2D = $Camera2D

func hit_enemy(enemy_position: Vector2 = global_position) -> void:
	if is_hurt:
		return
	is_hurt = true
	blink_timer = 0.0
	screen_shake = SCREEN_SHAKE_AMOUNT
	hit_sound.play()
	animated_sprite.play("hurt")
	# 敵の反対方向にノックバック
	var knock_dir: float = sign(global_position.x - enemy_position.x)
	if knock_dir == 0:
		knock_dir = -1.0 if animated_sprite.flip_h else 1.0
	velocity = Vector2(knock_dir * KNOCKBACK_VELOCITY.x, KNOCKBACK_VELOCITY.y)
	hurt_timer.start()

func _on_hurt_timer_timeout() -> void:
	is_hurt = false
	animated_sprite.visible = true

func _process(delta: float) -> void:
	# コヨーテタイム・ジャンプバッファ
	coyote_timer -= delta
	jump_buffer_timer -= delta
	if is_on_floor():
		coyote_timer = COYOTE_TIME
	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer = JUMP_BUFFER_TIME

	# 点滅
	if is_hurt:
		blink_timer += delta
		if blink_timer >= 0.1:
			blink_timer = 0.0
			animated_sprite.visible = not animated_sprite.visible

	# スクリーンシェイク
	if screen_shake > 0:
		screen_shake = max(0, screen_shake - delta * 15)
		camera.offset = Vector2(randf_range(-screen_shake, screen_shake), randf_range(-screen_shake, screen_shake))
	else:
		camera.offset = Vector2.ZERO

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump (coyote time + jump buffer)
	var can_jump := is_on_floor() or coyote_timer > 0
	if jump_buffer_timer > 0 and can_jump:
		jump_buffer_timer = 0
		coyote_timer = 0
		jump_sound.play()
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("move_left", "move_right")
	
	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true
		
	# playerアニメーション（hurt中はスキップ）
	if not is_hurt:
		if is_on_floor():
			if direction == 0:
				animated_sprite.play("idle")
			else:
				animated_sprite.play("run")
		else:
			animated_sprite.play("jump")
		
	# 通常時のみ移動入力（hurt中はノックバック維持）
	if not is_hurt:
		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
