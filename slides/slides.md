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
## Cultivando workflows de QA con agentes de Claude

Edgardo Crovetto · 2026

---

# ¿Quién soy?

- QA / STE en una plataforma de streaming
- 10+ años trabajando con tests automatizados
- Java y TypeScript en el día a día
- Convertido a "agentes" cuando descubrí que **el setup se podía versionar**

> Esta charla no es sobre features. Es sobre **un patrón**.

---

# La pregunta de hoy

> Si tu compañero nuevo te pregunta *"¿cómo arrancás un día de QA acá?"*,
> ¿podés mostrárselo en un repo en lugar de un Confluence?

Spoiler: sí, podés.

---

# Tu día como QA, hoy

- Llega un ticket → abrís 4 pestañas para entender el contexto
- Hacés un PR → pegás el mismo prompt de review otra vez
- Falla un build → triagéas 30 tests rojos a mano
- Mañana arranca una nueva sesión → re-explicás todo

**Mucho de eso es contexto que se pierde entre sesiones.**

---

<!-- _class: lead -->

# La tesis

# Tu setup de Claude no se diseña.

# Se cultiva.

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

# Memory — el primer escalón

Una corrección repetida 3 veces es candidata a memory.

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

Persiste entre sesiones. Sobrevive al `/clear`.

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

Nació de meterla 2 veces en una semana.

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

Nació de 90 minutos triagueando flakes que no existían.

---

# Hook — anatomía

```json
{
  "hooks": {
    "PostToolUse": [{
      "matcher": "Edit",
      "hooks": [{
        "type": "command",
        "command": "<bash command>"
      }]
    }]
  }
}
```

Triggers disponibles: `PreToolUse`, `PostToolUse`, `Stop`, etc.

**Lo ejecuta la harness, no el modelo** — es determinista.

---

# Hook — ejemplo real

```json
{
  "hooks": {
    "PostToolUse": [{
      "matcher": "Edit",
      "hooks": [{
        "type": "command",
        "command": "if [[ \"$CLAUDE_TOOL_FILE_PATH\" == *.ts ]]; then \\
                      cd demo-app && npm run typecheck 2>&1 | tail -10; \\
                    fi"
      }]
    }]
  }
}
```

Cada vez que Claude edita un `.ts`, corre `typecheck` automáticamente.

Promoción: memory → rule → hook. Ya no me puedo olvidar.

---

# Subagentes — qué son

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

El principal no carga 5× los tokens. Solo el agregado.

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

   ⟳ Loop: corrección repetida 3× ──▶ skill-creator ──▶ skill nueva
```

**Cada pieza compone con las demás.** No hay un workflow único — hay piezas.

---

<!-- _class: lead -->

# Ahora, en vivo

## Un día de QA, del ticket al merge

6 escenas. Repo `claude-qa-demo`. Todo offline.

---

# Demo 1 — Ticket → plan de cobertura

**Input:** un ticket de Jira mockeado en `mocks/jira/DEMO-100.json`.

**Prompt:**
> *"Planificá el trabajo para DEMO-100."*

**Skill invocada:** `ticket-coverage-gap-analysis`

**Output:**
- Mapa de cobertura existente (tabla)
- Gaps identificados (✅ / ⚠️ / ❌)
- TodoWrite con casos propuestos + estimación

---

# Demo 2 — TDD asistido

**Prompt:**
> *"Implementá `getChannelBySlug` con TDD."*

**Skill invocada:** `superpowers:test-driven-development`
*(descargada del marketplace, no la escribí yo)*

**Lo que vamos a ver:**
1. Test fallido primero (red)
2. Implementación mínima (green)
3. Refactor opcional

El skill **fuerza** el orden. No te deja saltar el red.

---

# Demo 3 — Gate local antes de CI

**Prompt:**
> *"Triggeá un build de Jenkins para esta branch."*

Antes de hacer nada, Claude consulta:
1. La rule `no-parallel-ci.mdc` → ¿hay otro corriendo?
2. La skill `local-build-gate` → ¿pasa el typecheck local?

Solo si ambos OK, propone triggerar.

**Mensaje:** rules y skills se **componen**.

---

# Demo 4 — Multi-agent PR review ⭐

PR sembrada con 5 bugs distintos (`mocks/github/pr-7.diff`):
- `silent-failure-hunter` → `catch (e) { return [] }` se traga errores
- `type-design-analyzer` → `as Channel` miente
- `comment-analyzer` → comentario que dice "sorted" pero no ordena
- `pr-test-analyzer` → test que solo verifica `toBeDefined()`
- `code-reviewer` → `// TODO` en producción

**Dispatch:** 5 agentes en paralelo, **un solo mensaje**.

---

# Demo 4 — Cómo se agrega

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

---

# Demo 5 — Triage de fallas de CI

**Input:** `mocks/jenkins/build-42.json` — 5 tests fallidos (2 regresiones, 2 flakes, 1 infra).

**Skill invocada:** `ci-failure-triage`

| Categoría | Señal |
|---|---|
| Regresión real | Falla nueva + el cambio toca código relacionado |
| Flake conocido | Match en `known-issues-registry.md` |
| Infra | Mensaje incluye DNS, timeout, conexión rechazada |
| Bug de test | Fecha hardcoded, data stale |

Output: status en una línea + acción sugerida por categoría.

---

# Demo 6 — De prompt repetido a skill 🪄

Durante la sesión, Claude fue corregido **3 veces** con
*"acordate de chequear X antes de Y"*.

**Prompt:**
> *"Esto ya me lo recordaste 3 veces. ¿Lo convertimos en skill?"*

**Skill invocada:** `skill-creator`

Output: nuevo `SKILL.md` guardado. En la próxima sesión,
ya aparece como invocable.

**Este es el patrón completo en acción.**

---

# La línea de tiempo del repo

```
semana 1   CLAUDE.md inicial (5 líneas)
semana 1   ← skill local-build-gate (después de romper CI 2 veces)
semana 2   ← rule no-parallel-ci (después de 90 min de triage falso)
semana 2   ← rule english-only
semana 3   ← skill ci-failure-triage
semana 3   ← skill known-issues-registry-update
semana 4   ← plugin pr-review-toolkit (descargado)
semana 4   ← skill multi-agent-pr-review (wrapper)
semana 5   ← hook typecheck-after-edit (promoción completa)
semana 6   ← skill ticket-coverage-gap-analysis
semana 7   ← memory stage-flakes heuristic
```

**Nada se diseñó. Todo respondió a un dolor concreto.**

---

# Fuentes

**Lo que descargás:**
- `/plugin` marketplace de Claude Code
- `superpowers` (TDD, debugging, brainstorming, …)
- `pr-review-toolkit` (5 reviewers especializados)
- MCP servers públicos (Atlassian, GitHub, Slack, context7)

**Lo que destilás:**
- Skills propios → `.claude/skills/`
- Rules → `.claude/rules/`
- Hooks → `.claude/settings.json`
- Memory → `memory/`

---

# Para comunicar el trabajo

Skills sirven para **hacer**. También hace falta contar lo que hacemos.

- **Gamma** (`gamma.app`) — generador de slides desde un prompt o markdown.
  Ideal para *primera versión* y para audiencias no-técnicas.
- **Marp** — slides como código (markdown → HTML/PDF), versionable en el repo.
  Estas slides están hechas así.
- **Claude Code** — escribir outline, script, ejemplos, diagramas ASCII.
- **Mermaid / draw.io** — diagramas en texto plano, copiables y editables.

> **Tip:** el `slides.md` de este repo se importa a Gamma en 2 clics
> (*Create → Import from text*). Mismo contenido, dos templates distintos.

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

# Skills + Rules + Memory + Subagentes
# = workflow de QA reproducible

Tu setup no se diseña. Se cultiva.

**github.com/edcrove/claude-qa-demo**

---

<!-- _class: lead -->

# ¿Preguntas?

Edgardo Crovetto · @edcrove
