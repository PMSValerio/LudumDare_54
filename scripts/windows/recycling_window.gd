extends DraggableWindow
class_name RecyclingWindow


@onready var ok_button : Button = %OKButton
@onready var recycling_bar : ProgressBar = %RecycleProgress
@onready var recycling_timer : Timer = $Timer

const MIN_RECYCLE_TIME := 0.2 ## in seconds
const MAX_RECYCLE_TIME := 3.0 ## in seconds


const TIMER_RATE := 0.1 ## in seconds
var timer_value_increment := 1

var space_to_recycle = 0:
	set(value):
		space_to_recycle = value
		# might be useful to for something down the line


func _ready():
	recycling_timer.wait_time = TIMER_RATE

	# max recycle time corresponds to recycling of max disk space
	var time_to_recycle = (space_to_recycle * MAX_RECYCLE_TIME) / Global.MAX_TRASH_SPACE
	time_to_recycle = clamp(time_to_recycle, MIN_RECYCLE_TIME, MAX_RECYCLE_TIME)
	timer_value_increment = recycling_bar.max_value/(time_to_recycle/TIMER_RATE)

	recycling_timer.start()
	close_button.disabled = true
	ok_button.disabled = true


func _on_timer_timeout():
	recycling_bar.value = recycling_bar.value + timer_value_increment
	
	if recycling_bar.value >= recycling_bar.max_value:
		recycling_timer.stop()

		close_button.disabled = false
		ok_button.disabled = false

		SignalManager.after_recycle_time.emit()
		


func _on_button_pressed():
	play_click_sfx()
	SignalManager.after_recycle_time.emit()
	await _click_sfx.finished
	self.queue_free()
