# Requerimientos — Movimiento del protagonista

## Metadata
Fecha: 2026-04-25
Fuente: docs/design/mecanicas/movimiento.md, docs/design/controles.md
Estado: Borrador
Versión: 1.0

---

## Descripción general
Sistema que controla todo el desplazamiento del protagonista: movimiento horizontal
en dos velocidades (caminar / correr), salto variable controlable por hold, mecánicas
de tolerancia de input (coyote time y buffer), y habilidades desbloqueables que
amplían progresivamente el vocabulario del jugador en el aire y en las paredes.

---

## Requerimientos funcionales

---

### Movimiento base

---

### RF-MOV-001 — Desplazamiento horizontal: caminar
**Descripción:** El protagonista se desplaza horizontalmente con aceleración y
desaceleración naturales mientras el jugador aplica input horizontal sin mantener
el botón de correr.
**Disparador:** Input horizontal (joystick izq. / WASD / flechas) sin hold de correr.
**Resultado esperado:** El protagonista acelera hasta la velocidad de caminar (~180 px/s)
y desacelera por completo al soltar el input. El movimiento tiene masa pero es
responsivo: no hay deslizamiento perceptible.
**Prioridad:** Alta
**Dependencias:** Ninguna.

---

### RF-MOV-002 — Desplazamiento horizontal: correr
**Descripción:** Mientras el jugador mantiene presionado el botón de correr con input
horizontal, el protagonista se desplaza a una velocidad mayor. Al soltar el botón
de correr, vuelve a la velocidad de caminar con una rampa corta de desaceleración,
no de forma instantánea.
**Disparador:** Hold del botón de correr (RT/R2 / Shift izq.) + input horizontal activo.
**Resultado esperado:**
- El protagonista acelera desde la velocidad de caminar hasta la de correr (~260 px/s)
  en una rampa de ~0.2s [REVISAR].
- Al soltar el botón de correr mientras sigue con input horizontal, desacelera a
  la velocidad de caminar en ~0.15s [REVISAR]. No es un corte brusco.
- Si el jugador suelta el input horizontal mientras corre, frena por completo
  usando la desaceleración estándar (distancia extra ~30% mayor que desde caminar [REVISAR]).
- El botón de correr se lee como binario (presionado / no presionado) con umbral
  de ~50% del recorrido del gatillo analógico [REVISAR CON DEV].
**Prioridad:** Alta
**Dependencias:** RF-MOV-001

---

### RF-MOV-003 — Cambio de dirección
**Descripción:** Al cambiar el input horizontal a la dirección opuesta, el protagonista
ejecuta un micro-freno antes de acelerar en la nueva dirección.
**Disparador:** Input horizontal opuesto al desplazamiento actual.
**Resultado esperado:**
- Desde caminar: hay un frame de freno breve (~0.05s [REVISAR]) antes de acelerar
  en la dirección nueva.
- Desde correr: el freno de cambio de dirección es perceptiblemente más largo que
  desde caminar [REVISAR]. El jugador siente que "corregir dirección corriendo cuesta más".
- En ningún caso el protagonista frena de forma instantánea ni mantiene su velocidad
  anterior en la dirección opuesta.
**Prioridad:** Media
**Dependencias:** RF-MOV-001, RF-MOV-002

---

### RF-MOV-004 — Salto: impulso inicial
**Descripción:** Al presionar el botón de salto estando en el suelo (o dentro de
la ventana de coyote time), el protagonista recibe un impulso vertical hacia arriba.
Este impulso garantiza una altura mínima incluso si el botón se suelta de inmediato
(tap instantáneo).
**Disparador:** Tap o inicio de hold del botón de salto (A/Cruz / Espacio) mientras
el protagonista está en suelo o en ventana de coyote time activa.
**Resultado esperado:** El protagonista despega con velocidad vertical hacia arriba.
La altura mínima garantizada (tap instantáneo) es de ~1.5 tiles [REVISAR]. El personaje
queda en el aire aunque el botón se haya soltado al instante.
**Prioridad:** Alta
**Dependencias:** Ninguna.

---

### RF-MOV-005 — Salto: extensión por hold durante el ascenso
**Descripción:** Mientras el botón de salto esté presionado durante la fase de
ascenso, la gravedad aplicada al protagonista es reducida, extendiendo el tiempo
en el aire y la altura alcanzada. El control es continuo: cada fracción adicional
de hold suma altura hasta el tope máximo. No hay pasos discretos.
**Disparador:** Hold continuo del botón de salto durante la fase de subida, dentro
de los primeros ~0.25s desde el despegue [REVISAR] (duración máxima del hold efectivo).
**Resultado esperado:**
- Mientras el hold esté activo durante el ascenso, la gravedad es reducida y el
  protagonista sigue subiendo.
- Un tap breve produce un salto corto (~1.5 tiles [REVISAR]).
- Un hold intermedio produce una altura intermedia entre mínimo y máximo.
- Un hold completo (~0.25s [REVISAR]) produce la altura máxima (~4 tiles [REVISAR]).
- La extensión solo funciona durante la fase de ascenso. Mantener el botón durante
  la caída no tiene efecto.
- Pasada la duración máxima del hold efectivo, la gravedad vuelve a normal aunque
  el botón continúe presionado. **No hay vuelo.**
**Prioridad:** Alta
**Dependencias:** RF-MOV-004

---

### RF-MOV-006 — Salto: corte por liberación del botón (jump cut)
**Descripción:** Si el jugador suelta el botón de salto antes de alcanzar el apex
(y después de la ventana mínima garantizada), la gravedad pasa inmediatamente a
un multiplicador mayor, haciendo que el protagonista comience a caer más rápido.
Esto permite cortar el salto en cualquier momento del ascenso.
**Disparador:** Liberación del botón de salto durante la fase de ascenso, después
de la ventana mínima de ~0.05s [REVISAR].
**Resultado esperado:** La gravedad aplicada sube a 2.0x [REVISAR] de forma inmediata,
y el protagonista desacelera su ascenso y cae antes de lo que hubiera hecho sin
soltar. El corte es responsivo: no hay delay entre soltar el botón y el cambio de gravedad.
**Prioridad:** Alta
**Dependencias:** RF-MOV-005

---

### RF-MOV-007 — Salto: ventana mínima garantizada (anti-cut accidental)
**Descripción:** Existe una ventana de tiempo mínimo tras el despegue durante la
cual el salto no puede ser cortado por la lógica de jump cut, aunque el jugador
suelte el botón. Esto protege al jugador de cortar el salto por soltar el botón
accidentalmente al presionar.
**Disparador:** Liberación del botón de salto dentro de los primeros ~0.05s [REVISAR]
desde el despegue.
**Resultado esperado:** El salto no se corta. El protagonista alcanza al menos la
altura mínima garantizada (~1.5 tiles [REVISAR]) independientemente de cuán
brevemente se haya tocado el botón.
**Prioridad:** Alta
**Dependencias:** RF-MOV-004, RF-MOV-006

---

### RF-MOV-008 — Salto: techo duro (altura máxima)
**Descripción:** El salto tiene una altura máxima y una duración máxima de hold
efectivo. Alcanzados esos límites, la gravedad vuelve a su valor normal aunque el
botón de salto continúe presionado.
**Disparador:** Protagonista alcanza el apex del salto o se agota la duración máxima
del hold efectivo (~0.25s [REVISAR]).
**Resultado esperado:** La gravedad vuelve a normal. El protagonista comienza la
caída. El hold continuo del botón no impide la caída ni produce flotación.
**Prioridad:** Alta
**Dependencias:** RF-MOV-005

---

### RF-MOV-009 — Salto: fase de caída con gravedad aumentada
**Descripción:** Durante la fase de caída (desde el apex hasta el suelo), la gravedad
aplicada es ligeramente mayor que la del ascenso base, dando mayor peso y rapidez
al descenso. Hay una velocidad máxima de caída (terminal velocity).
**Disparador:** Protagonista en fase de caída (velocidad vertical negativa).
**Resultado esperado:**
- La gravedad durante la caída es 1.4x [REVISAR] respecto a la gravedad base.
- La velocidad de caída no supera ~600 px/s (terminal velocity) [REVISAR].
- La caída se siente perceptiblemente más rápida que la subida, reforzando el peso
  del personaje.
**Prioridad:** Alta
**Dependencias:** RF-MOV-004

---

### RF-MOV-010 — Coyote time
**Descripción:** Si el protagonista camina fuera del borde de una plataforma sin
haber saltado, tiene una ventana de tiempo breve (~0.12s [REVISAR]) durante la cual
puede ejecutar el salto como si siguiera en el suelo.
**Disparador:** Protagonista abandona el borde de una plataforma por desplazamiento
horizontal (no por salto). Input de salto dentro de los primeros ~0.12s [REVISAR]
desde la separación.
**Resultado esperado:** El salto se ejecuta normalmente — misma lógica que RF-MOV-004
a RF-MOV-009. Al agotarse la ventana, el salto ya no es posible (salvo doble salto
si está desbloqueado).
**Prioridad:** Alta
**Dependencias:** RF-MOV-004

---

### RF-MOV-011 — Buffer de input: salto y dash
**Descripción:** Las acciones de salto y dash se registran aunque se hayan ejecutado
ligeramente antes de que la condición para realizarlas sea válida. Si el jugador
presiona el botón antes de que la acción sea posible, la acción se ejecuta en el
primer frame válido.
**Disparador:**
- Salto: botón presionado hasta ~0.1s [REVISAR] antes de tocar el suelo.
- Dash: botón presionado hasta ~0.1s [REVISAR] antes de que el cooldown expire.
**Resultado esperado:** La acción se ejecuta al volverse legal, sin requerir que el
jugador haga timing perfecto. El movimiento fluido se siente natural.
**Prioridad:** Media
**Dependencias:** RF-MOV-004 (para salto), RF-MOV-015 (para dash).

---

### RF-MOV-012 — Control aéreo completo
**Descripción:** El protagonista mantiene control horizontal completo en todo momento
mientras está en el aire. No hay reducción de agencia aérea respecto al suelo.
**Disparador:** Protagonista en el aire (tras salto, caída o cualquier habilidad aérea).
**Resultado esperado:**
- La velocidad horizontal en el aire es igual a la del suelo (caminar o correr según
  el estado del hold de correr al momento del despegue o durante el vuelo).
- El jugador puede cambiar de dirección libremente en el aire.
- Si el jugador mantiene el hold de correr en el aire, se mueve a velocidad de correr.
  Si lo suelta en el aire, desacelera a velocidad de caminar.
**Prioridad:** Alta
**Dependencias:** RF-MOV-001, RF-MOV-002, RF-MOV-004

---

### Habilidades de movimiento desbloqueables

> Los siguientes requerimientos corresponden a habilidades que no están disponibles
> desde el inicio. Se desbloquean explorando el mundo.
> La ubicación exacta de cada desbloqueo es [PENDIENTE] hasta que exista
> `docs/design/progresion.md`.

---

### RF-MOV-013 — Fast Fall
**Descripción:** Al presionar el input hacia abajo mientras está en el aire, el
protagonista cae significativamente más rápido. Requiere habilidad desbloqueada.
**Disparador:** Input ↓ (joystick izq. abajo / tecla S o ↓) mantenido mientras el
protagonista está en el aire.
**Resultado esperado:**
- La gravedad se multiplica por 3.0x [REVISAR] durante el fast fall.
- La velocidad de caída máxima durante fast fall es ~900 px/s [REVISAR].
- El fast fall dura mientras el jugador mantenga ↓ presionado.
- Al soltar ↓, la gravedad vuelve a su valor normal de caída (RF-MOV-009).
- El fast fall se cancela al tocar el suelo.
- El fast fall no afecta el control horizontal.
**Prioridad:** Media
**Dependencias:** RF-MOV-009, RF-MOV-012

---

### RF-MOV-014 — Doble salto: impulso y control
**Descripción:** Con la habilidad desbloqueada, el jugador puede ejecutar un segundo
salto mientras está en el aire. El segundo salto respeta la misma lógica de altura
variable que el primer salto (tap = impulso corto, hold = impulso más extendido),
pero con altura máxima menor. Requiere soltar y volver a presionar el botón
(release + press), no un hold continuo.
**Disparador:** Release + press del botón de salto mientras el protagonista está
en el aire y tiene el doble salto disponible.
**Resultado esperado:**
- La velocidad vertical del protagonista es **reemplazada** por el impulso del
  segundo salto (no se suma). Funciona igual cayendo que subiendo.
- Altura máxima del segundo salto (hold completo): ~3 tiles [REVISAR].
- Altura mínima del segundo salto (tap instantáneo): ~1 tile [REVISAR].
- Duración máxima del hold efectivo del segundo salto: ~0.2s [REVISAR].
- La ventana mínima garantizada aplica igual que en el primer salto (~0.05s [REVISAR]).
- Un hold continuo del primer salto sin soltar **no activa** el doble salto.
  El sistema requiere detección de release + press.
- Solo se puede usar una vez por estancia aérea.
**Prioridad:** Media
**Dependencias:** RF-MOV-004, RF-MOV-005, RF-MOV-006, RF-MOV-007

---

### RF-MOV-015 — Doble salto: recuperación del uso
**Descripción:** El doble salto consumido se recupera al tocar el suelo. También
se recupera al iniciar un wall slide (la pared actúa como reset del estado aéreo).
**Disparador:**
- Protagonista aterriza en el suelo.
- Protagonista inicia wall slide (RF-MOV-018).
**Resultado esperado:** El uso del doble salto se marca como disponible. El jugador
puede volver a ejecutarlo en la siguiente estancia aérea.
**Prioridad:** Media
**Dependencias:** RF-MOV-014, RF-MOV-018

---

### RF-MOV-016 — Dash I: horizontal y diagonal superior (prototipo)
**Descripción:** Impulso corto y rápido en la dirección que el protagonista está
mirando (facing), en tierra o en el aire. La dirección se determina por el facing,
no por el input horizontal del momento.
Modalidad diagonal superior [PROTOTIPO]: si el jugador mantiene ↑ al ejecutar el
dash, el impulso es diagonal (↖ si mira a la izquierda, ↗ si mira a la derecha).
**Disparador:** Tap del botón de dash (B/Círculo / K).
- Sin ↑: dash horizontal puro según facing.
- Con ↑ mantenido [PROTOTIPO]: dash diagonal superior según facing.
**Resultado esperado:**
- El protagonista se mueve en la dirección calculada a alta velocidad durante ~0.18s [REVISAR].
- Distancia horizontal: ~3 tiles [REVISAR].
- Distancia diagonal (componente horizontal y vertical): ~2.2 tiles cada uno [REVISAR],
  magnitud total del vector comparable al dash horizontal.
- Cooldown de ~0.6s [REVISAR] antes de poder ejecutar otro dash.
- En tierra: el dash se ejecuta en el suelo, sin despegue involuntario salvo
  dash diagonal desde el suelo (despega con el impulso).
- En el aire: consume el dash aéreo. Se recupera al tocar el suelo.
- No hay iframes en Dash I [REVISAR].
**Prioridad:** Media
**Dependencias:** RF-MOV-001, RF-MOV-012

---

### RF-MOV-017 — Dash II: dash direccional completo (8 direcciones)
**Descripción:** Amplía el dash a las 8 direcciones completas. Si las diagonales
superiores quedaron permanentes desde Dash I (prototipo confirmado), Dash II agrega:
↑ puro, ↓ puro y diagonales inferiores (↙, ↘). Si el prototipo fue descartado,
Dash II entrega las 8 direcciones completas de una.
**Disparador:** Tap del botón de dash con el input direccional correspondiente.
**Resultado esperado:**
- ↑ puro: impulso vertical hacia arriba (Fast Up). Permite revertir una caída bruscamente.
- ↓ puro en el aire: descenso a velocidad de dash, impacto inmediato con el suelo [REVISAR].
- Diagonales inferiores (↙, ↘): impulso diagonal hacia abajo según facing.
- El cooldown es el mismo que Dash I.
- Las diagonales son a 45° [REVISAR — puede adaptarse al ángulo del joystick analógico].
**Prioridad:** Baja (desbloqueo posterior)
**Dependencias:** RF-MOV-016

---

### RF-MOV-018 — Wall Slide
**Descripción:** Al estar en el aire y tocar una pared con input horizontal hacia
ella, el protagonista se adhiere a la pared y cae lentamente en lugar de caer a
velocidad normal. Requiere habilidad desbloqueada.
**Disparador:** Protagonista en el aire + contacto con pared + input horizontal
mantenido hacia esa pared.
**Resultado esperado:**
- El protagonista cae a ~60 px/s [REVISAR] en lugar de la velocidad de caída normal.
- Hay una micro-transición (~0.05s [REVISAR]) al activarse que indica visualmente
  que la mecánica está activa.
- Si el jugador suelta el input horizontal, el protagonista deja de adherirse y
  cae a velocidad normal.
- La mecánica se cancela al tocar el suelo.
- Durante el wall slide, la velocidad de correr no tiene efecto.
**Prioridad:** Media
**Dependencias:** RF-MOV-004, RF-MOV-009

---

### RF-MOV-019 — Wall Jump
**Descripción:** Durante el wall slide, el jugador puede saltar desde la pared.
El salto tiene una componente horizontal forzada alejándose de la pared y una
componente vertical, independientemente del input horizontal del jugador en ese momento.
Requiere Wall Slide desbloqueado.
**Disparador:** Input de salto durante wall slide activo.
**Resultado esperado:**
- El protagonista se impulsa alejándose de la pared (siempre en dirección contraria
  a la pared). No se puede wall jump hacia la misma pared.
- Velocidad horizontal de salida: ~200 px/s [REVISAR].
- Velocidad vertical de salida: comparable al salto completo [REVISAR].
- El jugador recupera control horizontal completo ~0.15s después del wall jump [REVISAR].
  Durante ese lapso, el input horizontal del jugador no sobreescribe el impulso de salida.
- Se puede encadenar entre paredes opuestas para escalar cañones verticales.
**Prioridad:** Media
**Dependencias:** RF-MOV-018, RF-MOV-004

---

## Criterios de aceptación

### CA para RF-MOV-001 — Caminar
- [ ] Dado que el protagonista está en el suelo sin hold de correr, cuando el jugador presiona derecha, entonces el protagonista se mueve hacia la derecha alcanzando ~180 px/s en ~0.1s [REVISAR].
- [ ] Dado que el protagonista camina, cuando el jugador suelta el input, entonces frena en ~0.08s [REVISAR] sin deslizamiento.
- [ ] Dado que el protagonista choca con una pared caminando, cuando el jugador mantiene el input en esa dirección, entonces el protagonista no la atraviesa.

### CA para RF-MOV-002 — Correr
- [ ] Dado que el protagonista está caminando, cuando el jugador activa el hold de correr, entonces acelera a ~260 px/s en ~0.2s [REVISAR].
- [ ] Dado que el protagonista corre, cuando el jugador suelta solo el botón de correr pero mantiene input horizontal, entonces desacelera hasta ~180 px/s en ~0.15s [REVISAR] sin corte brusco.
- [ ] Dado que el protagonista corre, cuando el jugador suelta el input horizontal, entonces frena usando la desaceleración estándar (distancia mayor que desde caminar).
- [ ] Dado que el protagonista está en el suelo y tiene el hold de correr activo, cuando salta y mantiene el hold en el aire, entonces vuela a velocidad de correr en el aire.

### CA para RF-MOV-003 — Cambio de dirección
- [ ] Dado que el protagonista camina a la derecha, cuando el jugador aplica input a la izquierda, entonces hay un micro-freno de ~0.05s [REVISAR] antes de acelerar a la izquierda.
- [ ] Dado que el protagonista corre a la derecha, cuando el jugador aplica input a la izquierda, entonces el freno de cambio de dirección es perceptiblemente más largo que desde caminar.

### CA para RF-MOV-004 — Impulso inicial del salto
- [ ] Dado que el protagonista está en el suelo, cuando el jugador hace un tap instantáneo de salto, entonces el protagonista despega y alcanza al menos ~1.5 tiles de altura [REVISAR].
- [ ] Dado que el protagonista está en el suelo, cuando el jugador presiona salto, entonces responde en el mismo frame (sin latencia perceptible).
- [ ] Dado que el protagonista está en el aire por cualquier causa, cuando el jugador presiona salto (sin doble salto desbloqueado), entonces el salto no se ejecuta.

### CA para RF-MOV-005 — Extensión del salto por hold
- [ ] Dado que el protagonista está en ascenso y el jugador mantiene el botón de salto, entonces el protagonista sigue subiendo con gravedad reducida.
- [ ] Dado un hold completo (~0.25s [REVISAR]) desde el despegue, entonces el protagonista alcanza la altura máxima de ~4 tiles [REVISAR].
- [ ] Dado un hold de ~0.12s, entonces el protagonista alcanza una altura intermedia entre mínimo y máximo.
- [ ] Dado que el hold supera la duración máxima efectiva (~0.25s [REVISAR]), entonces la gravedad vuelve a normal aunque el botón siga presionado — el protagonista no vuela.
- [ ] Dado que el protagonista está en la fase de caída y el jugador mantiene el botón de salto, entonces no se modifica la trayectoria.

### CA para RF-MOV-006 — Corte del salto
- [ ] Dado que el protagonista está en ascenso (pasada la ventana mínima de ~0.05s), cuando el jugador suelta el botón de salto, entonces la gravedad sube a 2.0x [REVISAR] de forma inmediata.
- [ ] Dado el corte del salto, el protagonista llega a un apex notoriamente más bajo que el salto completo equivalente.
- [ ] Dado el corte del salto, no hay delay entre la liberación del botón y el cambio de gravedad.

### CA para RF-MOV-007 — Ventana mínima garantizada
- [ ] Dado que el jugador suelta el botón de salto dentro de los primeros ~0.05s [REVISAR] desde el despegue, entonces el protagonista alcanza la altura mínima garantizada (~1.5 tiles [REVISAR]) sin que el salto sea cortado.

### CA para RF-MOV-008 — Techo duro
- [ ] Dado que el protagonista alcanza el apex del salto con hold continuo, entonces comienza la caída y el hold ya no produce extensión.
- [ ] Dado hold continuo del botón de salto durante todo el arco, entonces el protagonista nunca supera ~4 tiles de altura [REVISAR].

### CA para RF-MOV-009 — Gravedad de caída
- [ ] Dado que el protagonista está en fase de caída, la velocidad de descenso es perceptiblemente mayor que la velocidad de ascenso equivalente.
- [ ] Dado que el protagonista cae, la velocidad no supera ~600 px/s [REVISAR] (terminal velocity).

### CA para RF-MOV-010 — Coyote time
- [ ] Dado que el protagonista camina fuera del borde de una plataforma sin haber saltado, cuando el jugador presiona salto dentro de ~0.12s [REVISAR], entonces el salto se ejecuta normalmente.
- [ ] Dado que el protagonista cayó más de ~0.12s [REVISAR] sin saltar, cuando el jugador presiona salto (sin doble salto), entonces el salto no se ejecuta.
- [ ] Dado que el protagonista saltó voluntariamente y está en el aire, el coyote time no está activo (solo se activa por desplazamiento sobre el borde, no por salto).

### CA para RF-MOV-011 — Buffer de input
- [ ] Dado que el protagonista está a punto de aterrizar y el jugador presiona salto hasta ~0.1s [REVISAR] antes de tocar el suelo, entonces el salto se ejecuta al aterrizar.
- [ ] Dado que el dash está en cooldown y el jugador presiona dash hasta ~0.1s [REVISAR] antes de que expire, entonces el dash se ejecuta al expirar el cooldown.

### CA para RF-MOV-012 — Control aéreo
- [ ] Dado que el protagonista está en el aire, cuando el jugador aplica input horizontal, entonces responde con la misma velocidad y aceleración que en el suelo.
- [ ] Dado que el protagonista está en el aire con hold de correr activo, se mueve a velocidad de correr en el aire.
- [ ] Dado que el protagonista está en el aire, puede cambiar de dirección horizontal libremente.

### CA para RF-MOV-013 — Fast Fall
- [ ] Dado que el protagonista está en el aire con fast fall desbloqueado, cuando el jugador mantiene ↓, entonces la velocidad de caída aumenta significativamente (hasta ~900 px/s [REVISAR]).
- [ ] Dado fast fall activo, cuando el jugador suelta ↓, entonces la gravedad vuelve a la normal de caída.
- [ ] Dado fast fall activo, el control horizontal no se ve afectado.
- [ ] Dado que el protagonista toca el suelo con fast fall activo, la mecánica se cancela.

### CA para RF-MOV-014 — Doble salto: impulso
- [ ] Dado que el protagonista está en el aire con doble salto disponible, cuando el jugador hace release + press del botón de salto, entonces el protagonista recibe el impulso del segundo salto reemplazando su velocidad vertical actual.
- [ ] Dado un tap del segundo salto, el protagonista sube al menos ~1 tile [REVISAR].
- [ ] Dado un hold completo del segundo salto (~0.2s [REVISAR]), el protagonista sube ~3 tiles [REVISAR].
- [ ] Dado que el protagonista está cayendo y ejecuta el doble salto, el impulso reemplaza la velocidad de caída (no se atenúa por ella).
- [ ] Dado que el jugador mantiene el hold del primer salto sin soltar, el doble salto no se activa (requiere release + press detectados).
- [ ] Dado que el protagonista ya usó el doble salto en esta estancia aérea, el botón de salto en el aire no produce un tercer salto.

### CA para RF-MOV-015 — Doble salto: recuperación
- [ ] Dado que el protagonista usó el doble salto y toca el suelo, el doble salto queda disponible para la siguiente estancia aérea.
- [ ] Dado que el protagonista usó el doble salto y entra en wall slide, el doble salto queda disponible.

### CA para RF-MOV-016 — Dash I
- [ ] Dado que el protagonista tiene Dash I desbloqueado y no hay ↑ mantenido, cuando presiona dash, entonces se impulsa horizontalmente según su facing (~3 tiles [REVISAR]).
- [ ] Dado que el protagonista está parado mirando a la derecha sin input horizontal activo, cuando presiona dash, entonces el dash va a la derecha.
- [ ] Dado que el protagonista tiene ↑ mantenido y presiona dash [PROTOTIPO], entonces se impulsa en diagonal superior según su facing.
- [ ] Dado que el dash se ejecutó, el protagonista no puede hacer otro dash por ~0.6s [REVISAR] (cooldown).
- [ ] Dado que el protagonista hace dash contra una pared, entonces se detiene al contacto sin atravesarla.
- [ ] Dado que el protagonista hace dash en el aire, el dash aéreo queda consumido hasta tocar el suelo.

### CA para RF-MOV-017 — Dash II
- [ ] Dado Dash II desbloqueado y ↑ mantenido + dash, entonces el protagonista se impulsa verticalmente hacia arriba (Fast Up).
- [ ] Dado Dash II desbloqueado y ↓ mantenido + dash en el aire, entonces el protagonista desciende a velocidad de dash y aterriza con impacto inmediato [REVISAR].
- [ ] Dado Dash II, el cooldown es el mismo que Dash I.

### CA para RF-MOV-018 — Wall Slide
- [ ] Dado que el protagonista está en el aire con wall slide desbloqueado, cuando toca una pared con input horizontal hacia ella, entonces pasa a velocidad de caída reducida (~60 px/s [REVISAR]).
- [ ] Dado wall slide activo, cuando el jugador suelta el input horizontal, entonces el protagonista cae a velocidad normal.
- [ ] Dado wall slide activo, cuando el protagonista llega al suelo, la mecánica se cancela.
- [ ] Dado que el protagonista recibe daño durante el wall slide, entonces la mecánica se cancela y cae normalmente.

### CA para RF-MOV-019 — Wall Jump
- [ ] Dado wall slide activo, cuando el jugador presiona salto, entonces el protagonista se impulsa alejándose de la pared.
- [ ] Dado wall jump ejecutado, durante ~0.15s [REVISAR] el input horizontal del jugador no sobreescribe el impulso de salida.
- [ ] Dado pared a la izquierda, el wall jump impulsa hacia la derecha (nunca hacia la misma pared).
- [ ] Dado paredes opuestas, el jugador puede encadenar wall jumps para ascender.
- [ ] Sin wall slide desbloqueado, el protagonista no se adhiere a paredes y el wall jump es imposible.

---

## Casos borde a contemplar

### Salto
- ¿Qué pasa si el jugador presiona salto mientras cae desde gran altura sin coyote time y sin doble salto? → el salto no se ejecuta.
- ¿Qué pasa si el protagonista choca con un techo durante el ascenso? → la velocidad vertical se pone en cero y empieza a caer. No rebota ni se adhiere. El hold del botón no tiene efecto tras el impacto.
- ¿Qué pasa si el jugador suelta y vuelve a presionar el botón de salto en el aire sin doble salto desbloqueado? → no pasa nada.
- ¿Qué pasa si el jugador presiona izquierda y derecha simultáneamente? → el protagonista no se mueve horizontalmente.

### Correr
- ¿Qué pasa si el protagonista recibe daño mientras corre? → el hold de correr se ignora durante el stagger; al recuperar el control, si el botón sigue presionado, vuelve a aplicar. [REVISAR CON COMBATE]
- ¿Qué pasa si el protagonista hace dash mientras corre? → el dash ignora el estado de carrera. Al terminar el dash, si mantiene el hold y tiene input horizontal, vuelve a correr.

### Dash I
- ¿Qué pasa si el dash en diagonal choca contra un techo? → se detiene el componente vertical al contacto y conserva el horizontal hasta terminar la duración del dash. [REVISAR CON DEV]
- ¿Qué pasa si el dash lleva al protagonista al borde de una plataforma? → cae naturalmente después del dash.
- ¿Qué pasa si el prototipo de diagonales superiores se descarta tras playtest? → el bloque de RF-MOV-016 vuelve a solo horizontal; las diagonales superiores se trasladan a Dash II.

### Doble salto
- ¿Qué pasa si el protagonista cae de una plataforma sin saltar (coyote time agotado) y tiene doble salto disponible? → puede ejecutar el doble salto. El salto aéreo se consume. [REVISAR — evaluar si el primer salto aéreo no debería gastar el doble si hubo coyote time activo. Decidir tras playtest.]
- ¿Qué pasa si el protagonista ejecuta doble salto contra un techo de inmediato? → velocidad vertical a cero, empieza a caer, el doble salto queda consumido. [REVISAR — ¿perdonar el consumo si el choque fue en los primeros N frames?]
- ¿Qué pasa si el protagonista hace doble salto durante fast fall? → el fast fall se cancela; el impulso del segundo salto reemplaza la velocidad de caída.
- ¿Qué pasa si el protagonista está en wall slide después de haber usado el doble salto y lo vuelve a usar durante el slide? → sale de la pared con el impulso del segundo salto y el slide se cancela. [REVISAR — puede hacer la mecánica de pared redundante si es muy generoso]

### Wall Jump
- ¿Qué pasa si el jugador intenta wall jump en la misma pared repetidas veces? → [REVISAR — considerar limitar a 1 wall jump por pared para evitar ascenso infinito]
- ¿Qué pasa si el jugador hace dash inmediatamente después de un wall jump? → permitido con buffer de input.

---

## Dependencias con otros sistemas

- **Sistema de física de Godot (CharacterBody2D)** — base de todo el movimiento y colisiones.
- **State machine del protagonista** — el coyote time, el buffer de input y el doble salto requieren estados y timers independientes del estado físico.
- **Sistema de animación** — debe reproducir animaciones según el estado: idle, caminar, correr, ascenso, caída, dash, wall slide, etc.
- **Sistema de audio** — pasos (diferenciar caminar/correr), salto, aterrizaje, dash, wall slide, doble salto. Ver `docs/audio/audio-design.md`.
- **Sistema de cámara** — el Fast Up (Dash ↑) requiere que la cámara acompañe el movimiento vertical explosivo sin sacudir. [REVISAR CON DEV — ver `docs/design/camaras.md` cuando exista]
- **Sistema de combate** — interacción de correr con recibir daño (stagger). Ver `docs/design/mecanicas/combate.md`. [REVISAR — ataque en movimiento PENDIENTE]

---

## Ítems pendientes de diseño

- [PENDIENTE-001] Ubicación de desbloqueo de Fast Fall (RF-MOV-013) → bloqueado hasta que diseñador defina en `docs/design/progresion.md`.
- [PENDIENTE-002] Ubicación de desbloqueo de Doble Salto (RF-MOV-014/015) → ídem.
- [PENDIENTE-003] Ubicación de desbloqueo de Dash I (RF-MOV-016) → ídem.
- [PENDIENTE-004] Ubicación de desbloqueo de Dash II (RF-MOV-017) → ídem.
- [PENDIENTE-005] Ubicación de desbloqueo de Wall Slide (RF-MOV-018) → ídem.
- [PENDIENTE-006] Ubicación de desbloqueo de Wall Jump (RF-MOV-019) → ídem.
- [PENDIENTE-007] Dash I — las diagonales superiores (↖, ↗) son [PROTOTIPO]. RF-MOV-016 y sus CA correspondientes están condicionados a la confirmación del prototipo tras playtest. Si se descarta, el bloque de diagonales en RF-MOV-016 se elimina y las diagonales pasan a RF-MOV-017.
- [PENDIENTE-008] Comportamiento de correr + daño recibido → requiere que el diseñador lo defina en coordinación con `docs/design/mecanicas/combate.md`. [REVISAR CON COMBATE]
- [PENDIENTE-009] Interacción de ataques con movimiento (dash, correr, wall slide) → queda PENDIENTE según `combate.md`. No se pueden formalizar requerimientos de esa interacción hasta que el diseñador la defina.
- [PENDIENTE-010] Dash III (Dash Sombra) → estado [CONCEPTO]. No se generan requerimientos hasta que el diseñador lo defina.
- [PENDIENTE-011] Doble salto + wall slide: ¿la pared recupera el doble salto si el jugador entró al slide después de usarlo? → confirmar tras playtest.

---

## Notas para el desarrollador

- [NOTA-DEV-001] El coyote time y el buffer de input requieren timers independientes del estado físico del CharacterBody2D. Implementarlos en la state machine, no en el loop de física.
- [NOTA-DEV-002] El jump cut (RF-MOV-006) se implementa aplicando gravedad adicional al soltar el botón, **no cortando la velocidad vertical**. Cortar la velocidad produce un arco antinatural.
- [NOTA-DEV-003] La extensión del salto por hold (RF-MOV-005) se implementa reduciendo la gravedad mientras el botón esté presionado durante el ascenso, no aumentando el impulso inicial. Esto produce el control continuo y suave descrito.
- [NOTA-DEV-004] El doble salto requiere detección explícita de release + press. No se activa por hold continuo. Considerar una bandera `jump_button_released_in_air` que se activa al soltar el botón estando en el aire.
- [NOTA-DEV-005] El dash se dispara según el **facing** del personaje, no según el input horizontal del momento. Asegurarse de que la dirección del dash se calcule desde la variable de facing, no desde el vector de velocidad ni el input actual.
- [NOTA-DEV-006] El botón de correr (gatillo analógico RT/R2) debe leerse como binario con umbral de ~50% del recorrido. [REVISAR] No usar lectura progresiva del gatillo para esta acción.
- [NOTA-DEV-007] El wall slide puede recuperar el doble salto (RF-MOV-015). Esto implica que el inicio del wall slide debe disparar un evento de "reset aéreo" que otros sistemas puedan escuchar.
- [NOTA-DEV-008] Todos los valores numéricos marcados [REVISAR] son aproximaciones de diseño para la implementación inicial. El desarrollador puede proponer ajustes marcando `# [REVISAR CON DISEÑO]` en el código.
- [NOTA-DEV-009] La interacción Fast Fall + Dash ↑ (Fast Up) puede requerir coordinación especial con el sistema de cámara para evitar sacudidas. Evaluar junto al sistema de cámara cuando se implemente Dash II. [REVISAR CON DEV]
