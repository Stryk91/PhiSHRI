# ============================================================================
# SWE-BENCH + PHISHRI BENCHMARK SETUP
# ============================================================================
# This script sets up the complete SWE-bench testing environment with:
# - Python virtual environment
# - SWE-ReX runtime
# - SWE-bench dataset
# - Integration hooks for PhiSHRI MCP chain
#
# Run from PowerShell as: .\setup-swe-bench.ps1
# ============================================================================

$ErrorActionPreference = "Stop"
$BENCHMARK_ROOT = "C:\SWE-Bench"
$VENV_PATH = "$BENCHMARK_ROOT\venv"
$REPOS_PATH = "$BENCHMARK_ROOT\repos"
$RESULTS_PATH = "$BENCHMARK_ROOT\results"

Write-Host @"
╔══════════════════════════════════════════════════════════════════════════════╗
║                    SWE-BENCH + PHISHRI SETUP                                 ║
╚══════════════════════════════════════════════════════════════════════════════╝
"@ -ForegroundColor Cyan

# ============================================================================
# STEP 1: Create directory structure
# ============================================================================
Write-Host "`n[1/6] Creating directory structure..." -ForegroundColor Yellow

$dirs = @($BENCHMARK_ROOT, $REPOS_PATH, $RESULTS_PATH, "$BENCHMARK_ROOT\logs")
foreach ($dir in $dirs) {
    if (!(Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
        Write-Host "  Created: $dir" -ForegroundColor Green
    } else {
        Write-Host "  Exists: $dir" -ForegroundColor DarkGray
    }
}

# ============================================================================
# STEP 2: Check Python installation
# ============================================================================
Write-Host "`n[2/6] Checking Python installation..." -ForegroundColor Yellow

$pythonVersion = python --version 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "  ERROR: Python not found. Install Python 3.10+ first." -ForegroundColor Red
    Write-Host "  Run: winget install Python.Python.3.11" -ForegroundColor Yellow
    exit 1
}
Write-Host "  Found: $pythonVersion" -ForegroundColor Green

# ============================================================================
# STEP 3: Create virtual environment
# ============================================================================
Write-Host "`n[3/6] Creating virtual environment..." -ForegroundColor Yellow

if (!(Test-Path "$VENV_PATH\Scripts\activate.ps1")) {
    python -m venv $VENV_PATH
    Write-Host "  Created venv at: $VENV_PATH" -ForegroundColor Green
} else {
    Write-Host "  Venv already exists" -ForegroundColor DarkGray
}

# Activate venv
& "$VENV_PATH\Scripts\Activate.ps1"
Write-Host "  Activated virtual environment" -ForegroundColor Green

# ============================================================================
# STEP 4: Install dependencies
# ============================================================================
Write-Host "`n[4/6] Installing Python dependencies..." -ForegroundColor Yellow

$packages = @(
    "swe-rex",
    "datasets",
    "huggingface_hub",
    "GitPython",
    "pytest",
    "rich",
    "click"
)

foreach ($pkg in $packages) {
    Write-Host "  Installing $pkg..." -ForegroundColor DarkGray
    pip install $pkg --quiet
}
Write-Host "  All packages installed" -ForegroundColor Green

# ============================================================================
# STEP 5: Download SWE-bench dataset info
# ============================================================================
Write-Host "`n[5/6] Preparing SWE-bench dataset access..." -ForegroundColor Yellow

$datasetScript = @"
from datasets import load_dataset
import json

# Load SWE-bench Lite (300 issues - good for testing)
print("Loading SWE-bench Lite dataset info...")
ds = load_dataset("princeton-nlp/SWE-bench_Lite", split="test")
print(f"Dataset loaded: {len(ds)} instances")

# Save instance IDs for reference
instances = [{"id": item["instance_id"], "repo": item["repo"]} for item in ds]
with open(r"$BENCHMARK_ROOT\swe_bench_lite_instances.json", "w") as f:
    json.dump(instances, f, indent=2)
print(f"Instance list saved to swe_bench_lite_instances.json")

# Show repo distribution
repos = {}
for item in ds:
    repo = item["repo"]
    repos[repo] = repos.get(repo, 0) + 1

print("\nRepository distribution:")
for repo, count in sorted(repos.items(), key=lambda x: -x[1]):
    print(f"  {repo}: {count} issues")
"@

$datasetScript | Out-File -FilePath "$BENCHMARK_ROOT\load_dataset.py" -Encoding UTF8
python "$BENCHMARK_ROOT\load_dataset.py"

# ============================================================================
# STEP 6: Create benchmark runner script
# ============================================================================
Write-Host "`n[6/6] Creating benchmark runner..." -ForegroundColor Yellow

$runnerScript = @'
#!/usr/bin/env python3
"""
SWE-Bench + PhiSHRI Benchmark Runner

This script runs SWE-bench evaluations with MCP integration.
MCPs are called via subprocess to maintain independence.

Usage:
    python run_benchmark.py --instances 10 --output results.json
"""

import argparse
import json
import subprocess
import time
from pathlib import Path
from datetime import datetime
from datasets import load_dataset
from rich.console import Console
from rich.progress import Progress, SpinnerColumn, TextColumn
from rich.table import Table

console = Console()

# ============================================================================
# MCP Integration Helpers
# ============================================================================

def call_mcp_tool(server: str, tool: str, args: dict) -> dict:
    """
    Call an MCP tool via the MCP CLI or direct invocation.
    Adjust this based on your MCP setup.
    """
    # This is a placeholder - actual implementation depends on your MCP setup
    # Option 1: If MCPs expose HTTP endpoints (via ClaudeBridge)
    # Option 2: Direct stdio communication
    # Option 3: Via Claude Desktop (manual)

    # For now, return a marker that MCP should be called
    return {"_mcp_call": server, "tool": tool, "args": args}


def phishri_search(query: str) -> list:
    """Search PhiSHRI for relevant doors."""
    # In actual use, this calls phishri MCP
    # For benchmark, we preload doors based on repo
    door_mapping = {
        "django": ["F01DJANGO_PATTERNS", "F02DJANGO_ERRORS", "L60PYTHON_COMMON_ERRORS"],
        "flask": ["F03FLASK_PATTERNS", "L60PYTHON_COMMON_ERRORS"],
        "requests": ["L60PYTHON_COMMON_ERRORS", "E50PYTHON_DEBUG_PATTERNS"],
        "scikit-learn": ["L60PYTHON_COMMON_ERRORS", "E50PYTHON_DEBUG_PATTERNS"],
        "sympy": ["L60PYTHON_COMMON_ERRORS", "E50PYTHON_DEBUG_PATTERNS"],
    }

    for key, doors in door_mapping.items():
        if key in query.lower():
            return doors
    return ["W80SWE_BENCH_STRATEGY", "L60PYTHON_COMMON_ERRORS"]


def everything_search(pattern: str, path: str = None) -> list:
    """Search for files using Everything MCP."""
    # Placeholder - actual implementation calls Everything MCP
    return {"_mcp_call": "everything", "tool": "search", "args": {"query": pattern}}


# ============================================================================
# Benchmark Logic
# ============================================================================

def load_benchmark_instances(limit: int = None, dataset: str = "Lite") -> list:
    """Load SWE-bench instances."""
    ds_name = f"princeton-nlp/SWE-bench_{dataset}"
    console.print(f"[yellow]Loading {ds_name}...[/yellow]")

    ds = load_dataset(ds_name, split="test")
    instances = list(ds)

    if limit:
        instances = instances[:limit]

    console.print(f"[green]Loaded {len(instances)} instances[/green]")
    return instances


def prepare_instance(instance: dict) -> dict:
    """Prepare an instance for solving."""
    return {
        "instance_id": instance["instance_id"],
        "repo": instance["repo"],
        "base_commit": instance["base_commit"],
        "problem_statement": instance["problem_statement"],
        "hints_text": instance.get("hints_text", ""),
        "test_patch": instance["test_patch"],
        # Preload relevant PhiSHRI doors
        "phishri_doors": phishri_search(instance["repo"]),
    }


def solve_instance(instance: dict, use_mcps: bool = True) -> dict:
    """
    Solve a single SWE-bench instance.

    This is where Claude + MCPs would actually solve the problem.
    For benchmarking, this needs to integrate with your agent loop.
    """
    start_time = time.time()

    result = {
        "instance_id": instance["instance_id"],
        "repo": instance["repo"],
        "start_time": datetime.now().isoformat(),
        "mcps_used": use_mcps,
        "doors_loaded": instance.get("phishri_doors", []),
        "model_patch": None,
        "success": False,
        "error": None,
        "duration_seconds": 0,
    }

    try:
        # ================================================================
        # THIS IS WHERE YOUR AGENT LOGIC GOES
        # ================================================================
        #
        # Option 1: Claude Desktop (manual)
        #   - Print instance details
        #   - User copies to Claude
        #   - Claude solves with MCPs
        #   - User pastes back the patch
        #
        # Option 2: Claude API + MCPs
        #   - Call Claude API with instance
        #   - Claude uses MCP tools
        #   - Get patch from response
        #
        # Option 3: SWE-ReX integration
        #   - Use SWE-ReX to manage sandbox
        #   - Claude generates commands
        #   - SWE-ReX executes and returns results
        #
        # For now, we output what would be sent to Claude:
        # ================================================================

        prompt = f"""
# SWE-Bench Instance: {instance['instance_id']}

## Problem Statement
{instance['problem_statement']}

## Hints
{instance.get('hints_text', 'None provided')}

## Repository
{instance['repo']} @ {instance['base_commit']}

## Pre-loaded Knowledge (PhiSHRI Doors)
{', '.join(instance.get('phishri_doors', []))}

## Instructions
1. Load the relevant PhiSHRI doors for context
2. Use Everything MCP to find relevant files
3. Follow W80 SWE_BENCH_STRATEGY workflow
4. Output a git diff patch that fixes the issue
"""

        # For actual benchmark, this would call Claude
        # For now, mark as needing manual intervention
        result["prompt"] = prompt
        result["status"] = "awaiting_solution"

    except Exception as e:
        result["error"] = str(e)
        result["status"] = "error"

    result["duration_seconds"] = time.time() - start_time
    return result


def run_benchmark(
    num_instances: int = 10,
    use_mcps: bool = True,
    output_file: str = "benchmark_results.json",
    dataset: str = "Lite"
):
    """Run the full benchmark."""

    console.print("\n[bold cyan]═══ SWE-BENCH + PHISHRI BENCHMARK ═══[/bold cyan]\n")

    # Load instances
    instances = load_benchmark_instances(limit=num_instances, dataset=dataset)

    results = {
        "benchmark_start": datetime.now().isoformat(),
        "config": {
            "num_instances": num_instances,
            "use_mcps": use_mcps,
            "dataset": dataset,
        },
        "instances": [],
        "summary": {}
    }

    # Process each instance
    with Progress(
        SpinnerColumn(),
        TextColumn("[progress.description]{task.description}"),
        console=console,
    ) as progress:
        task = progress.add_task("Processing instances...", total=num_instances)

        for i, instance in enumerate(instances):
            prepared = prepare_instance(instance)
            result = solve_instance(prepared, use_mcps=use_mcps)
            results["instances"].append(result)
            progress.update(task, advance=1, description=f"[{i+1}/{num_instances}] {instance['instance_id'][:50]}...")

    # Calculate summary
    results["benchmark_end"] = datetime.now().isoformat()
    results["summary"] = {
        "total": len(results["instances"]),
        "solved": sum(1 for r in results["instances"] if r.get("success")),
        "errors": sum(1 for r in results["instances"] if r.get("error")),
        "awaiting": sum(1 for r in results["instances"] if r.get("status") == "awaiting_solution"),
    }

    # Save results
    output_path = Path(output_file)
    with open(output_path, "w") as f:
        json.dump(results, f, indent=2)

    console.print(f"\n[green]Results saved to: {output_path}[/green]")

    # Display summary
    table = Table(title="Benchmark Summary")
    table.add_column("Metric", style="cyan")
    table.add_column("Value", style="green")

    table.add_row("Total Instances", str(results["summary"]["total"]))
    table.add_row("Solved", str(results["summary"]["solved"]))
    table.add_row("Errors", str(results["summary"]["errors"]))
    table.add_row("Awaiting Solution", str(results["summary"]["awaiting"]))

    console.print(table)

    return results


# ============================================================================
# CLI
# ============================================================================

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="SWE-Bench + PhiSHRI Benchmark Runner")
    parser.add_argument("--instances", "-n", type=int, default=10, help="Number of instances to run")
    parser.add_argument("--output", "-o", type=str, default="benchmark_results.json", help="Output file")
    parser.add_argument("--no-mcps", action="store_true", help="Run without MCP integration (baseline)")
    parser.add_argument("--dataset", choices=["Lite", "Verified", "Full"], default="Lite", help="Dataset to use")

    args = parser.parse_args()

    run_benchmark(
        num_instances=args.instances,
        use_mcps=not args.no_mcps,
        output_file=args.output,
        dataset=args.dataset,
    )
'@

$runnerScript | Out-File -FilePath "$BENCHMARK_ROOT\run_benchmark.py" -Encoding UTF8
Write-Host "  Created: run_benchmark.py" -ForegroundColor Green

# ============================================================================
# Create activation helper
# ============================================================================

$activateHelper = @"
# SWE-Bench Environment Activation
# Run: . .\activate-swe-bench.ps1

`$env:SWE_BENCH_ROOT = "$BENCHMARK_ROOT"
& "$VENV_PATH\Scripts\Activate.ps1"

Write-Host ""
Write-Host "SWE-Bench environment activated!" -ForegroundColor Green
Write-Host ""
Write-Host "Commands:" -ForegroundColor Cyan
Write-Host "  python run_benchmark.py -n 10      # Run 10 instances"
Write-Host "  python run_benchmark.py --no-mcps  # Baseline (no MCPs)"
Write-Host "  python run_benchmark.py -n 50 -o results_with_mcps.json"
Write-Host ""
"@

$activateHelper | Out-File -FilePath "$BENCHMARK_ROOT\activate-swe-bench.ps1" -Encoding UTF8

# ============================================================================
# Summary
# ============================================================================

Write-Host @"

╔══════════════════════════════════════════════════════════════════════════════╗
║                    SETUP COMPLETE                                            ║
╠══════════════════════════════════════════════════════════════════════════════╣
║                                                                              ║
║   Location:     $BENCHMARK_ROOT
║   Python Env:   $VENV_PATH
║   Dataset:      SWE-bench Lite (300 instances)                              ║
║                                                                              ║
╠══════════════════════════════════════════════════════════════════════════════╣
║                                                                              ║
║   TO RUN BENCHMARK:                                                          ║
║                                                                              ║
║   1. cd $BENCHMARK_ROOT
║   2. . .\activate-swe-bench.ps1                                             ║
║   3. python run_benchmark.py -n 10                                          ║
║                                                                              ║
╠══════════════════════════════════════════════════════════════════════════════╣
║                                                                              ║
║   BENCHMARK MODES:                                                           ║
║                                                                              ║
║   With MCPs (test):     python run_benchmark.py -n 50                       ║
║   Without MCPs (base):  python run_benchmark.py -n 50 --no-mcps             ║
║                                                                              ║
║   Compare results to measure PhiSHRI impact!                                ║
║                                                                              ║
╚══════════════════════════════════════════════════════════════════════════════╝

"@ -ForegroundColor Cyan

Write-Host "Setup complete! Activate with: . .\activate-swe-bench.ps1" -ForegroundColor Green
