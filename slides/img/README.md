# slides/img/

Imágenes que el deck referencia con rutas **relativas** (`img/…`), igual que
los diagramas de `slides/diagrams/`. Por eso el deck se exporta **dentro de
`slides/`** — si lo exportás a `/tmp`, las rutas no resuelven y las imágenes
salen vacías. `scripts/check-slide-overflow.js` falla si eso pasa.

## Qué hay acá

- [`logos/`](logos/README.md) — Jira, TestRail, Jenkins y Confluence para la
  tabla de MCPs (slide 11), generados por `scripts/build-logos.js`. Ahí están
  documentados la procedencia, los colores y las marcas.

## Qué no hay, y por qué

- **No hay foto del autor.** Decisión del autor (2026-08-16): la slide
  "Quién soy" queda tipográfica.
- **Las slides de demo (1 a 6) no llevan imagen** a propósito: durante la
  charla se sale del deck y se muestra la terminal. Si se pre-graban las
  Demos 2 y 6 — está en la lista de recortes de tiempo en `docs/STATUS.md` —
  el video también reemplaza a la terminal, no a una slide.
