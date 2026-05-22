extends CanvasLayer

signal continuar_pressed
signal sair_pressed

@onready var button_continuar: Button = $BotaoContinuar
@onready var button_sair: Button = $BotaoSair
@onready var hover_continuar: ColorRect = $HoverContinuar
@onready var hover_sair: ColorRect = $HoverSair

var tween_continuar: Tween
var tween_sair: Tween


func _ready() -> void:
	hover_continuar.visible = false
	hover_sair.visible = false

	hover_continuar.modulate.a = 0.0
	hover_sair.modulate.a = 0.0

	hover_continuar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hover_sair.mouse_filter = Control.MOUSE_FILTER_IGNORE

	button_continuar.pressed.connect(_on_continuar_pressed)
	button_sair.pressed.connect(_on_sair_pressed)

	button_continuar.mouse_entered.connect(_on_continuar_mouse_entered)
	button_continuar.mouse_exited.connect(_on_continuar_mouse_exited)

	button_sair.mouse_entered.connect(_on_sair_mouse_entered)
	button_sair.mouse_exited.connect(_on_sair_mouse_exited)


func _on_continuar_pressed() -> void:
	continuar_pressed.emit()


func _on_sair_pressed() -> void:
	sair_pressed.emit()


func _mostrar_hover(hover: ColorRect, tween_atual: Tween) -> Tween:
	if tween_atual != null:
		tween_atual.kill()

	hover.visible = true

	var novo_tween := create_tween()
	novo_tween.tween_property(hover, "modulate:a", 1.0, 0.10)

	return novo_tween


func _esconder_hover(hover: ColorRect, tween_atual: Tween) -> Tween:
	if tween_atual != null:
		tween_atual.kill()

	var novo_tween := create_tween()
	novo_tween.tween_property(hover, "modulate:a", 0.0, 0.10)
	novo_tween.finished.connect(func(): hover.visible = false)

	return novo_tween


func _on_continuar_mouse_entered() -> void:
	tween_continuar = _mostrar_hover(hover_continuar, tween_continuar)


func _on_continuar_mouse_exited() -> void:
	tween_continuar = _esconder_hover(hover_continuar, tween_continuar)


func _on_sair_mouse_entered() -> void:
	tween_sair = _mostrar_hover(hover_sair, tween_sair)


func _on_sair_mouse_exited() -> void:
	tween_sair = _esconder_hover(hover_sair, tween_sair)
