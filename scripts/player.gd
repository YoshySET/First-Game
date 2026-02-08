extends CharacterBody2D


const SPEED = 130.0
const JUMP_VELOCITY = -300.0

var is_hurt := false
var blink_timer := 0.0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var jump_sound: AudioStreamPlayer2D = $JumpSound
@onready var hit_sound: AudioStreamPlayer2D = $HitSound
@onready var hurt_timer: Timer = $HurtTimer

func hit_enemy() -> void:
	if is_hurt:
		return
	is_hurt = true
	blink_timer = 0.0
	hit_sound.play()
	animated_sprite.play("hurt")
	hurt_timer.start()

func _on_hurt_timer_timeout() -> void:
	is_hurt = false
	animated_sprite.visible = true

func _process(delta: float) -> void:
	if is_hurt:
		blink_timer += delta
		if blink_timer >= 0.1:
			blink_timer = 0.0
			animated_sprite.visible = not animated_sprite.visible

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
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
		
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
