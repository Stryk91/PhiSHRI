//! Door Schema Definitions
//!
//! Rust structs matching the PhiSHRI door JSON schema.

use serde::{Deserialize, Serialize};
use std::collections::HashMap;

/// Complete door structure as stored in JSON files
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Door {
    /// Unique door code (e.g., "D05SILENT_INSTALL")
    pub door_code: String,

    /// Semantic path in the knowledge hierarchy (e.g., "TOOLS.DEPLOYMENT.SILENT")
    #[serde(default)]
    pub semantic_path: String,

    /// Alternative names/search terms for this door
    #[serde(default)]
    pub aliases: Vec<String>,

    /// The main content bundle
    pub context_bundle: ContextBundle,
}

/// Context bundle containing all door content
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ContextBundle {
    /// Brief summary of what this door covers
    #[serde(default)]
    pub summary: String,

    /// Door codes that should be read before this one
    #[serde(default)]
    pub prerequisites: Vec<String>,

    /// Related doors for further exploration
    #[serde(default)]
    pub related_doors: Vec<String>,

    /// Onboarding/quick-start information
    #[serde(default)]
    pub onboarding: Option<Onboarding>,

    /// Resource links and references
    #[serde(default)]
    pub resources: Option<Resources>,

    /// Metadata about the door
    #[serde(default)]
    pub metadata: Option<Metadata>,
}

/// Onboarding information for quick context loading
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Onboarding {
    /// Quick start instructions
    #[serde(default)]
    pub quick_start: String,

    /// Path to full context in PhiDEX
    #[serde(default)]
    pub full_context_path: String,

    /// Common patterns/examples
    #[serde(default)]
    pub common_patterns: Vec<String>,

    /// Known errors and gotchas
    #[serde(default)]
    pub known_errors: Vec<serde_json::Value>,
}

/// Resource references
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Resources {
    /// Documentation links
    #[serde(default)]
    pub docs: Vec<String>,

    /// Code references
    #[serde(default)]
    pub code: Vec<String>,

    /// Test references
    #[serde(default)]
    pub tests: Vec<String>,

    /// Error handling references
    #[serde(default)]
    pub errors: Vec<String>,
}

/// Door metadata
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Metadata {
    /// Last update timestamp
    #[serde(default)]
    pub last_updated: String,

    /// Confidence score (0.0 - 1.0)
    #[serde(default = "default_confidence")]
    pub confidence: f64,

    /// Searchable tags
    #[serde(default)]
    pub tags: Vec<String>,

    /// Primary category (SECURITY, TOOLS, WORKFLOWS, etc.)
    #[serde(default)]
    pub category: String,

    /// Sub-category within the primary
    #[serde(default)]
    pub subcategory: String,

    /// Schema version
    #[serde(default)]
    pub version: String,

    /// Agents this door is most relevant to
    #[serde(default)]
    pub agent_affinity: Vec<String>,
}

fn default_confidence() -> f64 {
    1.0
}

impl Door {
    /// Get the short code (e.g., "D05" from "D05SILENT_INSTALL")
    pub fn short_code(&self) -> &str {
        // Extract prefix + number pattern
        let code = &self.door_code;

        // Find where the descriptive part starts (after numbers)
        let mut end = 0;
        let mut found_digit = false;

        for (i, c) in code.chars().enumerate() {
            if c.is_ascii_digit() {
                found_digit = true;
                end = i + 1;
            } else if found_digit && c.is_ascii_alphabetic() {
                break;
            } else if !found_digit {
                end = i + 1;
            }
        }

        &code[..end.min(code.len())]
    }

    /// Get category from metadata or infer from door code
    pub fn category(&self) -> &str {
        if let Some(ref meta) = self.context_bundle.metadata {
            if !meta.category.is_empty() {
                return &meta.category;
            }
        }

        // Infer from door code prefix
        let code = &self.door_code;
        if code.starts_with('S') {
            "SECURITY"
        } else if code.starts_with('W') {
            "WORKFLOWS"
        } else if code.starts_with('R') {
            "ARCHITECTURE"
        } else if code.starts_with('T') || code.starts_with('D') {
            "TOOLS"
        } else if code.starts_with('A') {
            "AGENTS"
        } else if code.starts_with('P') || code.starts_with("000") {
            "PROJECTS"
        } else if code.starts_with('E') {
            "ERRORS"
        } else {
            "UNKNOWN"
        }
    }

    /// Format door for display (summary view)
    pub fn summary_text(&self) -> String {
        let mut output = String::new();

        output.push_str(&format!("# {} ({})\n\n", self.door_code, self.short_code()));

        if !self.semantic_path.is_empty() {
            output.push_str(&format!("**Path:** {}\n\n", self.semantic_path));
        }

        if !self.context_bundle.summary.is_empty() {
            output.push_str(&format!("## Summary\n{}\n\n", self.context_bundle.summary));
        }

        if !self.aliases.is_empty() {
            output.push_str(&format!("**Aliases:** {}\n\n", self.aliases.join(", ")));
        }

        output
    }

    /// Format door for full display
    pub fn full_text(&self) -> String {
        let mut output = self.summary_text();

        // Prerequisites
        if !self.context_bundle.prerequisites.is_empty() {
            output.push_str("## Prerequisites\n");
            for prereq in &self.context_bundle.prerequisites {
                output.push_str(&format!("- {}\n", prereq));
            }
            output.push('\n');
        }

        // Related doors
        if !self.context_bundle.related_doors.is_empty() {
            output.push_str("## Related Doors\n");
            for related in &self.context_bundle.related_doors {
                output.push_str(&format!("- {}\n", related));
            }
            output.push('\n');
        }

        // Onboarding
        if let Some(ref onboard) = self.context_bundle.onboarding {
            if !onboard.quick_start.is_empty() {
                output.push_str("## Quick Start\n");
                output.push_str(&onboard.quick_start);
                output.push_str("\n\n");
            }

            if !onboard.common_patterns.is_empty() {
                output.push_str("## Common Patterns\n");
                for pattern in &onboard.common_patterns {
                    output.push_str(&format!("- `{}`\n", pattern));
                }
                output.push('\n');
            }

            if !onboard.known_errors.is_empty() {
                output.push_str("## Known Issues\n");
                for err in &onboard.known_errors {
                    // Handle both string and object formats
                    let err_text = if let Some(s) = err.as_str() {
                        s.to_string()
                    } else if let Some(obj) = err.as_object() {
                        obj.get("error").and_then(|v| v.as_str()).unwrap_or("Unknown error").to_string()
                    } else {
                        err.to_string()
                    };
                    output.push_str(&format!("- {}\n", err_text));
                }
                output.push('\n');
            }
        }

        // Resources
        if let Some(ref res) = self.context_bundle.resources {
            if !res.docs.is_empty() || !res.code.is_empty() {
                output.push_str("## Resources\n");

                if !res.docs.is_empty() {
                    output.push_str("### Documentation\n");
                    for doc in &res.docs {
                        output.push_str(&format!("- {}\n", doc));
                    }
                }

                if !res.code.is_empty() {
                    output.push_str("### Code\n");
                    for code in &res.code {
                        output.push_str(&format!("- {}\n", code));
                    }
                }
                output.push('\n');
            }
        }

        // Metadata
        if let Some(ref meta) = self.context_bundle.metadata {
            output.push_str("## Metadata\n");
            output.push_str(&format!("- **Category:** {}\n", meta.category));
            if !meta.subcategory.is_empty() {
                output.push_str(&format!("- **Subcategory:** {}\n", meta.subcategory));
            }
            if !meta.tags.is_empty() {
                output.push_str(&format!("- **Tags:** {}\n", meta.tags.join(", ")));
            }
            if !meta.agent_affinity.is_empty() {
                output.push_str(&format!("- **Agent Affinity:** {}\n", meta.agent_affinity.join(", ")));
            }
            output.push_str(&format!("- **Confidence:** {:.0}%\n", meta.confidence * 100.0));
            if !meta.last_updated.is_empty() {
                output.push_str(&format!("- **Updated:** {}\n", meta.last_updated));
            }
        }

        output
    }
}

/// Hash table entry mapping door_code to file path
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct HashTableEntry {
    pub door_code: String,
    pub file_path: String,
    #[serde(default)]
    pub category: String,
    #[serde(default)]
    pub short_code: String,
}

/// Semantic map entry mapping aliases/paths to door codes
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SemanticMapEntry {
    pub key: String,
    pub door_code: String,
    #[serde(default)]
    pub match_type: String, // "alias", "path", "tag"
}

/// Hash table index structure
pub type HashTable = HashMap<String, HashTableEntry>;

/// Semantic map index structure
pub type SemanticMap = HashMap<String, Vec<String>>; // key -> [door_codes]

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_short_code_extraction() {
        let door = Door {
            door_code: "D05SILENT_INSTALL".to_string(),
            semantic_path: String::new(),
            aliases: vec![],
            context_bundle: ContextBundle {
                summary: String::new(),
                prerequisites: vec![],
                related_doors: vec![],
                onboarding: None,
                resources: None,
                metadata: None,
            },
        };

        assert_eq!(door.short_code(), "D05");
    }

    #[test]
    fn test_category_inference() {
        let make_door = |code: &str| Door {
            door_code: code.to_string(),
            semantic_path: String::new(),
            aliases: vec![],
            context_bundle: ContextBundle {
                summary: String::new(),
                prerequisites: vec![],
                related_doors: vec![],
                onboarding: None,
                resources: None,
                metadata: None,
            },
        };

        assert_eq!(make_door("S01HARDENING").category(), "SECURITY");
        assert_eq!(make_door("W115GIT").category(), "WORKFLOWS");
        assert_eq!(make_door("T01WIX").category(), "TOOLS");
        assert_eq!(make_door("A01VSCC").category(), "AGENTS");
    }
}
