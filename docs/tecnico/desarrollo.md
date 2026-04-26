# Diario de desarrollo — Sesión 1
> Documento escrito por el desarrollador para que el analista derive requerimientos formales.
> Proceso inverso: implementación → descripción → requerimientos.
> Fecha: 2026-04-25

---

## Contexto

Esta sesión implementó el sistema de movimiento base del protagonista en Godot 4.6.
No existía código previo. Se partió de cero con una escena de prueba.
Todo lo implementado vive en `src/codigo-proyecto-g/`.

---

## Archivos creados

| Archivo | Descripción |
|---|---|
| `personajes/protagonista/Protagonista.gd` | Script principal del protagonista |
| `sistemas/dano/ZonaDano.gd` | Zona de daño de prueba para testear el sistema de salud |
| `node_2d.tscn` | Escena de prueba con suelo, plataforma y zona de daño |

---

## Lo que se implementó

### 1. Movimiento horizontal

**Botón:** `A` (izquierda) / `D` (derecha)
**Tipo de input:** input mantenido (held)

El protagonista se mueve horizontalmente con aceleración y desaceleración suaves.
No hay velocidad instantánea: el personaje gana inercia en pocos frames y la pierde
también en pocos frames al soltar el input.

Valores actuales (todos ajustables desde el inspector de Godot):
- Velocidad máxima caminando: 180 px/s
- Aceleración: 1800 px/s²  (llega a velocidad máxima en ~0.1s)
- Desaceleración: 2250 px/s² (frena desde velocidad máxima en ~0.08s)

Comportamiento al cambiar de dirección: el personaje desacelera primero
antes de acelerar en la dirección opuesta (efecto de "peso").

El personaje registra internamente la última dirección que miró
para usarla como referencia en el dash (ver sección 5).

---

### 2. Corrida

**Botón:** `Ctrl izquierdo` (mantenido)
**Tipo de input:** modificador de velocidad (held)

Mientras el jugador mantiene Ctrl presionado junto con A o D,
el techo de velocidad horizontal sube de 180 px/s a 320 px/s.
La aceleración y desaceleración son las mismas que caminando —
solo cambia la velocidad máxima.

Funciona tanto en el suelo como en el aire.

Valores actuales:
- Velocidad máxima corriendo: 320 px/s

---

### 3. Salto

**Botón:** `Barra espaciadora`
**Tipo de input:** presión (just_pressed) para iniciar, held para controlar altura

El salto tiene altura variable según cuánto tiempo se mantenga presionada la barra espaciadora:
- Si el jugador **mantiene** espacio hasta el apex: salto completo (altura máxima)
- Si el jugador **suelta** espacio antes del apex: el salto se recorta, cayendo antes

Mecánica de gravedad diferenciada:
- Al subir y mantener el botón: gravedad base (1600 px/s²)
- Al subir y soltar el botón antes del apex: gravedad multiplicada × 2.0 (caída anticipada)
- Al bajar: gravedad multiplicada × 1.4 (caída ligeramente más pesada que la subida)
- Velocidad de caída: 640 px/s (igual al impulso de salto)

Restricción: solo se puede saltar si el protagonista está sobre el suelo
(o si hay un doble salto disponible, ver sección 4).

Valores actuales:
- Velocidad inicial de salto: 640 px/s (hacia arriba)
- Gravedad base: 1600 px/s²
- Multiplicador de gravedad en caída: 1.4×
- Multiplicador de gravedad al soltar antes del apex: 2.0×

---

### 4. Doble salto

**Botón:** `Barra espaciadora` (segundo press mientras está en el aire)
**Tipo de input:** presión (just_pressed)

Mientras el protagonista está en el aire, puede ejecutar un segundo salto.
El segundo salto tiene exactamente la misma altura y comportamiento que el primero
(misma velocidad inicial, mismo recorte al soltar).

Restricciones:
- Solo 1 salto aéreo disponible por vez
- El crédito de salto aéreo se recupera únicamente al tocar el suelo
- No se puede ejecutar un tercer salto sin tocar el suelo antes

La cantidad de saltos aéreos permitidos es configurable desde el inspector (actualmente: 1).

---

### 5. Dash

**Botón:** `Shift izquierdo`
**Tipo de input:** presión (just_pressed)

El protagonista ejecuta un impulso horizontal breve y rápido.

Dirección del dash:
- Si el jugador tiene `A` o `D` presionado al momento del dash → dashea en esa dirección
- Si el jugador no tiene ninguna dirección presionada → dashea en la última dirección que miró

Comportamiento durante el dash:
- La velocidad horizontal se fija a 533 px/s en la dirección del dash
- La gravedad se suspende completamente (velocidad vertical se pone en 0)
- El protagonista no puede cambiar de dirección ni saltar mientras dura el dash
- El dash dura 0.18 segundos fijos

Restricciones y cooldown:
- Al terminar el dash, hay un cooldown de 0.6s antes de poder volver a dashear
- En el aire: el dash consume el "crédito aéreo". Solo se puede hacer 1 dash en el aire
- El crédito de dash aéreo se recupera al tocar el suelo

Casos borde implementados:
- Dash contra pared: el personaje se detiene al contacto (manejo de física de Godot)
- Dash al borde de plataforma: el personaje cae normalmente después del dash
- No hay iframes (invulnerabilidad) durante el dash en esta versión

Valores actuales:
- Velocidad de dash: 533 px/s (~3 tiles de 32px / 0.18s)
- Duración del dash: 0.18s
- Cooldown entre dashes: 0.6s

---

### 6. Sistema de salud — Vidas

**No tiene botón asociado.** Es un sistema que responde a eventos externos (daño recibido).

El protagonista tiene 3 vidas. Cada vez que recibe daño pierde 1 vida.
Cuando llega a 0 vidas, emite la señal `jugador_murio` (sin comportamiento implementado aún —
se necesita un Game Manager para manejarlo).

Interfaz pública:
- `recibir_daño()` — método que llaman enemigos, trampas u otras zonas de daño
- `get_vidas() -> int` — retorna la cantidad de vidas actuales
- Señal `vida_perdida(vidas_restantes: int)` — emitida cada vez que se pierde una vida
- Señal `jugador_murio` — emitida cuando las vidas llegan a 0

Valores actuales:
- Vidas máximas: 3

---

### 7. Invencibilidad tras recibir daño (parpadeo)

**No tiene botón asociado.** Se activa automáticamente al recibir daño.

Después de recibir un golpe, el protagonista es invencible durante 1.5 segundos.
Durante ese tiempo, el personaje parpadea visualmente para indicar el estado de invencibilidad.
El parpadeo alterna la opacidad del personaje entre 0% y 100% cada 0.08 segundos.

Al terminar el período de invencibilidad, el protagonista vuelve a opacidad 100%
y puede recibir daño nuevamente.

Si el protagonista recibe daño mientras está invencible, el golpe es ignorado completamente.

Implementación: el parpadeo actúa sobre `modulate.a` del nodo raíz del protagonista,
por lo que funciona con cualquier visual hijo (placeholder actual o sprite futuro).

Valores actuales:
- Duración de invencibilidad: 1.5s
- Frecuencia de parpadeo: 0.08s por ciclo

---

## Escena de prueba

La escena `node_2d.tscn` contiene:
- **Protagonista** — en posición central de la escena
- **Suelo** — plataforma larga en la parte inferior (800px de ancho)
- **Plataforma** — plataforma más corta elevada (200px de ancho) para testear el salto
- **ZonaDano** — área roja semitransparente a la derecha del suelo para testear el sistema de salud

La escena es temporal. No representa ninguna zona del juego.

---

## Mapa de inputs de esta sesión

| Acción | Botón | Tipo |
|---|---|---|
| Mover izquierda | `A` | Held |
| Mover derecha | `D` | Held |
| Correr | `Ctrl izquierdo` | Held (modificador) |
| Saltar | `Barra espaciadora` | Just pressed + held para altura |
| Dash | `Shift izquierdo` | Just pressed |

---

## Interacciones entre sistemas implementados

| Combinación | Resultado |
|---|---|
| A/D + Ctrl | Corrida |
| Espacio en suelo | Salto |
| Espacio en aire (1 vez) | Doble salto |
| Espacio (soltar antes del apex) | Recorte de salto (caída anticipada) |
| Shift + A presionado | Dash hacia la izquierda |
| Shift + D presionado | Dash hacia la derecha |
| Shift sin dirección | Dash en la última dirección mirada |
| Shift en aire | Dash aéreo (1 uso, recarga al tocar suelo) |
| Contacto con ZonaDano | Pierde 1 vida + 1.5s de invencibilidad + parpadeo |

---

## Lo que falta / quedó pendiente

- **Coyote time** — documentado en `movimiento.md` como parte del movimiento base, no implementado aún
- **Buffer de input** — documentado en `movimiento.md`, no implementado aún
- **Fast Fall** — documentado en `movimiento.md` como habilidad desbloqueable, no implementado
- **Wall Slide / Wall Jump** — documentados en `movimiento.md`, no implementados
- **Doble salto** — implementado pero no figura en `movimiento.md`. Pendiente de documentar por el diseñador
- **Corrida** — implementada pero no figura en `movimiento.md`. Pendiente de documentar por el diseñador
- **Game Manager** — no existe. La señal `jugador_murio` no tiene receptor aún
- **HUD** — no existe. La señal `vida_perdida` no tiene receptor aún
- **Animaciones** — no hay sprites. El protagonista es un rectángulo placeholder
- **Sonido** — no hay ningún sonido implementado

---

## Notas técnicas para el analista

- Todos los valores numéricos marcados `[REVISAR]` son aproximaciones. El diseñador debe confirmarlos con playtest.
- El dash y el doble salto comparten el "crédito aéreo" de forma independiente: son dos contadores separados.
- El sistema de salud no tiene un estado "muerto" implementado — emite una señal pero el juego no reacciona todavía.
- El parpadeo de invencibilidad funciona sobre cualquier visual hijo, no está acoplado al placeholder actual.
- La escena de prueba (`node_2d.tscn`) no sigue la estructura de zonas del proyecto — es temporal.

---
---

# Diario de desarrollo — Sesión 2
> Fecha: 2026-04-26

---

## Contexto

Esta sesión implementó el sistema de combate base del protagonista y un enemigo placeholder para testearlo.
También se resolvió un bug crítico de posicionamiento de hitbox.

---

## Archivos creados

| Archivo | Descripción |
|---|---|
| `sistemas/combate/SistemaCombate.gd` | Sistema de combate: active frames, recovery, buffer, hitstop y pogo |
| `sistemas/combate/HitboxAtaque.gd` | Hitbox de ataque activable, emite señal al conectar golpe |
| `personajes/enemigos/enemigo_prueba/EnemigoPrueba.gd` | Enemigo placeholder sin lógica |

## Archivos modificados

| Archivo | Qué cambió |
|---|---|
| `personajes/protagonista/Protagonista.gd` | Integración con SistemaCombate: referencia, señal pogo, input de ataque |
| `node_2d.tscn` | HitboxAtaque reubicado como hijo directo de Protagonista; enemigo placeholder agregado |

---

## Lo que se implementó

### 1. Sistema de combate — SistemaCombate.gd

Componente que vive como hijo de `Protagonista` (nodo `Node` plano, sin transform).
Maneja todo el ciclo de vida de un ataque.

**Estados internos:**
```
IDLE → ACTIVE → HITSTOP → RECOVERY → IDLE
                         ↘ (sin golpe) RECOVERY directo desde ACTIVE
```

**Active frames:**  
Ventana donde la hitbox está activa y puede detectar un golpe.
Duración configurable desde el inspector (`duracion_active_frames`, default 0.15s).

**Recovery:**  
Período después del ataque donde el protagonista no puede volver a atacar.
Duración configurable (`duracion_recovery`, default 0.20s).

**Buffer de ataque:**  
Si el jugador presiona atacar durante los últimos `ventana_buffer` segundos del recovery,
el ataque se ejecuta automáticamente al salir del recovery.
Permite encadenar ataques con timing cómodo sin esperar el frame exacto.

**Hitstop:**  
Al conectar un golpe, el juego pausa brevemente al objetivo (`set_physics_process(false)`)
y al protagonista (`en_hitstop = true`, bloqueado en `Protagonista._physics_process`).
Esto crea el "golpe con peso" característico del metroidvania.
Duración diferenciada: hitstop normal (0.05s) vs hitstop de pogo (0.08s).

**Dirección del ataque:**  
- Arriba (↑ + atacar): hitbox sobre el protagonista
- Pogo (↓ + atacar, en el aire): hitbox debajo del protagonista
- Lateral (cualquier otro caso): hitbox al lado según `get_facing()`

**Pogo:**  
Ataque hacia abajo en el aire. Si conecta con un objetivo que no tiene la propiedad
`rebotable = false`, emite la señal `pogo_rebotado` y aplica un impulso vertical
hacia arriba al protagonista (`impulso_pogo`, default 480 px/s).
La propiedad `rebotable` permite que ciertos objetivos (jefes, objetos específicos)
no generen rebote sin necesidad de cambiar el sistema.

---

### 2. Hitbox de ataque — HitboxAtaque.gd

`Area2D` activable. Cuando está activa y detecta un `CharacterBody2D` (o cualquier physics body),
emite la señal `golpe_conectado(objetivo)`.

El nodo `propietario` (asignado por `SistemaCombate` en `_ready`) se excluye de la detección
para que el protagonista no se golpee a sí mismo.

La forma (`RectangleShape2D`) se reconfigura en cada ataque según la dirección.

**Posición en la escena:**  
`HitboxAtaque` es hijo directo de `Protagonista` (ver bug resuelto abajo).
`SistemaCombate` lo referencia con `$"../HitboxAtaque"`.

---

### 3. Botón de ataque

| Acción | Botón |
|---|---|
| Atacar | `J` (click izquierdo o según configuración) |

Input mapeado como `"atacar"` en `project.godot`.
El input se procesa en `Protagonista._physics_process` y se delega a `SistemaCombate.intentar_atacar()`.
Durante el dash o el hitstop, el input de ataque es ignorado.

---

### 4. Enemigo placeholder — EnemigoPrueba.gd

`CharacterBody2D` estático sin lógica de movimiento ni IA.
Tiene `recibir_daño()` como stub vacío para que `SistemaCombate` lo detecte como objetivo válido.
Pertenece al grupo `"enemigo"` (definido en la escena).
Tiene la propiedad `rebotable` ausente → el pogo produce rebote por default.

Posición en la escena de prueba: `(620, 460)`.

---

## Bug resuelto: hitbox no seguía al protagonista

**Síntoma:** La hitbox aparecía en posiciones incorrectas, desplazada respecto al protagonista.
Inicialmente tenía un offset hardcodeado `(259, 317)` en el CollisionShape2D (residuo del editor).
Al eliminar ese offset, la hitbox quedaba fija en `(0, 0)` global (esquina superior izquierda del mundo).

**Causa raíz:**  
En Godot 4, un `CanvasItem` (como `Area2D`) hereda su transform del padre solo si ese padre
también es un `CanvasItem`. Si el padre es un `Node` plano (sin transform), el hijo usa su
propio transform local como transform global — efectivamente queda anclado al origen del mundo.

`SistemaCombate` es un `Node` plano (intencional, no tiene representación visual).
`HitboxAtaque` era hijo de `SistemaCombate`, por lo que no heredaba la posición del `Protagonista`.

**Solución:**  
`HitboxAtaque` se movió para ser hijo directo de `Protagonista` (que sí es `Node2D`-derivado).
`SistemaCombate` lo referencia con `$"../HitboxAtaque"` (hermano en el árbol).

---

## Interacciones nuevas entre sistemas

| Combinación | Resultado |
|---|---|
| `J` en suelo o aire (sin dirección vertical) | Ataque lateral en la dirección que mira |
| `↑` + `J` | Ataque hacia arriba |
| `↓` + `J` (en el aire) | Pogo (ataque hacia abajo) |
| Pogo conecta en objetivo rebotable | Hitstop + impulso vertical hacia arriba |
| `J` durante recovery (últimos 0.10s) | Buffer: ataque ejecutado al salir de recovery |
| Golpe conectado | Hitstop en protagonista y objetivo |

---

## Lo que falta / quedó pendiente

- **Pogo**: la mecánica existe en `SistemaCombate` pero falta testear el impulso y valores.
- **Animaciones de ataque**: no hay. El protagonista no tiene feedback visual del ataque salvo el hitbox en debug.
- **Sonido de ataque / impacto**: no implementado.
- **Daño numérico**: `recibir_daño()` en el protagonista no recibe un valor, siempre resta 1 vida. Diseñar si habrá cantidades de daño variables.
- **Muerte del enemigo**: `EnemigoPrueba.recibir_daño()` es un stub vacío. No hay lógica de muerte ni feedback visual.
- **Enemigo real**: `EnemigoPrueba` es un placeholder sin IA. La implementación de enemigos reales espera documentación del bestiary.

---

## Notas técnicas para el analista

- El sistema de combate está desacoplado: `SistemaCombate` solo conoce a `Protagonista` (su padre) y a `HitboxAtaque` (su hermano). No referencia ningún enemigo directamente.
- La propiedad `rebotable` en los enemigos es opt-out: ausencia = rebota. Si un enemigo específico no debe generar rebote, agrega `var rebotable: bool = false` a su script.
- El hitstop llama a `objetivo.set_physics_process(false/true)` directamente. Esto funciona para `CharacterBody2D` pero puede requerir ajuste si el objetivo es `AnimationPlayer`-driven o tiene lógica fuera de `_physics_process`.
- `en_hitstop` es una variable pública de `SistemaCombate`. `Protagonista` la consulta cada frame para bloquear su propio procesamiento durante el hitstop.
