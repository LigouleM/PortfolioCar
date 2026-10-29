extends CanvasLayer

var js_resume_cb
@onready var sound: Button = $Sound
@export var texAudioOn: Texture2D
@export var texAudioOff: Texture2D

func _ready() -> void:
	# Preparamos una función para que React pueda "llamar" a Godot
	if OS.has_feature("web"):
		js_resume_cb = JavaScriptBridge.create_callback(_unpause_from_react)
		JavaScriptBridge.get_interface("window").unpauseGodot = js_resume_cb

func _unpause_from_react(args) -> void:
	get_tree().paused = false
	
func _on_pause_pressed() -> void:
	get_tree().paused = not get_tree().paused

func _on_sound_pressed() -> void:
	var bus_idx = AudioServer.get_bus_index("Master")
	var is_muted = AudioServer.is_bus_mute(bus_idx)
	AudioServer.set_bus_mute(bus_idx, not is_muted)
	if(is_muted):
		sound.icon = texAudioOn
	else:
		sound.icon = texAudioOff
