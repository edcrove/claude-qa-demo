# slides/img/

Imágenes que el deck referencia con rutas **relativas** (`img/…`), igual que
los diagramas de `slides/diagrams/`. Por eso el deck se exporta **dentro de
`slides/`** — si lo exportás a `/tmp`, las rutas no resuelven y las imágenes
salen vacías. `scripts/check-slide-overflow.js` falla si eso pasa.

## ⚠️ Dos imágenes están con un stand-in

Las armó el autor fuera del repo y todavía no están acá. El deck compila igual
—hay un PNG gris en su lugar— y `scripts/build-deck.sh` avisa en cada corrida
mientras sigan sin reemplazar. Guardá el archivo real con el mismo nombre y el
aviso desaparece solo (compara el hash).

| Archivo | Slide | Qué va |
|---|---|---|
| `qa-hero.png` | 4 · "La pregunta de hoy" | El agente asistiendo el flujo de QA |
| `logs-triage.png` | 23 · "El triage no termina en la categoría" | De logs completos a fallas agrupadas y priorizadas |

Las dos entran por la clase `hero`: se centran solas y se limitan a 352 px de
alto, así que no hace falta redimensionarlas. Conviene que sean **~3:2** —
las actuales son 1536×1024 — y que tengan **fondo claro o transparente**: sobre
la variante clara se funden, y sobre la oscura `qa-deck.css` les pone un borde
y una sombra suave para que se lean como una tarjeta y no como un agujero.

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
