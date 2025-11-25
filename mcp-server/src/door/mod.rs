//! Door Module
//!
//! Handles PhiSHRI door operations: schema, loading, and management.

pub mod loader;
pub mod manager;
pub mod schema;

pub use loader::{DoorLoader, LoaderError};
pub use manager::DoorManager;
pub use schema::Door;
