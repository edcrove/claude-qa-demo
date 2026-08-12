---
marp: true
theme: gaia
class: invert
paginate: true
backgroundColor: "#1a1d24"
color: "#e8e8e8"
style: |
  section { font-family: 'Inter', 'Helvetica Neue', sans-serif; padding: 50px 60px; font-size: 26px; }
  section h1 { color: #d97757; font-size: 1.6em; margin-top: 0; }
  section h2 { color: #c8c8c8; font-weight: 400; font-size: 1.2em; }
  section p, section li { font-size: 0.95em; line-height: 1.5; }
  code { background: #2d3139; color: #e8a373; padding: 2px 6px; border-radius: 3px; font-size: 0.85em; }
  pre { background: #11141a; border-left: 3px solid #d97757; padding: 12px 16px; margin: 8px 0; }
  pre code { background: transparent; color: #d4d4d4; font-size: 0.62em; line-height: 1.35; padding: 0; }
  table { border-collapse: collapse; }
  table th { background: #2d3139; color: #d97757; }
  table td, table th { border: 1px solid #3a3f4a; padding: 8px 12px; }
  blockquote { border-left: 4px solid #d97757; color: #b8b8b8; }
  a { color: #e8a373; }
  section.lead h1 { color: #d97757; font-size: 1.8em; }
  section.lead h2 { color: #e8e8e8; font-weight: 300; }
---

<!-- _class: lead -->

# De prompt a skill
## Cultivando workflows de QA automation con agentes de Claude

Edgardo Crovetto · 2026

---

<!-- _class: lead -->

# Una noche perdí 90 minutos

## triageando regresiones que no existían

Dos builds en paralelo compartían credenciales.
Todo rojo. Nada roto.

**Hoy eso no puede pasarme — no porque me acuerde:
porque mi setup se acuerda por mí.**

Esta charla es la historia de cómo llegué ahí.

---

# Quién soy

**Edgardo Crovetto** · QA automation engineer

Java + TypeScript · tests automatizados · CI/CD · pipelines

**Me gusta mejorar procesos — sobre todo los que ya estaban funcionando.**

> Esta charla no es sobre features. Es sobre **un patrón**.

`linkedin.com/in/edgardocrovetto`

---

# La pregunta de hoy

> ## ¿Puedo automatizar mi proceso de QA con IA?

Spoiler: sí — **sobre los rieles que ya tenés.**

---

# Mi setup antes de IA

Plataforma de streaming · servicio backend REST

**Framework:** Java + TestNG + RestAssured + Allure reports

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

> Funcionaba. Pero todo el contexto de cada ticket vivía **en mi cabeza**.

---

# Tu día como QA, hoy

- **Análisis del ticket** — Jira + repo + Confluence (AC) + TestRail · todo el contexto en tu cabeza
- **Mapeo AC ↔ cambio** — comparás docs vs branch a ojo, página por página
- **Test cases + automation** — copiás AC a TestRail, traducís a TestNG/RestAssured, linkeás IDs a mano
- **Ejecución multi-env** — Jenkins contra 3 ambientes · comparás resultados · investigás cada rojo
- **PR review** — armás la evidencia, pingeás 2 peers, esperás, re-pingeás
- **Bug found** — abrís ticket, pegás logs, follow-up del ciclo de vida en Jira
- **Mañana** — sesión nueva. Re-explicás el ticket, el plan, las convenciones.

**Mucho de eso es contexto que se pierde entre sesiones.**

---

<!-- _class: lead -->

## ¿Y si ese contexto **sobreviviera**?

---

<!-- _class: lead -->

# La tesis

# Mi setup no se diseñó.

# Se cultivó.

---

# Cuando empezó la IA: dos pasos

**1. Conectar Claude al repo del trabajo**
- `CLAUDE.md` inicial: 5 líneas
- Lo demás vino con el tiempo

**2. Agregar MCPs, uno a uno**
- 🎫 **Jira** — leer tickets, comentar, transicionar estados
- ✅ **TestRail** — leer/escribir test cases · asociar runs a builds
- 🏗️ **Jenkins** — triggerear builds · leer resultados de regression
- 📄 **Confluence** — leer acceptance criteria, specs, decisiones

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

| MCP | Para qué lo uso |
|-----|-----------------|
| 🎫 **Jira** | Leer ticket + AC, comentar, transicionar el estado |
| ✅ **TestRail** | Leer/escribir test cases, asociar runs a builds |
| 🏗️ **Jenkins** | Triggerear builds, leer resultados, descargar logs |
| 📄 **Confluence** | Leer specs y acceptance criteria |

Una sola conversación con Claude puede pasar por los **4**.

---

# Los workflows que emergieron

De pedir cosas día a día — sin diseñarlo:

- **Docs vs código** — diff entre Confluence y lo implementado
- **AC vs branch** — diff entre Acceptance Criteria y el branch real
- **Generar test cases** — propuestas desde los AC + el código
- **Automatizar casos** — TestNG/RestAssured a partir del caso
- **Multi-env Jenkins** — correr la suite contra distintos ambientes
- **PR estructurado** — armar el PR con la evidencia que el peer espera
- **Revisión pre-peer** — los agentes hacen el primer pase

Cada uno se promovió a skill cuando se repitió **3+ veces**.

---

# La pirámide de promoción

```
                  ╔════════════╗
                  ║    HOOK    ║   ◀ lo ejecuta la harness (determinista)
                  ╚════════════╝
                ╔════════════════╗
                ║      RULE      ║  ◀ guardrail, siempre cargado
                ╚════════════════╝
              ╔════════════════════╗
              ║       SKILL        ║ ◀ procedimiento invocable bajo demanda
              ╚════════════════════╝
            ╔════════════════════════╗
            ║        MEMORY          ║ ◀ hecho recordado entre sesiones
            ╚════════════════════════╝
          ╔════════════════════════════╗
          ║      PROMPT SUELTO         ║ ◀ lo que tipeás hoy
          ╚════════════════════════════╝

          más estructura  ↑           ↑  menos ceremonia futura
```

---

# Las 4 piezas — una sola historia

**El typecheck que me olvidaba después de cada rebase:**

| | Pieza | El mismo olvido, subiendo la pirámide |
|---|---|---|
| 1 | **Prompt** | *"acordate del typecheck antes de CI"* — tipeado una y otra vez |
| 2 | **Memory** | `feedback-local-build-before-ci` — y me lo olvidé igual |
| 3 | **Skill** | `local-build-gate` — ahora lo corre Claude por mí |
| 4 | **Hook** | typecheck en cada edit — 5 olvidos después, **ya no depende de nadie** |

La **Rule** tiene su propia cicatriz: `no-parallel-ci` — los 90 minutos del principio.

Markdown y JSON en el repo. Anatomía y ejemplos completos: **apéndice**.

> Ninguna pieza se diseñó. Cada una fue admitir que acordarse no escala.

---

# Subagentes — qué son

> Hasta acá vimos el **setup** — que vive en **archivos**.
> Ahora hablemos del **motor** — los subagentes, que corren en sesión.

Un agente subordinado con su **propio contexto** y **sus propias tools**.

- No ven tu historial — vos los preparás
- No te contaminan — el principal solo ve el resumen final
- Pueden ser **especializados** (code-reviewer, debugger, etc.)
- Se despachan en **paralelo** sin que se pisen

---

# Subagentes en paralelo

```
   ┌───────────────────────────────────────────────────────────────┐
   │                       Main agent (vos)                        │
   └─────┬───────┬───────┬───────┬───────┬─────────────────────────┘
         │       │       │       │       │     ◀ despacho paralelo
         ▼       ▼       ▼       ▼       ▼
     ┌──────┐┌──────┐┌──────┐┌──────┐┌──────┐
     │ code ││silent││ type ││ comm.││ test │  ◀ 5 contextos aislados
     │review││failur││design││analyz││analyz│
     └──┬───┘└──┬───┘└──┬───┘└──┬───┘└──┬───┘
        │       │       │       │       │
        └───────┴───┬───┴───────┴───────┘
                    ▼
              ┌──────────────┐
              │  Aggregator  │  ◀ un solo comentario al final
              └──────────────┘
```

**Antes de que un peer humano vea el PR, ya pasó por 5 revisores especializados.**
El peer review queda libre para arquitectura — no para tipos básicos o
`catch` que tragan errores. *(Mis compañeros aplaudieron esto.)*

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
                    │              │             │              │
                    ▼              ▼             ▼              ▼
                  HOOK         RULE            5 SUB-         MEMORY
                  typecheck    no-parallel-   AGENTES        known-
                  on-edit      ci             en paralelo    issues

   ─────────── memory + rules cargadas todo el tiempo ────────────────

   ⟳ Loop: corrección repetida 3× ──▶ writing-skills ──▶ skill nueva
```

**Cada pieza compone con las demás.** No hay un workflow único — hay piezas.

---

<!-- _class: lead -->

# Ahora, en vivo

## Un día de QA, del ticket al merge

6 escenas · 9:00 → 18:00 · repo `claude-qa-demo` · todo offline

*El demo está en TypeScript para que entre en pantalla y compile rápido.
El patrón es **idéntico** en Java/TestNG/RestAssured.*

---

# Demo 1 · 9:00 — Ticket → plan de cobertura

> *↩ Resuelve: las 4 pestañas para entender el contexto.*

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

El skill **fuerza** el orden. No te deja saltar el red.

*Gap cerrado, tests verdes. Ahora quiero correr esto en CI. →*

---

# Demo 3 · 11:30 — Gate local antes de CI

> *↩ Resuelve: triggerear Jenkins con un typo y esperar 10 min para enterarte.*

**Prompt:**
> *"Triggeá un build de Jenkins para esta branch."*

Lo que pasa en vivo:
1. `local-build-gate` → typecheck + tests locales ✅
2. `no-parallel-ci.mdc` → **build 43 ya está corriendo en stage** (`build-43-running.json`)
3. Claude **se niega a triggerear**: esperar ~12 min o cambiar de env

**El guardrail no me cuida a mí del agente — nos cuida a los dos del incidente.**
Los 90 minutos del principio, exactamente.

*Build 43 termina, corre el mío, abro la PR. →*

---

# Demo 4 (1/2) · 14:00 — Multi-agent PR review ⭐

> *↩ Resuelve: repetir los mismos comentarios review tras review.*

PR sembrada con 5 bugs distintos (`mocks/github/pr-7.diff`):
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

*Review adentro. Antes del merge, la regression completa en Jenkins. →*

---

# Demo 5 · 17:00 — Triage de fallas de CI

> *↩ Resuelve: triagear tests rojos a mano contra known-issues.*

**Input:** `mocks/jenkins/build-42.json` — 5 rojos **sin etiquetar**: nombre,
mensaje, stack y los commits. Y es **la misma branch de hoy**:
`feature/DEMO-100-channels-coverage`.

**Skill invocada:** `ci-failure-triage` + registry `memory/known-issues.md`

| Categoría | De dónde sale |
|---|---|
| Flake conocido | La firma matchea el registry (2× `TimeoutException`, visto hasta build 39) |
| Infra | El ambiente no responde (`Connection refused` a auth) |
| Regresión real | No está en el registry **y** el commit toca código relacionado |

**La categoría se deduce de la evidencia — no viene dada en el JSON.**

*Triage hecho. Pero hoy, tres veces, me corregiste lo mismo... →*

---

# Demo 6 · 18:00 — De prompt repetido a skill 🪄

> *↩ Resuelve: re-explicar el ticket, el plan, las convenciones en una sesión nueva.*

Durante la sesión, Claude fue corregido **3 veces** con
*"acordate de chequear X antes de Y"*.

**Prompt:**
> *"Esto ya me lo recordaste 3 veces. ¿Lo convertimos en skill?"*

**Skill invocada:** `superpowers:writing-skills`
*(alternativa del marketplace: el plugin `skill-creator`)*

Output: un `SKILL.md` nuevo en `.claude/skills/`.

La slide del principio terminaba:
*"Mañana — sesión nueva. Re-explicás el ticket, el plan, las convenciones."*

**Mañana — sesión nueva. No se re-explica ni el ticket,
ni el plan, ni las convenciones.**

**Este es el patrón completo en acción.**

---

# Mi línea de tiempo real

```
mes 1   CLAUDE.md inicial + Claude conectado al repo
mes 1   ← MCPs: Jira, TestRail, Jenkins, Confluence
mes 1   ← Skill: ticket-coverage-gap-analysis (de 4 pestañas a 1 prompt)
mes 2   ← Skill: AC-vs-branch-diff (después de mergear sin validar un AC)
mes 2   ← Rule: no-parallel-ci (90 min cazando flakes fantasma)
mes 3   ← Plugin pr-review-toolkit + skill multi-agent-pr-review
mes 3   ← Skill: pre-peer-review (compañeros aplaudieron)
mes 4   ← Hook: typecheck-after-edit (memory + rule no alcanzaban)
mes 5   ← Skill: ci-failure-triage
mes 6   ← Memory updates con feedback de compañeros (loop abierto)
ahora   ← El setup vive en git. Los compañeros lo PR-ean también.
```

**Nada se planificó. Cada pieza respondió a un dolor concreto.**

---

# El agente también construye

Cultivar no es solo skills, rules y memory **para** el agente.
Es lo que el agente construye **con vos**:

- **CI a tu medida** — el pipeline corre con tus reglas, no con las heredadas
- **Linters / checkstyle** — configurados y explicados, no copiados de un gist
- **SonarQube y quality gates** — de "algún día" a un PR
- **Coverage y reportes** — Allure, badges, dashboards
- **Notificaciones** — el build roto te encuentra a vos, no al revés

Cada una pedía **investigación + skill técnico dedicado**. Hoy es una conversación.

> **No le tengas miedo a lo desconocido: el costo de aprender colapsó.**
> Cultivás al agente — y el agente madura el proyecto.

---

# Fuentes

**Lo que descargás:**
- `/plugin` marketplace · `superpowers` · `pr-review-toolkit`
- MCP servers públicos (Atlassian, GitHub, Slack, context7)

**Lo que destilás:**
- Skills `.claude/skills/` · Rules `.claude/rules/`
- Hooks `.claude/settings.json` · Memory `memory/`

**Para comunicar el trabajo:**
- **Gamma** (`gamma.app`) — slides AI desde un prompt
- **Marp** — slides como código (este deck) · **Mermaid / draw.io** — diagramas en texto

> Tip: `slides.md` se importa a Gamma en 2 clics. Mismo contenido, otro template.

---

# El patrón

```
Prompt suelto  →  Memory  →  Skill  →  Rule  →  Hook
   (hoy)         (mañana)   (semana)   (mes)   (trimestre)
```

Cada nivel:
- **Más estructura**, **menos ceremonia futura**
- **Versionable**, **reviewable**, **reusable**
- **Promociona** desde lo concreto, no desde una reunión

---

<!-- _class: lead -->

## La pregunta del principio

# ¿Puedo automatizar mi proceso de QA con IA?

**Sí — lo acabás de ver.**
**¿Se diseñó? No. Se cultivó.**

---

# 3 pasos para el lunes

**1. Un `CLAUDE.md` de 5 líneas** en el repo donde más trabajás.
Nombre del proyecto, comando de test, convención de commits. Nada más.

**2. Anotá la próxima corrección que repitas.**
La segunda vez que escribís *"acordate de X antes de Y"*, eso es una memory.
La tercera, un skill.

**3. Bajá lo que ya existe:** `/plugin` → `superpowers` + `pr-review-toolkit`.
Arrancás con workflows que no tuviste que escribir.

> Nada de esto necesita presupuesto, permiso, ni una reunión de arquitectura.

---

<!-- _class: lead -->

# Tu setup no se diseña.
# Se cultiva.

**Skills + Rules + Memory + Subagentes = workflow reproducible**

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

Una corrección repetida 3 veces es candidata a memory.

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

Persiste entre sesiones. Sobrevive al `/clear`.

---

# Memory — ejemplo real

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

Nació después de 90 minutos cazando flakes fantasma.

---

# Hook — anatomía

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
la memory y la rule**. El hook fue el final del camino.

---

<!-- _class: lead -->

# Backup — Q&A

## Respuestas que suelen hacer falta

---

# ¿Y los costos en tokens?

- El día a día corre en un modelo mid-tier; el multi-agent review es el único paso caro
- 5 subagentes = 5 contextos aislados — pagás tokens para **no** pagar contexto contaminado
- El costo contra el que se compara: 10 min de CI roto · 90 min de flakes
  fantasma · un review que espera 2 días
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
