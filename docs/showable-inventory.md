# Inventario de lo mostrable

Qué tiene el toolkit privado del autor —el repo aparte al que apunta la slide de
stack— que le sirva al deck. Ya sanitizado: nada de acá nombra a la empresa, un
repo real, un job real, un ticket real ni un host real.

Este doc es un catálogo, no un plan. Materializar cualquiera de estos como
`.mdc` o `SKILL.md` en el repo del demo es un paso aparte.

## Sanitización

`scripts/check-leaks.sh` es la enforcement, no esta tabla. Corrélo cada vez que
pases algo de acá a una slide.

| Real | Acá |
|---|---|
| empresa, producto, productos hermanos | Acme Streaming · "el producto" · "el equipo hermano" |
| monorepo de tests funcionales | `api-tests` |
| repo del servicio deployable | `platform-service` |
| job de regresión en CI | `api-regression` |
| la suite que no puede solaparse | `catalogRegression` |
| los dos gateways de API | `web-gateway` · `app-gateway` |
| tickets | `PROJ-1234` · release `REL-4321` |
| hosts | `ci.example.com` · `jira.example.com` · `testrail.example.com` |
| canal del equipo | `#platform-contributors` |
| clases del framework | `ApiTestBase` · `ApiContext` · `ProductTestData` |
| el repo del toolkit | "un repo aparte" — **sin nombre, a propósito** |

El nombre del toolkit no va al deck: es un repo real en el org de la empresa, y
publicarlo es una búsqueda de distancia entre la charla y la organización.

---

## Rules

De las doce del toolkit **sólo dos son prohibiciones.** Esa es la observación que
vale una slide: el deck usa "rule" como sinónimo de guardrail y hay categorías
más ricas.

### Prohibición

| Rule | Qué dice | Por qué mostrarla |
|---|---|---|
| `no-parallel-ci` | No arranques `catalogRegression` si ya hay una corriendo o encolada en el mismo ambiente. | Ya está en el demo, pero la real tiene tres cosas más: acota el alcance (sólo esa suite, no todas), apunta a un **script guard** que corre igual sin el agente, y trae **bypass de emergencia** (`CI_GUARD_SKIP=1`). *"Una regla sin válvula de escape no se respeta: se saltea a mano y en silencio."* |
| `english-only` | Todo lo que va a GitHub, en inglés. | Ya está en el demo. La real enumera las superficies (título y body de PR, comments, commits, release notes) y sobre todo las **excepciones que no se traducen**: ticket ids, build numbers, nombres de branch, identificadores de código, log excerpts. Las excepciones son lo que la hace sobrevivir al uso real. |

### Formato — mecánicas, baratas, cumplimiento casi perfecto

| Rule | Qué dice | Por qué mostrarla |
|---|---|---|
| `pr-description-ticket-first-line` | Línea 1 del body es el ticket. Línea 2 vacía. Y si la PR toca tests, va un bloque `## Test evidence` con el link directo al build, comparación before/after vs `main` **en la misma matriz**, y statement de net-new-failures. | Aburrida, verificable, y es de lo que todo reviewer reclama para siempre. La mitad interesante es la cláusula de vencimiento: si entran commits después del build, **la evidencia está vieja** — codifica *cuándo la prueba deja de valer*. |
| `response-context-header` | Toda respuesta arranca con tres líneas: branch, workspace, hora. | La rara del set, y por eso vale 20 segundos: gobierna **cómo te habla el agente**, no qué le hace al código. *"Podés gobernar el formato de la respuesta, no sólo la acción."* |

### Procedimiento de decisión — la categoría más QA de todas

| Rule | Qué dice | Por qué mostrarla |
|---|---|---|
| `regression-evidence-scope` | Cuánta evidencia debe una PR **según los paths que toca, no según el ticket**: sólo la suite angosta si todo cae dentro de la carpeta de la feature; suite completa **además** si toca framework, clases base o servicios comunes. Si dudás si un path es común, tratalo como común. Y gate rápido primero: la suite completa cuesta una hora, el gate caza el fix roto en minutos. | La mejor del toolkit para esta audiencia. Tres ideas en una slide: esfuerzo escalado al riesgo, default explícito para la ambigüedad, y chequeo barato antes del caro. Es lo que un QA senior hace en la cabeza, escrito. |
| `scratchpad-for-working-docs` | Todo doc que genera el agente va a `<repo>/scratchpad/` (gitignored). Nunca un `.md` en la raíz. Nunca en el directorio de config de la herramienta. | Un agente que escribe archivos necesita **regla de archivo**, o en seis meses la raíz del repo es un basural de `analysis-final-v2.md`. Nadie lo piensa hasta que ya pasó. Va con la tabla de abajo. |
| `branch-management` | Rebase sobre la branch default, nunca merge, al actualizar una branch de ticket. `--force-with-lease` después. | Genérica, entra en una pantalla, se copia y pega. |

Los dos scratchpads, que es lo que hace que la regla se entienda:

| Dónde | Vive | Para |
|---|---|---|
| `<repo>/scratchpad/` | sobrevive la sesión | lo que vas a reabrir: planes, análisis, evidencia |
| el scratchpad de sesión del harness | sólo la sesión | scripts descartables, dumps de JSON, intermedios |

### Vocabulario — la categoría que nadie espera

| Rule | Qué dice | Por qué mostrarla |
|---|---|---|
| `second-checkout-definition` | "R1" es el checkout principal, "R2" el segundo checkout del mismo remoto que usás en paralelo. Los paths salen de config; si R2 no está configurado, decilo en vez de adivinar. | No tiene procedimiento y no prohíbe nada: le enseña al agente **la jerga de tu equipo**. Aside de 15 segundos: *"una rule también puede ser un glosario."* |

### Feedback de review destilado

**`test-antipatterns`** — la más grande del toolkit, y la que mejor prueba la
tesis del deck: cada bullet es un defecto que se cazó en un review real y se
escribió para no volver a cazarlo. Mostrá tres o cuatro, nunca toda:

- **Fallá rápido en el setup de suite.** Nada de `catch → log → return null` en
  setup obligatorio: un token nulo cacheado hace que *todo* request dé 401 y
  produce una corrida de fallas masivas confusa en lugar de un error claro.
- **Los smoke tests assertean el valor que consume el path productivo**, no un
  fetch fresco — si no, una regresión de cache/inyección pasa el smoke.
- **Soft assert en las hojas, hard assert en las compuertas.** Los chequeos de
  campos independientes van por soft assert, para que una corrida muestre *todos*
  los campos mal; queda hard cualquier chequeo que habilita un dereference
  posterior, o el path soft explota antes del `assertAll()`.
- **Ningún ticket id en comentarios de código.** El comentario explica qué y por
  qué; el ticket que lo agregó envejece y ya se llega por `git blame`.
- **Nada de comentarios de IA en ningún lado** — ni prosa de razonamiento en el
  Javadoc, ni footer de "generated with" en PRs o commits.

Ese último es el sleeper: una rule cuyo único trabajo es que **no queden las
huellas del agente en el artefacto**, y le pega fuerte a una audiencia que tiene
justo esa preocupación. *"La regla existe porque el output se tiene que poder
defender como tuyo."*

Detalle para decir al pasar: cada ítem cita el **número de PR** de donde salió,
nunca al reviewer. Trazabilidad sin nombrar a una persona.

### Dónde vive cada rule — slide en sí misma

- `rules/user/` → carga en **todos** los proyectos. Este set se mantiene chico.
- `rules/workspaces/<repo>/` → carga en un repo solo.

> Meter una rule específica de un proyecto en `user/` la hace cargar en todos
> lados, que es casi siempre lo incorrecto. Si la rule nombra un repo, un job o
> un package, va en `workspaces/`.

Es la versión mecánica del argumento de costo del deck. El toolkit real tiene
**4 globales y 8 por repo** — una proporción que se puede poner en pantalla.

---

## Skills

| Skill | Qué hace | Por qué mostrarlo |
|---|---|---|
| `feature-knowledge-base` | **RECALL** al empezar un ticket: greppea la base por endpoint/dominio/región, lee los matches, sigue los `[[cross-links]]` y te dice qué se sabe *antes* de proponer trabajo. **CAPTURE** después de analizar: copia el template, llena el frontmatter, escribe Summary / Qué aprendimos / Evidencia / Cómo aplicarlo. | El más fuerte de los nuevos, y el único que cambia qué cree la audiencia que *es* un skill: memoria durable que **no** es la feature de memory del harness. Archivos planos, greppeables, compartidos entre dos herramientas distintas. Su barra de calidad tiene la frase: *"una entrada que sólo registra qué pasó es un changelog, no conocimiento."* |
| `ci-regression-review` | Produce un **veredicto, no una lista**: (1) totales reconciliados —cross-check de inconsistencias internas antes de citar un número, y decís el crudo y el corregido—, (2) clusters por causa raíz y no por clase de test, (3) split por equipo derivado del package, (4) clasificación de skips, (5) si el release es realmente culpable, reproducido contra prod. | El punto 1. Todo pipeline de reporting junta rarezas, y el número del dashboard es el que termina en un status update. *"Un skill también es donde guardás cómo se leen de verdad los números de tu propio reporte."* |
| `session-status-panel` | Un panel: qué está haciendo cada sesión de agente abierta del proyecto (branch, último turno, en qué está trabada), qué hace CI, qué llegó a los canales. Dispara con la palabra "status". | Va con la slide de background agents: cuando corrés más de una sesión necesitás **una vista sobre tus agentes**, y esa vista es un skill. |
| `release-ticket-structure` | Lee tickets de release management, donde la evidencia de validación vive en **custom fields**, no en comments ni attachments. | **No tiene checklist ni procedimiento**: es una *referencia*. Le dice al agente dónde está la data en un sistema cuya UI la esconde. Cerca de la mitad de los skills del toolkit son referencias. *"Un skill no es sólo un procedimiento; a veces es sólo saber dónde está la data."* |
| `local-ci-compile` | Replica el compile de CI local, offline, en un `git worktree` limpio para que los untracked no causen errores de clase duplicada. | Patrón genérico, y el detalle del worktree no es obvio. |
| `ticket-to-tests-workflow` | El compuesto: ticket → plan → matriz de coverage → implementar → crear los casos en el gestor → mapear ids → PR. | Una línea, como ejemplo de "los skills se componen en pipeline". Demasiado grande para demostrar. |

---

## Hooks y permisos

### El bloque de permissions — el hueco más grande del repo del demo

`settings.json` no es sólo hooks:

```json
{
  "permissions": {
    "allow": [
      "Bash(git status:*)", "Bash(git diff:*)", "Bash(git log:*)",
      "Bash(gh pr view:*)", "Bash(gh pr checks:*)", "Bash(jq:*)"
    ],
    "ask": [
      "Bash(git push:*)", "Bash(gh pr edit:*)",
      "Bash(gh pr review:*)", "Bash(gh pr merge:*)"
    ],
    "deny": [
      "Read(**/secrets.env)", "Read(**/.env)",
      "Read(**/id_rsa)", "Read(**/id_ed25519)"
    ]
  }
}
```

Tres niveles, tres intenciones: **allow** lo read-only y dejás de clickear
aprobar cincuenta veces por día · **ask** todo lo que sale de tu máquina o cambia
lo que otro ve · **deny** los archivos que el agente no tiene que poder leer
siquiera, así ningún prompt lo convence.

*"`ask` es donde vive la firma. Todo lo que sale de tu máquina pasa por ahí."*
Es el hilo de accountability hecho mecánico, en un solo bloque de JSON.

### `check-leaks` como hook de **git**

```bash
ln -s ../../scripts/check-leaks.sh .git/hooks/pre-commit
```

Sirve para marcar la línea que el deck nunca marca: un **hook del harness**
dispara con las tool calls del agente; un **hook de git** dispara sobre el repo,
commitee quien commitee. Al segundo el agente no lo puede esquivar. *"El hook del
agente protege tu sesión; el de git protege el repo — del agente incluido."*

---

## Otros elementos

Acá el toolkit está más lejos del repo del demo, y es todo la misma jugada:
**tratar tu setup de agente como software y aplicarle las prácticas que ya
vendés.**

| Elemento | Qué es | Por qué mostrarlo |
|---|---|---|
| **`test-skills.sh`** | Validación estática de cada skill: 9 chequeos — que el frontmatter parsee, que `name` coincida con el directorio, que los links relativos resuelvan, que los `[[wikilinks]]` apunten a algo, que las variables de config estén declaradas en el `.env.example`, que los scripts pasen `bash -n`, que no queden referencias a archivos borrados. | **La adición más fuerte disponible.** Si `name` no coincide con el directorio, **el harness nunca encuentra el skill**: falla en silencio, para siempre, y parece que el modelo te ignora. Trae su propio disclaimer honesto: *"es análisis estático; no prueba que el skill produzca buen output."* Una charla de QA que muestra tests de su propio setup cierra el loop que abre. |
| **`test-skills-live.sh`** | Smoke tests read-only contra los sistemas reales, con tres resultados: **PASS** (respondió como se esperaba) · **SKIP** (falta una precondición: VPN caída, valor sin configurar — no es un bug) · **FAIL** (el sistema está accesible y se portó mal). Nunca escribe; los skills que escriben están cubiertos sólo hasta sus pre-flight y marcados `WRITE-GATED`. | El SKIP-no-es-FAIL es craft de diseño de tests real, y es la misma distinción que hace `ci-failure-triage` con los flakes. Mismo instinto, un nivel más arriba. |
| **Arquitectura de secretos** | Credenciales en `~/.config/<toolkit>/secrets.env`, modo `0600`, **fuera del repo**. Valores de sitio (org, repo, URLs, ids) en otro archivo, también afuera. El repo sólo trae `*.env.example`. Un script de helpers sourcea los dos, así ningún skill arma `curl` con credenciales inline. | La regla que vale la sección entera: **nunca pases un token como literal en la línea de comandos — queda en el historial de shell *y en el transcript del agente*.** Esa segunda mitad es información nueva para casi toda la sala. |
| **Split config/site** | Si un número, id, URL o path cambia entre equipos o máquinas, va a `site.env` y el skill lee la variable. La variable se agrega al `.env.example` en el mismo cambio — y el chequeo 6 de `test-skills.sh` lo **fuerza**. | Es la maquinaria que le da sustento a la slide de "repo aparte y compartible". Sin esto, "compartible" significa "cada uno lo forkea y edita doce strings hardcodeados". |
| **Knowledge base con forma** | `INDEX.md` (tabla: dominio, **status**, tickets, resumen) · `TEMPLATE.md` con frontmatter tipado · ciclo de vida `hypothesis → open → confirmed` · `[[slug]]` entre entradas · secciones fijas, con **Cómo aplicarlo a futuros tickets** obligatoria. | El campo `status`: *"el agente puede escribir acá, pero tiene que marcar si lo confirmó o lo supone."* Un store escribible por el agente que distingue verificado de supuesto es un artefacto de QA, no una página de wiki. |
| **`Last verified: YYYY-MM-DD`** | Toda afirmación sobre cómo se comporta **hoy** un sistema externo lleva fecha de verificación. | La idea más barata del inventario. Se roba en cinco segundos, y hace visible el vencimiento en vez de dejarlo podrirse en una instrucción que el agente sigue con total confianza. |
| **Distribución como plugin** | `.claude-plugin/plugin.json` + `marketplace.json` + un `install.sh` que mergea el fragmento de settings y linkea los skills. | Tu setup deja de ser "mis dotfiles" y pasa a ser algo que un compañero **instala**. Contrapeso honesto: el deck ya dice que audites plugins de terceros — acá el tercero sos vos. |
| **Slash command envolviendo un skill** | `commands/review-regression.md`, con `argument-hint` y `$1`, y en el cuerpo: *"invocá el skill y seguí sus etapas en orden — no improvises un análisis atajo"*. Si falta el build, listá los recientes, elegí y **decí cuál elegiste**; si hay más de uno plausible, preguntá. | Dos cosas en 30 segundos: un **command** es una puerta de entrada que tipeás, un **skill** lo descubre el modelo — y acá el trabajo del command es impedir que el agente tome el camino corto dentro del skill que acaba de invocar. |
| **`scan_sessions.py`** | Lee los transcripts del harness (JSONL, en disco, por proyecto) e imprime por sesión reciente: branch, cwd, primera tarea, último turno del usuario, último del asistente. | Es la prueba de que "pedile que escanee tus conversaciones pasadas" no es humo: los transcripts son **archivos**, y los archivos se greppean, se cuentan y se resumen. |

### Gobernanza del propio setup

Las cuatro reglas para contribuirle al toolkit: **inglés** · **ni un secreto, ni
en un ejemplo** · **ningún dato personal** (escribí "el operador"; citá el número
de PR, no al reviewer) · **ningún valor de sitio hardcodeado**.

Y dos insights que no son obvios y no son sobre código:

- **Ejemplo vs. dato.** Un ticket id introducido por "e.g." es un ejemplo y va
  como placeholder: uno real se lee como estado vivo y envejece. Un ticket id que
  **es** el contenido (el registry de known issues, una dependencia real, el
  review de donde salió una convención) se queda; reemplazarlo destruye la
  información por la que el artefacto existe. Test: *¿podría el lector seguir
  actuando sobre la línea sin el id?* Si sí, era un ejemplo.
- **Deprecar es borrar.** El historial de git es el archivo. Un directorio
  `removed-*` u `old-*` es peso muerto **que un agente igual puede leer y
  ejecutar.** Esta es genuinamente nueva para casi todos: el código muerto es un
  olor humano, las *instrucciones* muertas son un peligro activo.

---

## Si agregás sólo tres cosas

Ranking por valor de escenario ÷ tiempo de explicar, para un deck que ya está
~18 minutos pasado:

| # | Qué | Cuánto | Dónde |
|---|---|---|---|
| 1 | El bloque `allow`/`ask`/`deny` | ~40 s | apéndice, al lado de la anatomía del hook |
| 2 | `test-skills.sh` | ~60 s | tests para el setup de tests, en una charla de QA |
| 3 | `regression-evidence-scope` | ~45 s | nota al pasar después de la Demo 3, o Q&A backup |

Suplentes, una línea cada uno: las fechas `Last verified:`, el aviso de que los
transcripts son superficie de leak, y la proporción 4 globales / 8 por repo como
versión concreta del argumento de costo de contexto.

## Deliberadamente no mostrable

- **Las entradas del knowledge base.** La estructura sí; el contenido es
  internals del producto puros. Mostrá `TEMPLATE.md` y la forma de una fila del
  índice, nunca una entrada real.
- **El defecto de reporting detrás del paso de totales reconciliados.** El
  toolkit nombra el mecanismo exacto y el multiplicador exacto porque el skill
  necesita eso para hacer la aritmética. Es un bug vivo en la herramienta de un
  equipo y no es del autor para proyectarlo. El paso queda genérico —*cross-check
  de inconsistencias internas y ajustá*— y **no se vuelve a levantar el mecanismo
  del toolkit en un pase futuro.**
- **El validador de nombres de repo contra la política del org.** El patrón es
  bueno (codificar la política escrita de tu organización como un script que el
  agente corre), pero cada tabla de datos que tiene es identificatoria: sufijos
  aprobados, blocklist de palabras redundantes que es literalmente la lista de
  marcas de la empresa. Describí el patrón en una oración; el archivo no va a
  pantalla.
- **Las rules por repo que son puro conocimiento de producto** (convenciones del
  gestor de test cases con ids reales, el mapa de ownership del código
  compartido, la referencia de parámetros de CI). Su *forma* es la parte
  reutilizable y ya está arriba.
- **El nombre del toolkit y el del repo hermano.** Ver la sanitización arriba.
