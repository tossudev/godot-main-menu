extends Control

@onready var master_volume_bg = $VolumeMaster/SliderBackground


func _on_slider_value_changed(value):
	master_volume_bg.set_value(value)
	AudioServer.set_bus_volume_db(0, convert_audio_value(value))


func convert_audio_value(value: float):
	# Use a logarithmic equation to make volume slider stable
	value = log(value) * 17.3123
	return value
