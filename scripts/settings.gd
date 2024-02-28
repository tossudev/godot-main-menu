extends Control

const KEYBINDS_FILEPATH: String = "user://keybinds.ini"
const DEFAULT_VOLUME: float = 0.5

@onready var volume_node_master = $VolumeMaster
@onready var volume_node_music = $VolumeMusic
@onready var volume_node_sfx = $VolumeSfx
@onready var keybind_settings_node: Control = %KeybindSettings

var fullscreen: bool = false
var keybinds_open: bool = false

var keybinds: Dictionary = {
	"move_up" : ["Move up", 4194320],
}


func _ready():
	volume_node_master.get_node("Master").set_value(DEFAULT_VOLUME)
	volume_node_master.get_node("SliderBackground").set_value(DEFAULT_VOLUME)
	volume_node_music.get_node("Music").set_value(DEFAULT_VOLUME)
	volume_node_music.get_node("SliderBackground").set_value(DEFAULT_VOLUME)
	volume_node_sfx.get_node("Sfx").set_value(DEFAULT_VOLUME)
	volume_node_sfx.get_node("SliderBackground").set_value(DEFAULT_VOLUME)
	
	AudioServer.set_bus_volume_db(0, convert_audio_value(DEFAULT_VOLUME))
	AudioServer.set_bus_volume_db(1, convert_audio_value(DEFAULT_VOLUME))
	AudioServer.set_bus_volume_db(2, convert_audio_value(DEFAULT_VOLUME))
	
	var keybinds_file = ConfigFile.new()
	if keybinds_file.load(KEYBINDS_FILEPATH) == OK:
		for key in keybinds_file.get_section_keys("keybinds"):
			var key_value = keybinds_file.get_value("keybinds", key)
			
			if str(key_value) != "":
				keybinds[key] = key_value
			else:
				keybinds[key] = null
	
	set_keybinds()


func set_keybinds() -> void:
	var key_node: Control = keybind_settings_node.get_node("Keys/DummyKey")
	
	for key in keybinds.keys():
		var display_text: String = keybinds[key][0]
		var keycode: int = keybinds[key][1]
		var keycode_as_string: String = OS.get_keycode_string(keycode)
		
		var actionlist: Array[InputEvent] = InputMap.action_get_events(key)
		if not actionlist.is_empty():
			InputMap.action_erase_event(key, actionlist[0])
		
		if keycode != null:
			var new_key = InputEventKey.new()
			new_key.set_keycode(keycode)
			InputMap.action_add_event(key, new_key)
		
			var new_key_node = key_node.duplicate()
			
			keybind_settings_node.get_node("Keys").add_child(new_key_node)
			new_key_node.get_node("KeyNameText").set_text(display_text)
			new_key_node.get_node("ButtonChangeKey/Contents/Text").set_text(keycode_as_string)
			new_key_node.show()


func update_ui() -> void:
	for toggle_button_node in get_tree().get_nodes_in_group("togglebuttons"):
		var checkbox: TextureRect = toggle_button_node.get_node(
			"Contents/CheckBox/Checked")
		
		checkbox.set_visible(toggle_button_node.is_pressed())


func convert_audio_value(value: float):
	# Use a logarithmic equation to make volume slider stable
	value = log(value) * 17.3123
	return value


func _on_button_fullscreen_pressed():
	fullscreen = !fullscreen
	
	if fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	
	update_ui()


func _on_button_keybinds_pressed():
	keybinds_open = !keybinds_open
	
	if keybinds_open:
		hide()
		keybind_settings_node.show()
	
	else:
		show()
		keybind_settings_node.hide()


func _on_master_value_changed(value):
	volume_node_master.get_node("SliderBackground").set_value(value)
	AudioServer.set_bus_volume_db(0, convert_audio_value(value))


func _on_music_value_changed(value):
	volume_node_music.get_node("SliderBackground").set_value(value)
	AudioServer.set_bus_volume_db(1, convert_audio_value(value))


func _on_sfx_value_changed(value):
	volume_node_sfx.get_node("SliderBackground").set_value(value)
	AudioServer.set_bus_volume_db(2, convert_audio_value(value))
