//! Door File Loader
//!
//! Handles loading door JSON files from disk with caching.

use crate::config::Config;
use crate::door::schema::{Door, HashTable, HashTableEntry};
use std::collections::HashMap;
use std::fs;
use std::path::{Path, PathBuf};
use std::sync::RwLock;
use std::time::{Duration, Instant};
use thiserror::Error;

/// Door loading errors
#[derive(Debug, Error)]
pub enum LoaderError {
    #[error("Door not found: {0}")]
    DoorNotFound(String),

    #[error("Index not found: {0}")]
    IndexNotFound(String),

    #[error("IO error: {0}")]
    IoError(#[from] std::io::Error),

    #[error("JSON parse error: {0}")]
    ParseError(#[from] serde_json::Error),

    #[error("Invalid door file: {0}")]
    InvalidDoor(String),
}

/// Cached door entry
struct CachedDoor {
    door: Door,
    loaded_at: Instant,
}

/// Door loader with caching
pub struct DoorLoader {
    config: Config,
    hash_table: RwLock<Option<HashTable>>,
    door_cache: RwLock<HashMap<String, CachedDoor>>,
    cache_ttl: Duration,
}

impl DoorLoader {
    /// Create a new door loader
    pub fn new(config: Config) -> Self {
        Self {
            config,
            hash_table: RwLock::new(None),
            door_cache: RwLock::new(HashMap::new()),
            cache_ttl: Duration::from_secs(300), // 5 minute cache
        }
    }

    /// Load and cache the hash table index
    pub fn load_hash_table(&self) -> Result<HashTable, LoaderError> {
        // Check if already loaded
        {
            let guard = self.hash_table.read().unwrap();
            if let Some(ref table) = *guard {
                return Ok(table.clone());
            }
        }

        // Load from file
        let path = self.config.hash_table_path();
        if !path.exists() {
            return Err(LoaderError::IndexNotFound(path.display().to_string()));
        }

        let content = fs::read_to_string(&path)?;
        
        // Try parsing as wrapped format first (with version/mappings)
        let table: HashTable = if let Ok(wrapped) = serde_json::from_str::<serde_json::Value>(&content) {
            if let Some(mappings) = wrapped.get("mappings") {
                // New format: { "version": "...", "mappings": { "CODE": "path" } }
                let mut table = HashMap::new();
                if let Some(obj) = mappings.as_object() {
                    for (code, value) in obj {
                        let file_path = value.as_str().unwrap_or("").to_string();
                        let category = Self::category_from_path(&file_path);
                        let short_code = Self::extract_short_code(code);
                        table.insert(code.clone(), HashTableEntry {
                            door_code: code.clone(),
                            file_path,
                            category,
                            short_code,
                        });
                    }
                }
                table
            } else {
                // Old flat format
                serde_json::from_str(&content)?
            }
        } else {
            serde_json::from_str(&content)?
        };

        // Cache it
        {
            let mut guard = self.hash_table.write().unwrap();
            *guard = Some(table.clone());
        }

        Ok(table)
    }
    
    /// Extract category from file path
    fn category_from_path(path: &str) -> String {
        if path.contains("/TOOLS/") || path.contains("\\TOOLS\\") { "TOOLS".to_string() }
        else if path.contains("/WORKFLOWS/") || path.contains("\\WORKFLOWS\\") { "WORKFLOWS".to_string() }
        else if path.contains("/SECURITY/") || path.contains("\\SECURITY\\") { "SECURITY".to_string() }
        else if path.contains("/ARCHITECTURE/") || path.contains("\\ARCHITECTURE\\") { "ARCHITECTURE".to_string() }
        else if path.contains("/AGENTS/") || path.contains("\\AGENTS\\") { "AGENTS".to_string() }
        else if path.contains("/PROJECTS/") || path.contains("\\PROJECTS\\") { "PROJECTS".to_string() }
        else if path.contains("/ERRORS/") || path.contains("\\ERRORS\\") { "ERRORS".to_string() }
        else { "UNKNOWN".to_string() }
    }
    
    /// Extract short code (e.g., "D05" from "D05SILENT_INSTALL")
    fn extract_short_code(code: &str) -> String {
        let mut short = String::new();
        for c in code.chars() {
            if c.is_ascii_alphabetic() || c.is_ascii_digit() {
                short.push(c);
                if short.len() >= 2 && short.chars().last().map(|c| c.is_ascii_digit()).unwrap_or(false) {
                    // Check if next char would be non-digit (end of short code)
                    let remaining: String = code.chars().skip(short.len()).collect();
                    if remaining.chars().next().map(|c| !c.is_ascii_digit()).unwrap_or(true) {
                        break;
                    }
                }
            }
        }
        short
    }

    /// Resolve a door code to its file path
    pub fn resolve_door_path(&self, door_code: &str) -> Result<PathBuf, LoaderError> {
        let hash_table = self.load_hash_table()?;

        // Normalize the door code (uppercase, handle short codes)
        let normalized = normalize_door_code(door_code);

        // Try exact match first
        if let Some(entry) = hash_table.get(&normalized) {
            return Ok(self.config.phishri_path.join(&entry.file_path));
        }

        // Try short code match (e.g., "D05" matches "D05SILENT_INSTALL")
        for (code, entry) in &hash_table {
            if code.starts_with(&normalized) || entry.short_code == normalized {
                return Ok(self.config.phishri_path.join(&entry.file_path));
            }
        }

        Err(LoaderError::DoorNotFound(door_code.to_string()))
    }

    /// Load a door by code
    pub fn load_door(&self, door_code: &str) -> Result<Door, LoaderError> {
        let normalized = normalize_door_code(door_code);

        // Check cache
        {
            let cache = self.door_cache.read().unwrap();
            if let Some(cached) = cache.get(&normalized) {
                if cached.loaded_at.elapsed() < self.cache_ttl {
                    return Ok(cached.door.clone());
                }
            }
        }

        // Load from file
        let path = self.resolve_door_path(&normalized)?;
        let door = self.load_door_file(&path)?;

        // Cache it
        {
            let mut cache = self.door_cache.write().unwrap();
            cache.insert(normalized, CachedDoor {
                door: door.clone(),
                loaded_at: Instant::now(),
            });
        }

        Ok(door)
    }

    /// Load door directly from file path
    pub fn load_door_file(&self, path: &Path) -> Result<Door, LoaderError> {
        if !path.exists() {
            return Err(LoaderError::DoorNotFound(path.display().to_string()));
        }

        let content = fs::read_to_string(path)?;
        let door: Door = serde_json::from_str(&content)?;

        Ok(door)
    }

    /// List all doors, optionally filtered by category
    pub fn list_doors(&self, category: Option<&str>, limit: usize) -> Result<Vec<(String, String)>, LoaderError> {
        let hash_table = self.load_hash_table()?;

        let mut doors: Vec<(String, String)> = hash_table
            .iter()
            .filter(|(_, entry)| {
                if let Some(cat) = category {
                    entry.category.eq_ignore_ascii_case(cat)
                } else {
                    true
                }
            })
            .map(|(code, entry)| {
                let short = if entry.short_code.is_empty() {
                    code.clone()
                } else {
                    entry.short_code.clone()
                };
                (short, code.clone())
            })
            .collect();

        // Sort by short code
        doors.sort_by(|a, b| a.0.cmp(&b.0));

        // Apply limit
        doors.truncate(limit);

        Ok(doors)
    }

    /// Load multiple doors
    pub fn load_doors(&self, door_codes: &[String]) -> Result<Vec<Door>, LoaderError> {
        let mut doors = Vec::new();
        for code in door_codes {
            doors.push(self.load_door(code)?);
        }
        Ok(doors)
    }

    /// Clear the cache
    pub fn clear_cache(&self) {
        {
            let mut cache = self.door_cache.write().unwrap();
            cache.clear();
        }
        {
            let mut table = self.hash_table.write().unwrap();
            *table = None;
        }
    }

    /// Scan contexts directory and build hash table
    pub fn scan_doors(&self) -> Result<HashTable, LoaderError> {
        let contexts_path = self.config.contexts_path();
        if !contexts_path.exists() {
            return Err(LoaderError::IndexNotFound(contexts_path.display().to_string()));
        }

        let mut hash_table = HashMap::new();

        // Scan each category directory
        let categories = ["SECURITY", "WORKFLOWS", "ARCHITECTURE", "TOOLS", "AGENTS", "PROJECTS", "ERRORS", "LANGUAGES"];

        for category in &categories {
            let cat_path = contexts_path.join(category);
            if cat_path.exists() {
                self.scan_directory(&cat_path, category, &mut hash_table)?;
            }
        }

        Ok(hash_table)
    }

    /// Scan a single directory for door files
    fn scan_directory(&self, dir: &Path, category: &str, hash_table: &mut HashTable) -> Result<(), LoaderError> {
        for entry in fs::read_dir(dir)? {
            let entry = entry?;
            let path = entry.path();

            if path.is_file() && path.extension().map_or(false, |e| e == "json") {
                if let Ok(door) = self.load_door_file(&path) {
                    let relative_path = path
                        .strip_prefix(&self.config.phishri_path)
                        .unwrap_or(&path)
                        .to_string_lossy()
                        .to_string();

                    hash_table.insert(door.door_code.clone(), HashTableEntry {
                        door_code: door.door_code.clone(),
                        file_path: relative_path,
                        category: category.to_string(),
                        short_code: door.short_code().to_string(),
                    });
                }
            }
        }

        Ok(())
    }
}

/// Normalize door code for consistent lookup
fn normalize_door_code(code: &str) -> String {
    code.trim().to_uppercase()
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_normalize_door_code() {
        assert_eq!(normalize_door_code("d05"), "D05");
        assert_eq!(normalize_door_code("  D05  "), "D05");
        assert_eq!(normalize_door_code("D05SILENT_INSTALL"), "D05SILENT_INSTALL");
    }
}
