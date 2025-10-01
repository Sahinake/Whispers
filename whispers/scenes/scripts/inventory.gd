extends Control

@onready var save_tab = $VBoxContainer/SaveTab
@onready var settings_tab = $VBoxContainer/SettingsTab

func _ready():
	var save_pos = save_tab.position
	save_pos.x = -save_tab.get_size().x - 20
	save_tab.position = save_pos
	
	var settings_pos = settings_tab.position
	settings_pos.x = -settings_tab.get_size().x - 20
	settings_tab.position = settings_pos
