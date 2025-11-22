# /validate-doors

Validate door JSON files against schema.

## Usage
```
/validate-doors [path]
```

## Arguments
- `path` - Optional. Specific door or directory. Default: all doors.

## Validation Checks

### Structure
- [ ] Valid JSON syntax
- [ ] `door_code` field present and matches filename
- [ ] `semantic_path` follows CATEGORY.SUBCATEGORY.NAME format
- [ ] `aliases` is non-empty array
- [ ] `context_bundle` contains required fields

### Content Quality
- [ ] `summary` is 50-300 characters
- [ ] `quick_start` contains actual commands (not placeholder)
- [ ] `common_patterns` has 3+ entries
- [ ] `known_errors` has 2+ entries

### References
- [ ] `prerequisites` all exist in HASH_TABLE
- [ ] `related_doors` all exist in HASH_TABLE
- [ ] No circular prerequisites

### Metadata
- [ ] `last_updated` is valid ISO timestamp
- [ ] `category` matches parent directory
- [ ] `tags` array is non-empty

## Output
```
Validating doors...

PASS: 497 doors valid
WARN: 3 doors with issues

Issues:
- W185RATELIMIT.json: empty quick_start
- S46CONTAINER_ESCAPE.json: missing prerequisites
- T79PLATFORM_TEAMS.json: summary too short (23 chars)

Run with --fix to auto-repair minor issues.
```

## Fix Mode
```
/validate-doors --fix
```
Auto-repairs:
- Adds missing empty arrays
- Normalizes timestamps
- Fills placeholder summaries from content
