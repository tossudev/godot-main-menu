extends Control

const SETTINGS_FILEPATH: String = "user://settings.cfg"
const DEFAULT_VOLUME: float = 0.8

@onready var volume_node_master = $VolumeMaster
@onready var volume_node_music = $VolumeMusic
@onready var volume_node_sfx = $VolumeSfx
@onready var keybind_settings_node: Control = %KeybindSettings

var is_fullscreen: bool = false
var is_keybinds_open: bool = false

var keybinds: Dictionary = {
	"move_up" : [],
	"move_down" : [],
	"move_left" : [],
	"move_right" : [],
	"action" : [],
}

var keybind_names: Array = [
	"Move up",
	"Move down",
	"Move left",
	"Move right",
	"Action",
]


func _ready():
	_init_settings()


func update_ui() -> void:
	for toggle_button_node in get_tree().get_nodes_in_group("togglebuttons"):
		var checkbox: TextureRect = toggle_button_node.get_node(
			"Contents/CheckBox/Checked")
		
		checkbox.set_visible(toggle_button_node.is_pressed())


func convert_audio_value(value: float):
	# Use a logarithmic equation to make volume slider stable
	value = log(value) * 17.3123
	return value


func _init_settings() -> void:
	var settings_file = ConfigFile.new()
	var can_load_settings = settings_file.load(SETTINGS_FILEPATH)
	
	if can_load_settings != OK:
		_use_default_settings()
		return
	
	for key in settings_file.get_section_keys("keybinds"):
		var key_value = settings_file.get_value("keybinds", key)
		
		if key_value[1] != null:
			keybinds[key] = key_value
	
	_set_keybinds_ui()


func _use_default_settings() -> void:
	# Set default volume displays
	volume_node_master.get_node("Master").set_value(DEFAULT_VOLUME)
	volume_node_master.get_node("SliderBackground").set_value(DEFAULT_VOLUME)
	volume_node_music.get_node("Music").set_value(DEFAULT_VOLUME)
	volume_node_music.get_node("SliderBackground").set_value(DEFAULT_VOLUME)
	volume_node_sfx.get_node("Sfx").set_value(DEFAULT_VOLUME)
	volume_node_sfx.get_node("SliderBackground").set_value(DEFAULT_VOLUME)
	
	# Set default volumes
	AudioServer.set_bus_volume_db(0, convert_audio_value(DEFAULT_VOLUME))
	AudioServer.set_bus_volume_db(1, convert_audio_value(DEFAULT_VOLUME))
	AudioServer.set_bus_volume_db(2, convert_audio_value(DEFAULT_VOLUME))
	
	# Set default keybinds
	for keybind in keybinds.keys():
		var actions_list: Array[InputEvent] = InputMap.action_get_events(keybind)
		
		for action: InputEvent in actions_list:
			if action is InputEventKey:
				var keycode: Key = action.get_physical_keycode()
				keybinds[keybind].append(keycode)
	
	_save_settings()
	_set_keybinds_ui()


func _save_settings() -> void:
	var settings_file = ConfigFile.new()
	
	var audio_master: float = volume_node_master.get_node("Master").get_value()
	var audio_music: float = volume_node_music.get_node("Music").get_value()
	var audio_sfx: float = volume_node_sfx.get_node("Sfx").get_value()
	
	settings_file.set_value("audio", "master", audio_master)
	settings_file.set_value("audio", "music", audio_music)
	settings_file.set_value("audio", "sfx", audio_sfx)
	
	settings_file.set_value("screen", "is_fullscreen", is_fullscreen)
	
	for keybind in keybinds:
		settings_file.set_value("keybinds", keybind, keybinds[keybind])
	
	settings_file.save(SETTINGS_FILEPATH)


func _set_keybinds_ui() -> void:
	var key_node: Control = keybind_settings_node.get_node("Keys/DummyKey")
	
	var key_index: int = 0
	for keybind in keybinds:
		for keycode: int in keybinds[keybind]:
			var display_text: String = keybind_names[key_index]
			var keycode_as_string: String = OS.get_keycode_string(keycode)
			
			if keycode != null:
				var new_key_node = key_node.duplicate()
				
				keybind_settings_node.get_node("Keys").add_child(new_key_node)
				new_key_node.get_node("KeyNameText").set_text(display_text)
				new_key_node.get_node("ButtonChangeKey/Contents/Text").set_text(keycode_as_string)
				new_key_node.show()
			
			key_index += 1


func _on_button_fullscreen_pressed():
	is_fullscreen = !is_fullscreen
	
	if is_fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	
	update_ui()


func _on_button_keybinds_pressed():
	is_keybinds_open = !is_keybinds_open
	
	if is_keybinds_open:
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
