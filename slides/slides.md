---
marp: true
theme: default
paginate: true
---

<!-- _class: lead -->

# De prompt a skill
## Cultivando workflows de QA con agentes de Claude

Edgardo Crovetto · 2026

---

# La pirámide de promoción

```
              ┌──────────────┐
              │     Hook     │  determinista, lo ejecuta la harness
              ├──────────────┤
              │     Rule     │  guardrail textual, siempre cargado
              ├──────────────┤
              │     Skill    │  procedimiento invocable bajo demanda
              ├──────────────┤
              │    Memory    │  hecho/preferencia recordado
              ├──────────────┤
              │ Prompt suelto│  lo que tipeás hoy
              └──────────────┘
```

Cada nivel hacia arriba = más estructura, menos ceremonia futura.

---

# Fuentes

**Lo que descargás:**
- `/plugin` marketplace
- `superpowers` (TDD, debugging, brainstorming)
- `pr-review-toolkit` (5 reviewers)
- MCP servers públicos

**Lo que destilás:**
- Skills propios → `.claude/skills/`
- Rules → `.cursor/rules/`
- Hooks → `.claude/settings.json`
- Memory → `memory/`

---

<!-- _class: lead -->

# Skills + Rules + Memory + Subagents
# = workflow de QA reproducible

Tu setup no se diseña. Se cultiva.

github.com/edcrove/claude-qa-demo
