extends Node2D

var speed = 100
var direction = Vector2(1,0)

var screen_size = Vector2()
var window_size = Vector2(250,250)

var idle_timer = 0.0
var is_idling = false

var drop_timer = 0.0
var is_dropping = false 

var is_dragging = false
var drag_offset = Vector2()

var last_mouse = Vector2()
var velocity = Vector2()

@onready var animated_sprite = $AnimatedSprite2D
@onready var area = $Area2D


func _ready():
	screen_size = Vector2(DisplayServer.screen_get_size())
	animated_sprite.play("walking")
	area.input_event.connect(_on_area_input)
	#$Area2D.mouse_entered.connect(_got_hovered)
	#$Area2D.mouse_exited.connect(_got_unhovered)
	$PopupMenu.add_item("idle",0)
	$PopupMenu.add_item("smol",1)
	$PopupMenu.add_item("normal",2)
	$PopupMenu.add_item("flip",3)
	$PopupMenu.add_item("owo",4)

	$PopupMenu.id_pressed.connect(_on_menu_pressed)

	
func _physics_process(delta: float) -> void:
	if is_dragging:
		var mouse_pos = Vector2(DisplayServer.mouse_get_position())
		velocity = (mouse_pos - last_mouse) / delta
		last_mouse = mouse_pos
		var new_win_pos = mouse_pos - drag_offset 
		DisplayServer.window_set_position(Vector2i(new_win_pos))
		return 
	if is_idling:
		idle_timer -= delta
		if idle_timer <= 0:
			is_idling = false
			speed = 100
			animated_sprite.play("walking")
		return
	elif is_dropping:
		drop_timer -= delta 
		if drop_timer <= 0:
			is_dropping = false
			animated_sprite.play("idle")
			idle_timer = 1.0
			is_idling = true
			speed = 0
			#print("done falling")
		#return

	var window_position = Vector2(DisplayServer.window_get_position())
	#var pet = Vector2(DisplayServer.window_get_position()) + Vector2(125,125)
	#var direction = (Vector2(DisplayServer.mouse_get_position()) - pet).normalized()
	if(is_dropping):
		window_position.y += 200 * delta 
	else:
		window_position += direction * speed * delta

	#print(window_position)
	window_position.x = clamp(window_position.x,0,screen_size.x-window_size.x)
	window_position.y = clamp(window_position.y,0,screen_size.y - window_size.y)
	DisplayServer.window_set_position(Vector2i(window_position))
	if (window_position.x <= 0 or window_position.x >= screen_size.x - window_size.x):
		direction.x *= -1
		animated_sprite.flip_h = !animated_sprite.flip_h
		maybe_idle()
	if (window_position.y <= 0 or window_position.y >= screen_size.y - window_size.y):
		direction.y *= -1
		#maybe_idle()

# func get_yeeted(_delta):
# 	velocity = velocity.lerp(Vector2.ZERO, _delta * speed)

# 	if(velocity.x < 0.1 or velocity.y < 0.1):
# 		velocity = Vector2.ZERO
# 		pass 
# 	DisplayServer.window_set_position(Vector2i(DisplayServer.window_get_position()))
# 	var window_position = Vector2(DisplayServer.window_get_position())

# 	window_position += Vector2i(velocity)

func _got_hovered():
	$AnimatedSprite2D.scale = Vector2(0.22,0.22)

func _got_unhovered():
	$AnimatedSprite2D.scale = Vector2(0.2,0.2)

func maybe_idle():
	if randf() < 0.5:
		is_idling = true
		idle_timer = randf_range(1.0,5.0)
		animated_sprite.play("idle")
		speed = 0
		#var r = randi() % 3
		#animated_sprite.play("idle")
			
func _on_area_input(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed and event.double_click:
		if randf() < 0.1:
			OS.shell_open("https://www.youtube.com/watch?v=dQw4w9WgXcQ")
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			is_dragging = true
			animated_sprite.play("drag")
			var mouse_pos = Vector2(DisplayServer.mouse_get_position())
			var win_pos = Vector2(DisplayServer.window_get_position())
			drag_offset = mouse_pos - win_pos
			# window position based on center 
		else:
			drop_timer = 0.3
			idle_timer = 0.0
			is_idling = false
			is_dragging = false
			is_dropping = true
			animated_sprite.play("idle")

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		$PopupMenu.popup_on_parent(Rect2i(Vector2i(event.position),Vector2i.ZERO))


func _on_menu_pressed(id):
	if id == 0:
		speed = 0
		animated_sprite.play("idle")
	if id == 1:
		$AnimatedSprite2D.scale = Vector2(0.1,0.1)
	if id == 2:
		$AnimatedSprite2D.scale = Vector2(0.2,0.2)
	if id == 3:
		direction.x *= -1
		animated_sprite.flip_h = !animated_sprite.flip_h
	if id == 4:
		animated_sprite.rotate(PI)
