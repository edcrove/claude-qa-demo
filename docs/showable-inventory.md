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
| el repo hermano del pipeline multi-agente | "el repo hermano" — **también sin nombre** |
| el equipo que revisa y firma | "el equipo de QA" |
| servicios y equipos del árbol de config | `<service>/<team>`: `api/accounts`, `api/catalog`, `legacy-service` |

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
| `session-status-panel` | Con la palabra **"status"** sola, responde tres cosas a la vez: qué está haciendo cada sesión de agente abierta del proyecto (branch, último turno, cuál te dejó una pregunta sin responder), qué hace CI (builds en vuelo y recién terminados), y qué llegó a **Slack** en los canales configurados — sólo lo que te necesita: menciones, pedidos de release, preguntas sobre tus PRs, incidentes. Cierra con **una** acción recomendada, no una lista. | Va con la slide de background agents: cuando corrés más de una sesión necesitás **una vista sobre tus agentes**, y esa vista es un skill. Dos detalles de craft para señalar: el skill **define su formato de salida** (tres bloques, el más accionable primero, sin preámbulo) porque lo vas a leer veinte veces al día; y `"check again"` significa *diffear contra lo último que reportaste y liderar con lo que cambió* — si no cambió nada, decir exactamente eso en una línea. |
| `board-pr-triage` | El dashboard de **las PRs del equipo que no son tuyas**: arranca de la JQL del board, filtra por keyword, busca las PRs abiertas linkeadas a esos tickets, **excluye las tuyas**, y por cada una reporta estado en Jira, aprobaciones contra el mínimo de merge, estado de checks y **si tiene evidencia de CI**. Termina en una decisión por PR: pedir reviewers con `gh`, o correrle la review con agentes. | El que le faltaba al inventario, y el complemento de la Demo 4: esa revisa *una* PR que le señalás, esta gobierna **la cola del equipo**. Tres beats, elegí uno: (1) **contar aprobaciones bien** — la API te da *eventos* de review, no estado, así que hay que quedarse con el más reciente por reviewer y tratar un `CHANGES_REQUESTED` abierto como no-mergeable; el skill es donde vive esa reducción. (2) **"No inventes la JQL"** — el skill le dice al agente que la copie de Board settings → Filter, porque un agente arma una JQL plausible y equivocada sin dudar. (3) **el dashboard termina en una acción**, y una de las dos opciones es invocar otro skill: composición visible. |
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

## El repo hermano — el pipeline multi-agente

Fuente distinta y material distinto. No es una biblioteca de skills y rules: es
un **pipeline de tres agentes con orquestación determinística**. Dado un ticket,
planifica cobertura desde los AC, escribe tests en el framework real del equipo,
los corre contra el ambiente efímero del ticket, **verifica los resultados con un
agente independiente** y entrega para review humano.

Su propio README lo dice sin maquillaje, y esa honestidad es parte de lo
mostrable: *automatiza el primer ~80% de la escritura de tests — **no** reemplaza
el review del equipo de QA. Leé los known issues antes de confiarle algo
desatendido.*

### Los principios, tal como están escritos

Cinco líneas que se pueden poner en pantalla casi textuales:

- **"Green is never the goal."** Que los tests pasen no es el objetivo: verificar
  lo correcto sí. Nunca debilitar, borrar ni tragarse una assertion derivada de un
  AC; nunca `enabled=false` para esconder un rojo. Una falla real del producto se
  reporta roja.
- **Los AC se congelan** cuando el Planner los define: el Runner no los
  reinterpreta a mitad de la corrida.
- **El Verifier es independiente** — valida sin compartir el contexto ni el sesgo
  del Runner.
- **No se lee el código de producto para diseñar los tests.** Se diseñan desde el
  AC y las convenciones declaradas, no inspeccionando la implementación.
- **Nada personal hardcodeado en config compartida.** Con incidente real: el campo
  de assignee estaba fijo a la cuenta de una persona, así que los tickets de todo
  el equipo terminaban asignados a ella. Se arregló resolviéndolo dinámicamente.

### Los cinco agentes

| Agente | Tools / modelo | Su regla no negociable |
|---|---|---|
| `planner` | read-only, ciego al código | Sus gaps son a nivel AC. Si el AC no define algo, **lo reporta como observación de QA** en vez de resolverlo leyendo el código |
| `runner` | escribe y ejecuta | Reconcilia gaps contra el código pero **nunca completa el AC desde el código** |
| `verifier` | `Read`/`Grep`/`Glob`, modelo chico | *"No deferís al resultado autoreportado del Runner: tratalo como un claim a verificar."* Un pass sin assertion que cubra el AC **no es un pass** → `hollow_pass_suspected` |
| `backlog-evaluator` | read-only | Juzga si un ticket está listo para que un dev y un QA arranquen sin suposiciones |
| `backlog-verifier` | **sólo `Read`, sin tools de Jira** | *"Un primer pase marcó este ticket READY. Tu trabajo es asumir que no lo está y encontrar el gap que ese pase se perdió."* |

**El `verifier` es el mejor artefacto de los dos repos para esta audiencia.** Es
literalmente la respuesta a *"¿y quién revisa al agente que escribió los tests?"*:
otro agente, con menos tools, un modelo más chico, sin el contexto del primero, y
con instrucción explícita de no hacer rubber-stamp. Escala a humano cuando el pass
llegó *después de reparaciones*, cuando sospecha un pass hueco o cuando la
evidencia es fina — **nunca hace default a pass.**

Y el `backlog-verifier` trae el argumento que lo justifica, que es de diseño de
tests puro: **la falla es asimétrica.** Un ticket marcado listo por error se
construye mal y nadie lo vuelve a leer; un ticket frenado por error cuesta una
pregunta. Entonces la barra para confirmar "listo" es alta. Más una prohibición
que casi ningún reviewer humano se autoimpone: *"no fabriques un gap para parecer
riguroso"*, y *"si confirmás, confirmá porque buscaste y no encontraste — no
repitiendo el razonamiento del primer pase como acuerdo."*

### Su bloque de permissions — y el contraste con el otro repo

| | El toolkit | El pipeline |
|---|---|---|
| Postura | `allow` / **`ask`** / `deny` | `allow` / `deny`, **sin `ask`** |
| `git push` | va a `ask` | **`deny`** |
| Por qué | sesión interactiva: hay alguien para preguntarle | corre largo y semi-desatendido: no hay nadie a quien preguntarle |

El `deny` del pipeline es el más instructivo de los dos: `sudo`, `rm`, `ssh`,
`scp`, `git push`, `~/.ssh/**`, `~/.aws/**`, `**/.env`, el acceso al **keychain**
del sistema, y `WebFetch`/`WebSearch`.

Los dos últimos merecen una línea cada uno. Bloquear la web significa que el
agente **no puede importar una convención de un blog** mientras escribe tests: sale
del AC y de las convenciones declaradas, o no sale. Y el keychain está ahí por un
incidente real: **un agente intentó leer credenciales del keychain del sistema y
fue bloqueado.** Esa es la respuesta concreta a "¿por qué `deny` y no confianza?".

Y el `allow` enumera las tools de MCP **una por una** — el agente puede crear un
ticket y comentar, y nada más. Un MCP conectado no es un permiso: es una
superficie que también se recorta.

### Las lecciones del POC — la mina para "El modelo se equivoca"

El repo tiene un doc de resultados y lecciones escrito para leadership, y es el
mejor material honesto de los dos repos. Todo esto es genérico:

| Lección | Por qué mostrarla |
|---|---|
| **"El razonamiento es la parte fácil; la disciplina es la difícil."** Los agentes planifican y escriben tests buenos sin esfuerzo. La ingeniería real es mantenerlos honestos y en proceso. | Es la tesis del deck dicha desde otro ángulo, y viniendo de un POC medido pega más fuerte que como opinión. |
| **El agente se salió del proceso.** En vez de resolver el ambiente como estaba prescripto, fue a leer los cambios de código del dev para diseñar los tests. Consecuencia: su cobertura reflejaba **lo que el dev ya había verificado**, no el AC completo — y nunca ejecutó. *"Un test escrito desde el código tiende a pasar por construcción, bug incluido."* | **El mejor ejemplo de falla de agente disponible en cualquiera de los dos repos**, y es QA puro: no es "alucinó un nombre", es "tomó un atajo razonable y produjo cobertura que valida el bug". |
| **"La escalación honesta es una feature, no una falla.** Un sistema que nunca escala es sospechoso: o está inventando o está escondiendo." | Reencuadra el pedido de ayuda del agente como señal de calidad. Regalable en una línea. |
| **"Los guardrails se imponen, no se piden."** Las instrucciones blandas ("no hagas X") no alcanzan para operación desatendida; los límites que importan van hard-blocked. | Es la distinción rule-vs-hook del deck, con su límite honesto: la pirámide es contexto, no enforcement. Y conecta directo con el ítem de *unattended agents* de la última slide. |
| **"Cada fix manual es un upgrade del sistema."** Las correcciones que un QA hizo a mano después de una corrida se plegaron de vuelta a las reglas de los agentes. | El mecanismo de promoción del deck, encontrado de forma independiente por otro proyecto. Es la validación externa de la tesis. |
| **El review humano queda en el loop por diseño.** El valor es un punto de partida al 80% con calidad de review, más una lista precisa de lo que falta. | Cierra igual que el deck: se delega ejecución, no responsabilidad. |

### Patrones de config que se pueden robar

| Patrón | Qué es |
|---|---|
| **Config en tres niveles** | `_shared/` (aplica a todo) → `<service>/` → `<service>/<team>/`, con un flag `has_teams` que decide si el nivel de equipo existe. Cómo escalás config de agentes a varios equipos sin forkear. |
| **Un ticket son tres tickets** | `STORY_TICKET` (dónde viven los AC), `WORK_TICKET` (branch, commits, reporte) y `ENV_TICKET` (de dónde sale la URL del ambiente) son roles distintos y a veces tickets distintos. Nadie lo modela así hasta que se rompe. |
| **`ticket_flow` por equipo** | `create-ste` (el pipeline crea la tarea y la branch) vs `use-existing` (el equipo ya crea la suya). El pipeline **se adapta al proceso de cada equipo** en vez de imponer uno. |
| **`audit-backlog` — el gate más barato** | Corre sobre un sprint entero, no un ticket: decide si un dev y un QA podrían arrancar sin suposiciones, y etiqueta o comenta las preguntas abiertas. *Un AC faltante encontrado acá cuesta un comentario de Jira; el mismo gap encontrado por el Runner cuesta una implementación equivocada y una re-corrida.* Deliberadamente **no** enganchado al pipeline: el grooming tiene su propia cadencia. Y `--dry-run` obligatorio la primera vez. |
| **Escritura acotada por diseño** | El audit escribe **sólo labels y comments**, nunca una transición de estado ni ningún otro campo — y sólo desde el command, nunca desde un subagente. El permiso más chico que hace el trabajo. |

### Ya aplicado al deck

La slide **"El modelo se equivoca"** nació con tres ejemplos autorreferenciales
—la rule que frenó al agente en la Demo 3, y dos afirmaciones del propio deck que
estaban mal— y no se entendía: los ejemplos no compartían forma (uno era "el
agente hizo algo mal", los otros dos "el deck decía algo mal") y pedían contexto
que la sala no tiene. Se reformuló con material de acá:

- **El agente diseñó tests mirando el código del dev** en vez del AC → cobertura
  que pasa por construcción, con el bug adentro. La falla que a un QA le hiela la
  sangre, y no necesita ninguna explicación previa.
- **Un agente intentó leer credenciales del keychain** y lo frenó la capa de
  permisos. Justifica el `deny` en media línea.

Quedó como **taxonomía**: cuatro formas de fallar —inventa, toma un atajo, se pasa
de límite, se olvida— cada una en una fila, y al lado qué la agarra: hook, rule +
skill, permisos, memory. Las cuatro piezas de la pirámide apareciendo como
respuesta a una forma concreta de fallar.

### De este repo, no mostrable

- **El doc de resultados completo.** Tiene tickets reales, nombres de servicios y
  equipos, y evaluación de calidad de trabajo de gente identificable. Las
  lecciones de la tabla de arriba ya están destiladas y son lo reutilizable.
- **El árbol de config con nombres reales** de servicios y equipos, y el
  `domain-knowledge.md` de cada uno — que es conocimiento de producto puro.
- **Las convenciones de authoring por servicio**, que citan clases y paths del
  framework interno.
- **La tabla de metadata del repo** contra la política del org: mismo caso que el
  validador de nombres del otro repo.
- **El nombre del repo.** Ver sanitización arriba.

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

Y si en algún momento se abre espacio para un segundo skill en vivo,
**`board-pr-triage`** es el candidato: la Demo 4 revisa una PR que le señalás,
este gobierna la cola del equipo — y es el único del inventario que termina
invocando otro skill, así que la composición se ve en pantalla en vez de
explicarse.

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
