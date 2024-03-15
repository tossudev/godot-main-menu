extends Control

@export var save_settings: bool = true

const SETTINGS_FILEPATH: String = "user://settings.cfg"
const DEFAULT_VOLUME: float = 0.8

@onready var volume_node_master = $VolumeMaster
@onready var volume_node_music = $VolumeMusic
@onready var volume_node_sfx = $VolumeSfx
@onready var keybind_settings_node: Control = %KeybindSettings
@onready var button_close: Control = $"../KeybindSettings/ButtonCloseKeybinds"
@onready var button_back: Control = $"../ButtonBack"

var is_keybinds_open: bool = false

#region Saved variables
var is_fullscreen: bool = false
var audio_master: float = 0.0
var audio_music: float = 0.0
var audio_sfx: float = 0.0

var keybinds: Dictionary = {
	"move_up" : [],
	"move_down" : [],
	"move_left" : [],
	"move_right" : [],
	"action" : [],
}
#endregion

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
	# Set UI audio values correctly.
	volume_node_master.get_node("Master").set_value(audio_master)
	volume_node_master.get_node("SliderBackground").set_value(audio_master)
	volume_node_music.get_node("Music").set_value(audio_music)
	volume_node_music.get_node("SliderBackground").set_value(audio_music)
	volume_node_sfx.get_node("Sfx").set_value(audio_sfx)
	volume_node_sfx.get_node("SliderBackground").set_value(audio_sfx)
	
	# Update window mode
	if is_fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	$ButtonFullscreen.set_pressed(is_fullscreen)
	
	# Toggle visibility on checkboxes that are checked.
	for toggle_button_node in get_tree().get_nodes_in_group("togglebuttons"):
		var checkbox: TextureRect = toggle_button_node.get_node(
			"Contents/CheckBox/Checked")
		
		checkbox.set_visible(toggle_button_node.is_pressed())


func convert_audio_value(value: float):
	# Use a logarithmic equation to make volume slider stable.
	value = log(value) * 17.3123
	return value


func _init_settings() -> void:
	var settings_file: ConfigFile = ConfigFile.new()
	var can_load_settings = settings_file.load(SETTINGS_FILEPATH)
	
	# If there is no settings file or saving is disabled, use default settings.
	if can_load_settings != OK || !save_settings:
		_use_default_settings()
		return
	
	# Load settings from disk.
	_load_settings(settings_file)
	_set_keybinds_ui()


func _use_default_settings() -> void:
	# Set default volume displays
	audio_master = DEFAULT_VOLUME
	audio_music = DEFAULT_VOLUME
	audio_sfx = DEFAULT_VOLUME
	
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
	update_ui()


func _save_settings() -> void:
	if !save_settings:
		return
	
	var settings_file = ConfigFile.new()
	
	# Save audio values
	audio_master = volume_node_master.get_node("Master").get_value()
	audio_music = volume_node_music.get_node("Music").get_value()
	audio_sfx = volume_node_sfx.get_node("Sfx").get_value()
	
	settings_file.set_value("audio", "master", audio_master)
	settings_file.set_value("audio", "music", audio_music)
	settings_file.set_value("audio", "sfx", audio_sfx)
	
	settings_file.set_value("screen", "is_fullscreen", is_fullscreen)
	
	# Save keybinds
	for keybind in keybinds:
		settings_file.set_value("keybinds", keybind, keybinds[keybind])
	
	settings_file.save(SETTINGS_FILEPATH)


func _load_settings(settings_file: ConfigFile) -> void:
	if !save_settings:
		return
	
	# Load audio values
	audio_master = settings_file.get_value("audio", "master")
	audio_music = settings_file.get_value("audio", "music")
	audio_sfx = settings_file.get_value("audio", "sfx")
	
	volume_node_master.get_node("Master").set_value(audio_master)
	volume_node_music.get_node("Music").set_value(audio_music)
	volume_node_sfx.get_node("Sfx").set_value(audio_sfx)
	
	is_fullscreen = settings_file.get_value("screen", "is_fullscreen")
	
	# Load keybinds
	for key in settings_file.get_section_keys("keybinds"):
		InputMap.action_erase_events(key)
		var key_value = settings_file.get_value("keybinds", key)
		
		if key_value != null:
			keybinds[key] = key_value
			
			for keycode: int in key_value:
				var new_event := InputEventKey.new()
				new_event.set_keycode(keycode)
				InputMap.action_add_event(key, new_event)
	
	update_ui()


func _set_keybinds_ui() -> void:
	var key_node: Control = keybind_settings_node.get_node("Keys/DummyKey")
	
	var key_index: int = 0
	for keybind in keybinds:
		
		# Create a duplicate of the UI key element for each action in memory.
		var new_key_node = key_node.duplicate()
		keybind_settings_node.get_node("Keys").add_child(new_key_node)
		
		new_key_node.settings_node = self
		new_key_node.action_name = keybind
		new_key_node.key_index = key_index
		
		_update_key(keybind, key_index)
		key_index += 1


func _update_key(keybind: String, key_index: int) -> void:
	var key_node: Control = $"../KeybindSettings/Keys".get_child(key_index + 1)
	
	var keycode_texts_list: Array = []
	var action_text: String = keybind_names[key_index]
	
	# If no keybinds are set for an action, prevent user from exiting selection.
	if keybinds[keybind] == []:
		button_back.hide()
		button_close.hide()
	
	else:
		button_back.show()
		button_close.show()
	
	for keycode: int in keybinds[keybind]:
		# Get keycodes for each action in readable formats.
		keycode_texts_list.append(OS.get_keycode_string(keycode))
	
	# Get all keycode names in a nice list separated by slashes.
	var keycode_text_to_display: String = ""
	
	var keycode_index: int = 0
	for keycode_text: String in keycode_texts_list:
		if keycode_index == keycode_texts_list.size() - 1:
			keycode_text_to_display += keycode_text
		
		else:
			keycode_text_to_display += (keycode_text + " / ")
		
		keycode_index += 1
	
	key_node.action_text = action_text
	key_node.key_text = keycode_text_to_display
	
	# Apply values to UI elements
	key_node.get_node(
		"KeyNameText").set_text(action_text)
	key_node.get_node(
		"ButtonChangeKey/Contents/Text").set_text(keycode_text_to_display)
	key_node.show()


func _on_button_fullscreen_pressed():
	is_fullscreen = !is_fullscreen
	
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


func _on_button_back_pressed():
	_save_settings()
