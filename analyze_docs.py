#!/usr/bin/env python3
"""
PhiSHRI Documentation Analyzer
Extracts door candidates from all markdown files in the repository
"""

import os
import json
import re
from pathlib import Path
from collections import defaultdict
from typing import Dict, List, Set, Tuple

class DocumentAnalyzer:
    def __init__(self, base_path: str):
        self.base_path = Path(base_path)
        self.doors = []
        self.categories = defaultdict(list)
        self.tools = []
        self.agents = []
        self.projects = []
        self.errors = []
        self.workflows = []
        self.architectures = []
        
    def scan_directory(self, directory: Path) -> List[Path]:
        """Recursively find all markdown files"""
        md_files = []
        for item in directory.rglob("*.md"):
            if item.is_file():
                md_files.append(item)
        return md_files
    
    def extract_tools(self, content: str, filepath: str) -> List[Dict]:
        """Extract tool references from content"""
        tools = []
        
        # MCP tools
        mcp_pattern = r'mcp[_-]?(\w+)'
        for match in re.finditer(mcp_pattern, content, re.IGNORECASE):
            tools.append({
                'type': 'MCP',
                'name': match.group(0),
                'context': match.group(1),
                'source': filepath
            })
        
        # Windows MCP specific
        if 'windows' in content.lower() and 'mcp' in content.lower():
            tools.append({
                'type': 'WINDOWS_MCP',
                'name': 'Windows MCP',
                'source': filepath
            })
        
        # AutoHotkey
        if '.ahk' in content or 'autohotkey' in content.lower():
            tools.append({
                'type': 'AUTOHOTKEY',
                'name': 'AutoHotkey',
                'source': filepath
            })
        
        # PowerShell
        if '.ps1' in content or 'powershell' in content.lower():
            tools.append({
                'type': 'POWERSHELL',
                'name': 'PowerShell',
                'source': filepath
            })
        
        return tools
    
    def extract_agents(self, content: str, filepath: str) -> List[Dict]:
        """Extract agent references"""
        agents = []
        
        # Known agents
        agent_patterns = [
            r'\b(DC|DESKC|Desktop Claude)\b',
            r'\b(VSCC|VS Code Claude|IDE Claude|IDEC)\b',
            r'\b(TERMC|Terminal Claude)\b',
            r'\b(KALIC|Kali Claude)\b',
            r'\b(STRYK)\b',
            r'\b(Junie)\b',
            r'\b(analyzer)\b',
            r'\b(SmokeTester)\b'
        ]
        
        for pattern in agent_patterns:
            for match in re.finditer(pattern, content):
                agents.append({
                    'name': match.group(0),
                    'source': filepath
                })
        
        return agents
    
    def extract_projects(self, content: str, filepath: str) -> List[Dict]:
        """Extract project references"""
        projects = []
        
        project_patterns = [
            r'\b(PhiWave)\b',
            r'\b(PhiGEN)\b',
            r'\b(PhiVector)\b',
            r'\b(PhiDEX)\b',
            r'\b(PhiSHRI|PhiDOOR)\b'
        ]
        
        for pattern in project_patterns:
            for match in re.finditer(pattern, content):
                projects.append({
                    'name': match.group(0),
                    'source': filepath
                })
        
        return projects
    
    def extract_errors(self, content: str, filepath: str) -> List[Dict]:
        """Extract error patterns"""
        errors = []
        
        # Error patterns
        error_patterns = [
            r'(PermissionError|AccessDenied)',
            r'(UnicodeDecodeError|encoding)',
            r'(FileNotFoundError|path)',
            r'(TimeoutError|timeout)',
            r'(ConnectionError|network)'
        ]
        
        for pattern in error_patterns:
            for match in re.finditer(pattern, content, re.IGNORECASE):
                errors.append({
                    'type': match.group(0),
                    'source': filepath
                })
        
        return errors
    
    def extract_workflows(self, content: str, filepath: str) -> List[Dict]:
        """Extract workflow patterns"""
        workflows = []
        
        # Look for workflow indicators
        workflow_indicators = [
            'coordination', 'orchestration', 'pipeline',
            'workflow', 'automation', 'deployment'
        ]
        
        for indicator in workflow_indicators:
            if indicator in content.lower():
                workflows.append({
                    'type': indicator,
                    'source': filepath
                })
        
        return workflows
    
    def analyze_file(self, filepath: Path) -> Dict:
        """Analyze a single markdown file"""
        try:
            with open(filepath, 'r', encoding='utf-8', errors='ignore') as f:
                content = f.read()
            
            relative_path = filepath.relative_to(self.base_path)
            
            analysis = {
                'filepath': str(relative_path),
                'size': len(content),
                'lines': content.count('\n'),
                'tools': self.extract_tools(content, str(relative_path)),
                'agents': self.extract_agents(content, str(relative_path)),
                'projects': self.extract_projects(content, str(relative_path)),
                'errors': self.extract_errors(content, str(relative_path)),
                'workflows': self.extract_workflows(content, str(relative_path))
            }
            
            return analysis
        except Exception as e:
            print(f"Error analyzing {filepath}: {e}")
            return None
    
    def analyze_all(self):
        """Analyze all markdown files"""
        print("Scanning for markdown files...")
        md_files = self.scan_directory(self.base_path)
        print(f"Found {len(md_files)} markdown files")
        
        results = []
        for i, filepath in enumerate(md_files, 1):
            if i % 50 == 0:
                print(f"Analyzed {i}/{len(md_files)} files...")
            
            analysis = self.analyze_file(filepath)
            if analysis:
                results.append(analysis)
                
                # Aggregate data
                self.tools.extend(analysis['tools'])
                self.agents.extend(analysis['agents'])
                self.projects.extend(analysis['projects'])
                self.errors.extend(analysis['errors'])
                self.workflows.extend(analysis['workflows'])
        
        return results
    
    def generate_summary(self, results: List[Dict]) -> Dict:
        """Generate summary statistics"""
        # Deduplicate
        unique_tools = {}
        for tool in self.tools:
            key = f"{tool['type']}:{tool['name']}"
            if key not in unique_tools:
                unique_tools[key] = tool
        
        unique_agents = {}
        for agent in self.agents:
            if agent['name'] not in unique_agents:
                unique_agents[agent['name']] = agent
        
        unique_projects = {}
        for project in self.projects:
            if project['name'] not in unique_projects:
                unique_projects[project['name']] = project
        
        summary = {
            'total_files': len(results),
            'total_size': sum(r['size'] for r in results),
            'total_lines': sum(r['lines'] for r in results),
            'unique_tools': len(unique_tools),
            'unique_agents': len(unique_agents),
            'unique_projects': len(unique_projects),
            'total_errors': len(self.errors),
            'total_workflows': len(self.workflows),
            'tools': list(unique_tools.values()),
            'agents': list(unique_agents.values()),
            'projects': list(unique_projects.values())
        }
        
        return summary

def main():
    analyzer = DocumentAnalyzer('/workspace/PhiSHRI')
    
    print("=" * 60)
    print("PhiSHRI Documentation Analysis")
    print("=" * 60)
    
    results = analyzer.analyze_all()
    summary = analyzer.generate_summary(results)
    
    print("\n" + "=" * 60)
    print("ANALYSIS SUMMARY")
    print("=" * 60)
    print(f"Total Files: {summary['total_files']}")
    print(f"Total Size: {summary['total_size']:,} bytes")
    print(f"Total Lines: {summary['total_lines']:,}")
    print(f"\nUnique Tools: {summary['unique_tools']}")
    print(f"Unique Agents: {summary['unique_agents']}")
    print(f"Unique Projects: {summary['unique_projects']}")
    print(f"Error Patterns: {summary['total_errors']}")
    print(f"Workflow Patterns: {summary['total_workflows']}")
    
    # Save results
    output_file = '/workspace/PhiSHRI/analysis_results.json'
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump({
            'summary': summary,
            'detailed_results': results
        }, f, indent=2)
    
    print(f"\nDetailed results saved to: {output_file}")
    
    # Print top tools
    print("\n" + "=" * 60)
    print("TOP TOOLS IDENTIFIED")
    print("=" * 60)
    for tool in summary['tools'][:20]:
        print(f"  - {tool['type']}: {tool['name']}")
    
    # Print agents
    print("\n" + "=" * 60)
    print("AGENTS IDENTIFIED")
    print("=" * 60)
    for agent in summary['agents']:
        print(f"  - {agent['name']}")
    
    # Print projects
    print("\n" + "=" * 60)
    print("PROJECTS IDENTIFIED")
    print("=" * 60)
    for project in summary['projects']:
        print(f"  - {project['name']}")

if __name__ == '__main__':
    main()