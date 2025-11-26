# PhiSHRI Navigation Logic - Implementation Guide

**Complete guide to implementing and using the PhiSHRI navigation system**

Version: 1.0.0  
Created: 2025-01-18

---

## Table of Contents

1. [Quick Start](#quick-start)
2. [Core Concepts](#core-concepts)
3. [API Reference](#api-reference)
4. [Usage Examples](#usage-examples)
5. [Advanced Features](#advanced-features)
6. [Integration Guide](#integration-guide)
7. [Troubleshooting](#troubleshooting)
8. [Best Practices](#best-practices)

---

## Quick Start

### Installation

```python
from NAVIGATION.navigation_logic import PhiSHRINavigator

# Initialize navigator
nav = PhiSHRINavigator()
```

### Basic Usage

```python
# Find a door
result = nav.find_door("800WINMCP")

# Access the door
door = result['door']
summary = door['context_bundle']['summary']
quick_start = door['context_bundle']['onboarding']['quick_start']

print(f"Door: {result['door_code']}")
print(f"Method: {result['method']}")
print(f"Confidence: {result['confidence']}")
print(f"\nSummary: {summary}")
print(f"\nQuick Start: {quick_start}")
```

---

## Core Concepts

### 1. The Navigator

The `PhiSHRINavigator` class is the main interface to the PhiSHRI system.

**Initialization:**
```python
nav = PhiSHRINavigator(base_path="/workspace/PhiSHRI/PhiSHRI")
```

**What it loads:**
- SEMANTIC_MAP.json - Path → Code mappings
- HASH_TABLE.json - Code → File mappings
- NLP_PATTERNS.json - Natural language patterns
- ERROR_MATCHER.json - Error signatures
- PREREQUISITES.json - Dependency graph

### 2. Query Types

PhiSHRI supports multiple query types:

#### Hash Code
```python
result = nav.find_door("800WINMCP")
# Direct lookup, O(1), confidence 1.0
```

#### Semantic Path
```python
result = nav.find_door("TOOLS.WINDOWS_MCP.FILE_OPERATIONS")
# Semantic lookup, O(1), confidence 1.0
```

#### Natural Language
```python
result = nav.find_door("how to write files on windows")
# NLP matching, O(n), confidence 0.0-1.0
```

#### Error Pattern
```python
result = nav.find_door_by_error("PermissionError: [WinError 5] Access is denied")
# Error matching, O(n), confidence 0.0-1.0
```

### 3. Result Structure

All `find_door()` calls return a consistent structure:

```python
{
  'query': str,              # Original query
  'method': str,             # Lookup method used
  'door_code': str,          # Matched door code
  'door': Dict,              # Complete context bundle
  'prerequisites': List,     # Loaded prerequisite doors
  'confidence': float,       # Match confidence (0.0-1.0)
  'alternatives': List       # Alternative matches (NLP only)
}
```

---

## API Reference

### PhiSHRINavigator Class

#### `__init__(base_path: str = "/workspace/PhiSHRI/PhiSHRI")`

Initialize the navigator.

**Parameters:**
- `base_path` - Path to PhiSHRI directory

**Example:**
```python
nav = PhiSHRINavigator()
# or
nav = PhiSHRINavigator("/custom/path/to/PhiSHRI")
```

---

#### `find_door(query: str, load_prerequisites: bool = True) -> Dict`

Find and load a door using any addressing method.

**Parameters:**
- `query` - Hash code, semantic path, or natural language query
- `load_prerequisites` - Whether to auto-load prerequisite doors (default: True)

**Returns:**
```python
{
  'query': str,
  'method': str,  # 'hash_code_lookup', 'semantic_path_resolution', 
                  # 'natural_language_query', 'fuzzy_matching', 'no_match'
  'door_code': str,
  'door': Dict,
  'prerequisites': List[Dict],
  'confidence': float,
  'alternatives': List[Dict]
}
```

**Examples:**
```python
# Hash code
result = nav.find_door("800WINMCP")

# Semantic path
result = nav.find_door("TOOLS.WINDOWS_MCP.FILE_OPERATIONS")

# Natural language
result = nav.find_door("how to write files on windows")

# Without prerequisites
result = nav.find_door("A01DC", load_prerequisites=False)
```

---

#### `find_door_by_error(error_text: str, load_prerequisites: bool = True) -> Dict`

Find door based on error pattern matching.

**Parameters:**
- `error_text` - Error message or stack trace
- `load_prerequisites` - Whether to auto-load prerequisite doors (default: True)

**Returns:**
```python
{
  'error_text': str,
  'method': 'error_pattern_matching',
  'door_code': str,
  'door': Dict,
  'prerequisites': List[Dict],
  'confidence': float
}
```

**Examples:**
```python
# Permission error
result = nav.find_door_by_error("PermissionError: [WinError 5] Access is denied")

# Encoding error
result = nav.find_door_by_error("UnicodeDecodeError: 'utf-8' codec can't decode")

# MCP error
result = nav.find_door_by_error("MCP server connection failed")
```

---

#### `load_chain(chain_name: str) -> Dict`

Load a predefined chain of related doors.

**Parameters:**
- `chain_name` - Name of predefined chain

**Available Chains:**
- `full_phivector_stack` - Complete PhiVector multi-agent system
- `basic_file_operations` - File operations with error handling
- `agent_coordination` - Multi-agent coordination workflow

**Returns:**
```python
{
  'chain_name': str,
  'found': bool,
  'description': str,
  'total_doors': int,
  'estimated_load_time_ms': int,
  'doors': List[Dict]
}
```

**Examples:**
```python
# Load full stack
result = nav.load_chain("full_phivector_stack")
print(f"Loaded {result['total_doors']} doors")
print(f"Estimated time: {result['estimated_load_time_ms']}ms")

# Load file operations
result = nav.load_chain("basic_file_operations")
for door in result['doors']:
    print(f"- {door['door_code']}: {door['context_bundle']['summary'][:50]}...")
```

---

#### `get_onboarding_summary(door_code: str) -> str`

Get quick-start onboarding summary for a door.

**Parameters:**
- `door_code` - Door code to summarize

**Returns:**
- Markdown-formatted onboarding summary

**Example:**
```python
summary = nav.get_onboarding_summary("800WINMCP")
print(summary)

# Output:
# # 800WINMCP - TOOLS.WINDOWS_MCP.FILE_OPERATIONS
# 
# Windows MCP file operation tools for reading, writing...
# 
# ## Quick Start
# Use Windows MCP for file operations. Always validate paths...
# 
# ## Prerequisites
# - 800WINMCP_SETUP
# - S01PATH
# 
# ## Common Patterns
# - Read file: mcp.file_read(path) with error handling
# - Write file: mcp.file_write(path, content, encoding='utf-8')
# ...
```

---

## Usage Examples

### Example 1: Basic Door Lookup

```python
from NAVIGATION.navigation_logic import PhiSHRINavigator

nav = PhiSHRINavigator()

# Find door
result = nav.find_door("800WINMCP")

if result['door']:
    door = result['door']
    bundle = door['context_bundle']
    
    print(f"Door Code: {door['door_code']}")
    print(f"Semantic Path: {door['semantic_path']}")
    print(f"\nSummary:")
    print(bundle['summary'])
    
    print(f"\nQuick Start:")
    print(bundle['onboarding']['quick_start'])
    
    print(f"\nCommon Patterns:")
    for pattern in bundle['onboarding']['common_patterns']:
        print(f"  - {pattern}")
else:
    print("Door not found")
```

### Example 2: Natural Language Query with Alternatives

```python
nav = PhiSHRINavigator()

# Natural language query
result = nav.find_door("how to coordinate multiple agents")

print(f"Query: {result['query']}")
print(f"Method: {result['method']}")
print(f"Confidence: {result['confidence']:.2f}")
print(f"\nBest Match: {result['door_code']}")

if result['alternatives']:
    print(f"\nAlternatives:")
    for alt in result['alternatives']:
        print(f"  - {alt['door_code']} (confidence: {alt['confidence']:.2f})")
        print(f"    {alt['summary'][:60]}...")
```

### Example 3: Error-Driven Navigation

```python
nav = PhiSHRINavigator()

# Simulate error
error_message = "PermissionError: [WinError 5] Access is denied"

# Find solution
result = nav.find_door_by_error(error_message)

if result['door']:
    door = result['door']
    errors = door['context_bundle']['onboarding']['known_errors']
    
    print(f"Error: {error_message}")
    print(f"Solution Door: {result['door_code']}")
    print(f"Confidence: {result['confidence']}")
    
    print(f"\nKnown Solutions:")
    for error in errors:
        if error_message.lower() in error['error'].lower():
            print(f"\nError: {error['error']}")
            print(f"Cause: {error['cause']}")
            print(f"Solution: {error['solution']}")
            print(f"Prevention: {error['prevention']}")
```

### Example 4: Loading with Prerequisites

```python
nav = PhiSHRINavigator()

# Load door with prerequisites
result = nav.find_door("A01DC", load_prerequisites=True)

print(f"Main Door: {result['door_code']}")
print(f"Prerequisites Loaded: {len(result['prerequisites'])}")

print(f"\nPrerequisite Chain:")
for prereq in result['prerequisites']:
    print(f"  - {prereq['door_code']}: {prereq['semantic_path']}")

print(f"\nTotal Context Loaded:")
print(f"  - Main door: 1")
print(f"  - Prerequisites: {len(result['prerequisites'])}")
print(f"  - Total: {1 + len(result['prerequisites'])}")
```

### Example 5: Loading Predefined Chains

```python
nav = PhiSHRINavigator()

# Load full PhiVector stack
result = nav.load_chain("full_phivector_stack")

if result['found']:
    print(f"Chain: {result['chain_name']}")
    print(f"Description: {result['description']}")
    print(f"Total Doors: {result['total_doors']}")
    print(f"Estimated Load Time: {result['estimated_load_time_ms']}ms")
    
    print(f"\nDoors in Chain:")
    for door in result['doors']:
        print(f"  - {door['door_code']}: {door['semantic_path']}")
else:
    print("Chain not found")
```

### Example 6: Fuzzy Matching

```python
nav = PhiSHRINavigator()

# Typo in query
result = nav.find_door("winmcp")  # Should match 800WINMCP

print(f"Query: {result['query']}")
print(f"Method: {result['method']}")  # Will be 'fuzzy_matching'
print(f"Matched: {result['door_code']}")
print(f"Confidence: {result['confidence']:.2f}")
```

---

## Advanced Features

### 1. Custom Base Path

```python
# Use custom PhiSHRI location
nav = PhiSHRINavigator(base_path="/custom/path/PhiSHRI")
```

### 2. Caching

The navigator automatically caches loaded doors:

```python
nav = PhiSHRINavigator()

# First load - reads from file
result1 = nav.find_door("800WINMCP")

# Second load - reads from cache (faster)
result2 = nav.find_door("800WINMCP")
```

### 3. Confidence Thresholds

```python
nav = PhiSHRINavigator()

result = nav.find_door("file operations")

if result['confidence'] >= 0.8:
    print("High confidence match")
elif result['confidence'] >= 0.5:
    print("Medium confidence match")
else:
    print("Low confidence match - consider alternatives")
    for alt in result['alternatives']:
        print(f"  - {alt['door_code']} ({alt['confidence']:.2f})")
```

### 4. Batch Loading

```python
nav = PhiSHRINavigator()

door_codes = ["800WINMCP", "A01DC", "P03VECTOR"]

doors = []
for code in door_codes:
    result = nav.find_door(code, load_prerequisites=False)
    if result['door']:
        doors.append(result['door'])

print(f"Loaded {len(doors)} doors")
```

---

## Integration Guide

### Integration with AI Agents

```python
class AIAgent:
    def __init__(self):
        self.navigator = PhiSHRINavigator()
    
    def onboard(self, context_query: str):
        """Load context for a task"""
        result = self.navigator.find_door(context_query)
        
        if result['door']:
            # Extract onboarding info
            bundle = result['door']['context_bundle']
            self.context = {
                'summary': bundle['summary'],
                'quick_start': bundle['onboarding']['quick_start'],
                'patterns': bundle['onboarding']['common_patterns'],
                'errors': bundle['onboarding']['known_errors']
            }
            return True
        return False
    
    def handle_error(self, error_message: str):
        """Auto-resolve errors"""
        result = self.navigator.find_door_by_error(error_message)
        
        if result['door']:
            errors = result['door']['context_bundle']['onboarding']['known_errors']
            for error in errors:
                if error_message.lower() in error['error'].lower():
                    return error['solution']
        return None

# Usage
agent = AIAgent()
agent.onboard("windows file operations")
solution = agent.handle_error("PermissionError: Access denied")
```

### Integration with Multi-Agent Systems

```python
class AgentCoordinator:
    def __init__(self):
        self.navigator = PhiSHRINavigator()
    
    def setup_agent(self, agent_name: str):
        """Setup agent with appropriate context"""
        # Map agent names to door codes
        agent_doors = {
            'DC': 'A01DC',
            'VSCC': 'A02VSCC',
            'TERMC': 'A03TERMC',
            'STRYK': 'A00STRYK'
        }
        
        door_code = agent_doors.get(agent_name)
        if door_code:
            result = self.navigator.find_door(door_code, load_prerequisites=True)
            return result
        return None
    
    def load_workflow(self, workflow_name: str):
        """Load workflow context"""
        result = self.navigator.load_chain(workflow_name)
        return result

# Usage
coordinator = AgentCoordinator()
dc_context = coordinator.setup_agent('DC')
workflow = coordinator.load_workflow('agent_coordination')
```

---

## Troubleshooting

### Issue: Door Not Found

```python
result = nav.find_door("NONEXISTENT")

if result['method'] == 'no_match':
    print("Door not found")
    print("Try:")
    print("  1. Check door code spelling")
    print("  2. Use semantic path instead")
    print("  3. Try natural language query")
    print("  4. Check available doors in INDEX.json")
```

### Issue: Low Confidence Match

```python
result = nav.find_door("vague query")

if result['confidence'] < 0.5:
    print(f"Low confidence match: {result['confidence']:.2f}")
    print("Consider alternatives:")
    for alt in result['alternatives']:
        print(f"  - {alt['door_code']}: {alt['summary'][:50]}...")
```

### Issue: Prerequisites Not Loading

```python
result = nav.find_door("A01DC", load_prerequisites=True)

if not result['prerequisites']:
    print("No prerequisites loaded")
    print("Check PREREQUISITES.json for dependency graph")
```

### Issue: Slow Performance

```python
# Enable caching (default)
nav = PhiSHRINavigator()

# First load (slow)
result1 = nav.find_door("800WINMCP")

# Subsequent loads (fast - cached)
result2 = nav.find_door("800WINMCP")

# Clear cache if needed
nav.cache.clear()
```

---

## Best Practices

### 1. Use Specific Queries

```python
# Good - specific
result = nav.find_door("800WINMCP")
result = nav.find_door("TOOLS.WINDOWS_MCP.FILE_OPERATIONS")

# Less ideal - vague
result = nav.find_door("file stuff")
```

### 2. Check Confidence Scores

```python
result = nav.find_door("natural language query")

if result['confidence'] >= 0.8:
    # High confidence - use directly
    door = result['door']
elif result['confidence'] >= 0.5:
    # Medium confidence - verify with alternatives
    print("Did you mean:")
    for alt in result['alternatives'][:3]:
        print(f"  - {alt['door_code']}")
else:
    # Low confidence - ask for clarification
    print("Query too vague, please be more specific")
```

### 3. Load Prerequisites When Needed

```python
# For complete context
result = nav.find_door("A01DC", load_prerequisites=True)

# For quick lookup only
result = nav.find_door("A01DC", load_prerequisites=False)
```

### 4. Use Chains for Common Workflows

```python
# Instead of loading doors individually
result1 = nav.find_door("R01MULTI")
result2 = nav.find_door("820PWSH")
result3 = nav.find_door("810AHK")
# ... etc

# Use predefined chain
result = nav.load_chain("full_phivector_stack")
```

### 5. Handle Errors Gracefully

```python
try:
    result = nav.find_door(user_query)
    
    if result['door']:
        # Process door
        pass
    else:
        # Handle not found
        print("Door not found, try different query")
        
except Exception as e:
    print(f"Navigation error: {e}")
    # Fallback behavior
```

### 6. Cache Frequently Used Doors

```python
class CachedNavigator:
    def __init__(self):
        self.nav = PhiSHRINavigator()
        self.frequent_doors = {}
    
    def get_door(self, door_code: str):
        if door_code not in self.frequent_doors:
            result = self.nav.find_door(door_code)
            self.frequent_doors[door_code] = result['door']
        return self.frequent_doors[door_code]
```

---

## Performance Tips

### 1. Minimize Prerequisite Loading

```python
# Only load prerequisites when needed
result = nav.find_door("800WINMCP", load_prerequisites=False)
```

### 2. Use Hash Codes for Speed

```python
# Fastest - O(1)
result = nav.find_door("800WINMCP")

# Fast - O(1)
result = nav.find_door("TOOLS.WINDOWS_MCP.FILE_OPERATIONS")

# Slower - O(n)
result = nav.find_door("how to write files")
```

### 3. Batch Load Chains

```python
# Instead of individual loads
result = nav.load_chain("basic_file_operations")
# Loads: 800WINMCP, E01PERM, E02ENCODE in one call
```

### 4. Reuse Navigator Instance

```python
# Good - reuse instance (caching works)
nav = PhiSHRINavigator()
result1 = nav.find_door("800WINMCP")
result2 = nav.find_door("A01DC")

# Less efficient - new instance each time
nav1 = PhiSHRINavigator()
result1 = nav1.find_door("800WINMCP")
nav2 = PhiSHRINavigator()
result2 = nav2.find_door("A01DC")
```

---

## Conclusion

The PhiSHRI navigation system provides a powerful, flexible, and performant way to load context for AI agents. By supporting multiple addressing methods, automatic prerequisite loading, and error-driven navigation, it enables instant agent onboarding without questions.

**Key Takeaways:**
- Use hash codes for speed
- Use semantic paths for clarity
- Use natural language for flexibility
- Check confidence scores
- Load prerequisites when needed
- Handle errors gracefully
- Cache frequently used doors

---

**Happy navigating! 🚪**