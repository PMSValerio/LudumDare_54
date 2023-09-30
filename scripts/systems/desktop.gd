extends Node2D


## TODO: make this a dict in order to hold all file types' scenes
@export var file_scene : PackedScene
@export var corrupted_files_scene : PackedScene
@export var window_scene : PackedScene
@export var download_window_scene : PackedScene
@export var recursive_window_scene : PackedScene

@onready var _files_holder := $Files
@onready var _windows_holder := $Windows

## this color rect simply serves to define the spawn bounds in the inspector
@onready var _bounds_rect := $Node/BoundsDelimiter


func _ready():
	SignalManager.new_file.connect(_on_new_file)
	SignalManager.new_window.connect(_on_new_window)
	SignalManager.explode_files.connect(_on_explode_files)
	Global.bounds_rect = Rect2(_bounds_rect.position, _bounds_rect.size)


func _on_new_file(file_type):
	
	var file_pos = _get_position_within_bounds()
	
	_create_file(file_type, file_pos, Vector2.ZERO, 0.0)


func _on_new_window(window_type, last_position):
	var windows_pos = _get_position_within_bounds()
	var new_window
	match window_type:
		Global.WindowTypes.NORMAL:
			new_window = window_scene.instantiate()
		Global.WindowTypes.DOWNLOAD:
			new_window = download_window_scene.instantiate()
		Global.WindowTypes.RECURSIVE:
			new_window = recursive_window_scene.instantiate()

			var offset = Global.window_properties[window_type][0]["offset"]
			windows_pos = last_position + Vector2(-offset, offset)
	
	var window_properties = Global.window_properties[window_type]
	var properties = window_properties[randi() % window_properties.size()]
	
	_create_window(new_window, windows_pos, properties)


func _on_explode_files(origin_point : Vector2, quantity : int):
	
	var values = Global.FileTypes.values()
	for i in range(quantity):
		var type = values[randi() % values.size()]
		
		var angle = randf() * 2 * PI
		_create_file(type, origin_point, Vector2.RIGHT.rotated(angle), Global.EXPLODE_SPEED)


# --- || INTERNAL || ---


func _create_file(file_type : int, file_pos : Vector2, move_dir : Vector2, speed : float):
	var new_file : DraggableFile
	match file_type:
		Global.FileTypes.NORMAL:
			new_file = file_scene.instantiate()
		Global.FileTypes.INCREASE_SPAWN_EXE:
			new_file = corrupted_files_scene.instantiate()
			new_file.type = Global.FileTypes.INCREASE_SPAWN_EXE
		Global.FileTypes.CORRUPTED_FOLDER:
			new_file = corrupted_files_scene.instantiate()
			new_file.type = Global.FileTypes.CORRUPTED_FOLDER
	
	if new_file == null:
		push_error("file type not found")
		return
	
	var files_properties = Global.file_properties[file_type]
	var properties = files_properties[randi() % files_properties.size()]

	new_file.position = file_pos
	new_file.move_dir = move_dir
	new_file.speed = speed
	new_file.file_size = properties["size"]
	
	_files_holder.add_child(new_file)
	
	new_file.text = properties["name"]
	new_file.set_icon(properties["anim_name"])
	

func _create_window(window_instance : DraggableWindow, window_pos : Vector2, properties : Dictionary):
	window_instance.position = window_pos
	window_instance.title = properties["title"]
	window_instance.description = properties["description"]
	
	_windows_holder.add_child(window_instance)


## return a position within desktop bounds
func _get_position_within_bounds():
	var xx = randf_range(-_bounds_rect.size.x/2, _bounds_rect.size.x/2)
	var yy = randf_range(-_bounds_rect.size.y/2, _bounds_rect.size.y/2)
	var pos = Vector2(xx, yy)
	
	return pos
