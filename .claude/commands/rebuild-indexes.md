# /rebuild-indexes

Rebuild HASH_TABLE.json and SEMANTIC_MAP.json from door files.

## Usage
```
/rebuild-indexes [--verify]
```

## Process

### Step 1: Scan Doors
```
Scanning CONTEXTS/...
Found 500 door files across 8 categories
```

### Step 2: Build HASH_TABLE
```
Building HASH_TABLE.json...
- Extracting door_code from each file
- Mapping to relative paths
- Checking for duplicates
```

### Step 3: Build SEMANTIC_MAP
```
Building SEMANTIC_MAP.json...
- Extracting aliases from each door
- Building reverse lookup
- 2,568 total mappings
```

### Step 4: Validate
```
Validating indexes...
- All door_codes unique: PASS
- All paths valid: PASS
- No orphaned mappings: PASS
```

### Step 5: Write
```
Writing INDEXES/HASH_TABLE.json... done
Writing INDEXES/SEMANTIC_MAP.json... done
```

## Output
```
Index Rebuild Complete
======================
HASH_TABLE:   500 entries
SEMANTIC_MAP: 2,568 mappings
Duplicates:   0
Orphans:      0

Indexes written to PhiSHRI/INDEXES/
```

## Verify Mode
```
/rebuild-indexes --verify
```
Compares existing indexes against fresh scan without writing.
Reports drift if indexes are out of date.
