# Requerimientos — Índice general

> Cada archivo en esta carpeta traduce un documento de diseño a requerimientos
> concretos, accionables y verificables para el desarrollador.
> No crear requerimientos de sistemas que aún no tienen documento de diseño completo.

---

## Archivos existentes

| Archivo | Sistema | Estado | Versión | Fecha |
|---|---|---|---|---|
| [movimiento.md](movimiento.md) | Movimiento del protagonista | Borrador | 1.0 | 2026-04-25 |
| [combate.md](combate.md) | Combate (ataque direccional + pogo) | Borrador | 1.0 | 2026-04-25 |

---

## Pendientes — sin documento de diseño fuente

| Sistema | Bloqueado por |
|---|---|
| Parry | `docs/design/mecanicas/parry.md` no existe |
| Caza informada | `docs/design/mecanicas/caza.md` no existe |
| Mapa | `docs/design/mecanicas/mapa.md` no existe |
| Muerte y checkpoint | `docs/design/mecanicas/muerte.md` no existe |
| Interacción | `docs/design/mecanicas/interaccion.md` no existe |
| Progresión / desbloqueos | `docs/design/progresion.md` no existe |
| Economía | `docs/design/economia.md` no existe |
| UX / Interfaz | `docs/design/ux.md` no existe |
| Cámara | `docs/design/camaras.md` no existe |

---

## Convención de IDs

| Código | Sistema |
|---|---|
| `RF-MOV-XXX` | Movimiento del protagonista |
| `RF-CMB-XXX` | Combate |
| `RF-PARRY-XXX` | Parry |
| `RF-CAM-XXX` | Cámara |
| `RF-UI-XXX` | Interfaz y HUD |
| `RF-MUNDO-XXX` | Zonas y mundo conectado |
| `RF-SAVE-XXX` | Sistema de guardado |
| `RF-AUDIO-XXX` | Audio y música |
| `RF-NPC-XXX` | Personajes no jugables |
| `RF-ENE-XXX` | Enemigos (genérico) |
| `RF-[NOMBRE]-XXX` | Criatura específica (ej. `RF-LOBIZÓN-001`) |
| `RF-INV-XXX` | Inventario y recursos |
| `RF-DLG-XXX` | Sistema de diálogos |

---

> Este índice se actualiza cada vez que se crea o aprueba un archivo de requerimientos.
