//! MCP Stdio Transport Server
//!
//! Clean-room implementation of the MCP stdio transport layer.
//! Handles reading JSON-RPC messages from stdin and writing responses to stdout.

use crate::config::Config;
use crate::door::DoorManager;
use crate::mcp::protocol::{
    InitializeParams, InitializeResult, JsonRpcError, JsonRpcRequest, JsonRpcResponse,
    ServerCapabilities, ServerInfo, ToolCallParams, ToolCallResult,
    ToolsCapability, ToolsListResult, MCP_PROTOCOL_VERSION,
    PromptsCapability, PromptsListResult, PromptDefinition, PromptArgument,
    PromptGetParams, PromptGetResult, PromptMessage, PromptContent,
    ResourcesCapability, ResourcesListResult, ResourceDefinition,
    ResourceReadParams, ResourceReadResult, ResourceReadContent,
};
use crate::mcp::tools::get_tool_definitions;
use serde_json::Value;
use std::io::{self, BufRead, Write};
use tracing::{debug, error, info, warn};

/// MCP Server state
pub struct McpServer {
    initialized: bool,
    server_info: ServerInfo,
    config: Config,
    door_manager: DoorManager,
}

impl McpServer {
    pub fn new() -> Self {
        let config = Config::new();
        let door_manager = DoorManager::new(config.clone());

        Self {
            initialized: false,
            server_info: ServerInfo {
                name: "phishri-mcp".to_string(),
                version: env!("CARGO_PKG_VERSION").to_string(),
            },
            config,
            door_manager,
        }
    }

    /// Run the server, reading from stdin and writing to stdout
    pub fn run(&mut self) -> io::Result<()> {
        let stdin = io::stdin();
        let mut stdout = io::stdout();

        info!("PhiSHRI MCP Server starting...");
        info!("PhiSHRI path: {:?}", self.config.phishri_path);
        info!("Session root: {:?}", self.config.session_root);

        for line in stdin.lock().lines() {
            let line = match line {
                Ok(l) => l,
                Err(e) => {
                    error!("Error reading stdin: {}", e);
                    continue;
                }
            };

            // Skip empty lines
            if line.trim().is_empty() {
                continue;
            }

            debug!("Received: {}", line);

            // Parse and handle the request
            let response = self.handle_message(&line);

            // Only send response if we have one (notifications don't get responses)
            if let Some(resp) = response {
                match resp.to_json() {
                    Ok(json) => {
                        debug!("Sending: {}", json);
                        writeln!(stdout, "{}", json)?;
                        stdout.flush()?;
                    }
                    Err(e) => {
                        error!("Failed to serialize response: {}", e);
                    }
                }
            }
        }

        info!("Server shutting down");
        Ok(())
    }

    /// Handle a single JSON-RPC message
    fn handle_message(&mut self, message: &str) -> Option<JsonRpcResponse> {
        // Parse the JSON
        let request: JsonRpcRequest = match serde_json::from_str(message) {
            Ok(req) => req,
            Err(e) => {
                error!("Parse error: {}", e);
                return Some(JsonRpcResponse::error(None, JsonRpcError::parse_error()));
            }
        };

        // Validate JSON-RPC version
        if request.validate().is_err() {
            return Some(JsonRpcResponse::error(
                request.id.clone(),
                JsonRpcError::invalid_request(),
            ));
        }

        // Route to appropriate handler
        let result = self.route_request(&request);

        // Notifications (no id) don't get responses
        if request.is_notification() {
            return None;
        }

        Some(result)
    }

    /// Route request to the appropriate handler
    fn route_request(&mut self, request: &JsonRpcRequest) -> JsonRpcResponse {
        match request.method.as_str() {
            "initialize" => self.handle_initialize(request),
            "initialized" => {
                // This is typically a notification, just acknowledge
                JsonRpcResponse::success(request.id.clone(), Value::Null)
            }
            "ping" => self.handle_ping(request),
            "tools/list" => self.handle_tools_list(request),
            "tools/call" => self.handle_tools_call(request),
            "prompts/list" => self.handle_prompts_list(request),
            "prompts/get" => self.handle_prompts_get(request),
            "resources/list" => self.handle_resources_list(request),
            "resources/read" => self.handle_resources_read(request),
            "notifications/cancelled" => {
                // Handle cancellation notification
                JsonRpcResponse::success(request.id.clone(), Value::Null)
            }
            method => {
                warn!("Unknown method: {}", method);
                JsonRpcResponse::error(
                    request.id.clone(),
                    JsonRpcError::method_not_found(method),
                )
            }
        }
    }

    /// Handle initialize request
    fn handle_initialize(&mut self, request: &JsonRpcRequest) -> JsonRpcResponse {
        let params: InitializeParams = match request.params_as() {
            Ok(p) => p,
            Err(e) => {
                return JsonRpcResponse::error(request.id.clone(), e.into());
            }
        };

        info!("Client initializing: {} v{}", params.client_info.name, params.client_info.version);

        // Update agent_id from client info
        let agent_id = sanitize_id(&params.client_info.name);
        self.config.agent_id = agent_id;

        // Ensure session directory exists
        if let Err(e) = self.config.ensure_session_dir() {
            warn!("Could not create session directory: {}", e);
        }

        self.initialized = true;

        let result = InitializeResult {
            protocol_version: MCP_PROTOCOL_VERSION.to_string(),
            capabilities: ServerCapabilities {
                tools: Some(ToolsCapability {
                    list_changed: Some(false),
                }),
                resources: Some(serde_json::to_value(ResourcesCapability {
                    subscribe: Some(false),
                    list_changed: Some(false),
                }).unwrap_or(Value::Object(Default::default()))),
                prompts: Some(serde_json::to_value(PromptsCapability {
                    list_changed: Some(false),
                }).unwrap_or(Value::Object(Default::default()))),
                logging: None,
            },
            server_info: self.server_info.clone(),
        };

        match serde_json::to_value(result) {
            Ok(v) => JsonRpcResponse::success(request.id.clone(), v),
            Err(e) => JsonRpcResponse::error(
                request.id.clone(),
                JsonRpcError::internal_error(e.to_string()),
            ),
        }
    }

    /// Handle ping request
    fn handle_ping(&self, request: &JsonRpcRequest) -> JsonRpcResponse {
        JsonRpcResponse::success(request.id.clone(), serde_json::json!({}))
    }

    /// Handle tools/list request
    fn handle_tools_list(&self, request: &JsonRpcRequest) -> JsonRpcResponse {
        let tools = get_tool_definitions();
        let result = ToolsListResult { tools };

        match serde_json::to_value(result) {
            Ok(v) => JsonRpcResponse::success(request.id.clone(), v),
            Err(e) => JsonRpcResponse::error(
                request.id.clone(),
                JsonRpcError::internal_error(e.to_string()),
            ),
        }
    }

    /// Handle tools/call request
    fn handle_tools_call(&self, request: &JsonRpcRequest) -> JsonRpcResponse {
        let params: ToolCallParams = match request.params_as() {
            Ok(p) => p,
            Err(e) => {
                return JsonRpcResponse::error(request.id.clone(), e.into());
            }
        };

        info!("Tool call: {}", params.name);

        // Dispatch to tool handler
        let result = self.dispatch_tool(&params.name, params.arguments);

        match serde_json::to_value(result) {
            Ok(v) => JsonRpcResponse::success(request.id.clone(), v),
            Err(e) => JsonRpcResponse::error(
                request.id.clone(),
                JsonRpcError::internal_error(e.to_string()),
            ),
        }
    }

    /// Dispatch to specific tool handler
    fn dispatch_tool(&self, name: &str, arguments: Option<Value>) -> ToolCallResult {
        match name {
            "phishri_read_door" => self.tool_read_door(arguments),
            "phishri_list_doors" => self.tool_list_doors(arguments),
            "phishri_find_door" => self.tool_find_door(arguments),
            "phishri_load_chain" => self.tool_load_chain(arguments),
            "phishri_create_door" => self.tool_create_door(arguments),
            "phishri_validate_door" => self.tool_validate_door(arguments),
            "phishri_batch_create" => self.tool_batch_create(arguments),
            "phishri_get_bootstrap" => self.tool_get_bootstrap(arguments),
            "phishri_update_bootstrap" => self.tool_update_bootstrap(arguments),
            "phishri_session_checkpoint" => self.tool_session_checkpoint(arguments),
            "phishri_search_semantic" => self.tool_search_semantic(arguments),
            "phishri_get_prerequisites" => self.tool_get_prerequisites(arguments),
            "phishri_rebuild_indexes" => self.tool_rebuild_indexes(arguments),
            "phishri_audit" => self.tool_audit(arguments),
            "phishri_stats" => self.tool_stats(arguments),
            _ => ToolCallResult::error(format!("Unknown tool: {}", name)),
        }
    }

    // ========================================================================
    // Tool Implementations
    // ========================================================================

    fn tool_read_door(&self, arguments: Option<Value>) -> ToolCallResult {
        let door_code = arguments
            .as_ref()
            .and_then(|v| v.get("door_code"))
            .and_then(|v| v.as_str())
            .unwrap_or("");

        if door_code.is_empty() {
            return ToolCallResult::error("Missing required parameter: door_code");
        }

        match self.door_manager.read_door(door_code) {
            Ok(door) => ToolCallResult::text(door.full_text()),
            Err(e) => ToolCallResult::error(format!("Failed to read door {}: {}", door_code, e)),
        }
    }

    fn tool_list_doors(&self, arguments: Option<Value>) -> ToolCallResult {
        let category = arguments
            .as_ref()
            .and_then(|v| v.get("category"))
            .and_then(|v| v.as_str());

        let limit = arguments
            .as_ref()
            .and_then(|v| v.get("limit"))
            .and_then(|v| v.as_u64())
            .unwrap_or(50) as usize;

        match self.door_manager.list_doors(category, limit) {
            Ok(doors) => {
                let mut output = String::new();
                if let Some(cat) = category {
                    output.push_str(&format!("# Doors in category: {}\n\n", cat));
                } else {
                    output.push_str("# All Doors\n\n");
                }

                for item in doors {
                    output.push_str(&format!("- {}\n", item.to_line()));
                }

                ToolCallResult::text(output)
            }
            Err(e) => ToolCallResult::error(format!("Failed to list doors: {}", e)),
        }
    }

    fn tool_find_door(&self, arguments: Option<Value>) -> ToolCallResult {
        let query = arguments
            .as_ref()
            .and_then(|v| v.get("query"))
            .and_then(|v| v.as_str())
            .unwrap_or("");

        if query.is_empty() {
            return ToolCallResult::error("Missing required parameter: query");
        }

        let limit = arguments
            .as_ref()
            .and_then(|v| v.get("limit"))
            .and_then(|v| v.as_u64())
            .unwrap_or(5) as usize;

        let query_lower = query.to_lowercase();
        let query_terms: Vec<&str> = query_lower.split_whitespace().collect();

        match self.door_manager.list_doors(None, 300) {
            Ok(doors) => {
                let mut scored_matches: Vec<(u32, String, String)> = Vec::new();
                for item in &doors {
                    if let Ok(door) = self.door_manager.read_door(&item.short_code) {
                        let mut score: u32 = 0;
                        let code_lower = door.door_code.to_lowercase();
                        for term in &query_terms { if code_lower.contains(term) { score += 10; } }
                        for alias in &door.aliases {
                            let alias_lower = alias.to_lowercase();
                            for term in &query_terms { if alias_lower.contains(term) { score += 15; } }
                            if alias_lower == query_lower { score += 50; }
                        }
                        let path_lower = door.semantic_path.to_lowercase();
                        for term in &query_terms { if path_lower.contains(term) { score += 8; } }
                        let summary_lower = door.context_bundle.summary.to_lowercase();
                        for term in &query_terms { if summary_lower.contains(term) { score += 5; } }
                        if let Some(ref meta) = door.context_bundle.metadata {
                            for tag in &meta.tags {
                                let tag_lower = tag.to_lowercase();
                                for term in &query_terms { if tag_lower.contains(term) { score += 12; } }
                            }
                        }
                        if score > 0 {
                            let summary = &door.context_bundle.summary;
                            let preview = if summary.chars().count() > 80 {
                                format!("{}...", summary.chars().take(77).collect::<String>())
                            } else { summary.clone() };
                            scored_matches.push((score, door.door_code.clone(), preview));
                        }
                    }
                }
                scored_matches.sort_by(|a, b| b.0.cmp(&a.0));
                if scored_matches.is_empty() {
                    ToolCallResult::text(format!("No doors found matching: {}", query))
                } else {
                    let mut output = format!("# Search Results for: \"{}\"\n\n", query);
                    for (score, code, summary) in scored_matches.iter().take(limit) {
                        output.push_str(&format!("- **{}** (score: {}) - {}\n", code, score, summary));
                    }
                    output.push_str(&format!("\n_Found {} matches, showing top {}_", scored_matches.len(), limit.min(scored_matches.len())));
                    ToolCallResult::text(output)
                }
            }
            Err(e) => ToolCallResult::error(format!("Search failed: {}", e)),
        }
    }

    fn tool_load_chain(&self, arguments: Option<Value>) -> ToolCallResult {
        let door_codes: Vec<String> = arguments
            .as_ref()
            .and_then(|v| v.get("door_codes"))
            .and_then(|v| v.as_array())
            .map(|arr| {
                arr.iter()
                    .filter_map(|v| v.as_str().map(String::from))
                    .collect()
            })
            .unwrap_or_default();

        if door_codes.is_empty() {
            return ToolCallResult::error("Missing required parameter: door_codes");
        }

        let include_prereqs = arguments
            .as_ref()
            .and_then(|v| v.get("include_prerequisites"))
            .and_then(|v| v.as_bool())
            .unwrap_or(true);

        match self.door_manager.load_chain(&door_codes, include_prereqs) {
            Ok(chain) => ToolCallResult::text(chain.to_text()),
            Err(e) => ToolCallResult::error(format!("Failed to load chain: {}", e)),
        }
    }

    fn tool_get_bootstrap(&self, _arguments: Option<Value>) -> ToolCallResult {
        use std::fs;

        let bootstrap_path = self.config.bootstrap_path();

        if !bootstrap_path.exists() {
            return ToolCallResult::text(format!(
                "# No Bootstrap File\n\nNo session state found at: {}\n\nThis is a new session for agent '{}' (session: {})",
                bootstrap_path.display(),
                self.config.agent_id,
                self.config.session_id
            ));
        }

        match fs::read_to_string(&bootstrap_path) {
            Ok(content) => {
                let mut output = format!(
                    "# Session Bootstrap\n\n**Agent:** {}\n**Session:** {}\n**Path:** {}\n\n---\n\n{}",
                    self.config.agent_id,
                    self.config.session_id,
                    bootstrap_path.display(),
                    content
                );
                ToolCallResult::text(output)
            }
            Err(e) => ToolCallResult::error(format!("Failed to read bootstrap: {}", e)),
        }
    }

    fn tool_update_bootstrap(&self, arguments: Option<Value>) -> ToolCallResult {
        use std::fs;
        use chrono::Utc;

        // Ensure session directory exists
        if let Err(e) = self.config.ensure_session_dir() {
            return ToolCallResult::error(format!("Failed to create session directory: {}", e));
        }

        let progress = arguments
            .as_ref()
            .and_then(|v| v.get("progress"))
            .and_then(|v| v.as_str())
            .unwrap_or("");

        let batch_completed = arguments
            .as_ref()
            .and_then(|v| v.get("batch_completed"))
            .and_then(|v| v.as_str())
            .unwrap_or("");

        let next_options: Vec<String> = arguments
            .as_ref()
            .and_then(|v| v.get("next_options"))
            .and_then(|v| v.as_array())
            .map(|arr| {
                arr.iter()
                    .filter_map(|v| v.as_str().map(String::from))
                    .collect()
            })
            .unwrap_or_default();

        let doors_loaded: Vec<String> = arguments
            .as_ref()
            .and_then(|v| v.get("doors_loaded"))
            .and_then(|v| v.as_array())
            .map(|arr| {
                arr.iter()
                    .filter_map(|v| v.as_str().map(String::from))
                    .collect()
            })
            .unwrap_or_default();

        // Build bootstrap JSON
        let bootstrap = serde_json::json!({
            "agent_id": self.config.agent_id,
            "session_id": self.config.session_id,
            "updated_at": Utc::now().to_rfc3339(),
            "progress": progress,
            "batch_completed": batch_completed,
            "next_options": next_options,
            "doors_loaded": doors_loaded
        });

        let bootstrap_path = self.config.bootstrap_path();
        match fs::write(&bootstrap_path, serde_json::to_string_pretty(&bootstrap).unwrap()) {
            Ok(_) => ToolCallResult::text(format!(
                "Bootstrap updated successfully at: {}",
                bootstrap_path.display()
            )),
            Err(e) => ToolCallResult::error(format!("Failed to write bootstrap: {}", e)),
        }
    }

    fn tool_session_checkpoint(&self, arguments: Option<Value>) -> ToolCallResult {
        use std::fs;
        use chrono::Utc;

        let checkpoint_name = arguments
            .as_ref()
            .and_then(|v| v.get("checkpoint_name"))
            .and_then(|v| v.as_str())
            .unwrap_or("");

        if checkpoint_name.is_empty() {
            return ToolCallResult::error("Missing required parameter: checkpoint_name");
        }

        let doors_loaded: Vec<String> = arguments
            .as_ref()
            .and_then(|v| v.get("doors_loaded"))
            .and_then(|v| v.as_array())
            .map(|arr| {
                arr.iter()
                    .filter_map(|v| v.as_str().map(String::from))
                    .collect()
            })
            .unwrap_or_default();

        let notes = arguments
            .as_ref()
            .and_then(|v| v.get("notes"))
            .and_then(|v| v.as_str())
            .unwrap_or("");

        // Ensure checkpoints directory exists
        if let Err(e) = self.config.ensure_session_dir() {
            return ToolCallResult::error(format!("Failed to create session directory: {}", e));
        }

        let checkpoint = serde_json::json!({
            "name": checkpoint_name,
            "created_at": Utc::now().to_rfc3339(),
            "agent_id": self.config.agent_id,
            "session_id": self.config.session_id,
            "doors_loaded": doors_loaded,
            "notes": notes
        });

        let safe_name = sanitize_id(checkpoint_name);
        let checkpoint_path = self.config.checkpoints_path().join(format!("{}.json", safe_name));

        match fs::write(&checkpoint_path, serde_json::to_string_pretty(&checkpoint).unwrap()) {
            Ok(_) => ToolCallResult::text(format!(
                "Checkpoint '{}' created at: {}",
                checkpoint_name,
                checkpoint_path.display()
            )),
            Err(e) => ToolCallResult::error(format!("Failed to create checkpoint: {}", e)),
        }
    }

    fn tool_search_semantic(&self, arguments: Option<Value>) -> ToolCallResult {
        let path = arguments
            .as_ref()
            .and_then(|v| v.get("path"))
            .and_then(|v| v.as_str())
            .unwrap_or("");

        if path.is_empty() {
            return ToolCallResult::error("Missing required parameter: path");
        }

        // Simple implementation: search for doors with matching semantic_path
        match self.door_manager.list_doors(None, 268) {
            Ok(doors) => {
                let path_upper = path.to_uppercase();
                let mut matches = Vec::new();

                for item in doors {
                    if let Ok(door) = self.door_manager.read_door(&item.full_code) {
                        if door.semantic_path.to_uppercase().contains(&path_upper) {
                            matches.push((item.full_code, door.semantic_path));
                        }
                    }
                }

                if matches.is_empty() {
                    ToolCallResult::text(format!("No doors found with semantic path containing: {}", path))
                } else {
                    let mut output = format!("# Semantic Search: {}\n\n", path);
                    for (code, sem_path) in matches {
                        output.push_str(&format!("- {} → {}\n", code, sem_path));
                    }
                    ToolCallResult::text(output)
                }
            }
            Err(e) => ToolCallResult::error(format!("Semantic search failed: {}", e)),
        }
    }

    fn tool_get_prerequisites(&self, arguments: Option<Value>) -> ToolCallResult {
        let door_code = arguments
            .as_ref()
            .and_then(|v| v.get("door_code"))
            .and_then(|v| v.as_str())
            .unwrap_or("");

        if door_code.is_empty() {
            return ToolCallResult::error("Missing required parameter: door_code");
        }

        match self.door_manager.get_prerequisites(door_code) {
            Ok(prereqs) => {
                if prereqs.len() <= 1 {
                    ToolCallResult::text(format!("Door {} has no prerequisites.", door_code))
                } else {
                    let mut output = format!("# Prerequisites for {}\n\n", door_code);
                    output.push_str("Read these doors in order:\n\n");
                    for (i, prereq) in prereqs.iter().enumerate() {
                        let marker = if prereq == &door_code.to_uppercase() {
                            " ← (target)"
                        } else {
                            ""
                        };
                        output.push_str(&format!("{}. {}{}\n", i + 1, prereq, marker));
                    }
                    ToolCallResult::text(output)
                }
            }
            Err(e) => ToolCallResult::error(format!("Failed to get prerequisites: {}", e)),
        }
    }

    fn tool_rebuild_indexes(&self, _arguments: Option<Value>) -> ToolCallResult {
        match self.door_manager.rebuild_indexes() {
            Ok(result) => ToolCallResult::text(format!(
                "# Index Rebuild Complete\n\n- Doors indexed: {}\n- Hash table: {}",
                result.doors_indexed,
                result.hash_table_path
            )),
            Err(e) => ToolCallResult::error(format!("Index rebuild failed: {}", e)),
        }
    }

    // ========================================================================
    // New Tools: Creation, Validation, Audit, Stats
    // ========================================================================

    fn tool_create_door(&self, arguments: Option<Value>) -> ToolCallResult {
        use crate::door::manager::CreateDoorParams;

        let args = match arguments {
            Some(a) => a,
            None => return ToolCallResult::error("Missing arguments"),
        };

        let params = CreateDoorParams {
            door_code: args.get("door_code").and_then(|v| v.as_str()).unwrap_or("").to_string(),
            category: args.get("category").and_then(|v| v.as_str()).unwrap_or("").to_string(),
            semantic_path: args.get("semantic_path").and_then(|v| v.as_str()).unwrap_or("").to_string(),
            summary: args.get("summary").and_then(|v| v.as_str()).unwrap_or("").to_string(),
            aliases: args.get("aliases").and_then(|v| v.as_array()).map(|a| a.iter().filter_map(|v| v.as_str().map(String::from)).collect()).unwrap_or_default(),
            prerequisites: args.get("prerequisites").and_then(|v| v.as_array()).map(|a| a.iter().filter_map(|v| v.as_str().map(String::from)).collect()).unwrap_or_default(),
            related_doors: args.get("related_doors").and_then(|v| v.as_array()).map(|a| a.iter().filter_map(|v| v.as_str().map(String::from)).collect()).unwrap_or_default(),
            quick_start: args.get("quick_start").and_then(|v| v.as_str()).unwrap_or("").to_string(),
            common_patterns: args.get("common_patterns").and_then(|v| v.as_array()).map(|a| a.iter().filter_map(|v| v.as_str().map(String::from)).collect()).unwrap_or_default(),
            known_errors: args.get("known_errors").and_then(|v| v.as_array()).map(|a| a.iter().filter_map(|v| v.as_str().map(String::from)).collect()).unwrap_or_default(),
            tags: args.get("tags").and_then(|v| v.as_array()).map(|a| a.iter().filter_map(|v| v.as_str().map(String::from)).collect()).unwrap_or_default(),
            agent_affinity: args.get("agent_affinity").and_then(|v| v.as_array()).map(|a| a.iter().filter_map(|v| v.as_str().map(String::from)).collect()).unwrap_or_default(),
        };

        if params.door_code.is_empty() || params.category.is_empty() || params.summary.is_empty() {
            return ToolCallResult::error("Missing required fields: door_code, category, summary");
        }

        match self.door_manager.create_door(params) {
            Ok(result) => ToolCallResult::text(format!(
                "# Door Created\n\n- **Code:** {}\n- **File:** {}\n- **Validated:** {}",
                result.door_code, result.file_path, result.validated
            )),
            Err(e) => ToolCallResult::error(format!("Create failed: {}", e)),
        }
    }

    fn tool_validate_door(&self, arguments: Option<Value>) -> ToolCallResult {
        let door_code = arguments.as_ref().and_then(|v| v.get("door_code")).and_then(|v| v.as_str());
        let file_path = arguments.as_ref().and_then(|v| v.get("file_path")).and_then(|v| v.as_str());

        if door_code.is_none() && file_path.is_none() {
            return ToolCallResult::error("Must provide door_code or file_path");
        }

        let result = self.door_manager.validate_door(door_code, file_path);

        let mut output = format!("# Validation Result\n\n**Valid:** {}\n", if result.valid { "YES" } else { "NO" });
        if let Some(code) = &result.door_code { output.push_str(&format!("**Door:** {}\n", code)); }

        if !result.errors.is_empty() {
            output.push_str("\n## Errors\n");
            for e in &result.errors { output.push_str(&format!("- {}\n", e)); }
        }

        if !result.warnings.is_empty() {
            output.push_str("\n## Warnings\n");
            for w in &result.warnings { output.push_str(&format!("- {}\n", w)); }
        }

        if !result.missing_prerequisites.is_empty() {
            output.push_str(&format!("\n**Missing Prerequisites:** {}\n", result.missing_prerequisites.join(", ")));
        }

        if !result.broken_references.is_empty() {
            output.push_str(&format!("**Broken References:** {}\n", result.broken_references.join(", ")));
        }

        ToolCallResult::text(output)
    }

    fn tool_batch_create(&self, arguments: Option<Value>) -> ToolCallResult {
        use crate::door::manager::CreateDoorParams;

        let args = match arguments {
            Some(a) => a,
            None => return ToolCallResult::error("Missing arguments"),
        };

        let doors_array = match args.get("doors").and_then(|v| v.as_array()) {
            Some(a) => a,
            None => return ToolCallResult::error("Missing doors array"),
        };

        let validate = args.get("validate").and_then(|v| v.as_bool()).unwrap_or(true);
        let update_indexes = args.get("update_indexes").and_then(|v| v.as_bool()).unwrap_or(true);

        let mut params_list: Vec<CreateDoorParams> = Vec::new();

        for door in doors_array {
            params_list.push(CreateDoorParams {
                door_code: door.get("door_code").and_then(|v| v.as_str()).unwrap_or("").to_string(),
                category: door.get("category").and_then(|v| v.as_str()).unwrap_or("").to_string(),
                semantic_path: door.get("semantic_path").and_then(|v| v.as_str()).unwrap_or("").to_string(),
                summary: door.get("summary").and_then(|v| v.as_str()).unwrap_or("").to_string(),
                aliases: door.get("aliases").and_then(|v| v.as_array()).map(|a| a.iter().filter_map(|v| v.as_str().map(String::from)).collect()).unwrap_or_default(),
                prerequisites: door.get("prerequisites").and_then(|v| v.as_array()).map(|a| a.iter().filter_map(|v| v.as_str().map(String::from)).collect()).unwrap_or_default(),
                related_doors: door.get("related_doors").and_then(|v| v.as_array()).map(|a| a.iter().filter_map(|v| v.as_str().map(String::from)).collect()).unwrap_or_default(),
                quick_start: door.get("quick_start").and_then(|v| v.as_str()).unwrap_or("").to_string(),
                common_patterns: door.get("common_patterns").and_then(|v| v.as_array()).map(|a| a.iter().filter_map(|v| v.as_str().map(String::from)).collect()).unwrap_or_default(),
                known_errors: door.get("known_errors").and_then(|v| v.as_array()).map(|a| a.iter().filter_map(|v| v.as_str().map(String::from)).collect()).unwrap_or_default(),
                tags: door.get("tags").and_then(|v| v.as_array()).map(|a| a.iter().filter_map(|v| v.as_str().map(String::from)).collect()).unwrap_or_default(),
                agent_affinity: door.get("agent_affinity").and_then(|v| v.as_array()).map(|a| a.iter().filter_map(|v| v.as_str().map(String::from)).collect()).unwrap_or_default(),
            });
        }

        let result = self.door_manager.batch_create(params_list, validate, update_indexes);

        let mut output = format!("# Batch Create Result\n\n**Success:** {}\n**Created:** {}\n",
            if result.success { "YES" } else { "NO" }, result.created.len());

        if !result.created.is_empty() {
            output.push_str(&format!("\n## Created Doors\n{}\n", result.created.join(", ")));
        }

        if !result.errors.is_empty() {
            output.push_str("\n## Errors\n");
            for e in &result.errors { output.push_str(&format!("- {}\n", e)); }
        }

        if result.indexes_updated {
            output.push_str(&format!("\n**Total Doors After:** {}\n", result.total_doors));
        }

        ToolCallResult::text(output)
    }

    fn tool_audit(&self, arguments: Option<Value>) -> ToolCallResult {
        let scope = arguments.as_ref().and_then(|v| v.get("scope")).and_then(|v| v.as_str());

        let result = self.door_manager.audit(scope);

        let mut output = format!("# PhiSHRI Audit Report\n\n**Healthy:** {}\n**Total Doors:** {}\n",
            if result.healthy { "YES" } else { "NO" }, result.total_doors);

        output.push_str("\n## By Category\n");
        let mut cats: Vec<_> = result.by_category.iter().collect();
        cats.sort_by_key(|&(k, _)| k);
        for (cat, count) in cats { output.push_str(&format!("- {}: {}\n", cat, count)); }

        if !result.errors.is_empty() {
            output.push_str("\n## Errors\n");
            for e in &result.errors { output.push_str(&format!("- {}\n", e)); }
        }

        if !result.warnings.is_empty() {
            output.push_str(&format!("\n## Warnings ({})\n", result.warnings.len()));
            for w in result.warnings.iter().take(20) { output.push_str(&format!("- {}\n", w)); }
            if result.warnings.len() > 20 { output.push_str(&format!("... and {} more\n", result.warnings.len() - 20)); }
        }

        if !result.missing_prerequisites.is_empty() {
            output.push_str(&format!("\n## Missing Prerequisites ({})\n{}\n",
                result.missing_prerequisites.len(), result.missing_prerequisites.join(", ")));
        }

        if !result.broken_references.is_empty() {
            output.push_str(&format!("\n## Broken References ({})\n{}\n",
                result.broken_references.len(), result.broken_references.join(", ")));
        }

        ToolCallResult::text(output)
    }

    fn tool_stats(&self, arguments: Option<Value>) -> ToolCallResult {
        let granularity = arguments.as_ref().and_then(|v| v.get("granularity")).and_then(|v| v.as_str()).unwrap_or("summary");

        let result = self.door_manager.stats(granularity);

        let mut output = format!("# PhiSHRI Statistics\n\n**Total Doors:** {}\n**Index Exists:** {}\n",
            result.total_doors, if result.index_exists { "YES" } else { "NO" });

        output.push_str("\n## By Category\n");
        let mut cats: Vec<_> = result.by_category.iter().collect();
        cats.sort_by_key(|&(k, _)| k);
        for (cat, count) in cats { output.push_str(&format!("- {}: {}\n", cat, count)); }

        if granularity == "detailed" {
            output.push_str(&format!("\n**Doors with Prerequisites:** {}\n", result.doors_with_prerequisites));

            if !result.tag_counts.is_empty() {
                output.push_str("\n## Top Tags\n");
                let mut tags: Vec<_> = result.tag_counts.iter().collect();
                tags.sort_by(|a, b| b.1.cmp(a.1));
                for (tag, count) in tags.iter().take(15) { output.push_str(&format!("- {}: {}\n", tag, count)); }
            }
        }

        ToolCallResult::text(output)
    }

    // ========================================================================
    // Prompts Handlers
    // ========================================================================

    /// Handle prompts/list request
    fn handle_prompts_list(&self, request: &JsonRpcRequest) -> JsonRpcResponse {
        let prompts = vec![
            PromptDefinition {
                name: "open_door".to_string(),
                description: "Open a PhiSHRI door to load context for a specific topic".to_string(),
                arguments: Some(vec![
                    PromptArgument {
                        name: "door_code".to_string(),
                        description: "The door code to open (e.g., D05, S01, W115)".to_string(),
                        required: Some(true),
                    },
                ]),
            },
            PromptDefinition {
                name: "explore_category".to_string(),
                description: "Explore all doors in a specific category".to_string(),
                arguments: Some(vec![
                    PromptArgument {
                        name: "category".to_string(),
                        description: "Category: SECURITY, TOOLS, WORKFLOWS, ARCHITECTURE, AGENTS, PROJECTS, ERRORS".to_string(),
                        required: Some(true),
                    },
                ]),
            },
            PromptDefinition {
                name: "find_context".to_string(),
                description: "Find relevant doors for your current task using natural language".to_string(),
                arguments: Some(vec![
                    PromptArgument {
                        name: "query".to_string(),
                        description: "Describe what you're working on or need help with".to_string(),
                        required: Some(true),
                    },
                ]),
            },
            PromptDefinition {
                name: "session_resume".to_string(),
                description: "Resume a previous session from a checkpoint".to_string(),
                arguments: None,
            },
            PromptDefinition {
                name: "phishri_overview".to_string(),
                description: "Get an overview of the PhiSHRI knowledge base and available doors".to_string(),
                arguments: None,
            },
        ];

        let result = PromptsListResult { prompts };
        match serde_json::to_value(result) {
            Ok(v) => JsonRpcResponse::success(request.id.clone(), v),
            Err(e) => JsonRpcResponse::error(
                request.id.clone(),
                JsonRpcError::internal_error(e.to_string()),
            ),
        }
    }

    /// Handle prompts/get request
    fn handle_prompts_get(&self, request: &JsonRpcRequest) -> JsonRpcResponse {
        let params: PromptGetParams = match request.params_as() {
            Ok(p) => p,
            Err(e) => return JsonRpcResponse::error(request.id.clone(), e.into()),
        };

        let result = match params.name.as_str() {
            "open_door" => {
                let door_code = params.arguments
                    .as_ref()
                    .and_then(|a| a.get("door_code"))
                    .map(|s| s.as_str())
                    .unwrap_or("D05");

                PromptGetResult {
                    description: Some(format!("Load context from door {}", door_code)),
                    messages: vec![PromptMessage {
                        role: "user".to_string(),
                        content: PromptContent::Text {
                            text: format!(
                                "Please open PhiSHRI door {} and use the context to help me with my current task. \
                                After loading, summarize the key points and ask how you can help.",
                                door_code
                            ),
                        },
                    }],
                }
            }
            "explore_category" => {
                let category = params.arguments
                    .as_ref()
                    .and_then(|a| a.get("category"))
                    .map(|s| s.as_str())
                    .unwrap_or("TOOLS");

                PromptGetResult {
                    description: Some(format!("Explore {} category", category)),
                    messages: vec![PromptMessage {
                        role: "user".to_string(),
                        content: PromptContent::Text {
                            text: format!(
                                "List all PhiSHRI doors in the {} category and give me a brief overview of each. \
                                Highlight the most commonly useful ones.",
                                category
                            ),
                        },
                    }],
                }
            }
            "find_context" => {
                let query = params.arguments
                    .as_ref()
                    .and_then(|a| a.get("query"))
                    .map(|s| s.as_str())
                    .unwrap_or("general development");

                PromptGetResult {
                    description: Some("Find relevant context".to_string()),
                    messages: vec![PromptMessage {
                        role: "user".to_string(),
                        content: PromptContent::Text {
                            text: format!(
                                "I need help with: {}\n\n\
                                Search PhiSHRI for relevant doors, load the most applicable ones, \
                                and use that context to assist me. Explain what context you loaded and why.",
                                query
                            ),
                        },
                    }],
                }
            }
            "session_resume" => {
                PromptGetResult {
                    description: Some("Resume previous session".to_string()),
                    messages: vec![PromptMessage {
                        role: "user".to_string(),
                        content: PromptContent::Text {
                            text: "Check for any saved PhiSHRI session state or checkpoints. \
                                If found, load the context and summarize where we left off. \
                                If not, list available checkpoints or start fresh.".to_string(),
                        },
                    }],
                }
            }
            "phishri_overview" => {
                PromptGetResult {
                    description: Some("PhiSHRI knowledge base overview".to_string()),
                    messages: vec![PromptMessage {
                        role: "user".to_string(),
                        content: PromptContent::Text {
                            text: "Give me an overview of the PhiSHRI knowledge base:\n\
                                1. How many doors are available and in what categories?\n\
                                2. What are the most useful doors for common development tasks?\n\
                                3. How do I use door codes to load context?\n\
                                4. Show some example door codes and what they contain.".to_string(),
                        },
                    }],
                }
            }
            _ => {
                return JsonRpcResponse::error(
                    request.id.clone(),
                    JsonRpcError::invalid_params(format!("Unknown prompt: {}", params.name)),
                );
            }
        };

        match serde_json::to_value(result) {
            Ok(v) => JsonRpcResponse::success(request.id.clone(), v),
            Err(e) => JsonRpcResponse::error(
                request.id.clone(),
                JsonRpcError::internal_error(e.to_string()),
            ),
        }
    }

    // ========================================================================
    // Resources Handlers
    // ========================================================================

    /// Handle resources/list request
    fn handle_resources_list(&self, request: &JsonRpcRequest) -> JsonRpcResponse {
        // List categories as resources
        let categories = vec![
            ("SECURITY", "Security best practices, OWASP, authentication, encryption"),
            ("TOOLS", "Development tools, deployment, installers, CI/CD"),
            ("WORKFLOWS", "Git workflows, code review, testing, automation"),
            ("ARCHITECTURE", "System design, microservices, APIs, patterns"),
            ("AGENTS", "AI agent patterns, coordination, memory management"),
            ("PROJECTS", "Project-specific context and configurations"),
            ("ERRORS", "Common errors, debugging, troubleshooting"),
            ("LANGUAGES", "Language-specific patterns and best practices"),
        ];

        let mut resources: Vec<ResourceDefinition> = categories
            .iter()
            .map(|(name, desc)| ResourceDefinition {
                uri: format!("phishri://category/{}", name.to_lowercase()),
                name: format!("{} Doors", name),
                description: Some(desc.to_string()),
                mime_type: Some("application/json".to_string()),
            })
            .collect();

        // Add top-level resources
        resources.push(ResourceDefinition {
            uri: "phishri://index".to_string(),
            name: "Door Index".to_string(),
            description: Some("Complete index of all PhiSHRI doors".to_string()),
            mime_type: Some("application/json".to_string()),
        });

        resources.push(ResourceDefinition {
            uri: "phishri://stats".to_string(),
            name: "Statistics".to_string(),
            description: Some("PhiSHRI knowledge base statistics".to_string()),
            mime_type: Some("application/json".to_string()),
        });

        let result = ResourcesListResult { resources };
        match serde_json::to_value(result) {
            Ok(v) => JsonRpcResponse::success(request.id.clone(), v),
            Err(e) => JsonRpcResponse::error(
                request.id.clone(),
                JsonRpcError::internal_error(e.to_string()),
            ),
        }
    }

    /// Handle resources/read request
    fn handle_resources_read(&self, request: &JsonRpcRequest) -> JsonRpcResponse {
        let params: ResourceReadParams = match request.params_as() {
            Ok(p) => p,
            Err(e) => return JsonRpcResponse::error(request.id.clone(), e.into()),
        };

        let content = if params.uri == "phishri://index" {
            // Return full index
            match self.door_manager.list_doors(None, 1000) {
                Ok(doors) => {
                    let index: Vec<_> = doors.iter().map(|d| {
                        serde_json::json!({
                            "code": d.full_code,
                            "summary": d.summary
                        })
                    }).collect();
                    serde_json::to_string_pretty(&index).unwrap_or_default()
                }
                Err(e) => format!("{{\"error\": \"{}\"}}", e),
            }
        } else if params.uri == "phishri://stats" {
            // Return stats
            let stats = self.door_manager.stats("category");
            serde_json::to_string_pretty(&serde_json::json!({
                "total_doors": stats.total_doors,
                "index_exists": stats.index_exists,
                "by_category": stats.by_category
            })).unwrap_or_default()
        } else if params.uri.starts_with("phishri://category/") {
            // Return doors in category
            let category = params.uri.trim_start_matches("phishri://category/").to_uppercase();
            match self.door_manager.list_doors(Some(&category), 500) {
                Ok(doors) => {
                    let list: Vec<_> = doors.iter().map(|d| {
                        serde_json::json!({
                            "code": d.full_code,
                            "summary": d.summary
                        })
                    }).collect();
                    serde_json::to_string_pretty(&list).unwrap_or_default()
                }
                Err(e) => format!("{{\"error\": \"{}\"}}", e),
            }
        } else if params.uri.starts_with("phishri://door/") {
            // Return specific door
            let door_code = params.uri.trim_start_matches("phishri://door/");
            match self.door_manager.read_door(door_code) {
                Ok(door) => serde_json::to_string_pretty(&door).unwrap_or_default(),
                Err(e) => format!("{{\"error\": \"{}\"}}", e),
            }
        } else {
            format!("{{\"error\": \"Unknown resource: {}\"}}", params.uri)
        };

        let result = ResourceReadResult {
            contents: vec![ResourceReadContent {
                uri: params.uri,
                mime_type: Some("application/json".to_string()),
                text: Some(content),
            }],
        };

        match serde_json::to_value(result) {
            Ok(v) => JsonRpcResponse::success(request.id.clone(), v),
            Err(e) => JsonRpcResponse::error(
                request.id.clone(),
                JsonRpcError::internal_error(e.to_string()),
            ),
        }
    }
}

impl Default for McpServer {
    fn default() -> Self {
        Self::new()
    }
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
        .take(64)
        .collect()
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::mcp::protocol::RequestId;

    #[test]
    fn test_server_creation() {
        let server = McpServer::new();
        assert!(!server.initialized);
        assert_eq!(server.server_info.name, "phishri-mcp");
    }

    #[test]
    fn test_handle_unknown_method() {
        let mut server = McpServer::new();
        let request = JsonRpcRequest {
            jsonrpc: "2.0".to_string(),
            id: Some(RequestId::Number(1)),
            method: "unknown/method".to_string(),
            params: None,
        };

        let response = server.route_request(&request);
        assert!(response.error.is_some());
        assert_eq!(response.error.unwrap().code, -32601);
    }

    #[test]
    fn test_sanitize_id() {
        assert_eq!(sanitize_id("Claude Desktop"), "Claude_Desktop");
        assert_eq!(sanitize_id("test/path"), "test_path");
    }
}
