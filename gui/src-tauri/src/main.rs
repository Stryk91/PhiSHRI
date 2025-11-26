// Prevents additional console window on Windows in release
#![cfg_attr(not(debug_assertions), windows_subsystem = "windows")]

use serde::{Deserialize, Serialize};
use std::env;
use std::path::PathBuf;
use std::process::Stdio;
use tauri::Emitter;
use tokio::io::{AsyncBufReadExt, BufReader};
use tokio::process::Command;

#[derive(Clone, Serialize)]
struct InstallProgress {
    step: String,
    status: String, // "info", "ok", "warn", "error"
    message: String,
    progress: u8, // 0-100
}

#[derive(Deserialize)]
struct InstallOptions {
    method: String, // "Auto", "Mcpb", "Dxt", "Manual"
}

#[derive(Clone, Serialize)]
struct PlatformInfo {
    os: String,
    arch: String,
    home: String,
    phishri_root: String,
}

/// Get platform information
fn get_platform_info() -> PlatformInfo {
    let os = if cfg!(target_os = "windows") {
        "windows"
    } else if cfg!(target_os = "macos") {
        "macos"
    } else {
        "linux"
    };

    let arch = if cfg!(target_arch = "x86_64") {
        "x64"
    } else if cfg!(target_arch = "aarch64") {
        "arm64"
    } else {
        "unknown"
    };

    let home = get_home_dir();
    let phishri_root = format!("{}/.phishri", home);

    PlatformInfo {
        os: os.to_string(),
        arch: arch.to_string(),
        home,
        phishri_root,
    }
}

/// Get home directory cross-platform
fn get_home_dir() -> String {
    #[cfg(target_os = "windows")]
    {
        env::var("USERPROFILE").unwrap_or_else(|_| "C:\\Users\\Default".to_string())
    }
    #[cfg(not(target_os = "windows"))]
    {
        env::var("HOME").unwrap_or_else(|_| "/tmp".to_string())
    }
}

/// Get PhiSHRI paths for the current platform
fn get_phishri_paths() -> (String, String, String) {
    let info = get_platform_info();

    #[cfg(target_os = "windows")]
    {
        let binary = format!("{}/bin/phishri-mcp.exe", info.phishri_root);
        let knowledge = format!("{}/knowledge/CONTEXTS", info.phishri_root);
        (info.phishri_root, binary, knowledge)
    }

    #[cfg(not(target_os = "windows"))]
    {
        let binary = format!("{}/bin/phishri-mcp", info.phishri_root);
        let knowledge = format!("{}/knowledge/CONTEXTS", info.phishri_root);
        (info.phishri_root, binary, knowledge)
    }
}

#[tauri::command]
fn get_platform() -> PlatformInfo {
    get_platform_info()
}

#[tauri::command]
async fn run_installer(
    options: InstallOptions,
    window: tauri::Window,
) -> Result<String, String> {
    let platform = get_platform_info();

    // Emit starting event
    let _ = window.emit("install-progress", InstallProgress {
        step: "Starting".to_string(),
        status: "info".to_string(),
        message: format!("Starting installation on {} with method: {}", platform.os, options.method),
        progress: 0,
    });

    // Choose installer based on platform
    #[cfg(target_os = "windows")]
    {
        run_windows_installer(options, window).await
    }

    #[cfg(not(target_os = "windows"))]
    {
        run_unix_installer(options, window).await
    }
}

/// Windows installer using PowerShell
#[cfg(target_os = "windows")]
async fn run_windows_installer(
    options: InstallOptions,
    window: tauri::Window,
) -> Result<String, String> {
    let script_url = "https://raw.githubusercontent.com/Stryk91/PhiSHRI/main/install.ps1";

    let ps_command = format!(
        "$ErrorActionPreference = 'Continue'; \
         $script = Invoke-RestMethod -Uri '{}'; \
         $scriptBlock = [ScriptBlock]::Create($script); \
         & $scriptBlock -Method {}",
        script_url,
        options.method
    );

    let mut child = Command::new("powershell")
        .args([
            "-NoProfile",
            "-ExecutionPolicy", "Bypass",
            "-Command", &ps_command,
        ])
        .stdout(Stdio::piped())
        .stderr(Stdio::piped())
        .spawn()
        .map_err(|e| format!("Failed to start PowerShell: {}", e))?;

    process_installer_output(&mut child, window.clone()).await?;

    let status = child.wait().await.map_err(|e| e.to_string())?;
    finish_installation(status.success(), window)
}

/// Unix (Linux/macOS) installer using bash
#[cfg(not(target_os = "windows"))]
async fn run_unix_installer(
    options: InstallOptions,
    window: tauri::Window,
) -> Result<String, String> {
    let script_url = "https://raw.githubusercontent.com/Stryk91/PhiSHRI/main/install.sh";

    // Download and run the script
    let bash_command = format!(
        "curl -fsSL '{}' | bash -s -- --method {}",
        script_url,
        options.method.to_lowercase()
    );

    let mut child = Command::new("bash")
        .args(["-c", &bash_command])
        .stdout(Stdio::piped())
        .stderr(Stdio::piped())
        .spawn()
        .map_err(|e| format!("Failed to start bash: {}", e))?;

    process_installer_output(&mut child, window.clone()).await?;

    let status = child.wait().await.map_err(|e| e.to_string())?;
    finish_installation(status.success(), window)
}

/// Process installer output and emit progress events
async fn process_installer_output(
    child: &mut tokio::process::Child,
    window: tauri::Window,
) -> Result<(), String> {
    let stdout = child.stdout.take()
        .ok_or("Failed to capture stdout")?;

    let stderr = child.stderr.take();

    let mut reader = BufReader::new(stdout).lines();
    let mut progress: u8 = 10;

    // Process stdout
    while let Some(line) = reader.next_line().await.map_err(|e| e.to_string())? {
        let (status, step) = parse_installer_output(&line);

        // Increment progress based on detected steps
        if line.contains("[OK]") || line.contains("OK") {
            progress = (progress + 10).min(95);
        }

        let _ = window.emit("install-progress", InstallProgress {
            step: step.clone(),
            status,
            message: line.clone(),
            progress,
        });
    }

    // Also capture stderr
    if let Some(stderr) = stderr {
        let mut err_reader = BufReader::new(stderr).lines();
        while let Some(line) = err_reader.next_line().await.map_err(|e| e.to_string())? {
            // Skip INFO messages from stderr (our MCP auto-discovery logs there)
            if line.starts_with("[INFO]") {
                let _ = window.emit("install-progress", InstallProgress {
                    step: "Info".to_string(),
                    status: "info".to_string(),
                    message: line,
                    progress,
                });
            } else if !line.trim().is_empty() {
                let _ = window.emit("install-progress", InstallProgress {
                    step: "Output".to_string(),
                    status: "warn".to_string(),
                    message: line,
                    progress,
                });
            }
        }
    }

    Ok(())
}

/// Finish installation and emit final status
fn finish_installation(success: bool, window: tauri::Window) -> Result<String, String> {
    if success {
        let _ = window.emit("install-progress", InstallProgress {
            step: "Complete".to_string(),
            status: "ok".to_string(),
            message: "Installation completed successfully!".to_string(),
            progress: 100,
        });
        Ok("Installation completed successfully".to_string())
    } else {
        let _ = window.emit("install-progress", InstallProgress {
            step: "Failed".to_string(),
            status: "error".to_string(),
            message: "Installation failed. Check logs for details.".to_string(),
            progress: 100,
        });
        Err("Installation failed".to_string())
    }
}

fn parse_installer_output(line: &str) -> (String, String) {
    if line.contains("[OK]") {
        ("ok".to_string(), extract_step(line))
    } else if line.contains("[WARN]") {
        ("warn".to_string(), extract_step(line))
    } else if line.contains("[ERROR]") {
        ("error".to_string(), extract_step(line))
    } else if line.contains("[INFO]") {
        ("info".to_string(), extract_step(line))
    } else {
        ("info".to_string(), "Processing".to_string())
    }
}

fn extract_step(line: &str) -> String {
    let line_lower = line.to_lowercase();

    if line_lower.contains("prerequisite") {
        "Checking prerequisites".to_string()
    } else if line_lower.contains("directory") || line_lower.contains("structure") {
        "Creating directories".to_string()
    } else if line_lower.contains("binary") || line_lower.contains("mcp") || line_lower.contains("build") {
        "Installing MCP binary".to_string()
    } else if line_lower.contains("knowledge") || line_lower.contains("contexts") || line_lower.contains("door") {
        "Installing knowledge base".to_string()
    } else if line_lower.contains("config") || line_lower.contains("claude") {
        "Configuring Claude".to_string()
    } else if line_lower.contains("verif") || line_lower.contains("test") {
        "Verifying installation".to_string()
    } else if line_lower.contains("rust") || line_lower.contains("cargo") {
        "Building from source".to_string()
    } else {
        "Processing".to_string()
    }
}

#[tauri::command]
async fn run_uninstaller(window: tauri::Window) -> Result<String, String> {
    let _ = window.emit("install-progress", InstallProgress {
        step: "Uninstalling".to_string(),
        status: "info".to_string(),
        message: "Removing PhiSHRI...".to_string(),
        progress: 50,
    });

    #[cfg(target_os = "windows")]
    {
        let script_url = "https://raw.githubusercontent.com/Stryk91/PhiSHRI/main/install.ps1";
        let ps_command = format!(
            "$script = Invoke-RestMethod -Uri '{}'; \
             $scriptBlock = [ScriptBlock]::Create($script); \
             & $scriptBlock -Uninstall",
            script_url
        );

        let output = Command::new("powershell")
            .args([
                "-NoProfile",
                "-ExecutionPolicy", "Bypass",
                "-Command", &ps_command,
            ])
            .output()
            .await
            .map_err(|e| format!("Failed to run uninstaller: {}", e))?;

        if output.status.success() {
            emit_uninstall_success(&window);
            Ok("Uninstall completed".to_string())
        } else {
            Err("Uninstall failed".to_string())
        }
    }

    #[cfg(not(target_os = "windows"))]
    {
        let script_url = "https://raw.githubusercontent.com/Stryk91/PhiSHRI/main/install.sh";
        let bash_command = format!(
            "curl -fsSL '{}' | bash -s -- --uninstall",
            script_url
        );

        let output = Command::new("bash")
            .args(["-c", &bash_command])
            .output()
            .await
            .map_err(|e| format!("Failed to run uninstaller: {}", e))?;

        if output.status.success() {
            emit_uninstall_success(&window);
            Ok("Uninstall completed".to_string())
        } else {
            Err("Uninstall failed".to_string())
        }
    }
}

fn emit_uninstall_success(window: &tauri::Window) {
    let _ = window.emit("install-progress", InstallProgress {
        step: "Complete".to_string(),
        status: "ok".to_string(),
        message: "PhiSHRI has been uninstalled".to_string(),
        progress: 100,
    });
}

#[tauri::command]
async fn check_installation() -> Result<serde_json::Value, String> {
    let (root, binary_path, knowledge_path) = get_phishri_paths();

    let binary_exists = std::path::Path::new(&binary_path).exists();
    let knowledge_exists = std::path::Path::new(&knowledge_path).exists();

    // Count doors if knowledge exists
    let door_count = if knowledge_exists {
        count_json_files(&knowledge_path).unwrap_or(0)
    } else {
        0
    };

    let platform = get_platform_info();

    Ok(serde_json::json!({
        "installed": binary_exists && knowledge_exists,
        "binary_exists": binary_exists,
        "knowledge_exists": knowledge_exists,
        "door_count": door_count,
        "platform": {
            "os": platform.os,
            "arch": platform.arch
        },
        "paths": {
            "root": root,
            "binary": binary_path,
            "knowledge": knowledge_path
        }
    }))
}

fn count_json_files(path: &str) -> Result<usize, std::io::Error> {
    let mut count = 0;
    for entry in std::fs::read_dir(path)? {
        let entry = entry?;
        let path = entry.path();
        if path.is_dir() {
            count += count_json_files(path.to_str().unwrap_or(""))?;
        } else if path.extension().map(|e| e == "json").unwrap_or(false) {
            count += 1;
        }
    }
    Ok(count)
}

/// Browse for a custom PhiSHRI path
#[tauri::command]
async fn browse_phishri_path() -> Result<Option<String>, String> {
    // This would ideally use a native file dialog
    // For now, just return None and let the user type it
    Ok(None)
}

/// Set custom PhiSHRI path
#[tauri::command]
async fn set_custom_path(path: String) -> Result<bool, String> {
    let contexts_path = PathBuf::from(&path).join("CONTEXTS");
    if contexts_path.exists() && contexts_path.is_dir() {
        // Valid path - in production we'd save this to config
        Ok(true)
    } else {
        Err(format!("Invalid path: {} does not contain CONTEXTS directory", path))
    }
}

fn main() {
    tauri::Builder::default()
        .plugin(tauri_plugin_shell::init())
        .invoke_handler(tauri::generate_handler![
            run_installer,
            run_uninstaller,
            check_installation,
            get_platform,
            browse_phishri_path,
            set_custom_path,
        ])
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
