# slides/img/logos/

Logos de las herramientas que los MCPs conectan (slide 11 del deck).

## Procedencia

Generados por `scripts/build-logos.js` desde el paquete
[`simple-icons`](https://github.com/simple-icons/simple-icons) (CC0-1.0 en
cuanto al empaquetado). No se bajó nada a mano: el script los regenera desde
una dependencia, así que es auditable, y los `.svg` quedan commiteados para
que el deck siga funcionando sin red.

Para regenerarlos:

```bash
npm i simple-icons
node scripts/build-logos.js
```

## Colores

`simple-icons` trae el color de marca de cada uno. Dos no se leen sobre el
fondo `#011627` del deck, así que se usa la variante de la propia marca para
fondos oscuros en vez de inventar un color:

| Logo | Marca | Usado | Por qué |
|---|---|---|---|
| Jira | `#0052CC` | `#2684FF` | Azul B200 de Atlassian; el de marca es muy oscuro |
| Confluence | `#172B4D` | `#2684FF` | El de marca es prácticamente invisible sobre `#011627` |
| Jenkins | `#D24939` | `#E8604F` | Aclarado: su line art se emborrona sobre fondo oscuro |
| TestRail | `#65C179` | `#65C179` | Color de marca, sin cambios |

## Marcas registradas

Jira y Confluence son marcas de Atlassian; Jenkins, de la Continuous Delivery
Foundation; TestRail, de Gurock/Idera. Se usan acá solo para **identificar**
las herramientas de las que habla la charla — uso nominativo. Ni el repo ni la
charla están afiliados ni auspiciados por ninguna de ellas.
