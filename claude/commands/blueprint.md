---
description: Design a project blueprint through goal-driven domain analysis, ubiquitous language capture, and agentic workflow architecture
argument-hint: [project-name]
allowed-tools: ["Read", "Write", "Bash", "Glob", "Grep", "WebSearch", "WebFetch", "AskUserQuestion", "Task"]
---

# Blueprint Command — Claude-First Project Blueprint

Design a project blueprint from the ground up for agentic, Claude-driven development. This command walks through goal-driven domain analysis, ubiquitous language capture, agent architecture design, and scaffolding — producing a fully configured CLAUDE.md and agent files.

---

## Prerequisites

Before starting, confirm:
- You have Write and Bash tool access
- You can use AskUserQuestion for interactive steps

**All interactive steps use AskUserQuestion. Ask one question at a time. Never batch questions.**

---

## Phase 1: Project Identity

**Entry criteria:** Command invoked.
**Exit criteria:** All six identity fields are captured and confirmed.

### Step 1.1: Project Name

Check if `$ARGUMENTS` was provided.

- **If provided:** Use `$ARGUMENTS` as the project name. Inform the user: "Using project name: [name]"
- **If not provided:** Ask the user using AskUserQuestion:

> "What is the name of this project? Use lowercase-kebab-case (e.g., fleet-tracker, booking-engine)."

Store the result as `PROJECT_NAME`.

**Validation:** Check that `PROJECT_NAME` matches the pattern `^[a-z][a-z0-9-]*$` (lowercase kebab-case, starting with a letter).

- **If valid:** Proceed.
- **If not valid:** Auto-generate a kebab-case suggestion by lowercasing, replacing spaces and underscores with hyphens, and stripping invalid characters. Present it to the user using AskUserQuestion:

> "The project name '[original input]' is not valid kebab-case. Suggested name: '[suggested-name]'. Use this name? (yes / provide alternative)"

If the user provides an alternative, re-validate. Loop until a valid name is confirmed.

### Step 1.2: Project Location

Ask the user using AskUserQuestion with these options:

> "Where should this project live?"
>
> 1. New directory — creates `./$PROJECT_NAME/` in the current working directory
> 2. Current directory — uses the current working directory as-is
> 3. Custom path — you specify the full path

- If option 1: Set `PROJECT_DIR` to `$CWD/$PROJECT_NAME`
- If option 2: Set `PROJECT_DIR` to `$CWD`
- If option 3: Ask for the path using AskUserQuestion, then set `PROJECT_DIR` accordingly

Verify the directory exists or can be created. Use Bash to create it if needed:

```bash
mkdir -p "$PROJECT_DIR"
```

### Step 1.3: Mission Statement

Ask the user using AskUserQuestion:

> "In one sentence, what is this project's reason to exist? Be specific — not 'build an app' but 'automate fleet damage tracking to reduce manual inspection time by 80%.'"

Store as `MISSION`.

### Step 1.4: Goals

Ask the user using AskUserQuestion:

> "List 3-7 concrete goals for this project. Number them. Each goal should be specific and measurable where possible."
>
> Example:
> 1. Ingest damage reports from 3 external inspection APIs
> 2. Provide a real-time dashboard for fleet managers
> 3. Generate weekly cost reports per vehicle category

Store as `GOALS` (preserve numbering).

### Step 1.5: Scenario Walkthrough

Ask the user using AskUserQuestion:

> "Walk me through a typical day or workflow using this system. Start from the first interaction and describe what happens step by step, including who does what and what triggers each step."
>
> This helps surface domains, events, and workflows that direct questions miss. Be as detailed as you like — mention the people involved, the actions they take, what they see, and what happens behind the scenes.

Store as `SCENARIO`. This will be used as additional input for Phase 2's domain analysis — it often reveals actors, events, edge cases, and domain boundaries that goals alone do not capture.

### Step 1.6: Known Constraints

Ask the user using AskUserQuestion:

> "What constraints should this project respect? Consider:"
>
> - Tech stack (language, framework, database, hosting)
> - Team size and skill level
> - Existing systems this must integrate with
> - Domain-specific rules or regulations
> - Timeline or budget constraints
> - Security or compliance requirements
>
> List everything relevant. If none, say 'none'.

Store as `CONSTRAINTS`.

### Step 1.7: Confirm Identity

Present a summary to the user using AskUserQuestion:

> **Project Identity Summary**
>
> - **Name:** [PROJECT_NAME]
> - **Location:** [PROJECT_DIR]
> - **Mission:** [MISSION]
> - **Goals:** [GOALS]
> - **Scenario:** [SCENARIO — abbreviated if long, with key actors and events highlighted]
> - **Constraints:** [CONSTRAINTS]
>
> Does this look correct? (yes / edit [field name])

If the user wants edits, re-ask the specific field. Loop until confirmed.

---

## Phase 2: Domain Analysis

**Entry criteria:** Phase 1 complete with confirmed identity.
**Exit criteria:** Domain map confirmed by user.

### Step 2.1: Identify Domains

Analyze the mission, goals, scenario walkthrough, and constraints to identify distinct work domains. Use goal-driven capability decomposition — not technology-layer decomposition.

**Goal-driven decomposition process:**

1. **Goals to capabilities:** For each goal from Phase 1, identify the capabilities needed to achieve it. A capability is a thing the system must be able to do (e.g., "accept a booking," "calculate damage cost," "send a notification").

2. **Capabilities to requirements:** For each capability, determine what knowledge, tools, and data it requires to function.

3. **Group by cohesion:** Group capabilities into domains based on cohesion — capabilities that share the same data, vocabulary, or change together belong in the same domain. Signs of good cohesion:
   - They share core data entities
   - They use the same specialized vocabulary
   - A change to one typically requires a change to the others
   - They have a natural owner (a single team or role)

4. **Incorporate scenario insights:** Review the scenario walkthrough from Phase 1. Check for actors, events, workflows, or edge cases that the goal-based decomposition missed. Add or adjust domains as needed.

5. **Cross-check for gaps:** Review the following list of supporting concerns to verify nothing critical was missed. These should NOT drive the decomposition, but they may reveal supporting domains that pure goal analysis overlooks:
   - Data ingestion — external data sources, ETL, file processing
   - Data storage — database design, migrations, data models
   - API layer — endpoints, authentication, request/response handling
   - UI / frontend — user interfaces, dashboards, forms
   - CLI / tooling — command-line tools, scripts, developer utilities
   - Testing — test strategy, test infrastructure, test data
   - Infrastructure — deployment, CI/CD, monitoring, logging
   - Security — authentication, authorization, data protection
   - Integration — third-party services, webhooks, message queues
   - Documentation — API docs, user guides, architecture docs

For each identified domain, determine:
1. **What work happens here** — concrete tasks and responsibilities
2. **Expertise required** — what knowledge is needed
3. **Tools and capabilities needed** — languages, frameworks, APIs, Claude tools
4. **Inputs** — what this domain consumes
5. **Outputs** — what this domain produces
6. **Ubiquitous language** — key terms this domain owns and defines; note where the same term might mean something different in another domain (e.g., "vehicle" in fleet management means a physical asset with maintenance history, while in booking it means an available rental unit with a rate)

### Step 2.2: Map Domain Relationships

Determine how domains depend on each other:
- Which domains produce inputs for other domains?
- Which domains must be built first?
- Which domains can be developed in parallel?
- Where are the natural handoff points?

### Step 2.3: Present Domain Map

Present the complete domain analysis to the user using AskUserQuestion:

> **Domain Map**
>
> [For each domain:]
> ### [Domain Name]
> - **Work:** [description]
> - **Expertise:** [requirements]
> - **Tools:** [list]
> - **Inputs:** [from where]
> - **Outputs:** [to where]
> - **Language:** [key terms this domain owns, with disambiguation notes where a term overlaps with another domain]
>
> **Dependencies:**
> [Visual or textual representation of domain relationships]
>
> Does this domain map look right? Should I add, remove, or modify any domains?

Iterate until the user confirms.

---

## Phase 3: Agent Architecture Design

**Entry criteria:** Phase 2 complete with confirmed domain map.
**Exit criteria:** Agent architecture confirmed by user.

### Step 3.1: Map Domains to Agents

For each domain from Phase 2, decide whether it warrants a dedicated agent or can be handled by a general-purpose agent.

**Decision criteria — a domain gets a dedicated agent when:**
- It requires specialized knowledge that would clutter a general agent's prompt
- It needs a distinct set of tools not shared with other domains
- It represents a natural handoff point in the workflow (e.g., code review after code writing)
- It benefits from a focused Definition of Done
- It operates at a different quality/speed tradeoff (haiku vs opus)

**A domain does NOT need a dedicated agent when:**
- The work is straightforward and generic
- It shares the same tools and knowledge as another domain
- It would create unnecessary handoff overhead
- It can be a responsibility within an existing agent's scope

### Step 3.2: Define Each Agent

For each agent (including any general-purpose agent), define:

1. **Name** — clear, role-based (e.g., `senior-software-engineer`, `code-reviewer`, `test-engineer`, `devops-engineer`)
2. **Role description** — one paragraph explaining what this agent does and why it exists
3. **Model recommendation:**
   - **Haiku** — quick, repetitive, low-complexity tasks (formatting, simple generation, boilerplate)
   - **Sonnet** — standard development work (implementation, testing, documentation)
   - **Opus** — complex reasoning, architecture decisions, nuanced code review, ambiguous requirements
4. **Tools needed** — specific list from available Claude Code tools
5. **Trigger conditions** — when in the workflow this agent is invoked
6. **Domains covered** — which domains from Phase 2 this agent handles
7. **Definition of Done** — specific, measurable criteria for when this agent's work is complete

### Step 3.3: Define Workflow Pipeline

Determine the sequence of agent handoffs for the primary workflow:

1. What triggers the workflow? (user request, event, schedule)
2. Which agent starts?
3. What does each agent hand off to the next?
4. What quality gates exist between agents?
5. What happens if an agent's output fails a quality gate?
6. What is the terminal condition? (when is the whole workflow done?)

### Step 3.4: Define Contracts Between Agents

For each agent boundary (handoff point), specify:

- **Producer agent** — who generates the output
- **Consumer agent** — who receives it
- **Output format** — what the producer delivers (files, messages, artifacts)
- **Quality criteria** — what the consumer checks before accepting
- **Rejection protocol** — what happens if quality criteria are not met

### Step 3.5: Present Architecture

Present the complete agent architecture to the user using AskUserQuestion:

> **Agent Architecture**
>
> ### Agents
> [For each agent: name, role, model, tools, trigger, DoD]
>
> ### Workflow Pipeline
> [Step-by-step flow with handoffs]
>
> ### Contracts
> [For each boundary: producer, consumer, format, quality gate]
>
> Does this architecture look right? Should I adjust any agents, the workflow, or the contracts?

Iterate until confirmed.

---

## Phase 4: Generate CLAUDE.md

**Entry criteria:** Phase 3 complete with confirmed architecture.
**Exit criteria:** CLAUDE.md written to project directory.

### Step 4.1: Build CLAUDE.md Content

Construct the CLAUDE.md file with the following sections, in order:

```markdown
# [PROJECT_NAME]
## [One-line mission]

---

# 1. PROJECT IDENTITY

- **Name:** [PROJECT_NAME]
- **Mission:** [MISSION]
- **Created:** [current date]

---

# 2. GOALS

[Numbered goals from Phase 1, exactly as confirmed]

---

# 3. CONSTRAINTS

[Constraints from Phase 1]

---

# 4. UBIQUITOUS LANGUAGE

[Consolidated glossary of key terms from all domains. For terms with different meanings in different domains, note the disambiguation.]

| Term | Domain | Definition |
|------|--------|------------|
| [term] | [domain] | [what it means in this domain] |

---

# 5. AGENTIC WORKFLOW

Rules to follow:

1. We use agentic workflow. All substantive work is routed through the defined agents.
2. [For each agent handoff rule, e.g., "Never consider code complete until the code-reviewer agent has reviewed it."]
3. [Additional workflow rules derived from the pipeline]

---

# 6. AGENT DEFINITIONS

[For each agent:]

## [Agent Name]

- **Role:** [description]
- **Model:** [haiku/sonnet/opus]
- **Tools:** [list]
- **Trigger:** [when invoked]
- **Domains:** [which domains]

### Definition of Done
[Specific, measurable criteria]

---

# 7. WORKFLOW PIPELINE

[Step-by-step sequence with clear handoff descriptions]

[Include a text-based flow diagram if helpful, e.g.:]
User Request -> [Agent A] -> Quality Gate -> [Agent B] -> Quality Gate -> Done

---

# 8. CONTRACTS

[For each agent boundary:]

### [Producer] -> [Consumer]
- **Output:** [what is handed off]
- **Quality Gate:** [what is checked]
- **On Rejection:** [what happens]

---

# 9. DEFINITION OF DONE — PER AGENT

[Consolidate all per-agent DoDs in one reference section]

---

# 10. GLOBAL DEFINITION OF DONE

A task is Done when:

1. All numbered requirements from the spec are implemented.
2. No open "Must Fix" issues remain from code review.
3. Critical paths have tests.
4. The code runs without errors.
5. Edge cases listed in the spec are handled.
6. No obvious security risks exist.
7. Logging exists for failure paths.
8. The solution does not introduce breaking changes (unless explicitly allowed).

If all conditions are satisfied -> Stop.

---

# 11. OUTPUT STYLE

- Be clear, structured, and direct.
- Use bullet points and clear sections.
- No filler, no fluff, no motivational language.
- Every sentence adds value.
- Prefer concrete proposals over abstract observations.
```

### Step 4.2: Write CLAUDE.md

Use the Write tool to create `$PROJECT_DIR/CLAUDE.md` with the constructed content.

Confirm to the user: "CLAUDE.md written to [path]."

---

## Phase 5: Scaffold Agent Files

**Entry criteria:** Phase 4 complete, CLAUDE.md written.
**Exit criteria:** All agent files created, summary presented.

### Step 5.1: Create Agent Directory

```bash
mkdir -p "$PROJECT_DIR/.claude/agents"
```

### Step 5.2: Create Agent Files

For each agent defined in Phase 3, use the Write tool to create `$PROJECT_DIR/.claude/agents/[agent-name].md` containing:

```markdown
# [Agent Name]

## Role

[Detailed role description — expand beyond the one-liner in CLAUDE.md. This is the agent's full system prompt context. Include personality, operating style, and decision-making principles relevant to this role.]

## Model

[Recommended model with rationale]

## Tools

[List of allowed tools with brief explanation of why each is needed]

## Domains

[Which domains this agent owns, with specifics about what that means in practice]

## Ubiquitous Language

[The key terms this agent is authoritative over, drawn from the domains it covers in Phase 2. For each term, provide a brief definition as it applies within this agent's scope. Flag any terms that have different meanings in other agents' domains.]

## Trigger Conditions

[When this agent is invoked — be specific about the workflow conditions]

## Input Contract

[What this agent expects to receive:]
- Format
- Required fields
- Assumptions about input quality

## Output Contract

[What this agent must produce:]
- Format
- Required deliverables
- Quality standards

## Definition of Done

[Specific, measurable completion criteria — copy from Phase 3 but expand with operational detail]

## Operating Principles

[3-7 principles specific to this agent's role, e.g.:]
1. [Principle]
2. [Principle]
3. [Principle]

## Failure Protocol

[What this agent does when it encounters problems it cannot resolve:]
- How to escalate
- What information to include in escalation
- When to stop vs. when to attempt recovery
```

### Step 5.3: Optional — Settings File

Ask the user using AskUserQuestion:

> "Would you like me to create `.claude/settings.json` with tool permissions pre-configured for this project? (yes/no)"

If yes, use the Write tool to create `$PROJECT_DIR/.claude/settings.json` using the following template skeleton:

```json
{
  "permissions": {
    "allow": [],
    "deny": []
  }
}
```

Populate the `allow` list with tool permissions derived from the agents' tool definitions (e.g., `"Bash(npm run *)"`, `"Read"`, `"Write"`, `"Glob"`, `"Grep"`). Only include tools that at least one agent explicitly requires. Leave `deny` empty unless the user specifies tools that should be blocked.

### Step 5.4: Optional — Git Init

Ask the user using AskUserQuestion:

> "Would you like me to initialize a git repository in the project directory? (yes/no)"

If yes:

> **Note (if "Current directory" was chosen in Step 1.2):** Only the files created by this command will be staged. Any pre-existing files in the directory will NOT be included in the initial commit. You can stage them separately after reviewing.

```bash
cd "$PROJECT_DIR" && git init && git add CLAUDE.md .claude/ && git commit -m "Initial project blueprint"
```

### Step 5.5: Verification and Summary

Read back all created files using the Read tool to verify they were written correctly.

Then present a final summary to the user:

> **Project Blueprint Complete**
>
> **Project:** [PROJECT_NAME]
> **Location:** [PROJECT_DIR]
>
> **Files Created:**
> - `CLAUDE.md` — project identity, goals, workflow, agent definitions, contracts, DoD
> - `.claude/agents/[agent-name].md` — [one per agent, list all]
> - `.claude/settings.json` — [if created]
>
> **Agents Configured:** [count]
> [List each agent with one-line role summary]
>
> **Workflow Pipeline:**
> [Brief pipeline description]
>
> **Next Steps:**
> 1. Review CLAUDE.md and adjust any sections that need refinement
> 2. Open the project directory in Claude Code: `cd [PROJECT_DIR]`
> 3. Start working — the agentic workflow is ready
>
> Run `/retro` after your first significant implementation to capture improvements.

---

## Error Handling

- If any Write operation fails, report the error and retry once. If it fails again, inform the user with the exact error.
- If the user provides ambiguous input at any AskUserQuestion step, ask a clarifying follow-up — do not guess.
- If the domain analysis produces zero domains, something is wrong. Re-examine the mission, goals, and scenario, then ask the user for clarification.
- If the architecture produces only one agent, that is acceptable — not every project needs multiple agents. Confirm with the user that a single-agent setup is intentional.
- If the scenario walkthrough is very brief (fewer than 3 steps or interactions), probe with follow-up questions: "What happens after [last thing mentioned]?" or "Who else interacts with the system during this workflow?" Aim for at least one complete end-to-end flow before proceeding to Phase 2.

---

## Notes

- This command produces a starting point, not a final product. The CLAUDE.md and agent files should evolve as the project matures.
- Prefer fewer, well-defined agents over many narrow ones. Agent overhead (handoffs, contracts, quality gates) has a cost. Only add agents when the benefit clearly outweighs the coordination cost.
- The Global Definition of Done is a baseline. Projects may add stricter criteria but should not weaken it.
- All agent files use Markdown because they serve as prompt context — keep them readable and well-structured.
- Domain analysis is the foundation. If domains are wrong, agents will be wrong. Invest time in Phase 2.
- Goal-driven decomposition produces business-capability domains, not technology-layer domains. Resist the urge to create domains like "database" or "API" — instead, create domains like "booking management" or "fleet tracking" that own their data and logic end-to-end.
- Ubiquitous language prevents miscommunication between agents. When two domains use the same word differently, making that explicit early avoids subtle bugs downstream.
- The scenario walkthrough in Phase 1 often reveals workflow details, actors, and edge cases that structured goal-setting misses. Treat it as a first-class input to domain analysis, not an afterthought.
