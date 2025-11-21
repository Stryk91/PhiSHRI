# Agent Task: MCP Server QA Testing

## Context
PhiSHRI MCP server (`phishri-mcp`) is a Rust binary that provides AI session continuity via semantic door codes. The server just passed initial testing (10/10 tools working). Now needs edge case testing.

## Your Task
Generate comprehensive test cases for the PhiSHRI MCP server.

## Server Location
- Binary: `C:\Dev\PhiSHRI_MCP\phishri-mcp\target\release\phishri-mcp.exe`
- Doors: `C:\Dev\PhiSRHI\PhiSHRI\` (env var: PHISHRI_PATH)

## Tools to Test (10 total)
1. `phishri_read_door` - Read door by code
2. `phishri_list_doors` - List doors by category
3. `phishri_find_door` - Search doors by query
4. `phishri_load_chain` - Load multiple doors
5. `phishri_get_bootstrap` - Get session state
6. `phishri_update_bootstrap` - Update session state
7. `phishri_session_checkpoint` - Create checkpoint
8. `phishri_search_semantic` - Search by semantic path
9. `phishri_get_prerequisites` - Get prereq chain
10. `phishri_rebuild_indexes` - Rebuild indexes

## Test Categories Needed
1. **Happy path** - Normal usage (already done, skip)
2. **Invalid inputs** - Wrong door codes, empty strings, null values
3. **Edge cases** - Very long queries, special characters, unicode
4. **Boundary conditions** - Empty category, 0 limit, negative offset
5. **Concurrent access** - Multiple rapid requests
6. **File system** - Missing PHISHRI_PATH, read-only dirs, missing files
7. **Large payloads** - Loading 50+ doors at once

## Output Format
Deliver a markdown file with:
```markdown
## Test Case: [Name]
**Tool:** phishri_xxx
**Input:** `{"jsonrpc":"2.0","id":1,"method":"tools/call","params":{...}}`
**Expected:** [Description of expected behavior]
**Category:** [Invalid/Edge/Boundary/etc]
```

## Constraints
- DO NOT modify any server code
- DO NOT modify any door files
- DO NOT run tests yourself (no bash access assumed)
- ONLY generate test case documentation

## Deliverable
Create file: `QA_TEST_CASES.md` with 30+ test cases covering all categories above.
