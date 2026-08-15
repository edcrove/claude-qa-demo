# Tu setup de QA no se diseña: se cultiva

De prompt suelto a skills, rules y hooks.

Edgardo Crovetto · 2026

---

# Una noche perdí 90 minutos cazando flaky tests fantasma

Dos builds, mismo ambiente, mismas credenciales — sin que nadie lo supiera. Todo rojo. Nada roto.

Hoy eso no puede volver a pasarme. Y no es porque yo me acuerde: es porque mi setup se acuerda por mí.

Esta charla es la historia de cómo llegué ahí.

---

# Quién soy

Edgardo Crovetto · Senior QA automation engineer

Java + TypeScript · tests automatizados · CI/CD · pipelines

Me gusta mejorar procesos — sobre todo los que ya estaban funcionando.

Esta charla no es sobre features. Es sobre un patrón que se repite, y lo que hacés con eso.

---

# La pregunta de hoy

¿Puedo automatizar mi proceso de QA con IA?

Spoiler: sí — sobre las bases que ya tenés.

---

# Mi setup antes de IA

Plataforma de streaming, servicio backend REST.

Framework: Java + TestNG + RestAssured + Allure reports + Jira + TestRail + Jenkins.

El pipeline diario, paso a paso:

1. Ticket de Jira con los cambios y los acceptance criteria
2. Análisis del cambio y generación de tests
3. TestRail mapea automation, casos y coverage
4. Jenkins corre build y regression
5. PR con review de dos peers y checkstyle automático
6. Análisis local y de Jenkins, bugs a Jira, follow-up del ciclo

Funcionaba. Pero todo el conocimiento de cada ticket vivía en mi cabeza.

---

# Tu día como QA, hoy

**Análisis del ticket** — Jira, repo, Confluence y TestRail. Nada de eso queda escrito en un solo lugar.

**Mapeo AC contra cambio** — comparás docs y branch a ojo, página por página.

**Test cases y automation** — copiás AC a TestRail, traducís a TestNG/RestAssured, linkeás IDs a mano.

**Ejecución multi-ambiente** — Jenkins contra tres ambientes, comparás resultados, investigás cada rojo.

**PR review** — armás la evidencia, pingeás dos peers, esperás, re-pingeás.

**Bug encontrado** — abrís ticket, pegás logs, seguís el ciclo de vida en Jira.

**Mañana** — sesión nueva. Re-explicás el ticket, el plan, las convenciones.

Mucho de eso es conocimiento que se pierde entre sesiones.

---

# ¿Y si ese conocimiento sobreviviera?

---

# La tesis

Mi setup no se diseña.

Se cultiva.

---

# Mis primeros pasos con Claude

**Conectar Claude al repo del trabajo.** Todo arrancó con un CLAUDE.md de apenas 5 líneas, y se lo pedís en la conversación en vez de escribirlo a mano. Lo demás vino con el tiempo.

**Agregar MCPs, uno a uno.** Jira, TestRail, Jenkins, Confluence.

A partir de ahí: prompts del día a día. No hubo plan. Aparecieron patrones.

---

# Cómo Claude conoce mi proyecto

Cinco lugares, todos texto plano en disco, versionados y reviewables:

**CLAUDE.md global** — tus preferencias, tu identidad como usuario.

**CLAUDE.md del proyecto** — las convenciones del repo.

**.claude/skills/** — workflows invocables bajo demanda.

**.claude/rules/** — guardrails siempre cargados.

**memory/** — hechos que sobreviven entre sesiones.

**.claude/settings.json** — hooks automáticos.

---

# MCPs: los puentes a sistemas externos

Memory, skills, rules y hooks viven en tu repo. El trabajo real cruza varios sistemas, y los MCPs los conectan. Conectar uno también se pide en conversación: no hay instalador que armar a mano.

| MCP | Para qué lo uso |
|---|---|
| Jira | Leer ticket y acceptance criteria, comentar, transicionar el estado |
| TestRail | Leer y escribir test cases, asociar runs a builds |
| Jenkins | Triggerear builds, leer resultados, descargar logs |
| Confluence | Leer specs y acceptance criteria |

Una sola conversación con Claude puede pasar por los cuatro.

---

# La pirámide de promoción

Una sola historia: el typecheck que me olvidaba después de cada rebase, subiendo un nivel cada vez que el anterior no alcanzó.

**Nivel 1 — Prompt suelto.** "Acordate del typecheck antes de CI", una y otra vez.

**Nivel 2 — Memory.** feedback-local-build-before-ci. Y me lo olvidé igual.

**Nivel 3 — Skill.** local-build-gate: lo corre Claude cuando hace falta. La mayoría de las piezas se quedan acá.

**Nivel 4 — Rule.** Siempre cargada, pero Claude decide cómo aplicarla.

**Nivel 5 — Hook.** Typecheck en cada edit: corre solo, ya no depende de nadie.

Saltea la Rule, y no es olvido: una rule me lo recuerda, y el problema era justamente que recordármelo no alcanzaba. Pocas piezas llegan hasta arriba. No es una escalera que subís entera, es un menú. La Rule tiene su propia cicatriz: no-parallel-ci, los 90 minutos del principio.

Ninguna pieza se diseñó. Cada una fue admitir que acordarse no escala.

---

# Un skill no siempre ejecuta: a veces delega

multi-agent-pr-review es un SKILL.md como cualquier otro, markdown en tu repo, la misma pirámide. Lo distinto es lo que hace adentro: en vez de correr pasos él mismo, despacha subagentes.

Cada subagente tiene su propio contexto: no ve tu historial, y al agente principal solo le vuelve el resumen. Los cinco salen en paralelo, en un solo mensaje, y sus hallazgos se agregan en un único comentario final.

Los cinco especialistas del pr-review-toolkit:

| Subagente | Qué caza |
|---|---|
| code-reviewer | Deuda evidente, TODO en producción |
| silent-failure-hunter | Errores que desaparecen en silencio |
| type-design-analyzer | Tipos que mienten sobre lo que hay en runtime |
| comment-analyzer | Comentarios que no dicen la verdad |
| pr-test-analyzer | Tests que no prueban nada |

Antes de que un peer humano vea el PR, ya pasó por cinco revisores especializados. Al peer le queda lo que un especialista de tipos no puede ver: arquitectura.

Lo que no cambia: quien aprueba sigue siendo responsable de lo que aprueba.

---

# El flujo end-to-end

Cada etapa del día invoca un skill, y detrás de cada skill se activa una pieza distinta de la pirámide.

| Etapa | Skill | Pieza que se activa |
|---|---|---|
| Plan | ticket-coverage-gap-analysis | Skill (se queda acá) |
| Implement | superpowers: TDD | Hook: typecheck on edit |
| Push | local-build-gate | Rule: no-parallel-ci |
| Review | multi-agent-pr-review | 5 subagentes en paralelo |
| Triage | ci-failure-triage | Memory: known-issues |

Memory y rules están cargadas todo el tiempo, por debajo de todo.

Y hay un loop: una corrección repetida tres veces se convierte en un skill nuevo.

Cada pieza compone con las demás. No hay un workflow único: hay piezas.

---

# Ahora, en vivo: un día de QA, del ticket al merge

Seis escenas a lo largo de una jornada de 8 horas, de 9:00 a 17:00, sobre el repo claude-qa-demo, todo offline.

El demo está en TypeScript para que entre en pantalla y compile rápido. El patrón es idéntico en Java, TestNG y RestAssured.

---

# Demo 1 · 9:00 — Del ticket al plan de cobertura

Resuelve: las cuatro pestañas abiertas para armar el panorama completo.

**Input:** un ticket de Jira mockeado en mocks/jira/DEMO-100.json

**Prompt:** "Planificá el trabajo para DEMO-100."

**Skill invocada:** ticket-coverage-gap-analysis

**Output:** un mapa de la cobertura existente, los gaps identificados y una lista de casos propuestos con estimación.

El plan queda con un gap abierto: slug malformado sin cubrir.

---

# Demo 2 · 10:00 — TDD asistido

Resuelve: saltar el "red" y aterrizar directo en código sin test que lo respalde.

Demo 1 dejó un gap: DEMO-100 pide que un slug malformado sea rechazado. Hoy getChannelBySlug devuelve null, como si el canal no existiera.

**Prompt:** "Cerrá ese gap con TDD."

**Skill invocada:** superpowers:test-driven-development, descargada del marketplace, no la escribí yo.

El ciclo: primero un test que espera el rechazo y falla, después la validación mínima del formato que lo pone en verde, y un refactor opcional al final.

El skill guía el orden, y hoy lo respetó.

Gap cerrado, tests verdes. Ahora quiero correr esto en CI.

---

# Demo 3 · 11:30 — Gate local antes de CI

Resuelve: pushear un cambio con un typo y enterarte diez minutos después, cuando Jenkins ya arrancó el build.

**Prompt:** "Triggeá un build de Jenkins para esta branch."

Lo que pasa en vivo: primero local-build-gate corre typecheck y tests locales, y pasan. Después la rule no-parallel-ci detecta que el build 43 ya está corriendo en stage. Y Claude se niega a triggerear: hay que esperar unos doce minutos o cambiar de ambiente.

El guardrail no me cuida a mí del agente: nos cuida a los dos del incidente. Los 90 minutos del principio, exactamente.

---

# Demo 4 · 14:00 — Multi-agent PR review

Resuelve: repetir los mismos comentarios review tras review.

Un PR sembrado con cinco bugs distintos, uno para cada especialista:

- Un catch que se traga los errores y devuelve una lista vacía
- Un cast "as Channel" que miente sobre lo que hay en runtime
- Un comentario que dice "sorted" sobre código que no ordena
- Un test que solo verifica que algo esté definido
- Un TODO olvidado en código de producción

Los cinco agentes salen en paralelo, en un solo mensaje.

---

# El resultado agregado

Un solo comentario al final, con los hallazgos clasificados por severidad: bloqueantes, sugerencias y detalles menores, y el detalle por eje plegado abajo.

Cinco revisiones en paralelo, cada una con contexto aislado, un comentario al final.

Lo leo entero antes de postearlo. Si alguien pregunta por qué se bloqueó el PR, la respuesta soy yo. "No sé, lo hizo la IA" no es una respuesta.

---

# ¿Y esto no lo hacía ya un linter?

Buena parte sí, y el linter no se saca: es más barato y no se cansa.

SonarQube marca ese catch que ignora la excepción, con la regla S2486. Lo que no ve es que el comentario dice "sorted" sobre código que no ordena, ni que un toBeDefined no prueba nada.

El linter matchea patrones. El subagente lee. Van juntos.

---

# Demo 5 · 15:00 — Triage de fallas de CI

Resuelve: triagear tests rojos a mano contra la lista de known-issues.

**Input:** el build 44 con cinco rojos sin etiquetar: nombre, mensaje, stack y los commits del día. Y es la misma branch que veníamos trabajando.

**Skill invocada:** ci-failure-triage, contra el registry en memory/known-issues.md

| Categoría | De dónde sale |
|---|---|
| Flaky test conocido | La firma matchea el registry: dos timeouts vistos hasta el build 39 |
| Infra | El ambiente no responde, connection refused contra auth |
| Regresión real | No está en el registry y el commit toca código relacionado |

La categoría se deduce de la evidencia. No viene dada en el JSON.

---

# El triage no termina en la categoría

Son cinco fallas para que entren en pantalla. En un build de cientos, el mismo skill lee los logs completos, agrupa las fallas relacionadas entre sí y te dice por dónde empezar a mirar, no solo "esto es un flaky test".

---

# Demo 6 · 16:00 — De prompt repetido a skill

Resuelve: re-explicar el ticket, el plan y las convenciones en cada sesión nueva.

Durante la sesión, Claude fue corregido tres veces con la misma indicación.

**Prompt:** "Esto ya te lo repetí 3 veces. ¿Lo convertimos en skill?"

**Skill invocada:** superpowers:writing-skills

El output es un SKILL.md nuevo en el repo.

La slide del principio terminaba así: "Mañana, sesión nueva. Re-explicás el ticket, el plan, las convenciones."

Mañana, sesión nueva: no se re-explica ni el ticket, ni el plan, ni las convenciones.

Este es el patrón completo en acción.

---

# Y no siempre tenés que contar vos

Hoy lo repetí tres veces y lo noté. Cuando no lo notás, se lo preguntás:

"Revisá las últimas conversaciones y decime qué skills hay que crear o actualizar."

El patrón es el mismo. Cambia quién lo detecta.

---

# Mi línea de tiempo real

**Semana 1** — CLAUDE.md inicial de cinco líneas, y el skill local-build-gate, después de romper CI dos veces por un typo que typecheck cazaba en dos segundos.

**Semana 3** — Las rules no-parallel-ci, después de los 90 minutos cazando flaky tests fantasma, y english-only, porque un compañero no podía revisar un commit escrito en español.

**Semana 6** — Los skills ci-failure-triage, por hacerme las mismas tres preguntas cada lunes, y known-issues-registry-update, porque perdía el registro de qué flaky test ya había visto.

**Semana 9** — El plugin pr-review-toolkit y el skill multi-agent-pr-review, para pasar de secuencial a paralelo.

**Semana 11** — El hook typecheck-after-edit, porque memory y skill no alcanzaban.

**Semana 13** — El skill ticket-coverage-gap-analysis, después de tener la misma conversación cuatro sprints seguidos.

**Semana 16** — Una memory con la heurística de flaky tests en stage: el 80% de los rojos no eran regresiones.

**Ahora** — El setup quedó versionado en el repo, y los compañeros también lo mejoran con sus propias PRs.

**Futuro** — Nuevas ideas, nuevas necesidades. Seguimos buscando patrones.

Nada se planificó. Cada pieza respondió a un dolor concreto.

---

# El agente también construye

Cultivar no es solo skills, rules y memory para el agente. Es lo que el agente construye con vos:

**CI a tu medida** — el pipeline corre con tus reglas, no con las heredadas.

**Linters, checkstyle y SonarQube** — configurados y explicados, no copiados de un gist.

**Coverage y notificaciones** — Allure, dashboards, y el build roto que te encuentra a vos.

El hook de typecheck que viste hace rato es exactamente este patrón. Aplicado a un linter o a un quality gate, la conversación es la misma.

No le tengas miedo a lo desconocido: el costo de aprender colapsó. Cultivás al agente, y el proyecto queda mejor armado que antes.

---

# Qué le toca a la persona

| | El agente | Vos |
|---|---|---|
| Ejecución | Corre el procedimiento, agrega resultados, propone cambios de código para revisar | — |
| Criterio | — | Interpretás un AC ambiguo, decidís qué es "suficiente" |
| Aporte | — | Metés lo que el agente no vio: charlas, discusiones, decisiones de negocio |
| Revisión | Hace el primer pase, cinco subagentes en paralelo | Leés el resultado antes de postearlo o mergear |
| Decisión | — | Aprobás, bloqueás, o decidís qué se promueve a skill o rule |
| Responsabilidad | — | Si preguntan por qué, la respuesta sos vos |

El agente ejecuta. La persona aporta lo que falta, decide, revisa y responde por el resultado. Eso no se delega.

"No sé, lo hizo la IA" no es una respuesta válida.

---

# La pregunta del principio

¿Puedo automatizar mi proceso de QA con IA?

Sí, lo acabás de ver.

¿Se diseña? No. Se cultiva.

---

# 4 pasos para el lunes

**Un CLAUDE.md de cinco líneas** en el repo donde más trabajás. Nombre del proyecto, comando de test, convención de commits. Nada más.

**Probá hacer todo con el agente**, aunque hoy lo hagas por fuera: leer el ticket de Jira, estudiar la story, compararla contra el código. Ahí empiezan a aparecer los patrones repetibles.

**Anotá la próxima corrección que repitas.** La segunda vez que escribís "acordate de X antes de Y", eso es una memory. La tercera, un skill.

**Bajá lo que ya existe:** superpowers y pr-review-toolkit. Arrancás con workflows que no tuviste que escribir. Son públicos: usá los de confianza, los que tu organización ya aceptó.

Nada de esto necesita presupuesto, permiso, ni una reunión de arquitectura.

---

# Tu setup no se diseña. Se cultiva.

Memory + Skills + Rules + Hooks = workflow reproducible

Cultivarlo no te saca del medio: el criterio, el dominio y la firma siguen siendo tuyos.

¿Preguntas?

github.com/edcrove/claude-qa-demo · linkedin.com/in/edgardocrovetto

---

# Apéndice: anatomía de cada pieza

Memory, Skill, Rule y Hook, con su ejemplo real.

---

# Memory

Una corrección repetida dos veces es candidata a memory.

**El prompt que la crea:** "Guardá esto en memory: corré typecheck y tests locales antes de cualquier build remoto. Me olvidé dos veces después de un rebase."

**Qué tiene adentro:** un nombre en kebab-case, una descripción de una línea que Claude usa para decidir si traer ese recuerdo, un tipo, el hecho en sí, el porqué (casi siempre un incidente pasado) y cuándo aplica.

Ese prompt es lo único que hace falta: Claude arma el archivo. Persiste entre sesiones y sobrevive al /clear.

---

# Skill

**El prompt que lo crea:** "Rompí el build dos veces esta semana por lo mismo. Convertí el chequeo local en un skill."

**Qué tiene adentro:** nombre, una descripción que empieza con "Use when" y describe el trigger, cuándo usarlo, los pasos concretos y verificables, y qué produce.

La descripción es el campo crítico: es lo que Claude usa para decidir si invocarlo.

**El ejemplo real, local-build-gate:** typecheck, tests unitarios y un smoke check del endpoint. Nunca se saltea, y compone con la rule no-parallel-ci.

---

# Rule

**El prompt que la crea:** "Esto no puede volver a pasar. Regla: nunca triggerear un build si ya hay otro corriendo en el mismo ambiente."

**Qué tiene adentro:** una descripción de una línea en presente, la regla en sí, el porqué y cuándo se activa.

A diferencia de un skill, siempre está cargada en el contexto.

**El ejemplo real, no-parallel-ci:** antes de triggerear un build, chequear si ya hay otro corriendo en el ambiente. Si lo hay, esperar o cambiar de ambiente. Los runs en paralelo comparten credenciales y se interfieren entre sí, y eso se ve igual que una regresión real, pero no lo es.

Nació después de 90 minutos cazando flaky tests fantasma.

---

# Hook

**El prompt que lo crea:** "Me olvidé el typecheck cinco veces seguidas, teniendo memory y skill. Convertilo en hook: que corra en cada edit, pase lo que pase."

**Qué tiene adentro:** un evento del ciclo al que engancharse, un matcher que decide sobre qué herramientas dispara, y un comando de shell.

Se engancha a momentos del ciclo: antes y después de cada herramienta, al cerrar la sesión, entre otros. El comando recibe el evento como JSON por entrada estándar.

No depende del modelo: lo dispara el runtime de Claude Code y siempre se ejecuta.

El hook fue el final del camino, después de que memory y skill no alcanzaran.

---

# Backup para Q&A

Las respuestas que suelen hacer falta.

---

# ¿Y los costos en tokens?

El día a día corre en un modelo mid-tier. El multi-agent review es el único paso caro.

Cinco subagentes son cinco contextos aislados: pagás tokens para no pagar contexto contaminado.

El costo contra el que se compara: diez minutos de CI roto, noventa minutos de flaky tests fantasma, un review que espera dos días.

Memory, rules y hooks cuestan prácticamente cero: es texto plano en el contexto que ya pagás.

---

# ¿Qué pasa cuando cambia el modelo?

Los prompts afinados a un modelo a veces mueren con él.

Skills, rules y memory sobreviven, porque describen tu proceso, no al modelo.

El hook ni siquiera pasa por el modelo: lo ejecuta el runtime.

Por eso la pirámide promociona hacia arriba: cada nivel es más robusto al cambio.

---

# ¿Funciona offline? ¿Sirve en mi stack?

El demo corre cien por ciento offline: mocks JSON en disco, cero credenciales.

Solo los MCPs reales necesitan red.

El patrón no sabe de lenguajes: es idéntico en Java, TestNG y RestAssured.

Todo es texto plano: clonalo y reemplazá los mocks por tus sistemas.

---

# ¿Quién audita al clasificador de CI?

ci-failure-triage no decide a ciegas: la categoría sale de evidencia visible, la firma en el registry, el stack y los commits. No es una caja negra.

El registry lo propone el agente y lo confirmás vos antes de commitear, y pide al menos dos apariciones: un solo fallo nunca es un flaky test.

Si la categoría no cierra con evidencia, regresión real es el default. El skill sesga hacia flaggear de más, no de menos.

Igual que en la review de PRs: el agente propone, vos confirmás antes de actuar.
