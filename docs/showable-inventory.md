# Piezas de un setup real

Si viniste de la charla y querés armarte algo parecido, esto es el catálogo. Son
las piezas que uso todos los días en el trabajo: rules, skills, agentes, hooks,
permisos y el andamiaje alrededor.

Cada fila dice **qué hace la pieza y por qué existe** — casi siempre, el dolor
concreto que la hizo aparecer. Esa segunda columna es la que importa: si
reconocés el dolor, la pieza te sirve; si no, salteala. Un setup copiado entero
de otro es tan inútil como no tener ninguno.

**Lo que está en este repo va marcado.** El resto lo tenés que escribir vos, pero
está descrito con suficiente detalle como para que no arranques de cero.

Está ordenado por **tipo de pieza**, no por dónde vive: en mi máquina esto está
repartido en varios repos, y eso es contabilidad mía. Hay una excepción marcada
—`talk-deck-editing`— que no es del setup de trabajo: salió de escribir la charla
y vive acá.

## Los nombres son de mentira

Reemplazalos por los tuyos. Donde leés `api-tests`, `api-regression`,
`PROJ-1234`, `ci.example.com` o `catalogRegression`, va tu repo, tu job, tu clave
de proyecto, tu host. Nada de lo que sigue nombra a mi empleador, un repo real,
un job real ni un ticket real.

Y la lección que vale más que la tabla, si algún día publicás tu setup: **una
promesa de sanear no alcanza, necesitás enforcement.** Este repo trae
`scripts/check-leaks.sh`, que greppea todo el árbol —trackeado y no— buscando
nombres prohibidos y devuelve error. Enganchalo como hook de git y no te podés
olvidar:

```bash
ln -s ../../scripts/check-leaks.sh .git/hooks/pre-commit
```

Ese `ln -s` lo tenés que correr vos: **`.git/hooks/` no se versiona**, así que
clonar el repo te trae el script pero no la protección. Es una trampa cómoda —
asumís que el guard vino con el clone y no vino.

Dos cosas que aprendí escribiéndolo: **nada de tres letras o menos** en la lista
de palabras prohibidas (`gqe` aparecía dentro de un hash base64 y saltaba con
ruido — una palabra que salta con ruido termina en que alguien desactiva el
chequeo entero), y **escapá los puntos** de los patrones de mail, o al pasar a
case-insensitive matchean el espacio de un nombre propio.

---

## Rules

Una rule es un archivo de markdown que se carga en **toda** sesión. Lo primero
que sorprende cuando las juntás: de las que tengo, **sólo un puñado son
prohibiciones.** El resto son otras cosas, y ahí está la parte útil.

### Prohibición

| Rule | Qué dice | Por qué existe |
|---|---|---|
| `no-parallel-ci` | No arranques la suite de regresión si ya hay una corriendo o encolada en el mismo ambiente. | **Está en este repo.** Nació de perder 90 minutos cazando flaky tests que no existían: dos corridas pisándose en el mismo ambiente. Tres detalles que la hacen funcionar: acota el alcance (esa suite, no todas), apunta a un **script guard** que corre igual si el trigger lo dispara una persona, y trae **bypass de emergencia**. Una regla sin válvula de escape no se respeta: se saltea a mano y en silencio. |
| `english-only` | Todo lo que va a GitHub, en inglés. | **Está en este repo.** Nació de un compañero de otra región que no pudo revisar un commit. Lo que la hace sobrevivir al uso real no es la regla, son las **excepciones**: ticket ids, build numbers, nombres de branch, identificadores de código y log excerpts no se traducen. Sin esa lista, la regla se rompe el primer día. |
| `green-is-never-the-goal` | Que los tests pasen no es el objetivo: verificar lo correcto sí. Nunca debilitar, borrar ni tragarse una assertion que viene de un criterio de aceptación. Nunca deshabilitar un test para esconder un rojo. Una falla real del producto se reporta **roja**. | La prohibición más importante que tengo, y la que no necesita explicación para nadie que haya hecho QA: **si le pedís verde, te va a dar verde.** El agente no tiene malicia, tiene un objetivo mal puesto. |
| `no-leer-el-código-para-diseñar-tests` | Los tests se diseñan desde los criterios de aceptación y las convenciones declaradas, **no** inspeccionando la implementación. Si el criterio no define algo, eso se reporta como observación en vez de resolverlo leyendo el código. | Existe por una falla concreta que le vi hacer a un agente (está más abajo, en *Lo que aprendí midiendo*). Un test escrito desde el código **tiende a pasar por construcción, con el bug adentro.** |
| `ac-congelados` | Una vez definidas las assertions que cubren un criterio, el que ejecuta **no las reinterpreta a mitad de la corrida.** | Es la contramedida al derivar-para-que-pase: corta el camino por el que un agente "resuelve" un rojo aflojando lo que había prometido verificar. |

### Formato — mecánicas, baratas, cumplimiento casi perfecto

| Rule | Qué dice | Por qué existe |
|---|---|---|
| `pr-description-ticket-first-line` | Línea 1 del cuerpo de la PR es el ticket. Línea 2 vacía. Y si la PR toca tests, va un bloque de evidencia con el link directo al build, comparación before/after contra la branch principal **en la misma matriz**, y una frase sobre fallas nuevas netas. | Es aburrida, es verificable, y es de lo que todo reviewer reclama para siempre — perfecta para delegar. La mitad interesante es la cláusula de vencimiento: **si entran commits después del build, la evidencia está vieja.** Codifica *cuándo la prueba deja de valer*, que es lo que nadie escribe. |
| `status-format` | Los reportes de estado de CI van en una línea sola: `❌ build 52 — 280 passed / 5 failed (3 flakes, 2 real)`. | **Está en este repo**, y es la rule más chica que tengo: cuatro líneas. Su *por qué* es lo que la hace valer — **el estado se escanea, no se lee.** Un formato consistente te deja triagear de un vistazo y, de paso, hace que esos mensajes se puedan pipear a otra herramienta. Si tenés un mensaje que mandás veinte veces por semana, ése es tu primer candidato a rule. |
| `response-context-header` | Toda respuesta del agente arranca con tres líneas: branch, workspace, hora. | La rara, y por eso vale la pena copiarla: gobierna **cómo te habla el agente**, no qué le hace al código. Nació de trabajar en la branch equivocada porque la respuesta no decía en cuál estaba. Podés gobernar el formato de la respuesta, no sólo la acción. |

### Procedimiento de decisión — la categoría más QA de todas

| Rule | Qué dice | Por qué existe |
|---|---|---|
| `regression-evidence-scope` | Cuánta evidencia debe una PR **según los paths que toca, no según el ticket**: sólo la suite angosta si todo cae dentro de la carpeta de la feature; suite completa **además** si toca framework, clases base o servicios comunes. Si dudás si un path es común, tratalo como común. Y gate rápido primero: la suite completa cuesta una hora, el gate caza el fix roto en minutos. | Si te llevás una sola rule de acá, llevate esta. Tiene tres ideas juntas: **esfuerzo escalado al riesgo**, **default explícito para la ambigüedad** y **chequeo barato antes del caro**. Es lo que un QA con experiencia hace en la cabeza sin darse cuenta — escribirlo es lo que lo hace delegable. |
| `scratchpad-for-working-docs` | Todo doc que genera el agente va a `<repo>/scratchpad/`, gitignoreado. Nunca un `.md` en la raíz. Nunca en el directorio de config de la herramienta. | Un agente que escribe archivos necesita **regla de archivo**, o en seis meses la raíz del repo es un basural de `analysis-final-v2.md`. Nadie lo piensa hasta que ya pasó. |
| `branch-management` | Rebase sobre la branch principal, nunca merge, al actualizar una branch de ticket. `--force-with-lease` después. | Genérica, entra en una pantalla, se copia y pega tal cual. |

Los dos scratchpads, que es lo que hace que la regla se entienda:

| Dónde | Vive | Para |
|---|---|---|
| `<repo>/scratchpad/` | sobrevive la sesión | lo que vas a reabrir: planes, análisis, evidencia |
| el scratchpad de sesión de la herramienta | sólo la sesión | scripts descartables, dumps de JSON, intermedios |

### Vocabulario — la categoría que nadie espera

| Rule | Qué dice | Por qué existe |
|---|---|---|
| `second-checkout-definition` | "R1" es el checkout principal, "R2" el segundo checkout del mismo remoto que uso en paralelo. Los paths salen de config; si R2 no está configurado, decilo en vez de adivinar. | No tiene procedimiento y no prohíbe nada: le enseña al agente **la jerga de tu equipo**. Si en tus reuniones decís "el ambiente viejo" o "la copia dos" y todos entienden, eso es una rule esperando a ser escrita. Una rule también puede ser un glosario. |

### La rule que sale de tus code reviews

**`test-antipatterns`** — la más grande que tengo, y la que mejor muestra de dónde
salen estas cosas: **cada bullet es un defecto que alguien cazó en un review real
y que no quise volver a cazar.** Si tenés reviews donde repetís los mismos
comentarios, ya tenés el borrador escrito, está en los comentarios de tus PRs.

Cuatro ejemplos de los míos, para que veas la forma:

- **Fallá rápido en el setup de suite.** Nada de `catch → log → return null` en
  setup obligatorio: un token nulo cacheado hace que *todo* request dé 401 y
  produce una corrida de fallas masivas confusa en lugar de un error claro.
- **Los smoke tests assertean el valor que consume el path productivo**, no un
  fetch fresco — si no, una regresión de cache pasa el smoke sin que nadie note.
- **Soft assert en las hojas, hard assert en las compuertas.** Los chequeos de
  campos independientes van por soft assert, para que una corrida muestre *todos*
  los campos mal; queda hard cualquier chequeo que habilita un dereference
  posterior, o el path soft explota antes del assert final.
- **Nada de comentarios de IA en ningún lado** — ni prosa de razonamiento en los
  docstrings, ni footer de "generated with" en PRs o commits.

Ese último es el que más gente necesita y menos gente escribe: es una rule cuyo
único trabajo es que **no queden las huellas del agente en el artefacto.** Existe
porque el output se tiene que poder defender como tuyo.

Y un detalle de forma que copiá: cada ítem cita **el número de la PR** de donde
salió, nunca al reviewer. Trazabilidad sin señalar a una persona, y el número no
envejece.

### Dónde poner cada rule

- **Global** (`rules/user/`) → carga en **todos** tus proyectos. Mantené este set
  chico.
- **Por repo** (`rules/workspaces/<repo>/`) → carga en uno solo.

Meter una rule específica de un proyecto en el set global la hace cargar en todos
lados, que es casi siempre lo incorrecto. Si la rule nombra un repo, un job o un
package, va en el set por repo.

Esto no es orden por prolijidad: **lo siempre-cargado es lo único con costo
recurrente**, se paga en cada mensaje de cada sesión. Yo tengo **4 globales y 8
por repo**, y esa proporción es la que hace que el setup no se vuelva caro.

---

## Skills

Un skill es un archivo de markdown que la herramienta carga **sólo cuando hace
falta**. Eso es lo que lo diferencia de una rule, y es lo que te permite tener
veinte sin pagar veinte.

### Planificar

| Skill | Qué hace | Por qué existe |
|---|---|---|
| `ticket-coverage-gap-analysis` | Trae los criterios de aceptación del ticket, greppea las clases y los métodos de test relacionados, **mapea cada test al criterio que cubre** y reporta lo que falta. | **Está en este repo.** Salió de tener la misma conversación de mapeo cuatro sprints seguidos. La versión que uso tiene además un catálogo de *patrones comunes de gap*: lo que típicamente falta, para no redescubrirlo cada vez. |
| `ticket-execution-plan` | Identifica las clases y grupos de test que aplican, arma **el comando local por plataforma**, escribe el plan en el scratchpad y genera el script de trigger de CI. | El detalle que lo hace un plan y no una lista: **resuelve el ambiente desde el estado del ticket de desarrollo.** Si el ticket dev está cerrado, la branch ya está mergeada y va contra el ambiente estable; si no, contra el de la branch. Es una decisión derivada, no un parámetro que le pasás — y es la que más veces me equivoqué a mano. |
| `multi-ticket-work-plan` | Lo mismo para varios tickets a la vez: los trae uno por uno, inventaría los tests que ya existen, define la matriz de dispositivos y escribe un plan único con el orden. | Y una decisión de diseño que vale copiar: el template del doc incluye a propósito **un ticket cuyo ticket dev NO está cerrado**, como segundo ejemplo. Enseñar la forma de la excepción es lo que separa un skill de un tutorial. |
| `ticket-to-tests-workflow` | El compuesto: ticket → plan → matriz de cobertura → implementar → crear los casos en el gestor → mapear ids → PR. | Está acá para mostrar que **los skills se componen**: este no hace nada propio, llama a los otros en orden. Cuando tengas cinco o seis, este es el que aparece solo. |

### Correr y verificar en local

| Skill | Qué hace | Por qué existe |
|---|---|---|
| `local-build-gate` | Typecheck + tests locales antes de disparar CI. | **Está en este repo.** El más barato de todos y el primero que escribí: nació de disparar dos builds seguidos que murieron por un error de tipos que el typecheck agarraba en dos segundos. |
| `local-functional-tests` | Corre la suite funcional en local con la config equivalente a CI, sobre clases ya compiladas. | **Los tres títulos de este skill son lo más útil que tengo para prestarte.** *"BUILD SUCCESS no significa nada"*: el pom trae `testFailureIgnore=true`, así que la herramienta reporta éxito con fallas **y con cero tests** — hay que leer la línea de conteo y confirmar que el número es el esperado. *"¿La falla es mía o del ambiente?"*: un `5xx` upstream es el ambiente, no tu test; compará contra un build reciente del mismo ambiente antes de debuggear. Y *"cómo elegir un subconjunto que sabés verde"*. |
| `local-ci-compile` | Replica el compile de CI en local, offline, en un `git worktree` limpio. | El worktree limpio es el detalle no obvio: los archivos sin trackear de tu copia de trabajo causan errores de clase duplicada que no existen en CI, y te hacen perder una tarde buscando un problema que es tuyo y no del código. |

### CI

| Skill | Qué hace | Por qué existe |
|---|---|---|
| `ci-build-trigger` | Arma y corre el script de trigger: carga de credenciales, crumb de CSRF, el POST, referencia de parámetros, y cómo leer el resultado. | Lo primero que hace es **llamar al guard de no-paralelo**. Las dos capas en el mismo lugar: la rule le habla al agente, el script corre igual si el trigger lo dispara una persona. |
| `ci-failure-triage` | Clasifica las fallas de un build en regresión real / flake conocido / infraestructura, contra un registro de flakes. | **Está en este repo.** Salió de contestar las mismas tres preguntas todos los lunes a la mañana. |
| `known-issues-registry-update` | Agrega al registro un flake confirmado: nombre del test, firma de la falla, frecuencia, builds de primera y última aparición. | **Está en este repo.** Y el detalle que hace la diferencia: pide **2 o más apariciones.** Una sola falla nunca es un flaky test, y el sesgo del skill es a flaggear de más, no de menos. |
| `ci-regression-review` | Produce un **veredicto, no una lista**: totales reconciliados, clusters por causa raíz en vez de por clase de test, split por equipo derivado del package, clasificación de skips, y si el release es realmente culpable — reproducido contra producción. | Los totales reconciliados son la parte que más gente necesita: **todo pipeline de reporting junta rarezas** —una corrida contada dos veces, un fork que falta del resumen, un retry inflando un número— y el número del dashboard es el que termina en un status update. Cross-checkeá los totales antes de citarlos, y decí el crudo y el corregido. |

### Review

| Skill | Qué hace | Por qué existe |
|---|---|---|
| `pr-review-domain-agents` | Despacha **cinco reviewers en paralelo** (más abajo, en *Agentes*) y después aplica dos **gates bloqueantes calculados desde los paths tocados**: si algún archivo cae fuera del árbol de tu equipo, no es un merge solo tuyo — pide review del equipo dueño, aviso en el canal compartido y un chequeo de si el fix podía portarse a tu propio árbol; y si toca código común, exige la evidencia de regresión completa. Cierra con un reporte unificado y **pregunta qué aplicar**. | **Hay una versión simplificada en este repo** (la que corre en la demo, con reviewers genéricos de un plugin). Lo que agrega la versión real son los gates, y por qué valen: **no son opiniones, son decisiones mecánicas sacadas de la lista de archivos.** Y el orquestador tiene instrucción de liderar con el gate cross-team, porque un cambio en código compartido es un bloqueante de merge, no un nit. |
| `board-pr-triage` | El dashboard de **las PRs del equipo que no son tuyas**: arranca de la consulta del board, filtra por keyword, busca las PRs abiertas linkeadas a esos tickets, **excluye las tuyas**, y por cada una reporta estado del ticket, aprobaciones contra el mínimo de merge, estado de checks y si tiene evidencia de CI. Termina en una decisión por PR. | Tres cosas para robar. **Contar aprobaciones bien:** la API te da *eventos* de review, no estado — hay que quedarse con el más reciente por reviewer y tratar un "cambios pedidos" abierto como no-mergeable. **"No inventes la consulta":** el skill le dice al agente que la copie de la config del board, porque un agente arma una consulta plausible y equivocada sin dudar un segundo. Y **el dashboard termina en una acción**, no en una lista — una de las opciones es invocar otro skill. |

### Conocimiento y referencia

| Skill | Qué hace | Por qué existe |
|---|---|---|
| `feature-knowledge-base` | **Recall** al empezar un ticket: greppea la base por endpoint, dominio o región, lee lo que matchea, sigue los links entre entradas y te dice qué se sabe *antes* de proponer trabajo. **Capture** después de analizar: copia el template, llena el frontmatter, escribe qué aprendimos, la evidencia y cómo aplicarlo. | El que más cambia lo que uno cree que *es* un skill: es **memoria durable que no es la feature de memoria de la herramienta.** Archivos planos, greppeables, que sirven en cualquier agente. Su barra de calidad es la frase que más uso: *una entrada que sólo registra qué pasó es un changelog, no conocimiento.* |
| `release-ticket-structure` | Lee los tickets de release management, donde la evidencia de validación vive en **campos custom**, no en comentarios ni adjuntos. | **No tiene checklist ni procedimiento: es una referencia.** Le dice al agente dónde está la data en un sistema cuya interfaz la esconde. Casi la mitad de mis skills son así, y es la categoría que más se subestima — un skill no es sólo un procedimiento, a veces es sólo saber dónde está la data. |
| `test-case-manager-workflow` | Crea y mantiene secciones y casos en el gestor de test cases: inspeccionar la estructura, crear bajo el padre correcto, cargar los campos, traer los ids para mapearlos. Con un paso de **verificación pre-PR marcado obligatorio** y otro para retirar casos viejos. | Su primera línea es el hallazgo: **el MCP conectado no expone ninguna tool**, así que todo va por la API REST. Si tenés una integración conectada que no sirve, escribir eso —y cuál es el camino que sí funciona— ahorra que alguien lo descubra una segunda vez. |

### Panel y despliegue

| Skill | Qué hace | Por qué existe |
|---|---|---|
| `session-status-panel` | Con la palabra **"status"** sola: qué está haciendo cada sesión de agente abierta del proyecto (branch, último turno, cuál te dejó una pregunta sin responder), qué hace CI, y qué llegó a Slack en los canales que configurás — sólo lo que te necesita. Cierra con **una** acción recomendada, no una lista. | Cuando corrés más de una sesión a la vez, necesitás **una vista sobre tus agentes**, y esa vista es un skill. Dos detalles de forma: **define su propio formato de salida** (tres bloques, el más accionable primero, sin preámbulo) porque lo vas a leer veinte veces al día; y "chequeá de nuevo" significa *diffear contra lo último que reportaste y liderar con lo que cambió* — si no cambió nada, decirlo en una línea en vez de repetir el panel. |
| `preprod-deploy` | Dispara el deploy de una branch a preproducción. | **El ejemplo más puro de "un skill es donde vive el gotcha".** Los parámetros de ese job son dinámicos: si el job no fue consultado por API en esta sesión, el trigger **descarta silenciosamente todos los parámetros** y el build muere mucho más adelante con un error que no dice nada. Y el "primado" no es un no-op: corre el pipeline completo con los defaults y *los deploya*, quince minutos. Por API cuesta **dos builds**. El skill trae el one-liner que te dice si hace falta primar antes de tocar nada. Eso es un día de alguien, escrito una vez. |

### El setup sobre sí mismo

| Skill | Qué hace | Por qué existe |
|---|---|---|
| `talk-deck-editing` | Las reglas de cómo se edita el deck de esta charla: el gate de render que toda edición tiene que pasar, las fallas que son **silenciosas** (slides recortadas, paths relativos que dejan de resolver, una línea en blanco adentro de un `<svg>`, una clase de CSS que sólo desvía el color en un tema), los **callbacks que se editan de a pares**, y la regla de que las afirmaciones se verifican en vez de recordarse. | **Está en este repo**, y es la única pieza del catálogo cuyo tema es la charla misma. Cada regla que tiene está porque ya salió mal una vez. Está acá por una razón práctica: **si tu artefacto principal no es código, igual tiene reglas de edición**, y probablemente las estés repitiendo de memoria cada vez. Un deck, un doc de arquitectura, un runbook: todos tienen su gate y sus trampas silenciosas. |

Va de la mano con **`test-skills.sh`** (más abajo): son la misma jugada a dos
niveles. Uno testea tus skills, el otro codifica cómo se edita tu propio
artefacto.

---

## Agentes

Un agente no es "otro Claude": se le define un **rol**, sus **tools**, su
**criterio** y su **modelo**. Eso es todo, y se escribe en un archivo de markdown
como cualquier otra pieza. Acá hay dos grupos.

### Los cinco reviewers de PR

Hay plugins públicos que traen cinco reviewers **genéricos** —código, fallas
silenciosas, tipos, comentarios, tests— y son un excelente punto de partida: la
versión que corre en la demo de este repo es esa. Pero los que uso en el trabajo
son otros:

| Reviewer | Qué chequea |
|---|---|
| **Dev code** | Estructura, redundancia, constantes en vez de strings mágicos, imports, estilo. Y seis ítems que son la rule `test-antipatterns` convertida en prompt |
| **Experto del framework** | Diseño del test, patrones de login, flakiness, y **las convenciones de nombres de tu repo** — incluido qué anotación **no** se usa acá aunque sí en el repo de al lado |
| **Sync con el gestor de casos** | Que la cantidad de tests matchee la de casos, la etiqueta de creado-por-IA, la referencia al ticket, que no queden casos huérfanos, que ningún título tenga un ticket id |
| **Cobertura de criterios** | **Mapea cada criterio de aceptación a un test** y marca el que no tiene ninguno. Tipos de usuario, regiones, plataformas, casos de error |
| **Analista de comentarios** | Clasifica los comentarios que ya dejaron los reviewers —fix de código / explicación / aclaración / ya resuelto—, redacta las respuestas… y **no postea nada** |

**Por qué vale escribir los tuyos.** Ningún reviewer genérico puede saber que el
id de tu caso de test es un prefijo del nombre del método, ni que tal anotación
aplica en un repo del monorepo y no en el otro, ni qué criterio pedía el ticket.
Eso no es un code smell: es tu convención. Un plugin sabe de código; el que
escribís vos sabe de tu equipo.

Y ahí se cierra un círculo: **la rule le dice al agente cómo escribir, el reviewer
chequea que lo hizo.** El mismo conocimiento en los dos extremos del ciclo, salido
del mismo review repetido.

Tres detalles de diseño que copiaría tal cual:

- **La política de auto-fix, partida en dos.** Un solo reviewer arregla sin
  preguntar: metadata del gestor de casos, que no cambia el comportamiento de
  ningún test. Todo lo demás se reporta y espera aprobación. Es una línea
  defendible de qué toca un agente sin que lo miren.
- **El analista de comentarios tiene prohibido postear.** Analiza y devuelve;
  postea el orquestador después de que elegís vos.
- **El de cobertura corre un chequeo de salud de datos** contra el ambiente, para
  separar *"falta cobertura"* de *"los datos del ambiente no soportan ese
  escenario"*. Un reviewer que exige un test imposible pierde credibilidad rápido.

### El pipeline: planificar → escribir → verificar

Tres agentes con orquestación determinística: dado un ticket, planifica la
cobertura desde los criterios, escribe los tests en el framework real del equipo,
los corre contra el ambiente efímero del ticket, **verifica los resultados con un
agente independiente** y entrega para review humano.

Lo digo sin maquillaje porque es parte de lo útil: automatiza el primer ~80% de
la escritura de tests, **no** reemplaza el review de una persona.

| Agente | Tools / modelo | Su regla no negociable |
|---|---|---|
| `planner` | read-only, ciego al código | Sus gaps son a nivel criterio. Si el criterio no define algo, **lo reporta como observación** en vez de resolverlo leyendo el código |
| `runner` | escribe y ejecuta | Reconcilia gaps contra el código pero **nunca completa el criterio desde el código** |
| `verifier` | `Read`/`Grep`/`Glob`, modelo chico | *"No deferís al resultado autoreportado del runner: tratalo como un claim a verificar."* Un pass sin assertion que cubra el criterio **no es un pass** |
| `backlog-evaluator` | read-only | Juzga si un ticket está listo para que un dev y un QA arranquen sin suposiciones |
| `backlog-verifier` | **sólo `Read`, sin tools del gestor de tickets** | *"Un primer pase marcó este ticket listo. Tu trabajo es asumir que no lo está y encontrar el gap que ese pase se perdió."* |

**Si te llevás un solo agente de acá, llevate el `verifier`.** Es la respuesta a
la pregunta que todos hacen: *"¿y quién revisa al agente que escribió los
tests?"*. Otro agente, con menos tools, un modelo más chico, sin el contexto del
primero, y con instrucción explícita de no hacer rubber-stamp. Escala a un humano
cuando el pass llegó *después de reparaciones*, cuando sospecha un pass hueco, o
cuando la evidencia es fina. **Nunca hace default a pass.**

Y el `backlog-verifier` trae el argumento que justifica todo esto, que es diseño
de tests puro: **la falla es asimétrica.** Un ticket marcado listo por error se
construye mal y nadie lo vuelve a leer; un ticket frenado por error cuesta una
pregunta. Entonces la barra para confirmar "listo" es alta. Y una prohibición que
casi ningún reviewer humano se autoimpone: *"no fabriques un gap para parecer
riguroso"*, y *"si confirmás, confirmá porque buscaste y no encontraste — no
repitiendo el razonamiento del primer pase como acuerdo."*

---

## Hooks y permisos

### El bloque de permisos, que es lo primero que yo copiaría

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

Si tuviera que resumir por qué importa: **`ask` es donde vive tu firma.** Todo lo
que sale de tu máquina pasa por ahí. Son veinte líneas de JSON y es lo que
convierte "confío en el agente" en algo mecánico.

### Y una segunda postura, para cuando no hay nadie mirando

Un pipeline que corre largo y semi-desatendido necesita otro bloque:

| | Sesión interactiva | Corrida semi-desatendida |
|---|---|---|
| Niveles | `allow` / **`ask`** / `deny` | `allow` / `deny`, **sin `ask`** |
| `git push` | va a `ask` | **`deny`** |
| Por qué | hay alguien a quien preguntarle | no hay nadie a quien preguntarle |

El `deny` de la segunda es el más instructivo: `sudo`, `rm`, `ssh`, `scp`,
`git push`, `~/.ssh/**`, `~/.aws/**`, `**/.env`, el acceso al **keychain** del
sistema, y las tools de búsqueda web.

Los dos últimos merecen una línea cada uno. Bloquear la web significa que el
agente **no puede importar una convención de un blog** mientras escribe tests:
sale de los criterios y de las convenciones declaradas, o no sale. Y el keychain
está ahí porque **un agente intentó leer credenciales del keychain del sistema y
fue bloqueado.** Si te preguntás por qué `deny` y no confianza, ésa es la
respuesta.

Y el `allow` enumera las tools de las integraciones **una por una** — el agente
puede crear un ticket y comentar, y nada más. Una integración conectada no es un
permiso: es una superficie que también se recorta.

### El hook que ejecuta el runtime, no el modelo

**Está en este repo**, y son seis líneas en `.claude/settings.json`: después de
cada edición de un archivo `.ts`, corre el typecheck.

```json
{ "hooks": { "PostToolUse": [ { "matcher": "Edit|Write|MultiEdit",
  "hooks": [ { "type": "command", "command": "<corré tu typecheck>" } ] } ] } }
```

Salió de olvidarme de correr el typecheck después de que el agente editaba: primero
fue una corrección que repetí, después una nota en memoria, después un skill, y
recién al final esto. Lo que cambia al llegar acá es una sola cosa y es la que
importa: **ya no depende de que el modelo se acuerde.** Lo ejecuta el runtime
después de cada edición, no consume contexto, y no se puede saltear.

Y el límite honesto, que conviene saber antes de convertir todo en hooks: **un
hook no razona.** Matchea una tool y corre un comando. Todo lo que necesite
criterio —decidir *si* corresponde, elegir *qué* correr— sigue siendo un skill o
una rule. Por eso son pocas las piezas que llegan hasta acá.

### El hook de git, que el agente no puede esquivar

```bash
ln -s ../../scripts/check-leaks.sh .git/hooks/pre-commit
```

Vale la distinción: un **hook de la herramienta** dispara con las tool calls del
agente; un **hook de git** dispara sobre el repo, commitee quien commitee. El
hook del agente protege tu sesión; el de git protege el repo — del agente
incluido.

Y acordate de que este no viaja: `.git/hooks/` no se versiona, así que en cada
clon hay que volver a linkearlo. Si te importa que no se olvide, ponelo en el
README o en un `make setup`.

---

## Otros elementos

Todo lo que sigue es la misma jugada: **tratar tu setup de agente como software y
aplicarle las prácticas que ya usás en el trabajo.**

| Elemento | Qué es | Por qué existe |
|---|---|---|
| **`test-skills.sh`** | Validación estática de cada skill: 9 chequeos — que el frontmatter parsee, que el `name` coincida con el nombre del directorio, que los links relativos resuelvan, que los links entre docs apunten a algo, que las variables de config estén declaradas en el `.env.example`, que los scripts pasen `bash -n`, que no queden referencias a archivos borrados. | **Lo primero que le agregaría a cualquier setup que ya tenga tres o cuatro skills.** El chequeo del `name` es el que más duele: si no coincide con el directorio, **la herramienta nunca encuentra el skill** — falla en silencio, para siempre, y parece que el modelo te ignora. Y trae su propio disclaimer honesto: es análisis estático, no prueba que el skill produzca buen output. |
| **`test-skills-live.sh`** | Smoke tests read-only contra los sistemas reales, con tres resultados: **PASS** (respondió como se esperaba) · **SKIP** (falta una precondición: VPN caída, valor sin configurar — no es un bug) · **FAIL** (el sistema está accesible y se portó mal). Nunca escribe. | El SKIP-no-es-FAIL es la misma distinción que hacés cuando triageás flakes, aplicada un nivel más arriba. Y los skills cuyo propósito *es* escribir están cubiertos sólo hasta su pre-flight, marcados como tal — un smoke test que dispara un deploy no es un smoke test. |
| **Arquitectura de secretos** | Credenciales en `~/.config/<app>/secrets.env`, modo `0600`, **fuera del repo**. Valores que cambian por equipo o por máquina (org, repo, URLs, ids) en otro archivo, también afuera. El repo sólo trae `*.env.example`. Un script de helpers sourcea los dos, así ningún skill arma `curl` con credenciales inline. | La regla que vale toda la fila: **nunca pases un token como literal en la línea de comandos.** Queda en el historial de shell *y en el transcript del agente*. Esa segunda mitad es la que casi nadie tiene presente: el transcript es una superficie de leak nueva. |
| **Split config/site** | Si un número, id, URL o path cambia entre equipos o máquinas, va a un archivo de config y el skill lee la variable. La variable se agrega al `.env.example` en el mismo cambio — y el chequeo 6 de `test-skills.sh` lo **fuerza**. | Es la maquinaria que hace que un setup sea **compartible de verdad.** Sin esto, "compartible" significa "cada uno lo forkea y edita doce strings hardcodeados", y a la tercera persona ya divergió. |
| **Config en tres niveles** | Lo compartido arriba → por servicio → por equipo, con un flag que decide si el nivel de equipo existe. | Cómo escalás config de agentes a varios equipos sin forkear el setup. Lo genérico arriba, la decisión de cada equipo abajo. |
| **Un ticket son tres tickets** | El ticket que tiene los criterios, el ticket donde viven la branch y el reporte, y el ticket del que sale la URL del ambiente son **roles distintos**, y a veces tickets distintos. | Nadie lo modela así hasta que se rompe. Es el tipo de detalle que hace que un pipeline funcione en un equipo y no en el de al lado. |
| **El proceso de cada equipo, no el tuyo** | Un flag por equipo elige entre "el pipeline crea la tarea y la branch" y "el equipo ya crea la suya, usala como está". | El pipeline **se adapta al proceso existente** en vez de imponer uno. Es la diferencia entre que lo adopten y que lo esquiven, y no cuesta casi nada dejarlo configurable. |
| **El gate más barato del flujo** | Un comando corre sobre un sprint entero (no un ticket) y decide si un dev y un QA podrían arrancar sin suposiciones: etiqueta, o comenta las preguntas abiertas. **No** está enganchado al pipeline — el grooming tiene su propia cadencia. Con `--dry-run` obligatorio la primera vez. | Un criterio faltante encontrado acá cuesta un comentario; el mismo gap encontrado por el que escribe los tests cuesta una implementación equivocada y una re-corrida. Es shift-left aplicado al backlog en vez de al código. |
| **Escritura acotada por diseño** | Ese comando escribe **sólo etiquetas y comentarios** — nunca una transición de estado ni ningún otro campo — y sólo desde el comando, nunca desde un subagente. | El permiso más chico que alcanza para hacer el trabajo. No todo se resuelve en `deny`: parte se resuelve acotando qué escribe cada pieza. |
| **Knowledge base con forma** | Un índice (dominio, **estado**, tickets, resumen) · un template con frontmatter tipado · ciclo de vida `hipótesis → abierto → confirmado` · links entre entradas · secciones fijas, con **"cómo aplicarlo a futuros tickets"** obligatoria. | El campo de estado es el que la salva: **el agente puede escribir acá, pero tiene que marcar si lo confirmó o lo supone.** Un store escribible por un agente que distingue verificado de supuesto es un artefacto de QA; sin ese campo es una página de wiki que envejece. |
| **`Last verified: YYYY-MM-DD`** | Toda afirmación sobre cómo se comporta **hoy** un sistema externo lleva fecha de verificación. | Lo más barato de todo el catálogo: se copia en cinco segundos y hace visible el vencimiento, en vez de dejarlo podrirse en una instrucción que el agente sigue con total confianza. |
| **Distribución como plugin** | Un manifiesto, un marketplace local y un `install.sh` que mergea el fragmento de settings y linkea los skills. | Tu setup deja de ser "mis dotfiles" y pasa a ser algo que un compañero **instala**. Contrapeso honesto: si vas a pedirle a tu equipo que audite plugins de terceros, acá el tercero sos vos. |
| **Slash command envolviendo un skill** | Con hint de argumentos, y en el cuerpo: *"invocá el skill y seguí sus etapas en orden — no improvises un análisis atajo"*. Si falta el argumento, listá las opciones, elegí y **decí cuál elegiste**; si hay más de una plausible, preguntá. | Un **command** es una puerta de entrada que tipeás; un **skill** lo descubre el modelo. Y el trabajo del command acá es impedir que el agente tome el camino corto dentro del skill que acaba de invocar — algo que va a intentar. |
| **Escanear tus propias conversaciones** | Un script que lee los transcripts de la herramienta (JSONL, en disco, por proyecto) e imprime por sesión reciente: branch, directorio, primera tarea, último turno tuyo, último del asistente. | La prueba de que "pedile que escanee tus conversaciones pasadas" no es humo: **los transcripts son archivos**, y los archivos se greppean, se cuentan y se resumen. Es también de dónde salen los candidatos a skill que todavía no escribiste. |

### Cuatro reglas para el setup en sí

Si vas a compartir el tuyo: **inglés** (o el idioma común de tu equipo) ·
**ni un secreto, ni en un ejemplo** · **ningún dato personal** · **ningún valor
que cambie entre máquinas, hardcodeado.**

Las dos últimas tienen el mismo incidente detrás: **un campo de assignee estaba
fijo a la cuenta de una persona**, así que los tickets que creaba el agente para
todo el equipo terminaban asignados a ella. Se arregló resolviéndolo
dinámicamente en tiempo de corrida. Escribí "el operador", nunca un nombre; y
cuando registres feedback de un review, citá **el número de la PR** en vez del
reviewer — es la fuente verificable y no envejece.

Y dos cosas que no son obvias y no son sobre código:

- **Ejemplo vs. dato.** Un ticket id introducido por "por ejemplo" es un ejemplo y
  va como placeholder: uno real se lee como estado vivo y envejece. Un ticket id
  que **es** el contenido (el registro de flakes, una dependencia real, el review
  de donde salió una convención) se queda; reemplazarlo destruye la información
  por la que el artefacto existe. El test: *¿podrías seguir actuando sobre la
  línea si le sacás el id?* Si sí, era un ejemplo.
- **Deprecar es borrar.** El historial de git es el archivo. Un directorio
  `removed-*` u `old-*` es peso muerto **que un agente igual puede leer y
  ejecutar.** El código muerto es un olor humano; las *instrucciones* muertas son
  un peligro activo.

---

## Lo que aprendí midiendo

No son piezas: son hallazgos de correr esto contra tickets y ambientes reales. Es
la parte que te va a ahorrar más tiempo, porque son los errores que ya cometí.

| Lección | Por qué te importa |
|---|---|
| **El razonamiento es la parte fácil; la disciplina es la difícil.** Los agentes planifican y escriben tests buenos sin esfuerzo. La ingeniería real es mantenerlos honestos y en proceso. | Si esperabas que lo difícil fuera que escriba código decente, te vas a sorprender para el otro lado. Todo el diseño de arriba —las rules, los gates, el verifier— existe por esto. |
| **Un agente se salió del proceso.** En vez de resolver el ambiente como estaba prescripto, fue a leer los cambios de código del dev para diseñar los tests. Su cobertura reflejaba **lo que el dev ya había verificado**, no los criterios completos — y nunca ejecutó. | Es la falla que más asusta y no es "alucinó un nombre": **tomó un atajo razonable y produjo cobertura que valida el bug.** Un test escrito desde el código tiende a pasar por construcción. De acá salió la rule de no leer el código. |
| **La escalación honesta es una feature, no una falla.** Un sistema que nunca escala es sospechoso: o está inventando o está escondiendo. | Cambia cómo lees el output. Cuando el agente dice "verifiqué X pero no Y", ésa es la corrida en la que podés confiar. |
| **Los guardrails se imponen, no se piden.** Las instrucciones blandas ("no hagas X") no alcanzan para operación desatendida; los límites que importan van hard-blocked. | Es el límite honesto de todo lo de arriba: las rules son contexto, no enforcement. Si vas a dejar un agente corriendo sin mirar, lo que importa va en permisos o en un hook. |
| **Cada fix manual es un upgrade del sistema.** Las correcciones que hice a mano después de una corrida se plegaron de vuelta a las reglas de los agentes. | Es el mecanismo entero, en una frase. Si corregís lo mismo tres veces y no lo escribís, lo vas a corregir una cuarta. |
| **El review humano queda en el loop por diseño.** El valor es un punto de partida al 80% con calidad de review, más una lista precisa de lo que falta. | Se delega ejecución, nunca responsabilidad. Si alguien pregunta por qué se mergeó algo, la respuesta sos vos. |

---

## Si copiás sólo tres cosas

Ordenadas por valor sobre esfuerzo, para alguien que arranca el lunes:

| # | Qué | Esfuerzo | Qué te da |
|---|---|---|---|
| 1 | El bloque `allow`/`ask`/`deny` de `settings.json` | veinte minutos, una vez | Dejás de aprobar cincuenta prompts por día, y lo que sale de tu máquina pasa por un punto explícito |
| 2 | `test-skills.sh` sobre los skills que ya tengas | media tarde | Deja de fallar en silencio el error más común: un skill que la herramienta nunca encuentra |
| 3 | La rule de alcance de evidencia | una hora de escribirla bien | Convierte en explícito el criterio que hoy tenés sólo en la cabeza — y por eso no podés delegar |

Y dos que se copian en cinco minutos: las fechas **`Last verified:`** en cualquier
afirmación sobre un sistema externo, y anotarte que **el transcript del agente es
una superficie de leak** — nunca un token como literal en la línea de comandos.

Si te llevás una idea sola y ninguna pieza, que sea ésta: **la próxima corrección
que repitas por tercera vez, escribila.** Todo lo de arriba salió de ahí.

## Lo que no publiqué, y por qué

Si vas a compartir tu setup, esta lista te va a servir más que cualquier otra
sección — es la parte que hay que decidir *antes* de subir el repo.

- **Las entradas del knowledge base.** La estructura sí; el contenido es
  internals del producto puros. Se publica el template y la forma de una fila del
  índice, nunca una entrada real.
- **El doc de resultados del piloto completo.** Tiene tickets reales, nombres de
  servicios y equipos, y evaluación de calidad de trabajo de gente
  identificable. Las lecciones de la tabla de arriba son lo destilado y lo
  reutilizable; el resto no es mío para publicar.
- **El defecto de reporting exacto** detrás del paso de totales reconciliados. El
  skill nombra el mecanismo y el multiplicador porque necesita eso para hacer la
  aritmética. Es un bug vivo en la herramienta de un equipo. El paso queda
  genérico —cross-check de inconsistencias internas y ajustá— y alcanza.
- **El árbol de config con nombres reales** de servicios y equipos, y el
  conocimiento de dominio de cada uno, que es producto puro. Lo mismo las
  convenciones de authoring por servicio, que citan clases y paths internos.
- **Los validadores de política de la organización** (nombres de repo, metadata).
  El patrón es bueno —codificar la política escrita de tu organización como un
  script que el agente corre— pero cada tabla de datos que tienen es
  identificatoria: sufijos aprobados, y una blocklist de palabras redundantes que
  es literalmente la lista de marcas de la empresa. Copiá el patrón, no el
  archivo.
- **Las rules por repo que son puro conocimiento de producto.** Su *forma* es la
  parte reutilizable, y está arriba.
