# CEREBRAS MASTER BOOTSTRAP - PhiSHRI Content Engine

## Model Context
- **Model**: Cerebras 347B
- **Context Window**: 2M tokens
- **Role**: Primary content generation engine for PhiSHRI door system
- **Agent Capacity**: Yes - multi-step task execution

---

## PART 1: FULL PROJECT CONTEXT

### What is PhiSHRI?
**PhiSHRI** = **S**emantic(**S**elf) **H**ashing **R**adial **R**epository **I**ndex

A system that solves the **AI context continuity problem**. Instead of re-explaining context every session, AI agents load "doors" - curated JSON knowledge bundles indexed by semantic codes.

**The Innovation:**
- Traditional: 10 sessions = 320K tokens with context drift
- PhiSHRI: 10 sessions = 56K tokens with zero drift (83% savings)

**How It Works:**
1. Knowledge is stored in "doors" (JSON files with semantic codes like D05, S26, W156)
2. Doors are indexed by HASH_TABLE (code → path) and SEMANTIC_MAP (aliases → code)
3. AI agents load doors by code instead of re-reading documentation
4. Session state is preserved in bootstrap files for cross-session handoffs
5. Door codes act as "checkpoint coordinates" - "Resume: [D05, S26, T30]"

### Architecture
```
PhiSHRI/
├── INDEX.json                 # Master catalog
├── INDEXES/
│   ├── HASH_TABLE.json       # door_code → file_path
│   └── SEMANTIC_MAP.json     # aliases → door_code
├── CONTEXTS/
│   ├── DEPLOYMENT/           # D## doors
│   ├── SECURITY/             # S## doors
│   ├── WORKFLOWS/            # W## doors
│   ├── TOOLS/                # T## doors
│   ├── REFERENCE/            # R## doors
│   ├── ERRORS/               # E## doors
│   ├── ARCHITECTURE/         # A## doors
│   └── LANGUAGES/            # L## doors
└── SESSIONS/                 # Bootstrap files
```

### Door JSON Schema
```json
{
  "door_code": "T30",
  "title": "T30JENKINS_PIPELINES",
  "category": "TOOLS",
  "subcategory": "DEVOPS",
  "path": "TOOLS.DEVOPS.CI_CD",
  "summary": "2-3 sentence overview of what this door covers",
  "content": "Comprehensive guide content - 2000-5000 words of actual usable knowledge",
  "key_points": [
    "Critical insight 1",
    "Critical insight 2",
    "Critical insight 3"
  ],
  "tags": ["jenkins", "ci-cd", "pipelines", "devops", "automation"],
  "prerequisites": ["T05"],
  "related_doors": ["T31", "T32", "W120"],
  "version": "1.0",
  "last_updated": "2025-11-21"
}
```

### Quality Standards for Door Content
1. **Actionable**: Reader can implement immediately after reading
2. **Comprehensive**: Covers the topic thoroughly, not surface-level
3. **Structured**: Clear sections, code examples where relevant
4. **Referenced**: Mentions specific tools, versions, commands
5. **Connected**: Links to related doors via prerequisites/related_doors
6. **Current**: Reflects 2024-2025 best practices

### Content Depth Guide
| Door Type | Word Count | Code Examples | Depth |
|-----------|------------|---------------|-------|
| Concept | 1500-2500 | Few | Explain the "why" |
| Tool | 2500-4000 | Many | Hands-on guide |
| Pattern | 2000-3500 | Several | When/how to apply |
| Reference | 3000-5000 | Comprehensive | Deep dive |

---

## PART 2: CURRENT STATE (As of 2025-11-21)

### Door Inventory
- **Total Doors**: 323 (after Batch 13A)
- **Target**: 500 minimum by end of December
- **Ultimate Goal**: 100MB of markdown content

### Category Breakdown (Current)
| Category | Code Prefix | Count | Notes |
|----------|-------------|-------|-------|
| DEPLOYMENT | D## | ~25 | Silent install, MSI, enterprise |
| SECURITY | S## | 35 | OWASP complete (S01-S35) |
| WORKFLOWS | W## | 165 | Largest category |
| TOOLS | T## | ~30 | DevOps, CI/CD |
| REFERENCE | R## | ~25 | Architecture patterns |
| ERRORS | E## | ~15 | Error handling |
| ARCHITECTURE | A## | ~10 | System design |
| LANGUAGES | L## | 0 | Not started |

### Batches Completed
- Batch 1-8: Foundation (268 doors)
- Batch 8A: 30 doors (S19-S25, W132-W145, R17-R23, T28-T29)
- Batch 9A: 10 doors (S26-S35 OWASP security)
- Batch 10A-12A: Various
- Batch 13A: 10 doors (W156-W165 Data Engineering)
- Batch 14A: In progress (R24-R33 Cloud Architecture)

### Remaining to 500
177 doors across planned batches 14A-31A

---

## PART 3: MCP SERVER STATUS

### What is PhiSHRI MCP?
A Rust binary that exposes PhiSHRI as a Model Context Protocol server. Any MCP-compatible AI client (Claude Desktop, etc.) can use PhiSHRI tools directly.

### Current Status: FUNCTIONAL
- Binary: `C:\Dev\PhiSHRI_MCP\phishri-mcp\target\release\phishri-mcp.exe`
- 10/10 tools passing tests
- Ready for Claude Desktop integration

### MCP Tools Available
1. `phishri_read_door` - Read single door by code
2. `phishri_list_doors` - List doors by category
3. `phishri_find_door` - Search by natural language query
4. `phishri_load_chain` - Load multiple doors at once
5. `phishri_get_bootstrap` - Get current session state
6. `phishri_update_bootstrap` - Update session progress
7. `phishri_session_checkpoint` - Create named checkpoint
8. `phishri_search_semantic` - Search by semantic path
9. `phishri_get_prerequisites` - Get prerequisite chain
10. `phishri_rebuild_indexes` - Rebuild HASH_TABLE and SEMANTIC_MAP

### Integration Config (Claude Desktop)
```json
{
  "mcpServers": {
    "phishri": {
      "command": "C:\\Dev\\PhiSHRI_MCP\\phishri-mcp\\target\\release\\phishri-mcp.exe",
      "env": {
        "PHISHRI_PATH": "C:\\Dev\\PhiSRHI\\PhiSHRI"
      }
    }
  }
}
```

---

## PART 4: FUTURE ROADMAP

### Phase 1: Content (Now - Dec 31, 2025)
- Hit 500 doors minimum
- Target 100MB total markdown content
- Focus areas: DevOps, Security, Cloud, Languages

### Phase 2: Distribution (Jan 2026)
- PhiSHRI MCP published to crates.io
- Starter door pack bundled
- Full door collection as separate download
- MIT license for maximum adoption

### Phase 3: Ecosystem (Q1 2026)
- REST API for web-based AI agents
- Door contribution guidelines
- Community door submissions
- Specialized door packs (Security-focused, ML-focused, etc.)

### Phase 4: Enterprise (Q2 2026)
- Private door repositories
- Team session sharing
- Audit logging
- Custom door creation tools

### Long-term Vision
PhiSHRI becomes the standard protocol for AI session continuity. Any AI agent, any platform, can maintain context across sessions using door codes. Like how URLs standardized web navigation, door codes standardize AI context navigation.

---

## PART 5: YOUR ROLE (CEREBRAS)

### Primary Function
**Bulk content generation engine**. Your 2M context window and 347B parameters make you ideal for generating large batches of high-quality doors.

### Typical Task Pattern
1. Receive batch specification (50-100 doors)
2. Generate complete door JSON for each
3. Maintain quality standards across entire batch
4. Output as JSON array or individual files
5. Include proper cross-references (related_doors)

### Quality Expectations
- Every door should be production-ready
- No placeholder content ("TODO", "TBD", etc.)
- Real code examples that actually work
- Consistent formatting across batch
- Proper semantic paths

### Coordination Notes
- **Keymaster Agent**: Handles index updates after your batches
- **Coder Agent**: Building MCP server (don't touch)
- **Other Agents**: QA, docs, research (non-conflicting)
- **Your Lane**: Bulk door content generation

---

## PART 6: IMMEDIATE TASK - BATCH 15A-18A (50 DOORS)

### Assignment
Generate 50 doors in one batch covering DevOps tooling.

### Door Codes: T30-T79

### Topic Breakdown

#### T30-T34: CI/CD Platforms (5 doors)
| Code | Title | Focus |
|------|-------|-------|
| T30 | T30JENKINS_PIPELINES | Jenkins declarative/scripted pipelines, shared libraries |
| T31 | T31GITLAB_CI | GitLab CI/CD, .gitlab-ci.yml, runners, artifacts |
| T32 | T32GITHUB_ACTIONS | Workflows, actions, matrices, reusable workflows |
| T33 | T33ARGOCD | GitOps deployments, app-of-apps, sync waves |
| T34 | T34CIRCLECI | Orbs, workflows, caching strategies |

#### T35-T39: Container Technologies (5 doors)
| Code | Title | Focus |
|------|-------|-------|
| T35 | T35DOCKER_ADVANCED | Multi-stage builds, layer caching, security scanning |
| T36 | T36PODMAN | Rootless containers, systemd integration, pods |
| T37 | T37CONTAINERD | Low-level runtime, CRI, snapshots |
| T38 | T38BUILDAH | OCI image building without daemon |
| T39 | T39KANIKO | In-cluster container builds, caching |

#### T40-T44: Kubernetes Deep Dives (5 doors)
| Code | Title | Focus |
|------|-------|-------|
| T40 | T40K8S_NETWORKING | CNI, services, ingress, network policies |
| T41 | T41HELM_ADVANCED | Chart development, hooks, dependencies, testing |
| T42 | T42KUSTOMIZE | Overlays, patches, generators, components |
| T43 | T43K8S_OPERATORS | Operator pattern, controller-runtime, reconciliation |
| T44 | T44K8S_CRD | Custom resources, validation, versioning |

#### T45-T49: Service Mesh (5 doors)
| Code | Title | Focus |
|------|-------|-------|
| T45 | T45ISTIO | Traffic management, security, observability |
| T46 | T46LINKERD | Lightweight mesh, mTLS, tap |
| T47 | T47ENVOY | Proxy configuration, xDS, filters |
| T48 | T48CONSUL_MESH | Service mesh with Consul Connect |
| T49 | T49TRAEFIK | Ingress controller, middleware, providers |

#### T50-T54: Observability Stack (5 doors)
| Code | Title | Focus |
|------|-------|-------|
| T50 | T50PROMETHEUS | PromQL, recording rules, alerting, federation |
| T51 | T51GRAFANA | Dashboards, datasources, alerting, provisioning |
| T52 | T52JAEGER | Distributed tracing, sampling, storage backends |
| T53 | T53OPENTELEMETRY | Instrumentation, collectors, OTLP |
| T54 | T54DATADOG | APM, logs, metrics, synthetics integration |

#### T55-T59: Logging Systems (5 doors)
| Code | Title | Focus |
|------|-------|-------|
| T55 | T55ELK_STACK | Elasticsearch, Logstash, Kibana patterns |
| T56 | T56LOKI | Log aggregation, LogQL, Promtail |
| T57 | T57FLUENTD | Unified logging, plugins, buffering |
| T58 | T58VECTOR | High-performance log routing, VRL |
| T59 | T59SPLUNK_PATTERNS | Enterprise logging, SPL, dashboards |

#### T60-T64: Infrastructure as Code (5 doors)
| Code | Title | Focus |
|------|-------|-------|
| T60 | T60TERRAFORM_ADVANCED | Modules, workspaces, state management, providers |
| T61 | T61PULUMI | Programming language IaC, stacks, automation API |
| T62 | T62CROSSPLANE | Kubernetes-native IaC, compositions, XRDs |
| T63 | T63AWS_CDK | TypeScript/Python infrastructure, constructs |
| T64 | T64ANSIBLE_ADVANCED | Roles, collections, AWX, dynamic inventory |

#### T65-T69: Secrets Management (5 doors)
| Code | Title | Focus |
|------|-------|-------|
| T65 | T65VAULT | Secrets engines, auth methods, policies, HA |
| T66 | T66SOPS | Encrypted files, key management, git integration |
| T67 | T67SEALED_SECRETS | Kubernetes secrets encryption, key rotation |
| T68 | T68EXTERNAL_SECRETS | ESO, providers, sync strategies |
| T69 | T69KMS_PATTERNS | AWS/GCP/Azure KMS, envelope encryption |

#### T70-T74: GitOps Patterns (5 doors)
| Code | Title | Focus |
|------|-------|-------|
| T70 | T70FLUX | GitOps toolkit, Kustomize controller, helm controller |
| T71 | T71GITOPS_PATTERNS | Repository structures, promotion, multi-cluster |
| T72 | T72DRIFT_DETECTION | Sync status, remediation, notifications |
| T73 | T73PROGRESSIVE_DELIVERY | Canary, blue-green, Flagger, Argo Rollouts |
| T74 | T74IMAGE_AUTOMATION | Image update automation, policies, signing |

#### T75-T79: Platform Engineering (5 doors)
| Code | Title | Focus |
|------|-------|-------|
| T75 | T75BACKSTAGE | Developer portal, software catalog, plugins |
| T76 | T76PORT | Internal developer portal, self-service |
| T77 | T77KRATIX | Platform as a Product, promises |
| T78 | T78IDP_PATTERNS | Internal developer platforms, golden paths |
| T79 | T79PLATFORM_TEAMS | Team topologies, platform thinking, APIs |

### Output Format
Generate as a JSON array:
```json
[
  {
    "door_code": "T30",
    "title": "T30JENKINS_PIPELINES",
    ...full door object...
  },
  {
    "door_code": "T31",
    ...
  },
  ...48 more doors...
]
```

### Cross-Reference Guidelines
- T30-T34 (CI/CD) should reference each other
- T40-T44 (K8s) should reference T35-T39 (containers)
- T50-T54 (observability) should reference T55-T59 (logging)
- T70-T74 (GitOps) should reference T30-T34 (CI/CD)
- All should reference relevant security doors (S26-S35) where applicable

---

## PART 7: FUTURE BATCH ASSIGNMENTS

When recalled, you may be assigned:

### Batch 19A-22A: Reference Architecture (40 doors)
- R24-R63: Cloud patterns, integration patterns, scalability

### Batch 23A-26A: Languages (40 doors)
- L01-L40: Python, Node.js, Go, Rust, TypeScript best practices

### Batch 27A-30A: Advanced Security (40 doors)
- S36-S75: Cloud security, container security, compliance frameworks

### Batch 31A+: Gap filling
- Mixed categories based on coverage gaps

---

## PART 8: COMMUNICATION PROTOCOL

### After Completing a Batch
Report format:
```
BATCH COMPLETE: [Batch ID]
Doors generated: [count]
Door codes: [range]
Total tokens used: [estimate]
Quality notes: [any concerns]
Ready for index integration.
```

### If You Encounter Issues
- Missing context: Request specific door for reference
- Ambiguous topic: Pick most common interpretation, note in door
- Overlap with existing: Check related_doors, differentiate focus

### Index Update Trigger
After your batch is accepted, Keymaster will:
1. Add doors to CONTEXTS/TOOLS/
2. Update HASH_TABLE.json
3. Update SEMANTIC_MAP.json
4. Update INDEX.json counts

---

## EXECUTION

You have full context. Generate the 50-door batch (T30-T79) as specified.

Prioritize:
1. Accuracy over speed
2. Depth over breadth
3. Actionable over theoretical
4. Connected over isolated

Begin.
