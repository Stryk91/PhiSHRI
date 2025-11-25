//! PhiSHRI MCP Server
//!
//! Universal AI session continuity via semantic door codes.
//!
//! This is the main entry point for the PhiSHRI MCP server.
//! It initializes logging and starts the stdio-based MCP server.
//!
//! Authors: STRYK, VSCC
//! License: MIT

mod config;
mod door;
mod mcp;

use mcp::McpServer;
use std::io::{self, IsTerminal};
use tracing::Level;
use tracing_subscriber::fmt::format::FmtSpan;

fn main() -> io::Result<()> {
    // Initialize logging to stderr (stdout is reserved for MCP protocol)
    // Only enable if PHISHRI_LOG env var is set, to avoid polluting MCP output
    if std::env::var("PHISHRI_LOG").is_ok() {
        tracing_subscriber::fmt()
            .with_writer(io::stderr)
            .with_max_level(Level::DEBUG)
            .with_span_events(FmtSpan::CLOSE)
            .with_target(false)
            .with_ansi(io::stderr().is_terminal())
            .init();
    }

    // Create and run the MCP server
    let mut server = McpServer::new();
    server.run()
}
