# PERFORMANCE OPTIMIZATION GUIDE

A comprehensive guide to optimizing application performance across binaries, installers, runtime, and deployment. Based on 2024 best practices and modern optimization techniques.

---

## Table of Contents

1. [Binary Optimization](#binary-optimization)
2. [Installer Optimization](#installer-optimization)
3. [Runtime Optimization](#runtime-optimization)
4. [Deployment Architecture](#deployment-architecture)
5. [Platform-Specific Optimizations](#platform-specific-optimizations)
6. [Benchmarking & Profiling](#benchmarking--profiling)
7. [Quick Reference](#quick-reference)

---

## Binary Optimization

Binary optimization focuses on producing smaller, faster executables by leveraging compiler techniques and post-compilation processing.

### Compiler Flags

#### GCC/Clang Optimization Levels

- **-O0** (default): No optimization, fastest compilation
- **-O1**: Basic optimizations, minimal code size/speed improvement
- **-O2**: Standard optimization, good balance of performance and compilation time (recommended baseline)
- **-O3**: Aggressive optimization, maximum performance, may increase code size significantly
- **-Os**: Optimize for size while maintaining good performance, disables size-increasing optimizations
- **-Oz**: More aggressive size optimization (Clang), slightly slower than -Os
- **-Ofast**: -O3 with fast (unsafe) math operations

#### GCC Compiler Flags (Common)

```bash
# Basic optimization with size reduction
gcc -O2 -Wall -fomit-frame-pointer -march=native source.c -o binary

# Size-optimized build (reduces binary by 20-40%)
gcc -Os -Wall -ffunction-sections -fdata-sections -Wl,--gc-sections source.c -o binary

# Performance-optimized with aggressive inlining
gcc -O3 -march=native -mtune=native -finline-functions source.c -o binary

# Size optimization with dead code removal
gcc -Os -ffunction-sections -fdata-sections -Wl,--gc-sections \
    -Wl,--strip-all -fvisibility=hidden source.c -o binary

# Recommended production build
gcc -O2 -ffunction-sections -fdata-sections -Wl,--gc-sections source.c -o binary
```

#### MSVC Compiler Flags (Windows)

```bash
# Basic optimization
cl /O2 /fp:fast /GL source.cpp /link /LTCG

# Size optimization
cl /O1 /fp:fast /GL source.cpp /link /LTCG

# Performance optimization
cl /O2 /Ox /fp:fast /GL source.cpp /link /LTCG /USEPROFILE:PGO.pgd

# Link-time optimization
cl /GL /O2 source.cpp /link /LTCG

# Whole Program Optimization
cl /GL /Gy /Gw source.cpp /link /LTCG /OPT:REF /OPT:ICF
```

Key MSVC flags:
- `/O1`: Minimize size
- `/O2`: Maximize speed
- `/Ox`: Full optimization
- `/GL`: Enable whole program optimization
- `/Gy`: Enable function-level linking
- `/Gw`: Enable global data optimization
- `/OPT:REF`: Remove unreferenced functions/data
- `/OPT:ICF`: Enable identical code folding

#### Rust Optimization

```bash
# Size-optimized release build
[profile.release]
opt-level = "z"          # Optimize for size
lto = true               # Link-time optimization
codegen-units = 1        # Enable LTO (slower compile, better optimization)
strip = true             # Strip debug symbols

# Performance-optimized release build
[profile.release]
opt-level = 3            # Maximum performance
lto = "fat"              # Full LTO
codegen-units = 1
panic = "abort"          # Reduce binary size

# Compile Rust with optimizations
cargo build --release -Z build-std=std,panic_abort --target x86_64-unknown-linux-gnu
```

#### Go Optimization

```bash
# Standard build
go build -ldflags="-s -w" -trimpath main.go

# Size optimization (strip symbols and DWARF info)
go build -ldflags="-s -w" -trimpath main.go

# Performance optimization
go build -ldflags="-s" main.go

# Build with UPX compression (post-build)
go build -ldflags="-s -w" main.go
upx --best main
```

### Link-Time Optimization (LTO)

LTO enables whole-program optimization by analyzing and optimizing all compilation units together. This can yield double-digit performance improvements.

#### GCC/Clang LTO

```bash
# Standard LTO (may increase compile time 2-3x)
gcc -flto -O2 source.c -o binary

# Parallel LTO (faster compilation)
gcc -flto=auto -O2 source.c -o binary

# Thin LTO (Clang, faster than full LTO)
clang -flto=thin -O2 source.c -o binary

# Enable LTO with multiple files
gcc -flto -O2 -c file1.c -o file1.o
gcc -flto -O2 -c file2.c -o file2.o
gcc -flto -O2 file1.o file2.o -o binary

# For Makefiles
CFLAGS = -flto -O2
LDFLAGS = -flto
```

#### Rust LTO

```bash
# In Cargo.toml
[profile.release]
lto = true           # Enable LTO
codegen-units = 1    # Required for LTO

# Or use "fat" for full LTO or "thin" for faster compilation
[profile.release]
lto = "fat"
codegen-units = 1
```

#### Benefits & Trade-offs

**Benefits:**
- 10-30% performance improvement in many applications
- Smaller binary sizes (5-20% reduction)
- Better dead code elimination
- Improved inlining across translation units

**Trade-offs:**
- Compile time increases 2-3x
- Memory usage during linking increases
- Slower build times in CI/CD pipelines

### Profile-Guided Optimization (PGO)

PGO uses runtime profiling data to guide compiler optimizations, often achieving 20-40% performance improvements for hot paths.

#### GCC/Clang PGO Workflow

```bash
# Step 1: Build with profiling instrumentation
gcc -fprofile-generate -O2 source.c -o binary_instrumented

# Step 2: Run the profiling workload (use realistic inputs)
./binary_instrumented < typical_input.txt

# Step 3: Rebuild using profiling data
gcc -fprofile-use -fprofile-correction -O2 source.c -o binary_optimized
```

#### MSVC PGO Workflow

```batch
# Step 1: Compile with profile generation
cl /GL /O2 /PGD:profile.pgd source.cpp /link /LTCG /PGDPATH

# Step 2: Run instrumented binary with representative workload
program.exe < input.txt

# Step 3: Merge profiling data
pgomgr /merge profile.pgd

# Step 4: Rebuild with profile data
cl /GL /O2 /USEPROFILE:profile.pgd source.cpp /link /LTCG
```

#### Rust PGO

```bash
# PGO is not yet stabilized, but can be approximated with:
# 1. Use benchmarks for hot paths
# 2. Use CPU profilers (perf, instruments)
# 3. Manual optimization based on profiling results
```

#### PGO Best Practices

- Use realistic input data for training runs, not just test suites
- Even basic test suites can provide significant improvements in practice
- Combine with LTO for best results
- Re-run PGO after major code changes

### Strip Symbols

Symbol stripping removes debug information and symbol tables, reducing binary size by 20-50%.

```bash
# GCC/Clang: strip symbols at compile time
gcc -O2 -s source.c -o binary

# Or strip after compilation
gcc -O2 source.c -o binary.unstripped
strip --strip-all binary.unstripped -o binary

# GCC: strip only debug symbols (keep some symbols)
strip --strip-debug binary

# Rust: automatic stripping in release mode
[profile.release]
strip = true          # Strip all symbols
strip = "debuginfo"   # Strip only debug info

# Go: strip during build
go build -ldflags="-s -w" main.go
# -s: disable symbol table
# -w: disable DWARF generation

# Size comparison
ls -lh binary.unstripped binary
# Output shows ~30-50% size reduction
```

### UPX Compression

UPX (Ultimate Packer for eXecutables) compresses executables by 50-70%, though with trade-offs in memory usage and startup time.

#### Installation

```bash
# Linux
sudo apt-get install upx  # Debian/Ubuntu
sudo yum install upx      # RedHat/CentOS
brew install upx          # macOS

# Windows
choco install upx         # Chocolatey
# Or download from https://upx.github.io/
```

#### Usage

```bash
# Standard compression
upx program.exe

# Best compression (slower decompression)
upx --best program.exe

# Brute force compression (very slow)
upx --brute program.exe

# LZMA compression (best ratio, slower decompression)
upx --lzma program.exe

# Compression level (1-9)
upx -9 program.exe

# Extract compressed executable
upx -d program.exe

# Multiple files
upx *.exe

# Verify compression
upx -l program.exe
```

#### Compression Ratios by Method

| Compression | Ratio | Decompression Speed |
|-------------|-------|-------------------|
| Standard | 50-60% | 500+ MB/sec |
| --best | 55-65% | 400+ MB/sec |
| --brute | 60-70% | 300+ MB/sec |
| --lzma | 65-75% | 100-200 MB/sec |

#### Important Considerations

**Pros:**
- Dramatic size reduction on disk
- Fast decompression (500+ MB/sec)
- No dependency installation required for execution

**Cons:**
- Entire code uncompressed into memory (higher memory footprint)
- Slightly slower startup time (decompression overhead)
- False-positive antivirus alerts (UPX-packed executables resemble malware)
- Not recommended for security-critical applications

#### When to Use UPX

- Portable single-file distributions
- Memory-constrained environments (still have disk space)
- When antivirus false-positives are acceptable
- NOT recommended for memory-sensitive or performance-critical applications

---

## Installer Optimization

Optimizing installers reduces download size and installation time, improving user experience.

### Compression Techniques

#### 7-Zip Compression

7-Zip provides excellent compression ratios (up to 80% reduction) with good decompression speed.

```bash
# Installation
sudo apt-get install p7zip-full  # Linux
brew install p7zip               # macOS
# Windows: built-in or 7-Zip application

# Basic compression
7z a archive.7z files/

# Maximum compression
7z a -mx=9 archive.7z files/

# Ultra compression
7z a -mx=9 -md=32m archive.7z files/

# Compression with password
7z a -p -mx=9 archive.7z files/

# Extract
7z x archive.7z

# Test integrity
7z t archive.7z

# View archive contents
7z l archive.7z
```

#### Zstandard (Zstd) Compression

Zstandard provides fast compression with modern compression ratios, ideal for real-time compression.

```bash
# Installation
sudo apt-get install zstandard  # Linux
brew install zstandard          # macOS

# Basic compression
zstd file.bin -o file.bin.zst

# Compression level (1-22, default 3)
zstd -19 file.bin -o file.bin.zst

# Fast compression
zstd -1 file.bin -o file.bin.zst

# Directory compression
tar --zstd -c -f archive.tar.zst directory/

# Decompression
unzstd file.bin.zst

# Speed vs ratio example
time zstd -1 large_file.bin  # Fast, lower ratio
time zstd -19 large_file.bin # Slower, higher ratio
```

#### LZMA Compression

LZMA (Lempel-Ziv-Markov chain algorithm) provides maximum compression at the cost of compression/decompression speed.

```bash
# Installation
sudo apt-get install xz-utils  # Linux

# Basic compression
xz -z file.bin

# Maximum compression (takes longer)
xz -9 file.bin

# Extreme compression
xz -e -9 file.bin

# Multithreaded compression
xz -T 4 -9 file.bin

# Decompression
xz -d file.bin.xz

# Compression ratios
xz -0 file.bin  # Fast compression, larger output
xz -9 file.bin  # Slow compression, smallest output
```

#### Compression Comparison

```bash
# Compare compression methods on large file
original_size=$(stat -f%z large_file.bin)

# 7-Zip
7z a archive.7z large_file.bin
zipped_7z=$(stat -f%z archive.7z)

# Zstandard
zstd -19 large_file.bin
zipped_zst=$(stat -f%z large_file.bin.zst)

# LZMA
xz -9 large_file.bin.copy
zipped_xz=$(stat -f%z large_file.bin.copy.xz)

echo "Original: $original_size bytes"
echo "7-Zip: $zipped_7z bytes ($(($zipped_7z * 100 / $original_size))%)"
echo "Zstd: $zipped_zst bytes ($(($zipped_zst * 100 / $original_size))%)"
echo "LZMA: $zipped_xz bytes ($(($zipped_xz * 100 / $original_size))%)"
```

### Delta Patches

Delta patches reduce download size for updates by only distributing changed bytes.

#### bsdiff/bspatch

Traditional binary diff/patch tool, excellent for executable patches.

```bash
# Installation
sudo apt-get install bsdiff  # Linux
brew install bsdiff          # macOS

# Create delta patch
bsdiff old_binary new_binary patch.bin

# Apply patch
bspatch old_binary patched_binary patch.bin

# Real-world example: Update binary from v1.0 to v1.1
bsdiff program-1.0.exe program-1.1.exe program-1.0-to-1.1.patch

# Size comparison
echo "Binary size: $(stat -f%z program-1.1.exe)"
echo "Patch size: $(stat -f%z program-1.0-to-1.1.patch)"
# Patches typically 10-20% of new binary size
```

#### HDiffPatch (Modern Alternative)

Modern differential compression supporting large files and limited memory.

```bash
# Installation: https://github.com/sisong/HDiffPatch
git clone https://github.com/sisong/HDiffPatch
cd HDiffPatch && cmake . && make

# Create diff
./hdiffz old_binary new_binary patch.hd

# Apply patch
./hpatchz old_binary patch.hd patched_binary

# With compression
./hdiffz -d old_binary new_binary patch.hd

# Parallel processing
./hdiffz -p 4 old_binary new_binary patch.hd
```

#### Delta Patch Workflow Example

```bash
#!/bin/bash
# Update distribution workflow

OLD_VERSION="1.0"
NEW_VERSION="1.1"

OLD_BINARY="app-${OLD_VERSION}.exe"
NEW_BINARY="app-${NEW_VERSION}.exe"
PATCH_FILE="app-${OLD_VERSION}-to-${NEW_VERSION}.patch"

# Create patch
bsdiff "$OLD_BINARY" "$NEW_BINARY" "$PATCH_FILE"

# Compress patch
7z a -mx=9 "${PATCH_FILE}.7z" "$PATCH_FILE"

# Show sizes
echo "Full binary: $(stat -c%s "$NEW_BINARY") bytes"
echo "Delta patch: $(stat -c%s "$PATCH_FILE") bytes"
echo "Compressed: $(stat -c%s "${PATCH_FILE}.7z") bytes"

# Distribution: Send compressed patch to users
# Users apply: bspatch app-1.0.exe app-1.1.exe patch.bin
```

### Streaming Installs

Streaming installs allow application usage before full installation completes.

#### Implementation Strategies

```bash
# Prioritize core executables first
installer_order=(
    "core_executable.exe"      # 1st priority
    "critical_libraries.dll"   # 2nd priority
    "standard_libraries.dll"   # 3rd priority
    "assets/"                  # Lower priority
    "documentation/"           # Lowest priority
)

# Download in priority order
for file in "${installer_order[@]}"; do
    download_file "$file"
    mark_as_installed "$file"
    if is_executable_ready; then
        launch_application_in_background &
    fi
done
```

### Lazy Loading

Lazy loading defers loading non-essential resources until needed.

```c
// Example: Lazy load resources
typedef struct {
    char* resource_path;
    void* data;
    bool loaded;
} LazyResource;

void* load_resource(LazyResource* res) {
    if (!res->loaded) {
        res->data = load_from_disk(res->resource_path);
        res->loaded = true;
    }
    return res->data;
}

// Define resources without loading them
LazyResource fonts = { "assets/fonts.data", NULL, false };
LazyResource textures = { "assets/textures.data", NULL, false };

// Load only when needed
void render_ui() {
    void* font_data = load_resource(&fonts);
    // Use font_data...
}
```

#### Lazy Loading Configuration

```yaml
# installer_config.yaml
lazy_loading:
  enabled: true

  # Core resources (load immediately)
  core:
    - main_executable
    - critical_libraries

  # Standard resources (load on first use)
  standard:
    - ui_resources
    - configuration_files

  # Optional resources (load on demand)
  optional:
    - documentation
    - examples
    - locale_files
```

---

## Runtime Optimization

Optimizing application runtime behavior improves user experience and resource efficiency.

### Startup Time Reduction

#### Techniques

1. **Executable Preloading (AOT)**
   - Rust: Compile static binaries with max optimization
   - .NET: Use Native AOT
   - Go: Native compilation (inherent)

2. **Module Lazy Loading**
   ```c
   // Load modules on first use
   extern void load_graphics_module(void);

   void render() {
       static bool loaded = false;
       if (!loaded) {
           load_graphics_module();
           loaded = true;
       }
       // render code
   }
   ```

3. **Reduce JIT Compilation Time**
   - Pre-compile hot functions using PGO
   - Use tiering compilation (high-level first, then optimized)
   - Pre-generate class metadata

4. **Remove Unused Dependencies**
   ```bash
   # Find unused dependencies in Rust
   cargo tree --duplicate
   cargo bloat --release -n 20

   # Find unused imports
   grep -r "^use " src/ | grep -v "crate"
   ```

#### Benchmarking Startup Time

```bash
# Simple startup time measurement (Linux/macOS)
time ./application arg1 arg2

# More precise measurement
/usr/bin/time -v ./application

# Repeated measurements
for i in {1..10}; do /usr/bin/time -v ./application; done

# Profiling startup with perf (Linux)
perf record ./application
perf report

# Windows: WPR (Windows Performance Recorder)
wpr -start GeneralProfile
application.exe
wpr -stop output.etl
```

#### Expected Startup Time by Platform

| Application Type | Target Startup | Optimization |
|------------------|----------------|--------------|
| CLI tool | <100ms | Native compilation, minimal dependencies |
| Web server | <500ms | Defer non-critical initialization |
| Desktop app | <1s | Pre-load UI framework, async resource loading |
| Service | <2s | Background initialization acceptable |

### Memory Footprint

#### Reduction Techniques

1. **String Interning** (reduce duplicate strings)
   ```c
   typedef struct {
       const char* strings[256];
       size_t count;
   } StringPool;

   const char* intern_string(StringPool* pool, const char* str) {
       for (size_t i = 0; i < pool->count; i++) {
           if (strcmp(pool->strings[i], str) == 0)
               return pool->strings[i];
       }
       pool->strings[pool->count++] = strdup(str);
       return pool->strings[pool->count - 1];
   }
   ```

2. **Memory Pooling** (reduce allocation overhead)
   ```c
   typedef struct {
       void* pool;
       size_t available;
   } MemoryPool;

   void* allocate_from_pool(MemoryPool* pool, size_t size) {
       if (size > pool->available) return NULL;
       void* ptr = pool->pool;
       pool->pool = (char*)pool->pool + size;
       pool->available -= size;
       return ptr;
   }
   ```

3. **Data Structure Optimization**
   - Use bit-fields instead of booleans
   - Pack structures efficiently
   - Use enums instead of strings

#### Memory Profiling

```bash
# Linux: valgrind memory analysis
valgrind --tool=massif ./application
ms_print massif.out.<pid>

# Linux: RSS and VSZ tracking
ps aux | grep application
# Monitor RSS (resident memory) growth

# macOS: Instruments
instruments -t "Allocations" -l 30 ./application

# Generic: Monitor peak memory
/usr/bin/time -v ./application 2>&1 | grep "Maximum resident"

# Windows: Task Manager
tasklist /V | find "application.exe"
```

### Disk I/O Optimization

#### Techniques

1. **Asynchronous I/O**
   ```c
   // Non-blocking file operations
   int fd = open("file.txt", O_RDONLY | O_NONBLOCK);
   char buffer[4096];
   ssize_t n = read(fd, buffer, sizeof(buffer));
   if (n == -1 && errno == EAGAIN) {
       // Retry later
   }
   ```

2. **I/O Buffering**
   ```c
   // Use larger buffers for I/O
   #define BUFFER_SIZE (1 << 20)  // 1 MB
   char* buffer = malloc(BUFFER_SIZE);

   FILE* file = fopen("large_file.bin", "rb");
   setvbuf(file, buffer, _IOFBF, BUFFER_SIZE);
   ```

3. **Memory Mapping**
   ```c
   // mmap for fast file access
   int fd = open("file.bin", O_RDONLY);
   size_t size = lseek(fd, 0, SEEK_END);
   void* data = mmap(NULL, size, PROT_READ, MAP_SHARED, fd, 0);
   // Use data directly, no explicit read() needed
   munmap(data, size);
   close(fd);
   ```

#### Disk I/O Benchmarking

```bash
# Linux: iostat monitoring
iostat -x 1 10

# Sequential read speed
dd if=/dev/nvme0n1 of=/dev/null bs=1M count=1000 iflag=direct

# Random read speed
fio --name=random_read --ioengine=libaio --iodepth=32 \
    --rw=randread --bs=4k --numjobs=4 --size=1G

# Disk latency
fio --name=latency --ioengine=libaio --iodepth=1 \
    --rw=randread --bs=4k --numjobs=1 --size=1G

# Cache behavior
perf stat -e cache-references,cache-misses ./application
```

### Network Efficiency

#### Techniques

1. **Connection Pooling**
   ```c
   typedef struct {
       int sockets[MAX_CONNECTIONS];
       bool in_use[MAX_CONNECTIONS];
       size_t count;
   } ConnectionPool;

   int get_connection(ConnectionPool* pool) {
       for (size_t i = 0; i < pool->count; i++) {
           if (!pool->in_use[i]) {
               pool->in_use[i] = true;
               return pool->sockets[i];
           }
       }
       return -1;  // No available connection
   }
   ```

2. **Compression**
   ```bash
   # HTTP compression (gzip, brotli)
   curl -H "Accept-Encoding: gzip, br" http://example.com

   # Protocol-level compression
   # Use QUIC (HTTP/3) for lower latency and better compression
   ```

3. **Request Batching**
   ```c
   // Batch multiple small requests into one
   typedef struct {
       void* requests[100];
       size_t count;
   } RequestBatch;

   void flush_batch(RequestBatch* batch) {
       send_to_server(batch->requests, batch->count);
       batch->count = 0;
   }
   ```

#### Network Benchmarking

```bash
# Measure latency
ping -c 10 example.com

# HTTP request latency
curl -w "Total: %{time_total}s\n" http://example.com

# Connection speed
iperf3 -c server_ip -t 30

# Download speed
wget --output-document=/dev/null http://example.com/large_file.bin
```

---

## Deployment Architecture

Optimizing deployment architecture improves availability, performance, and user experience globally.

### CDN Strategy

#### CloudFront (AWS)

Architecture features:
- 400+ edge locations with 13+ regional edge caches
- Tiered caching model
- Origin Shield option for additional origin protection

```yaml
# CloudFront distribution config
distribution:
  enabled: true
  origin_shield: true

  cache_behaviors:
    - path_pattern: "*.html"
      cache_ttl: 3600
      compress: true

    - path_pattern: "*.{js,css}"
      cache_ttl: 31536000  # 1 year
      compress: true

    - path_pattern: "api/*"
      cache_ttl: 0  # No caching for API
      forward_cookies: true
      forward_query_strings: true
```

```bash
# CloudFront cache invalidation
aws cloudfront create-invalidation \
  --distribution-id E1234567890ABC \
  --paths "/*"

# Monitor cache performance
aws cloudfront get-distribution-statistics \
  --distribution-id E1234567890ABC
```

#### Cloudflare

Architecture features:
- 335+ edge locations in 125+ countries
- Flat, anycast-based network (no mid-tier caches)
- Built-in DDoS protection and WAF

```toml
# Wrangler config (Cloudflare Workers)
[env.production]
routes = [
  { pattern = "example.com/*", zone_name = "example.com" }
]

[[services]]
binding = "CACHE"
service = "cache-service"
environment = "production"
```

```javascript
// Cloudflare Workers: Cache strategy
addEventListener('fetch', event => {
  event.respondWith(handleRequest(event.request));
});

async function handleRequest(request) {
  const cacheKey = new Request(request.url, { method: 'GET' });
  const cache = caches.default;

  let response = await cache.match(cacheKey);
  if (response) return response;

  response = await fetch(request);

  // Cache successful responses
  if (response.status === 200) {
    const cacheResponse = response.clone();
    event.waitUntil(cache.put(cacheKey, cacheResponse));
  }

  return response;
}
```

#### CloudFront vs Cloudflare Comparison

| Feature | CloudFront | Cloudflare |
|---------|-----------|-----------|
| Edge Locations | 400+ | 335+ |
| Caching Model | Tiered | Flat Anycast |
| Nearest PoP | Regional caches | Direct PoP access |
| latency (avg) | ~100ms | ~80ms (faster) |
| Compression | Native gzip | Native gzip + Brotli |
| Workers | Lambda@Edge | Cloudflare Workers |
| DDoS Protection | Basic | Advanced (built-in) |
| Price | Pay per GB | Fixed rate |

### Caching Strategies

#### Cache-Control Headers

```bash
# Static assets (long cache, immutable)
# Use fingerprinting in filenames: app.abc123.js
Cache-Control: public, max-age=31536000, immutable

# HTML (frequent updates)
Cache-Control: public, max-age=3600, stale-while-revalidate=86400

# API responses
Cache-Control: public, max-age=300, stale-while-revalidate=3600

# User-specific content
Cache-Control: private, max-age=3600, stale-while-revalidate=86400
```

#### Multi-Layer Caching

```yaml
caching_strategy:
  # Browser cache (24 hours)
  browser:
    ttl: 86400
    types: [images, css, js, fonts]

  # CDN edge cache (1 hour)
  edge:
    ttl: 3600
    types: [html, api]

  # Origin shield (24 hours)
  origin_shield:
    ttl: 86400

  # Database cache (5 minutes)
  database:
    ttl: 300
    types: [api_responses]
```

#### Cache Invalidation

```bash
# Time-based invalidation (filename versioning)
# app.v1.2.3.js -> updates automatically

# Event-based invalidation
POST /api/cache/invalidate
{
  "paths": ["/api/users/*", "/images/*"]
}

# Full cache purge (use sparingly)
cloudflare_curl DELETE "https://api.cloudflare.com/client/v4/zones/{zone_id}/purge_cache" \
  --data '{"files":["*"]}'
```

### Multi-Region Deployment

#### Architecture Pattern

```yaml
global_deployment:
  regions:
    - name: us-west
      primary: true
      failover: us-east

    - name: us-east
      failover: eu-west

    - name: eu-west
      failover: ap-southeast

    - name: ap-southeast
      failover: us-west

  traffic_routing:
    strategy: geolocation
    rules:
      - region: us-*
        weight: 40
      - region: eu-*
        weight: 35
      - region: ap-*
        weight: 25

  health_checks:
    interval: 30
    timeout: 10
    unhealthy_threshold: 3
```

#### Deployment Commands

```bash
# Deploy to all regions
for region in us-west us-east eu-west ap-southeast; do
    echo "Deploying to $region..."
    kubectl --context=$region apply -f deployment.yaml
done

# Verify deployment health
for region in us-west us-east eu-west ap-southeast; do
    echo "Health check: $region"
    curl -s https://${region}.api.example.com/health | jq .
done

# Test failover
# Disable primary region
aws elbv2 deregister-targets \
  --target-group-arn arn:aws:elasticloadbalancing:us-west-2:xxx:targetgroup/xxx \
  --targets Id=i-1234567890abcdef0
```

---

## Platform-Specific Optimizations

Optimize applications for specific platforms and operating systems.

### Windows (.NET)

#### NGEN (Native Image Generation)

NGEN pre-compiles .NET assemblies to native code, improving startup time by 15-30%.

```bash
# Install NGEN (usually in .NET Framework directory)
cd "C:\Windows\Microsoft.NET\Framework\v4.0.30319"

# Generate native image
ngen install MyAssembly.dll

# Remove native image
ngen uninstall MyAssembly.dll

# List all native images
ngen display

# Force update for all assemblies
ngen update /force
```

**Important Note:** NGEN is deprecated in favor of tiered compilation in .NET Core. For modern .NET Core:

```csharp
// Enable tiered compilation (default in .NET 5+)
// In csproj:
<PropertyGroup>
    <TieredCompilation>true</TieredCompilation>
    <TieredCompilationQuickJit>true</TieredCompilationQuickJit>
</PropertyGroup>

// Or via environment variable
setx DOTNET_TieredCompilation 1
setx DOTNET_TieredCompilationQuickJit 1
```

#### Native AOT (.NET 8+)

Compile .NET applications to native code for maximum startup performance.

```xml
<!-- Project file configuration -->
<Project Sdk="Microsoft.NET.Sdk">
    <PropertyGroup>
        <OutputType>Exe</OutputType>
        <TargetFramework>net8.0</TargetFramework>
        <PublishAot>true</PublishAot>
    </PropertyGroup>
</Project>
```

```bash
# Publish as Native AOT
dotnet publish -c Release -p PublishAot=true

# Results
# Startup: <100ms
# Memory: 30-50MB
# Size: 20-50MB (single executable)
```

### macOS

#### Notarization Optimization

Optimize notarization for faster processing and app launch.

```bash
# Create developer ID certificate
# In Xcode: Preferences > Accounts > Manage Certificates

# Sign binary
codesign -s "Developer ID Application" \
  --entitlements entitlements.plist \
  --timestamp \
  --options runtime \
  MyApp.app

# Verify signature
codesign -dv MyApp.app

# Create notarization package
ditto -c -k --sequesterRsrc --keepParent MyApp.app MyApp.zip

# Submit for notarization
xcrun notarytool submit MyApp.zip \
  --apple-id <apple-id> \
  --team-id <team-id> \
  --password <app-specific-password>

# Check notarization status
xcrun notarytool info <submission-id> \
  --apple-id <apple-id> \
  --team-id <team-id> \
  --password <app-specific-password>

# Staple notarization ticket
xcrun stapler staple MyApp.app
```

#### Code Size Optimization

```bash
# Remove unused symbols
strip -u -r MyApp

# Analyze binary size
otool -lh MyApp | head
nm -m MyApp | sort -k 3 -rn | head -20

# Use dsymutil to extract debug symbols
dsymutil -o MyApp.dSYM MyApp
strip MyApp
```

### Linux

#### apt-fast (Repository Mirror Optimization)

Accelerate package downloads using parallel connections.

```bash
# Install apt-fast
git clone https://github.com/itvladimir/apt-fast.git
cd apt-fast
sudo cp apt-fast /usr/local/bin/apt-fast
sudo cp apt-fast.conf /etc/apt-fast.conf

# Configure fastest mirrors
sudo apt-fast update

# Use apt-fast instead of apt-get
sudo apt-fast install -y package1 package2 package3

# Configuration in /etc/apt-fast.conf
_APTMGR=apt
_DOWNLOADER=aria2c
_CONN_COUNT=5
```

#### Binary Stripping for Distribution

```bash
# Build with debug symbols
gcc -g -O2 source.c -o binary.debug

# Strip debug symbols for distribution
objcopy --only-keep-debug binary.debug binary.debug.symbols
objcopy --strip-debug binary.debug binary
objcopy --add-gnu-debuglink=binary.debug.symbols binary

# Size comparison
ls -lh binary.debug binary
# ~60-70% size reduction
```

### Docker

#### Multi-Stage Builds

Reduce final image size by compiling in one stage and copying binaries to a minimal image.

```dockerfile
# Dockerfile with multi-stage build

# Stage 1: Build
FROM golang:1.21 as builder

WORKDIR /app
COPY . .

RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 \
    go build -ldflags="-s -w" -o app main.go

# Stage 2: Runtime
FROM scratch

COPY --from=builder /app/app /app
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/

ENTRYPOINT ["/app"]
```

Image size comparison:
- Without multi-stage: 1.2 GB
- With multi-stage: 15 MB

#### Docker Layer Optimization

```dockerfile
# Optimize layer caching order
FROM node:18-alpine

# Install dependencies (cache this)
RUN apk add --no-cache python3 make g++

# Copy package files (cache invalidates less often)
COPY package*.json ./

# Install npm dependencies
RUN npm ci --only=production && \
    npm cache clean --force

# Copy application code (frequently changes)
COPY . .

# Build application
RUN npm run build

# Remove build dependencies
RUN rm -rf node_modules/.cache && \
    npm prune --only=production

EXPOSE 3000
CMD ["node", "server.js"]
```

#### Docker Image Size Benchmarks

| Base Image | Size | Use Case |
|-----------|------|----------|
| alpine | 5-10 MB | Minimal, efficient |
| scratch | <1 MB | Pre-compiled binaries only |
| ubuntu | 77 MB | Full tooling |
| debian | 101 MB | Compatibility |

---

## Benchmarking & Profiling

Measure and analyze application performance to identify optimization opportunities.

### Binary Size Benchmarking

#### Tools

```bash
# Rust: cargo-bloat
cargo install cargo-bloat
cargo bloat --release -n 20

# Rust: cargo-tree (dependency analysis)
cargo tree --duplicates

# Generic: GNU binutils
size binary
objdump -d binary | head -50
nm -l binary | sort -k 2 -rn | head -20

# Generic: Google Bloaty
bloaty binary -d compileunits
bloaty binary -d symbols
```

#### Example Output Analysis

```bash
$ cargo bloat --release -n 10
    Finished release [optimized] target(s) in 0.01s
    Analyzing target/release/myapp

 File  Size      Crate Name
 1.2%   23.4KB   myapp std::collections::hash::map
 0.9%   17.2KB   myapp serde_json::parser
 0.8%   15.3KB   myapp tokio::runtime
 0.7%   13.5KB   myapp regex::compile
 0.6%   11.8KB   myapp std::io
 0.5%    9.7KB   myapp myapp main
```

**Action:** Remove serde_json if not needed, or use `serde_json` feature flags to minimize.

### Speed Benchmarking

#### Micro-benchmarks

```bash
# Rust: criterion (built-in benchmarks)
[dev-dependencies]
criterion = "0.5"

# Run benchmarks
cargo bench --release

# C/C++: Google Benchmark
git clone https://github.com/google/benchmark.git
cd benchmark && cmake -E make_directory build && cd build
cmake -DCMAKE_BUILD_TYPE=Release ..
make -j
```

#### Macro-benchmarks

```bash
# Application startup time (repeated measurements)
for i in {1..100}; do
    (time ./application) 2>&1 | grep real
done | awk '{sum+=$2; n++} END {print "Average:", sum/n "ms"}'

# Throughput measurement
time ./application process 1000000 items

# Latency percentiles
./application --benchmark | \
    awk '{print $NF}' | \
    sort -n | \
    awk '{
        data[NR]=$1;
        sum+=$1
    }
    END {
        n=NR;
        print "p50: " data[int(n*0.5)];
        print "p95: " data[int(n*0.95)];
        print "p99: " data[int(n*0.99)]
    }'
```

#### Comparative Benchmarking

```bash
# Compare performance before/after optimization
run_benchmark() {
    local app=$1
    local name=$2
    echo "Benchmarking: $name"
    hyperfine --runs 10 "./$app"
}

run_benchmark "app.old" "Before optimization"
run_benchmark "app.new" "After optimization"

# hyperfine output:
# 'app.old' ran 1.42x slower than 'app.new'
```

### Profiling Tools

#### Linux: perf

```bash
# Record CPU profile
perf record -F 99 ./application
perf report

# Flame graph
perf record -g ./application
perf script | stackcollapse-perf.pl | flamegraph.pl > graph.svg

# Event-based profiling
perf stat -e cycles,instructions,cache-misses ./application

# Memory profiling
perf record -e page-faults ./application
perf report
```

#### macOS: Instruments

```bash
# Profile with Instruments
instruments -t "Time Profiler" ./application

# Collect to file
instruments -t "Time Profiler" \
  -l 30 \
  -o profile.trace \
  ./application

# Analyze in Xcode
open profile.trace
```

#### Windows: Performance Analyzer

```batch
# Windows Performance Recorder
wpr -start GeneralProfile
application.exe
wpr -stop output.etl

# Windows Performance Analyzer
wpa output.etl
```

#### Valgrind (Linux Memory Analysis)

```bash
# Memory profiling
valgrind --tool=massif --massif-out-file=massif.out ./application
ms_print massif.out

# Leak detection
valgrind --leak-check=full --show-leak-kinds=all ./application

# Cache profiling
valgrind --tool=cachegrind ./application
cg_annotate cachegrind.out.* | head -40
```

### Performance Regression Testing

```bash
#!/bin/bash
# regression_test.sh

THRESHOLD=5  # 5% threshold

run_benchmark() {
    hyperfine --runs 10 "./$1" | grep "Mean" | awk '{print $2}'
}

baseline=$(run_benchmark "app.baseline")
current=$(run_benchmark "app.new")

diff_percent=$(echo "scale=2; (($current - $baseline) / $baseline) * 100" | bc)

echo "Baseline: ${baseline}ms"
echo "Current:  ${current}ms"
echo "Change:   ${diff_percent}%"

if (( $(echo "$diff_percent > $THRESHOLD" | bc -l) )); then
    echo "ERROR: Performance regression detected (>${THRESHOLD}%)"
    exit 1
fi

echo "OK: Performance within threshold"
exit 0
```

---

## Quick Reference

### Optimization Checklist

#### Pre-Release

- [ ] Enable compiler optimizations (-O2 minimum)
- [ ] Enable LTO for final builds
- [ ] Strip debug symbols for distribution
- [ ] Run PGO profiling with realistic workload
- [ ] Analyze binary size (cargo-bloat, bloaty)
- [ ] Test on target platform/architecture
- [ ] Benchmark startup time
- [ ] Memory profile with valgrind/Instruments

#### Installer

- [ ] Compress with appropriate algorithm (7-Zip for max, Zstd for speed)
- [ ] Create delta patches for updates
- [ ] Test streaming install workflow
- [ ] Verify extract times on slow systems

#### Deployment

- [ ] Configure CDN caching headers
- [ ] Set up multi-region deployment
- [ ] Configure health checks
- [ ] Plan cache invalidation strategy
- [ ] Test failover behavior

#### Platform-Specific

- [ ] **Windows**: Enable tiered compilation or use Native AOT
- [ ] **macOS**: Notarize and sign application
- [ ] **Linux**: Strip symbols, consider apt-fast
- [ ] **Docker**: Use multi-stage builds

### Performance Target Metrics

| Metric | Target | Acceptable | Poor |
|--------|--------|-----------|------|
| Startup time | <100ms | <500ms | >1s |
| Memory (CLI) | <50MB | <100MB | >500MB |
| Binary size (single executable) | <20MB | <50MB | >100MB |
| Download size | Minimize | <100MB | >500MB |
| Disk I/O latency | <1ms | <5ms | >10ms |
| API response time | <100ms | <500ms | >1s |

### Common Optimization Commands Reference

```bash
# Build optimization (GCC)
gcc -O2 -ffunction-sections -fdata-sections -Wl,--gc-sections \
    -fvisibility=hidden -s -o binary source.c

# Build with LTO and PGO (Rust)
[profile.release]
lto = "fat"
codegen-units = 1
opt-level = 3
strip = true

# Docker multi-stage (Go)
# Stage 1
COPY . /src
RUN cd /src && CGO_ENABLED=0 go build -ldflags="-s -w" -o app

# Stage 2
FROM scratch
COPY --from=builder /src/app /app
ENTRYPOINT ["/app"]

# Compression
7z a -mx=9 archive.7z binary
bsdiff old_binary new_binary patch.bin
upx --best binary.exe

# Profiling
cargo bench --release
perf record -g ./application && perf script | flamegraph.pl
valgrind --tool=massif ./application && ms_print massif.out.*
```

---

## References & Further Reading

### Compiler Documentation
- [GCC Optimization Options](https://gcc.gnu.org/onlinedocs/gcc/Optimize-Options.html)
- [MSVC Compiler Optimizations](https://docs.microsoft.com/en-us/cpp/build/reference/compiler-options-listed-by-category)
- [Rust Book: Release Profiles](https://doc.rust-lang.org/cargo/reference/profiles.html)

### Tools
- [cargo-bloat](https://github.com/RazrFalcon/cargo-bloat) - Rust binary size analyzer
- [Google Bloaty](https://github.com/google/bloaty) - Binary size profiler
- [UPX](https://upx.github.io/) - Executable compressor
- [Flamegraph](https://github.com/brendangregg/FlameGraph) - Profiling visualization

### Performance Resources
- [Linux Kernel Perf Wiki](https://perf.wiki.kernel.org/)
- [The Rust Performance Book](https://nnethercote.github.io/perf-book/)
- [AWS Performance Optimization](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/performance-optimization.html)

---

**Last Updated:** November 2024
**Version:** 1.0
