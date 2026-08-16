---
marp: true
theme: gaia
class: invert
paginate: true
backgroundColor: "#272932"
color: "#CCC9E7"
style: |
  /* ── paleta ───────────────────────────────────────────────── */
  :root {
    --bg:      #272932;   /* Shadow Grey — base */
    --surface: #1E2028;   /* derivado, para paneles de codigo */
    --ink:     #CCC9E7;   /* Periwinkle */
    --bright:  #F4F2FB;   /* derivado, para negritas */
    --muted:   #8C89A6;   /* derivado, periwinkle desaturado */
    --accent:  #EECF6D;   /* Jasmine — acento primario */
    --accent2: #DC493A;   /* Cinnabar — acento secundario */
    --hot:     #EF2D56;   /* Watermelon — solo para las cicatrices */
    --line:    #3B3E4B;
  }
  section {
    font-family:'Inter','Helvetica Neue',sans-serif; font-size:24px; line-height:1.42;
    padding:44px 60px; color:var(--ink); background:var(--bg);
  }
  /* ── titulos: cuadrado Jasmine como marcador ──────────────── */
  section h1 {
    color:var(--bright); font-size:1.36em; font-weight:650;
    margin:0 0 .5em; letter-spacing:-.014em; line-height:1.15;
  }
  section h1::before {
    content:''; display:inline-block; width:14px; height:14px; border-radius:3px;
    background:var(--accent); margin-right:.5em; vertical-align:baseline;
  }
  section h2 { color:var(--muted); font-weight:400; font-size:1.06em; margin:0 0 .5em; }
  section p { margin:.5em 0; }
  section ul { margin:.4em 0; padding-left:1.1em; }
  section li { margin:.18em 0; }
  section li::marker { color:var(--accent); }
  strong { color:var(--bright); font-weight:650; }
  em { color:var(--muted); }
  /* ── codigo ───────────────────────────────────────────────── */
  code { background:#31343F; color:var(--accent); padding:1px 6px; border-radius:4px; font-size:.84em; }
  pre {
    background:var(--surface); border:1px solid var(--line);
    border-left:3px solid var(--accent); border-radius:6px;
    padding:10px 14px; margin:.5em 0;
  }
  pre code { background:transparent; color:var(--ink); font-size:.58em; line-height:1.3; padding:0; }
  /* ── tablas: reglas, no cajas ─────────────────────────────── */
  table { border-collapse:collapse; width:100%; margin:.4em 0; font-size:.93em; }
  section table, section table thead, section table tbody,
  section table tr, section table th, section table td {
    background:transparent !important; background-color:transparent !important;
  }
  section table th {
    color:var(--accent2) !important; text-align:left;
    font-size:.74em; font-weight:600; text-transform:uppercase; letter-spacing:.08em;
    border:none !important; border-bottom:1px solid var(--accent2) !important;
    padding:3px 12px 4px 0;
  }
  section table td {
    border:none !important; border-bottom:1px solid var(--line) !important;
    padding:5px 12px 5px 0; vertical-align:top;
  }
  section table tr:last-child td { border-bottom:none !important; }
  blockquote {
    border-left:3px solid var(--hot); color:var(--muted);
    margin:.5em 0; padding-left:.8em; font-size:.95em;
  }
  blockquote strong { color:var(--ink); }
  a { color:var(--accent); }
  /* ── lead ─────────────────────────────────────────────────── */
  section.lead {
    padding:60px 90px;
    background:radial-gradient(ellipse at 30% 0%, #32353F 0%, var(--bg) 70%);
  }
  section.lead h1 { color:var(--accent); font-size:1.85em; letter-spacing:-.02em; }
  section.lead h1::before { display:none; }
  section.lead h2 { color:var(--ink); font-weight:300; font-size:1.25em; }
  /* ── dense: para las slides mas cargadas ──────────────────── */
  section.dense { font-size:21px; line-height:1.34; }
  section.dense h1 { font-size:1.3em; margin-bottom:.35em; }
  section.dense pre code { font-size:.55em; }
---

<!-- _class: lead -->

# Tu setup de QA no se diseña: se cultiva
## De prompt suelto a skills, rules y hooks.

Edgardo Crovetto · 2026

---

<!-- _class: lead -->

# Una noche perdí 90 minutos

## cazando flaky tests fantasma

Dos builds, mismo ambiente, mismas credenciales — sin que nadie lo supiera.
Todo rojo. Nada roto.

**Hoy eso no puede volver a pasarme.
Y no es porque yo me acuerde: es porque mi setup se acuerda por mí.**

Esta charla es la historia de cómo llegué ahí.

---

# Quién soy

**Edgardo Crovetto** · Senior QA automation engineer

Java + TypeScript · tests automatizados · CI/CD · pipelines

**Me gusta mejorar procesos — sobre todo los que ya estaban funcionando.**

> Esta charla no es sobre features. Es sobre **un patrón que se repite** — y lo que hacés con eso.

`linkedin.com/in/edgardocrovetto`

---

# La pregunta de hoy

> ## ¿Puedo automatizar mi proceso de QA con IA?

Spoiler: sí — **sobre las bases que ya tenés.**

---

# Mi setup antes de IA

Plataforma de streaming · servicio backend REST

**Framework:** Java + TestNG + RestAssured + Allure reports + Jira + TestRail + Jenkins

**Pipeline diario:**

```
Jira ticket (changes + AC)  →  análisis del cambio
                            →  generar tests / automation
                            ↓
TestRail mapea automation ↔ casos ↔ coverage
                            ↓
Jenkins corre build + regression
                            ↓
PR con review de 2 peers · checkstyle automático
                            ↓
Análisis local + Jenkins  →  bugs en Jira  →  follow-up del ciclo
```

> Funcionaba. Pero todo el conocimiento de cada ticket vivía **en mi cabeza**.

---

# Tu día como QA, hoy

- **Análisis del ticket** — Jira + repo + Confluence (AC) + TestRail · nada de eso queda escrito en un solo lugar
- **Mapeo AC ↔ cambio** — comparás docs vs branch a ojo, página por página
- **Test cases + automation** — copiás AC a TestRail, traducís a TestNG/RestAssured, linkeás IDs a mano
- **Ejecución multi-env** — Jenkins contra 3 ambientes · comparás resultados · investigás cada rojo
- **PR review** — armás la evidencia, pingeás 2 peers, esperás, re-pingeás
- **Bug encontrado** — abrís ticket, pegás logs, follow-up del ciclo de vida en Jira
- **Mañana** — sesión nueva. Re-explicás el ticket, el plan, las convenciones.

**Mucho de eso es conocimiento que se pierde entre sesiones.**

---

<!-- _class: lead -->

## ¿Y si ese conocimiento **sobreviviera**?

---

<!-- _class: lead -->

# La tesis

# Mi setup no se diseña.

# Se cultiva.

---

# Mis primeros pasos con Claude

**1. Conectar Claude al repo del trabajo**
- Todo arrancó con un `CLAUDE.md` de apenas 5 líneas — se lo pedís en la conversación, no lo escribís a mano
- Lo demás vino con el tiempo

**2. Agregar MCPs, uno a uno**
Jira, TestRail, Jenkins, Confluence — el detalle, en la próxima slide.

A partir de ahí: **prompts del día a día**.
No hubo plan. Aparecieron patrones.

---

# Cómo Claude conoce mi proyecto

```
~/.claude/CLAUDE.md          ← preferencias globales (tu identidad)
└── proyecto/CLAUDE.md       ← convenciones del repo
    ├── .claude/skills/      ← workflows invocables
    ├── .claude/rules/       ← guardrails siempre cargados
    ├── memory/              ← hechos entre sesiones
    └── .claude/settings.json ← hooks automáticos
```

Todo es **texto plano en disco**. Versionado. Reviewable.

---

# MCPs — los puentes a sistemas externos

Memory, skills, rules y hooks viven en tu repo.
El trabajo real cruza varios sistemas. Los MCPs los conectan.

*Conectar uno también se pide en conversación — no hay instalador que armar a mano.*

| MCP | Para qué lo uso |
|-----|-----------------|
| 🎫 **Jira** | Leer ticket + AC, comentar, transicionar el estado |
| ✅ **TestRail** | Leer/escribir test cases, asociar runs a builds |
| 🏗️ **Jenkins** | Triggerear builds, leer resultados, descargar logs |
| 📄 **Confluence** | Leer specs y acceptance criteria |

Una sola conversación con Claude puede pasar por los **4**.

---

# La pirámide de promoción

**Una sola historia:** el typecheck que me olvidaba después de cada rebase,
subiendo un nivel cada vez que el anterior no alcanzó.

```
                  ╔════════════╗
                  ║    HOOK    ║   ◀ typecheck en cada edit — corre solo, ya no depende de nadie
                  ╚════════════╝
                ╔════════════════╗
                ║      RULE      ║  ◀ siempre cargada — pero Claude decide cómo aplicarla
                ╚════════════════╝
              ╔════════════════════╗
              ║       SKILL        ║ ◀ local-build-gate — lo corre Claude cuando hace falta
              ╚════════════════════╝
            ╔════════════════════════╗
            ║        MEMORY          ║ ◀ feedback-local-build-before-ci — y me lo olvidé igual
            ╚════════════════════════╝
          ╔════════════════════════════╗
          ║      PROMPT SUELTO         ║ ◀ "acordate del typecheck antes de CI", una y otra vez
          ╚════════════════════════════╝
```

**Saltea la Rule** — y no es olvido: una rule me lo *recuerda*, y el problema
era justamente que recordármelo no alcanzaba. **Pocas piezas llegan hasta
arriba**: no es una escalera que subís entera, es un menú. La Rule tiene su
propia cicatriz — `no-parallel-ci`, los 90 minutos del principio.

> Ninguna pieza se diseñó. Cada una fue admitir que acordarse no escala.

---

<!-- _class: dense -->

# Un skill no siempre ejecuta: a veces delega

`multi-agent-pr-review` es un `SKILL.md` como cualquier otro — markdown en tu
repo, la misma pirámide. Lo distinto es lo que hace adentro: en vez de correr
pasos él mismo, **despacha subagentes.** Cada uno con su propio contexto: no ve
tu historial, y al principal solo le vuelve el resumen.

```
   ┌───────────────────────────────────────────────────────────────┐
   │                          Main agent                           │
   └─────┬───────┬───────┬───────┬───────┬─────────────────────────┘
         │       │       │       │       │     ◀ despacho paralelo
         ▼       ▼       ▼       ▼       ▼
     ┌──────┐┌──────┐┌──────┐┌──────┐┌──────┐
     │ code ││silent││ type ││ comm.││ test │  ◀ pr-review-toolkit:
     │review││failur││design││analyz││analyz│    code-reviewer · silent-failure-hunter ·
     └──┬───┘└──┬───┘└──┬───┘└──┬───┘└──┬───┘    type-design-analyzer · comment-analyzer ·
        │       │       │       │       │        pr-test-analyzer — 5 contextos aislados
        └───────┴───┬───┴───────┴───────┘
                    ▼
              ┌──────────────┐
              │  Aggregator  │  ◀ un solo comentario al final
              └──────────────┘
```

**Antes de que un peer humano vea el PR, ya pasó por 5 revisores especializados**,
cada uno cazando su propia clase de bug. Al peer le queda lo que un especialista
de tipos no puede ver: arquitectura. *(Mis compañeros aplaudieron esto.)*

**Lo que no cambia: quien aprueba sigue siendo responsable de lo que aprueba.**

---

# El flujo end-to-end

```
   PLAN          IMPLEMENT       PUSH           REVIEW         TRIAGE
   ─────         ─────────       ────           ──────         ──────
      │             │             │               │              │
      ▼             ▼             ▼               ▼              ▼
  ┌─────────┐   ┌─────────┐  ┌──────────┐   ┌──────────┐   ┌──────────┐
  │ ticket- │   │ super:  │  │ local-   │   │ multi-   │   │ ci-      │
  │coverage │   │ TDD     │  │ build-   │   │ agent-   │   │ failure- │
  │  -gap-  │   │ skill   │  │ gate     │   │ pr-      │   │ triage   │
  │analysis │   │         │  │          │   │ review   │   │          │
  └─────────┘   └─────────┘  └──────────┘   └──────────┘   └──────────┘
  │                 │              │             │              │
  ▼                 ▼              ▼             ▼              ▼
  SKILL           HOOK         RULE            5 SUB-         MEMORY
  ticket-coverage typecheck    no-parallel-   AGENTES        known-
  -gap-analysis   on-edit      ci             en paralelo    issues

   ─────────── memory + rules cargadas todo el tiempo ────────────────

   ⟳ Loop: corrección repetida 3× ──▶ writing-skills ──▶ skill nueva
```

**Cada pieza compone con las demás.** No hay un workflow único — hay piezas.

---

<!-- _class: lead -->

# Ahora, en vivo

## Un día de QA, del ticket al merge

6 escenas a lo largo de una jornada de 8 horas · 9:00 → 17:00 · repo `claude-qa-demo` · todo offline

*El demo está en TypeScript para que entre en pantalla y compile rápido.
El patrón es **idéntico** en Java/TestNG/RestAssured.*

---

# Demo 1 · 9:00 — Ticket → plan de cobertura

> *↩ Resuelve: las 4 pestañas para armar el panorama completo.*

**Input:** un ticket de Jira mockeado en `mocks/jira/DEMO-100.json`.

**Prompt:**
> *"Planificá el trabajo para DEMO-100."*

**Skill invocada:** `ticket-coverage-gap-analysis`

**Output:**
- Mapa de cobertura existente (tabla)
- Gaps identificados (✅ / ⚠️ / ❌)
- TodoWrite con casos propuestos + estimación

*El plan queda con un ❌: slug malformado sin cubrir. →*

---

# Demo 2 · 10:00 — TDD asistido

> *↩ Resuelve: saltar el "red" y aterrizar directo en código sin test que lo respalde.*

Demo 1 dejó un ❌: **DEMO-100 pide que un slug malformado sea rechazado.**
Hoy `getChannelBySlug('News Channel!')` devuelve `null`, como si no existiera.

**Prompt:**
> *"Cerrá ese gap con TDD."*

**Skill invocada:** `superpowers:test-driven-development`
*(descargada del marketplace, no la escribí yo)*

1. Test que espera el rechazo → **red**
2. Validación mínima del formato → **green**
3. Refactor opcional

El skill guía el orden — y hoy lo respetó.

*Gap cerrado, tests verdes. Ahora quiero correr esto en CI. →*

---

# Demo 3 · 11:30 — Gate local antes de CI

> *↩ Resuelve: pushear un cambio con un typo y enterarte 10 minutos después, cuando Jenkins ya arrancó el build.*

**Prompt:**
> *"Triggeá un build de Jenkins para esta branch."*

Lo que pasa en vivo:
1. `local-build-gate` → typecheck + tests locales ✅
2. `no-parallel-ci.mdc` → **build 43 ya está corriendo en stage** (`build-43-running.json`)
3. Claude **se niega a triggerear**: esperar ~12 min o cambiar de env

**El guardrail no me cuida a mí del agente — nos cuida a los dos del incidente.**
Los 90 minutos del principio, exactamente.

*Build 43 termina, corre el mío, abro el PR. →*

---

# Demo 4 (1/2) · 14:00 — Multi-agent PR review ⭐

> *↩ Resuelve: repetir los mismos comentarios review tras review.*

PR sembrado con 5 bugs distintos (`mocks/github/pr-7.diff`):
- `silent-failure-hunter` → `catch (e) { return [] }` se traga errores
- `type-design-analyzer` → `as Channel` miente
- `comment-analyzer` → comentario que dice "sorted" pero no ordena
- `pr-test-analyzer` → test que solo verifica `toBeDefined()`
- `code-reviewer` → `// TODO` en producción

**Dispatch:** 5 agentes en paralelo, **un solo mensaje**.

---

# Demo 4 (2/2) — el resultado agregado

```markdown
## Review summary

**Blockers:** silent-failure-hunter found 1
**Suggestions:** type-design-analyzer found 1, comment-analyzer found 1, pr-test-analyzer found 1
**Nitpicks:** code-reviewer found 1

<details><summary>Per-axis details</summary>
...
</details>
```

5× paralelo, contexto aislado, 1 comentario al final.

**Lo leo entero antes de postearlo. Si alguien pregunta por qué se bloqueó
el PR, la respuesta soy yo — "no sé, lo hizo la IA" no es una respuesta.**

---

# ¿Y esto no lo hacía ya un linter?

Buena parte sí — y **el linter no se saca**: es más barato y no se cansa.

SonarQube marca ese `catch` que ignora la excepción (`S2486`). Lo que no ve es
que el comentario dice *"sorted"* sobre código que no ordena, ni que un
`toBeDefined()` no prueba nada.

**El linter matchea patrones. El subagente lee.** Van juntos.

*Review adentro. Antes del merge, la regression completa en Jenkins. →*

---

# Demo 5 · 15:00 — Triage de fallas de CI

> *↩ Resuelve: triagear tests rojos a mano contra known-issues.*

**Input:** `mocks/jenkins/build-44.json` — 5 rojos **sin etiquetar**: nombre,
mensaje, stack y los commits. Y es **la misma branch de hoy**:
`feature/DEMO-100-channels-coverage`.

**Skill invocada:** `ci-failure-triage` + registry `memory/known-issues.md`

| Categoría | De dónde sale |
|---|---|
| Flaky test conocido | La firma matchea el registry (2× `Test timed out in 5000ms`, visto hasta build 39) |
| Infra | El ambiente no responde (`ECONNREFUSED` a auth) |
| Regresión real | No está en el registry **y** el commit toca código relacionado |

**La categoría se deduce de la evidencia — no viene dada en el JSON.**

---

# El triage no termina en la categoría

Son 5 fallas para que entren en pantalla. En un build de cientos, el mismo
skill lee los **logs completos**, agrupa las fallas relacionadas entre sí y
te dice **por dónde empezar a mirar** — no solo "esto es un flaky test".

*Triage hecho. Pero hoy, tres veces, me corregiste lo mismo... →*

---

# Demo 6 · 16:00 — De prompt repetido a skill 🪄

> *↩ Resuelve: re-explicar el ticket, el plan, las convenciones en una sesión nueva.*

Durante la sesión, Claude fue corregido **3 veces** con
*"acordate de chequear X antes de Y"*.

**Prompt:**
> *"Esto ya te lo repetí 3 veces. ¿Lo convertimos en skill?"*

**Skill invocada:** `superpowers:writing-skills`
*(alternativa del marketplace: el plugin `skill-creator`)*

Output: un `SKILL.md` nuevo en `.claude/skills/`.

La slide del principio terminaba:
*"Mañana — sesión nueva. Re-explicás el ticket, el plan, las convenciones."*

**Mañana — sesión nueva. No se re-explica ni el ticket,
ni el plan, ni las convenciones.**

**Este es el patrón completo en acción.**

---

# Y no siempre tenés que contar vos

Hoy lo repetí 3 veces y lo noté. Cuando no lo notás, se lo preguntás:

> *"Revisá las últimas conversaciones y decime qué skills hay que crear o actualizar."*

El patrón es el mismo — cambia quién lo detecta.

---

# Mi línea de tiempo real

```
semana 1    CLAUDE.md inicial: 5 líneas — nombre, comando de test, convención de commits
semana 1    ← Skill: local-build-gate (CI roto 2 veces por un typo que typecheck cazaba en 2 seg)
semana 3    ← Rule: no-parallel-ci (90 min cazando flaky tests fantasma en stage)
semana 3    ← Rule: english-only (un compañero no podía revisar un commit en español)
semana 6    ← Skill: ci-failure-triage (las mismas 3 preguntas cada lunes)
semana 6    ← Skill: known-issues-registry-update (perdía el registro de qué flaky test ya vi)
semana 9    ← Plugin pr-review-toolkit + Skill: multi-agent-pr-review (de secuencial a paralelo)
semana 11   ← Hook: typecheck-after-edit (memory + rule no alcanzaban)
semana 13   ← Skill: ticket-coverage-gap-analysis (la misma conversación 4 sprints seguidos)
semana 16   ← Memory: heurística de flaky tests en stage (80% de los rojos eran flaky tests, no regresiones)
ahora       ← El setup quedó versionado en el repo — los compañeros también lo mejoran, con sus propias PRs
futuro      ← Nuevas ideas, nuevas necesidades — seguimos buscando patrones
```

**Nada se planificó. Cada pieza respondió a un dolor concreto.**

---

# El agente también construye

Cultivar no es solo skills, rules y memory **para** el agente.
Es lo que el agente construye **con vos**:

- **CI a tu medida** — el pipeline corre con tus reglas, no con las heredadas
- **Linters / checkstyle / SonarQube** — configurados y explicados, no copiados de un gist
- **Coverage y notificaciones** — Allure, dashboards, el build roto te encuentra a vos

El hook de typecheck que viste hace rato **es exactamente este patrón** —
aplicado a un linter o a un quality gate, la conversación es la misma.

> **No le tengas miedo a lo desconocido: el costo de aprender colapsó.**
> Cultivás al agente — y el proyecto queda mejor armado que antes.

---

<!-- _class: dense -->

# Qué le toca a la persona

| | El agente | Vos |
|---|---|---|
| **Ejecución** | Corre el procedimiento, agrega resultados, propone cambios de código para revisar | — |
| **Criterio** | — | Interpretás un AC ambiguo, decidís qué es "suficiente" |
| **Aporte** | — | Metés lo que el agente no vio: charlas, discusiones, decisiones de negocio — enriquecés, corregís |
| **Revisión** | Hace el primer pase (5 subagentes en paralelo) | Leés el resultado antes de postearlo o mergear |
| **Decisión** | — | Aprobás, bloqueás, o decidís qué se promueve a skill/rule |
| **Responsabilidad** | — | Si preguntan por qué, la respuesta sos vos |

**El agente ejecuta. La persona aporta lo que falta, decide, revisa y
responde por el resultado — eso no se delega.**

*Mismo criterio que en la Demo 4: se lee entero antes de postearlo —*
**"no sé, lo hizo la IA" no es una respuesta válida.**

---

<!-- _class: lead -->

## La pregunta del principio

# ¿Puedo automatizar mi proceso de QA con IA?

**Sí — lo acabás de ver.**
**¿Se diseña? No. Se cultiva.**

---

# 4 pasos para el lunes

**1. Un `CLAUDE.md` de 5 líneas** en el repo donde más trabajás.
Nombre del proyecto, comando de test, convención de commits. Nada más.

**2. Probá hacer todo con el agente, aunque hoy lo hagas por fuera.**
Leer el ticket de Jira, estudiar la story, compararla contra el código.
Ahí empiezan a aparecer los patrones repetibles.

**3. Anotá la próxima corrección que repitas.**
La segunda vez que escribís *"acordate de X antes de Y"*, eso es una memory.
La tercera, un skill.

**4. Bajá lo que ya existe:** `/plugin` → `superpowers` + `pr-review-toolkit`.
Arrancás con workflows que no tuviste que escribir. Son públicos: usá los de
confianza, los que tu organización ya aceptó.

> Nada de esto necesita presupuesto, permiso, ni una reunión de arquitectura.

---

<!-- _class: lead -->

# Tu setup no se diseña.
# Se cultiva.

**Memory + Skills + Rules + Hooks = workflow reproducible**

**Cultivarlo no te saca del medio: el criterio, el dominio y la firma siguen siendo tuyos.**

## ¿Preguntas?

`github.com/edcrove/claude-qa-demo`
`linkedin.com/in/edgardocrovetto`

---

<!-- _class: lead -->

# Apéndice

## Anatomía y ejemplo real de cada pieza

Memory · Skill · Rule · Hook

---

# Memory — anatomía

Una corrección repetida **2 veces** es candidata a memory.

**Prompt:**
> *"Guardá esto en memory: <la corrección o el hecho>."*

```markdown
---
name: kebab-case-slug
description: <One-line summary; Claude lo usa para decidir si traer este recuerdo>
metadata:
  type: feedback | user | project | reference
---

<Body: el hecho, la preferencia, la corrección>

**Why:** <razón concreta — usualmente un incidente pasado>
**How to apply:** <cuándo aplica>
```

Ese prompt es lo único que hace falta — Claude arma el archivo. Persiste
entre sesiones. Sobrevive al `/clear`.

---

# Memory — ejemplo real

**Prompt:**
> *"Guardá esto en memory: corré typecheck y tests locales antes de
> cualquier build remoto. Me olvidé 2 veces después de un rebase."*

```markdown
---
name: feedback-local-build-before-ci
description: Always run local typecheck + tests before triggering remote CI
metadata:
  type: feedback
---

Run `npm run typecheck && npm test` before any remote CI build.

**Why:** failed CI runs burn ~10 minutes per attempt.
**How to apply:** see `local-build-gate` skill.
```

Nació después de olvidarme el `typecheck` post-rebase un lunes a la mañana.

---

# Skill — anatomía

**Prompt:**
> *"Convertí esto en un skill."*

```markdown
---
name: kebab-case-name
description: Use when <trigger>. <One-sentence summary.>
---

# Title

## When to use
- Concrete trigger 1
- Concrete trigger 2

## Steps
1. Concrete and verifiable
2. ...

## Output
What the skill produces.
```

`description` es el campo crítico: Claude lo usa para decidir si invocar.

---

# Skill — ejemplo real

**Prompt:**
> *"Rompí el build dos veces esta semana por lo mismo. Convertí el
> chequeo local en un skill."*

```markdown
---
name: local-build-gate
description: Use before triggering remote CI to fail fast on
  compile or unit-test errors. Saves ~10 min per broken push.
---

# Local build gate

1. **Typecheck:** cd demo-app && npm run typecheck
2. **Unit tests:** cd demo-app && npm test
3. **Smoke check:** call the endpoint once

## When to skip
Never. Compose with `no-parallel-ci.mdc`.
```

Nació después de romper el build dos veces en la misma semana.

---

# Rule — anatomía

**Prompt:**
> *"Convertí esto en una rule — quiero que esté siempre presente."*

```markdown
---
description: One-line summary, ≤ 120 chars, present tense
---

Rule statement: what you must / must not do.

**Why:** the reason — often a past incident.
**How to apply:** when this kicks in.
```

A diferencia de un skill, **siempre está cargada** en el contexto.

---

# Rule — ejemplo real

**Prompt:**
> *"Esto no puede volver a pasar. Regla: nunca triggerear un build
> si ya hay otro corriendo en el mismo ambiente."*

```markdown
---
description: Never trigger two CI builds in parallel against
  the same TEST_ENV — they share credentials.
---

Before triggering a CI build:
1. Check whether another build is already running on the env.
2. If yes, wait or pick a different env. Do not queue parallel.

**Why:** parallel runs share credentials → mutual interference
that looks like real regressions but isn't.
```

Nació después de 90 minutos cazando flaky tests fantasma.

---

# Hook — anatomía

**Prompt:**
> *"Convertí esto en un hook — que corra solo, sin que nadie lo invoque."*

```json
{
  "hooks": {
    "PostToolUse": [{
      "matcher": "Edit|Write|MultiEdit",
      "hooks": [{
        "type": "command",
        "command": "<bash command>"
      }]
    }]
  }
}
```

Se engancha a momentos del ciclo: antes (`PreToolUse`) y después
(`PostToolUse`) de cada tool, cierre de sesión (`Stop`), entre otros.
El comando recibe el evento como **JSON por stdin**.

**No depende del modelo:** lo dispara el runtime de Claude Code y siempre se ejecuta.

---

# Hook — ejemplo real

**Prompt:**
> *"Me olvidé el typecheck 5 veces seguidas — teniendo memory y skill.
> Convertilo en hook: que corra en cada edit, pase lo que pase."*

```json
{
  "hooks": {
    "PostToolUse": [{
      "matcher": "Edit|Write|MultiEdit",
      "hooks": [{
        "type": "command",
        "command": "f=$(jq -r '.tool_input.file_path // empty');
                    case \"$f\" in \"$CLAUDE_PROJECT_DIR\"/*.ts)
                      cd \"$CLAUDE_PROJECT_DIR/demo-app\" && npm run typecheck;;
                    esac"
      }]
    }]
  }
}
```

El path sale del JSON de stdin con `jq` — no de una variable de entorno.

Nació después de olvidarme el `typecheck` 5 veces seguidas — **teniendo
el memory y el skill**. El hook fue el final del camino.

---

<!-- _class: lead -->

# Backup — Q&A

## Respuestas que suelen hacer falta

---

# ¿Y los costos en tokens?

- El día a día corre en un modelo mid-tier; el multi-agent review es el único paso caro
- 5 subagentes = 5 contextos aislados — pagás tokens para **no** pagar contexto contaminado
- El costo contra el que se compara: 10 min de CI roto · 90 min de flaky
  tests fantasma · un review que espera 2 días
- Memory, rules y hooks cuestan ~0: texto plano en el contexto que ya pagás

---

# ¿Qué pasa cuando cambia el modelo?

- Los **prompts** afinados a un modelo a veces mueren con él
- **Skills, rules y memory sobreviven** — describen tu proceso, no al modelo
- El **hook** ni siquiera pasa por el modelo: lo ejecuta el runtime
- Por eso la pirámide promociona hacia arriba: **cada nivel es más robusto al cambio**

---

# ¿Funciona offline? ¿Sirve en mi stack?

- Este demo corre **100% offline**: mocks JSON en disco, cero credenciales
- Solo los **MCPs** reales (Jira, Jenkins, TestRail) necesitan red
- El patrón no sabe de lenguajes: idéntico en **Java/TestNG/RestAssured**
- Todo es texto plano: clonalo y reemplazá los mocks por tus sistemas

---

# ¿Quién audita al clasificador de CI?

- `ci-failure-triage` no decide a ciegas: la categoría sale de evidencia
  visible (firma en el registry, stack, commits) — no es una caja negra
- El registry (`memory/known-issues.md`) lo propone el agente y lo confirmás
  vos antes de commitear, y pide **2+ sightings** — un solo fallo nunca es un
  flaky test
- Si la categoría no cierra con evidencia, **regresión real es el default**
  — el skill sesga hacia flaggear de más, no de menos
- Igual que en la Demo 4: el agente propone la categoría, vos la confirmás
  antes de actuar
