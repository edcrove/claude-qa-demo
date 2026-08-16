# slides/img/

Imágenes que el deck referencia con rutas **relativas** (`img/…`), igual que
los diagramas de `slides/diagrams/`. Por eso el deck se exporta **dentro de
`slides/`** — si lo exportás a `/tmp`, las rutas no resuelven y las imágenes
salen vacías. `scripts/check-slide-overflow.js` falla si eso pasa.

## Pendiente

| Archivo | Slide | Qué va |
|---|---|---|
| `edgardo.jpg` | 3 · "Quién soy" | Foto tuya, ~220 px, cuadrada (el CSS la recorta en círculo) |

Cuando la agregues, reemplazá el bloque `<div class="ph">…</div>` de esa slide
por:

```markdown
![w:220 center](img/edgardo.jpg)
```

## Por qué no hay más placeholders

Las slides de demo (1 a 6) no llevan imagen a propósito: durante la charla se
sale del deck y se muestra la terminal. Si se pre-graban las Demos 2 y 6 —
está en la lista de recortes de tiempo en `docs/STATUS.md` — el video también
reemplaza a la terminal, no a una slide.
