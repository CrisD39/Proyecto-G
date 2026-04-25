extends CharacterBody2D
class_name Protagonista

# ── Señales ──────────────────────────────────────────
signal vida_perdida(vidas_restantes: int)
signal jugador_murio

# ── Constantes ───────────────────────────────────────

# ── Variables exportadas (ajustables en inspector) ───
@export_group("Movimiento Horizontal")
@export var velocidad_max: float = 180.0
@export var velocidad_corrida: float = 320.0           # [REVISAR]
@export var aceleracion: float = 1800.0
@export var desaceleracion: float = 2250.0

@export_group("Salto")
@export var velocidad_salto: float = 640.0
@export var velocidad_doble_salto: float = 540.0       # [REVISAR] — ligeramente menor que el primero
@export var gravedad: float = 1600.0
@export var mult_gravedad_hold: float = 0.3            # [REVISAR] — gravedad reducida durante hold en ascenso
@export var mult_gravedad_caida: float = 1.4           # [REVISAR]
@export var mult_gravedad_corte_salto: float = 2.0     # [REVISAR]
@export var duracion_hold_max: float = 0.25            # [REVISAR] — techo duro del hold efectivo en segundos
@export var ventana_minima_salto: float = 0.05         # [REVISAR] — protección anti-cut accidental post-despegue
@export var velocidad_caida_max: float = 600.0         # [REVISAR] — terminal velocity en px/s
@export var saltos_aereos_max: int = 1

@export_group("Dash")
@export var dash_velocidad: float = 533.0
@export var dash_duracion: float = 0.18
@export var dash_cooldown: float = 0.6

@export_group("Salud")
@export var vidas_maximas: int = 3
@export var duracion_invencibilidad: float = 1.5       # [REVISAR]
@export var frecuencia_parpadeo: float = 0.08          # [REVISAR]

# ── Variables privadas ───────────────────────────────
var _direccion_mirando: float = 1.0
var _saltos_aereos_restantes: int = 0

# Salto — control por hold (RF-MOV-005 / 007 / 008)
var _en_ascenso_por_salto: bool = false            # true durante el ascenso de un salto activo
var _hold_efectivo_activo: bool = false            # false al agotar duracion_hold_max o soltar el botón
var _timer_hold_salto: float = 0.0                # acumula el tiempo de hold desde el despegue
var _timer_ventana_minima: float = 0.0            # mientras > 0, el jump cut no aplica
var _boton_salto_soltado_en_aire: bool = false    # detecta release+press para el doble salto (RF-MOV-014)

# Dash
var _en_dash: bool = false
var _timer_dash: float = 0.0
var _cooldown_restante: float = 0.0
var _dash_aereo_disponible: bool = true

# Salud
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
		_procesar_salto(delta)
		_aplicar_gravedad(delta)
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

func _procesar_salto(delta: float) -> void:
	if is_on_floor():
		_en_ascenso_por_salto = false
		_hold_efectivo_activo = false
		_timer_hold_salto = 0.0
		_timer_ventana_minima = 0.0
		_saltos_aereos_restantes = saltos_aereos_max
		_boton_salto_soltado_en_aire = false
	else:
		# Rastrear liberación del botón en el aire para habilitar el doble salto (RF-MOV-014)
		if not Input.is_action_pressed("saltar"):
			_boton_salto_soltado_en_aire = true

		# Actualizar timers del hold mientras estamos en ascenso activo
		if _en_ascenso_por_salto:
			if _timer_ventana_minima > 0.0:
				_timer_ventana_minima -= delta

			if _hold_efectivo_activo:
				if Input.is_action_pressed("saltar"):
					_timer_hold_salto += delta
					if _timer_hold_salto >= duracion_hold_max:
						# Techo duro alcanzado: el hold ya no extiende la altura (RF-MOV-008)
						_hold_efectivo_activo = false
				else:
					# Botón soltado: el hold pierde efecto
					_hold_efectivo_activo = false

	if Input.is_action_just_pressed("saltar"):
		if is_on_floor():
			_ejecutar_salto(velocidad_salto)
		elif _saltos_aereos_restantes > 0 and _boton_salto_soltado_en_aire:
			# Doble salto: requiere release + press explícito (RF-MOV-014)
			_ejecutar_salto(velocidad_doble_salto)
			_saltos_aereos_restantes -= 1

func _ejecutar_salto(velocidad: float) -> void:
	velocity.y = -velocidad
	_en_ascenso_por_salto = true
	_hold_efectivo_activo = true
	_timer_hold_salto = 0.0
	_timer_ventana_minima = ventana_minima_salto
	_boton_salto_soltado_en_aire = false

func _aplicar_gravedad(delta: float) -> void:
	if is_on_floor():
		return

	var mult: float = 1.0

	if velocity.y > 0.0:
		# Fase de caída: gravedad aumentada para dar peso al descenso (RF-MOV-009)
		mult = mult_gravedad_caida
	elif velocity.y < 0.0 and _en_ascenso_por_salto:
		# Fase de ascenso con salto activo
		if _hold_efectivo_activo and Input.is_action_pressed("saltar"):
			# Hold válido: gravedad reducida para extender la altura de forma continua (RF-MOV-005)
			mult = mult_gravedad_hold
		elif _timer_ventana_minima <= 0.0 and not Input.is_action_pressed("saltar"):
			# Botón soltado fuera de la ventana mínima: jump cut (RF-MOV-006)
			mult = mult_gravedad_corte_salto
		# Dentro de ventana mínima o hold agotado → mult = 1.0 (gravedad normal)

	velocity.y += gravedad * mult * delta

	# Terminal velocity: limita la velocidad máxima de caída (RF-MOV-009)
	if velocity.y > velocidad_caida_max:
		velocity.y = velocidad_caida_max

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
