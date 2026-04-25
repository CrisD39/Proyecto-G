# Movimiento

## Descripción

El sistema de movimiento es el núcleo del juego. El jugador tiene control total
y preciso de su personaje tanto en tierra como en el aire. Moverse bien se aprende,
pero nunca se siente injusto — el mundo es peligroso, no los controles.

---

## Por qué existe

El movimiento es el primer lenguaje entre el jugador y el juego. En un metroidvania,
el jugador pasa cientos de horas atravesando el mundo: si el movimiento falla,
todo lo demás falla. La referencia es Hollow Knight: cada acción responde exactamente
como el jugador espera, sin latencia, sin imprecisión.

Además, el sistema de habilidades de movimiento desbloqueables es el eje
de la progresión del juego — cada habilidad nueva abre zonas antes inaccesibles
y expande el vocabulario del jugador.

---

## Arquitectura del sistema

El movimiento se divide en dos capas:

- **Movimiento base** — disponible desde el inicio, nunca se pierde.
- **Habilidades de movimiento** — se desbloquean explorando el mundo.

---

## Movimiento base

### Desplazamiento horizontal (caminar)

El jugador se mueve horizontalmente con aceleración y desaceleración naturales.
No hay velocidad instantánea: el personaje gana y pierde inercia de forma que
se siente con peso, pero sin ser lento. Esta es la velocidad base — el jugador
se desplaza caminando salvo que mantenga el botón de correr (ver sección siguiente).

- La aceleración es rápida — el personaje responde en pocos frames.
- La desaceleración al soltar el input es también rápida — no hay deslizamiento.
- Cambio de dirección: breve frame de freno antes de acelerar en la dirección opuesta.

**Feel:** el personaje tiene masa, pero obedece. Nunca se siente que "patina".

**Parámetros:**
- Velocidad de caminar: ~180 px/s [REVISAR]
- Tiempo hasta velocidad de caminar: ~0.1s [REVISAR]
- Tiempo de frenado al soltar: ~0.08s [REVISAR]
- Tiempo de cambio de dirección: ~0.05s [REVISAR]

---

### Correr (sprint)

Mientras el jugador mantenga presionado el botón de correr, se desplaza a una
velocidad significativamente mayor que la de caminar. Al soltar el botón, vuelve
a la velocidad de caminar con una rampa corta, no de golpe. El correr está
disponible desde el inicio del juego — no es una habilidad desbloqueable.

**Por qué existe:** El mundo es grande y el jugador va a recorrer mucho territorio.
El correr hace que la exploración no se vuelva tediosa y refuerza que el protagonista,
pese a la edad, es ágil y está entrenado para moverse en el campo. Además expande
el vocabulario de movimiento horizontal: ofrece al jugador una decisión constante
entre precisión (caminar) y velocidad (correr).

**Comportamiento:**
- Input: botón de correr en **hold** [ver controles.md]. Mientras está presionado,
  corre. Al soltarlo, vuelve a caminar.
- El personaje acelera desde la velocidad de caminar hasta la de correr con una
  rampa corta (no instantánea).
- Al soltar el botón, desacelera hasta la velocidad de caminar mientras el jugador
  siga moviéndose.
- Si el jugador suelta el input horizontal mientras corre, frena por completo
  siguiendo la desaceleración normal.

**Feel:** el paso al correr debe sentirse como un compromiso. No es simplemente
"más rápido": hay un empuje perceptible, una inercia mayor. Detenerse corriendo
requiere un poco más de distancia que detenerse caminando.

**Parámetros:**
- Velocidad de correr: ~260 px/s [REVISAR]
- Tiempo de rampa de caminar a correr: ~0.2s [REVISAR]
- Tiempo de rampa de correr a caminar: ~0.15s [REVISAR]
- Distancia extra para frenar completo desde correr vs. caminar: ~30% mayor [REVISAR]

**Casos borde:**
- **Correr + saltar:** la velocidad horizontal en el aire conserva el estado del
  hold al despegar. Si saltó corriendo y mantiene el botón, el aire conserva
  velocidad de correr. Si lo suelta en el aire, desacelera a caminar.
- **Correr + daño recibido:** el hold se ignora durante el stagger y vuelve a
  aplicar cuando el jugador recupera control. [REVISAR CON COMBATE]
- **Correr + dash:** el dash tiene su propia velocidad e ignora si el jugador
  estaba caminando o corriendo al ejecutarlo. Al terminar el dash, si el jugador
  mantiene el botón de correr y tiene input horizontal, vuelve a correr.
- **Correr en el aire:** el control aéreo respeta la velocidad activa (caminar o
  correr) según el estado del hold.
- **Correr + wall slide:** el correr no tiene efecto durante el slide (la velocidad
  vertical está fijada por la mecánica de pared). Al saltar desde la pared,
  si mantiene el botón, el aire posterior puede ser a velocidad de correr.
- **Correr + cambio de dirección:** el freno de cambio de dirección es más largo
  corriendo que caminando. El jugador siente que la dirección corriendo "cuesta"
  más de corregir — recompensa anticipar.

---

### Salto

El salto es **controlable**: el jugador modula la altura y el tiempo en el aire
según cuánto mantiene presionado el botón. No es un impulso fijo, no es un vuelo —
es un salto real con techo claro, pero la distancia entre "rozar el aire" y
"saltar con todo" está en los dedos del jugador.

**La experiencia del jugador:**
- **Tap rápido:** apenas despega. Un saltito corto, reactivo, bueno para esquivar
  algo bajo o ajustar posición sin comprometerse.
- **Hold breve:** salto intermedio. Sube un poco más, pasa sobre obstáculos medios.
- **Hold completo:** salto alto. El personaje sube al máximo y tiene más tiempo
  de aire para maniobrar, ajustar horizontal o encadenar acciones.

El control es **continuo**, no en pasos. Cada fracción extra que el jugador
mantiene el botón durante el ascenso le da un poco más de altura, hasta el
tope máximo. Cuando el jugador suelta el botón, o cuando alcanza la altura
máxima, el salto deja de extenderse y comienza la caída normal.

**Por qué existe:** Un salto de altura fija trataría al jugador como alguien
que solo elige "cuándo", no "cuánto". El salto controlable le da un vocabulario
vertical: cada salto puede ser una decisión distinta según lo que tenga enfrente.
Este control es la base sobre la que después se construye todo el vocabulario
aéreo (fast fall, dash direccional, wall jump).

**Comportamiento detallado:**
- **Impulso inicial:** al presionar el botón, el personaje recibe una velocidad
  vertical hacia arriba. Esto garantiza la altura mínima — incluso un tap
  instantáneo deja al jugador en el aire.
- **Extensión durante el ascenso:** mientras el botón se mantenga presionado
  durante la fase de subida, la gravedad aplicada es reducida. El jugador
  sigue subiendo a medida que el botón sigue presionado.
- **Corte del salto:** al soltar el botón antes del apex, la gravedad vuelve
  a un multiplicador mayor y el personaje empieza a caer más rápido. Esto
  permite cortar el salto en cualquier momento.
- **Techo duro:** aunque el botón siga presionado, el salto tiene un límite
  de altura y de duración. Alcanzado ese límite, la gravedad vuelve a normal
  aunque el hold continúe. **No se vuela.**
- **Caída:** durante la caída, la gravedad es ligeramente mayor que durante
  el ascenso — la caída se siente más rápida que la subida, lo que da peso
  al personaje.

**Feel:** el salto debe sentirse como una decisión que el jugador toma con los
dedos, no como un botón que se aprieta. Un buen salto es el que exactamente
alcanzó lo que necesitaba alcanzar y ni un frame más. Referencia: Hollow Knight
y Celeste — ambos tienen salto controlable, ninguno se siente flotante.

El tap corto **no es un bug ni una penalización**: es una herramienta. Debe
sentirse limpio, rápido, útil. El hold completo debe sentirse comprometido —
el jugador dice "ahora sí" y el personaje responde con todo.

**Parámetros:**
- Altura máxima de salto (hold completo): ~4 tiles [REVISAR]
- Altura mínima de salto (tap instantáneo): ~1.5 tiles [REVISAR]
- Duración máxima del hold efectivo (tiempo en que extender el hold sigue sumando altura): ~0.25s [REVISAR]
- Ventana mínima de salto garantizado (el salto no se puede cortar antes de este tiempo, para evitar inputs accidentales que corten el despegue): ~0.05s [REVISAR]
- Multiplicador de gravedad al soltar salto antes del apex: 2.0x [REVISAR]
- Multiplicador de gravedad en caída: 1.4x [REVISAR]
- Velocidad máxima de caída (terminal velocity): ~600 px/s [REVISAR]

**Casos borde:**
- **Hold durante la caída:** mantener el botón de salto después del apex no
  hace nada. La caída sigue su curso. El hold solo extiende durante el ascenso.
- **Salto interrumpido por techo:** si el personaje choca contra un techo
  durante el ascenso, la velocidad vertical se pone en cero y empieza a caer
  aunque el botón siga presionado. No rebota ni se "pega".
- **Presión múltiple:** soltar y volver a presionar el botón durante el aire
  no hace nada en el kit base. Con la habilidad **Doble salto** desbloqueada,
  release + press en el aire activa el segundo salto (ver sección correspondiente).
- **Salto cortado justo al despegar:** la ventana mínima de salto garantizado
  protege al jugador de soltar por accidente. Mantiene altura mínima siempre.
- **Salto + dash:** ver sección Dash. El buffer de input permite encadenarlos.
- **Salto desde borde fuera de tiempo:** ver Coyote time más abajo.

---

### Coyote time

El jugador tiene una ventana breve para ejecutar el salto después de caminar
al borde de una plataforma. Esto elimina la frustración de "casi llegaba"
sin hacer el juego más fácil — solo más justo.

**Parámetros:**
- Duración de la ventana de coyote time: ~0.12s [REVISAR]
- Condición: solo activo si el jugador caminó fuera del borde (no si saltó)

---

### Buffer de input

Las acciones se registran ligeramente antes de que sea posible ejecutarlas.
Si el jugador presiona salto justo antes de tocar el suelo, el salto se ejecuta
al aterrizar. Esto hace que el movimiento fluido se sienta natural, no que requiera
timing perfecto.

**Parámetros:**
- Ventana de buffer de salto: ~0.1s [REVISAR]
- Ventana de buffer de dash: ~0.1s [REVISAR]

---

### Control aéreo

El jugador mantiene control horizontal completo mientras está en el aire.
El aire no es una penalización — es un espacio de juego con la misma agencia
que el suelo. La velocidad horizontal en el aire es igual a la del suelo.

No hay reducción de control aéreo. El jugador puede cambiar de dirección
en el aire libremente.

---

## Habilidades de movimiento desbloqueables

> Estas habilidades no están disponibles al inicio. Se obtienen explorando el mundo.
> El orden aquí es una guía de intención, no un árbol rígido.
> Ver: docs/design/progresion.md [PENDIENTE]

---

### Fast Fall

**Descripción:** Presionar abajo en el aire hace que el personaje caiga
significativamente más rápido. El jugador gana control sobre su velocidad
de descenso.

**Por qué existe:** Expande la agencia del jugador en el aire. Permite descender
rápido en combate para evadir, o atravesar plataformas más velozmente.
También crea asimetría interesante: subir es lento, bajar puede ser rápido.

**Comportamiento:**
- Input: presionar ↓ mientras está en el aire
- Efecto: multiplica la gravedad actual por un factor, acelerando la caída
- No tiene duración fija — dura mientras el jugador mantenga ↓ presionado
- Se cancela al tocar el suelo

**Feel:** la caída debe sentirse como un derrumbe controlado — rápida y con peso,
pero con la sensación de que el jugador lo eligió.

**Parámetros:**
- Multiplicador de gravedad durante fast fall: 3.0x [REVISAR]
- Velocidad máxima de caída con fast fall: ~900 px/s [REVISAR]

**Casos borde:**
- Si el jugador activa fast fall y luego suelta ↓, la gravedad vuelve a normal
- Fast fall no cancela el control horizontal
- Fast fall durante un dash activo: [REVISAR — ver interacción con Dash]

**Estado de desbloqueo:** [PENDIENTE — definir dónde y cómo se desbloquea]

---

### Doble salto

**Descripción:** Una vez desbloqueada esta habilidad, el jugador puede ejecutar
un segundo salto mientras está en el aire. El segundo salto respeta la misma
lógica de control que el salto base: tap = impulso corto, hold = impulso más
largo, con techo duro. No convierte al personaje en volador — expande el
vocabulario aéreo un paso, no lo rompe.

**Por qué existe:** Es el primer desbloqueo que cambia el techo vertical del
personaje sin depender de paredes. Convierte zonas antes inalcanzables en
accesibles y retroactivamente resignifica el mundo explorado: rutas nuevas
aparecen en lugares ya conocidos. En términos de combate, da una herramienta
extra de reposicionamiento aéreo.

**Comportamiento:**
- **Input:** botón de salto en el aire, después del primer salto o después de
  haber caído de una plataforma.
- **Impulso del segundo salto:** similar al salto base, pero **ligeramente
  menor** en altura máxima. Se mantiene la lógica de hold: apretar breve = impulso
  corto, mantener = impulso más extendido, con techo.
- **Altura variable:** sí. El segundo salto también es controlable por hold.
- **Reset de velocidad vertical:** al ejecutar el doble salto, la velocidad
  vertical del personaje se reemplaza por el impulso del segundo salto
  (no se suma). Esto permite que funcione igual cayendo que subiendo —
  un doble salto durante una caída no queda atenuado por la velocidad de caída.
- **Recuperación:** el doble salto se consume al usarse. Se recupera **al
  tocar el suelo** o **al iniciar un wall slide** (la pared "resetea" el aire
  como si fuera suelo vertical). [REVISAR — confirmar reset por pared tras playtest]
- **Un único doble salto por estancia en el aire:** no hay triple, cuádruple, etc.

**Feel:** el segundo salto debe sentirse como un **impulso extra ganado**,
no como una extensión del primero. El jugador debería percibir una micro-pausa
entre los dos — el primer salto termina (aunque sea brevemente) y el segundo
empieza. Esto refuerza que son dos decisiones, no una sola acción prolongada.

Visual y sonoramente debería haber un feedback claro al activar el segundo salto
(el dev y el arte definen la manifestación exacta) [REVISAR CON ARTE Y DEV].
No debería ser silencioso — es una habilidad que el jugador desbloqueó y
usar una habilidad tiene que sentirse.

**Parámetros:**
- Altura máxima del segundo salto (hold completo): ~3 tiles [REVISAR — menor que el primero para que "subir alto" siga siendo un compromiso]
- Altura mínima del segundo salto (tap instantáneo): ~1 tile [REVISAR]
- Duración máxima del hold efectivo del segundo salto: ~0.2s [REVISAR]
- Ventana mínima de salto garantizado (segundo salto): ~0.05s [REVISAR]
- Usos por estancia aérea: 1 [REVISAR]
- Recuperación: al tocar suelo o iniciar wall slide [REVISAR]

**Casos borde:**
- **Doble salto después de caer sin saltar (coyote time agotado):** permitido.
  El jugador saltó o no, si está en el aire y tiene el doble salto disponible,
  lo puede usar. Cayó de una plataforma → puede ejecutar el "segundo" salto
  como si fuera el primero, pero consume el aéreo. [REVISAR — alternativa:
  que el primer salto aéreo no gaste el doble si hubo coyote time activo.
  Decidir tras playtest si la ambigüedad molesta o ayuda.]
- **Doble salto + dash aéreo:** ambos se consumen de pools distintas. Puedo
  hacer primer salto → dash → doble salto, o primer salto → doble salto → dash,
  en cualquier orden mientras cada uno tenga uso disponible.
- **Doble salto durante fast fall:** cancelarlo. El doble salto reemplaza la
  velocidad vertical por el impulso del segundo salto, efectivamente abortando
  el fast fall. El jugador recupera control vertical.
- **Doble salto contra techo:** mismo comportamiento que el salto base — choque,
  velocidad vertical a cero, empieza a caer. El doble salto queda consumido
  aunque el contacto haya sido inmediato. [REVISAR — ¿perdonamos el salto
  desperdiciado si el choque fue dentro de los primeros N frames?]
- **Doble salto + wall slide:** si el jugador entra en wall slide después de
  usar el doble salto, la pared recupera el doble salto. Si lo usa durante
  el slide mismo, sale de la pared con el impulso del segundo salto.
  [REVISAR — puede hacer la mecánica de pared redundante si es muy generoso]
- **Doble salto corto + hold del primer salto:** si el jugador estaba manteniendo
  el botón del primer salto y sin soltar lo "vuelve a presionar" para activar
  el doble salto: no funciona. El doble salto requiere **soltar y volver a
  presionar** el botón (release + press), no un hold continuo. Esto evita
  que el doble salto se active sin querer.

**Estado de desbloqueo:** [PENDIENTE — definir dónde y cómo se desbloquea
en la progresión. Ver `docs/design/progresion.md` cuando exista.]

**Estado:**
- [x] Definida, pendiente de implementación
- [ ] Implementada
- [ ] Testeada y ajustada

---

### Dash

El dash es un sistema modular: el jugador desbloquea tipos de dash progresivamente,
cada uno añadiendo capacidades sobre el anterior.

#### Dash I — Horizontal + Diagonales Superiores [PROTOTIPO] (primer desbloqueo)

**Descripción:** Impulso corto y rápido en la dirección que el jugador está
mirando. Funciona en tierra y en el aire. Dash I tiene dos modalidades:

- **Horizontal puro** (default): si el jugador no presiona input vertical al
  ejecutar el dash, el impulso es horizontal según el facing.
- **Diagonal superior [PROTOTIPO — evaluar feel]:** si el jugador mantiene ↑
  al momento de ejecutar el dash, el impulso es diagonal hacia arriba en el
  sentido del facing (↖ si mira a la izquierda, ↗ si mira a la derecha).

Las diagonales superiores están marcadas como prototipo porque todavía no hay
certeza sobre qué tan cómodas y útiles resultan en mano. Si el playtest confirma
que suman expresividad sin chocar con otras mecánicas, quedan en el kit del
Dash I de forma permanente. Si no, vuelven a Dash II, como fueron concebidas
originalmente.

**Comportamiento:**
- **Input:** botón de dash [ver controles.md]
- **Dirección horizontal:** según el **facing** del personaje, independientemente
  del input horizontal actual. Si el jugador está parado mirando a la derecha
  y presiona dash sin input, el dash va a la derecha. Si está caminando o
  corriendo hacia la izquierda, va a la izquierda. El facing manda.
- **Dirección vertical (prototipo):** si el jugador mantiene ↑ al momento de
  ejecutar el dash, el dash es diagonal superior. Cualquier otro estado vertical
  (↓ o sin input vertical) produce dash horizontal.
- El personaje es brevemente invulnerable durante el dash [REVISAR — puede no tener iframes en este nivel]
- Cooldown antes de poder hacer otro dash
- En el aire: consume el dash aéreo (se recupera al tocar el suelo)

**Feel:** movimiento explosivo y directo. Corto pero satisfactorio. La diagonal
debe sentirse como una extensión natural del dash horizontal, no como una
mecánica aparte — el jugador debería poder descubrirla intuitivamente al
mantener ↑. Referencia: dash de Hollow Knight — preciso, sin florituras.

**Parámetros:**
- Distancia horizontal: ~3 tiles [REVISAR]
- Distancia diagonal (por componente horizontal y vertical): ~2.2 tiles cada uno [REVISAR — mantener magnitud total del vector comparable al horizontal]
- Duración: ~0.18s [REVISAR]
- Cooldown: ~0.6s [REVISAR]
- Iframes: ninguno en esta versión [REVISAR]
- Usos en el aire antes de recargar: 1 [REVISAR]

**Casos borde:**
- Dash contra pared: el personaje se detiene al contacto, no atraviesa
- Dash al borde de plataforma: el personaje cae naturalmente después del dash
- Dash + salto: el buffer de input permite ejecutar ambos casi simultáneamente
- **Dash diagonal contra techo:** se detiene el componente vertical al contacto
  y conserva el horizontal hasta terminar la duración del dash [REVISAR CON DEV]
- **Dash diagonal desde el suelo:** despega del suelo con el impulso diagonal,
  sin necesidad de saltar previamente
- **Dash diagonal en el aire:** consume el dash aéreo igual que el horizontal
- **Si el prototipo diagonal se descarta tras playtest,** este bloque se revierte:
  las diagonales vuelven a Dash II y el Dash I queda solo horizontal.

**Estado de prototipo (diagonales superiores):**
- [ ] Confirmada tras playtest — pasa a kit permanente de Dash I
- [ ] Descartada — vuelve a Dash II

---

#### Dash II — Dash Direccional completo (segundo desbloqueo)

**Descripción:** El dash completa las 8 direcciones. Si las diagonales superiores
ya están disponibles desde Dash I (prototipo confirmado), Dash II agrega: ↑ puro,
↓ puro y diagonales inferiores (↙, ↘). Si el prototipo de diagonales superiores
fue descartado, Dash II entrega las 8 direcciones completas de una.

**Por qué existe:** Abre un nuevo vocabulario de movimiento. El dash hacia arriba
puro introduce el concepto de **Fast Up** — la contraparte activa del Fast Fall.

**Fast Up (interacción Dash Direccional + Dash ↑):**
Dashear directamente hacia arriba genera un impulso vertical explosivo.
Si el jugador activó Fast Fall para descender, puede usar Dash ↑ para
revertir su trayectoria bruscamente. Juntos, Fast Fall y Fast Up crean
un eje vertical de movimiento activo y expresivo — el jugador puede
controlar con precisión su posición vertical a voluntad.

**Feel del Dash ↑ (Fast Up):** debe sentirse como un disparo hacia arriba —
brusco, vertical, limpio. Diferente en carácter al dash horizontal.
La cámara debería acompañar el movimiento sin sacudir. [REVISAR CON DEV]

**Comportamiento adicional:**
- El dash diagonal es a 45° [REVISAR — puede ser en cualquier ángulo con joystick analógico]
- Dash ↓ en el aire actúa como fast fall instantáneo con velocidad de dash [REVISAR]
- El cooldown es el mismo que Dash I

**Casos borde:**
- Dash ↑ contra techo: el personaje se detiene al contacto
- Dash ↓ hacia el suelo: el personaje aterriza con impacto inmediato
- Dash diagonal hacia pared + suelo: resolución por componente más corta [REVISAR CON DEV]

---

#### Dash III — Dash Sombra (tercer desbloqueo) [CONCEPTO]

**Descripción:** El dash gana iframes completos durante su ejecución.
El personaje atraviesa ataques enemigos sin recibir daño.
Visualmente: el personaje deja una estela de sombra breve.

**Por qué existe:** Convierte el dash en una herramienta de combate real,
no solo de movilidad. El jugador que domina el timing puede esquivar
ataques que de otro modo serían inevitables.

**Parámetros:**
- Iframes: duración completa del dash [REVISAR]
- Efecto visual: trail de sombra que desaparece en ~0.3s [REVISAR CON ARTE]

**Estado:** [CONCEPTO — definir si se implementa y cómo se desbloquea]

---

### Mecánicas de Pared

Las mecánicas de pared se desbloquean en dos etapas.

#### Wall Slide (primer desbloqueo)

**Descripción:** Al estar en el aire y tocar una pared con input horizontal
hacia ella, el personaje se adhiere a la pared y cae lentamente en lugar
de caer a velocidad normal.

**Comportamiento:**
- Condición: el jugador debe estar presionando ↔ hacia la pared
- Si suelta el input horizontal, el personaje deja de adherirse y cae normal
- La velocidad de deslizamiento es constante y lenta
- Se cancela al tocar el suelo

**Feel:** el personaje se "agarra" a la superficie — debe haber un micro-frame
de transición que indique que la mecánica activó. No debe ser silencioso.

**Parámetros:**
- Velocidad de deslizamiento en pared: ~60 px/s [REVISAR]
- Tiempo de transición al activar: ~0.05s [REVISAR]

**Casos borde:**
- Wall slide en pared con techo: el personaje llega al suelo, no al techo
- Wall slide interrumpido por daño: el personaje cae normalmente

---

#### Wall Jump (segundo desbloqueo, requiere Wall Slide)

**Descripción:** Mientras hace wall slide, el jugador puede saltar desde la pared.
El salto tiene una componente horizontal forzada (alejándose de la pared)
y una vertical, independientemente del input del jugador en ese momento.

**Por qué existe:** Convierte las paredes en plataformas verticales.
Abre diseño de zonas con cañones verticales, laberintos de muros y
rutas de escape que antes eran imposibles.

**Comportamiento:**
- Input: botón de salto durante wall slide
- Dirección: siempre se aleja de la pared (no puede wall jump hacia la misma pared)
- El jugador recupera control horizontal completo ~0.15s después del wall jump [REVISAR]
- Se puede encadenar entre paredes opuestas para subir cañones verticales

**Feel:** debe sentirse como un impulso limpio y definido — el personaje se
desprende de la pared con decisión. No debe sentirse como un salto normal
empujado de costado.

**Parámetros:**
- Velocidad horizontal de salida: ~200 px/s [REVISAR]
- Velocidad vertical de salida: similar al salto completo [REVISAR]
- Tiempo de control bloqueado post wall jump: ~0.15s [REVISAR]

**Casos borde:**
- Wall jump sin tener wall slide desbloqueado: imposible — el personaje no se adhiere
- Wall jump + dash inmediato: permitido con buffer de input
- Encadenado en la misma pared (wall jump → tocar misma pared → wall jump): [REVISAR — puede limitar a 1 por pared para evitar subir infinito]

---

## Interacciones entre habilidades

| Combinación | Resultado |
|---|---|
| Fast Fall + Dash ↑ | Fast Up — ascenso explosivo desde caída |
| Fast Fall + Dash ↓ | Descenso a máxima velocidad |
| Wall Slide + Dash | Dash desde la pared (se aleja) |
| Wall Jump + Dash | Extensión de distancia post wall jump |
| Dash direccional ↗↙ | Diagonales — movilidad expresiva en espacios abiertos |
| Doble salto + Dash | Alcance aéreo extendido — segundo salto abre nueva ventana para dashear |
| Doble salto + Fast Fall | Reposicionamiento vertical rápido: subir con doble salto, bajar con fast fall |
| Doble salto durante Fast Fall | Cancela el fast fall y devuelve control vertical |
| Doble salto + Wall Slide | La pared recupera el doble salto (reset aéreo) [REVISAR] |
| Pogo al conectar (↓ + ataque en el aire) | Rebote vertical hacia arriba + reset del doble salto y dash aéreo [REVISAR]. Ver `combate.md` |
| Pogo durante Fast Fall | El rebote cancela el fast fall y devuelve control vertical |
| Ataque en movimiento | Ver `combate.md`. Interacciones con dash, correr y wall slide [PENDIENTE] |

---

## Feel general del sistema

El movimiento debe comunicar que el protagonista es competente pero humano.
No es ágil por naturaleza sobrenatural — es alguien que aprendió a moverse
en un mundo que quiere matarlo.

Al inicio, el kit base es suficiente para sobrevivir pero limitado.
Con cada habilidad desbloqueada, el jugador siente que el mundo se abre —
no porque el mundo cambió, sino porque él sí.

**Referencia de feel:** Hollow Knight para la base. Celeste para la expresividad
aérea una vez desbloqueadas las habilidades avanzadas.

---

## Parámetros globales

| Parámetro | Valor | Estado |
|---|---|---|
| Velocidad de caminar | 180 px/s | [REVISAR] |
| Velocidad de correr | 260 px/s | [REVISAR] |
| Rampa caminar → correr | 0.2s | [REVISAR] |
| Rampa correr → caminar | 0.15s | [REVISAR] |
| Velocidad de caída normal (terminal) | 600 px/s | [REVISAR] |
| Velocidad de caída con fast fall | 900 px/s | [REVISAR] |
| Altura de salto completo | 4 tiles | [REVISAR] |
| Altura de salto mínimo | 1.5 tiles | [REVISAR] |
| Altura máxima del doble salto | 3 tiles | [REVISAR] |
| Altura mínima del doble salto | 1 tile | [REVISAR] |
| Ventana de coyote time | 0.12s | [REVISAR] |
| Ventana de buffer de input | 0.1s | [REVISAR] |
| Distancia de dash horizontal | 3 tiles | [REVISAR] |
| Distancia de dash diagonal (por componente) | 2.2 tiles | [REVISAR] |
| Duración de dash | 0.18s | [REVISAR] |
| Cooldown de dash | 0.6s | [REVISAR] |

> Todos los valores son aproximaciones de diseño. Se ajustan con playtest.
> El dev puede proponer cambios marcando [REVISAR CON DISEÑO] en el código.

---

## Estado

- [x] Definida, pendiente de implementación
- [ ] Implementada
- [ ] Testeada y ajustada

---

## Historial de cambios

- 2026-04-24 — Creación del documento. Sistema base + habilidades desbloqueables definidas.
  Incluye: movimiento horizontal, salto variable, coyote time, buffer, control aéreo,
  fast fall, dash I/II/III (concepto), wall slide, wall jump, interacciones entre habilidades.
- 2026-04-24 — Agregada mecánica **Correr** al movimiento base (hold, ~260 px/s).
  La velocidad horizontal previa (~180 px/s) pasa a ser "caminar". Justificación:
  mundo grande, exploración sostenida, protagonista ágil y entrenado.
- 2026-04-24 — Aclarado que el **Dash I se dispara según el facing del personaje**,
  no según el input horizontal. Parado + dash va hacia donde mira.
- 2026-04-24 — **Adelantadas las diagonales superiores (↖, ↗) al Dash I como
  [PROTOTIPO — evaluar feel]**. Se activan manteniendo ↑ al ejecutar el dash.
  Dash II ajustado en consecuencia: si el prototipo queda, Dash II entrega
  ↑ puro, ↓ puro y diagonales inferiores; si se descarta, entrega las 8 direcciones
  de una. Pendiente decisión tras playtest.
- 2026-04-24 — Reescrita la sección **Salto** para hacer explícito el control
  continuo por hold: tap = salto corto, hold prolongado = salto más alto y con
  más tiempo de aire, con techo duro (no es vuelo). Agregados parámetros de
  "duración máxima del hold efectivo" (~0.25s) y "ventana mínima de salto
  garantizado" (~0.05s), y casos borde de hold durante caída, techo, y presión
  múltiple. Mantenidos todos los parámetros técnicos previos.
- 2026-04-24 — Agregada habilidad desbloqueable **Doble salto**. Respeta la
  lógica de altura variable del primer salto pero con techo menor (~3 tiles
  vs. 4). Requiere release + press (no hold continuo). Se recupera al tocar
  suelo o wall slide. Interactúa con fast fall (lo cancela) y con dash aéreo
  (pools distintas). Ubicación de desbloqueo queda [PENDIENTE] hasta que
  exista `progresion.md`. Actualizada la tabla de interacciones entre habilidades
  y la tabla de parámetros globales.
- 2026-04-24 — Agregadas referencias cruzadas con `combate.md`: pogo como
  ataque hacia abajo con rebote vertical, reset de doble salto y dash aéreo
  al conectar [REVISAR]. Ataque en movimiento (interacción con dash, correr
  y pared) queda [PENDIENTE] para próxima iteración.
