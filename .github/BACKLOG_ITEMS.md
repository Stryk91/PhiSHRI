# PhiSHRI Project Backlog Items

Copy each item individually into GitHub Projects backlog.

---

## v0.2 - In Progress

### MCP-001: PhiSHRI MCP Claude Desktop Integration Test
**Description:** Test MCP server with Claude Desktop using verified config
**Size:** Small
**Priority:** High

### MCP-002: Complete HASH_TABLE Index
**Description:** Ensure HASH_TABLE.json has mappings for all doors
**Size:** Small
**Priority:** High

### MCP-003: Complete SEMANTIC_MAP Index
**Description:** Ensure SEMANTIC_MAP.json has all alias mappings
**Size:** Small
**Priority:** High

### MCP-004: CLI Tool - phishri find
**Description:** Implement `phishri find "deployment"` command for terminal lookup
**Size:** Medium
**Priority:** Medium

### MCP-005: NLP Query Matching
**Description:** Natural language door search via fuzzy-matcher crate
**Size:** Medium
**Priority:** Medium

### MCP-006: Python Navigation API
**Description:** Programmatic door lookup for non-MCP integrations
**Size:** Medium
**Priority:** Low

---

## Content Milestones

### CONTENT-001: Hit 500 Doors
**Description:** Currently ~437 doors, need 63 more to reach 500 minimum
**Size:** Large
**Priority:** High

### CONTENT-002: 100MB Content Target
**Description:** Target 100MB of markdown content by Dec 31, 2025
**Size:** XL
**Priority:** High

### CONTENT-003: Cloud Provider Batch (C01-C50)
**Description:** 50 doors covering AWS/GCP/Azure deep dives - next batch after Languages
**Size:** Large
**Priority:** High

### CONTENT-004: Merge L01-L50 Languages Batch
**Description:** Sonnet 4.5's 50 language doors ready for merge
**Size:** Small
**Priority:** High

### CONTENT-005: Merge T30-T79 DevOps Batch
**Description:** Cerebras's 50 DevOps doors after conflict resolution
**Size:** Small
**Priority:** High

### CONTENT-006: Database Patterns Batch (D20-D35)
**Description:** Postgres, Redis, Mongo, migrations, connection pooling
**Size:** Medium
**Priority:** Medium

### CONTENT-007: Networking Batch (N01-N15)
**Description:** DNS, CDN, TLS, mTLS, load balancing, VPC
**Size:** Medium
**Priority:** Medium

### CONTENT-008: FinOps Batch (F01-F10)
**Description:** Cloud cost optimization, spot instances, rightsizing
**Size:** Medium
**Priority:** Low

### CONTENT-009: Incident Response Batch (I01-I10)
**Description:** Runbooks, postmortems, on-call, PagerDuty patterns
**Size:** Medium
**Priority:** Medium

### CONTENT-010: Compliance Batch (S70-S85)
**Description:** SOC2, HIPAA, GDPR, audit logging deep dives
**Size:** Medium
**Priority:** Medium

---

## v0.3 - Future Features

### FEAT-001: Granularity Markers
**Description:** Atomic/chunked/hierarchical door access patterns for cognitive load matching
**Size:** Medium
**Priority:** Medium

### FEAT-002: Session Checkpoint Doors
**Description:** Explicit session state persistence as door format
**Size:** Medium
**Priority:** Medium

### FEAT-003: Multi-Agent Coordination
**Description:** Shared door context between multiple AI agents
**Size:** Large
**Priority:** Low

### FEAT-004: Agent Isolation
**Description:** Session namespacing for MCP - agent_id + session_id isolation
**Size:** Medium
**Priority:** Medium

### FEAT-005: REST API
**Description:** `GET /door/D05` endpoint for web-based AI agents without MCP
**Size:** Large
**Priority:** Low

### FEAT-006: Door Contribution System
**Description:** Guidelines and tooling for community door submissions
**Size:** Medium
**Priority:** Low

### FEAT-007: Domain-Specific Door Packs
**Description:** Curated bundles (Security Pack, ML Pack, etc.) for specialized use
**Size:** Medium
**Priority:** Low

---

## Validation & Launch

### VALID-001: First External User Test
**Description:** Someone outside your machine successfully uses PhiSHRI MCP
**Size:** Small
**Priority:** Critical

### VALID-002: MCP Integration Guide Finalized
**Description:** Polish and verify MCP_INTEGRATION_GUIDE.md accuracy
**Size:** Small
**Priority:** High

### VALID-003: README Update Post-500
**Description:** Update door counts and status after hitting 500
**Size:** Small
**Priority:** Medium

### VALID-004: crates.io Publication
**Description:** Publish phishri-mcp to crates.io for easy installation
**Size:** Medium
**Priority:** Medium

---

## Branding & Marketing

### BRAND-001: Icon Design
**Description:** Phi (Φ) with radial spokes, tesseract-inspired depth
**Size:** Small
**Priority:** Low

### BRAND-002: Custom Domain Email
**Description:** contact@phishri.dev or similar for professional outreach
**Size:** Small
**Priority:** Low

### BRAND-003: Landing Page
**Description:** Simple site explaining PhiSHRI value proposition
**Size:** Medium
**Priority:** Low

---

## Technical Debt

### TECH-001: Fuzzy Search Integration
**Description:** Integrate fuzzy-matcher crate for better phishri_find_door
**Size:** Small
**Priority:** Medium

### TECH-002: File Watcher Integration
**Description:** Integrate notify crate for live index updates when doors change
**Size:** Medium
**Priority:** Low

### TECH-003: Test Suite for MCP
**Description:** assert_cmd based tests for stdio MCP server
**Size:** Medium
**Priority:** Medium

---

**Total Items: 28**

Copy each ### heading as a separate backlog item.
