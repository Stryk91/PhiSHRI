//! MCP (Model Context Protocol) Implementation
//!
//! Clean-room implementation of the MCP protocol for PhiSHRI.

pub mod protocol;
pub mod server;
pub mod tools;

pub use server::McpServer;
