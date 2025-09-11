extends Control

func _ready():
	var newGameBtn = $VBoxContainer/NewGameButton
	if newGameBtn:
		newGameBtn.pressed.connect(_on_novo_jogo_pressed)
		print("Conectado com sucesso!")
	else:
		print("Botão não encontrado!")
	
	var loadGameButton = $VBoxContainer/LoadGameButton
	if loadGameButton:
		loadGameButton.pressed.connect(_on_carregar_jogo_pressed)
		print("Conectado com sucesso!")
	else:
		print("Botão não encontrado!")
		
	var settingsButton = $VBoxContainer/Settings
	if settingsButton:
		settingsButton.pressed.connect(_on_configuracoes_pressed)
		print("Conectado com sucesso!")
	else:
		print("Botão não encontrado!")
		
	var exitButton = $VBoxContainer/Exit
	if exitButton:
		exitButton.pressed.connect(_on_sair_pressed)
		print("Conectado com sucesso!")
	else:
		print("Botão não encontrado!")
		
func _on_novo_jogo_pressed():
	get_tree().change_scene_to_file("res://Scenes/Game.tscn")

func _on_carregar_jogo_pressed():
	print("Carregar jogo ainda não implementado")

func _on_configuracoes_pressed():
	print("Abrir menu de configurações")

func _on_sair_pressed():
	get_tree().quit()
