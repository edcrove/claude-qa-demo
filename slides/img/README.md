# slides/img/

Imágenes que el deck referencia con rutas **relativas** (`img/…`), igual que
los diagramas de `slides/diagrams/`. Por eso el deck se exporta **dentro de
`slides/`** — si lo exportás a `/tmp`, las rutas no resuelven y las imágenes
salen vacías. `scripts/check-slide-overflow.js` falla si eso pasa.

## Las imágenes de apoyo

| Archivo | Slide | Qué muestra |
|---|---|---|
| `qa-hero.png` | 4 · "La pregunta de hoy" | El agente asistiendo el flujo de QA |
| `logs-triage.png` | 23 · "El triage no termina en la categoría" | De logs completos a fallas agrupadas y priorizadas |
| `skill-suggest.png` | 25 · "Y no siempre tenés que contar vos" | Repetí / noté / anoté, y el agente devuelve las skills sugeridas |

Las tres entran por la clase `hero`: **alineadas a la izquierda** —como todo el
resto del deck— y limitadas a 390 px de alto, así que no hace falta
redimensionarlas al reemplazarlas. Conviene que sean **~3:2** (las actuales son
1100×733) y con **fondo claro o transparente**: sobre la variante clara se
funden, y sobre la oscura `qa-deck.css` les pone borde y sombra suave para que
se lean como una tarjeta y no como un agujero.

Vinieron a 1536×1024 y ~1.4–1.8 MB; se bajaron a 1100 px de ancho y se
cuantizaron a paleta porque el deck las muestra a ~585×390 y el peso se
multiplica por 4 builds × 2 PDFs. Quedaron en 191 / 310 / 275 KB.

## Qué más hay acá

- [`logos/`](logos/README.md) — Jira, TestRail, Jenkins, GitHub, Confluence y
  Claude, generados por `scripts/build-logos.js`. Ahí están documentados la
  procedencia, los colores y las marcas.

## Qué no hay, y por qué

- **No hay foto del autor.** Decisión del autor (2026-08-16): la slide
  "Quién soy" queda tipográfica.
- **Las slides de demo (1 a 6) no llevan imagen** a propósito: durante la
  charla se sale del deck y se muestra la terminal. Si se pre-graban las
  Demos 2 y 6 — está en la lista de recortes de tiempo en `docs/STATUS.md` —
  el video también reemplaza a la terminal, no a una slide.
