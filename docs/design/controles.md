# Controles — Proyecto G

> Mapeo de inputs del juego. Se actualiza cada vez que se define o cambia una acción.
> Todos los valores están sujetos a playtest y a la decisión del jugador vía remapeo.

---

## Gamepad (referencia principal)

| Acción              | Botón gamepad         | Teclado        | Tipo de input | Notas |
|---------------------|-----------------------|----------------|---------------|-------|
| Mover               | Joystick izq.         | WASD / Flechas | Analógico / Digital | El input vertical se usa también para Fast Fall y modificadores de dash |
| Saltar              | A / Cruz              | Espacio        | Tap + Hold    | Hold = salto completo, Tap = salto corto |
| Correr              | Gatillo derecho (RT / R2) | Shift (izq.) | **Hold**      | Mientras se mantiene, se corre (~260 px/s). Al soltar, se vuelve a caminar (~180 px/s) |
| Atacar              | X / Cuadrado          | J              | Tap           | Dirección según facing + modificador vertical. ↑ = ataque alto, ↓ en aire = pogo. Ver `combate.md` |
| Dash                | B / Círculo           | K              | Tap           | Dirección según facing del personaje. Con ↑ mantenido = dash diagonal superior [PROTOTIPO] |
| Parry               | [PENDIENTE]           | [PENDIENTE]    | [PENDIENTE]   | [PENDIENTE — ver docs/design/mecanicas/parry.md cuando exista] |
| Interactuar         | Y / Triángulo         | E              | Tap           | Diálogos, objetos, checkpoints |
| Pausa               | Start / Options       | Escape         | Tap           |  |
| Mapa                | Select / Back / Share | Tab            | Tap           |  |

---

## Inputs compuestos y modificadores

Estas combinaciones surgen de la interacción entre inputs básicos. No son botones
nuevos — son el resultado de mantener un input mientras se ejecuta otro.

| Resultado                          | Combinación                       | Disponibilidad |
|------------------------------------|-----------------------------------|----------------|
| Salto corto                        | Tap de saltar                     | Kit base |
| Salto completo                     | Hold de saltar                    | Kit base |
| Fast Fall                          | ↓ mantenido en el aire            | Habilidad desbloqueable |
| Dash horizontal                    | Dash sin input vertical           | Desbloqueo Dash I |
| Dash diagonal superior (↖ / ↗)     | ↑ mantenido + Dash                | [PROTOTIPO] en Dash I — evaluar feel |
| Dash vertical puro (↑ / ↓)         | ↑ o ↓ mantenido + Dash            | Desbloqueo Dash II |
| Dash diagonal inferior (↙ / ↘)     | ↓ + Dash                          | Desbloqueo Dash II |
| Wall Jump                          | Saltar durante Wall Slide         | Habilidad desbloqueable |
| Doble salto                        | Saltar en el aire (release + press) | Habilidad desbloqueable |
| Ataque lateral                     | Atacar sin input vertical         | Kit base |
| Ataque hacia arriba                | ↑ mantenido + Atacar              | Kit base |
| Pogo (ataque hacia abajo)          | ↓ mantenido + Atacar **en el aire** | Kit base |

> Todas las referencias de mecánicas en detalle están en `docs/design/mecanicas/movimiento.md`.

---

## Notas de diseño de controles

- **Dash según facing:** el dash se dispara en la dirección que mira el personaje,
  no según el input horizontal del momento. Estar parado mirando a la derecha
  + dash = dash a la derecha. Esta decisión privilegia la lectura visual clara
  del personaje por sobre la reactividad al stick.
- **Correr como hold, no toggle:** decisión tomada para que el jugador sienta el
  esfuerzo del sprint y pueda modular entre caminar y correr con fluidez.
  El toggle fue descartado por menos agencia moment-to-moment.
- **Buffer de input:** el dash y el salto tienen ventanas de buffer de ~0.1s
  (ver `movimiento.md`). El jugador puede pre-ejecutar la acción antes de que
  sea legal y se dispara en cuanto lo es.
- **Ninguna acción crítica va en un gatillo analógico con lectura progresiva.**
  El gatillo usado para correr se lee como binario (presionado / no presionado),
  con umbral de ~50% del recorrido. [REVISAR CON DEV]
- **Remapeo:** todas las acciones deberían ser remapeables por el jugador.
  [PENDIENTE — definir en `ux.md`]
- **El input vertical es un modificador transversal:** afecta ataque (dirección
  del golpe) y dash (diagonales superiores [PROTOTIPO]). El jugador debería
  descubrir estos modificadores por intuición al mantener direccionales
  mientras ejecuta la acción.
- **Conflictos resueltos:** Atacar en X/Cuadrado (era [PENDIENTE]) mueve el
  Dash a B/Círculo. El patrón queda: saltar y atacar ocupan los botones
  inferiores (más usados), dash a la derecha, interactuar arriba.

---

## Cambios pendientes

- [PENDIENTE] Definir botón para parry (depende de `docs/design/mecanicas/parry.md`)
- [PENDIENTE] Definir si hay botón de habilidad especial / ítem consumible
- [PENDIENTE] Definir controles de menú (navegación inventario, mapa, diálogos)
- [PENDIENTE] Definir controles de accesibilidad (hold-para-correr alternativo tipo toggle opcional para accesibilidad)
- [REVISAR] Confirmar que el Gatillo derecho como correr no choca con la futura mecánica de apuntado si hubiera arma a distancia — depende de lo que defina combate

---

## Historial de cambios

- 2026-04-24 — Creación del documento. Mapeo inicial: mover, saltar, correr, dash,
  interactuar, pausa, mapa. Acciones de combate y parry quedan [PENDIENTE].
  Tabla de inputs compuestos incluye Fast Fall, diagonales de dash y Wall Jump.
- 2026-04-24 — Agregado botón de **Atacar** (X / Cuadrado — J teclado).
  Dash movido a B / Círculo (K teclado) para liberar el botón inferior derecho.
  Agregadas filas de doble salto y ataques direccionales a la tabla de inputs
  compuestos. Parry sigue [PENDIENTE].
