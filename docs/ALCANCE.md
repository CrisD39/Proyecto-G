# Alcance del proyecto — Estado actual

> Este documento define qué está en desarrollo activo, qué está diferido y
> cuándo se considera cerrada la fase actual.
> Se actualiza cuando el foco del proyecto cambia.

---

## Fase actual: Demo de combate

**Objetivo:** Tener un prototipo jugable donde el movimiento base y el combate
estén tan pulidos que se sientan exactamente como deben sentirse en el juego final.
Un solo enemigo. Sin historia, sin progresión, sin zonas múltiples.

La pregunta que cierra esta fase es: **¿El combate se siente como lo que tengo
en mente?** Cuando la respuesta sea sí, se abre la siguiente fase.

---

## Qué está en scope ahora

### Movimiento base (completo)
Todo lo definido en `docs/design/mecanicas/movimiento.md` bajo la sección
**Movimiento base**. Requerimientos formalizados en `docs/requerimientos/movimiento.md`
(RF-MOV-001 a RF-MOV-012).

| Mecánica | Estado |
|---|---|
| Caminar | En scope |
| Correr | En scope |
| Cambio de dirección | En scope |
| Salto variable (tap / hold / jump cut) | En scope |
| Coyote time | En scope |
| Buffer de input | En scope |
| Control aéreo | En scope |

### Combate base (completo)
Todo lo definido en `docs/design/mecanicas/combate.md` que no esté marcado
como [PENDIENTE]. Requerimientos en `docs/requerimientos/combate.md`.

| Mecánica | Estado |
|---|---|
| Ataque lateral (facón, según facing) | En scope |
| Ataque hacia arriba (↑ + ataque) | En scope |
| Pogo — ataque hacia abajo en el aire, con rebote | En scope |
| Sistema rebotable / no-rebotable | En scope |
| Hitstop al conectar | En scope |
| Buffer de ataque | En scope |

### Un enemigo de prueba
Un único enemigo con comportamiento suficientemente interesante para validar
el sistema de combate. Qué enemigo y cuál es su comportamiento es **[PENDIENTE
— definir con el diseñador antes de que el desarrollador lo implemente]**.

El enemigo de demo no necesita ser el enemigo "final" del juego. Su función
es ser el sparring del sistema de combate.

---

## Qué está fuera de scope (diferido)

Estas cosas existen como documentación o como ideas, pero **nadie las implementa
ni se generan requerimientos para ellas** hasta que se cierre la fase actual.

| Sistema / Feature | Diferido hasta |
|---|---|
| Habilidades de movimiento desbloqueables (fast fall, doble salto, dash, wall slide, wall jump) | Después de la demo de combate |
| Sistema de parry | Después de la demo de combate |
| Caza informada | Después de la demo de combate |
| Más enemigos / criaturas | Después de la demo de combate |
| Progresión y desbloqueos | Después de la demo de combate |
| Mundo conectado y zonas múltiples | Después de la demo de combate |
| NPCs y diálogos | Después de la demo de combate |
| Historia y lore jugable | Después de la demo de combate |
| Sistema de guardado | Después de la demo de combate |
| Inventario y recursos | Después de la demo de combate |
| Mapa | Después de la demo de combate |
| Armas secundarias | Después de la demo de combate |
| Ataque en carrera | Después de la demo de combate |
| Interacción ataque + dash | Después de la demo de combate |
| Interacción ataque + wall slide / wall jump | Después de la demo de combate |

---

## Criterio de cierre de esta fase

La demo de combate se considera cerrada cuando:

- [ ] El movimiento base se siente con el peso y la responsividad esperados
      (referencia: Hollow Knight — preciso, sin latencia, sin imprecisión).
- [ ] El salto variable (tap / hold / jump cut) se comporta exactamente como
      está descrito en `docs/design/mecanicas/movimiento.md`.
- [ ] El ataque lateral, el ataque alto y el pogo están implementados y se
      sienten correctos en mano.
- [ ] El pogo rebota de forma clara y satisfactoria sobre el enemigo de prueba.
- [ ] El único enemigo tiene un comportamiento que ejercita el sistema de combate.
- [ ] **El usuario confirma: "esto es lo que tenía en mente."**

---

## Documentos activos en esta fase

| Documento | Rol |
|---|---|
| `docs/design/mecanicas/movimiento.md` | Fuente de diseño — movimiento |
| `docs/design/mecanicas/combate.md` | Fuente de diseño — combate |
| `docs/design/controles.md` | Mapeo de inputs |
| `docs/requerimientos/movimiento.md` | Requerimientos formalizados — movimiento base |
| `docs/requerimientos/combate.md` | Requerimientos formalizados — combate base |
| `docs/personajes/bestiary/[enemigo-demo].md` | **[PENDIENTE — definir]** |

---

## Documentos que existen pero no se tocan ahora

| Documento | Razón |
|---|---|
| `docs/mundo/world-bible.md` | Diferido a siguiente fase |
| `docs/personajes/protagonista.md` | Diferido (salvo nombre si se necesita para el build) |
| `docs/design/GDD.md` — secciones de progresión | Diferido |
| Cualquier archivo en `docs/mundo/zonas/` | Diferido |

---

## Historial de cambios

- 2026-04-25 — Creación del documento. Fase actual: Demo de combate.
  Scope: movimiento base completo + combate base completo + un enemigo de prueba.
  Todo lo demás diferido.
