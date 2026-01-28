# Ralph Kanban

> Autonomous AI agent orchestration - a fork of [Vibe Kanban](https://github.com/BloopAI/vibe-kanban) with Ralph multi-iteration capabilities.

## Quick Start

Run Ralph Kanban instantly without installation:

```bash
npx ralph-kanban
```

This will launch the application locally and open it in your browser automatically.

## What is Ralph Kanban?

Ralph Kanban extends Vibe Kanban with **autonomous multi-iteration agent capabilities**. Instead of running AI coding agents once per task, Ralph can:

- **Break work into small stories** - Each story is small enough to complete in one AI session
- **Execute one story per iteration** - Fresh context each time, no context overflow
- **Track progress in `prd.json`** - Knows what's done, what's next, and can recover from crashes
- **Pause at checkpoints** - You review work at key milestones before continuing

### Key Features (inherited from Vibe Kanban)

**🗂️ Project Management**
- Add git repositories as projects
- Automatic git integration and repository validation
- Project search functionality across all files

**📋 Task Management**
- Create and manage tasks with kanban-style boards
- Task status tracking (Todo, In Progress, Done)
- Rich task descriptions and notes

**🤖 AI Agent Integration**
- **Claude Code**: Advanced AI coding assistant
- **Amp**: Powerful development agent
- Create tasks and immediately start agent execution

**⚡ Development Workflow**
- Create isolated git worktrees for each task attempt
- View diffs of changes made by agents
- Merge successful changes back to main branch

### Ralph-Specific Features

**🔄 Autonomous Multi-Iteration**
- Create Ralph tasks with a PRD (Product Requirements Document)
- AI breaks the PRD into implementable user stories
- Each story is executed in a fresh AI session
- Automatic progression through stories with checkpoint pauses

**📄 PRD-Driven Development**
- Store PRDs in `.ralph/prd.json`
- Track story completion status
- Support for `inProgress` flags for crash recovery
- Checkpoint stories that require human review

## Two-Phase Workflow

### Phase 1: Interactive (Design)
1. Create a **Ralph task** in the UI (toggle "Ralph" on)
2. Chat with the AI to design your feature
3. AI creates `prd.json` when the PRD is ready

### Phase 2: Autonomous (Execution)
1. Set `"started": true` in `prd.json`
2. Click **Continue** to start execution
3. AI implements one story, commits, updates `prd.json`
4. Auto-continues to next story (unless it's a checkpoint)

## Requirements

- Node.js (for npx execution)
- Git (for repository operations)
- Your preferred code editor (optional)

## Supported Platforms

- Linux x64 / ARM64
- Windows x64 / ARM64
- macOS x64 (Intel) / ARM64 (Apple Silicon)

---

**Ready to try autonomous AI coding?**

```bash
npx ralph-kanban
```

*Fork of Vibe Kanban with Ralph autonomous agent capabilities.*
