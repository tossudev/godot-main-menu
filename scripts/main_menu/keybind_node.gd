extends Control

@export var texture_normal: Texture2D
@export var texture_locked: Texture2D

var action_name: String = "undefined"
var action_text: String = "undefined"
var key_text: String = "undefined"
var key_index: int = -1

@onready var button_add_input: Button = $ButtonChangeKey
@onready var button_remove_all: Button = $ButtonRemoveKey
var settings_node: Control


func _ready() -> void:
	set_process_input(false)
	button_add_input.connect("toggled", _on_change_key_activated)
	button_remove_all.connect("pressed", _on_remove_all_pressed)
	
	update_key_ui()


func _input(event: InputEvent):
	if button_add_input.is_pressed() and event is InputEventKey:
		_add_new_input(event)


func update_key_ui() -> void:
	var binds_amount: int = InputMap.action_get_events(action_name).size()
	var button_sprite: NinePatchRect = button_add_input.get_node("Contents/SpriteBackground")
	
	if binds_amount == 0:
		set_modulate(Color.RED)
		return
	
	set_modulate(Color.WHITE)
	
	if binds_amount >= 3:
		button_add_input.set_disabled(true)
		button_sprite.set_texture(texture_locked)
	
	else:
		button_add_input.set_disabled(false)
		button_sprite.set_texture(texture_normal)


func _add_new_input(event: InputEvent) -> void:
	var keycode: int = event.get_physical_keycode()
	if settings_node.keybinds[action_name].has(keycode):
		return
	
	InputMap.action_add_event(action_name, event)
	settings_node.keybinds[action_name].append(keycode)
	
	settings_node._update_key(action_name, key_index)
	
	set_process_input(false)
	button_add_input.set_pressed(false)
	
	update_key_ui()


func _on_change_key_activated(toggled: bool):
	set_process_input(toggled)


func _on_remove_all_pressed() -> void:
	InputMap.action_erase_events(action_name)
	settings_node.keybinds[action_name] = []
	settings_node._update_key(action_name, key_index)
	update_key_ui()
