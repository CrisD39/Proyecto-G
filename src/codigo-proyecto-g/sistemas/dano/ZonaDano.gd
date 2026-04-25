extends Area2D
class_name ZonaDano

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body is Protagonista:
		body.recibir_daño()
