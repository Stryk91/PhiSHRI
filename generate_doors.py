#!/usr/bin/env python3
"""
PhiSHRI Door Generator
Creates context bundles for all identified doors
"""

import json
import os
from pathlib import Path
from datetime import datetime
from typing import Dict, List, Optional

class DoorGenerator:
    def __init__(self, base_path: str):
        self.base_path = Path(base_path)
        self.output_dir = self.base_path / "PhiSHRI"
        self.doors = []
        self.semantic_map = {}
        self.hash_table = {}
        self.nlp_patterns = {}
        self.error_matcher = {}
        self.prerequisites = {}
        
        # Load analysis results
        with open(self.base_path / "analysis_results.json", 'r') as f:
            self.analysis = json.load(f)
    
    def generate_door_code(self, category: str, sequence: int, suffix: str = "") -> str:
        """Generate a door code"""
        prefix_map = {
            "TOOLS": "8",
            "DOCS": "D",
            "AGENTS": "A",
            "PROJECTS": "P",
            "WORKFLOWS": "W",
            "ARCHITECTURE": "R",
            "SECURITY": "S",
            "ERRORS": "E"
        }
        
        prefix = prefix_map.get(category, "X")
        code = f"{prefix}{sequence:02d}{suffix}"
        return code
    
    def create_tool_doors(self) -> List[Dict]:
        """Create doors for all tools"""
        doors = []
        
        # Windows MCP File Operations
        doors.append({
            "door_code": "800WINMCP",
            "semantic_path": "TOOLS.WINDOWS_MCP.FILE_OPERATIONS",
            "aliases": ["winmcp_files", "windows_file_ops", "mcp_write", "mcp_read"],
            "context_bundle": {
                "summary": "Windows MCP file operation tools for reading, writing, listing, searching, moving, and deleting files. Includes permission handling, path validation, and error recovery patterns. Essential for file system automation on Windows.",
                "prerequisites": ["800WINMCP_SETUP", "S01PATH"],
                "related_doors": ["801WINMCP_READ", "E01PERM", "E02ENCODE"],
                "onboarding": {
                    "quick_start": "Use Windows MCP for file operations. Always validate paths. Handle UTF-8 encoding explicitly. Check permissions before operations.",
                    "full_context_path": "/PHIiSRHI/MARKDOWNS_/MCP_QUICK_REFERENCE.md",
                    "common_patterns": [
                        "Read file: mcp.file_read(path) with error handling",
                        "Write file: mcp.file_write(path, content, encoding='utf-8')",
                        "List directory: mcp.file_list(path, pattern='*')",
                        "Search files: mcp.file_search(path, query)"
                    ],
                    "known_errors": [
                        {
                            "error": "PermissionError: [WinError 5] Access is denied",
                            "cause": "Insufficient permissions or file locked",
                            "solution": "Check file permissions, ensure file not open, run as admin if needed",
                            "prevention": "Always check os.access() before operations",
                            "related_door": "E01PERM"
                        },
                        {
                            "error": "UnicodeDecodeError on file read",
                            "cause": "File encoding mismatch",
                            "solution": "Specify encoding='utf-8' explicitly",
                            "prevention": "Detect encoding with chardet library",
                            "related_door": "E02ENCODE"
                        }
                    ]
                },
                "resources": {
                    "docs": [
                        "/PHIiSRHI/MARKDOWNS_/MCP_QUICK_REFERENCE.md",
                        "/PHIiSRHI/MARKDOWNS_/MCP_QUICK_START.md",
                        "/PHIiSRHI/MARKDOWNS_/MCP_SERVER_SETUP.md"
                    ],
                    "code": [],
                    "tests": [],
                    "errors": []
                },
                "metadata": {
                    "last_updated": datetime.now().isoformat(),
                    "confidence": 0.95,
                    "usage_count": 0,
                    "success_rate": 0.0,
                    "tags": ["windows", "mcp", "file-io", "automation", "essential"],
                    "category": "TOOLS",
                    "subcategory": "WINDOWS_MCP",
                    "version": "3.0.0",
                    "tested_on": ["Windows 10", "Windows 11"],
                    "agent_affinity": ["DC", "VSCC", "TERMC"]
                }
            }
        })
        
        # AutoHotkey Automation
        doors.append({
            "door_code": "810AHK",
            "semantic_path": "TOOLS.AUTOHOTKEY.AUTOMATION",
            "aliases": ["ahk", "autohotkey", "window_automation", "ui_automation"],
            "context_bundle": {
                "summary": "AutoHotkey automation for Windows UI control, window management, keyboard/mouse simulation, and inter-application messaging. Core tool for DC agent coordination and desktop automation.",
                "prerequisites": [],
                "related_doors": ["A01DC", "W01COORD", "811AHK_MSG"],
                "onboarding": {
                    "quick_start": "Use AutoHotkey for UI automation. Send window messages for coordination. Simulate keyboard/mouse for control. Handle window focus carefully.",
                    "full_context_path": "/PHIiSRHI/LANGUAGE_COORDS/DC_Browser_Messaging.ahk",
                    "common_patterns": [
                        "Window control: WinActivate, WinWait, WinClose",
                        "Input simulation: Send, SendInput, Click",
                        "Message passing: PostMessage, SendMessage",
                        "Hotkeys: Define with :: syntax"
                    ],
                    "known_errors": [
                        {
                            "error": "Window not found",
                            "cause": "Window title changed or not visible",
                            "solution": "Use WinWait with timeout, check window exists",
                            "prevention": "Use partial window matching with SetTitleMatchMode",
                            "related_door": "E10WIN"
                        }
                    ]
                },
                "resources": {
                    "docs": [
                        "/PHIiSRHI/LANGUAGE_COORDS/DC_Browser_Messaging.ahk",
                        "/PHIiSRHI/LANGUAGE_COORDS/DC_VSCC_Messaging.ahk",
                        "/PHIiSRHI/LANGUAGE_COORDS/VSCC_Browser_Messaging.ahk"
                    ],
                    "code": [],
                    "tests": [],
                    "errors": []
                },
                "metadata": {
                    "last_updated": datetime.now().isoformat(),
                    "confidence": 0.90,
                    "usage_count": 0,
                    "success_rate": 0.0,
                    "tags": ["autohotkey", "automation", "windows", "ui", "coordination"],
                    "category": "TOOLS",
                    "subcategory": "AUTOHOTKEY",
                    "version": "1.1",
                    "tested_on": ["Windows 10", "Windows 11"],
                    "agent_affinity": ["DC"]
                }
            }
        })
        
        # PowerShell Coordination
        doors.append({
            "door_code": "820PWSH",
            "semantic_path": "TOOLS.POWERSHELL.COORDINATION",
            "aliases": ["powershell", "ps1", "coordination_engine"],
            "context_bundle": {
                "summary": "PowerShell coordination engine for multi-agent orchestration, state management, workflow control, and token optimization. Core infrastructure for agent communication and task distribution.",
                "prerequisites": [],
                "related_doors": ["W01COORD", "A00STRYK", "R01MULTI"],
                "onboarding": {
                    "quick_start": "Use PowerShell for agent coordination. Manage state with JSON files. Control workflows with modules. Optimize token usage.",
                    "full_context_path": "/PHIiSRHI/LANGUAGE_COORDS/AgentCoordination.psm1",
                    "common_patterns": [
                        "State management: Read/write JSON state files",
                        "Module loading: Import-Module AgentCoordination",
                        "Task distribution: Invoke-AgentTask",
                        "Error recovery: Try-Catch with logging"
                    ],
                    "known_errors": [
                        {
                            "error": "Execution policy restricted",
                            "cause": "PowerShell execution policy blocks scripts",
                            "solution": "Set-ExecutionPolicy RemoteSigned -Scope CurrentUser",
                            "prevention": "Check execution policy before running",
                            "related_door": "E20PWSH"
                        }
                    ]
                },
                "resources": {
                    "docs": [
                        "/PHIiSRHI/LANGUAGE_COORDS/AgentCoordination.psm1",
                        "/PHIiSRHI/LANGUAGE_COORDS/Startup.ps1",
                        "/PHIiSRHI/LANGUAGE_COORDS/VALIDATION_TESTS.ps1"
                    ],
                    "code": [],
                    "tests": [],
                    "errors": []
                },
                "metadata": {
                    "last_updated": datetime.now().isoformat(),
                    "confidence": 0.92,
                    "usage_count": 0,
                    "success_rate": 0.0,
                    "tags": ["powershell", "coordination", "orchestration", "state", "workflow"],
                    "category": "TOOLS",
                    "subcategory": "POWERSHELL",
                    "version": "5.1",
                    "tested_on": ["Windows 10", "Windows 11"],
                    "agent_affinity": ["STRYK", "DC", "VSCC"]
                }
            }
        })
        
        return doors
    
    def create_agent_doors(self) -> List[Dict]:
        """Create doors for all agents"""
        doors = []
        
        # Desktop Claude (DC)
        doors.append({
            "door_code": "A01DC",
            "semantic_path": "AGENTS.DC.COORDINATION",
            "aliases": ["dc", "desktop_claude", "deskc", "desktop_controller"],
            "context_bundle": {
                "summary": "Desktop Claude (DC) is the desktop controller agent responsible for UI automation, window management, cross-application messaging, and agent coordination. Uses AutoHotkey for window control and message routing.",
                "prerequisites": ["810AHK", "820PWSH"],
                "related_doors": ["A02VSCC", "A03TERMC", "W01COORD"],
                "onboarding": {
                    "quick_start": "DC handles UI automation and message routing. Uses AutoHotkey for window control. Coordinates with VSCC and other agents. Manages desktop workflows.",
                    "full_context_path": "/PHIiSRHI/LANGUAGE_COORDS/AGENT_REGISTRY.json",
                    "common_patterns": [
                        "Window automation: Activate, focus, control windows",
                        "Message routing: Send messages between agents",
                        "Input simulation: Keyboard and mouse control",
                        "Coordination: Orchestrate multi-agent workflows"
                    ],
                    "known_errors": []
                },
                "resources": {
                    "docs": [
                        "/PHIiSRHI/LANGUAGE_COORDS/AGENT_REGISTRY.json",
                        "/PHIiSRHI/LANGUAGE_COORDS/DC_Browser_Messaging.ahk",
                        "/PHIiSRHI/LANGUAGE_COORDS/DC_VSCC_Messaging.ahk"
                    ],
                    "code": [],
                    "tests": [],
                    "errors": []
                },
                "metadata": {
                    "last_updated": datetime.now().isoformat(),
                    "confidence": 0.95,
                    "usage_count": 0,
                    "success_rate": 0.0,
                    "tags": ["agent", "dc", "desktop", "coordination", "automation"],
                    "category": "AGENTS",
                    "subcategory": "DC",
                    "version": "1.0",
                    "tested_on": ["Windows 10", "Windows 11"],
                    "agent_affinity": ["DC"]
                }
            }
        })
        
        # VS Code Claude (VSCC)
        doors.append({
            "door_code": "A02VSCC",
            "semantic_path": "AGENTS.VSCC.COORDINATION",
            "aliases": ["vscc", "vscode_claude", "ide_claude", "idec", "editor"],
            "context_bundle": {
                "summary": "VS Code Claude (VSCC/IDEC) is the code editor agent responsible for code generation, file operations, content analysis, and script execution. Works within VS Code IDE with full file system access.",
                "prerequisites": ["800WINMCP"],
                "related_doors": ["A01DC", "A03TERMC", "W01COORD"],
                "onboarding": {
                    "quick_start": "VSCC handles code generation and file operations. Uses VS Code API for editor control. Coordinates with DC for messaging. Manages code workflows.",
                    "full_context_path": "/PHIiSRHI/LANGUAGE_COORDS/AGENT_REGISTRY.json",
                    "common_patterns": [
                        "Code generation: Create and modify files",
                        "File operations: Read, write, search files",
                        "Content analysis: Parse and validate code",
                        "Script execution: Run and test code"
                    ],
                    "known_errors": []
                },
                "resources": {
                    "docs": [
                        "/PHIiSRHI/LANGUAGE_COORDS/AGENT_REGISTRY.json",
                        "/PHIiSRHI/LANGUAGE_COORDS/VSCC_Browser_Messaging.ahk"
                    ],
                    "code": [],
                    "tests": [],
                    "errors": []
                },
                "metadata": {
                    "last_updated": datetime.now().isoformat(),
                    "confidence": 0.95,
                    "usage_count": 0,
                    "success_rate": 0.0,
                    "tags": ["agent", "vscc", "vscode", "editor", "code"],
                    "category": "AGENTS",
                    "subcategory": "VSCC",
                    "version": "1.0",
                    "tested_on": ["Windows 10", "Windows 11"],
                    "agent_affinity": ["VSCC", "IDEC"]
                }
            }
        })
        
        # Terminal Claude (TERMC)
        doors.append({
            "door_code": "A03TERMC",
            "semantic_path": "AGENTS.TERMC.COORDINATION",
            "aliases": ["termc", "terminal_claude", "cli_claude", "terminal"],
            "context_bundle": {
                "summary": "Terminal Claude (TERMC) is the command-line agent responsible for terminal operations, script execution, system commands, and CLI automation. Operates in terminal environment with full system access.",
                "prerequisites": ["820PWSH"],
                "related_doors": ["A01DC", "A02VSCC", "W01COORD"],
                "onboarding": {
                    "quick_start": "TERMC handles terminal operations and CLI automation. Executes system commands. Coordinates with other agents via MCP. Manages terminal workflows.",
                    "full_context_path": "/PHIiSRHI/MARKDOWNS_/AGENT_SYSTEM_COMPLETE.md",
                    "common_patterns": [
                        "Command execution: Run system commands",
                        "Script automation: Execute scripts",
                        "MCP integration: Use MCP tools",
                        "Agent communication: Post messages to hub"
                    ],
                    "known_errors": []
                },
                "resources": {
                    "docs": [
                        "/PHIiSRHI/MARKDOWNS_/AGENT_SYSTEM_COMPLETE.md",
                        "/PHIiSRHI/MARKDOWNS_/MCP_QUICK_REFERENCE.md"
                    ],
                    "code": [],
                    "tests": [],
                    "errors": []
                },
                "metadata": {
                    "last_updated": datetime.now().isoformat(),
                    "confidence": 0.95,
                    "usage_count": 0,
                    "success_rate": 0.0,
                    "tags": ["agent", "termc", "terminal", "cli", "automation"],
                    "category": "AGENTS",
                    "subcategory": "TERMC",
                    "version": "1.0",
                    "tested_on": ["Windows 10", "Windows 11"],
                    "agent_affinity": ["TERMC"]
                }
            }
        })
        
        # STRYK Coordinator
        doors.append({
            "door_code": "A00STRYK",
            "semantic_path": "AGENTS.STRYK.COORDINATION",
            "aliases": ["stryk", "coordinator", "orchestrator", "strategic_coordinator"],
            "context_bundle": {
                "summary": "STRYK is the strategic coordinator agent responsible for workflow orchestration, task distribution, deadlock detection, token optimization, and system health monitoring. Master coordinator for multi-agent systems.",
                "prerequisites": ["820PWSH", "W01COORD"],
                "related_doors": ["A01DC", "A02VSCC", "A03TERMC", "R01MULTI"],
                "onboarding": {
                    "quick_start": "STRYK orchestrates multi-agent workflows. Distributes tasks to agents. Monitors system health. Optimizes token usage. Detects and resolves deadlocks.",
                    "full_context_path": "/PHIiSRHI/LANGUAGE_COORDS/AGENT_REGISTRY.json",
                    "common_patterns": [
                        "Task distribution: Assign tasks to agents",
                        "Workflow orchestration: Coordinate agent activities",
                        "Health monitoring: Track system status",
                        "Token optimization: Minimize token usage"
                    ],
                    "known_errors": []
                },
                "resources": {
                    "docs": [
                        "/PHIiSRHI/LANGUAGE_COORDS/AGENT_REGISTRY.json",
                        "/PHIiSRHI/LANGUAGE_COORDS/coordination_rules.json"
                    ],
                    "code": [],
                    "tests": [],
                    "errors": []
                },
                "metadata": {
                    "last_updated": datetime.now().isoformat(),
                    "confidence": 0.90,
                    "usage_count": 0,
                    "success_rate": 0.0,
                    "tags": ["agent", "stryk", "coordinator", "orchestration", "strategy"],
                    "category": "AGENTS",
                    "subcategory": "STRYK",
                    "version": "1.0",
                    "tested_on": ["Windows 10", "Windows 11"],
                    "agent_affinity": ["STRYK"]
                }
            }
        })
        
        return doors
    
    def create_project_doors(self) -> List[Dict]:
        """Create doors for all projects"""
        doors = []
        
        # PhiWave
        doors.append({
            "door_code": "P01WAVE",
            "semantic_path": "PROJECTS.PHIWAVE.OVERVIEW",
            "aliases": ["phiwave", "audio_project", "binaural"],
            "context_bundle": {
                "summary": "PhiWave is a multi-agent audio processing project featuring binaural audio generation, preset management, and GUI interface. Uses agent hub for coordination and MCP for tool integration.",
                "prerequisites": ["800WINMCP", "A03TERMC"],
                "related_doors": ["P02GEN", "W01COORD"],
                "onboarding": {
                    "quick_start": "PhiWave handles audio processing with multi-agent coordination. Uses MCP agent hub for communication. Implements binaural audio generation with custom presets.",
                    "full_context_path": "/PHIiSRHI/MARKDOWNS_/AGENT_SYSTEM_COMPLETE.md",
                    "common_patterns": [
                        "Agent communication: Use MCP agent hub",
                        "Audio processing: Generate binaural audio",
                        "Preset management: Load and save presets",
                        "GUI interaction: Control via interface"
                    ],
                    "known_errors": []
                },
                "resources": {
                    "docs": [
                        "/PHIiSRHI/MARKDOWNS_/AGENT_SYSTEM_COMPLETE.md",
                        "/PHIiSRHI/INFO_FROM_OTHER_DRIVE_ENV_PROJ/README.md"
                    ],
                    "code": [],
                    "tests": [],
                    "errors": []
                },
                "metadata": {
                    "last_updated": datetime.now().isoformat(),
                    "confidence": 0.85,
                    "usage_count": 0,
                    "success_rate": 0.0,
                    "tags": ["project", "phiwave", "audio", "binaural", "multi-agent"],
                    "category": "PROJECTS",
                    "subcategory": "PHIWAVE",
                    "version": "1.0",
                    "tested_on": ["Windows 10", "Windows 11"],
                    "agent_affinity": ["TERMC", "IDEC", "Junie"]
                }
            }
        })
        
        # PhiVector
        doors.append({
            "door_code": "P03VECTOR",
            "semantic_path": "PROJECTS.PHIVECTOR.OVERVIEW",
            "aliases": ["phivector", "orchestration", "multi_agent_system"],
            "context_bundle": {
                "summary": "PhiVector is the multi-agent AI orchestration platform enabling instant AI onboarding, agent coordination, and workflow automation. Core infrastructure for agent-based development.",
                "prerequisites": ["A00STRYK", "W01COORD", "R01MULTI"],
                "related_doors": ["P01WAVE", "P02GEN", "P04SHRI"],
                "onboarding": {
                    "quick_start": "PhiVector orchestrates multi-agent AI systems. Enables instant onboarding with minimal instruction. Coordinates agents across platforms. Automates workflows.",
                    "full_context_path": "/PHIiSRHI/MARKDOWNS_/AI_CODER_ENCYCLOPEDIA.md",
                    "common_patterns": [
                        "Agent coordination: Orchestrate multiple agents",
                        "Instant onboarding: Load context quickly",
                        "Workflow automation: Automate development tasks",
                        "Cross-platform: Work across Windows, Linux, etc."
                    ],
                    "known_errors": []
                },
                "resources": {
                    "docs": [
                        "/PHIiSRHI/MARKDOWNS_/AI_CODER_ENCYCLOPEDIA.md",
                        "/PHIiSRHI/LANGUAGE_COORDS/ARCHITECTURE.md"
                    ],
                    "code": [],
                    "tests": [],
                    "errors": []
                },
                "metadata": {
                    "last_updated": datetime.now().isoformat(),
                    "confidence": 0.95,
                    "usage_count": 0,
                    "success_rate": 0.0,
                    "tags": ["project", "phivector", "orchestration", "multi-agent", "platform"],
                    "category": "PROJECTS",
                    "subcategory": "PHIVECTOR",
                    "version": "1.0",
                    "tested_on": ["Windows 10", "Windows 11"],
                    "agent_affinity": ["STRYK", "DC", "VSCC", "TERMC"]
                }
            }
        })
        
        # PhiSHRI/PhiDOOR
        doors.append({
            "door_code": "P04SHRI",
            "semantic_path": "PROJECTS.PHISHRI.OVERVIEW",
            "aliases": ["phishri", "phidoor", "keymaster", "semantic_index"],
            "context_bundle": {
                "summary": "PhiSHRI (Semantic Hash Repository Index) is the keymaster's index system enabling instant AI agent onboarding through semantic navigation. Provides 3-layer addressing: semantic paths, hash codes, and natural language queries.",
                "prerequisites": [],
                "related_doors": ["P03VECTOR", "R01MULTI"],
                "onboarding": {
                    "quick_start": "PhiSHRI provides instant context loading for AI agents. Use hash codes, semantic paths, or natural language to find doors. Each door contains complete onboarding context.",
                    "full_context_path": "/PhiDOOR/CEREBRAS_COMPLETE_PROMPT.md",
                    "common_patterns": [
                        "Hash lookup: findDoor('827HHWINC#')",
                        "Semantic path: findDoor('TOOLS.WINDOWS_MCP.FILE_OPERATIONS')",
                        "Natural language: findDoor('how to write files on windows')",
                        "Error-driven: Auto-navigate from error patterns"
                    ],
                    "known_errors": []
                },
                "resources": {
                    "docs": [
                        "/PhiDOOR/CEREBRAS_COMPLETE_PROMPT.md",
                        "/docs/COMBINED_DOCUMENTATION_SUMMARY.md"
                    ],
                    "code": [],
                    "tests": [],
                    "errors": []
                },
                "metadata": {
                    "last_updated": datetime.now().isoformat(),
                    "confidence": 1.0,
                    "usage_count": 0,
                    "success_rate": 0.0,
                    "tags": ["project", "phishri", "phidoor", "index", "navigation", "keymaster"],
                    "category": "PROJECTS",
                    "subcategory": "PHISHRI",
                    "version": "1.0",
                    "tested_on": ["All platforms"],
                    "agent_affinity": ["ALL"]
                }
            }
        })
        
        return doors
    
    def create_workflow_doors(self) -> List[Dict]:
        """Create doors for workflows"""
        doors = []
        
        # Agent Coordination Workflow
        doors.append({
            "door_code": "W01COORD",
            "semantic_path": "WORKFLOWS.AGENT_COORDINATION.MULTI_AGENT",
            "aliases": ["coordination", "multi_agent_workflow", "orchestration"],
            "context_bundle": {
                "summary": "Multi-agent coordination workflow for orchestrating tasks across DC, VSCC, TERMC, and other agents. Includes turn-based execution, state management, message passing, and error recovery.",
                "prerequisites": ["A00STRYK", "A01DC", "A02VSCC", "A03TERMC"],
                "related_doors": ["R01MULTI", "820PWSH", "810AHK"],
                "onboarding": {
                    "quick_start": "Coordinate multiple agents with turn-based workflow. Use PowerShell for state management. AutoHotkey for message passing. JSON for task queues. Handle errors gracefully.",
                    "full_context_path": "/PHIiSRHI/LANGUAGE_COORDS/ARCHITECTURE.md",
                    "common_patterns": [
                        "Turn-based execution: One agent at a time",
                        "State management: JSON state files",
                        "Message passing: File IPC and AutoHotkey",
                        "Error recovery: Retry with exponential backoff"
                    ],
                    "known_errors": []
                },
                "resources": {
                    "docs": [
                        "/PHIiSRHI/LANGUAGE_COORDS/ARCHITECTURE.md",
                        "/PHIiSRHI/LANGUAGE_COORDS/coordination_rules.json",
                        "/PHIiSRHI/MARKDOWNS_/AI_CODER_ENCYCLOPEDIA.md"
                    ],
                    "code": [],
                    "tests": [],
                    "errors": []
                },
                "metadata": {
                    "last_updated": datetime.now().isoformat(),
                    "confidence": 0.92,
                    "usage_count": 0,
                    "success_rate": 0.0,
                    "tags": ["workflow", "coordination", "multi-agent", "orchestration"],
                    "category": "WORKFLOWS",
                    "subcategory": "COORDINATION",
                    "version": "1.0",
                    "tested_on": ["Windows 10", "Windows 11"],
                    "agent_affinity": ["STRYK", "DC", "VSCC", "TERMC"]
                }
            }
        })
        
        return doors
    
    def create_architecture_doors(self) -> List[Dict]:
        """Create doors for architecture patterns"""
        doors = []
        
        # Multi-Agent Architecture
        doors.append({
            "door_code": "R01MULTI",
            "semantic_path": "ARCHITECTURE.MULTI_AGENT.DESIGN",
            "aliases": ["multi_agent_architecture", "agent_design", "system_architecture"],
            "context_bundle": {
                "summary": "Multi-agent system architecture with specialized agents (planner, coder, tester), shared state via JSONL, turn-based coordination, and token optimization. Core design pattern for PhiVector.",
                "prerequisites": [],
                "related_doors": ["W01COORD", "A00STRYK", "P03VECTOR"],
                "onboarding": {
                    "quick_start": "Design multi-agent systems with specialized roles. Use shared state for coordination. Implement turn-based execution. Optimize token usage. Enable error autonomy.",
                    "full_context_path": "/PHIiSRHI/MARKDOWNS_/AI_CODER_ENCYCLOPEDIA.md",
                    "common_patterns": [
                        "Agent specialization: Planner, coder, tester roles",
                        "Shared state: JSONL or JSON files",
                        "Turn-based: Sequential execution",
                        "Token optimization: Minimize context"
                    ],
                    "known_errors": []
                },
                "resources": {
                    "docs": [
                        "/PHIiSRHI/MARKDOWNS_/AI_CODER_ENCYCLOPEDIA.md",
                        "/PHIiSRHI/LANGUAGE_COORDS/ARCHITECTURE.md"
                    ],
                    "code": [],
                    "tests": [],
                    "errors": []
                },
                "metadata": {
                    "last_updated": datetime.now().isoformat(),
                    "confidence": 0.95,
                    "usage_count": 0,
                    "success_rate": 0.0,
                    "tags": ["architecture", "multi-agent", "design", "pattern"],
                    "category": "ARCHITECTURE",
                    "subcategory": "MULTI_AGENT",
                    "version": "1.0",
                    "tested_on": ["All platforms"],
                    "agent_affinity": ["ALL"]
                }
            }
        })
        
        return doors
    
    def create_error_doors(self) -> List[Dict]:
        """Create doors for common errors"""
        doors = []
        
        # Permission Errors
        doors.append({
            "door_code": "E01PERM",
            "semantic_path": "ERRORS.PERMISSIONS.WINDOWS",
            "aliases": ["permission_error", "access_denied", "winError_5"],
            "context_bundle": {
                "summary": "Windows permission errors (WinError 5: Access Denied) caused by insufficient permissions, locked files, or admin requirements. Common in file operations and system commands.",
                "prerequisites": [],
                "related_doors": ["800WINMCP", "820PWSH"],
                "onboarding": {
                    "quick_start": "Permission errors occur when accessing restricted resources. Check file permissions with os.access(). Ensure files not locked. Run as admin if needed. Handle gracefully.",
                    "full_context_path": "",
                    "common_patterns": [
                        "Check permissions: os.access(path, os.W_OK)",
                        "Handle locked files: Retry with delay",
                        "Admin elevation: Run as administrator",
                        "Graceful degradation: Fallback to read-only"
                    ],
                    "known_errors": [
                        {
                            "error": "PermissionError: [WinError 5] Access is denied",
                            "cause": "Insufficient permissions or file locked",
                            "solution": "Check permissions, ensure file not open, run as admin",
                            "prevention": "Always check os.access() before operations",
                            "related_door": "800WINMCP"
                        }
                    ]
                },
                "resources": {
                    "docs": [],
                    "code": [],
                    "tests": [],
                    "errors": []
                },
                "metadata": {
                    "last_updated": datetime.now().isoformat(),
                    "confidence": 0.95,
                    "usage_count": 0,
                    "success_rate": 0.0,
                    "tags": ["error", "permission", "windows", "access_denied"],
                    "category": "ERRORS",
                    "subcategory": "PERMISSIONS",
                    "version": "1.0",
                    "tested_on": ["Windows 10", "Windows 11"],
                    "agent_affinity": ["ALL"]
                }
            }
        })
        
        # Encoding Errors
        doors.append({
            "door_code": "E02ENCODE",
            "semantic_path": "ERRORS.ENCODING.UTF8",
            "aliases": ["encoding_error", "unicode_error", "utf8"],
            "context_bundle": {
                "summary": "Unicode/encoding errors (UnicodeDecodeError, UnicodeEncodeError) caused by file encoding mismatches, especially with PowerShell and Windows file operations. Always specify UTF-8 explicitly.",
                "prerequisites": [],
                "related_doors": ["800WINMCP", "820PWSH"],
                "onboarding": {
                    "quick_start": "Encoding errors occur with non-UTF-8 files. Always specify encoding='utf-8' explicitly. Use errors='ignore' or 'replace' for binary. Detect encoding with chardet.",
                    "full_context_path": "",
                    "common_patterns": [
                        "Explicit encoding: open(file, encoding='utf-8')",
                        "Error handling: errors='ignore' or 'replace'",
                        "Encoding detection: chardet.detect()",
                        "PowerShell: Use [Console]::OutputEncoding = [System.Text.Encoding]::UTF8"
                    ],
                    "known_errors": [
                        {
                            "error": "UnicodeDecodeError on file read",
                            "cause": "File encoding mismatch",
                            "solution": "Specify encoding='utf-8' explicitly",
                            "prevention": "Detect encoding with chardet library",
                            "related_door": "800WINMCP"
                        }
                    ]
                },
                "resources": {
                    "docs": [],
                    "code": [],
                    "tests": [],
                    "errors": []
                },
                "metadata": {
                    "last_updated": datetime.now().isoformat(),
                    "confidence": 0.95,
                    "usage_count": 0,
                    "success_rate": 0.0,
                    "tags": ["error", "encoding", "unicode", "utf8"],
                    "category": "ERRORS",
                    "subcategory": "ENCODING",
                    "version": "1.0",
                    "tested_on": ["Windows 10", "Windows 11"],
                    "agent_affinity": ["ALL"]
                }
            }
        })
        
        return doors
    
    def generate_all_doors(self):
        """Generate all context bundles"""
        print("Generating context bundles...")
        
        # Generate doors for each category
        tool_doors = self.create_tool_doors()
        agent_doors = self.create_agent_doors()
        project_doors = self.create_project_doors()
        workflow_doors = self.create_workflow_doors()
        architecture_doors = self.create_architecture_doors()
        error_doors = self.create_error_doors()
        
        all_doors = (
            tool_doors + agent_doors + project_doors + 
            workflow_doors + architecture_doors + error_doors
        )
        
        print(f"Generated {len(all_doors)} doors:")
        print(f"  - Tools: {len(tool_doors)}")
        print(f"  - Agents: {len(agent_doors)}")
        print(f"  - Projects: {len(project_doors)}")
        print(f"  - Workflows: {len(workflow_doors)}")
        print(f"  - Architecture: {len(architecture_doors)}")
        print(f"  - Errors: {len(error_doors)}")
        
        return all_doors
    
    def save_doors(self, doors: List[Dict]):
        """Save all doors to files"""
        print("\nSaving context bundles...")
        
        for door in doors:
            category = door['context_bundle']['metadata']['category']
            door_code = door['door_code']
            
            # Determine output directory
            output_dir = self.output_dir / "CONTEXTS" / category
            output_dir.mkdir(parents=True, exist_ok=True)
            
            # Save door
            output_file = output_dir / f"{door_code}.json"
            with open(output_file, 'w', encoding='utf-8') as f:
                json.dump(door, f, indent=2)
            
            # Update mappings
            self.semantic_map[door['semantic_path']] = door_code
            self.hash_table[door_code] = str(output_file.relative_to(self.output_dir))
            
            # Add aliases to semantic map
            for alias in door['aliases']:
                self.semantic_map[alias] = door_code
        
        print(f"Saved {len(doors)} context bundles")
    
    def build_semantic_map(self):
        """Build and save semantic map"""
        output_file = self.output_dir / "INDEXES" / "SEMANTIC_MAP.json"
        output_file.parent.mkdir(parents=True, exist_ok=True)
        
        with open(output_file, 'w', encoding='utf-8') as f:
            json.dump({
                "version": "1.0.0",
                "description": "Maps semantic paths and aliases to door codes",
                "total_mappings": len(self.semantic_map),
                "mappings": self.semantic_map
            }, f, indent=2)
        
        print(f"Built semantic map with {len(self.semantic_map)} mappings")
    
    def build_hash_table(self):
        """Build and save hash table"""
        output_file = self.output_dir / "INDEXES" / "HASH_TABLE.json"
        
        with open(output_file, 'w', encoding='utf-8') as f:
            json.dump({
                "version": "1.0.0",
                "description": "Maps door codes to context bundle file paths",
                "total_doors": len(self.hash_table),
                "mappings": self.hash_table
            }, f, indent=2)
        
        print(f"Built hash table with {len(self.hash_table)} entries")
    
    def update_index(self, doors: List[Dict]):
        """Update master INDEX.json"""
        index_file = self.output_dir / "INDEX.json"
        
        with open(index_file, 'r') as f:
            index = json.load(f)
        
        # Count doors by category
        category_counts = {}
        for door in doors:
            category = door['context_bundle']['metadata']['category']
            category_counts[category] = category_counts.get(category, 0) + 1
        
        # Update index
        index['total_doors'] = len(doors)
        index['last_updated'] = datetime.now().isoformat()
        
        for category, count in category_counts.items():
            if category in index['categories']:
                index['categories'][category]['count'] = count
        
        # Save updated index
        with open(index_file, 'w', encoding='utf-8') as f:
            json.dump(index, f, indent=2)
        
        print(f"Updated INDEX.json with {len(doors)} total doors")

def main():
    generator = DoorGenerator('/workspace/PhiSHRI')
    
    print("=" * 60)
    print("PhiSHRI Door Generator")
    print("=" * 60)
    
    # Generate all doors
    doors = generator.generate_all_doors()
    
    # Save doors
    generator.save_doors(doors)
    
    # Build indexes
    generator.build_semantic_map()
    generator.build_hash_table()
    
    # Update master index
    generator.update_index(doors)
    
    print("\n" + "=" * 60)
    print("Door generation complete!")
    print("=" * 60)

if __name__ == '__main__':
    main()