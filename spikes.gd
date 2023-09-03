extends Area2D

@export var spikes_count: int = 10

@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var line_2d: Line2D = $Line2D
@onready var damage_timer: Timer = $DamageTimer

var entered_player


func _ready() -> void:
	draw_spikes()
	body_entered.connect(start_damage_player)
	body_exited.connect(end_damage_player)
	damage_timer.timeout.connect(damage_player)


func start_damage_player(body):
	body.life -= 1
	entered_player = body
	damage_timer.start()


func end_damage_player(_body):
	damage_timer.stop()


func damage_player():
	entered_player.life -= 1


func draw_spikes():
	var full_width = collision_shape_2d.shape.size.x
	var spike_height = collision_shape_2d.shape.size.y
	var step = full_width / (spikes_count * 2)
	var x = 0.0
	var y = 0.0
	var points = []
	while x <= full_width:
		points.append(Vector2(x - full_width / 2, y))
		x += step
		y = -spike_height if y == 0 else 0
	line_2d.points = points
