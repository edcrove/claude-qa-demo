# claude-qa-demo

Repo compañero de la charla **"Tu setup de QA no se diseña: se cultiva"** — de
prompt suelto a skills, rules y hooks.

Todo lo que hay acá es texto plano en disco. Clonalo, leelo, copiá lo que te
sirva.

## Empezá por acá

**El deck** — [slides-light-16x9.pdf](slides/slides-light-16x9.pdf) · 48 slides.
También en [16:10](slides/slides-light-16x10.pdf), y en tema oscuro:
[16:9](slides/slides-dark-16x9.pdf) · [16:10](slides/slides-dark-16x10.pdf).
Los PDF están versionados a propósito, así que se leen sin instalar nada.

**El catálogo** — [`docs/showable-inventory.md`](docs/showable-inventory.md).
Las piezas de un setup de QA real, sanitizadas: rules, skills, agentes, hooks y
permisos. Cada fila dice qué hace la pieza y **por qué existe** — casi siempre,
el dolor concreto que la hizo aparecer. Si reconocés el dolor, copiá la pieza.
Arrancá por su tabla *"si copiás sólo tres cosas"*.

## Qué hay adentro

| Path | Para qué |
|------|----------|
| `CLAUDE.md` | Las convenciones del proyecto, que Claude carga al abrir la sesión |
| `.claude/skills/` | 6 workflows invocables — cinco del día de QA, más el que salió de escribir esta charla |
| `.claude/rules/` | 3 guardrails siempre cargados |
| `.claude/settings.json` | 1 hook `PostToolUse` |
| `memory/` | Memoria entre sesiones: una entrada de feedback + el registro de known issues |
| `mocks/` | Jira / Jenkins / GitHub falsos, para correr sin red |
| `skill-templates/` | Plantillas pegables para tus propios skills, rules y hooks |
| `demo-app/` | Una API mínima en TypeScript, la que se usa en las escenas de TDD y de PR |
| `docs/` | STATUS (el ancla para retomar), diseño de la charla, decision log, runbook en vivo, HANDOFF (cápsula para un chat) y el catálogo de piezas |
| `evolution-timeline.md` | Cómo creció este repo semana por semana (la ficción del demo) |
| `SOURCES.md` | De dónde bajar las piezas que ya existían |
| `scripts/` | Seguridad de escenario (`prep-demo.sh`, `check-leaks.sh`, `demo-profile.sh`) y build del deck (`build-deck.sh`, `build-diagrams.sh`, `build-logos.js`, `check-slide-overflow.js`) |
| `slides/` | El deck en Marp, 48 slides (32 de flujo principal + 9 de apéndice + 6 de backup de Q&A + 1 mapa del repo). Ver [`slides/README.md`](slides/README.md) |

## Correr la demo-app

```bash
cd demo-app
npm install
npm test
npm run typecheck
```

## Correr el demo desde cero

```bash
./scripts/prep-demo.sh     # resetea el estado y verifica que cada escena tenga trabajo pendiente
./scripts/check-leaks.sh   # chequea que no haya strings confidenciales antes de pushear
./scripts/demo-profile.sh  # abre Claude con una config aislada (sin contexto de trabajo)
```

El que importa en escena es `demo-profile.sh`: arranca Claude Code con
`CLAUDE_CONFIG_DIR` apuntando a un perfil descartable, así no llega al proyector
ningún `CLAUDE.md` global, ningún MCP de trabajo y ningún token.
`check-leaks.sh` sólo greppea **este** repo — no te puede proteger de tu propia
config global.

Y si vas a usar `check-leaks.sh` en serio, engancharlo como hook de git es lo que
hace que no te lo puedas olvidar:

```bash
ln -s ../../scripts/check-leaks.sh .git/hooks/pre-commit
```

Ese `ln -s` lo tenés que correr vos: **`.git/hooks/` no se versiona**, así que
clonar el repo te trae el script pero no la protección.

## El estado inicial del que dependen las demos

El repo viene **incompleto** a propósito, para que cada escena tenga trabajo real
por hacer:

| Escena | Qué tiene que faltar o estar | Lo verifica |
|--------|------------------------------|-------------|
| Demo 1 | `DEMO-100` lista 4 criterios de aceptación y sólo 2 tienen tests | — |
| Demo 2 | `getChannelBySlug` existe pero **no** valida el formato del slug — ése es el test rojo | `prep-demo.sh` |
| Demo 3 | `build-43-running.json` muestra un build RUNNING en stage, así que `no-parallel-ci` bloquea el trigger en vivo | `prep-demo.sh` |
| Demo 5 | `memory/known-issues.md` está, y `build-44.json` **no** trae pistas de categoría | `prep-demo.sh` |
| Hook | `jq` en el PATH (el hook parsea con eso el JSON que le llega por stdin) | `prep-demo.sh` |

## El patrón

```
Prompt → Memory → Skill → Rule → Hook
```

No se diseña: se cultiva. La historia completa está en
[`evolution-timeline.md`](evolution-timeline.md).

## Licencia

MIT — ver [`LICENSE`](LICENSE).
