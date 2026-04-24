# Proyecto G

> Si llegás nuevo al proyecto, empezá por [`docs/PITCH.md`](docs/PITCH.md) —
> ahí está todo lo que necesitás saber sobre qué es el juego antes de tocar cualquier otra cosa.

---

## Índice

1. [¿Qué es esto?](#qué-es-esto)
2. [Primeros pasos](#primeros-pasos)
3. [Estructura del repositorio](#estructura-del-repositorio)
4. [Cómo trabajamos](#cómo-trabajamos)
5. [Ramas y flujo de Git](#ramas-y-flujo-de-git)
6. [El sistema de agentes](#el-sistema-de-agentes)
7. [Roles disponibles](#roles-disponibles)
8. [Convenciones de commits](#convenciones-de-commits)

---

## ¿Qué es esto?

Este repositorio contiene todo el proyecto **Proyecto G**: código fuente, documentación de diseño, lore, requerimientos, planes de testing y configuración de agentes de IA.

Es un metroidvania 2D de terror basado en folclore argentino, desarrollado en Godot 4.
Para entender el juego → [`docs/PITCH.md`](docs/PITCH.md).
Para entender cómo trabajar en él → seguí leyendo.

---

## Primeros pasos

### Si sos nuevo en el proyecto

```
1. Leé docs/PITCH.md          → qué es el juego
2. Leé CLAUDE.md              → reglas generales de trabajo
3. Leé agents/[tu-rol].md     → reglas específicas de tu rol
4. Revisá docs/design/GDD.md  → estado actual del diseño
5. Preguntá antes de tocar algo que no conocés
```

### Requisitos técnicos

| Herramienta | Versión mínima | Para qué |
|---|---|---|
| Godot | 4.x | Motor del juego |
| Git | 2.x | Control de versiones |
| Node.js | 18+ | Claude Code (agentes IA) |
| Claude Code | última | Agentes de desarrollo |

### Setup inicial

```bash
# Clonar el repo
git clone https://github.com/[usuario]/proyecto-g.git
cd proyecto-g

# Pararse en la rama de desarrollo
git checkout dev

# Instalar Claude Code (opcional, para trabajar con agentes)
npm install -g @anthropic-ai/claude-code
```

---

## Estructura del repositorio

```
proyecto-g/
│
├── README.md                        ← estás acá
├── CLAUDE.md                        ← reglas globales para agentes IA
├── project.godot                    ← configuración del proyecto Godot
│
├── agents/                          ← perfiles de cada agente IA
│   ├── diseñador.md
│   ├── escritor.md
│   ├── analista.md
│   ├── desarrollador.md
│   └── tester.md
│
├── docs/                            ← toda la documentación del proyecto
│   ├── PITCH.md                     ← presentación general del juego ⭐ empezá acá
│   ├── design/
│   │   ├── GDD.md                   ← game design document principal
│   │   └── mecanicas/               ← un .md por mecánica
│   ├── mundo/
│   │   ├── world-bible.md           ← lore e historia del mundo
│   │   ├── mapa.md                  ← conexiones entre zonas
│   │   └── zonas/                   ← un .md por zona
│   ├── personajes/
│   │   ├── protagonista.md
│   │   ├── bestiary/                ← criaturas del folclore
│   │   │   └── INDEX.md
│   │   └── npcs/
│   ├── requerimientos/              ← requerimientos funcionales por sistema
│   ├── arte/
│   │   └── art-bible.md
│   ├── audio/
│   │   └── audio-design.md
│   ├── tecnico/
│   │   ├── arquitectura.md
│   │   └── sistemas/
│   ├── testing/
│   │   ├── planes/
│   │   └── resultados/
│   └── bugs/
│       └── INDEX.md
│
├── src/                             ← código fuente del juego
│   ├── personajes/
│   ├── sistemas/
│   ├── mundo/
│   ├── ui/
│   └── textos/
│
├── assets/                          ← sprites, audio, shaders
│   ├── sprites/
│   ├── audio/
│   └── shaders/
│
└── referencias/                     ← material de investigación (folclore, literatura)
    ├── literatura/
    ├── folclore/
    ├── articulos/
    └── notas-propias/
```

---

## Cómo trabajamos

El proyecto separa claramente **documentación** e **implementación**.
Nada se implementa sin estar documentado primero.

El flujo general es:

```
Escritor          Diseñador         Analista          Desarrollador       Tester
    │                 │                 │                    │                │
 Crea lore        Define           Formaliza           Implementa        Verifica
 y criaturas     mecánicas        requerimientos        en Godot          bugs
    │                 │                 │                    │                │
 /docs/mundo     /docs/design     /docs/requerim.          /src          /docs/bugs
 /personajes     /mecanicas/      RF-[SISTEMA].md                        INDEX.md
```

Cada rol tiene su propio scope. Nadie toca lo que no le corresponde sin coordinación explícita.

---

## Ramas y flujo de Git

### Ramas principales

| Rama | Propósito | Quién toca |
|---|---|---|
| `main` | Versión estable. Solo recibe merges desde `dev` cuando hay un hito cerrado. | Nadie directamente |
| `dev` | Rama de desarrollo activo. Punto de partida para toda rama de trabajo. | Todos, via PR |

### Ramas de trabajo

Toda tarea nueva nace desde `dev` con este formato:

```
[tipo]/[descripcion-corta]
```

| Prefijo | Para qué |
|---|---|
| `feat/` | Nueva mecánica, sistema o feature |
| `doc/` | Documentación nueva o actualizada |
| `fix/` | Corrección de bug |
| `art/` | Assets, sprites, shaders |
| `refactor/` | Reorganización de código |

**Ejemplos:**
```bash
git checkout -b feat/sistema-parry
git checkout -b doc/bestiary-lobizón
git checkout -b fix/dash-atraviesa-paredes
git checkout -b doc/GDD-mecanica-caza
```

### Flujo completo

```bash
# 1. Siempre partir desde dev actualizado
git checkout dev
git pull origin dev

# 2. Crear rama para la tarea
git checkout -b doc/bestiary-lobizón

# 3. Trabajar, hacer commits atómicos
git add docs/personajes/bestiary/lobizón.md
git commit -m "doc(bestiary): agregar entrada del Lobizón"

# 4. Subir la rama
git push origin doc/bestiary-lobizón

# 5. Abrir Pull Request hacia dev
# Describir qué se hizo y qué revisar

# 6. Después del merge, borrar la rama
git branch -d doc/bestiary-lobizón
```

### Reglas de ramas

- **Nunca commiteás directo a `main`** — solo llega por merge desde `dev`
- **Nunca commiteás directo a `dev`** — siempre via rama + PR
- **Una tarea = una rama** — no mezcles mecánicas, sistemas o documentos no relacionados
- **Ramas cortas** — una rama que dura más de una semana probablemente está haciendo demasiado
- **Mergeás vos o alguien más revisa** — ningún PR se mergea sin al menos una lectura

---

## El sistema de agentes

El proyecto usa **Claude Code** como sistema de agentes especializados.
Cada agente es una sesión de Claude Code con un perfil de rol cargado al inicio.

### Cómo iniciar un agente

```bash
# Abrís Claude Code en la carpeta del proyecto
cd proyecto-g
claude

# Al inicio de cada sesión, pegás el prompt de arranque:
# "Leé CLAUDE.md y agents/[rol].md completos.
#  Luego decime qué documentos encontraste y esperá instrucciones."
```

### Un agente por terminal

Cada agente corre en su propia terminal de forma independiente.
Cada uno trabaja en su rama correspondiente:

```
Terminal 1 → escritor    → rama: doc/world-bible
Terminal 2 → diseñador   → rama: doc/mecanica-caza
Terminal 3 → analista    → rama: doc/RF-combate
Terminal 4 → dev         → rama: feat/sistema-parry
Terminal 5 → tester      → rama: fix/verificacion-dash
```

Los agentes no se coordinan entre sí directamente — **vos sos el punto de coordinación**.
Cuando el escritor termina algo que el diseñador necesita, vos lo mergeas a `dev` y le avisás al diseñador.

---

## Roles disponibles

| Rol | Archivo | Trabaja en | Toca |
|---|---|---|---|
| Diseñador | `agents/diseñador.md` | Mecánicas y diseño | `/docs/design/` |
| Escritor | `agents/escritor.md` | Lore y narrativa | `/docs/mundo/`, `/docs/personajes/` |
| Analista | `agents/analista.md` | Requerimientos | `/docs/requerimientos/` |
| Desarrollador | `agents/desarrollador.md` | Implementación | `/src/` |
| Tester | `agents/tester.md` | QA y bugs | `/docs/bugs/`, `/docs/testing/` |

Para entender el scope exacto de cada rol → leé su archivo en `/agents/`.

---

## Convenciones de commits

Formato obligatorio:

```
tipo(scope): descripción en minúsculas
```

| Tipo | Cuándo |
|---|---|
| `feat` | Nueva mecánica, sistema o feature implementada |
| `doc` | Documentación nueva o actualizada |
| `fix` | Corrección de bug |
| `art` | Assets, sprites, shaders, animaciones |
| `refactor` | Reorganización sin cambio funcional |
| `test` | Planes de testing o resultados |

**Ejemplos:**
```
feat(combate): implementar ventana de parry
doc(bestiary): agregar entrada del Lobizón
doc(GDD): documentar mecánica de caza informada
fix(movimiento): corregir coyote time en pendientes
art(protagonista): agregar spritesheet de dash
test(movimiento): agregar plan de pruebas RF-MOV
```

---

> **¿Dudas?** Antes de hacer algo que no sabés si va, abrí una discusión o preguntá.
> Es mejor perder cinco minutos consultando que una hora deshaciendo.
