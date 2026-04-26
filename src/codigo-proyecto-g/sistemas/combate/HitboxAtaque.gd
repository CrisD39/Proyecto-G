extends Area2D
class_name HitboxAtaque

# ── Señales ──────────────────────────────────────────
signal golpe_conectado(objetivo: Node2D)

# ── Variables exportadas ─────────────────────────────
@export var propietario: Node2D  # excluido de la detección; asignado por SistemaCombate en _ready

# ── Nodos referenciados ──────────────────────────────
@onready var _forma: CollisionShape2D = $CollisionShape2D

# ── Ciclo de vida ────────────────────────────────────
func _ready() -> void:
	monitoring = false
	_forma.disabled = true
	body_entered.connect(_on_body_entered)

# ── Métodos públicos ─────────────────────────────────
func activar() -> void:
	monitoring = true
	_forma.disabled = false

func desactivar() -> void:
	monitoring = false
	_forma.disabled = true

func configurar_forma(tamanio: Vector2) -> void:
	var rect := RectangleShape2D.new()
	rect.size = tamanio
	_forma.shape = rect

# ── Métodos privados ─────────────────────────────────
func _on_body_entered(body: Node2D) -> void:
	if body == propietario:
		return
	golpe_conectado.emit(body)
