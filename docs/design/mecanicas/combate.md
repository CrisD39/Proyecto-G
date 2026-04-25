# Combate

## Descripción

Sistema de combate melee centrado en el **ataque direccional** con arma blanca.
El jugador ejecuta un golpe cuya dirección depende del input vertical en el
momento del ataque: hacia los lados (según facing), hacia arriba (con ↑) o
hacia abajo (con ↓ en el aire). Un solo botón de ataque. La decisión táctica
no está en combinaciones de botones sino en **cuándo, hacia dónde y mientras
se hace qué movimiento** el jugador golpea.

El combate se integra con el movimiento: el mismo golpe puede esquivar, rebotar,
posicionar o cerrar distancia según el estado de movimiento en que se ejecute.

---

## Por qué existe

El pilar "Parry como lectura" del GDD y el pilar "Caza informada" exigen un
combate donde el jugador lea al enemigo, no un combate de mashing de botones.
El ataque direccional simple fuerza a que cada golpe sea una decisión consciente —
la única riqueza expresiva es la dirección y el momento, así que el jugador
tiene que elegir ambos bien.

Un solo botón mantiene el combate legible mientras se sumen capas encima
(parry, variedad de armas, enemigos con patrones particulares). La profundidad
viene de las interacciones, no del árbol de combos.

---

## Armas de Facundo

Facundo porta varias armas a lo largo del juego. La **principal y default**
es el **facón** — cuchillo largo del gaucho, de alcance corto, rápido y preciso.
Es el arma con la que empieza y con la que ejecuta el golpe básico documentado
en este archivo.

Otras armas (secundarias, desbloqueables, situacionales) se documentarán en
archivos propios bajo `docs/design/mecanicas/armas/[nombre-arma].md` cuando
se definan. Este documento cubre únicamente el sistema de combate base con facón.

> **Nota al escritor:** la ficha del personaje en `docs/personajes/protagonista.md`
> debería reflejar el elenco de armas que Facundo porta. La caracterización
> narrativa del facón y de las demás armas pertenece a ese documento.

---

## Input del ataque

**Un solo botón de ataque** [ver `controles.md`]. El input vertical del stick
direccional actúa como modificador de dirección:

| Input vertical | Dirección del golpe | Nombre interno |
|---|---|---|
| Sin input (o input horizontal puro) | Horizontal según **facing** | Ataque lateral |
| ↑ mantenido | Hacia arriba | Ataque alto |
| ↓ mantenido, **en el aire** | Hacia abajo | Pogo |
| ↓ mantenido, **en tierra** | Horizontal (el ↓ en tierra no cambia nada) | Ataque lateral |

**Regla de facing:** como en el dash, los ataques laterales van en la dirección
que mira el personaje, independientemente del input horizontal actual.
Esto mantiene la lectura visual consistente entre movimiento y combate.

---

## Ataque lateral (básico)

**Descripción:** Tajo horizontal con el facón en la dirección del facing.
Es el ataque por default y el que más se usa.

**Comportamiento:**
- Input: botón de ataque sin input vertical.
- Dirección: facing del personaje.
- Duración del golpe (active frames): ~0.15s [REVISAR]
- Recovery (tiempo antes de poder ejecutar el siguiente input de ataque): ~0.2s [REVISAR]
- El personaje puede seguir moviéndose mientras ataca: sí, pero a velocidad reducida si está en el suelo [REVISAR — ver "Ataque en movimiento" más abajo].
- En el aire: conserva momentum horizontal sin penalización.

**Feel:** el golpe debe sentirse corto, limpio, quirúrgico. Un facón no es una
espada larga — es un cuchillo grande usado con eficiencia. Sin floritura.
El sonido y el hitstop (la micro-pausa al conectar) hacen la mayor parte del
trabajo de impacto. [REVISAR CON AUDIO Y ARTE]

**Parámetros [PENDIENTE — ajustar en playtest]:**
- Alcance lateral: ~1.5 tiles [REVISAR]
- Daño base: [PENDIENTE — depende de vida de enemigos, aún no definida]
- Hitstop al conectar: ~0.05s [REVISAR]

**Casos borde:**
- **Atacar sin facing definido (primer frame del juego):** el personaje mira
  por default hacia donde estaba el último input horizontal; si no hubo, hacia
  la derecha. [REVISAR con el dev cuando implemente el estado inicial.]
- **Spam del botón:** el ataque no se puede repetir hasta pasar el recovery.
  Inputs extra dentro del recovery se bufferean (ventana de ~0.1s al final
  del recovery) y se ejecutan automáticamente al salir.
- **Atacar + girar:** si el jugador cambia de facing durante el recovery,
  el siguiente ataque sale hacia la nueva dirección.

---

## Ataque hacia arriba

**Descripción:** Estocada del facón hacia arriba. Útil contra enemigos voladores,
enemigos en plataformas superiores, o techos con elementos interactivos.

**Comportamiento:**
- Input: botón de ataque + ↑ mantenido.
- Dirección: vertical hacia arriba.
- Duración y recovery: equivalentes al ataque lateral [REVISAR — puede tener
  recovery ligeramente mayor por el riesgo de descubrir el flanco].
- Se puede ejecutar en tierra y en el aire.
- En tierra: el personaje permanece quieto durante el golpe.
- En el aire: conserva momentum horizontal y vertical.

**Feel:** movimiento ascendente claro. El brazo se extiende hacia arriba y
marca un arco corto. Debería ser obvio desde la animación que el personaje
"está dejando el pecho descubierto" — es un golpe que gana espacio arriba
a cambio de protección abajo. [REVISAR CON ARTE]

**Parámetros:**
- Alcance hacia arriba: ~1.5 tiles [REVISAR]
- Ángulo de cobertura: ligeramente abierto hacia los lados superiores (no un
  rayo vertical puro) — permite errar por medio tile y que igual impacte
  al enemigo aéreo. [REVISAR]

**Casos borde:**
- **Ataque ↑ con techo bajo inmediato:** el golpe se ejecuta igual, pero el
  hitbox se corta visualmente al nivel del techo [REVISAR CON DEV].
- **Ataque ↑ en salto:** conserva la trayectoria del salto. El input ↑ para
  el ataque no extiende el salto por sí mismo (ver interacción con hold
  del salto en `movimiento.md`).

---

## Pogo (ataque hacia abajo con rebote)

**Descripción:** Estocada del facón hacia abajo, ejecutada únicamente en el aire.
Al conectar limpio con un objetivo rebotable, el personaje **rebota** hacia arriba
y recupera recursos aéreos.

**Por qué existe:** Es la capa más expresiva del combate + movimiento. Convierte
a los enemigos en plataformas temporales, abre rutas verticales nuevas y
recompensa al jugador que planifica cadenas de ataques. Referencia estándar:
pogo de Hollow Knight.

**Comportamiento:**
- **Input:** botón de ataque + ↓ mantenido, **en el aire**. En tierra el ↓ no
  tiene efecto (el golpe sale lateral).
- **Dirección:** vertical hacia abajo.
- **Al conectar con objetivo rebotable:**
  1. La velocidad vertical del personaje se reemplaza por un impulso hacia arriba
     (no se suma — funciona igual cayendo que subiendo).
  2. Se **recuperan** el dash aéreo y el doble salto (si están desbloqueados)
     [REVISAR — puede ser muy generoso, evaluar en playtest si conviene recuperar
     solo uno de los dos o ninguno].
  3. Se gatilla feedback visual y sonoro de impacto [REVISAR CON ARTE Y AUDIO].
- **Al no conectar o chocar contra objetivo no-rebotable:**
  - El ataque se ejecuta igual (hitbox activo, puede dañar sin rebotar).
  - El personaje **continúa cayendo** con su velocidad vertical previa.
  - No hay impulso hacia arriba.
- **Al fallar el hitbox completo:**
  - El ataque se ejecuta en el vacío. Recovery normal, sin rebote.

**Feel:** el rebote debe sentirse **firme**. Hay un hitstop levemente más largo
que en el ataque normal, y luego el impulso hacia arriba es nítido. El jugador
debe percibir claramente que "algo pasó" — el pogo es de las mecánicas más
expresivas del juego y merece peso audiovisual. [REVISAR CON ARTE Y AUDIO]

**Parámetros:**
- Alcance hacia abajo: ~1.5 tiles [REVISAR]
- Impulso vertical al rebotar: equivalente aproximado al salto base con hold
  breve (~2.5 tiles de altura sumada desde el punto de contacto) [REVISAR]
- Hitstop al rebotar: ~0.08s [REVISAR — un poco mayor que ataques normales para marcar el impacto]

---

## Qué rebota y qué no (categoría "rebotable")

**Regla default:** todas las entidades con hurtbox (enemigos, proyectiles que
admitan contacto directo, objetos del escenario interactivos como faroles o
plantas) son **rebotables por default**.

**Excepción explícita — categoría "no-rebotable":** algunas entidades llevan
la propiedad `no-rebotable`. Cuando el pogo impacta una entidad no-rebotable,
el ataque se registra (puede causar daño si aplica), pero **no hay rebote**.
El personaje sigue cayendo.

**Criterios de diseño para marcar algo como no-rebotable:**
- **Jefes o enemigos de encuentro único:** no queremos que el pogo trivialice
  el encuentro al permitir que el jugador se quede sobre el jefe toda la pelea.
- **Enemigos blindados en la parte superior:** si narrativamente tiene sentido
  que el jugador no pueda "pisarles" la cabeza (enemigo con pinchos arriba,
  criatura con coraza).
- **Objetos narrativos o frágiles:** si un objeto no debe ser una plataforma
  infinita (p.ej. algo que se rompe al primer golpe).

Estas decisiones se toman **caso por caso** durante el diseño de cada enemigo
o entidad. La lista centralizada de enemigos con sus propiedades vive en
`docs/personajes/bestiary/` y se reflejará en cada ficha del enemigo.

---

## Casos borde del sistema de combate

- **Pogo + Fast Fall:** compatible. El ↓ ya estaba presionado por fast fall;
  presionar ataque ejecuta el pogo sin interrumpir la caída rápida. Si conecta
  rebotable, el rebote cancela el fast fall.
- **Pogo + Doble salto disponible pero no usado:** al rebotar, el doble salto
  se recupera (si se había usado) pero no se consume. El jugador puede
  encadenar pogo + salto aéreo + dash, etc.
- **Ataque durante Dash:** [PENDIENTE — definir si se puede cancelar el dash
  atacando, o si el ataque espera al fin del dash, o si se ignora. Afecta el
  feel mucho.]
- **Ataque durante Wall Slide:** [PENDIENTE — ¿se puede atacar desde la pared?
  Si sí, hacia qué dirección?]
- **Ataque durante Wall Jump (ventana de control bloqueada):** [PENDIENTE —
  decidir si el botón de ataque rompe el control bloqueado o queda en cola.]
- **Ataque justo al aterrizar un salto con input de ataque mantenido:** el
  ataque sale con la dirección del input vertical **al momento de ejecutarse**,
  no al momento de presionarse. Esto evita que un jugador que aterrizó durante
  el input ↓ ejecute un pogo fallido en el piso.

---

## Ataque durante la carrera [PENDIENTE]

> Esta sección queda pendiente hasta la próxima iteración con el usuario.
> La interacción entre correr y atacar no está definida: ¿el ataque frena al
> personaje, conserva velocidad, extiende alcance, cambia animación?
> Documentar en cuanto haya decisión.

**Preguntas abiertas:**
- ¿Mantiene velocidad de correr durante el golpe o desacelera a caminar?
- ¿El alcance o el daño cambian por la velocidad?
- ¿Hay una animación específica de "tajo en carrera" o es la misma animación?
- ¿El freno post-ataque es mayor viniendo de correr?

---

## Parámetros (tabla resumen)

| Parámetro | Valor | Estado |
|---|---|---|
| Alcance del ataque lateral | ~1.5 tiles | [REVISAR] |
| Alcance del ataque hacia arriba | ~1.5 tiles | [REVISAR] |
| Alcance del pogo (hacia abajo) | ~1.5 tiles | [REVISAR] |
| Duración de active frames | ~0.15s | [REVISAR] |
| Recovery post-ataque | ~0.2s | [REVISAR] |
| Hitstop al conectar (normal) | ~0.05s | [REVISAR] |
| Hitstop al rebotar (pogo) | ~0.08s | [REVISAR] |
| Ventana de buffer de ataque | ~0.1s | [REVISAR] |
| Impulso vertical al rebotar | ~2.5 tiles | [REVISAR] |
| Daño base del facón | [PENDIENTE] | — |

> Los valores son aproximaciones de diseño. Se ajustan con playtest y con la
> tabla de vida/daño de enemigos (pendiente).

---

## Decisiones pendientes (resumen para futuras iteraciones)

- [PENDIENTE] Ataque durante carrera — próxima iteración.
- [PENDIENTE] Interacción ataque + dash (¿cancelable?).
- [PENDIENTE] Interacción ataque + wall slide / wall jump.
- [PENDIENTE] Daño del facón y tabla de vida de enemigos.
- [PENDIENTE] Sistema de parry — archivo propio: `docs/design/mecanicas/parry.md`.
- [PENDIENTE] Armas secundarias de Facundo — archivos propios por arma.
- [REVISAR] Pogo recupera dash aéreo y doble salto: evaluar balance en playtest.

---

## Estado

- [x] Definida parcialmente (ataque direccional base + pogo). Pendiente: ataque en carrera, interacción con otras mecánicas de movimiento, parámetros de daño.
- [ ] Implementada
- [ ] Testeada y ajustada

---

## Historial de cambios

- 2026-04-24 — Creación del documento. Definido sistema de ataque direccional
  con un solo botón (1 arma: facón). Cuatro direcciones: lateral según facing,
  arriba con ↑, abajo con ↓ en el aire (pogo). Pogo rebota por default sobre
  todo objetivo salvo los marcados "no-rebotable". Recupera dash aéreo y doble
  salto al conectar [REVISAR]. Sección de ataque en carrera queda pendiente.
