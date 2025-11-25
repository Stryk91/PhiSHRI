//! Configuration Management
//!
//! Handles path resolution and configuration for PhiSHRI.
//!
//! ## Multi-Agent Session Isolation
//!
//! PhiSHRI supports multiple agents with isolated sessions:
//! ```
//! ~/.phishri/
//! ├── sessions/
//! │   ├── {agent_id}_{session_id}/
//! │   │   ├── bootstrap.json
//! │   │   └── checkpoints/
//! │   └── {agent_id}_{session_id}/
//! │       └── bootstrap.json
//! └── shared/
//!     └── indexes/  (read-only, shared across agents)
//! ```

use std::env;
use std::fs;
use std::path::PathBuf;

/// PhiSHRI configuration
#[derive(Debug, Clone)]
pub struct Config {
    /// Path to PhiSHRI root directory (knowledge base)
    pub phishri_path: PathBuf,
    /// Path to session storage root (~/.phishri)
    pub session_root: PathBuf,
    /// Current agent identifier
    pub agent_id: String,
    /// Current session identifier
    pub session_id: String,
}

impl Config {
    /// Create configuration by resolving paths
    pub fn new() -> Self {
        let agent_id = resolve_agent_id();
        let session_id = resolve_session_id();
        let session_root = resolve_session_root();

        Self {
            phishri_path: resolve_phishri_path(),
            session_root,
            agent_id,
            session_id,
        }
    }

    /// Create config with specific agent and session IDs
    pub fn with_session(agent_id: impl Into<String>, session_id: impl Into<String>) -> Self {
        let mut config = Self::new();
        config.agent_id = agent_id.into();
        config.session_id = session_id.into();
        config
    }

    // ========================================================================
    // Knowledge Base Paths (shared, read-only)
    // ========================================================================

    /// Path to CONTEXTS directory
    pub fn contexts_path(&self) -> PathBuf {
        self.phishri_path.join("CONTEXTS")
    }

    /// Path to INDEXES directory
    pub fn indexes_path(&self) -> PathBuf {
        self.phishri_path.join("INDEXES")
    }

    /// Path to HASH_TABLE.json
    pub fn hash_table_path(&self) -> PathBuf {
        self.indexes_path().join("HASH_TABLE.json")
    }

    /// Path to SEMANTIC_MAP.json
    pub fn semantic_map_path(&self) -> PathBuf {
        self.indexes_path().join("SEMANTIC_MAP.json")
    }

    /// Path to NLP_PATTERNS.json
    pub fn nlp_patterns_path(&self) -> PathBuf {
        self.indexes_path().join("NLP_PATTERNS.json")
    }

    /// Path to PREREQUISITES.json
    pub fn prerequisites_path(&self) -> PathBuf {
        self.indexes_path().join("PREREQUISITES.json")
    }

    // ========================================================================
    // Session Paths (isolated per agent+session)
    // ========================================================================

    /// Get unique session directory name
    fn session_dir_name(&self) -> String {
        format!("{}_{}", self.agent_id, self.session_id)
    }

    /// Path to this agent+session's directory
    pub fn session_path(&self) -> PathBuf {
        self.session_root.join("sessions").join(self.session_dir_name())
    }

    /// Path to this session's bootstrap file
    pub fn bootstrap_path(&self) -> PathBuf {
        self.session_path().join("bootstrap.json")
    }

    /// Path to this session's checkpoints directory
    pub fn checkpoints_path(&self) -> PathBuf {
        self.session_path().join("checkpoints")
    }

    /// Ensure session directory exists
    pub fn ensure_session_dir(&self) -> std::io::Result<()> {
        fs::create_dir_all(self.session_path())?;
        fs::create_dir_all(self.checkpoints_path())?;
        Ok(())
    }

    // ========================================================================
    // Session Enumeration (for cleanup/admin)
    // ========================================================================

    /// List all sessions for a given agent
    pub fn list_agent_sessions(&self, agent_id: &str) -> std::io::Result<Vec<String>> {
        let sessions_dir = self.session_root.join("sessions");
        if !sessions_dir.exists() {
            return Ok(vec![]);
        }

        let prefix = format!("{}_", agent_id);
        let mut sessions = vec![];

        for entry in fs::read_dir(sessions_dir)? {
            let entry = entry?;
            if let Some(name) = entry.file_name().to_str() {
                if name.starts_with(&prefix) {
                    sessions.push(name[prefix.len()..].to_string());
                }
            }
        }

        Ok(sessions)
    }

    /// List all active sessions (all agents)
    pub fn list_all_sessions(&self) -> std::io::Result<Vec<(String, String)>> {
        let sessions_dir = self.session_root.join("sessions");
        if !sessions_dir.exists() {
            return Ok(vec![]);
        }

        let mut sessions = vec![];

        for entry in fs::read_dir(sessions_dir)? {
            let entry = entry?;
            if let Some(name) = entry.file_name().to_str() {
                if let Some((agent, session)) = name.split_once('_') {
                    sessions.push((agent.to_string(), session.to_string()));
                }
            }
        }

        Ok(sessions)
    }

    /// Clean up old sessions (older than given days)
    pub fn cleanup_old_sessions(&self, max_age_days: u64) -> std::io::Result<usize> {
        use std::time::{Duration, SystemTime};

        let sessions_dir = self.session_root.join("sessions");
        if !sessions_dir.exists() {
            return Ok(0);
        }

        let max_age = Duration::from_secs(max_age_days * 24 * 60 * 60);
        let now = SystemTime::now();
        let mut cleaned = 0;

        for entry in fs::read_dir(&sessions_dir)? {
            let entry = entry?;
            let metadata = entry.metadata()?;

            if let Ok(modified) = metadata.modified() {
                if let Ok(age) = now.duration_since(modified) {
                    if age > max_age {
                        fs::remove_dir_all(entry.path())?;
                        cleaned += 1;
                    }
                }
            }
        }

        Ok(cleaned)
    }
}

impl Default for Config {
    fn default() -> Self {
        Self::new()
    }
}

/// Resolve agent ID from environment or generate default
fn resolve_agent_id() -> String {
    // Check environment variable first
    if let Ok(id) = env::var("PHISHRI_AGENT_ID") {
        return sanitize_id(&id);
    }

    // Try to get from MCP client info (set during initialize)
    // This will be updated when we receive initialize request
    "default".to_string()
}

/// Resolve session ID from environment or generate new
fn resolve_session_id() -> String {
    // Check environment variable first
    if let Ok(id) = env::var("PHISHRI_SESSION_ID") {
        return sanitize_id(&id);
    }

    // Generate a unique session ID based on timestamp + random
    use std::time::{SystemTime, UNIX_EPOCH};
    let timestamp = SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .unwrap_or_default()
        .as_millis();

    format!("{:x}", timestamp)
}

/// Resolve session storage root
fn resolve_session_root() -> PathBuf {
    // Check environment variable first
    if let Ok(path) = env::var("PHISHRI_SESSION_ROOT") {
        return PathBuf::from(path);
    }

    // Platform-specific defaults
    #[cfg(windows)]
    {
        if let Ok(userprofile) = env::var("USERPROFILE") {
            return PathBuf::from(userprofile).join(".phishri");
        }
        PathBuf::from(r"C:\Users\Public\.phishri")
    }

    #[cfg(not(windows))]
    {
        if let Some(home) = env::var_os("HOME") {
            return PathBuf::from(home).join(".phishri");
        }
        PathBuf::from("/tmp/.phishri")
    }
}

/// Resolve PhiSHRI root path (knowledge base)
///
/// Scans common MCP/PhiSHRI install locations across all platforms.
/// If not found, prompts user via stderr and waits for path input.
///
/// Priority:
/// 1. PHISHRI_PATH environment variable
/// 2. Scan common locations (platform-specific)
/// 3. Prompt user for path
fn resolve_phishri_path() -> PathBuf {
    // 1. Environment variable (highest priority)
    if let Ok(path) = env::var("PHISHRI_PATH") {
        let p = PathBuf::from(&path);
        if is_valid_knowledge_base(&p) {
            return p;
        }
        // Path set but invalid - warn but continue scanning
        eprintln!("[WARN] PHISHRI_PATH='{}' does not contain valid knowledge base, scanning...", path);
    }

    // 2. Scan common locations
    let candidates = get_common_paths();
    for candidate in &candidates {
        if is_valid_knowledge_base(candidate) {
            eprintln!("[INFO] Found PhiSHRI knowledge base at: {}", candidate.display());
            return candidate.clone();
        }
    }

    // 3. Prompt user for path
    eprintln!("\n[ERROR] PhiSHRI knowledge base not found!");
    eprintln!("Searched locations:");
    for candidate in &candidates {
        eprintln!("  - {}", candidate.display());
    }
    eprintln!("\nThe knowledge base folder should contain a 'CONTEXTS' directory.");
    eprintln!("\nPlease enter the full path to your PhiSHRI knowledge base:");
    eprintln!("(Or set PHISHRI_PATH environment variable and restart)\n");

    // Try to read from stdin (won't work in MCP mode, but useful for debugging)
    // In production, this will just use the first candidate as fallback
    if atty::is(atty::Stream::Stdin) {
        // Interactive terminal - try to get user input
        let mut input = String::new();
        if std::io::stdin().read_line(&mut input).is_ok() {
            let user_path = PathBuf::from(input.trim());
            if is_valid_knowledge_base(&user_path) {
                eprintln!("[OK] Using: {}", user_path.display());
                return user_path;
            } else {
                eprintln!("[ERROR] Invalid path or missing CONTEXTS directory");
            }
        }
    }

    // Final fallback - return first candidate (will error gracefully later)
    candidates.into_iter().next().unwrap_or_else(|| PathBuf::from("."))
}

/// Check if a path contains a valid PhiSHRI knowledge base
fn is_valid_knowledge_base(path: &PathBuf) -> bool {
    if !path.exists() {
        return false;
    }

    // Must contain CONTEXTS directory with at least one subdirectory
    let contexts = path.join("CONTEXTS");
    if contexts.is_dir() {
        if let Ok(entries) = fs::read_dir(&contexts) {
            return entries.filter_map(|e| e.ok()).any(|e| e.path().is_dir());
        }
    }

    // Also accept if PhiSHRI subdirectory exists with CONTEXTS
    let nested = path.join("PhiSHRI").join("CONTEXTS");
    if nested.is_dir() {
        return true;
    }

    false
}

/// Get list of common PhiSHRI/MCP installation paths for all platforms
fn get_common_paths() -> Vec<PathBuf> {
    let mut paths = Vec::new();

    // Get home directory
    let home = env::var_os("HOME")
        .or_else(|| env::var_os("USERPROFILE"))
        .map(PathBuf::from);

    if let Some(ref h) = home {
        // Standard PhiSHRI installer locations
        paths.push(h.join(".phishri").join("knowledge"));
        paths.push(h.join(".phishri").join("PhiSHRI"));
        paths.push(h.join(".phishri"));

        // Common MCP locations
        paths.push(h.join(".mcp").join("phishri"));
        paths.push(h.join(".mcp").join("PhiSHRI"));
        paths.push(h.join(".config").join("phishri"));
        paths.push(h.join(".config").join("PhiSHRI"));

        // Direct home installs
        paths.push(h.join("PhiSHRI"));
        paths.push(h.join("PhiSHRI-local").join("PhiSHRI"));
        paths.push(h.join("phishri"));

        // Development locations
        paths.push(h.join("Dev").join("PhiSHRI").join("PhiSHRI"));
        paths.push(h.join("dev").join("PhiSHRI").join("PhiSHRI"));
        paths.push(h.join("Projects").join("PhiSHRI").join("PhiSHRI"));
        paths.push(h.join("projects").join("PhiSHRI").join("PhiSHRI"));
        paths.push(h.join("Code").join("PhiSHRI").join("PhiSHRI"));
        paths.push(h.join("code").join("PhiSHRI").join("PhiSHRI"));

        // macOS specific
        #[cfg(target_os = "macos")]
        {
            paths.push(h.join("Library").join("Application Support").join("PhiSHRI"));
            paths.push(h.join("Library").join("PhiSHRI"));
        }
    }

    // Windows specific paths
    #[cfg(windows)]
    {
        paths.push(PathBuf::from(r"C:\Dev\PhiSHRI\PhiSHRI"));
        paths.push(PathBuf::from(r"C:\PhiSHRI"));
        paths.push(PathBuf::from(r"C:\Program Files\PhiSHRI"));
        paths.push(PathBuf::from(r"C:\ProgramData\PhiSHRI"));

        if let Ok(appdata) = env::var("APPDATA") {
            paths.push(PathBuf::from(&appdata).join("PhiSHRI"));
        }
        if let Ok(localappdata) = env::var("LOCALAPPDATA") {
            paths.push(PathBuf::from(&localappdata).join("PhiSHRI"));
        }
    }

    // Linux specific paths
    #[cfg(target_os = "linux")]
    {
        paths.push(PathBuf::from("/opt/phishri"));
        paths.push(PathBuf::from("/usr/local/share/phishri"));
        paths.push(PathBuf::from("/usr/share/phishri"));

        if let Ok(xdg_data) = env::var("XDG_DATA_HOME") {
            paths.push(PathBuf::from(xdg_data).join("phishri"));
        }
        if let Ok(xdg_config) = env::var("XDG_CONFIG_HOME") {
            paths.push(PathBuf::from(xdg_config).join("phishri"));
        }
    }

    // Current directory variants (lowest priority)
    paths.push(PathBuf::from("./PhiSHRI"));
    paths.push(PathBuf::from("./knowledge"));
    paths.push(PathBuf::from("."));

    paths
}

/// Sanitize ID strings to be filesystem-safe
fn sanitize_id(id: &str) -> String {
    id.chars()
        .map(|c| {
            if c.is_alphanumeric() || c == '-' || c == '_' {
                c
            } else {
                '_'
            }
        })
        .take(64) // Limit length
        .collect()
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_config_creation() {
        let config = Config::new();
        assert!(!config.phishri_path.as_os_str().is_empty());
        assert!(!config.session_root.as_os_str().is_empty());
        assert!(!config.agent_id.is_empty());
        assert!(!config.session_id.is_empty());
    }

    #[test]
    fn test_derived_paths() {
        let config = Config::new();
        assert!(config.contexts_path().ends_with("CONTEXTS"));
        assert!(config.indexes_path().ends_with("INDEXES"));
        assert!(config.hash_table_path().ends_with("HASH_TABLE.json"));
    }

    #[test]
    fn test_session_isolation() {
        let config_a = Config::with_session("agent_a", "session_1");
        let config_b = Config::with_session("agent_b", "session_2");

        // Bootstrap paths should be different
        assert_ne!(config_a.bootstrap_path(), config_b.bootstrap_path());

        // But knowledge base paths should be the same
        assert_eq!(config_a.hash_table_path(), config_b.hash_table_path());
    }

    #[test]
    fn test_sanitize_id() {
        assert_eq!(sanitize_id("valid-id_123"), "valid-id_123");
        assert_eq!(sanitize_id("has spaces!"), "has_spaces_");
        assert_eq!(sanitize_id("path/injection"), "path_injection");
    }

    #[test]
    fn test_session_dir_name() {
        let config = Config::with_session("claude", "abc123");
        assert_eq!(config.session_dir_name(), "claude_abc123");
    }
}
