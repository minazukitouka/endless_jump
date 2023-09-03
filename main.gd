extends Node2D

const floor_scene := preload('res://floor.tscn')

@onready var initial_floor: StaticBody2D = $InitialFloor
@onready var camera_2d: Camera2D = $Camera2D
@onready var floors: Node2D = $Floors

@onready var life_label: Label = $CanvasLayer/Life
@onready var score_label: Label = $CanvasLayer/Score
@onready var game_over_label: Label = $CanvasLayer/GameOver
@onready var player: CharacterBody2D = $Player

@export var scroll_speed: float = -50.0
@export var gap_between_floor: float = 100.0
@export var floor_minimum_distance_to_boundary: float = 150.0
@export var floor_maximum_distance: float = 800.0

var is_game_started = false
var is_game_over = false
var screen_height = ProjectSettings.get_setting("display/window/size/viewport_height")
var screen_width = ProjectSettings.get_setting("display/window/size/viewport_width")
var previous_x
var previous_y = 0.0


func _ready() -> void:
	update_life_label(player.life, player.max_life)
	player.life_changed.connect(update_life_label)
	player.life_changed.connect(detect_game_over)
	player.game_started.connect(start_game)
	print_debug('screen height: ', screen_height)
	generate_initial_floors()


func _physics_process(delta: float) -> void:
	if is_game_over:
		if Input.is_action_just_pressed('ui_accept'):
			get_tree().reload_current_scene()
		return
	if not is_game_started:
		return
	camera_2d.position.y += scroll_speed * delta
	queue_free_sink_floors()
	generate_next_floor()
	score_label.text = str(floor(abs(camera_2d.position.y)))


func update_life_label(life, max_life):
	life_label.text = "{0}/{1}".format([life, max_life])


func detect_game_over(life, _max_life):
	if life != 0:
		return
	is_game_over = true
	player.queue_free()
	game_over_label.visible = true


func start_game():
	initial_floor.queue_free()
	is_game_started = true
	print_debug('start game')


func queue_free_sink_floors():
	var floors = get_tree().get_nodes_in_group('float_floors')
	for floor in floors:
		if floor.position.y > camera_2d.position.y + screen_height + 50:
			floor.queue_free()


func get_random_x_for_floor():
	var candidate = randf_range(floor_minimum_distance_to_boundary, screen_width - floor_minimum_distance_to_boundary)
	while abs(candidate - previous_x) > floor_maximum_distance:
		candidate = get_random_x_for_floor()
	return candidate


func generate_initial_floors():
	previous_x = screen_width / 2
	var y = 0
	while y < screen_height:
		generate_floor_at_height(y)
		y += gap_between_floor
	previous_x = floors.get_child(0).position.x


func generate_next_floor():
	if camera_2d.position.y < previous_y:
		var y = previous_y - gap_between_floor
		generate_floor_at_height(y)
		previous_y = y


func generate_floor_at_height(y):
	var x = get_random_x_for_floor()
	var floor_position = Vector2(x, y)
	var floor = floor_scene.instantiate()
	floor.position = floor_position
	floors.add_child(floor)
	previous_x = x
