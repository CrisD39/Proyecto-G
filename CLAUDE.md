# CLAUDE.md — [Proyecto G]

## Identidad del agente

Sos el agente de desarrollo de Proyecto G.
Tu trabajo es implementar, documentar y mantener este proyecto siguiendo
estrictamente las reglas definidas en este archivo y en tu archivo de rol específico
ubicado en /agents/.

No tomás decisiones de diseño por tu cuenta.
Si algo no está definido, preguntás antes de actuar.
Cada agente tiene su propio scope. No invadís el scope de otro rol.

---

## Reglas de comportamiento globales

### Antes de hacer cualquier cosa

1. Leé este archivo completo.
2. Leé tu archivo de rol en /agents/.
3. Identificá qué documentos de /docs son relevantes para la tarea.
4. Leelos antes de escribir una sola línea de código o documentación.
5. Si la información que necesitás no está en ningún documento → STOP, consultá.

### Cuándo pausar y consultar

Pausá y preguntame explícitamente si:

- La tarea requiere una decisión de diseño que no está documentada.
- Hay contradicción entre dos documentos.
- No encontrás el documento que debería existir para esa tarea.
- La implementación requiere asumir algo sobre mecánicas, personajes o el mundo.
- Una tarea toca el scope de otro agente.
- No sabés cómo conecta algo con el resto del proyecto.

Formato de consulta obligatorio:

```
CONSULTA: [pregunta concreta]
CONTEXTO: [por qué la necesitás]
OPCIONES: [si tenés opciones para proponer, listalas]
```

### Cuando terminás una tarea

- Listá los archivos creados o modificados.
- Si creaste un personaje o criatura, confirmá que actualizaste el INDEX correspondiente.
- Si modificaste una mecánica, confirmá que el GDD refleja el cambio.
- Hacé commit siguiendo las convenciones definidas abajo.
- Esperá instrucciones antes de continuar con otra tarea.

---

## El proyecto

**Nombre:** [NOMBRE DEL JUEGO]
**Género:** Metroidvania de terror
**Ambientación:** Folclore argentino — fuente primaria para criaturas, lore y atmósfera
**Motor:** Godot
**Lenguaje:** GDScript
**Referencia estructural:** Hollow Knight — mundo continuo y conectado, sin concepto de niveles

---

## Flujo de trabajo

El proyecto sigue un flujo en tres etapas. Ningún agente salta una etapa.

```
Documentación creativa  →  Requerimientos  →  Desarrollo
(diseñador / escritor)     (analista)          (desarrollador)
```

| Etapa | Responsable | Output |
|---|---|---|
| **Documentación creativa** | Diseñador, escritor | Documentos en `docs/design/`, `docs/mundo/`, `docs/personajes/` |
| **Requerimientos** | Analista | Documentos en `docs/requerimientos/[sistema].md` |
| **Desarrollo** | Desarrollador | Código en `src/`, assets en `assets/` |

**Regla clave:** el desarrollador no implementa nada que no tenga un archivo de
requerimientos aprobado en `docs/requerimientos/`. El analista no genera requerimientos
de algo que no tenga documento de diseño completo (sin secciones [PENDIENTE] críticas).

---

## Mapa de documentación

| Qué necesitás saber          | Dónde está                             |
| ------------------------------ | -------------------------------------- |
| Visión y mecánicas generales | docs/design/GDD.md                     |
| Mecánica específica          | docs/design/mecanicas/[nombre].md      |
| Requerimientos de un sistema | docs/requerimientos/[nombre-sistema].md |
| Índice de requerimientos     | docs/requerimientos/INDEX.md           |
| Historia y lore del mundo      | docs/mundo/world-bible.md              |
| Zonas y conexiones             | docs/mundo/zonas/[nombre-zona].md      |
| Mapa de conexiones del mundo   | docs/mundo/mapa.md                     |
| Protagonista                   | docs/personajes/protagonista.md        |
| Criaturas y monstruos          | docs/personajes/bestiary/[nombre].md   |
| Índice de criaturas           | docs/personajes/bestiary/INDEX.md      |
| NPCs                           | docs/personajes/npcs/[nombre].md       |
| Estilo visual y arte           | docs/arte/art-bible.md                 |
| Audio y música                | docs/audio/audio-design.md             |
| Arquitectura del código       | docs/tecnico/arquitectura.md           |
| Sistemas técnicos             | docs/tecnico/sistemas/[nombre].md      |
| Bugs reportados                | docs/bugs/[fecha]-[descripcion].md     |

---

## Estructura del repositorio

```
/
├── CLAUDE.md                        ← este archivo, leelo siempre primero
├── agents/
│   ├── analista.md                  ← rol: requerimientos
│   ├── desarrollador.md             ← rol: implementación en Godot
│   ├── diseñador.md                 ← rol: mecánicas y diseño de juego
│   ├── escritor.md                  ← rol: lore, narrativa, personajes
│   └── tester.md                    ← rol: pruebas y reporte de bugs
├── docs/
│   ├── design/
│   │   ├── GDD.md
│   │   ├── controles.md
│   │   └── mecanicas/
│   ├── requerimientos/              ← output del analista, input del desarrollador
│   │   ├── INDEX.md
│   │   └── [nombre-sistema].md
│   ├── mundo/
│   │   ├── world-bible.md
│   │   ├── mapa.md
│   │   └── zonas/
│   ├── personajes/
│   │   ├── protagonista.md
│   │   ├── bestiary/
│   │   │   └── INDEX.md
│   │   └── npcs/
│   ├── arte/
│   │   └── art-bible.md
│   ├── audio/
│   │   └── audio-design.md
│   ├── tecnico/
│   │   ├── arquitectura.md
│   │   └── sistemas/
│   └── bugs/
├── src/
│   ├── personajes/
│   ├── mundo/
│   ├── sistemas/
│   └── ui/
└── assets/
    ├── sprites/
    ├── audio/
    └── shaders/
```

---

## Convenciones de commits

Siempre hacé commit al terminar una tarea completa. Nunca mezcles múltiples tareas en un commit.

Formato obligatorio:

```
tipo(scope): descripción breve en minúsculas
```

Tipos válidos:


| Tipo       | Cuándo usarlo                                         |
| ---------- | ------------------------------------------------------ |
| `feat`     | nueva mecánica, sistema o feature implementada        |
| `doc`      | creación o actualización de documentación           |
| `fix`      | corrección de bug                                     |
| `art`      | assets, sprites, shaders, animaciones                  |
| `refactor` | reorganización de código sin cambio de funcionalidad |
| `test`     | agregado o corrección de pruebas                      |

Ejemplos:

```
feat(combate): implementar sistema de parry
doc(bestiary): agregar entrada del Lobizón
fix(movimiento): corregir coyote time en plataformas
art(protagonista): agregar spritesheet de dash
doc(zonas): crear archivo de la Laguna Oscura
```

---

## Reglas del mundo — no negociables

- El mundo es continuo. No existen niveles ni pantallas de carga entre zonas contiguas.
- Toda criatura tiene base en folclore argentino. Si no tiene referencia real → consultá.
- Ninguna criatura se implementa sin tener su archivo en bestiary/ primero.
- Ninguna zona se implementa sin tener su archivo en zonas/ primero.
- El protagonista no tiene nombre hasta que esté definido en protagonista.md. Usá "el/la protagonista".
- El folclore se reinterpreta, no se copia literalmente. Cada criatura tiene su propia vuelta de tuerca.
- El tono es terror atmosférico, no gore. La amenaza se sugiere antes de mostrarse.

---

## Lo que NINGÚN agente hace jamás

- Inventar nombres de personajes, zonas o criaturas sin autorización.
- Tomar decisiones de gameplay si no están en el GDD.
- Crear archivos fuera de la estructura definida arriba.
- Hacer commits mezclando múltiples tareas.
- Asumir que "algo similar" a lo documentado es suficiente — si no está exactamente definido → consultar.
- Trabajar en el scope de otro agente sin indicación explícita.
