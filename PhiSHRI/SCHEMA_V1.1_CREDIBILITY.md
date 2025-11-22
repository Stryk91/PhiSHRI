# PhiSHRI Door Schema v1.1 - Credibility Update

## New Fields Added

### `verification` block
Tracks credibility status and source attribution.

```json
{
  "door_code": "T50PROMETHEUS",
  "semantic_path": "TOOLS.OBSERVABILITY.PROMETHEUS",
  "aliases": ["prometheus", "promql", "prom"],

  "context_bundle": {
    "summary": "...",
    "prerequisites": [],
    "related_doors": [],
    "onboarding": {
      "quick_start": "...",
      "common_patterns": [],
      "known_errors": []
    }
  },

  "verification": {
    "status": "verified",
    "verified_by": "STRYK",
    "verified_date": "2025-11-21",
    "sources": [
      {
        "title": "Prometheus Official Documentation",
        "url": "https://prometheus.io/docs/prometheus/latest/querying/basics/",
        "accessed": "2025-11-21"
      },
      {
        "title": "Prometheus GitHub Repository",
        "url": "https://github.com/prometheus/prometheus",
        "accessed": "2025-11-21"
      }
    ],
    "tested_versions": [
      "Prometheus 2.45+",
      "Grafana 10.0+"
    ],
    "confidence_score": 0.95,
    "last_audit": "2025-11-21",
    "audit_notes": "Commands verified against official docs. PromQL examples tested."
  },

  "metadata": {
    "last_updated": "2025-11-21T00:00:00Z",
    "version": "1.1.0",
    "category": "TOOLS",
    "subcategory": "OBSERVABILITY",
    "tags": ["prometheus", "monitoring", "metrics"]
  }
}
```

## Field Definitions

### verification.status
| Value | Meaning |
|-------|---------|
| `unverified` | AI-generated, not yet audited |
| `verified` | Manually checked against sources |
| `community_verified` | Verified by community contributor |
| `outdated` | Was verified but sources have updated |
| `disputed` | Has reported inaccuracies |

### verification.sources
Array of source objects:
```json
{
  "title": "Human-readable name",
  "url": "https://official-docs.com/page",
  "accessed": "2025-11-21",
  "section": "Optional - specific section referenced"
}
```

### verification.tested_versions
Array of specific versions this door's content was tested against:
```json
"tested_versions": [
  "Kubernetes 1.29",
  "Docker 24.0",
  "Ubuntu 22.04"
]
```

### verification.confidence_score
Float 0.0 - 1.0:
| Score | Meaning |
|-------|---------|
| 0.0-0.5 | AI-generated, no verification |
| 0.5-0.7 | Partially verified |
| 0.7-0.9 | Verified against docs |
| 0.9-1.0 | Tested in production |

### verification.audit_notes
Free text for auditor notes:
- What was checked
- Any caveats
- Known limitations

## Migration Path

### Existing doors (v1.0)
Add default verification block:
```json
"verification": {
  "status": "unverified",
  "verified_by": null,
  "verified_date": null,
  "sources": [],
  "tested_versions": [],
  "confidence_score": 0.5,
  "last_audit": null,
  "audit_notes": "AI-generated content, pending verification"
}
```

### New doors (v1.1+)
Require at minimum:
- `status`: "unverified" (default) or higher
- `sources`: At least empty array
- `tested_versions`: At least empty array

## Keymaster Tasks

1. **Batch update existing 417 doors**
   - Add `verification` block with `status: "unverified"`
   - Set `confidence_score: 0.5`
   - Add `audit_notes: "AI-generated, pending verification"`

2. **Priority verification queue**
   - Start with most-referenced doors (high prerequisite count)
   - Focus on T30-T79 (DevOps tools) - high enterprise value
   - Security doors (S##) - credibility critical

3. **Source collection**
   - For each verified door, add 1-3 official doc links
   - Prefer: official docs > GitHub repos > blog posts > Stack Overflow

4. **Ongoing process**
   - New AI-generated doors start as `unverified`
   - Weekly verification sprint: 10-20 doors
   - Track verification % as quality metric

## Quality Metrics

Track in INDEX.json or separate METRICS.json:
```json
{
  "total_doors": 417,
  "verified_doors": 0,
  "verification_percentage": 0.0,
  "average_confidence": 0.5,
  "doors_with_sources": 0,
  "outdated_doors": 0
}
```

Target: 50% verified by v1.0 release, 80% by v2.0.
