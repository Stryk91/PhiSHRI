# Development Workflows: Comprehensive Guide 2024-2025

> **Research Date:** November 2025
> **Last Updated:** This guide compiles the latest development workflow patterns, tools, and best practices from official documentation, industry leaders, and real-world implementations.

---

## Table of Contents

1. [IDE Integration Patterns](#1-ide-integration-patterns)
   - [VSCode Extension Development](#11-vscode-extension-development)
   - [JetBrains Plugin Development](#12-jetbrains-plugin-development)
   - [AI-Assisted Coding Tools](#13-ai-assisted-coding-tools)

2. [Git Workflow Optimization](#2-git-workflow-optimization)
   - [Branching Strategies](#21-branching-strategies)
   - [Commit Message Conventions](#22-commit-message-conventions)
   - [Monorepo Management](#23-monorepo-management)

3. [CI/CD Pipeline Templates](#3-cicd-pipeline-templates)
   - [GitHub Actions](#31-github-actions)
   - [GitLab CI](#32-gitlab-ci)
   - [Jenkins](#33-jenkins)
   - [CircleCI](#34-circleci)

4. [Code Generation Automation](#4-code-generation-automation)
   - [Scaffolding Tools](#41-scaffolding-tools)
   - [AI Code Generation](#42-ai-code-generation)
   - [Template Engines](#43-template-engines)

---

# 1. IDE Integration Patterns

## 1.1 VSCode Extension Development

### Quick Start

**Official Documentation:** https://code.visualstudio.com/api

### Installation & Setup

```bash
# Install prerequisites
npm install -g yo generator-code

# Generate extension scaffold
yo code

# Choose extension type:
# - New Extension (TypeScript)
# - New Extension (JavaScript)
# - New Color Theme
# - New Language Support
# - New Code Snippets
```

### Package.json Example

```json
{
  "name": "my-extension",
  "displayName": "My Extension",
  "description": "Extension description",
  "version": "0.0.1",
  "engines": {
    "vscode": "^1.74.0"
  },
  "categories": [
    "Other"
  ],
  "activationEvents": [],
  "main": "./dist/extension.js",
  "contributes": {
    "commands": [
      {
        "command": "extension.helloWorld",
        "title": "Hello World"
      }
    ]
  },
  "scripts": {
    "vscode:prepublish": "npm run package",
    "compile": "webpack",
    "watch": "webpack --watch",
    "package": "webpack --mode production --devtool hidden-source-map"
  }
}
```

### Activation Events (Pre-VSCode 1.74)

```json
{
  "activationEvents": [
    "onLanguage:python",
    "onLanguage:javascript",
    "onCommand:extension.sayHello",
    "workspaceContains:.editorconfig",
    "onStartupFinished"
  ]
}
```

**Important:** As of VSCode 1.74+, activation events are automatically populated for:
- `onCommand`
- `onAuthenticationRequest`
- `onLanguage`
- `onCustomEditor`
- `onView`

### Extension Entry Point (extension.ts)

```typescript
import * as vscode from 'vscode';

export function activate(context: vscode.ExtensionContext) {
    console.log('Extension is now active!');

    let disposable = vscode.commands.registerCommand('extension.helloWorld', () => {
        vscode.window.showInformationMessage('Hello World from my extension!');
    });

    context.subscriptions.push(disposable);
}

export function deactivate() {}
```

### Best Practices

1. **Use TypeScript** - Provides better tooling and type safety
2. **Follow UX Guidelines** - Reference official guidelines at https://code.visualstudio.com/api/ux-guidelines/overview
3. **Implement Proper Testing** - Use VS Code's testing framework
4. **Optimize Activation** - Use `onStartupFinished` instead of `*` for startup tasks
5. **Bundle with Webpack** - Reduce extension size and improve load time
6. **Stay Current** - VS Code updates monthly; keep dependencies updated

### Key Resources

- **Official Extension API:** https://code.visualstudio.com/api
- **Extension Samples:** https://github.com/microsoft/vscode-extension-samples
- **UX Guidelines:** https://code.visualstudio.com/api/ux-guidelines/overview
- **Publishing Guide:** https://code.visualstudio.com/api/working-with-extensions/publishing-extension

---

## 1.2 JetBrains Plugin Development

### Official Resources

**Platform SDK:** https://plugins.jetbrains.com/docs/intellij/developing-plugins.html

### Key Updates 2024

#### Kotlin K2 Migration (Critical)
Starting from IntelliJ 2024.2.1, plugins must migrate to Kotlin K2 mode or they may not work properly when K2 is enabled.

**Migration Guide:** https://plugins.jetbrains.com/docs/intellij/k2-mode.html

#### Threading Model Updates

Use **Kotlin Coroutines** for asynchronous code:

```kotlin
import kotlinx.coroutines.launch
import com.intellij.openapi.components.service
import com.intellij.openapi.project.Project

class MyService(private val project: Project) {
    fun doAsyncWork() {
        service<MyService>().scope.launch {
            // Background work here
            // This runs on a background thread automatically
            val result = performHeavyComputation()

            // Update UI on EDT
            withContext(Dispatchers.EDT) {
                updateUI(result)
            }
        }
    }
}
```

### IntelliJ Platform Plugin Template

**Repository:** https://github.com/JetBrains/intellij-platform-plugin-template

```bash
# Use template to bootstrap plugin
# 1. Click "Use this template" on GitHub
# 2. Clone your repository
# 3. Customize gradle.properties
```

**gradle.properties Example:**

```properties
pluginGroup = com.example
pluginName = MyPlugin
pluginRepositoryUrl = https://github.com/username/my-plugin
pluginVersion = 0.0.1

# IntelliJ Platform Properties
platformType = IC
platformVersion = 2024.2

# Gradle Settings
kotlin.code.style = official
org.gradle.jvmargs = -Xmx2048m
```

### Plugin Structure (plugin.xml)

```xml
<idea-plugin>
    <id>com.example.myplugin</id>
    <name>My Plugin</name>
    <vendor email="support@example.com" url="https://www.example.com">Example Corp</vendor>

    <description><![CDATA[
    Plugin description goes here.
    ]]></description>

    <depends>com.intellij.modules.platform</depends>

    <extensions defaultExtensionNs="com.intellij">
        <!-- Add extensions here -->
        <toolWindow id="My Tool Window"
                    secondary="true"
                    icon="AllIcons.General.Modified"
                    anchor="right"
                    factoryClass="com.example.MyToolWindowFactory"/>
    </extensions>

    <actions>
        <action id="com.example.MyAction"
                class="com.example.MyAction"
                text="My Action"
                description="Description of my action">
            <add-to-group group-id="ToolsMenu" anchor="first"/>
        </action>
    </actions>
</idea-plugin>
```

### Language Server Protocol (LSP) Support

New in 2024: Full LSP support for language implementations.

```xml
<extensions defaultExtensionNs="com.intellij">
    <platform.lsp.serverSupportProvider
        implementation="com.example.MyLspServerSupportProvider"/>
</extensions>
```

### Build Configuration (Gradle 2.0+)

```kotlin
// build.gradle.kts
plugins {
    id("java")
    id("org.jetbrains.kotlin.jvm") version "1.9.20"
    id("org.jetbrains.intellij") version "2.0.0"
}

group = "com.example"
version = "1.0-SNAPSHOT"

repositories {
    mavenCentral()
}

intellij {
    version.set("2024.2")
    type.set("IC") // IntelliJ IDEA Community
    plugins.set(listOf(/* Plugin Dependencies */))
}

tasks {
    patchPluginXml {
        sinceBuild.set("242")
        untilBuild.set("242.*")
    }

    signPlugin {
        certificateChain.set(System.getenv("CERTIFICATE_CHAIN"))
        privateKey.set(System.getenv("PRIVATE_KEY"))
        password.set(System.getenv("PRIVATE_KEY_PASSWORD"))
    }

    publishPlugin {
        token.set(System.getenv("PUBLISH_TOKEN"))
    }
}
```

### Best Practices 2024

1. **Use IntelliJ Platform Plugin Template** - Simplifies setup and configuration
2. **Migrate to K2 Mode** - Essential for compatibility with 2024.2.1+
3. **Use Kotlin Coroutines** - Replace manual threading with structured concurrency
4. **Implement LSP When Possible** - For language support features
5. **Test Across Versions** - Use `runPluginVerifier` Gradle task
6. **Follow UX Guidelines** - Match IntelliJ Platform patterns

### Key Resources

- **Plugin DevConf 2024 Recordings:** https://lp.jetbrains.com/plugin-dev-conf-2024/
- **Quarterly Newsletter:** https://blog.jetbrains.com/platform/
- **API Changes 2024:** https://plugins.jetbrains.com/docs/intellij/api-notable-list-2024.html
- **Threading Guide:** https://plugins.jetbrains.com/docs/intellij/general-threading-rules.html

---

## 1.3 AI-Assisted Coding Tools

### Market Overview 2024-2025

By late 2024, nearly every major IDE includes built-in AI code suggestion, explanation, and conversational debugging capabilities.

### Top AI-Integrated IDEs

#### AI-First Editors (Built on VS Code)

1. **Cursor**
   - Built on VS Code foundation
   - Native AI integration throughout
   - Features: AI autocomplete, chat, multi-file editing
   - **URL:** https://cursor.com/

2. **Windsurf**
   - Built on VS Code
   - Features: Supercomplete, Cascade (AI flow)
   - Advanced context awareness
   - **URL:** https://windsurf.com/

3. **Trae**
   - ByteDance's AI editor
   - Built on VS Code
   - Polished UI with fresh AI features
   - Regional focus: Strong in Asia-Pacific

#### Traditional IDEs with AI

1. **GitHub Copilot** (Leader in adoption)
   - **Platforms:** VS Code, Visual Studio, JetBrains IDEs, Neovim
   - **URL:** https://github.com/features/copilot

2. **Visual Studio**
   - Native AI features
   - IntelliCode + Copilot integration
   - **URL:** https://visualstudio.microsoft.com/vs/

#### High-Performance Alternative

**Zed**
- Built from scratch in Rust
- Focus: Performance and speed
- AI features launched August 2024
- **URL:** https://zed.dev/

### GitHub Copilot Setup (VS Code)

#### Installation

```bash
# Via VS Code Extensions
# 1. Open Extensions (Ctrl+Shift+X / Cmd+Shift+X)
# 2. Search "GitHub Copilot"
# 3. Click Install
# 4. Sign in with GitHub account
```

#### Free Plan Available

As of 2024, GitHub offers **Copilot Free** with monthly limits on:
- Code completions
- Chat interactions

Perfect for individual developers and students.

#### Configuration (settings.json)

```json
{
  // Enable/disable inline suggestions
  "github.copilot.enable": {
    "*": true,
    "yaml": false,
    "plaintext": false
  },

  // Editor suggestions
  "github.copilot.editor.enableAutoCompletions": true,

  // Telemetry
  "telemetry.telemetryLevel": "off",

  // Advanced settings
  "github.copilot.advanced": {
    "debug.overrideEngine": "gpt-4",
    "debug.testOverrideProxyUrl": "",
    "debug.overrideProxyUrl": ""
  }
}
```

#### New Features (2025)

1. **Agent Sessions View** - Manage local and cloud agent sessions
2. **Plan Mode** - Creates step-by-step implementation plans
3. **Multi-file Context** - Better understanding of codebase structure

### AI Integration Best Practices

1. **Security**
   - Review AI-generated code before committing
   - Don't expose secrets in prompts
   - Use `.gitignore` for sensitive files

2. **Productivity**
   - Use AI for boilerplate code generation
   - Leverage AI for documentation
   - Let AI handle repetitive patterns

3. **Code Quality**
   - Always review suggestions
   - Test AI-generated code
   - Maintain coding standards

4. **Privacy**
   - Check telemetry settings
   - Review data usage policies
   - Use enterprise versions for sensitive projects

### Productivity Impact

According to 2024 studies:
- **30% increase** in developer productivity with AI code validation
- **72.3% of teams** exploring AI-driven testing workflows
- **76% of developers** rely on AI for code writing and explanation

### Key Resources

- **Cursor Documentation:** https://cursor.com/docs
- **GitHub Copilot Setup:** https://code.visualstudio.com/docs/copilot/setup
- **Copilot Settings Reference:** https://code.visualstudio.com/docs/copilot/reference/copilot-settings
- **AI IDE Comparison 2025:** https://www.builder.io/blog/best-ai-code-editors

---

# 2. Git Workflow Optimization

## 2.1 Branching Strategies

### Current State (2024-2025)

**Trunk-Based Development** has become the standard for high-performing engineering teams, while **GitFlow** is now considered legacy but still useful for specific scenarios.

### Strategy Comparison

| Feature | Trunk-Based Development | GitFlow |
|---------|------------------------|---------|
| **Main Branches** | 1 (main/trunk) | 2+ (main, develop) |
| **Feature Branches** | Short-lived (<1-2 days) | Long-lived (weeks) |
| **Release Cycle** | Continuous delivery | Scheduled releases |
| **Merge Frequency** | Multiple times per day | Weekly or less |
| **Team Size** | Any (requires discipline) | Large teams |
| **Best For** | CI/CD, rapid releases | Structured release cycles |
| **Complexity** | Low | High |

### Trunk-Based Development

#### Workflow

```
main (trunk)
  ├── feature/short-lived-1 (< 1 day)
  ├── feature/short-lived-2 (< 1 day)
  └── release/v1.2.3 (if needed)
```

#### Implementation

```bash
# 1. Create short-lived feature branch
git checkout -b feature/add-login main

# 2. Make small, focused changes
git add .
git commit -m "feat: add login form component"

# 3. Keep branch updated with main
git pull origin main --rebase

# 4. Merge to main (within 1-2 days)
git checkout main
git merge feature/add-login
git push origin main

# 5. Delete feature branch
git branch -d feature/add-login
```

#### Best Practices

1. **Feature Flags** - Deploy incomplete features behind flags
   ```javascript
   if (featureFlags.newLogin) {
     return <NewLoginForm />;
   }
   return <OldLoginForm />;
   ```

2. **Continuous Integration** - Automated tests on every commit

3. **Small Commits** - Merge multiple times per day

4. **Code Review** - Fast review cycles (< 4 hours)

5. **Release Branches** - Only for production hotfixes
   ```bash
   # Create release branch from main
   git checkout -b release/v1.2.3 main

   # Apply hotfix
   git commit -m "fix: critical security patch"

   # Merge back to main
   git checkout main
   git merge release/v1.2.3
   ```

#### When to Use

✅ **Use Trunk-Based Development when:**
- Moving towards continuous delivery
- Frequent application releases required
- Team has strong testing culture
- Fast feedback loops needed

### GitFlow

#### Workflow

```
main (production)
  └── develop (integration)
      ├── feature/feature-1
      ├── feature/feature-2
      └── release/v1.2.0
          └── hotfix/critical-bug
```

#### Branch Types

1. **main** - Production-ready code
2. **develop** - Integration branch
3. **feature/** - New features
4. **release/** - Release preparation
5. **hotfix/** - Production fixes

#### Implementation

```bash
# 1. Create feature branch from develop
git checkout -b feature/new-feature develop

# 2. Work on feature (can be weeks)
git add .
git commit -m "feat: add new feature"

# 3. Merge to develop
git checkout develop
git merge --no-ff feature/new-feature

# 4. Create release branch
git checkout -b release/1.2.0 develop

# 5. Merge release to main and develop
git checkout main
git merge --no-ff release/1.2.0
git tag -a v1.2.0

git checkout develop
git merge --no-ff release/1.2.0

# 6. Hotfix if needed
git checkout -b hotfix/critical-fix main
git checkout main
git merge --no-ff hotfix/critical-fix
git checkout develop
git merge --no-ff hotfix/critical-fix
```

#### When to Use

✅ **Use GitFlow when:**
- Structured release cycles (quarterly, monthly)
- Multiple versions in production simultaneously
- Large teams needing clear separation
- Infrequent deployments

⚠️ **Challenges:**
- Can be cumbersome for small teams
- Complex branching leads to slower feedback
- Difficult with CI/CD practices

### GitHub Flow (Alternative)

Simpler than GitFlow, different from Trunk-Based:

```
main
  ├── feature/feature-1
  ├── feature/feature-2
  └── feature/feature-3
```

**Rules:**
1. `main` is always deployable
2. Create descriptive feature branches
3. Open pull requests early
4. Merge after review and tests pass
5. Deploy immediately after merge

### Key Resources

- **Trunk-Based Development:** https://www.atlassian.com/continuous-delivery/continuous-integration/trunk-based-development
- **GitFlow Tutorial:** https://www.atlassian.com/git/tutorials/comparing-workflows/gitflow-workflow
- **Strategy Comparison:** https://graphite.com/guides/git-branching-strategies
- **Trunk-Based Guide:** https://www.getunleash.io/blog/how-to-implement-trunk-based-development-a-practical-guide

---

## 2.2 Commit Message Conventions

### Conventional Commits Specification

**Official Spec:** https://www.conventionalcommits.org/

### Format

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

### Commit Types

| Type | Description | Version Impact |
|------|-------------|----------------|
| `feat` | New feature | MINOR |
| `fix` | Bug fix | PATCH |
| `docs` | Documentation only | - |
| `style` | Code style (formatting, whitespace) | - |
| `refactor` | Code restructuring (no behavior change) | - |
| `perf` | Performance improvements | PATCH |
| `test` | Add/update tests | - |
| `build` | Build system, dependencies | - |
| `ci` | CI/CD configuration | - |
| `chore` | Other changes (`.gitignore`, etc) | - |
| `revert` | Revert previous commit | - |

### Breaking Changes

Add `!` before the colon to indicate breaking changes:

```
feat(api)!: remove deprecated endpoints

BREAKING CHANGE: The /v1/users endpoint has been removed.
Use /v2/users instead.
```

**Version Impact:** MAJOR

### Examples

#### Basic Examples

```bash
# Feature addition
feat: add email notifications for new messages

# Bug fix with scope
fix(shopping-cart): prevent ordering empty carts

# Performance improvement
perf: decrease memory footprint using HyperLogLog

# Documentation
docs: update API reference for v2 endpoints

# Build system
build(release): bump version to 1.0.0

# Breaking change
feat(api)!: remove status endpoint

BREAKING CHANGE: Status endpoint removed. Use health endpoint instead.
```

#### With Body and Footer

```
fix(auth): resolve token expiration issue

Previously, tokens were expiring too early due to incorrect
timezone calculation. This fix ensures tokens use UTC consistently.

Fixes #123
Reviewed-by: @username
```

### Writing Guidelines

1. **Use imperative mood** - "add" not "added" or "adds"
2. **Don't capitalize first letter** - "add feature" not "Add feature"
3. **No period at end** - "add feature" not "add feature."
4. **Keep description concise** - Under 72 characters
5. **Explain WHY in body** - Not what (visible in diff)

### Semantic Versioning Integration

Conventional Commits map to SemVer:

```
MAJOR version: feat!, fix!, etc. (breaking changes)
MINOR version: feat (new features)
PATCH version: fix, perf (bug fixes)
```

### Automation Tools

#### Commitizen - Interactive Commits

```bash
# Installation
npm install -g commitizen cz-conventional-changelog

# Initialize in project
commitizen init cz-conventional-changelog --save-dev --save-exact

# Usage
git add .
git cz  # Interactive commit prompt
```

#### Commitlint - Enforce Rules

```bash
# Installation
npm install --save-dev @commitlint/{config-conventional,cli}

# Configuration (.commitlintrc.json)
{
  "extends": ["@commitlint/config-conventional"],
  "rules": {
    "type-enum": [
      2,
      "always",
      [
        "feat", "fix", "docs", "style", "refactor",
        "perf", "test", "build", "ci", "chore", "revert"
      ]
    ],
    "subject-case": [2, "always", "lower-case"],
    "subject-full-stop": [2, "never", "."],
    "header-max-length": [2, "always", 72]
  }
}

# Husky integration (.husky/commit-msg)
#!/bin/sh
. "$(dirname "$0")/_/husky.sh"

npx --no -- commitlint --edit "$1"
```

#### semantic-release - Automated Versioning

```bash
# Installation
npm install --save-dev semantic-release

# Configuration (.releaserc.json)
{
  "branches": ["main"],
  "plugins": [
    "@semantic-release/commit-analyzer",
    "@semantic-release/release-notes-generator",
    "@semantic-release/changelog",
    "@semantic-release/npm",
    "@semantic-release/github",
    "@semantic-release/git"
  ]
}
```

### Template (Copy-Paste)

```bash
# Feature
feat(scope): add new feature
# Example: feat(auth): add OAuth2 support

# Bug Fix
fix(scope): fix specific issue
# Example: fix(ui): resolve button alignment

# Breaking Change
feat(scope)!: breaking change description

BREAKING CHANGE: detailed explanation
# Example:
# feat(api)!: change response format to JSON:API spec
#
# BREAKING CHANGE: All API responses now follow JSON:API
# specification. Update clients to parse new format.
```

### Key Resources

- **Conventional Commits Spec:** https://www.conventionalcommits.org/
- **Cheatsheet:** https://gist.github.com/qoomon/5dfcdf8eec66a051ecd85625518cfd13
- **Commitizen:** https://github.com/commitizen/cz-cli
- **Commitlint:** https://commitlint.js.org/
- **semantic-release:** https://semantic-release.gitbook.io/

---

## 2.3 Monorepo Management

### Tools Comparison 2024

| Tool | Language Focus | Strengths | Best For |
|------|---------------|-----------|----------|
| **Turborepo** | JS/TS | Simple, fast, great DX | Web apps, Node.js |
| **Nx** | Multi-language | Feature-rich, extensible | Large enterprises |
| **pnpm** | JS/TS | Workspace + speed | Node.js projects |
| **Bazel** | Multi-language | Google-scale performance | Massive codebases |
| **Lerna** | JS/TS | Legacy, limited features | Legacy projects |
| **Rush** | JS/TS | Microsoft-backed | Large organizations |
| **moon** | Multi-language | Modern, task-focused | New projects |

**Source:** State of JavaScript 2024 - https://2024.stateofjs.com/en-US/libraries/monorepo_tools/

### Turborepo (Recommended for JS/TS)

#### Installation

```bash
# New monorepo
npx create-turbo@latest

# Add to existing monorepo
npm install turbo --save-dev
```

#### Project Structure

```
my-monorepo/
├── apps/
│   ├── web/          # Next.js app
│   └── docs/         # Documentation site
├── packages/
│   ├── ui/           # Shared UI components
│   ├── config/       # Shared configs
│   └── tsconfig/     # Shared TypeScript configs
├── turbo.json
└── package.json
```

#### Configuration (turbo.json)

```json
{
  "$schema": "https://turborepo.com/schema.json",
  "pipeline": {
    "build": {
      "dependsOn": ["^build"],
      "outputs": ["dist/**", ".next/**", "!.next/cache/**"]
    },
    "test": {
      "dependsOn": ["build"],
      "outputs": ["coverage/**"],
      "inputs": ["src/**/*.tsx", "src/**/*.ts", "test/**/*.ts"]
    },
    "lint": {
      "outputs": []
    },
    "dev": {
      "cache": false,
      "persistent": true
    },
    "deploy": {
      "dependsOn": ["build", "test", "lint"],
      "outputs": []
    }
  }
}
```

#### Usage

```bash
# Run build across all packages
turbo run build

# Run build and test
turbo run build test

# Run only in specific package
turbo run build --filter=web

# Run with force (ignore cache)
turbo run build --force

# Run in parallel
turbo run lint test --parallel
```

#### Key Features

1. **Task Dependencies** - `^build` means "run build in dependencies first"
2. **Caching** - Never run the same task twice
3. **Remote Caching** - Share cache across team (Vercel Remote Cache)
4. **Parallel Execution** - Run tasks concurrently when possible

### Nx (Enterprise-Grade)

#### Installation

```bash
# New workspace
npx create-nx-workspace@latest

# Add to existing repo
npx nx@latest init
```

#### Configuration (nx.json)

```json
{
  "extends": "nx/presets/npm.json",
  "tasksRunnerOptions": {
    "default": {
      "runner": "nx/tasks-runners/default",
      "options": {
        "cacheableOperations": ["build", "test", "lint"]
      }
    }
  },
  "targetDefaults": {
    "build": {
      "dependsOn": ["^build"],
      "inputs": ["production", "^production"],
      "cache": true
    },
    "test": {
      "inputs": ["default", "^production"],
      "cache": true
    }
  },
  "namedInputs": {
    "default": ["{projectRoot}/**/*"],
    "production": [
      "default",
      "!{projectRoot}/**/*.spec.ts",
      "!{projectRoot}/tsconfig.spec.json"
    ]
  }
}
```

#### Project Configuration (project.json)

```json
{
  "name": "my-app",
  "sourceRoot": "apps/my-app/src",
  "projectType": "application",
  "targets": {
    "build": {
      "executor": "@nx/webpack:webpack",
      "outputs": ["{options.outputPath}"],
      "options": {
        "outputPath": "dist/apps/my-app",
        "main": "apps/my-app/src/main.ts",
        "tsConfig": "apps/my-app/tsconfig.app.json"
      }
    },
    "serve": {
      "executor": "@nx/webpack:dev-server",
      "options": {
        "buildTarget": "my-app:build",
        "port": 4200
      }
    },
    "test": {
      "executor": "@nx/jest:jest",
      "options": {
        "jestConfig": "apps/my-app/jest.config.ts"
      }
    }
  }
}
```

#### Usage

```bash
# Run command for specific project
nx build my-app

# Run for affected projects only
nx affected --target=build

# Visualize dependency graph
nx graph

# Run in parallel
nx run-many --target=build --all --parallel=3

# Cache statistics
nx reset
```

#### Key Features

1. **Affected Commands** - Only build what changed
2. **Computation Caching** - Smart task result caching
3. **Distributed Execution** - Run tasks across machines
4. **Plugins** - React, Angular, Node, Next.js, etc.
5. **Dependency Graph** - Visual project relationships

### pnpm Workspaces (Lightweight)

#### Installation

```bash
npm install -g pnpm
```

#### Configuration (pnpm-workspace.yaml)

```yaml
packages:
  - 'apps/*'
  - 'packages/*'
  - 'tools/*'
```

#### Root package.json

```json
{
  "name": "monorepo-root",
  "private": true,
  "scripts": {
    "build": "pnpm --filter='./packages/*' run build",
    "test": "pnpm --recursive run test",
    "dev": "pnpm --filter='./apps/*' --parallel run dev"
  },
  "devDependencies": {
    "turbo": "^1.10.0"
  }
}
```

#### Package-specific Commands

```bash
# Install dependency in specific package
pnpm --filter my-app add lodash

# Run script in specific package
pnpm --filter my-app run build

# Run script in all packages
pnpm --recursive run test

# Run in parallel
pnpm --parallel --filter='./apps/*' run dev
```

### Monorepo Best Practices

1. **Shared Configuration**
   ```
   packages/
   ├── eslint-config/     # Shared ESLint config
   ├── tsconfig/          # Shared TypeScript configs
   └── jest-preset/       # Shared Jest config
   ```

2. **Version Management**
   - Use fixed versioning for public packages
   - Use `workspace:*` for internal dependencies

3. **Code Sharing**
   ```json
   {
     "dependencies": {
       "@myorg/ui": "workspace:*",
       "@myorg/utils": "workspace:*"
     }
   }
   ```

4. **Task Orchestration**
   - Define clear build order
   - Use pipeline configurations
   - Enable caching for all tasks

5. **CI/CD Optimization**
   - Use `affected` commands in CI
   - Enable remote caching
   - Distribute tasks across runners

### Migration Strategies

#### From Polyrepo to Monorepo

```bash
# 1. Create monorepo structure
mkdir my-monorepo && cd my-monorepo
npx create-turbo@latest

# 2. Move existing repos
git subtree add --prefix apps/app1 https://github.com/org/app1.git main
git subtree add --prefix apps/app2 https://github.com/org/app2.git main

# 3. Extract shared code
# Move common code to packages/

# 4. Update dependencies to use workspace:*

# 5. Configure turbo.json or nx.json
```

### Key Resources

- **Monorepo.tools:** https://monorepo.tools/
- **Turborepo Docs:** https://turborepo.com/docs
- **Nx Documentation:** https://nx.dev/
- **pnpm Workspaces:** https://pnpm.io/workspaces
- **Comparison Guide:** https://graphite.com/guides/monorepo-tools-a-comprehensive-comparison

---

# 3. CI/CD Pipeline Templates

## 3.1 GitHub Actions

### Basic Workflow Structure

```yaml
name: CI

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Run build
        run: npm run build
```

### Node.js CI/CD Pipeline

```yaml
name: Node.js CI/CD

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest

    strategy:
      matrix:
        node-version: [18.x, 20.x]

    steps:
    - uses: actions/checkout@v4

    - name: Use Node.js ${{ matrix.node-version }}
      uses: actions/setup-node@v4
      with:
        node-version: ${{ matrix.node-version }}
        cache: 'npm'

    - name: Install dependencies
      run: npm ci

    - name: Run linter
      run: npm run lint

    - name: Run tests
      run: npm test

    - name: Upload coverage
      uses: codecov/codecov-action@v3
      with:
        file: ./coverage/coverage-final.json

  build:
    needs: test
    runs-on: ubuntu-latest
    if: github.event_name == 'push'

    steps:
    - uses: actions/checkout@v4

    - name: Setup Node.js
      uses: actions/setup-node@v4
      with:
        node-version: '20.x'
        cache: 'npm'

    - name: Install dependencies
      run: npm ci

    - name: Build
      run: npm run build

    - name: Upload artifacts
      uses: actions/upload-artifact@v4
      with:
        name: dist
        path: dist/

  deploy:
    needs: build
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'

    steps:
    - uses: actions/checkout@v4

    - name: Download artifacts
      uses: actions/download-artifact@v4
      with:
        name: dist
        path: dist/

    - name: Deploy to production
      run: |
        echo "Deploying to production..."
        # Add deployment commands
```

### Docker Build & Push

```yaml
name: Docker Build and Push

on:
  push:
    branches: [ main ]
    tags: [ 'v*' ]

env:
  REGISTRY: ghcr.io
  IMAGE_NAME: ${{ github.repository }}

jobs:
  build-and-push:
    runs-on: ubuntu-latest
    permissions:
      contents: read
      packages: write

    steps:
    - name: Checkout repository
      uses: actions/checkout@v4

    - name: Set up QEMU
      uses: docker/setup-qemu-action@v3

    - name: Set up Docker Buildx
      uses: docker/setup-buildx-action@v3

    - name: Log in to Container Registry
      uses: docker/login-action@v3
      with:
        registry: ${{ env.REGISTRY }}
        username: ${{ github.actor }}
        password: ${{ secrets.GITHUB_TOKEN }}

    - name: Extract metadata
      id: meta
      uses: docker/metadata-action@v5
      with:
        images: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}
        tags: |
          type=ref,event=branch
          type=ref,event=pr
          type=semver,pattern={{version}}
          type=semver,pattern={{major}}.{{minor}}

    - name: Build and push Docker image
      uses: docker/build-push-action@v5
      with:
        context: .
        platforms: linux/amd64,linux/arm64
        push: true
        tags: ${{ steps.meta.outputs.tags }}
        labels: ${{ steps.meta.outputs.labels }}
        cache-from: type=gha
        cache-to: type=gha,mode=max
```

### Monorepo with Turborepo

```yaml
name: Monorepo CI

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@v4
      with:
        fetch-depth: 2  # For turbo --filter

    - name: Setup Node.js
      uses: actions/setup-node@v4
      with:
        node-version: '20'
        cache: 'pnpm'

    - name: Install pnpm
      uses: pnpm/action-setup@v2
      with:
        version: 8

    - name: Install dependencies
      run: pnpm install --frozen-lockfile

    - name: Setup Turbo cache
      uses: actions/cache@v4
      with:
        path: .turbo
        key: ${{ runner.os }}-turbo-${{ github.sha }}
        restore-keys: |
          ${{ runner.os }}-turbo-

    - name: Build
      run: pnpm turbo run build

    - name: Test
      run: pnpm turbo run test

    - name: Lint
      run: pnpm turbo run lint
```

### Reusable Workflow

**Workflow definition (.github/workflows/reusable-test.yml):**

```yaml
name: Reusable Test Workflow

on:
  workflow_call:
    inputs:
      node-version:
        required: true
        type: string
      working-directory:
        required: false
        type: string
        default: '.'
    secrets:
      npm-token:
        required: false

jobs:
  test:
    runs-on: ubuntu-latest
    defaults:
      run:
        working-directory: ${{ inputs.working-directory }}

    steps:
    - uses: actions/checkout@v4

    - name: Setup Node.js
      uses: actions/setup-node@v4
      with:
        node-version: ${{ inputs.node-version }}

    - name: Install dependencies
      run: npm ci
      env:
        NODE_AUTH_TOKEN: ${{ secrets.npm-token }}

    - name: Run tests
      run: npm test
```

**Using reusable workflow:**

```yaml
name: CI

on: [push, pull_request]

jobs:
  test-node-18:
    uses: ./.github/workflows/reusable-test.yml
    with:
      node-version: '18'

  test-node-20:
    uses: ./.github/workflows/reusable-test.yml
    with:
      node-version: '20'
    secrets:
      npm-token: ${{ secrets.NPM_TOKEN }}
```

### Best Practices

#### 1. Security

```yaml
# Pin actions to commit SHA
- uses: actions/checkout@8e5e7e5ab8b370d6c329ec480221332ada57f0ab # v4.1.1

# Use GITHUB_TOKEN with minimal permissions
permissions:
  contents: read
  packages: write

# Use secrets for sensitive data
env:
  API_KEY: ${{ secrets.API_KEY }}
```

#### 2. Performance Optimization

```yaml
# Use caching
- name: Cache node modules
  uses: actions/cache@v4
  with:
    path: ~/.npm
    key: ${{ runner.os }}-node-${{ hashFiles('**/package-lock.json') }}
    restore-keys: |
      ${{ runner.os }}-node-

# Run jobs in parallel
jobs:
  lint:
    runs-on: ubuntu-latest
  test:
    runs-on: ubuntu-latest
  build:
    needs: [lint, test]
    runs-on: ubuntu-latest

# Set timeout to avoid hanging
jobs:
  build:
    runs-on: ubuntu-latest
    timeout-minutes: 30
```

#### 3. Matrix Strategy

```yaml
strategy:
  matrix:
    os: [ubuntu-latest, windows-latest, macos-latest]
    node: [18, 20]
    exclude:
      - os: macos-latest
        node: 18
  fail-fast: false
```

#### 4. Conditional Execution

```yaml
# Only on main branch
if: github.ref == 'refs/heads/main'

# Only on push (not PR)
if: github.event_name == 'push'

# Only on tags
if: startsWith(github.ref, 'refs/tags/')

# Only if previous job succeeded
needs: build
if: success()
```

### Popular Actions

| Action | Purpose | URL |
|--------|---------|-----|
| `actions/checkout` | Checkout repository | https://github.com/actions/checkout |
| `actions/setup-node` | Setup Node.js | https://github.com/actions/setup-node |
| `actions/cache` | Cache dependencies | https://github.com/actions/cache |
| `docker/build-push-action` | Build/push Docker | https://github.com/docker/build-push-action |
| `codecov/codecov-action` | Upload coverage | https://github.com/codecov/codecov-action |

### Key Resources

- **GitHub Actions Documentation:** https://docs.github.com/en/actions
- **Workflow Syntax:** https://docs.github.com/en/actions/reference/workflow-syntax-for-github-actions
- **Awesome Actions:** https://github.com/sdras/awesome-actions
- **Starter Workflows:** https://github.com/actions/starter-workflows
- **Best Practices Guide:** https://www.datree.io/resources/github-actions-best-practices

---

## 3.2 GitLab CI

### Basic Pipeline (.gitlab-ci.yml)

```yaml
stages:
  - build
  - test
  - deploy

variables:
  NODE_VERSION: "20"

# Default configuration for all jobs
default:
  image: node:${NODE_VERSION}
  before_script:
    - npm ci
  cache:
    key:
      files:
        - package-lock.json
    paths:
      - node_modules/

build:
  stage: build
  script:
    - npm run build
  artifacts:
    paths:
      - dist/
    expire_in: 1 hour

test:unit:
  stage: test
  script:
    - npm run test:unit
  coverage: '/All files[^|]*\|[^|]*\s+([\d\.]+)/'
  artifacts:
    reports:
      coverage_report:
        coverage_format: cobertura
        path: coverage/cobertura-coverage.xml

test:e2e:
  stage: test
  script:
    - npm run test:e2e
  artifacts:
    when: on_failure
    paths:
      - cypress/screenshots/
      - cypress/videos/

deploy:production:
  stage: deploy
  script:
    - npm run deploy
  environment:
    name: production
    url: https://example.com
  only:
    - main
```

### Multi-Stage Docker Build

```yaml
variables:
  DOCKER_DRIVER: overlay2
  DOCKER_TLS_CERTDIR: "/certs"
  IMAGE_TAG: $CI_REGISTRY_IMAGE:$CI_COMMIT_REF_SLUG

stages:
  - build
  - test
  - release

build:
  stage: build
  image: docker:24-dind
  services:
    - docker:24-dind
  before_script:
    - docker login -u $CI_REGISTRY_USER -p $CI_REGISTRY_PASSWORD $CI_REGISTRY
  script:
    - docker build --target test -t $IMAGE_TAG-test .
    - docker build --target production -t $IMAGE_TAG .
    - docker push $IMAGE_TAG-test
    - docker push $IMAGE_TAG

test:
  stage: test
  image: $IMAGE_TAG-test
  script:
    - npm test

release:
  stage: release
  image: docker:24
  services:
    - docker:24-dind
  before_script:
    - docker login -u $CI_REGISTRY_USER -p $CI_REGISTRY_PASSWORD $CI_REGISTRY
  script:
    - docker pull $IMAGE_TAG
    - docker tag $IMAGE_TAG $CI_REGISTRY_IMAGE:latest
    - docker push $CI_REGISTRY_IMAGE:latest
  only:
    - main
```

### Using Templates

```yaml
include:
  - template: Security/SAST.gitlab-ci.yml
  - template: Security/Dependency-Scanning.gitlab-ci.yml
  - template: Code-Quality.gitlab-ci.yml

stages:
  - build
  - test
  - security
  - deploy

# Your custom jobs
build:
  stage: build
  script:
    - npm run build
  artifacts:
    paths:
      - dist/

# SAST and Dependency Scanning automatically run in 'test' stage
# Code Quality runs in '.pre' stage
```

### Reusable Configuration with Anchors

```yaml
.node_template: &node_definition
  image: node:20
  before_script:
    - npm ci
  cache:
    key:
      files:
        - package-lock.json
    paths:
      - node_modules/

.deploy_template: &deploy_definition
  only:
    - main
  when: manual
  environment:
    name: $ENVIRONMENT_NAME
    url: $ENVIRONMENT_URL

build:
  <<: *node_definition
  stage: build
  script:
    - npm run build

test:
  <<: *node_definition
  stage: test
  script:
    - npm test

deploy:staging:
  <<: [*node_definition, *deploy_definition]
  stage: deploy
  variables:
    ENVIRONMENT_NAME: staging
    ENVIRONMENT_URL: https://staging.example.com
  script:
    - npm run deploy:staging

deploy:production:
  <<: [*node_definition, *deploy_definition]
  stage: deploy
  variables:
    ENVIRONMENT_NAME: production
    ENVIRONMENT_URL: https://example.com
  script:
    - npm run deploy:production
```

### Monorepo Pipeline (Selective Execution)

```yaml
workflow:
  rules:
    - if: $CI_PIPELINE_SOURCE == "merge_request_event"
    - if: $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH

variables:
  PACKAGES_CHANGED: ""

.detect_changes:
  script:
    - |
      if [ "$CI_COMMIT_BEFORE_SHA" = "0000000000000000000000000000000000000000" ]; then
        export PACKAGES_CHANGED="all"
      else
        export PACKAGES_CHANGED=$(git diff --name-only $CI_COMMIT_BEFORE_SHA $CI_COMMIT_SHA | grep -E '^packages/[^/]+' | cut -d/ -f2 | sort -u | tr '\n' ' ')
      fi

build:app1:
  extends: .detect_changes
  stage: build
  script:
    - |
      if echo "$PACKAGES_CHANGED" | grep -qE "(all|app1)"; then
        echo "Building app1..."
        cd packages/app1
        npm run build
      else
        echo "No changes in app1, skipping"
      fi
  artifacts:
    paths:
      - packages/app1/dist/

build:app2:
  extends: .detect_changes
  stage: build
  script:
    - |
      if echo "$PACKAGES_CHANGED" | grep -qE "(all|app2)"; then
        echo "Building app2..."
        cd packages/app2
        npm run build
      else
        echo "No changes in app2, skipping"
      fi
  artifacts:
    paths:
      - packages/app2/dist/
```

### Parallel Matrix Jobs

```yaml
.test_template:
  stage: test
  script:
    - npm run test
  parallel:
    matrix:
      - NODE_VERSION: ["18", "20"]
        OS: ["ubuntu", "alpine"]

test:
  extends: .test_template
  image: node:${NODE_VERSION}-${OS}
```

### Best Practices

1. **Use `include` for reusability**
2. **Cache dependencies properly**
3. **Set appropriate artifact expiration**
4. **Use `only`/`except` or `rules` for conditional execution**
5. **Leverage templates from GitLab**
6. **Use anchors to reduce duplication**

### Key Resources

- **GitLab CI/CD Documentation:** https://docs.gitlab.com/ci/
- **CI/CD Examples:** https://docs.gitlab.com/ci/examples/
- **YAML Syntax Reference:** https://docs.gitlab.com/ci/yaml/
- **Templates Repository:** https://gitlab.com/gitlab-org/gitlab/-/tree/master/lib/gitlab/ci/templates

---

## 3.3 Jenkins

### Declarative Pipeline (Jenkinsfile)

```groovy
pipeline {
    agent any

    environment {
        NODE_VERSION = '20'
        REGISTRY = 'docker.io'
        IMAGE_NAME = 'myorg/myapp'
    }

    options {
        timeout(time: 1, unit: 'HOURS')
        timestamps()
        buildDiscarder(logRotator(numToKeepStr: '10'))
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build') {
            agent {
                docker {
                    image "node:${NODE_VERSION}"
                    args '-v $HOME/.npm:/root/.npm'
                }
            }
            steps {
                sh 'npm ci'
                sh 'npm run build'
            }
        }

        stage('Test') {
            parallel {
                stage('Unit Tests') {
                    agent {
                        docker {
                            image "node:${NODE_VERSION}"
                        }
                    }
                    steps {
                        sh 'npm run test:unit'
                    }
                    post {
                        always {
                            junit 'test-results/**/*.xml'
                        }
                    }
                }

                stage('Integration Tests') {
                    agent {
                        docker {
                            image "node:${NODE_VERSION}"
                        }
                    }
                    steps {
                        sh 'npm run test:integration'
                    }
                }

                stage('Lint') {
                    agent {
                        docker {
                            image "node:${NODE_VERSION}"
                        }
                    }
                    steps {
                        sh 'npm run lint'
                    }
                }
            }
        }

        stage('Docker Build') {
            when {
                branch 'main'
            }
            steps {
                script {
                    docker.build("${IMAGE_NAME}:${env.BUILD_NUMBER}")
                }
            }
        }

        stage('Deploy') {
            when {
                branch 'main'
            }
            steps {
                input message: 'Deploy to production?', ok: 'Deploy'
                script {
                    docker.withRegistry("https://${REGISTRY}", 'docker-credentials') {
                        docker.image("${IMAGE_NAME}:${env.BUILD_NUMBER}").push()
                        docker.image("${IMAGE_NAME}:${env.BUILD_NUMBER}").push('latest')
                    }
                }
            }
        }
    }

    post {
        always {
            cleanWs()
        }
        success {
            echo 'Pipeline succeeded!'
            // Send notifications
        }
        failure {
            echo 'Pipeline failed!'
            // Send alerts
        }
    }
}
```

### Multi-Branch Pipeline

```groovy
pipeline {
    agent any

    stages {
        stage('Build') {
            steps {
                echo "Building branch: ${env.BRANCH_NAME}"
                sh 'npm ci && npm run build'
            }
        }

        stage('Test') {
            steps {
                sh 'npm test'
            }
        }

        stage('Deploy to Dev') {
            when {
                branch 'develop'
            }
            steps {
                echo 'Deploying to development environment'
                sh './deploy-dev.sh'
            }
        }

        stage('Deploy to Staging') {
            when {
                branch 'release/*'
            }
            steps {
                echo 'Deploying to staging environment'
                sh './deploy-staging.sh'
            }
        }

        stage('Deploy to Production') {
            when {
                branch 'main'
            }
            steps {
                input message: 'Deploy to production?'
                echo 'Deploying to production environment'
                sh './deploy-prod.sh'
            }
        }
    }
}
```

### Shared Library Usage

**Shared Library (vars/buildNodeApp.groovy):**

```groovy
// vars/buildNodeApp.groovy
def call(Map config = [:]) {
    pipeline {
        agent any

        environment {
            NODE_VERSION = config.nodeVersion ?: '20'
        }

        stages {
            stage('Setup') {
                steps {
                    script {
                        sh "nvm use ${NODE_VERSION}"
                        sh 'npm ci'
                    }
                }
            }

            stage('Build') {
                steps {
                    sh 'npm run build'
                }
            }

            stage('Test') {
                steps {
                    sh 'npm test'
                }
            }

            stage('Deploy') {
                when {
                    expression { config.deploy == true }
                }
                steps {
                    sh config.deployScript ?: './deploy.sh'
                }
            }
        }
    }
}
```

**Using Shared Library (Jenkinsfile):**

```groovy
@Library('my-shared-library') _

buildNodeApp(
    nodeVersion: '20',
    deploy: true,
    deployScript: './scripts/deploy-to-prod.sh'
)
```

### Kubernetes Integration

```groovy
pipeline {
    agent {
        kubernetes {
            yaml """
apiVersion: v1
kind: Pod
metadata:
  labels:
    jenkins: agent
spec:
  containers:
  - name: node
    image: node:20
    command:
    - cat
    tty: true
  - name: docker
    image: docker:24
    command:
    - cat
    tty: true
    volumeMounts:
    - name: docker-sock
      mountPath: /var/run/docker.sock
  volumes:
  - name: docker-sock
    hostPath:
      path: /var/run/docker.sock
"""
        }
    }

    stages {
        stage('Build') {
            steps {
                container('node') {
                    sh 'npm ci'
                    sh 'npm run build'
                }
            }
        }

        stage('Docker Build') {
            steps {
                container('docker') {
                    sh 'docker build -t myapp:${BUILD_NUMBER} .'
                }
            }
        }
    }
}
```

### Best Practices

1. **Use Declarative Pipeline** - Simpler syntax, better validation
2. **Define timeout limits** - Prevent hanging builds
3. **Use Docker agents** - Consistent build environments
4. **Implement proper error handling** - Use `post` blocks
5. **Store credentials securely** - Use Jenkins credentials store
6. **Use shared libraries** - Reduce code duplication
7. **Clean workspace** - Use `cleanWs()` in post block

### Key Resources

- **Pipeline Documentation:** https://www.jenkins.io/doc/book/pipeline/
- **Getting Started:** https://www.jenkins.io/doc/book/pipeline/getting-started/
- **Examples Repository:** https://github.com/jenkinsci/pipeline-examples
- **Best Practices Guide:** https://www.lambdatest.com/blog/jenkins-declarative-pipeline-examples/

---

## 3.4 CircleCI

### Basic Configuration (.circleci/config.yml)

```yaml
version: 2.1

orbs:
  node: circleci/node@5.1.0

jobs:
  build-and-test:
    docker:
      - image: cimg/node:20.0
    steps:
      - checkout
      - node/install-packages:
          pkg-manager: npm
      - run:
          name: Run tests
          command: npm test
      - run:
          name: Build
          command: npm run build
      - persist_to_workspace:
          root: .
          paths:
            - dist

  deploy:
    docker:
      - image: cimg/node:20.0
    steps:
      - attach_workspace:
          at: .
      - run:
          name: Deploy to production
          command: npm run deploy

workflows:
  build-test-deploy:
    jobs:
      - build-and-test
      - deploy:
          requires:
            - build-and-test
          filters:
            branches:
              only: main
```

### Advanced Multi-Job Pipeline

```yaml
version: 2.1

orbs:
  node: circleci/node@5.1.0
  docker: circleci/docker@2.2.0

executors:
  node-executor:
    docker:
      - image: cimg/node:20.0
    resource_class: medium

jobs:
  checkout-and-install:
    executor: node-executor
    steps:
      - checkout
      - restore_cache:
          keys:
            - npm-deps-v1-{{ checksum "package-lock.json" }}
            - npm-deps-v1-
      - run:
          name: Install dependencies
          command: npm ci
      - save_cache:
          key: npm-deps-v1-{{ checksum "package-lock.json" }}
          paths:
            - node_modules
      - persist_to_workspace:
          root: .
          paths:
            - .

  lint:
    executor: node-executor
    steps:
      - attach_workspace:
          at: .
      - run:
          name: Run linter
          command: npm run lint

  test:
    executor: node-executor
    parallelism: 4
    steps:
      - attach_workspace:
          at: .
      - run:
          name: Run tests
          command: |
            TEST_FILES=$(circleci tests glob "test/**/*.test.js" | circleci tests split --split-by=timings)
            npm test -- $TEST_FILES
      - store_test_results:
          path: test-results
      - store_artifacts:
          path: coverage

  build:
    executor: node-executor
    steps:
      - attach_workspace:
          at: .
      - run:
          name: Build application
          command: npm run build
      - persist_to_workspace:
          root: .
          paths:
            - dist

  docker-build-and-push:
    executor: docker/docker
    steps:
      - setup_remote_docker:
          version: 20.10.18
      - checkout
      - docker/check
      - docker/build:
          image: myorg/myapp
          tag: ${CIRCLE_SHA1},latest
      - docker/push:
          image: myorg/myapp
          tag: ${CIRCLE_SHA1},latest

workflows:
  main-workflow:
    jobs:
      - checkout-and-install

      - lint:
          requires:
            - checkout-and-install

      - test:
          requires:
            - checkout-and-install

      - build:
          requires:
            - lint
            - test

      - docker-build-and-push:
          requires:
            - build
          filters:
            branches:
              only: main
          context:
            - docker-hub-creds
```

### Monorepo Configuration

```yaml
version: 2.1

parameters:
  run-app1-workflow:
    type: boolean
    default: false
  run-app2-workflow:
    type: boolean
    default: false

jobs:
  check-changes:
    docker:
      - image: cimg/base:stable
    steps:
      - checkout
      - run:
          name: Determine changed packages
          command: |
            if git diff --name-only origin/main | grep -q "packages/app1/"; then
              echo "export APP1_CHANGED=true" >> $BASH_ENV
            fi
            if git diff --name-only origin/main | grep -q "packages/app2/"; then
              echo "export APP2_CHANGED=true" >> $BASH_ENV
            fi

  build-app1:
    docker:
      - image: cimg/node:20.0
    steps:
      - checkout
      - run:
          name: Build App1
          command: |
            cd packages/app1
            npm ci
            npm run build

  build-app2:
    docker:
      - image: cimg/node:20.0
    steps:
      - checkout
      - run:
          name: Build App2
          command: |
            cd packages/app2
            npm ci
            npm run build

workflows:
  check-and-build:
    when:
      not: << pipeline.parameters.run-app1-workflow >>
    jobs:
      - check-changes

  app1-workflow:
    when: << pipeline.parameters.run-app1-workflow >>
    jobs:
      - build-app1

  app2-workflow:
    when: << pipeline.parameters.run-app2-workflow >>
    jobs:
      - build-app2
```

### Best Practices

1. **Use Orbs** - Reusable configuration packages
2. **Implement Caching** - Speed up builds with dependency caching
3. **Workspace Persistence** - Share data between jobs efficiently
4. **Parallelism** - Split tests across multiple containers
5. **Resource Classes** - Choose appropriate compute resources

### Key Resources

- **CircleCI Documentation:** https://circleci.com/docs/
- **Configuration Reference:** https://circleci.com/docs/configuration-reference
- **Orb Registry:** https://circleci.com/developer/orbs
- **GitLab Integration:** https://circleci.com/docs/guides/integration/gitlab-integration/

---

# 4. Code Generation Automation

## 4.1 Scaffolding Tools

### Yeoman

**Official Site:** https://yeoman.io/

#### Installation

```bash
npm install -g yo
```

#### Using Existing Generators

```bash
# Install a generator
npm install -g generator-webapp
npm install -g generator-node
npm install -g generator-react

# Run generator
yo webapp        # Scaffold web app
yo node          # Scaffold Node.js module
yo react         # Scaffold React app
```

#### Creating Custom Generator

**Project Structure:**

```
generator-myapp/
├── package.json
├── generators/
│   ├── app/
│   │   ├── index.js
│   │   └── templates/
│   │       ├── package.json
│   │       ├── src/
│   │       └── README.md
│   └── component/
│       ├── index.js
│       └── templates/
│           └── component.tsx
```

**Generator Code (generators/app/index.js):**

```javascript
const Generator = require('yeoman-generator');
const chalk = require('chalk');

module.exports = class extends Generator {
  // 1. Initialization
  initializing() {
    this.log(chalk.blue('Welcome to my awesome generator!'));
  }

  // 2. Prompting for user input
  async prompting() {
    this.answers = await this.prompt([
      {
        type: 'input',
        name: 'appName',
        message: 'What is your app name?',
        default: this.appname
      },
      {
        type: 'list',
        name: 'framework',
        message: 'Which framework?',
        choices: ['React', 'Vue', 'Angular']
      },
      {
        type: 'confirm',
        name: 'includeTests',
        message: 'Include test setup?',
        default: true
      }
    ]);
  }

  // 3. Writing files
  writing() {
    // Copy template with EJS variables
    this.fs.copyTpl(
      this.templatePath('package.json'),
      this.destinationPath('package.json'),
      {
        appName: this.answers.appName,
        framework: this.answers.framework
      }
    );

    // Copy entire directory
    this.fs.copy(
      this.templatePath('src'),
      this.destinationPath('src')
    );

    // Conditional file creation
    if (this.answers.includeTests) {
      this.fs.copy(
        this.templatePath('tests'),
        this.destinationPath('tests')
      );
    }
  }

  // 4. Installing dependencies
  install() {
    this.npmInstall();
  }

  // 5. Completion
  end() {
    this.log(chalk.green('Setup complete! Run npm start to begin.'));
  }
};
```

**Template with EJS (templates/package.json):**

```json
{
  "name": "<%= appName %>",
  "version": "1.0.0",
  "description": "<%= framework %> application",
  "scripts": {
    "start": "react-scripts start",
    "build": "react-scripts build",
    "test": "react-scripts test"
  },
  "dependencies": {
    "<%= framework.toLowerCase() %>": "^18.0.0"
  }
}
```

**Component Generator (generators/component/index.js):**

```javascript
const Generator = require('yeoman-generator');

module.exports = class extends Generator {
  async prompting() {
    this.answers = await this.prompt([
      {
        type: 'input',
        name: 'componentName',
        message: 'Component name:',
        validate: (input) => input.length > 0
      },
      {
        type: 'confirm',
        name: 'withStyles',
        message: 'Include styles?',
        default: true
      }
    ]);
  }

  writing() {
    const { componentName, withStyles } = this.answers;

    this.fs.copyTpl(
      this.templatePath('component.tsx'),
      this.destinationPath(`src/components/${componentName}.tsx`),
      { componentName }
    );

    if (withStyles) {
      this.fs.copy(
        this.templatePath('styles.css'),
        this.destinationPath(`src/components/${componentName}.css`)
      );
    }
  }
};
```

**Usage:**

```bash
# Link local generator for development
cd generator-myapp
npm link

# Run generator
yo myapp              # Run app generator
yo myapp:component    # Run component sub-generator
```

### Plop.js

**Official Site:** https://plopjs.com/

#### Installation

```bash
npm install --save-dev plop
```

#### Configuration (plopfile.js)

```javascript
module.exports = function (plop) {
  // Component generator
  plop.setGenerator('component', {
    description: 'Create a new React component',
    prompts: [
      {
        type: 'input',
        name: 'name',
        message: 'Component name:'
      },
      {
        type: 'list',
        name: 'type',
        message: 'Component type:',
        choices: ['functional', 'class']
      }
    ],
    actions: [
      {
        type: 'add',
        path: 'src/components/{{pascalCase name}}/{{pascalCase name}}.tsx',
        templateFile: 'templates/component.tsx.hbs'
      },
      {
        type: 'add',
        path: 'src/components/{{pascalCase name}}/{{pascalCase name}}.test.tsx',
        templateFile: 'templates/component.test.tsx.hbs'
      },
      {
        type: 'add',
        path: 'src/components/{{pascalCase name}}/index.ts',
        template: 'export { {{pascalCase name}} } from "./{{pascalCase name}}";\n'
      }
    ]
  });

  // API route generator
  plop.setGenerator('api-route', {
    description: 'Create a new API route',
    prompts: [
      {
        type: 'input',
        name: 'name',
        message: 'Route name (e.g., users):'
      },
      {
        type: 'checkbox',
        name: 'methods',
        message: 'HTTP methods:',
        choices: ['GET', 'POST', 'PUT', 'DELETE']
      }
    ],
    actions: function(data) {
      const actions = [
        {
          type: 'add',
          path: 'src/routes/{{kebabCase name}}.ts',
          templateFile: 'templates/route.ts.hbs'
        }
      ];

      // Add test file
      actions.push({
        type: 'add',
        path: 'src/routes/{{kebabCase name}}.test.ts',
        templateFile: 'templates/route.test.ts.hbs'
      });

      return actions;
    }
  });

  // Custom action type
  plop.setActionType('log', function (answers, config, plop) {
    console.log('Custom action:', answers);
  });
};
```

**Template (templates/component.tsx.hbs):**

```handlebars
import React from 'react';
import styles from './{{pascalCase name}}.module.css';

interface {{pascalCase name}}Props {
  // Define props here
}

{{#if (eq type 'functional')}}
export const {{pascalCase name}}: React.FC<{{pascalCase name}}Props> = (props) => {
  return (
    <div className={styles.container}>
      <h1>{{pascalCase name}}</h1>
    </div>
  );
};
{{else}}
export class {{pascalCase name}} extends React.Component<{{pascalCase name}}Props> {
  render() {
    return (
      <div className={styles.container}>
        <h1>{{pascalCase name}}</h1>
      </div>
    );
  }
}
{{/if}}
```

**Usage:**

```bash
# Run generator
npx plop            # Interactive selection
npx plop component  # Run specific generator
```

**package.json scripts:**

```json
{
  "scripts": {
    "generate": "plop",
    "g:component": "plop component",
    "g:route": "plop api-route"
  }
}
```

### Hygen

**Official Site:** http://www.hygen.io/

#### Installation

```bash
npm install -g hygen
```

#### Project Setup

```bash
# Initialize hygen in project
hygen init self

# Project structure
_templates/
├── component/
│   ├── new/
│   │   ├── component.ejs.t
│   │   ├── test.ejs.t
│   │   └── prompt.js
│   └── with-prompt/
│       └── hello.ejs.t
└── generator/
    └── ...
```

#### Generator Template (_templates/component/new/component.ejs.t)

```javascript
---
to: src/components/<%= name %>/<%= name %>.tsx
---
import React from 'react';
import './<%= name %>.css';

interface <%= name %>Props {
  // Props definition
}

export const <%= name %>: React.FC<<%= name %>Props> = (props) => {
  return (
    <div className="<%= h.changeCase.kebab(name) %>">
      <h1><%= name %></h1>
    </div>
  );
};
```

#### Prompt Configuration (_templates/component/new/prompt.js)

```javascript
module.exports = {
  prompt: ({ inquirer }) => {
    const questions = [
      {
        type: 'input',
        name: 'name',
        message: 'Component name:'
      },
      {
        type: 'confirm',
        name: 'withStyles',
        message: 'Include CSS file?'
      }
    ];
    return inquirer.prompt(questions).then(answers => {
      return { ...answers };
    });
  }
};
```

#### Usage

```bash
# Generate component
hygen component new --name MyComponent

# With prompt
hygen component with-prompt
```

### Cookiecutter (Python)

**Official Site:** https://cookiecutter.readthedocs.io/

#### Installation

```bash
pip install cookiecutter
```

#### Using Templates

```bash
# From GitHub
cookiecutter https://github.com/audreyr/cookiecutter-pypackage

# Local template
cookiecutter /path/to/template

# With extra context
cookiecutter template/ --no-input project_name=myproject
```

#### Creating Template

**Project Structure:**

```
cookiecutter-mytemplate/
├── {{cookiecutter.project_slug}}/
│   ├── {{cookiecutter.project_slug}}/
│   │   └── __init__.py
│   ├── tests/
│   ├── README.md
│   └── setup.py
└── cookiecutter.json
```

**Configuration (cookiecutter.json):**

```json
{
  "project_name": "My Project",
  "project_slug": "{{ cookiecutter.project_name.lower().replace(' ', '_') }}",
  "author_name": "Your Name",
  "author_email": "you@example.com",
  "version": "0.1.0",
  "python_version": ["3.8", "3.9", "3.10", "3.11"],
  "use_pytest": "y",
  "use_docker": "n"
}
```

**Template File ({{cookiecutter.project_slug}}/setup.py):**

```python
from setuptools import setup, find_packages

setup(
    name='{{ cookiecutter.project_slug }}',
    version='{{ cookiecutter.version }}',
    author='{{ cookiecutter.author_name }}',
    author_email='{{ cookiecutter.author_email }}',
    packages=find_packages(),
    python_requires='>={{ cookiecutter.python_version }}',
)
```

### Scaffolding Tools Comparison

| Tool | Language | Complexity | Best For |
|------|----------|-----------|----------|
| **Yeoman** | JavaScript | Medium | Full project scaffolding |
| **Plop** | JavaScript | Low | Repetitive file generation |
| **Hygen** | JavaScript | Low | Fast, simple templates |
| **Cookiecutter** | Python | Low | Python project templates |
| **Spring Initializr** | Java | Low | Spring Boot projects |

---

## 4.2 AI Code Generation

### Top AI Code Generation Tools 2024-2025

#### GitHub Copilot

**Platform:** VS Code, Visual Studio, JetBrains, Neovim
**Model:** GPT-4 (OpenAI Codex)
**URL:** https://github.com/features/copilot

**Features:**
- Real-time code suggestions
- Multi-line completions
- Chat interface for questions
- Test generation
- Documentation generation

**Setup (VS Code):**

```json
// settings.json
{
  "github.copilot.enable": {
    "*": true
  },
  "github.copilot.editor.enableAutoCompletions": true,
  "editor.inlineSuggest.enabled": true
}
```

**Usage Examples:**

```javascript
// Type comment, Copilot suggests implementation
// Function to validate email address
function validateEmail(email) {
  // Copilot generates regex validation
}

// Generate test cases
// Test suite for validateEmail
describe('validateEmail', () => {
  // Copilot generates test cases
});
```

#### Amazon Q Developer (formerly CodeWhisperer)

**Platform:** VS Code, JetBrains, AWS Cloud9
**Model:** Amazon proprietary
**URL:** https://aws.amazon.com/q/developer/

**Features:**
- Code generation
- Security scanning
- AWS best practices
- Reference tracking (licenses)

**Key Advantage:** Free for individual developers

#### Tabnine

**Platform:** All major IDEs
**Model:** Custom trained models
**URL:** https://www.tabnine.com/

**Features:**
- Local/cloud AI
- Team training on codebase
- Privacy-focused (on-premise option)
- Multi-language support

**Configuration:**

```json
{
  "tabnine.experimentalAutoImports": true,
  "tabnine.debounceMilliseconds": 300,
  "tabnine.cloud.teamKey": "your-team-key"
}
```

#### Cursor (AI-First IDE)

**Platform:** Standalone (VS Code fork)
**URL:** https://cursor.com/

**Features:**
- Cmd+K for inline editing
- Chat with codebase
- Multi-file editing
- AI-powered debugging

**Unique Capabilities:**
- Edit multiple files at once
- Natural language to code
- Codebase-aware suggestions

#### Devin (Autonomous Agent)

**Launch:** March 2024
**Type:** Autonomous coding agent
**URL:** https://www.cognition-labs.com/devin

**Capabilities:**
- Autonomous bug fixing
- Full application building
- Learn new technologies
- Deploy applications
- Train AI models

**Status:** Limited availability, enterprise-focused

### AI Code Generation Best Practices

#### 1. Security & Privacy

```python
# ❌ Bad: Exposing secrets to AI
API_KEY = "sk-1234567890abcdef"  # AI sees this

# ✅ Good: Use environment variables
import os
API_KEY = os.getenv("API_KEY")
```

**Settings for Privacy:**

```json
{
  "github.copilot.telemetry.enabled": false,
  "github.copilot.advanced": {
    "inlineSuggestEnabled": false  // For sensitive files
  }
}
```

#### 2. Code Review AI Suggestions

**Always:**
- Review generated code for correctness
- Check for security vulnerabilities
- Verify performance implications
- Test thoroughly

**Example Review Checklist:**

```markdown
- [ ] Code follows project conventions
- [ ] No hardcoded secrets or credentials
- [ ] Error handling is appropriate
- [ ] Edge cases are handled
- [ ] Performance is acceptable
- [ ] Tests are comprehensive
```

#### 3. Effective Prompting

**Better Comments = Better Code:**

```javascript
// ❌ Vague
// Function to process data

// ✅ Specific
// Function to validate user input, sanitize HTML, and check for XSS
// Returns: { valid: boolean, sanitized: string, errors: string[] }
function processUserInput(input) {
  // AI generates better code with detailed context
}
```

#### 4. Test Generation

```python
# Write function first
def calculate_fibonacci(n: int) -> int:
    """Calculate nth Fibonacci number using iteration."""
    if n <= 1:
        return n
    a, b = 0, 1
    for _ in range(2, n + 1):
        a, b = b, a + b
    return b

# Add comment, let AI generate tests
# Pytest tests for calculate_fibonacci covering edge cases
# AI generates comprehensive test suite
```

#### 5. Documentation Generation

```typescript
// Hover over function, use AI to generate docs
export async function fetchUserData(
  userId: string,
  options?: FetchOptions
): Promise<UserData> {
  // Implementation
}

// AI generates:
/**
 * Fetches user data from the API
 * @param userId - The unique identifier for the user
 * @param options - Optional fetch configuration
 * @returns Promise resolving to user data
 * @throws {APIError} When the API request fails
 * @throws {ValidationError} When userId is invalid
 */
```

### AI Code Generation Patterns

#### Boilerplate Generation

```bash
# Instead of writing manually, use AI to generate:
# - CRUD operations
# - API clients
# - Database models
# - React components with hooks
# - Express routes with validation
```

#### Refactoring

```javascript
// Select code, ask AI to refactor
// Before (verbose)
function getUserName(user) {
  if (user) {
    if (user.name) {
      return user.name;
    } else {
      return 'Unknown';
    }
  } else {
    return 'Unknown';
  }
}

// AI suggests (clean)
function getUserName(user) {
  return user?.name ?? 'Unknown';
}
```

#### Bug Fixing

```python
# Copy error, ask AI for fix
# Error: TypeError: 'NoneType' object is not subscriptable
def get_first_item(items):
    return items[0]  # Error when items is None

# AI suggests fix:
def get_first_item(items):
    if items and len(items) > 0:
        return items[0]
    return None
```

### Productivity Metrics (2024)

According to industry studies:
- **30% faster** development with AI assistance
- **76% of developers** use AI for code writing
- **7.5% improvement** in documentation quality
- **3.4% improvement** in code quality
- **3.1% faster** code reviews

### Key Resources

- **GitHub Copilot Docs:** https://docs.github.com/en/copilot
- **Amazon Q Developer:** https://aws.amazon.com/q/developer/
- **Tabnine Documentation:** https://www.tabnine.com/docs
- **AI Code Tools Comparison:** https://www.turing.com/blog/top-5-ai-code-generation-tools-in-2024

---

## 4.3 Template Engines

### Handlebars

**Official Site:** https://handlebarsjs.com/

#### Installation

```bash
npm install handlebars
```

#### Basic Usage

```javascript
const Handlebars = require('handlebars');

// Template
const template = Handlebars.compile(`
  <div class="user">
    <h1>{{name}}</h1>
    <p>{{email}}</p>
  </div>
`);

// Data
const context = {
  name: 'John Doe',
  email: 'john@example.com'
};

// Generate
const html = template(context);
```

#### Advanced Features

```handlebars
{{!-- Conditionals --}}
{{#if user}}
  <h1>Welcome, {{user.name}}!</h1>
{{else}}
  <h1>Please log in</h1>
{{/if}}

{{!-- Loops --}}
<ul>
  {{#each items}}
    <li>{{this.name}} - ${{this.price}}</li>
  {{/each}}
</ul>

{{!-- Helpers --}}
{{uppercase name}}
{{formatDate createdAt}}

{{!-- Partials --}}
{{> header}}
<main>Content here</main>
{{> footer}}
```

**Custom Helpers:**

```javascript
Handlebars.registerHelper('uppercase', function(str) {
  return str.toUpperCase();
});

Handlebars.registerHelper('formatDate', function(date) {
  return new Date(date).toLocaleDateString();
});

Handlebars.registerHelper('eq', function(a, b) {
  return a === b;
});
```

**Partials:**

```javascript
Handlebars.registerPartial('header', `
  <header>
    <h1>{{title}}</h1>
  </header>
`);
```

### EJS (Embedded JavaScript)

**Official Site:** https://ejs.co/

#### Installation

```bash
npm install ejs
```

#### Basic Usage

```javascript
const ejs = require('ejs');

// Template string
const template = `
  <h1><%= title %></h1>
  <p><%- content %></p>
  <% if (user) { %>
    <span>Welcome, <%= user.name %></span>
  <% } %>
`;

// Render
const html = ejs.render(template, {
  title: 'My Page',
  content: '<strong>Bold content</strong>',
  user: { name: 'John' }
});
```

#### File-based Templates

```javascript
// template.ejs
/*
<!DOCTYPE html>
<html>
<head>
  <title><%= title %></title>
</head>
<body>
  <%- include('partials/header') %>

  <main>
    <% users.forEach(function(user) { %>
      <div class="user">
        <h2><%= user.name %></h2>
        <p><%= user.email %></p>
      </div>
    <% }); %>
  </main>

  <%- include('partials/footer') %>
</body>
</html>
*/

// Render from file
ejs.renderFile('template.ejs', {
  title: 'Users',
  users: [...]
}, function(err, html) {
  console.log(html);
});
```

#### Tags

```ejs
<%= value %>     <%# Escaped output %>
<%- value %>     <%# Unescaped output (raw HTML) %>
<% code %>       <%# JavaScript code (no output) %>
<%# comment %>   <%# Comment %>
<%- include('partial') %>  <%# Include partial %>
```

### Mustache

**Official Site:** https://mustache.github.io/

#### Installation

```bash
npm install mustache
```

#### Basic Usage

```javascript
const Mustache = require('mustache');

const template = `
  <h1>{{title}}</h1>
  {{#users}}
    <div>
      <strong>{{name}}</strong>
      {{#admin}}<span class="badge">Admin</span>{{/admin}}
    </div>
  {{/users}}
  {{^users}}
    <p>No users found</p>
  {{/users}}
`;

const data = {
  title: 'User List',
  users: [
    { name: 'John', admin: true },
    { name: 'Jane', admin: false }
  ]
};

const html = Mustache.render(template, data);
```

#### Sections

```mustache
{{#section}}Content{{/section}}        <!-- If truthy, render content -->
{{^section}}Content{{/section}}        <!-- If falsy, render content -->
{{#list}}{{name}}{{/list}}             <!-- Loop over array -->
{{.}}                                   <!-- Current item in loop -->
```

### Nunjucks

**Official Site:** https://mozilla.github.io/nunjucks/

#### Installation

```bash
npm install nunjucks
```

#### Basic Usage

```javascript
const nunjucks = require('nunjucks');

// Configure
nunjucks.configure('views', {
  autoescape: true,
  watch: true
});

// Render
const html = nunjucks.render('template.html', {
  title: 'My Page',
  items: [1, 2, 3]
});
```

#### Template Features

```nunjucks
{# Variables #}
{{ username }}
{{ user.name }}

{# Filters #}
{{ name | upper }}
{{ items | length }}
{{ date | date("YYYY-MM-DD") }}

{# Conditionals #}
{% if hungry %}
  <p>I'm hungry</p>
{% elif tired %}
  <p>I'm tired</p>
{% else %}
  <p>I'm good!</p>
{% endif %}

{# Loops #}
{% for item in items %}
  <li>{{ item.title }}</li>
{% else %}
  <li>No items</li>
{% endfor %}

{# Macros (reusable components) #}
{% macro field(name, value='', type='text') %}
  <input type="{{ type }}" name="{{ name }}" value="{{ value }}">
{% endmacro %}

{{ field('email', 'user@example.com', 'email') }}

{# Inheritance #}
{% extends "base.html" %}

{% block content %}
  <h1>Page Content</h1>
{% endblock %}

{# Include #}
{% include "header.html" %}
```

### Template Engine Comparison

| Engine | Syntax | Logic | Precompile | Best For |
|--------|--------|-------|------------|----------|
| **Handlebars** | Mustache-like | Helpers only | Yes | Simple, logic-less |
| **EJS** | JavaScript tags | Full JavaScript | No | JavaScript developers |
| **Mustache** | Minimal | Logic-less | Yes | Simple templates |
| **Nunjucks** | Django-like | Rich features | Yes | Complex templates |
| **Pug** | Indentation | Full JavaScript | Yes | HTML generation |

### Code Generation with Templates

#### File Generator Example

```javascript
const fs = require('fs');
const path = require('path');
const Handlebars = require('handlebars');

// Template
const componentTemplate = `
import React from 'react';
{{#if withStyles}}
import styles from './{{name}}.module.css';
{{/if}}

interface {{name}}Props {
  {{#each props}}
  {{this.name}}{{#if this.optional}}?{{/if}}: {{this.type}};
  {{/each}}
}

export const {{name}}: React.FC<{{name}}Props> = ({{#if props}}{
  {{#each props}}{{this.name}}{{#unless @last}}, {{/unless}}{{/each}}
}{{/if}}) => {
  return (
    <div{{#if withStyles}} className={styles.container}{{/if}}>
      <h1>{{name}}</h1>
    </div>
  );
};
`;

// Generator function
function generateComponent(config) {
  const template = Handlebars.compile(componentTemplate);
  const code = template(config);

  const filePath = path.join(
    'src/components',
    config.name,
    `${config.name}.tsx`
  );

  fs.mkdirSync(path.dirname(filePath), { recursive: true });
  fs.writeFileSync(filePath, code);

  console.log(`Created ${filePath}`);
}

// Usage
generateComponent({
  name: 'UserCard',
  withStyles: true,
  props: [
    { name: 'username', type: 'string', optional: false },
    { name: 'email', type: 'string', optional: false },
    { name: 'avatar', type: 'string', optional: true }
  ]
});
```

### Key Resources

- **Handlebars:** https://handlebarsjs.com/
- **EJS:** https://ejs.co/
- **Mustache:** https://mustache.github.io/
- **Nunjucks:** https://mozilla.github.io/nunjucks/
- **Template Comparison:** https://colorlib.com/wp/top-templating-engines-for-javascript/

---

## Conclusion

This comprehensive guide covers the latest development workflow patterns and tools as of 2024-2025. Key trends include:

1. **AI Integration** - Nearly every IDE now includes AI-powered code assistance
2. **Trunk-Based Development** - Replacing GitFlow as the standard for modern teams
3. **Monorepo Adoption** - Tools like Turborepo and Nx making monorepos accessible
4. **GitHub Actions Dominance** - Leading the CI/CD space with extensive ecosystem
5. **Conventional Commits** - Standard for automated versioning and changelogs

### Next Steps

1. Choose tools that match your team size and workflow
2. Start with simple implementations and iterate
3. Prioritize automation where it adds most value
4. Keep security and code quality as top priorities
5. Stay updated with official documentation

### Additional Resources

- **State of JavaScript 2024:** https://2024.stateofjs.com/
- **GitHub Trending:** https://github.com/trending
- **Dev.to:** https://dev.to/
- **Medium Engineering:** https://medium.com/tag/software-engineering

---

**Document compiled on:** November 15, 2025
**Sources:** Official documentation, developer blogs, industry surveys, and real-world implementations
**Maintainer:** Research compiled from 40+ sources across web searches and documentation
