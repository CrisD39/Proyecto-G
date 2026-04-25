# Parry

## Descripción

El jugador ejecuta un parry en el instante exacto en que un ataque enemigo llega.
La ventana es precisa, la penalización por errarla es real, y la recompensa por
acertar es significativa: el enemigo queda expuesto para recibir golpes.

---

## Por qué existe

Es el corazón del pilar "Parry como lectura" del GDD.
Sin parry, el combate es atacar y aguantar. Con parry, cada intercambio tiene
una lectura activa: el jugador observa el telegraph del enemigo, decide cuándo
actuar, y gana o pierde según lo que leyó.

Recompensa la atención al patrón del enemigo, no la velocidad de reacción.
El jugador que estudia cómo ataca una criatura puede parear sistemáticamente.
El jugador que spamea el botón muere.

---

## Comportamiento detallado

### Ejecución normal

1. El enemigo telegrafía su ataque con una animación de wind-up.
2. El jugador presiona el botón de parry durante ese wind-up.
3. La ventana efectiva del parry se activa cuando el **ataque llega** (frame de
   impacto), no cuando el enemigo empieza el wind-up.
4. Si el input del jugador cae dentro de la ventana: **parry exitoso**.
5. Si el input cae fuera de la ventana: ver secciones "Demasiado temprano" y
   "Demasiado tarde".

### Parry exitoso

- El daño se **cancela completamente**. No hay chip damage, no hay reducción
  parcial. Todo o nada.
- Facundo ejecuta un **micro-paso hacia el enemigo** — pequeño, de cazador
  que absorbe el golpe y avanza, no de guerrero que retrocede. Esto refuerza
  el carácter del personaje y da al jugador feedback visual claro de que el
  parry activó.
- El enemigo entra en **estado de stagger**: animación de vulnerabilidad,
  sin poder atacar durante la duración del estado.
- El jugador tiene una ventana para castigar: **1 a 2 golpes** cómodos antes
  de que el enemigo se recupere.
- **Parry perfecto** (ver sección abajo): los enemigos soltaron más monedas
  al ser eliminados tras un parry perfecto. [REVISAR con economía cuando
  `docs/design/economia.md` exista — la mecánica de monedas es [PENDIENTE]]

### Demasiado temprano (falso parry)

Si el jugador ejecuta el parry **antes** de que la ventana esté activa:
- La animación de parry se ejecuta de todas formas.
- Facundo queda **brevemente expuesto**: la animación lo compromete durante
  ~0.3s y no puede cancelarla ni ejecutar otra acción.
- Si el ataque llega durante esos ~0.3s, impacta con **daño completo**.
- El jugador aprendió a no apurarse.

### Demasiado tarde

Si el jugador ejecuta el parry **después** de que la ventana cerró:
- El ataque ya conectó y causó daño completo antes de que el input sea procesado.
- La animación de parry no se ejecuta (el input llega cuando ya no aplica).

---

## Parry perfecto

Dentro de la ventana completa existe una **sub-ventana más ajustada** en el
momento más cercano al impacto: el parry perfecto.

- La ventana completa de parry: ~0.15s antes del frame de impacto [REVISAR]
- La ventana de parry perfecto: ~0.05s antes del frame de impacto [REVISAR]
  (último tercio de la ventana completa, aproximadamente)

**Efecto adicional del parry perfecto:**
Al eliminar un enemigo en el que se ejecutó un parry perfecto antes del golpe
de gracia, ese enemigo suelta una cantidad **mayor de monedas** que la normal.
[PENDIENTE — definir multiplicador o cantidad extra cuando exista `economia.md`]

El parry perfecto no cambia el combate en sí (el stagger es igual, los golpes
de castigo son los mismos), pero recompensa al jugador que leyó el ataque con
precisión máxima. La diferencia entre "acertar el parry" y "acertar el parry
perfecto" es la misma diferencia que entre sobrevivir y dominar.

---

## Feel

El parry debe sentirse como un momento cinematográfico pequeño. El ataque viene,
el mundo se detiene un instante por el hitstop, y el jugador está exactamente
donde tenía que estar.

El micro-paso de Facundo es clave: **entra al golpe, no lo esquiva**.
Es un personaje que aprendió a moverse en este mundo. El parry no es miedo —
es lectura.

El stagger del enemigo debería tener feedback audiovisual claro: el enemigo
tambalea, abre la guardia, hay un sonido de impacto o desorientación.
El jugador sabe que tiene una ventana sin que el juego se lo diga con texto.
[REVISAR CON ARTE Y AUDIO]

---

## Casos borde

- **Parry en el aire:** permitido. El jugador puede parear ataques mientras
  está en el aire. El micro-paso de Facundo se ajusta según el estado aéreo
  [REVISAR CON DEV — puede omitirse el paso en el aire, manteniendo solo
  la cancelación de daño y el stagger].
- **Parry durante carrera:** el parry interrumpe el sprint en el momento del
  micro-paso. Al salir del parry, si el jugador mantiene el hold de correr y
  tiene input horizontal, vuelve a correr.
- **Ataque no-parryable:** algunos ataques están marcados con la propiedad
  `no-parryable`. Ver sección correspondiente.
- **Parry seguido de parry:** si el enemigo ataca de nuevo durante el stagger,
  el jugador puede volver a parear el segundo ataque. El stagger **no se
  extiende** — el segundo parry inicia un stagger nuevo. [REVISAR — puede
  ser explotable si el enemigo tiene ataques rápidos consecutivos]
- **Parry + pogo:** si el enemigo está en posición rebotable y el jugador
  ejecutó un parry exitoso, puede optar por un pogo como golpe de castigo.
  El rebote aplica normalmente.
- **Spam del botón de parry:** si el jugador mantiene el botón presionado en
  lugar de tapearlo, el parry solo se registra en el primer frame del press.
  Spammear el botón produce múltiples animaciones de falso parry consecutivas
  y expone al jugador repetidamente. [REVISAR CON DEV — confirmar que el
  input se lee como tap y no como hold continuo]

---

## Ataques no-parryables

Algunos ataques están marcados con la propiedad `no-parryable` en el diseño
del enemigo o del ataque. Al intentar parear un ataque no-parryable:

- Si el jugador ejecuta el parry dentro de la ventana: la animación de parry
  se ejecuta pero **no cancela el daño**. Facundo recibe el golpe completo.
- Si ejecutó el parry demasiado temprano: la penalización de falso parry
  aplica normalmente, y el ataque también conecta.

**Criterios de diseño para marcar un ataque como no-parryable:**
- Ataques de área (impacto amplio, no tiene sentido parear con un cuchillo)
- Ataques de jefes con propiedades especiales (aplastamiento, embestida cargada)
- Ataques de criatura blindada frontalmente donde el parry "no tiene dónde
  apoyarse" narrativamente
- Ataques que el diseño del encuentro requiere que el jugador esquive en
  lugar de absorber

Estas decisiones se toman por enemigo en `docs/personajes/bestiary/[nombre].md`.

---

## Parámetros de diseño

| Parámetro | Valor | Estado |
|---|---|---|
| Ventana completa de parry | ~0.15s antes del frame de impacto | [REVISAR] |
| Ventana de parry perfecto | ~0.05s antes del frame de impacto | [REVISAR] |
| Duración del stagger del enemigo | ~0.7s | [REVISAR] |
| Duración de exposición por falso parry | ~0.3s | [REVISAR] |
| Hitstop al ejecutar parry exitoso | ~0.06s | [REVISAR] |
| Multiplicador de monedas por parry perfecto | [PENDIENTE — ver economia.md] | — |
| Botón de parry | [PENDIENTE — ver controles.md] | — |

---

## Estado

- [x] Definida, pendiente de implementación
- [ ] Implementada
- [ ] Testeada y ajustada

---

## Historial de cambios

- 2026-04-25 — Creación del documento. Parry de ventana precisa con penalización
  por falso parry (exposición breve). Todo o nada: daño completo si falla,
  cancelación total si acierta. Stagger del enemigo como recompensa de castigo.
  Sub-ventana de parry perfecto con bonus de monedas al eliminar al enemigo
  [PENDIENTE hasta que exista economia.md]. Propiedad no-parryable para ataques
  específicos, definida por enemigo en el bestiary.
