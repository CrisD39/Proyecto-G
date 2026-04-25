# GDD — Proyecto G
> Documento raíz de diseño. No reemplazar — solo extender o corregir con control.

---

## Visión

Metroidvania 2D de terror atmosférico ambientado en el folclore argentino.
Un mundo continuo, oscuro y vivo donde el movimiento es supervivencia.

**Referencia estructural:** Hollow Knight  
**Referencia visual:** Blasphemous  
**Referencia de conocimiento:** The Witcher 3

---

## Pilares de diseño

| Pilar | Resumen |
|---|---|
| Movimiento como lenguaje | Preciso, expresivo, con profundidad. Moverse bien es en sí mismo satisfactorio. |
| Parry como lectura | Recompensa la atención al enemigo, no los reflejos puros. |
| Caza informada | El conocimiento del folclore es información de combate. |
| Terror atmosférico | La amenaza se sugiere antes de mostrarse. Sin gore, sin jump scares. |
| Mundo continuo | Sin niveles. Sin pantallas de carga entre zonas contiguas. |
| Folclore como fuente primaria | Cada criatura, lugar y fragmento de lore tiene raíz en la tradición argentina. |

---

## Mecánicas core

| Mecánica | Archivo | Estado |
|---|---|---|
| Movimiento | docs/design/mecanicas/movimiento.md | 🔄 Definida, pendiente de implementación |
| Combate | docs/design/mecanicas/combate.md | 🔄 Definida parcialmente (ataque direccional + pogo). Ataque en carrera [PENDIENTE] |
| Parry | docs/design/mecanicas/parry.md | ⬜ Pendiente |
| Caza informada | docs/design/mecanicas/caza.md | ⬜ Pendiente |
| Mapa | docs/design/mecanicas/mapa.md | ⬜ Pendiente |
| Muerte y checkpoint | docs/design/mecanicas/muerte.md | ⬜ Pendiente |
| Interacción | docs/design/mecanicas/interaccion.md | ⬜ Pendiente |

---

## Sistema de progresión (visión general)

El jugador empieza con un kit de movimiento mínimo y va desbloqueando habilidades
explorando el mundo. Cada habilidad nueva abre zonas antes inaccesibles.

Las habilidades de movimiento son el eje principal de la progresión.
Ver: docs/design/progresion.md [PENDIENTE]

---

## Documentos relacionados

- `docs/design/controles.md` — mapeo de inputs
- `docs/design/progresion.md` — curva de desbloqueo de habilidades [PENDIENTE]
- `docs/design/economia.md` — recursos del juego [PENDIENTE]
- `docs/design/ux.md` — interfaz y feedback [PENDIENTE]
- `docs/design/camaras.md` — comportamiento de cámara [PENDIENTE]

---

## Historial de cambios

- 2026-04-24 — Creación del GDD base. Movimiento definido como primera mecánica.
- 2026-04-24 — Extensión del movimiento base con **correr** (hold, ~260 px/s).
  Dash I aclarado como disparado por facing; se adelantan las diagonales
  superiores (↖, ↗) al kit de Dash I como [PROTOTIPO — evaluar feel].
  Creado `docs/design/controles.md` con el mapeo inicial de inputs.
- 2026-04-24 — Reescrita la sección **Salto** como controlable por hold.
  Agregado **Doble salto** como habilidad desbloqueable.
- 2026-04-24 — Creado `docs/design/mecanicas/combate.md` con el sistema de
  ataque direccional: un solo botón, arma principal **facón**, cuatro direcciones
  (lateral según facing / ↑ / pogo ↓ en aire). Pogo rebota por default, categoría
  "no-rebotable" para jefes y entidades especiales. Ataque durante carrera
  queda [PENDIENTE] para la próxima iteración. Combate pasa a 🔄 Definida parcialmente.
