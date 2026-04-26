extends Node
class_name SistemaCombate

# ── Señales ──────────────────────────────────────────
signal pogo_rebotado

# ── Variables exportadas ─────────────────────────────
@export_group("Tiempos de ataque")
@export var duracion_active_frames: float = 0.15   # [REVISAR]
@export var duracion_recovery: float = 0.20         # [REVISAR]
@export var ventana_buffer: float = 0.10            # [REVISAR]

@export_group("Hitstop")
@export var duracion_hitstop_normal: float = 0.05  # [REVISAR]
@export var duracion_hitstop_pogo: float = 0.08    # [REVISAR]

@export_group("Pogo")
@export var impulso_pogo: float = 480.0            # [REVISAR] — aprox 2.5 tiles con gravedad 1600

@export_group("Hitbox — Lateral")
@export var lateral_offset_x: float = 56.0         # [REVISAR]
@export var lateral_ancho: float = 48.0            # [REVISAR]
@export var lateral_alto: float = 20.0             # [REVISAR]

@export_group("Hitbox — Vertical")
@export var vertical_offset_y: float = 52.0        # [REVISAR]
@export var vertical_ancho: float = 28.0           # [REVISAR]
@export var vertical_alto: float = 48.0            # [REVISAR]

# ── Variables privadas ───────────────────────────────
enum EstadoAtaque { IDLE, ACTIVE, RECOVERY, HITSTOP }
enum DireccionAtaque { LATERAL, ARRIBA, ABAJO }

var _estado: EstadoAtaque = EstadoAtaque.IDLE
var _direccion_ataque: DireccionAtaque = DireccionAtaque.LATERAL
var _timer: float = 0.0
var _buffer_activo: bool = false
var _es_pogo_con_rebote: bool = false
var _objetivo_golpeado: Node2D = null

var en_hitstop: bool = false

# ── Nodos referenciados ──────────────────────────────
@onready var _hitbox: HitboxAtaque = $"../HitboxAtaque"
@onready var _protagonista: CharacterBody2D = get_parent() as CharacterBody2D

# ── Ciclo de vida ────────────────────────────────────
func _ready() -> void:
	_hitbox.propietario = _protagonista
	_hitbox.golpe_conectado.connect(_on_golpe_conectado)

func _physics_process(delta: float) -> void:
	match _estado:
		EstadoAtaque.ACTIVE:
			_timer -= delta
			if _timer <= 0.0:
				_hitbox.desactivar()
				_cambiar_a_recovery()

		EstadoAtaque.RECOVERY:
			_timer -= delta
			if _timer <= 0.0:
				_estado = EstadoAtaque.IDLE
				if _buffer_activo:
					_buffer_activo = false
					_ejecutar_ataque()

		EstadoAtaque.HITSTOP:
			_timer -= delta
			if _timer <= 0.0:
				en_hitstop = false
				if is_instance_valid(_objetivo_golpeado):
					_objetivo_golpeado.set_physics_process(true)
				if _es_pogo_con_rebote:
					pogo_rebotado.emit()
					_protagonista.velocity.y = -impulso_pogo
				_objetivo_golpeado = null
				_es_pogo_con_rebote = false
				_cambiar_a_recovery()

# ── Métodos públicos ─────────────────────────────────
func intentar_atacar() -> void:
	if _estado == EstadoAtaque.IDLE:
		_ejecutar_ataque()
	elif _estado == EstadoAtaque.RECOVERY and _timer <= ventana_buffer:
		_buffer_activo = true

# ── Métodos privados ─────────────────────────────────
func _ejecutar_ataque() -> void:
	var dir_vertical: float = Input.get_axis("moverse_arriba", "moverse_abajo")
	var en_suelo: bool = _protagonista.is_on_floor()

	var es_arriba: bool = dir_vertical < -0.5
	var es_pogo: bool = dir_vertical > 0.5 and not en_suelo

	if es_arriba:
		_direccion_ataque = DireccionAtaque.ARRIBA
		_configurar_hitbox_arriba()
	elif es_pogo:
		_direccion_ataque = DireccionAtaque.ABAJO
		_configurar_hitbox_abajo()
	else:
		_direccion_ataque = DireccionAtaque.LATERAL
		_configurar_hitbox_lateral()

	_hitbox.activar()
	_estado = EstadoAtaque.ACTIVE
	_timer = duracion_active_frames
	_objetivo_golpeado = null

func _cambiar_a_recovery() -> void:
	_estado = EstadoAtaque.RECOVERY
	_timer = duracion_recovery

func _configurar_hitbox_lateral() -> void:
	var facing: float = _protagonista.get_facing()
	_hitbox.position = Vector2(lateral_offset_x * facing, 0.0)
	_hitbox.configurar_forma(Vector2(lateral_ancho, lateral_alto))

func _configurar_hitbox_arriba() -> void:
	_hitbox.position = Vector2(0.0, -vertical_offset_y)
	_hitbox.configurar_forma(Vector2(vertical_ancho, vertical_alto))

func _configurar_hitbox_abajo() -> void:
	_hitbox.position = Vector2(0.0, vertical_offset_y)
	_hitbox.configurar_forma(Vector2(vertical_ancho, vertical_alto))

func _on_golpe_conectado(objetivo: Node2D) -> void:
	if _objetivo_golpeado == objetivo:
		return
	if not objetivo.has_method("recibir_daño"):
		return

	_objetivo_golpeado = objetivo
	_hitbox.desactivar()

	objetivo.recibir_daño()

	# Determinar si el pogo produce rebote (RF-CMB-005): rebotable por default salvo excepción
	var hacer_rebote: bool = false
	if _direccion_ataque == DireccionAtaque.ABAJO:
		if "rebotable" in objetivo:
			hacer_rebote = objetivo.rebotable
		else:
			hacer_rebote = true

	_es_pogo_con_rebote = hacer_rebote

	var duracion_hitstop: float = duracion_hitstop_pogo if _es_pogo_con_rebote else duracion_hitstop_normal
	en_hitstop = true
	objetivo.set_physics_process(false)

	_estado = EstadoAtaque.HITSTOP
	_timer = duracion_hitstop
