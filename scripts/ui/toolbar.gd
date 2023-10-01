extends Control
class_name Toolbar

@onready var disk_space_bar := %DiskSpaceBar
@onready var disk_space_label := %DiskSpaceLabel
@onready var pause_menu := %PauseMenu
@onready var blocker := $Blocker
@onready var date_label := %Date


func _physics_process(_delta):
	var time = Time.get_time_dict_from_system()
	date_label.text = str(time["hour"]) + ":" + str(time["minute"])


func _on_disk_space_manager_space_update(new_space, max_space):
	# TODO: change colour (and animation?) according to space occupied
	disk_space_bar.max_value = max_space
	disk_space_bar.min_value = 0
	disk_space_bar.value = new_space
	
	disk_space_label.text = str(max_space - new_space) + " free out of " + str(max_space)


func _on_empty_button_pressed():
	SignalManager.empty_trash.emit()


func _on_anti_v_button_pressed():
	SignalManager.toggle_antivirus.emit()


func _on_start_button_pressed():
	if get_tree().paused:
		get_tree().paused = false
		pause_menu.hide()
		blocker.hide()
	else:
		get_tree().paused = true
		pause_menu.show()
		blocker.show()


func _on_logoff_button_pressed():
	# TODO: change to title scene
	pass


func _on_shutdown_button_pressed():
	get_tree().quit()
