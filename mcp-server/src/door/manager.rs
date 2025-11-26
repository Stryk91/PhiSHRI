//! Door Manager
//!
//! High-level operations on doors: reading, searching, chain loading, creation, validation.

use crate::config::Config;
use crate::door::loader::{DoorLoader, LoaderError};
use crate::door::schema::{Door, ContextBundle, Metadata, Onboarding, Resources};
use chrono::Utc;
use std::collections::{HashMap, HashSet};
use std::fs;
use std::path::PathBuf;

/// Door manager for high-level operations
pub struct DoorManager {
    loader: DoorLoader,
    config: Config,
}

impl DoorManager {
    /// Create a new door manager
    pub fn new(config: Config) -> Self {
        let loader = DoorLoader::new(config.clone());
        Self { loader, config }
    }

    /// Read a single door by code
    pub fn read_door(&self, door_code: &str) -> Result<Door, LoaderError> {
        self.loader.load_door(door_code)
    }

    /// List doors, optionally filtered
    pub fn list_doors(&self, category: Option<&str>, limit: usize) -> Result<Vec<DoorListItem>, LoaderError> {
        let doors = self.loader.list_doors(category, limit)?;

        let mut items = Vec::new();
        for (short_code, full_code) in doors {
            // Try to load just enough to get the summary
            let summary = if let Ok(door) = self.loader.load_door(&full_code) {
                door.context_bundle.summary.lines().next().unwrap_or("").to_string()
            } else {
                String::new()
            };

            items.push(DoorListItem {
                short_code,
                full_code,
                summary,
            });
        }

        Ok(items)
    }

    /// Load a chain of doors with prerequisite resolution
    pub fn load_chain(&self, door_codes: &[String], include_prerequisites: bool) -> Result<ChainResult, LoaderError> {
        let mut loaded_codes: Vec<String> = Vec::new();
        let mut loaded_doors: Vec<Door> = Vec::new();
        let mut seen: HashSet<String> = HashSet::new();

        // Queue for processing (door_code, is_prerequisite)
        let mut queue: Vec<(String, bool)> = door_codes.iter().map(|c| (c.clone(), false)).collect();

        while let Some((code, is_prereq)) = queue.pop() {
            let normalized = code.to_uppercase();

            if seen.contains(&normalized) {
                continue;
            }

            let door = self.loader.load_door(&normalized)?;
            seen.insert(normalized.clone());

            // Add prerequisites to queue first (they should be loaded before this door)
            if include_prerequisites {
                for prereq in &door.context_bundle.prerequisites {
                    let prereq_normalized = prereq.to_uppercase();
                    if !seen.contains(&prereq_normalized) {
                        queue.push((prereq.clone(), true));
                    }
                }
            }

            loaded_codes.push(normalized);
            loaded_doors.push(door);
        }

        // Reverse to get prerequisites first
        loaded_codes.reverse();
        loaded_doors.reverse();

        Ok(ChainResult {
            doors: loaded_doors,
            order: loaded_codes,
            prerequisites_added: include_prerequisites,
        })
    }

    /// Get prerequisites for a door (recursive)
    pub fn get_prerequisites(&self, door_code: &str) -> Result<Vec<String>, LoaderError> {
        let mut prereqs: Vec<String> = Vec::new();
        let mut seen: HashSet<String> = HashSet::new();

        self.collect_prerequisites(door_code, &mut prereqs, &mut seen)?;

        Ok(prereqs)
    }

    /// Recursively collect prerequisites
    fn collect_prerequisites(
        &self,
        door_code: &str,
        prereqs: &mut Vec<String>,
        seen: &mut HashSet<String>,
    ) -> Result<(), LoaderError> {
        let normalized = door_code.to_uppercase();

        if seen.contains(&normalized) {
            return Ok(());
        }
        seen.insert(normalized.clone());

        // Gracefully handle missing doors
        let door = match self.loader.load_door(&normalized) {
            Ok(d) => d,
            Err(_) => {
                prereqs.push(format!("{}[MISSING]", normalized));
                return Ok(());
            }
        };

        for prereq in &door.context_bundle.prerequisites {
            // Don't fail on missing prereqs, just mark them
            let _ = self.collect_prerequisites(prereq, prereqs, seen);
        }

        prereqs.push(normalized);

        Ok(())
    }

    /// Rebuild indexes from door files
    pub fn rebuild_indexes(&self) -> Result<RebuildResult, LoaderError> {
        let hash_table = self.loader.scan_doors()?;
        let count = hash_table.len();

        let hash_path = self.config.hash_table_path();
        if let Some(parent) = hash_path.parent() {
            fs::create_dir_all(parent)?;
        }

        let json = serde_json::to_string_pretty(&hash_table)?;
        fs::write(&hash_path, json)?;

        self.loader.clear_cache();

        Ok(RebuildResult {
            doors_indexed: count,
            hash_table_path: hash_path.display().to_string(),
        })
    }

    /// Create a new door
    pub fn create_door(&self, params: CreateDoorParams) -> Result<CreateResult, LoaderError> {
        if params.door_code.is_empty() {
            return Err(LoaderError::InvalidDoor("door_code cannot be empty".to_string()));
        }

        if self.loader.load_door(&params.door_code).is_ok() {
            return Err(LoaderError::InvalidDoor(format!("Door {} already exists", params.door_code)));
        }

        let door = Door {
            door_code: params.door_code.clone(),
            semantic_path: params.semantic_path.clone(),
            aliases: params.aliases.clone(),
            context_bundle: ContextBundle {
                summary: params.summary.clone(),
                prerequisites: params.prerequisites.clone(),
                related_doors: params.related_doors.clone(),
                onboarding: Some(Onboarding {
                    quick_start: params.quick_start.clone(),
                    full_context_path: String::new(),
                    common_patterns: params.common_patterns.clone(),
                    known_errors: params.known_errors.iter().map(|s| serde_json::Value::String(s.clone())).collect(),
                }),
                resources: Some(Resources {
                    docs: vec![], code: vec![], tests: vec![], errors: vec![],
                }),
                metadata: Some(Metadata {
                    last_updated: Utc::now().to_rfc3339(),
                    confidence: 1.0,
                    tags: params.tags.clone(),
                    category: params.category.clone(),
                    subcategory: params.semantic_path.split('.').nth(1).unwrap_or("").to_string(),
                    version: "1.0.0".to_string(),
                    agent_affinity: params.agent_affinity.clone(),
                }),
            },
        };

        let file_path = self.get_door_file_path(&params.category, &params.door_code);
        if let Some(parent) = file_path.parent() {
            fs::create_dir_all(parent)?;
        }

        let json = serde_json::to_string_pretty(&door)?;
        fs::write(&file_path, &json)?;

        self.loader.clear_cache();
        let _ = self.rebuild_indexes();

        Ok(CreateResult {
            door_code: params.door_code,
            file_path: file_path.display().to_string(),
            validated: true,
        })
    }

    fn get_door_file_path(&self, category: &str, door_code: &str) -> PathBuf {
        self.config.contexts_path().join(category.to_uppercase()).join(format!("{}.json", door_code))
    }

    /// Validate a door
    pub fn validate_door(&self, door_code: Option<&str>, file_path: Option<&str>) -> ValidationResult {
        let mut result = ValidationResult::default();

        let door = if let Some(code) = door_code {
            match self.loader.load_door(code) {
                Ok(d) => { result.door_code = Some(code.to_string()); d }
                Err(e) => { result.errors.push(format!("Failed to load: {}", e)); return result; }
            }
        } else if let Some(path) = file_path {
            match self.loader.load_door_file(&PathBuf::from(path)) {
                Ok(d) => { result.file_path = Some(path.to_string()); d }
                Err(e) => { result.errors.push(format!("Failed to load: {}", e)); return result; }
            }
        } else {
            result.errors.push("Must provide door_code or file_path".to_string());
            return result;
        };

        result.door_code = Some(door.door_code.clone());
        if door.door_code.is_empty() { result.errors.push("door_code is empty".to_string()); }
        if door.context_bundle.summary.is_empty() { result.warnings.push("summary is empty".to_string()); }

        for prereq in &door.context_bundle.prerequisites {
            if self.loader.load_door(prereq).is_err() {
                result.warnings.push(format!("Prerequisite not found: {}", prereq));
                result.missing_prerequisites.push(prereq.clone());
            }
        }

        for related in &door.context_bundle.related_doors {
            if self.loader.load_door(related).is_err() {
                result.warnings.push(format!("Related door not found: {}", related));
                result.broken_references.push(related.clone());
            }
        }

        if door.context_bundle.metadata.is_none() { result.warnings.push("metadata missing".to_string()); }
        result.valid = result.errors.is_empty();
        result
    }

    /// Batch create doors
    pub fn batch_create(&self, doors: Vec<CreateDoorParams>, validate: bool, update_indexes: bool) -> BatchCreateResult {
        let mut result = BatchCreateResult::default();

        if validate {
            for params in &doors {
                if params.door_code.is_empty() { result.errors.push("Empty door_code".to_string()); }
                if self.loader.load_door(&params.door_code).is_ok() {
                    result.errors.push(format!("Door {} exists", params.door_code));
                }
            }
            if !result.errors.is_empty() { return result; }
        }

        let mut created_files: Vec<PathBuf> = Vec::new();

        for params in doors {
            let file_path = self.get_door_file_path(&params.category, &params.door_code);

            let door = Door {
                door_code: params.door_code.clone(),
                semantic_path: params.semantic_path.clone(),
                aliases: params.aliases,
                context_bundle: ContextBundle {
                    summary: params.summary,
                    prerequisites: params.prerequisites,
                    related_doors: params.related_doors,
                    onboarding: Some(Onboarding {
                        quick_start: params.quick_start,
                        full_context_path: String::new(),
                        common_patterns: params.common_patterns,
                        known_errors: params.known_errors.iter().map(|s| serde_json::Value::String(s.clone())).collect(),
                    }),
                    resources: Some(Resources { docs: vec![], code: vec![], tests: vec![], errors: vec![] }),
                    metadata: Some(Metadata {
                        last_updated: Utc::now().to_rfc3339(),
                        confidence: 1.0,
                        tags: params.tags,
                        category: params.category.clone(),
                        subcategory: params.semantic_path.split('.').nth(1).unwrap_or("").to_string(),
                        version: "1.0.0".to_string(),
                        agent_affinity: params.agent_affinity,
                    }),
                },
            };

            if let Some(parent) = file_path.parent() {
                if let Err(e) = fs::create_dir_all(parent) {
                    for f in &created_files { let _ = fs::remove_file(f); }
                    result.errors.push(format!("Dir error: {}", e));
                    return result;
                }
            }

            match serde_json::to_string_pretty(&door) {
                Ok(json) => {
                    if let Err(e) = fs::write(&file_path, &json) {
                        for f in &created_files { let _ = fs::remove_file(f); }
                        result.errors.push(format!("Write error: {}", e));
                        return result;
                    }
                    created_files.push(file_path);
                    result.created.push(params.door_code);
                }
                Err(e) => {
                    for f in &created_files { let _ = fs::remove_file(f); }
                    result.errors.push(format!("JSON error: {}", e));
                    return result;
                }
            }
        }

        if update_indexes && !result.created.is_empty() {
            self.loader.clear_cache();
            if let Ok(r) = self.rebuild_indexes() { result.indexes_updated = true; result.total_doors = r.doors_indexed; }
        }

        result.success = result.errors.is_empty();
        result
    }

    /// Run system audit
    pub fn audit(&self, scope: Option<&str>) -> AuditResult {
        let mut result = AuditResult::default();

        let hash_table = match self.loader.scan_doors() {
            Ok(ht) => ht,
            Err(e) => { result.errors.push(format!("Scan failed: {}", e)); return result; }
        };

        result.total_doors = hash_table.len();
        let mut all_codes: HashSet<String> = HashSet::new();
        let mut referenced_prereqs: HashSet<String> = HashSet::new();
        let mut referenced_related: HashSet<String> = HashSet::new();

        for (code, entry) in &hash_table {
            if let Some(s) = scope {
                if s != "all" && !entry.category.eq_ignore_ascii_case(s) && code != s { continue; }
            }

            all_codes.insert(code.clone());

            if let Ok(door) = self.loader.load_door(code) {
                if door.context_bundle.summary.is_empty() { result.warnings.push(format!("{}: empty summary", code)); }
                for prereq in &door.context_bundle.prerequisites { referenced_prereqs.insert(prereq.to_uppercase()); }
                for related in &door.context_bundle.related_doors { referenced_related.insert(related.to_uppercase()); }
                if door.context_bundle.metadata.is_none() { result.warnings.push(format!("{}: no metadata", code)); }
            } else {
                result.errors.push(format!("{}: load failed", code));
            }
        }

        for prereq in &referenced_prereqs {
            if !all_codes.contains(prereq) { result.missing_prerequisites.push(prereq.clone()); }
        }
        for related in &referenced_related {
            if !all_codes.contains(related) { result.broken_references.push(related.clone()); }
        }

        for (_, entry) in &hash_table {
            *result.by_category.entry(entry.category.clone()).or_insert(0) += 1;
        }

        result.healthy = result.errors.is_empty() && result.missing_prerequisites.is_empty();
        result
    }

    /// Get statistics
    pub fn stats(&self, granularity: &str) -> StatsResult {
        let mut result = StatsResult::default();

        let hash_table = match self.loader.scan_doors() { Ok(ht) => ht, Err(_) => return result };

        result.total_doors = hash_table.len();
        for (_, entry) in &hash_table { *result.by_category.entry(entry.category.clone()).or_insert(0) += 1; }

        result.index_path = self.config.hash_table_path().display().to_string();
        result.index_exists = self.config.hash_table_path().exists();

        if granularity == "detailed" {
            for (code, _) in &hash_table {
                if let Ok(door) = self.loader.load_door(code) {
                    if !door.context_bundle.prerequisites.is_empty() { result.doors_with_prerequisites += 1; }
                    if let Some(ref meta) = door.context_bundle.metadata {
                        for tag in &meta.tags { *result.tag_counts.entry(tag.clone()).or_insert(0) += 1; }
                    }
                }
            }
        }
        result
    }

    /// Get reference to config
    pub fn config(&self) -> &Config {
        &self.config
    }
}

// ============================================================================
// Parameter and Result Types
// ============================================================================

/// Parameters for creating a door
#[derive(Debug, Clone, Default)]
pub struct CreateDoorParams {
    pub door_code: String,
    pub category: String,
    pub semantic_path: String,
    pub summary: String,
    pub aliases: Vec<String>,
    pub prerequisites: Vec<String>,
    pub related_doors: Vec<String>,
    pub quick_start: String,
    pub common_patterns: Vec<String>,
    pub known_errors: Vec<String>,
    pub tags: Vec<String>,
    pub agent_affinity: Vec<String>,
}

/// Result of creating a door
#[derive(Debug, Clone)]
pub struct CreateResult {
    pub door_code: String,
    pub file_path: String,
    pub validated: bool,
}

/// Result of validating a door
#[derive(Debug, Clone, Default)]
pub struct ValidationResult {
    pub valid: bool,
    pub door_code: Option<String>,
    pub file_path: Option<String>,
    pub errors: Vec<String>,
    pub warnings: Vec<String>,
    pub missing_prerequisites: Vec<String>,
    pub broken_references: Vec<String>,
}

/// Result of batch creation
#[derive(Debug, Clone, Default)]
pub struct BatchCreateResult {
    pub success: bool,
    pub created: Vec<String>,
    pub errors: Vec<String>,
    pub indexes_updated: bool,
    pub total_doors: usize,
}

/// Result of system audit
#[derive(Debug, Clone, Default)]
pub struct AuditResult {
    pub healthy: bool,
    pub total_doors: usize,
    pub errors: Vec<String>,
    pub warnings: Vec<String>,
    pub missing_prerequisites: Vec<String>,
    pub broken_references: Vec<String>,
    pub by_category: HashMap<String, usize>,
}

/// Result of stats query
#[derive(Debug, Clone, Default)]
pub struct StatsResult {
    pub total_doors: usize,
    pub by_category: HashMap<String, usize>,
    pub index_path: String,
    pub index_exists: bool,
    pub doors_with_prerequisites: usize,
    pub tag_counts: HashMap<String, usize>,
}

/// Door list item for display
#[derive(Debug, Clone)]
pub struct DoorListItem {
    pub short_code: String,
    pub full_code: String,
    pub summary: String,
}

impl DoorListItem {
    pub fn to_line(&self) -> String {
        if self.summary.is_empty() {
            format!("{} ({})", self.short_code, self.full_code)
        } else {
            let truncated = if self.summary.len() > 60 {
                format!("{}...", &self.summary[..57])
            } else {
                self.summary.clone()
            };
            format!("{}: {}", self.short_code, truncated)
        }
    }
}

/// Result of loading a door chain
#[derive(Debug)]
pub struct ChainResult {
    pub doors: Vec<Door>,
    pub order: Vec<String>,
    pub prerequisites_added: bool,
}

impl ChainResult {
    pub fn to_text(&self) -> String {
        let mut output = String::new();

        output.push_str(&format!(
            "# Door Chain ({} doors)\n\n",
            self.doors.len()
        ));

        if self.prerequisites_added {
            output.push_str("*Prerequisites automatically included*\n\n");
        }

        output.push_str("## Load Order\n");
        for (i, code) in self.order.iter().enumerate() {
            output.push_str(&format!("{}. {}\n", i + 1, code));
        }
        output.push('\n');

        output.push_str("---\n\n");

        for door in &self.doors {
            output.push_str(&door.full_text());
            output.push_str("\n---\n\n");
        }

        output
    }
}

/// Result of rebuilding indexes
#[derive(Debug)]
pub struct RebuildResult {
    pub doors_indexed: usize,
    pub hash_table_path: String,
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_door_list_item_to_line() {
        let item = DoorListItem {
            short_code: "D05".to_string(),
            full_code: "D05SILENT_INSTALL".to_string(),
            summary: "Silent installation patterns".to_string(),
        };

        let line = item.to_line();
        assert!(line.contains("D05"));
        assert!(line.contains("Silent"));
    }
}
