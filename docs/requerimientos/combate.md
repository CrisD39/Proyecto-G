# Requerimientos — Combate

## Metadata
Fecha: 2026-04-25
Fuente: docs/design/mecanicas/combate.md, docs/design/controles.md
Estado: Borrador
Versión: 1.0

---

## Descripción general
Sistema de combate melee con un solo botón de ataque cuya dirección depende del
input vertical. El protagonista ejecuta ataques laterales, hacia arriba o hacia
abajo (pogo) según el estado del stick al momento del input.

---

## Requerimientos funcionales

---

### RF-CMB-001 — Dirección del ataque según input
**Descripción:** Un único botón de ataque produce un golpe cuya dirección se
determina por el input vertical en el momento de presionarlo.
**Disparador:** Tap del botón de ataque (X/Cuadrado / J).
**Resultado esperado:**

| Input vertical al atacar | Ubicación del protagonista | Dirección del golpe |
|---|---|---|
| Sin input vertical (o input horizontal puro) | Tierra o aire | Horizontal según facing |
| ↑ mantenido | Tierra o aire | Hacia arriba |
| ↓ mantenido | En el aire | Hacia abajo (pogo) |
| ↓ mantenido | En tierra | Horizontal (↓ en tierra no tiene efecto en el ataque) |

- La dirección del golpe se calcula en el momento de presionar el botón, no al soltar.
- La dirección lateral usa el **facing** del personaje, no el input horizontal del momento.
  Esto es consistente con el comportamiento del dash.

**Prioridad:** Alta
**Dependencias:** RF-MOV-001 (para facing).

---

### RF-CMB-002 — Ataque lateral (básico)
**Descripción:** Tajo horizontal con el facón en la dirección del facing.
Es el ataque por default y el de mayor uso.
**Disparador:** Tap del botón de ataque sin input vertical activo.
**Resultado esperado:**
- El golpe tiene active frames durante ~0.15s [REVISAR].
- El personaje puede seguir moviéndose durante el ataque, pero a velocidad reducida
  si está en el suelo [REVISAR — valor exacto de reducción pendiente de definición].
- En el aire: conserva momentum horizontal sin penalización.
- Tras los active frames, hay un recovery de ~0.2s [REVISAR] antes de poder
  ejecutar el siguiente input de ataque.
- El alcance del golpe es de ~1.5 tiles [REVISAR].
- Al conectar con un objetivo, se produce un hitstop de ~0.05s [REVISAR].
- Inputs de ataque dentro de la ventana de buffer (~0.1s [REVISAR] al final del
  recovery) se ejecutan automáticamente al salir del recovery.

**Prioridad:** Alta
**Dependencias:** RF-CMB-001.

---

### RF-CMB-003 — Ataque hacia arriba
**Descripción:** Estocada del facón hacia arriba.
**Disparador:** Tap del botón de ataque con ↑ mantenido.
**Resultado esperado:**
- El golpe tiene duración y recovery equivalentes al ataque lateral [REVISAR — puede
  tener recovery ligeramente mayor para reflejar que el personaje deja el flanco descubierto].
- El alcance es de ~1.5 tiles hacia arriba [REVISAR].
- El ángulo de cobertura es ligeramente abierto a los lados superiores (no un rayo
  vertical puro) — permite errar medio tile y que el golpe igualmente impacte a un
  enemigo aéreo cercano. [REVISAR]
- Se puede ejecutar en tierra y en el aire.
- En tierra: el protagonista permanece quieto durante el golpe.
- En el aire: conserva momentum horizontal y vertical.
- Produce hitstop de ~0.05s [REVISAR] al conectar.

**Prioridad:** Alta
**Dependencias:** RF-CMB-001.

---

### RF-CMB-004 — Pogo (ataque hacia abajo con rebote)
**Descripción:** Estocada del facón hacia abajo ejecutada únicamente en el aire.
Al conectar con un objetivo rebotable, el protagonista recibe un impulso hacia arriba
y recupera recursos aéreos consumidos.
**Disparador:** Tap del botón de ataque con ↓ mantenido, mientras el protagonista
está en el aire.
**Resultado esperado:**

**Al conectar con objetivo rebotable:**
1. La velocidad vertical del protagonista se **reemplaza** por un impulso hacia arriba
   de ~2.5 tiles [REVISAR] desde el punto de contacto. No se suma — funciona igual
   cayendo que subiendo.
2. Se recuperan el dash aéreo y el doble salto si están desbloqueados [REVISAR —
   evaluar en playtest si conviene recuperar solo uno de los dos o ninguno].
3. Se produce hitstop de ~0.08s [REVISAR] — levemente mayor que en ataques normales,
   para marcar el impacto con peso audiovisual.

**Al conectar con objetivo no-rebotable:**
- El ataque se ejecuta (hitbox activo, puede causar daño si aplica).
- El protagonista **continúa cayendo** con su velocidad vertical previa.
- No hay impulso hacia arriba.

**Al no conectar (fallo completo del hitbox):**
- El ataque se ejecuta en el vacío.
- Recovery normal, sin rebote.

- El alcance del pogo (hacia abajo) es de ~1.5 tiles [REVISAR].
- En tierra, el input ↓ + ataque produce un ataque lateral (RF-CMB-002); el pogo
  solo es posible en el aire.

**Prioridad:** Alta
**Dependencias:** RF-CMB-001, RF-MOV-014 (doble salto), RF-MOV-016 (dash aéreo).

---

### RF-CMB-005 — Sistema de categoría rebotable / no-rebotable
**Descripción:** Cada entidad con hurtbox (enemigo, proyectil interactuable,
objeto del escenario) tiene una propiedad que determina si el pogo produce rebote
al impactarla.
**Disparador:** El pogo impacta una entidad.
**Resultado esperado:**
- **Categoría rebotable (default):** toda entidad con hurtbox es rebotable salvo
  que esté explícitamente marcada como no-rebotable. Al recibir un pogo, produce
  el rebote descrito en RF-CMB-004.
- **Categoría no-rebotable (excepción explícita):** al recibir un pogo, el ataque
  se registra (puede causar daño), pero no hay rebote ni impulso hacia arriba.
  El protagonista sigue cayendo.
- La propiedad no-rebotable se asigna entidad por entidad. La lista vive en
  `docs/personajes/bestiary/` en la ficha de cada criatura.
- Criterios para marcar no-rebotable: jefes/encuentros únicos, enemigos blindados
  en la parte superior, objetos narrativos que no deben actuar como plataformas.

**Prioridad:** Alta
**Dependencias:** RF-CMB-004.

---

### RF-CMB-006 — Buffer de ataque
**Descripción:** Al presionar el botón de ataque durante el recovery de un ataque
previo, el sistema registra el input y lo ejecuta automáticamente al salir del recovery.
**Disparador:** Input de ataque dentro de la ventana de buffer (~0.1s [REVISAR]
al final del recovery).
**Resultado esperado:** El próximo ataque se ejecuta automáticamente al expirar
el recovery, usando la dirección que el input vertical tenga en ese momento
(no la del momento en que se presionó el botón durante el buffer).

**Prioridad:** Media
**Dependencias:** RF-CMB-001.

---

### RF-CMB-007 — Facing: herencia y cambio durante el combate
**Descripción:** El facing del protagonista define la dirección de los ataques
laterales, igual que define la dirección del dash. Cambiar de facing durante
el recovery de un ataque actualiza la dirección del siguiente ataque.
**Disparador:** El jugador cambia el input horizontal mientras el protagonista
está en recovery de un ataque.
**Resultado esperado:** El siguiente ataque lateral sale hacia la nueva dirección
del facing, no hacia la dirección del ataque anterior.
**Prioridad:** Media
**Dependencias:** RF-CMB-002.

---

## Criterios de aceptación

### CA para RF-CMB-001 — Dirección del ataque
- [ ] Dado el protagonista sin input vertical, cuando el jugador presiona ataque, entonces el golpe sale horizontal según el facing actual.
- [ ] Dado ↑ mantenido al presionar ataque, entonces el golpe sale hacia arriba, independientemente del facing.
- [ ] Dado ↓ mantenido en el aire al presionar ataque, entonces el golpe sale hacia abajo (pogo).
- [ ] Dado ↓ mantenido en tierra al presionar ataque, entonces el golpe sale horizontal (igual que sin input vertical).
- [ ] Dado el protagonista parado mirando a la derecha con input horizontal a la izquierda, cuando presiona ataque sin input vertical, entonces el golpe sale hacia la derecha (facing manda sobre input).

### CA para RF-CMB-002 — Ataque lateral
- [ ] Dado que el protagonista está en el suelo, cuando ejecuta el ataque lateral, entonces el hitbox cubre ~1.5 tiles [REVISAR] en la dirección del facing.
- [ ] Dado que el protagonista está en el suelo y atacó, puede seguir moviéndose durante el ataque (a velocidad reducida [REVISAR]).
- [ ] Dado que el protagonista está en el aire y atacó, conserva su momentum horizontal.
- [ ] Dado que el protagonista presiona ataque repetidamente dentro del recovery, solo se ejecuta un ataque por recovery (el extra se bufferiza).
- [ ] Dado que el ataque conecta con un objetivo, se produce hitstop de ~0.05s [REVISAR].
- [ ] Dado que el recovery expiró, el protagonista puede ejecutar el siguiente ataque.

### CA para RF-CMB-003 — Ataque hacia arriba
- [ ] Dado ↑ mantenido al presionar ataque, el hitbox cubre ~1.5 tiles [REVISAR] hacia arriba con ángulo ligeramente abierto.
- [ ] Dado que el protagonista está en tierra y ejecuta el ataque hacia arriba, permanece quieto durante el golpe.
- [ ] Dado que el protagonista está en el aire y ejecuta el ataque hacia arriba, conserva su momentum horizontal y vertical.
- [ ] Dado que el ataque hacia arriba conecta, se produce hitstop equivalente al ataque lateral.

### CA para RF-CMB-004 — Pogo
- [ ] Dado que el protagonista está en el aire con ↓ mantenido y presiona ataque, el hitbox cubre ~1.5 tiles [REVISAR] hacia abajo.
- [ ] Dado que el pogo conecta con un objetivo rebotable, la velocidad vertical del protagonista es reemplazada por un impulso hacia arriba de ~2.5 tiles [REVISAR].
- [ ] Dado que el pogo conecta con un objetivo rebotable, el dash aéreo y el doble salto (si están desbloqueados) quedan recuperados.
- [ ] Dado que el protagonista está cayendo y el pogo conecta rebotable, el impulso cancela la velocidad de caída y lo envía hacia arriba.
- [ ] Dado que el pogo conecta con un objetivo no-rebotable, el protagonista continúa cayendo sin impulso.
- [ ] Dado que el protagonista está en tierra con ↓ mantenido y presiona ataque, el golpe sale lateral (no pogo).
- [ ] Dado que el pogo conecta, el hitstop es ~0.08s [REVISAR] (perceptiblemente mayor que el del ataque lateral).

### CA para RF-CMB-005 — Categoría rebotable
- [ ] Dado un enemigo sin propiedad no-rebotable, cuando el pogo impacta, el sistema produce rebote.
- [ ] Dado un enemigo marcado como no-rebotable, cuando el pogo impacta, no hay rebote aunque el ataque cause daño.
- [ ] Dado un objeto del escenario interactivo sin marca especial, el pogo produce rebote por default.

### CA para RF-CMB-006 — Buffer de ataque
- [ ] Dado que el protagonista está en recovery de un ataque y el jugador presiona ataque dentro de la ventana de buffer (~0.1s [REVISAR] antes de que expire), entonces el siguiente ataque se ejecuta automáticamente al salir del recovery.
- [ ] Dado buffer activo, el ataque resultante usa el input vertical al momento de ejecutarse, no al momento de presionar el botón.

### CA para RF-CMB-007 — Facing durante recovery
- [ ] Dado que el protagonista está en recovery de un ataque lateral a la derecha y el jugador cambia el facing a la izquierda, el siguiente ataque lateral sale hacia la izquierda.

---

## Casos borde a contemplar

- **Pogo + Fast Fall:** el ↓ para fast fall y el ↓ para pogo usan el mismo input. Presionar ataque con ↓ activo en el aire ejecuta el pogo sin interrumpir la lógica de fast fall. Si el pogo conecta rebotable, el rebote cancela el fast fall.
- **Pogo + Doble salto disponible y no usado:** al rebotar, el doble salto se recupera si había sido consumido, pero no se consume si estaba disponible. El jugador puede encadenar pogo → doble salto → dash.
- **Atacar sin facing definido (primer frame del juego o tras respawn):** el protagonista debe tener un facing por default (hacia la derecha). [REVISAR con el dev al implementar el estado inicial.]
- **Spam de botón durante active frames:** el sistema no registra inputs durante los active frames, solo durante el recovery (ventana de buffer).
- **Ataque al aterrizar con ↓ mantenido:** el ataque sale con la dirección del input vertical al momento de ejecutarse, no al momento de presionarse. Un jugador que aterriza durante el input ↓ ejecuta un ataque lateral, no un pogo fallido en el piso.
- **Ataque ↑ con techo bajo inmediato:** el hitbox se corta al nivel del techo pero el ataque se ejecuta igual. [REVISAR CON DEV]
- **Ataque durante Dash:** [PENDIENTE — ver ítem de pendientes de diseño]
- **Ataque durante Wall Slide:** [PENDIENTE — ver ítem de pendientes de diseño]
- **Ataque durante Wall Jump (ventana de control bloqueada):** [PENDIENTE — ver ítem de pendientes de diseño]
- **Daño del facón sobre enemigos:** no formalizable hasta que el diseñador defina tabla de vida de enemigos.

---

## Dependencias con otros sistemas

- **State machine del protagonista** — el estado en suelo vs. aire determina si ↓ + ataque produce pogo o ataque lateral. El estado de facing es necesario para ataques laterales.
- **Sistema de física (CharacterBody2D)** — para determinar si el protagonista está en el aire.
- **Sistema de movimiento** — el pogo recupera el dash aéreo (RF-MOV-016) y el doble salto (RF-MOV-014). El rebote del pogo reemplaza la velocidad vertical del protagonista.
- **Sistema de hitbox/hurtbox** — cada entidad necesita un hurtbox y la propiedad rebotable/no-rebotable.
- **Sistema de animación** — animaciones distintas para ataque lateral, ataque arriba, pogo, con diferenciación visual clara. Ver `docs/arte/art-bible.md`.
- **Sistema de audio** — sonidos de golpe, hitstop, rebote de pogo. Ver `docs/audio/audio-design.md`.
- **Bestiary** — la propiedad no-rebotable se define en la ficha de cada criatura en `docs/personajes/bestiary/`.

---

## Ítems pendientes de diseño

- [PENDIENTE-001] Ataque durante carrera — la interacción entre correr y atacar no está definida en `combate.md`. No se pueden generar requerimientos de esa interacción hasta que el diseñador la defina. Preguntas abiertas: ¿el ataque frena al personaje?, ¿el alcance o daño cambian?, ¿hay animación específica de "tajo en carrera"?
- [PENDIENTE-002] Ataque durante Dash — no definido si el dash se puede cancelar atacando, si el ataque espera al fin del dash, o si se ignora. Bloquea RF-CMB-002 para ese contexto.
- [PENDIENTE-003] Ataque durante Wall Slide — no definido si se puede atacar desde la pared. Si sí, hacia qué dirección.
- [PENDIENTE-004] Ataque durante Wall Jump (ventana de control bloqueada) — no definido si el botón de ataque rompe el control bloqueado o queda en cola.
- [PENDIENTE-005] Daño del facón — depende de la tabla de vida de enemigos, aún no definida.
- [PENDIENTE-006] Sistema de parry — archivo propio pendiente: `docs/design/mecanicas/parry.md`. No se generan requerimientos hasta que exista.
- [PENDIENTE-007] Pogo recupera dash aéreo y doble salto — marcado [REVISAR] en el documento fuente. Confirmar balance en playtest.
- [PENDIENTE-008] Reducción de velocidad del protagonista al atacar en suelo — el documento fuente indica "velocidad reducida [REVISAR]" sin definir el valor. Bloqueado hasta que diseñador lo especifique.

---

## Notas para el desarrollador

- [NOTA-DEV-001] El hitstop se implementa pausando la simulación del protagonista y el objetivo durante N frames, no con un sleep del proceso. Esto permite que el juego siga corriendo (UI, audio) mientras la acción "congela" visualmente.
- [NOTA-DEV-002] El pogo reemplaza la velocidad vertical con un valor fijo (`velocity.y = -impulso`), no la suma. Esto garantiza el comportamiento igual en caída y en ascenso.
- [NOTA-DEV-003] La propiedad rebotable/no-rebotable debe ser una variable exportada en los nodos de las entidades enemigas, para que el diseñador pueda configurarla desde el editor sin tocar código.
- [NOTA-DEV-004] La dirección del ataque se calcula desde el **facing** del protagonista y el estado en tierra/aire + input vertical, en el momento del tap. La dirección del input horizontal no afecta la dirección del golpe.
- [NOTA-DEV-005] El buffer de ataque es un timer que se inicia al presionar el botón durante el recovery. Al expirar el recovery, si el timer aún está activo, se ejecuta el ataque. La dirección del ataque se recalcula en ese momento (no se guarda la dirección del momento del press).
- [NOTA-DEV-006] El pogo al conectar debe disparar un evento o señal de "rebote ejecutado" para que el sistema de movimiento pueda recuperar dash aéreo y doble salto sin acoplamiento directo entre los sistemas de combate y movimiento.
