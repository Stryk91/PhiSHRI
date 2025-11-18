# VS Code AI Coder: Cross‑Automation Guide  
Maximizing collaboration between **VS Code (AI coder)**, **Claude Desktop (strategist)**, and **Linux VM containers**

> Model: VS Code is your **primary coder**. Claude Desktop is **non‑coding**: planner, reviewer, requirements clarifier, product/UX brain.

---

## 1. Core Setup Overview

Goal: Treat VS Code (AI coder), Claude Desktop (strategist), and Linux VMs as a **single integrated system**.

High‑level pattern:

- **VS Code (AI coder)**
  - Writes/refactors code, scripts, infra definitions
  - Runs tests/builds via integrated terminal
  - Connects to Linux VMs / dev containers
- **Claude Desktop (non‑coder)**
  - Clarifies requirements, user stories, constraints
  - Designs workflows, UX flows, checklists
  - Reviews architecture at a textual/diagram level
- **Linux VM / Containers**
  - Actual execution environment for code, tests, automation

Glue:
- VS Code **Remote – SSH / Dev Containers**
- Shared repo & task scripts
- Claude generating *plans/acceptance criteria*, VS Code AI implementing them

---

## 2. Essential VS Code Extensions (for AI Coding + Remote)

Install these in VS Code:

1. **Remote Development** (Microsoft)
   - `ms-vscode-remote.vscode-remote-extensionpack`
   - Includes:
     - Remote – SSH
     - Remote – Tunnels
     - Dev Containers
   - Use: open code directly inside Linux VMs/containers.

2. **Dev Containers**
   - `ms-vscode-remote.remote-containers`
   - Use: reproducible dev envs where the AI coder’s suggestions will run.

3. **Tasks / Scripts Helpers**
   - **Task Explorer**: `spmeesseman.vscode-taskexplorer`
   - **Code Runner** (optional): `formulahendry.code-runner`
   - Use: common actions (“run tests”, “build image”) VS Code’s AI can call.

4. **Git / Review Tools**
   - **GitLens**: `eamodio.gitlens`
   - **GitHub Pull Requests**: `GitHub.vscode-pull-request-github` if using GitHub.
   - Use: VS Code AI proposes commits/branches; you manage via UI.

5. **Quality of Life**
   - **Error Lens**: `usernamehw.errorlens`
   - **Path Intellisense**: `christian-kohler.path-intellisense`
   - **REST Client** (if hitting APIs): `humao.rest-client`

---

## 3. Linux VM / Container Setup

### 3.1 Minimal Linux VM requirements

On each automation VM:

```bash
sudo apt-get update
sudo apt-get install -y git curl build-essential unzip
sudo apt-get install -y python3 python3-pip   # common target for scripts

# Optional: Docker for containerized workflows
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker $USER

SSH:

bash

sudo apt-get install -y openssh-server
sudo systemctl enable ssh
sudo systemctl start ssh

3.2 Attach VS Code to VM

On your local machine:

sshconfig

# ~/.ssh/config
Host my-linux-vm
    HostName 203.0.113.10
    User dev
    IdentityFile ~/.ssh/id_rsa

VS Code:

    F1 → “Remote-SSH: Connect to Host…” → my-linux-vm.

Now:

    VS Code AI coder edits files directly on the VM.
    Integrated terminals run on the VM.

4. Dev Containers for Stable AI Targets

Use dev containers so VS Code AI’s suggestions have a consistent environment.

Example .devcontainer/devcontainer.json:

jsonc

{
  "name": "ai-automation-env",
  "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
  "postCreateCommand": "apt-get update && apt-get install -y git curl python3 python3-pip",
  "settings": {
    "terminal.integrated.defaultProfile.linux": "bash"
  },
  "remoteUser": "vscode"
}

VS Code:

    F1 → “Dev Containers: Reopen in Container”.

Now you can tell the VS Code AI:

    “Assume we are in a dev container with python3, git, docker client installed.”

5. Role Split: VS Code AI Coder vs Claude Desktop

Claude Desktop (non‑coder):

Use for:

    Requirements clarification:
        “Given this user story, what are the edge cases?”
        “What’s the minimal viable workflow for this feature?”
    Architectural/UX diagrams (textual):
        “Describe components and interactions for a multi‑service system.”
    Acceptance criteria:
        “Turn this feature request into precise acceptance tests.”

VS Code AI Coder:

Use for:

    Implementing the plan:
        Code, tests, scripts, Dockerfiles, CI configs
    Refactoring, performance tweaks, bug fixes
    Generating commands / automation scripts for Linux VMs

Pipeline:

    Talk with Claude: extract plan + acceptance criteria into NOTES.md.
    In VS Code, feed this into the AI coder:
        “Implement these acceptance criteria in <file>.”
    Run and debug directly in VM/container via VS Code.

6. VS Code Settings Optimized for AI Coding

Recommended settings.json (user or workspace):

jsonc

{
  "files.trimTrailingWhitespace": true,
  "files.insertFinalNewline": true,
  "editor.formatOnSave": true,
  "editor.codeActionsOnSave": {
    "source.organizeImports": true
  },
  "terminal.integrated.scrollback": 10000,
  "git.enableSmartCommit": true,
  "git.confirmSync": false
}

Shared conventions (for both AI and human):

    Repo root: /workspace in dev container, or /home/dev/projects/<repo> on VM.
    Scripts: ./scripts/
    Logs: ./logs/

Tell VS Code AI explicitly:

    “The repo root is /workspace, scripts go in ./scripts, logs in ./logs.”

7. Task + Script Patterns for Automation

Create stable entrypoints that the VS Code AI can rely on, and that Claude can reason about at the planning level.
7.1 Scripts

bash

# scripts/test.sh
#!/usr/bin/env bash
set -euo pipefail
pytest -q

bash

# scripts/build.sh
#!/usr/bin/env bash
set -euo pipefail
docker build -t myapp:dev .

bash

# scripts/deploy-dev.sh
#!/usr/bin/env bash
set -euo pipefail
kubectl apply -f k8s/dev/

7.2 VS Code tasks

.vscode/tasks.json:

jsonc

{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "test",
      "type": "shell",
      "command": "./scripts/test.sh",
      "problemMatcher": []
    },
    {
      "label": "build-image",
      "type": "shell",
      "command": "./scripts/build.sh",
      "problemMatcher": []
    },
    {
      "label": "deploy-dev",
      "type": "shell",
      "command": "./scripts/deploy-dev.sh",
      "problemMatcher": []
    }
  ]
}

Usage pattern:

    Claude Desktop: designs the workflow (“run tests → build → deploy dev”).
    VS Code AI: implements/maintains the scripts + tasks.
    You: run tasks via Terminal → Run Task… or keybindings.

8. Concrete Cross‑Automation Workflows
Workflow A: Feature from Plan → Code → VM

    Claude Desktop:
        Turn business request into:
            User story
            Acceptance criteria list
            Constraints, non‑functional requirements
    Paste that into NOTES.md in repo.
    VS Code AI:
        Prompt: “Using NOTES.md, implement feature X in <files>. Update or add tests to satisfy these criteria.”
    Run tests/build inside VM/container using tasks.
    If behavior mismatch:
        Copy logs/test outputs → Claude Desktop to refine requirements, not code.

Workflow B: VM Automation Scripts

    Claude Desktop:
        Outline process: e.g., “Daily log rotation & compression for services A/B/C.”
    VS Code AI:
        Implement:
            scripts/rotate_logs.sh
            systemd timer/service unit files
    VS Code AI (or you) applies on VM via SSH/Dev Container.
    Claude:
        Validate process diagram / operational runbook; doesn’t write scripts.

Workflow C: Multi‑Container Dev Environment

    Claude:
        Describe dev topology (API + DB + worker) and desired workflows.
    VS Code AI:
        Produce Docker Compose / devcontainer setup.
    VS Code:
        Reopen folder in container; AI coder adjusts code and compose files directly.
    Linux VM:
        Runs the stack; you hit services from browser or REST client.

9. Clipboard & Info Flow

    From VS Code to Claude:
        Copy:
            NOTES.md (requirements)
            High‑level directory structure (tree -L 2)
            Logs / error messages (sanitized)
        Ask: “Update the requirements/acceptance criteria based on this behavior.”

    From Claude to VS Code:
        Plans only:
            Bullet checklists
            Pseudo‑flows
            Non‑code suggestions (naming, UX, constraints)
        VS Code AI turns these into actual code/scripts.

10. Quick Checklist

    VS Code Remote – SSH connected to Linux VM(s).
    Optional Dev Containers configured for repo.
    Core extensions installed (Remote pack, GitLens, tasks helper).
    ./scripts + .vscode/tasks.json exist and are maintained by VS Code AI.
    Claude Desktop used for:
        Requirements
        Plans
        Acceptance criteria & runbooks
    VS Code AI used for:
        Code, scripts, infra, CI
        Applying changes on VM/containers
    You enforce:
        Clear boundaries: Claude = planner, VS Code = coder.
        Review of destructive scripts before running on VMs.

This setup turns VS Code into your coding and automation engine, Claude into your high‑level strategist, and the Linux VMs/containers into your execution layer, all working coherently.