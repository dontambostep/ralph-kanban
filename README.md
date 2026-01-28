```
██████╗  █████╗ ██╗     ██████╗ ██╗  ██╗
██╔══██╗██╔══██╗██║     ██╔══██╗██║  ██║
██████╔╝███████║██║     ██████╔╝███████║
██╔══██╗██╔══██║██║     ██╔═══╝ ██╔══██║
██║  ██║██║  ██║███████╗██║     ██║  ██║
╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚═╝     ╚═╝  ╚═╝
██╗  ██╗ █████╗ ███╗   ██╗██████╗  █████╗ ███╗   ██╗
██║ ██╔╝██╔══██╗████╗  ██║██╔══██╗██╔══██╗████╗  ██║
█████╔╝ ███████║██╔██╗ ██║██████╔╝███████║██╔██╗ ██║
██╔═██╗ ██╔══██║██║╚██╗██║██╔══██╗██╔══██║██║╚██╗██║
██║  ██╗██║  ██║██║ ╚████║██████╔╝██║  ██║██║ ╚████║
╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═══╝
```

**Autonomous AI agent orchestration** • Fork of [Vibe Kanban](https://github.com/BloopAI/vibe-kanban)

---

![](frontend/public/vibe-kanban-screenshot-overview.png)

## Overview

AI coding agents are increasingly writing the world's code and human engineers now spend the majority of their time planning, reviewing, and orchestrating tasks. Ralph-Kanban streamlines this process, enabling you to:

- Easily switch between different coding agents
- Orchestrate the execution of multiple coding agents in parallel or in sequence
- Quickly review work and start dev servers
- Track the status of tasks that your coding agents are working on
- Centralise configuration of coding agent MCP configs
- **Run autonomous multi-iteration tasks with Ralph**

## What is Ralph?

Ralph is an **autonomous coding agent system** that implements features incrementally from a PRD (Product Requirements Document). Instead of trying to build everything at once, Ralph:

- **Breaks work into small stories** - Each story is small enough to complete in one AI session
- **Executes one story per iteration** - Fresh context each time, no context overflow
- **Tracks progress in `prd.json`** - Knows what's done, what's next, and can recover from crashes
- **Pauses at checkpoints** - You review work at key milestones before continuing

Ralph lives in the `.ralph/` folder of your repository:
- `.ralph/prompt.md` - Agent instructions (you create this once)
- `.ralph/prd.json` - The PRD with stories and progress (AI creates this)
- `.ralph/progress.txt` - Log of completed work and learnings

## Two-Phase Workflow

### Phase 1: Interactive (Design)

1. Create a **Ralph task** in the UI (toggle "Ralph" on)
2. Chat with the AI to design your feature
3. Tag files, discuss architecture, iterate on requirements
4. AI creates `prd.json` when the PRD is ready

During this phase, the AI receives your original task description as the prompt.

### Phase 2: Autonomous (Execution)

1. Set `"started": true` in `prd.json`
2. Click **Continue** to start execution
3. AI implements one story, commits, updates `prd.json`
4. Auto-continues to next story (unless it's a checkpoint)
5. At checkpoints, review work and click **Continue** when ready

During this phase, the AI receives the iteration prompt (customizable in `prd.json`).

## prd.json Schema

The `prd.json` file controls Ralph's behavior. Key fields:

### Top-Level Fields

| Field | Type | Description |
|-------|------|-------------|
| `started` | boolean | `false` = interactive phase, `true` = autonomous phase |
| `iterationPrompt` | string | Custom prompt for autonomous iterations. Default: "Read .ralph/prompt.md and continue implementing the PRD." |
| `branchName` | string | Git branch for this feature |
| `userStories` | array | List of stories to implement |

### Story Fields

| Field | Type | Description |
|-------|------|-------------|
| `id` | string | Story identifier (e.g., "US-001") |
| `title` | string | Short description |
| `passes` | boolean | `true` when story is complete |
| `inProgress` | boolean | `true` while agent is working (for crash recovery) |
| `checkpoint` | boolean | `true` to pause for review after this story |

### Example

```json
{
  "started": true,
  "iterationPrompt": "Read .ralph/prompt.md and continue implementing the PRD.",
  "branchName": "ralph/my-feature",
  "userStories": [
    {
      "id": "US-001",
      "title": "Add database migration",
      "passes": true,
      "inProgress": false,
      "checkpoint": true
    },
    {
      "id": "US-002",
      "title": "Add API endpoint",
      "passes": false,
      "inProgress": false,
      "checkpoint": false
    }
  ]
}
```

For complete agent instructions, see [`.ralph/prompt.md`](.ralph/prompt.md).

## MCP Server

Ralph-Kanban extends Vibe Kanban's MCP server with workspace lifecycle tools that allow AI agents to monitor and manage their workspace sessions programmatically.

### Workspace Lifecycle Tools (New in Ralph-Kanban)

| Tool | Description |
|------|-------------|
| `get_workspace_status` | Get execution status (`running`, `completed`, `failed`, `killed`) and diff stats (files changed, lines added/removed) |
| `get_workspace_transcript` | Get the prompt sent to the agent and its final summary/output |
| `get_workspace_diff` | Get unified diffs for all changed files with additions/deletions per file |
| `close_workspace` | Close a workspace with `merge` (merge changes to target branch) or `discard` (discard all changes) strategy |
| `get_context` | Get project/task/workspace metadata for the active session |

These tools enable autonomous agents to:
- Check if their execution completed successfully
- Review what changes were made
- Programmatically merge or discard their work
- Access session context without hardcoding IDs

### Inherited Vibe Kanban Tools

Ralph-Kanban also includes all standard Vibe Kanban MCP tools for task management:

`list_projects`, `list_tasks`, `create_task`, `get_task`, `update_task`, `delete_task`, `start_workspace_session`, `list_repos`, `get_repo`, `update_setup_script`, `update_cleanup_script`, `update_dev_server_script`

The MCP server automatically provides workspace context when running inside a task session.

## Installation

**One-line install (macOS/Linux):**

```bash
curl -sSL https://raw.githubusercontent.com/dontambostep/ralph-kanban/main/install.sh | bash
```

Then run:

```bash
ralph-kanban
```

### Supported Platforms

| Platform | Architecture | Status |
|----------|--------------|--------|
| Linux | x64 | ✅ |
| macOS | ARM64 (Apple Silicon) | ✅ |
| Windows | x64 | ✅ |

### MCP Server Installation

To also install the MCP server (for AI agent integration):

```bash
INSTALL_MCP=1 bash -c "$(curl -sSL https://raw.githubusercontent.com/dontambostep/ralph-kanban/main/install.sh)"
```

Then add to your Claude Code MCP config (`~/.claude/claude_desktop_config.json`):

```json
{
  "mcpServers": {
    "ralph-kanban": {
      "command": "/Users/YOUR_USERNAME/.ralph-kanban/bin/ralph-kanban-mcp"
    }
  }
}
```

Replace `YOUR_USERNAME` with your actual username, or use the full path shown after installation.

> **Note:** This is a fork of vibe-kanban with Ralph autonomous agent capabilities. If you want the original without Ralph, use `npx vibe-kanban` instead.

## Development

### Prerequisites

- [Rust](https://rustup.rs/) (latest stable)
- [Node.js](https://nodejs.org/) (>=18)
- [pnpm](https://pnpm.io/) (>=8)

Additional development tools:
```bash
cargo install cargo-watch
cargo install sqlx-cli
```

Install dependencies:
```bash
pnpm i
```

### Running the dev server

```bash
pnpm run dev
```

This will start the backend. A blank DB will be copied from the `dev_assets_seed` folder.

### Building the frontend

To build just the frontend:

```bash
cd frontend
pnpm build
```

### Build from source (macOS)

1. Run `./local-build.sh`
2. Test with `cd npx-cli && node bin/cli.js`


### Environment Variables

The following environment variables can be configured at build time or runtime:

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `POSTHOG_API_KEY` | Build-time | Empty | PostHog analytics API key (disables analytics if empty) |
| `POSTHOG_API_ENDPOINT` | Build-time | Empty | PostHog analytics endpoint (disables analytics if empty) |
| `PORT` | Runtime | Auto-assign | **Production**: Server port. **Dev**: Frontend port (backend uses PORT+1) |
| `BACKEND_PORT` | Runtime | `0` (auto-assign) | Backend server port (dev mode only, overrides PORT+1) |
| `FRONTEND_PORT` | Runtime | `3000` | Frontend dev server port (dev mode only, overrides PORT) |
| `HOST` | Runtime | `127.0.0.1` | Backend server host |
| `MCP_HOST` | Runtime | Value of `HOST` | MCP server connection host (use `127.0.0.1` when `HOST=0.0.0.0` on Windows) |
| `MCP_PORT` | Runtime | Value of `BACKEND_PORT` | MCP server connection port |
| `DISABLE_WORKTREE_CLEANUP` | Runtime | Not set | Disable all git worktree cleanup including orphan and expired workspace cleanup (for debugging) |
| `VK_ALLOWED_ORIGINS` | Runtime | Not set | Comma-separated list of origins that are allowed to make backend API requests (e.g., `https://my-vibekanban-frontend.com`) |

**Build-time variables** must be set when running `pnpm run build`. **Runtime variables** are read when the application starts.

#### Self-Hosting with a Reverse Proxy or Custom Domain

When running Ralph-Kanban behind a reverse proxy (e.g., nginx, Caddy, Traefik) or on a custom domain, you must set the `VK_ALLOWED_ORIGINS` environment variable. Without this, the browser's Origin header won't match the backend's expected host, and API requests will be rejected with a 403 Forbidden error.

Set it to the full origin URL(s) where your frontend is accessible:

```bash
# Single origin
VK_ALLOWED_ORIGINS=https://vk.example.com

# Multiple origins (comma-separated)
VK_ALLOWED_ORIGINS=https://vk.example.com,https://vk-staging.example.com
```

### Remote Deployment

When running Ralph-Kanban on a remote server (e.g., via systemctl, Docker, or cloud hosting), you can configure your editor to open projects via SSH:

1. **Access via tunnel**: Use Cloudflare Tunnel, ngrok, or similar to expose the web UI
2. **Configure remote SSH** in Settings → Editor Integration:
   - Set **Remote SSH Host** to your server hostname or IP
   - Set **Remote SSH User** to your SSH username (optional)
3. **Prerequisites**:
   - SSH access from your local machine to the remote server
   - SSH keys configured (passwordless authentication)
   - VSCode Remote-SSH extension

When configured, the "Open in VSCode" buttons will generate URLs like `vscode://vscode-remote/ssh-remote+user@host/path` that open your local editor and connect to the remote server.

## Upstream

This is a fork of [Vibe Kanban](https://github.com/BloopAI/vibe-kanban) with Ralph autonomous agent capabilities added. Ralph is an experimental add-on for multi-iteration autonomous task execution.

To sync with upstream:
```bash
git remote add upstream https://github.com/BloopAI/vibe-kanban.git
git fetch upstream
git merge upstream/main
```
