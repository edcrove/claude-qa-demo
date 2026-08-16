# slides/img/logos/

Logos de las herramientas que los MCPs conectan (slide 11 del deck):
Jira, TestRail, Jenkins, GitHub y Confluence.

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

## Colores: todos de marca

Los cinco usan su color real, sin retocar. Una versión anterior tuvo que
aclarar tres de ellos para que sobrevivieran al fondo `#011627` — el azul de
Atlassian quedaba invisible y el mayordomo de Jenkins, que es line art, se
convertía en una mancha.

Eso se resolvió en CSS y no tocando las marcas: la regla `img.logo` de
`slides/slides.md` los apoya sobre un **chip claro** de esquinas redondeadas.
Sobre blanco, cada color de marca funciona como fue diseñado, y los cinco
quedan con el mismo peso visual — que era el otro problema, porque Jenkins
tiene mucho más detalle que los demás.

Si algún día cambia el fondo del deck, el chip es lo único a revisar.

## Marcas registradas

Jira y Confluence son marcas de Atlassian; Jenkins, de la Continuous Delivery
Foundation; TestRail, de Gurock/Idera; GitHub, de GitHub, Inc. Se usan acá solo
para **identificar** las herramientas de las que habla la charla — uso
nominativo. Ni el repo ni la charla están afiliados ni auspiciados por ninguna
de ellas.
