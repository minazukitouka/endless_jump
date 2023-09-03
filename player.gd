extends CharacterBody2D

signal life_changed(life, max_life)
signal game_started

const SPEED = 300.0
const JUMP_VELOCITY = -650.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")

var max_life = 10
var life = 10: set = _set_life
var is_game_started = false


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

		if velocity.y < 0 and Input.is_action_just_released('ui_accept'):
			velocity.y = 0

	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

	if not is_game_started:
		var collision = get_last_slide_collision()
		if collision:
			var collider = collision.get_collider()
			if collider.is_in_group('float_floors'):
				game_started.emit()
				is_game_started = true


func _set_life(value: int):
	if value < life:
		var tween = create_tween()
		modulate = Color.RED
		tween.tween_property(self, 'modulate', Color.WHITE, 0.2)

	life = value
	life_changed.emit(life, max_life)
