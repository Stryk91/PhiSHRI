//! PhiSHRI MCP Tool Definitions
//!
//! Defines all 15 MCP tools with their schemas for the tools/list response.

use crate::mcp::protocol::ToolDefinition;
use serde_json::json;

/// Get all PhiSHRI tool definitions
pub fn get_tool_definitions() -> Vec<ToolDefinition> {
    vec![
        // Core Door Operations (4 tools)
        tool_read_door(),
        tool_list_doors(),
        tool_find_door(),
        tool_load_chain(),
        // Door Creation & Validation (3 tools) - NEW
        tool_create_door(),
        tool_validate_door(),
        tool_batch_create(),
        // Session State Operations (3 tools)
        tool_get_bootstrap(),
        tool_update_bootstrap(),
        tool_session_checkpoint(),
        // Index Operations (3 tools)
        tool_search_semantic(),
        tool_get_prerequisites(),
        tool_rebuild_indexes(),
        // Quality & Stats (2 tools) - NEW
        tool_audit(),
        tool_stats(),
    ]
}

fn tool_read_door() -> ToolDefinition {
    ToolDefinition {
        name: "phishri_read_door".to_string(),
        description: "Read a specific door by code. Returns complete context bundle including summary, prerequisites, related doors, and resources.".to_string(),
        input_schema: json!({
            "type": "object",
            "properties": {
                "door_code": {
                    "type": "string",
                    "description": "Door code (e.g., D05, W115, S01, A01, P01, E03). Supports various prefixes: S=Security, W=Workflows, R=Architecture, T/D=Tools, A=Agents, P=Projects, E=Errors."
                }
            },
            "required": ["door_code"]
        }),
    }
}

fn tool_list_doors() -> ToolDefinition {
    ToolDefinition {
        name: "phishri_list_doors".to_string(),
        description: "List available doors in the PhiSHRI knowledge base, optionally filtered by category. Returns door codes with brief descriptions.".to_string(),
        input_schema: json!({
            "type": "object",
            "properties": {
                "category": {
                    "type": "string",
                    "description": "Filter by category: SECURITY, TOOLS, WORKFLOWS, ARCHITECTURE, AGENTS, PROJECTS, ERRORS. Leave empty for all doors.",
                    "enum": ["SECURITY", "TOOLS", "WORKFLOWS", "ARCHITECTURE", "AGENTS", "PROJECTS", "ERRORS"]
                },
                "limit": {
                    "type": "integer",
                    "description": "Maximum number of doors to return (default: 50, max: 268)",
                    "default": 50,
                    "minimum": 1,
                    "maximum": 268
                }
            }
        }),
    }
}

fn tool_find_door() -> ToolDefinition {
    ToolDefinition {
        name: "phishri_find_door".to_string(),
        description: "Search for doors using natural language query. Uses fuzzy matching against door names, aliases, tags, and descriptions. Returns matches ranked by confidence score.".to_string(),
        input_schema: json!({
            "type": "object",
            "properties": {
                "query": {
                    "type": "string",
                    "description": "Search query (e.g., 'enterprise deployment', 'silent install', 'security hardening', 'git workflow')"
                },
                "limit": {
                    "type": "integer",
                    "description": "Maximum number of results to return (default: 5)",
                    "default": 5,
                    "minimum": 1,
                    "maximum": 20
                }
            },
            "required": ["query"]
        }),
    }
}

fn tool_load_chain() -> ToolDefinition {
    ToolDefinition {
        name: "phishri_load_chain".to_string(),
        description: "Load multiple doors with automatic prerequisite resolution. Ensures doors are loaded in the correct order based on their dependency graph.".to_string(),
        input_schema: json!({
            "type": "object",
            "properties": {
                "door_codes": {
                    "type": "array",
                    "items": {
                        "type": "string"
                    },
                    "description": "Array of door codes to load (e.g., ['D05', 'D06', 'W115'])"
                },
                "include_prerequisites": {
                    "type": "boolean",
                    "description": "Automatically include and load prerequisite doors (default: true)",
                    "default": true
                }
            },
            "required": ["door_codes"]
        }),
    }
}

fn tool_get_bootstrap() -> ToolDefinition {
    ToolDefinition {
        name: "phishri_get_bootstrap".to_string(),
        description: "Get current session state from bootstrap file. Returns progress tracking, completed batches, loaded doors, and recommended next steps for session continuity.".to_string(),
        input_schema: json!({
            "type": "object",
            "properties": {}
        }),
    }
}

fn tool_update_bootstrap() -> ToolDefinition {
    ToolDefinition {
        name: "phishri_update_bootstrap".to_string(),
        description: "Update session state in bootstrap file. Use this to track progress, mark completed work, and set next steps for session continuity.".to_string(),
        input_schema: json!({
            "type": "object",
            "properties": {
                "progress": {
                    "type": "string",
                    "description": "Current progress description (e.g., 'Completed security audit phase 1')"
                },
                "batch_completed": {
                    "type": "string",
                    "description": "Description of completed batch/milestone"
                },
                "next_options": {
                    "type": "array",
                    "items": {
                        "type": "string"
                    },
                    "description": "Array of recommended next steps or door codes"
                },
                "doors_loaded": {
                    "type": "array",
                    "items": {
                        "type": "string"
                    },
                    "description": "Array of door codes loaded in this session"
                }
            }
        }),
    }
}

fn tool_session_checkpoint() -> ToolDefinition {
    ToolDefinition {
        name: "phishri_session_checkpoint".to_string(),
        description: "Create a named session checkpoint with loaded doors and notes. Enables easy resumption of complex multi-session tasks.".to_string(),
        input_schema: json!({
            "type": "object",
            "properties": {
                "checkpoint_name": {
                    "type": "string",
                    "description": "Name for this checkpoint (e.g., 'security-audit-phase1', 'deployment-prep')"
                },
                "doors_loaded": {
                    "type": "array",
                    "items": {
                        "type": "string"
                    },
                    "description": "Array of door codes that were loaded/referenced"
                },
                "notes": {
                    "type": "string",
                    "description": "Optional notes about current state or context"
                }
            },
            "required": ["checkpoint_name", "doors_loaded"]
        }),
    }
}

fn tool_search_semantic() -> ToolDefinition {
    ToolDefinition {
        name: "phishri_search_semantic".to_string(),
        description: "Search by semantic path to find doors in the knowledge hierarchy (e.g., TOOLS.DEPLOYMENT.SILENT, SECURITY.HARDENING, WORKFLOWS.GIT).".to_string(),
        input_schema: json!({
            "type": "object",
            "properties": {
                "path": {
                    "type": "string",
                    "description": "Semantic path to resolve (e.g., 'TOOLS.DEPLOYMENT.SILENT', 'SECURITY.HARDENING'). Supports partial paths."
                }
            },
            "required": ["path"]
        }),
    }
}

fn tool_get_prerequisites() -> ToolDefinition {
    ToolDefinition {
        name: "phishri_get_prerequisites".to_string(),
        description: "Get the prerequisite chain for a door - what doors should be read first. Returns ordered list based on dependency graph.".to_string(),
        input_schema: json!({
            "type": "object",
            "properties": {
                "door_code": {
                    "type": "string",
                    "description": "Door code to get prerequisites for"
                }
            },
            "required": ["door_code"]
        }),
    }
}

fn tool_rebuild_indexes() -> ToolDefinition {
    ToolDefinition {
        name: "phishri_rebuild_indexes".to_string(),
        description: "Rebuild HASH_TABLE and SEMANTIC_MAP indexes from door files. Use after adding or modifying doors to update the search indexes.".to_string(),
        input_schema: json!({
            "type": "object",
            "properties": {}
        }),
    }
}

// ============================================================================
// Door Creation & Validation Tools (NEW)
// ============================================================================

fn tool_create_door() -> ToolDefinition {
    ToolDefinition {
        name: "phishri_create_door".to_string(),
        description: "Create a new door with enforced template structure. Validates all fields and prevents malformed doors. Automatically updates indexes after creation.".to_string(),
        input_schema: json!({
            "type": "object",
            "properties": {
                "door_code": {
                    "type": "string",
                    "description": "Unique door code (e.g., 'D15NEW_FEATURE', 'S26HARDENING'). Format: PREFIX + NUMBER + DESCRIPTIVE_NAME"
                },
                "category": {
                    "type": "string",
                    "description": "Door category",
                    "enum": ["SECURITY", "TOOLS", "WORKFLOWS", "ARCHITECTURE", "AGENTS", "PROJECTS", "ERRORS"]
                },
                "semantic_path": {
                    "type": "string",
                    "description": "Semantic path in hierarchy (e.g., 'TOOLS.DEPLOYMENT.SILENT')"
                },
                "summary": {
                    "type": "string",
                    "description": "Brief summary of what this door covers (1-2 sentences)"
                },
                "aliases": {
                    "type": "array",
                    "items": {"type": "string"},
                    "description": "Alternative names/search terms for this door"
                },
                "prerequisites": {
                    "type": "array",
                    "items": {"type": "string"},
                    "description": "Door codes that should be read before this one"
                },
                "related_doors": {
                    "type": "array",
                    "items": {"type": "string"},
                    "description": "Related door codes for further exploration"
                },
                "quick_start": {
                    "type": "string",
                    "description": "Quick start instructions"
                },
                "common_patterns": {
                    "type": "array",
                    "items": {"type": "string"},
                    "description": "Common code patterns or examples"
                },
                "known_errors": {
                    "type": "array",
                    "items": {"type": "string"},
                    "description": "Known issues and gotchas"
                },
                "tags": {
                    "type": "array",
                    "items": {"type": "string"},
                    "description": "Searchable tags"
                },
                "agent_affinity": {
                    "type": "array",
                    "items": {"type": "string"},
                    "description": "Agents this door is most relevant to (e.g., ['VSCC', 'DC'])"
                }
            },
            "required": ["door_code", "category", "semantic_path", "summary"]
        }),
    }
}

fn tool_validate_door() -> ToolDefinition {
    ToolDefinition {
        name: "phishri_validate_door".to_string(),
        description: "Validate a door's structure, check prerequisites exist, verify no broken references. Use before committing new doors.".to_string(),
        input_schema: json!({
            "type": "object",
            "properties": {
                "door_code": {
                    "type": "string",
                    "description": "Door code to validate (validates existing door)"
                },
                "file_path": {
                    "type": "string",
                    "description": "Path to door JSON file to validate (alternative to door_code)"
                }
            }
        }),
    }
}

fn tool_batch_create() -> ToolDefinition {
    ToolDefinition {
        name: "phishri_batch_create".to_string(),
        description: "Create multiple doors atomically with validation. Rolls back all on any error. Updates indexes once after all doors created.".to_string(),
        input_schema: json!({
            "type": "object",
            "properties": {
                "doors": {
                    "type": "array",
                    "items": {
                        "type": "object",
                        "properties": {
                            "door_code": {"type": "string"},
                            "category": {"type": "string"},
                            "semantic_path": {"type": "string"},
                            "summary": {"type": "string"},
                            "aliases": {"type": "array", "items": {"type": "string"}},
                            "prerequisites": {"type": "array", "items": {"type": "string"}},
                            "related_doors": {"type": "array", "items": {"type": "string"}},
                            "quick_start": {"type": "string"},
                            "common_patterns": {"type": "array", "items": {"type": "string"}},
                            "known_errors": {"type": "array", "items": {"type": "string"}},
                            "tags": {"type": "array", "items": {"type": "string"}},
                            "agent_affinity": {"type": "array", "items": {"type": "string"}}
                        },
                        "required": ["door_code", "category", "semantic_path", "summary"]
                    },
                    "description": "Array of door definitions to create"
                },
                "validate": {
                    "type": "boolean",
                    "description": "Validate all doors before creating (default: true)",
                    "default": true
                },
                "update_indexes": {
                    "type": "boolean",
                    "description": "Rebuild indexes after creation (default: true)",
                    "default": true
                }
            },
            "required": ["doors"]
        }),
    }
}

fn tool_audit() -> ToolDefinition {
    ToolDefinition {
        name: "phishri_audit".to_string(),
        description: "Run system health check. Finds orphan doors, broken references, missing prerequisites, duplicate codes, and structural issues.".to_string(),
        input_schema: json!({
            "type": "object",
            "properties": {
                "scope": {
                    "type": "string",
                    "description": "Audit scope: 'all' for entire system, category name, or specific door_code",
                    "default": "all"
                },
                "fix": {
                    "type": "boolean",
                    "description": "Attempt to auto-fix issues (remove broken refs, etc). Default: false (report only)",
                    "default": false
                }
            }
        }),
    }
}

fn tool_stats() -> ToolDefinition {
    ToolDefinition {
        name: "phishri_stats".to_string(),
        description: "Get PhiSHRI statistics: door counts by category, coverage gaps, index health, and growth metrics.".to_string(),
        input_schema: json!({
            "type": "object",
            "properties": {
                "granularity": {
                    "type": "string",
                    "description": "Detail level: 'summary' (totals), 'category' (per-category), 'detailed' (full breakdown)",
                    "enum": ["summary", "category", "detailed"],
                    "default": "summary"
                }
            }
        }),
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_all_tools_defined() {
        let tools = get_tool_definitions();
        assert_eq!(tools.len(), 15);
    }

    #[test]
    fn test_tool_names() {
        let tools = get_tool_definitions();
        let names: Vec<&str> = tools.iter().map(|t| t.name.as_str()).collect();

        assert!(names.contains(&"phishri_read_door"));
        assert!(names.contains(&"phishri_list_doors"));
        assert!(names.contains(&"phishri_find_door"));
        assert!(names.contains(&"phishri_load_chain"));
        assert!(names.contains(&"phishri_get_bootstrap"));
        assert!(names.contains(&"phishri_update_bootstrap"));
        assert!(names.contains(&"phishri_session_checkpoint"));
        assert!(names.contains(&"phishri_search_semantic"));
        assert!(names.contains(&"phishri_get_prerequisites"));
        assert!(names.contains(&"phishri_rebuild_indexes"));
    }

    #[test]
    fn test_schemas_are_valid_json() {
        let tools = get_tool_definitions();
        for tool in tools {
            // Ensure schema is an object with type property
            assert!(tool.input_schema.is_object());
            assert!(tool.input_schema.get("type").is_some());
        }
    }
}
