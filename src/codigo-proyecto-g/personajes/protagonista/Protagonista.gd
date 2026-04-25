extends CharacterBody2D
class_name Protagonista

# ── Señales ──────────────────────────────────────────
signal vida_perdida(vidas_restantes: int)
signal jugador_murio

# ── Constantes ───────────────────────────────────────

# ── Variables exportadas (ajustables en inspector) ───
@export_group("Movimiento Horizontal")
@export var velocidad_max: float = 180.0
@export var velocidad_corrida: float = 320.0  # [REVISAR]
@export var aceleracion: float = 1800.0
@export var desaceleracion: float = 2250.0

@export_group("Salto")
@export var velocidad_salto: float = 640.0
@export var gravedad: float = 1600.0
@export var mult_gravedad_caida: float = 1.4
@export var mult_gravedad_corte_salto: float = 2.0
@export var saltos_aereos_max: int = 1

@export_group("Dash")
@export var dash_velocidad: float = 533.0
@export var dash_duracion: float = 0.18
@export var dash_cooldown: float = 0.6

@export_group("Salud")
@export var vidas_maximas: int = 3
@export var duracion_invencibilidad: float = 1.5  # [REVISAR]
@export var frecuencia_parpadeo: float = 0.08     # [REVISAR]

# ── Variables privadas ───────────────────────────────
var _presionando_salto: bool = false
var _direccion_mirando: float = 1.0
var _saltos_aereos_restantes: int = 0

var _en_dash: bool = false
var _timer_dash: float = 0.0
var _cooldown_restante: float = 0.0
var _dash_aereo_disponible: bool = true

var _vidas: int = 0
var _invencible: bool = false
var _timer_invencibilidad: float = 0.0
var _timer_parpadeo: float = 0.0

# ── Nodos referenciados ──────────────────────────────

# ── Ciclo de vida ────────────────────────────────────
func _ready() -> void:
	_vidas = vidas_maximas

func _physics_process(delta: float) -> void:
	_actualizar_invencibilidad(delta)

	if _cooldown_restante > 0.0:
		_cooldown_restante -= delta

	if _en_dash:
		_timer_dash -= delta
		if _timer_dash <= 0.0:
			_en_dash = false
			_cooldown_restante = dash_cooldown
	else:
		_aplicar_gravedad(delta)
		_procesar_salto()
		_procesar_movimiento_horizontal(delta)
		_intentar_dash()

	if is_on_floor():
		_dash_aereo_disponible = true

	move_and_slide()

# ── Métodos públicos ─────────────────────────────────
func recibir_daño() -> void:
	if _invencible:
		return

	_vidas -= 1
	vida_perdida.emit(_vidas)

	if _vidas <= 0:
		jugador_murio.emit()
		return

	_invencible = true
	_timer_invencibilidad = duracion_invencibilidad
	_timer_parpadeo = 0.0

func get_vidas() -> int:
	return _vidas

# ── Métodos privados ─────────────────────────────────
func _actualizar_invencibilidad(delta: float) -> void:
	if not _invencible:
		return

	_timer_invencibilidad -= delta
	_timer_parpadeo -= delta

	if _timer_parpadeo <= 0.0:
		modulate.a = 0.0 if modulate.a > 0.5 else 1.0
		_timer_parpadeo = frecuencia_parpadeo

	if _timer_invencibilidad <= 0.0:
		_invencible = false
		modulate.a = 1.0

func _aplicar_gravedad(delta: float) -> void:
	if is_on_floor():
		return

	var mult: float = 1.0
	if velocity.y > 0.0:
		mult = mult_gravedad_caida
	elif _presionando_salto and not Input.is_action_pressed("saltar"):
		# jugador soltó antes del apex: recorte de salto
		mult = mult_gravedad_corte_salto

	velocity.y += gravedad * mult * delta

func _procesar_salto() -> void:
	if is_on_floor():
		_presionando_salto = false
		_saltos_aereos_restantes = saltos_aereos_max

	if Input.is_action_just_pressed("saltar"):
		if is_on_floor():
			velocity.y = -velocidad_salto
			_presionando_salto = true
		elif _saltos_aereos_restantes > 0:
			velocity.y = -velocidad_salto
			_presionando_salto = true
			_saltos_aereos_restantes -= 1

func _procesar_movimiento_horizontal(delta: float) -> void:
	var dir: float = Input.get_axis("moverse_izquierda", "moverse_derecha")
	var vel_objetivo: float = velocidad_corrida if Input.is_action_pressed("correr") else velocidad_max

	if dir != 0.0:
		_direccion_mirando = sign(dir)
		velocity.x = move_toward(velocity.x, vel_objetivo * dir, aceleracion * delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, desaceleracion * delta)

func _intentar_dash() -> void:
	if not Input.is_action_just_pressed("dash"):
		return
	if _cooldown_restante > 0.0:
		return
	if not is_on_floor() and not _dash_aereo_disponible:
		return

	var dir: float = Input.get_axis("moverse_izquierda", "moverse_derecha")
	var dir_dash: float = dir if dir != 0.0 else _direccion_mirando

	velocity.x = dash_velocidad * dir_dash
	velocity.y = 0.0
	_en_dash = true
	_timer_dash = dash_duracion

	if not is_on_floor():
		_dash_aereo_disponible = false
