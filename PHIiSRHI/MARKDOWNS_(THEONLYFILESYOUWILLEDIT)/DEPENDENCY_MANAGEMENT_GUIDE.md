# Dependency Management Guide

A comprehensive guide to managing software dependencies across languages, platforms, and deployment models. Covers bundling strategies, implementation patterns, conflict resolution, and security best practices.

---

## Table of Contents

1. [Bundling Strategies](#bundling-strategies)
2. [Implementation Patterns](#implementation-patterns)
3. [Conflict Resolution](#conflict-resolution)
4. [Security](#security)
5. [Decision Matrices](#decision-matrices)
6. [Best Practices Summary](#best-practices-summary)

---

## Bundling Strategies

Bundling strategies determine how dependencies are packaged and distributed with your application. Each approach has distinct trade-offs between distribution size, update capability, and compatibility.

### Static vs Dynamic Linking

#### Static Linking

**Definition:** Libraries are compiled directly into the executable at build time. The entire library code is embedded in the final binary.

**Advantages:**
- Larger executable but self-contained and portable
- No runtime dependency on external libraries
- Easier to distribute to diverse environments
- Faster execution (no dynamic linking overhead)
- Issues caught at compile time
- Binary compatibility guaranteed

**Disadvantages:**
- Significantly larger file size
- Security patches require recompilation and redistribution
- Memory inefficiency when multiple processes use the same library
- Difficulty in updating shared functionality

**Use Cases:**
- Containerized applications
- Mobile applications (iOS, Android)
- Security-critical applications
- Offline/air-gapped deployments
- Single-purpose binaries

**Example - C/C++ Static Linking:**
```bash
# Compile with static linking
gcc -static myprogram.c -o myprogram
# Result: Single binary with all dependencies included
```

#### Dynamic Linking

**Definition:** Libraries are linked at runtime. The executable references shared libraries installed on the system.

**Advantages:**
- Smaller executable size
- Efficient memory usage (shared libraries in memory)
- Security updates propagate without recompilation
- Easy to update dependencies
- Standard approach in most Unix-like systems

**Disadvantages:**
- Runtime dependency on correct library versions
- Complex dependency resolution
- Potential for version conflicts
- Harder to debug issues
- Environment-dependent execution

**Use Cases:**
- System utilities
- Desktop applications
- Long-running services
- Cloud deployments with controlled environments
- Development environments

**Example - C/C++ Dynamic Linking:**
```bash
# Compile with dynamic linking (default)
gcc myprogram.c -o myprogram
# Links to shared libraries (libm.so, libc.so, etc.)
```

#### Hybrid Strategy

Many organizations use a layered approach:
- **Development:** Dynamic linking for fast iteration
- **CI/CD Testing:** Reproducible environment with pinned versions
- **Production:** Static linking for binaries, dynamic for containers

```makefile
# Example Makefile with hybrid approach
.PHONY: dev prod

dev:
	gcc -shared myprogram.c -o myprogram

prod:
	gcc -static myprogram.c -o myprogram

docker: prod
	docker build -t myapp .
```

---

### Vendoring

**Definition:** Committing external dependencies into your version control system, eliminating the need to download them at build time.

#### When to Vendor

**Recommended for:**
- Executable projects (not libraries)
- CI/CD pipelines without reliable network access
- Supply chain security-critical projects
- Projects with specific version locking requirements
- Air-gapped deployments

**Not Recommended for:**
- Library projects (forces vendored dependencies on users)
- Projects needing frequent updates
- Large dependency trees
- Multi-project monorepos

#### Go Vendoring Example

Go's vendoring is the gold standard for language-level dependency management.

```bash
# Initialize Go modules
go mod init github.com/user/myproject

# Add dependencies
go get github.com/gorilla/mux@v1.8.0

# Create vendor directory with checksums (Cargo.lock equivalent)
go mod vendor

# Tidy up dependencies
go mod tidy

# Result: vendor/ directory committed to version control
# with go.sum for hash verification
```

**go.mod Example:**
```
module github.com/user/myproject

go 1.21

require (
    github.com/gorilla/mux v1.8.0
    github.com/google/uuid v1.3.0
)

require (
    github.com/gorilla/context v1.1.1 // indirect
)
```

**go.sum Example:**
```
github.com/google/uuid v1.3.0 h1:7cqIQjlzS7aLJRRm+FQAfHS5sCr0/TmyREO3ygsFSE=
github.com/google/uuid v1.3.0/go.mod h1:TIyPZe4MgqvfeYDBFedMoGGpEw/LqMQaWyT/7O0LcQ=
github.com/gorilla/context v1.1.1 h1:AWwleXJkX/nhxjqjZKShlXV/CI2IBmQ+gVUe/Qd9+I=
github.com/gorilla/context v1.1.1/go.mod h1:kBGZzfjLAUO3sFANQKP3CBs5tvBP4XStQn1z7Xb8+M=
```

**Best Practice: For executables, always commit vendor/ and go.sum**

```bash
# Command to verify vendoring integrity
go mod verify
```

#### Rust Vendoring Example

```bash
# Initialize Rust project
cargo init myproject
cd myproject

# Add dependencies to Cargo.toml
# Cargo.toml:
[dependencies]
serde = "1.0"
serde_json = "1.0"
reqwest = { version = "0.11", features = ["json"] }

# Vendor dependencies
cargo vendor --versioned-dirs

# Create .cargo/config.toml to use vendored dependencies
cat > .cargo/config.toml << 'EOF'
[source.crates-io]
replace-with = "vendored-sources"

[source.vendored-sources]
directory = "vendor"
EOF

# Update Cargo.lock with hashes
cargo update
```

**When vendoring Go vs Rust:**
| Aspect | Go | Rust |
|--------|----|----|
| Commit vendor/ for binaries? | Yes | Optional (has Cargo.lock) |
| Hash verification | go.sum | Cargo.lock |
| Reproducibility | Excellent | Excellent |
| Use with lock file? | Yes (go.mod) | Yes (Cargo.lock) |

---

### Virtual Environments

Virtual environments isolate project dependencies, preventing conflicts between projects and system packages.

#### Python Virtual Environments

**Built-in venv (Recommended for simplicity):**
```bash
# Create virtual environment
python3 -m venv venv

# Activate
source venv/bin/activate  # macOS/Linux
venv\Scripts\activate     # Windows

# Install dependencies
pip install requests django

# Generate requirements file
pip freeze > requirements.txt

# Install from requirements
pip install -r requirements.txt

# Deactivate
deactivate
```

**requirements.txt Best Practices:**
```txt
# Pin exact versions for reproducibility
requests==2.31.0
django==4.2.0
celery==5.3.1

# Pin with hash for security verification
Django==4.2.0 --hash=sha256:abc123def456...

# Use pip-tools for deterministic builds
pip-compile requirements.in -o requirements.txt
```

#### Python Poetry (Modern Standard)

Poetry provides deterministic builds with pyproject.toml and poetry.lock:

```bash
# Create new project
poetry new myproject

# Add dependencies
poetry add requests django

# Add development dependencies
poetry add --group dev pytest black mypy

# Install in isolated environment
poetry install

# Run in project environment
poetry run python script.py

# Export to requirements.txt if needed
poetry export -f requirements.txt -o requirements.txt --without-hashes
```

**pyproject.toml Example:**
```toml
[tool.poetry]
name = "myapp"
version = "0.1.0"
description = "My application"

[tool.poetry.dependencies]
python = "^3.9"
requests = "^2.31"
django = "^4.2"

[tool.poetry.group.dev.dependencies]
pytest = "^7.0"
black = "^23.0"
mypy = "^1.0"

[build-system]
requires = ["poetry-core"]
build-backend = "poetry.core.masonry.api"
```

**poetry.lock Partial Example:**
```toml
[[package]]
name = "django"
version = "4.2.0"
description = "A high-level Python web framework that encourages rapid development and clean, pragmatic design."
category = "main"
optional = false
python-versions = ">=3.8"
files = [
    {file = "Django-4.2.0-py3-none-any.whl", hash = "sha256:..."}
]
```

#### Node.js Virtual Environments

Modern Node.js uses corepack and workspaces:

```bash
# Using npm (built-in)
npm install  # Creates node_modules/

# Using yarn
yarn install

# Using pnpm (more efficient)
pnpm install  # Creates pnpm-lock.yaml

# Local binaries available via npx
npx eslint --version  # Runs from node_modules/.bin
```

---

### Container Isolation

Containers provide filesystem-level isolation, the strongest form of dependency isolation.

#### Docker Multi-Stage Build

```dockerfile
# Stage 1: Builder
FROM python:3.11 as builder
WORKDIR /app
COPY requirements.txt .
RUN pip install --user --no-cache-dir -r requirements.txt

# Stage 2: Runtime
FROM python:3.11-slim
WORKDIR /app
COPY --from=builder /root/.local /root/.local
COPY . .
ENV PATH=/root/.local/bin:$PATH
CMD ["python", "app.py"]
```

**Advantages:**
- Completely isolated dependencies per container
- Reproducible across any environment
- Can pin base image versions
- Easy to update dependencies without touching host
- Layer caching for faster builds

**Best Practices:**
```dockerfile
# Use specific versions, not 'latest'
FROM python:3.11.7-slim

# Pin all dependency versions
RUN pip install --no-cache-dir \
    requests==2.31.0 \
    django==4.2.0

# Use lockfiles in containers
COPY poetry.lock pyproject.toml ./
RUN poetry config virtualenvs.create false && \
    poetry install --no-interaction --no-ansi
```

---

### Runtime Bundling

Bundling dependencies into the application package at runtime.

#### Java Fat JAR / Uber JAR

**Definition:** Single JAR file containing the application and all its dependencies.

**Maven Shade Plugin (Recommended):**
```xml
<plugin>
    <groupId>org.apache.maven.plugins</groupId>
    <artifactId>maven-shade-plugin</artifactId>
    <version>3.4.1</version>
    <executions>
        <execution>
            <phase>package</phase>
            <goals>
                <goal>shade</goal>
            </goals>
            <configuration>
                <transformers>
                    <transformer implementation="org.apache.maven.plugins.shade.resource.ManifestResourceTransformer">
                        <mainClass>com.example.Main</mainClass>
                    </transformer>
                </transformers>
                <finalName>${project.artifactId}-${project.version}-uber</finalName>
            </configuration>
        </execution>
    </executions>
</plugin>
```

**Build and Run:**
```bash
mvn clean package
java -jar myapp-1.0.0-uber.jar
```

**Maven Assembly Plugin (Alternative):**
```xml
<plugin>
    <groupId>org.apache.maven.plugins</groupId>
    <artifactId>maven-assembly-plugin</artifactId>
    <version>3.4.2</version>
    <executions>
        <execution>
            <phase>package</phase>
            <goals>
                <goal>single</goal>
            </goals>
            <configuration>
                <archive>
                    <manifest>
                        <mainClass>com.example.Main</mainClass>
                    </manifest>
                </archive>
                <descriptorRefs>
                    <descriptorRef>jar-with-dependencies</descriptorRef>
                </descriptorRefs>
            </configuration>
        </execution>
    </executions>
</plugin>
```

**Fat JAR Comparison:**

| Method | Package Relocation | Class Loader | Size | Conflicts | Complexity |
|--------|-------------------|--------------|------|-----------|------------|
| Shade Plugin | Yes | Standard | Large | Low | Medium |
| Assembly Plugin | No | Standard | Large | Medium | Medium |
| One-JAR | No | Custom | Large | Low | Low |
| JAR-of-JARs | No | Custom | Large | None | Medium |

**Note:** Maven Shade Plugin is preferred for its ability to relocate packages and prevent dependency conflicts.

---

## Implementation Patterns

Language and ecosystem-specific dependency management patterns.

### Python

#### Pattern 1: Requirements.txt (Simple Projects)
```
# requirements.txt
Flask==2.3.0
SQLAlchemy==2.0.0
python-dotenv==1.0.0
```

**Pros:** Simple, universally supported
**Cons:** No lock file, no dev dependency separation
**Use Case:** Small projects, scripts

#### Pattern 2: Poetry (Modern Standard)
```toml
# pyproject.toml
[tool.poetry]
name = "myapp"

[tool.poetry.dependencies]
python = "^3.9"
flask = "^2.3"

[tool.poetry.group.dev.dependencies]
pytest = "^7.0"
```

**Pros:** Deterministic builds, lock file, dev dependencies, modern
**Cons:** Steeper learning curve
**Use Case:** Professional projects, libraries

#### Pattern 3: Pipenv (Environment + Lock)
```bash
# Pipfile
[[source]]
url = "https://pypi.org/simple"
verify_ssl = true
name = "pypi"

[packages]
requests = "*"

[dev-packages]
pytest = "*"

[requires]
python_version = "3.9"
```

**Pros:** Combines virtualenv and requirements management
**Cons:** Slower than Poetry, less active
**Use Case:** Projects migrating from requirements.txt

#### Pattern 4: Conda (Scientific Computing)
```bash
# environment.yml
name: myenv
channels:
  - conda-forge
  - defaults
dependencies:
  - python=3.9
  - numpy::numpy
  - pandas
  - matplotlib
```

**Pros:** Handles system packages, scientific packages
**Cons:** Large, slower, separate ecosystem
**Use Case:** Data science, scientific computing

---

### Node.js

#### Pattern 1: npm with package-lock.json
```json
{
  "name": "myapp",
  "version": "1.0.0",
  "dependencies": {
    "express": "^4.18.0",
    "dotenv": "^16.0.0"
  },
  "devDependencies": {
    "jest": "^29.0.0",
    "eslint": "^8.0.0"
  }
}
```

**Lock File (package-lock.json):**
```json
{
  "name": "myapp",
  "version": "1.0.0",
  "lockfileVersion": 3,
  "packages": {
    "": {
      "name": "myapp",
      "version": "1.0.0",
      "dependencies": {
        "express": "4.18.2"
      }
    },
    "node_modules/express": {
      "version": "4.18.2",
      "resolved": "https://registry.npmjs.org/express/-/express-4.18.2.tgz",
      "integrity": "sha512-5/PsL6iGPdfQ/lKM1UuYUP5APluqQ8mh0dVonda/SubbNqWuVc7nrq3dXKLPI3WrqbR6wpMSTY336TVQcyPT4Q=="
    }
  }
}
```

**Best Practices:**
```bash
# Always commit both files
git add package.json package-lock.json

# Avoid npm shrinkwrap unless in monorepo
# Use npm ci in CI/CD (installs exact versions)
npm ci

# Local install for development
npm install
```

#### Pattern 2: Yarn (Deterministic)
```yaml
# yarn.lock (excerpt)
express@^4.18.0:
  version "4.18.2"
  resolved "https://registry.yarnpkg.com/express/-/express-4.18.2.tgz#5/PsL6iGPdfQ/lKM1UuYUP5APluqQ8mh0dVonda/SubbNqWuVc7nrq3dXKLPI3WrqbR6wpMSTY336TVQcyPT4Q=="
  dependencies:
    body-parser "1.20.1"
    content-disposition "0.5.4"
```

**Advantages:** Workspace support, offline mode, more deterministic

#### Pattern 3: pnpm (Space-Efficient)
```yaml
# pnpm-lock.yaml uses content-addressable storage
# Dependencies stored in single location
# All projects share same instance
```

**Advantages:**
- Significantly reduces disk space
- Prevents phantom dependencies
- Faster installation

---

### Rust

#### Pattern 1: Cargo with Cargo.lock
```toml
# Cargo.toml
[package]
name = "myapp"
version = "0.1.0"
edition = "2021"

[dependencies]
serde = { version = "1.0", features = ["derive"] }
tokio = { version = "1.0", features = ["full"] }
reqwest = "0.11"

[dev-dependencies]
criterion = "0.5"
```

**Cargo.lock Example:**
```toml
[[package]]
name = "myapp"
version = "0.1.0"
dependencies = [
 "serde 1.0.147 (registry+https://github.com/rust-lang/crates.io-index)",
 "tokio 1.34.0 (registry+https://github.com/rust-lang/crates.io-index)",
]

[[package]]
name = "serde"
version = "1.0.147"
source = "registry+https://github.com/rust-lang/crates.io-index"
checksum = "d193d69e403a780c6e40f330f28a887b40e81f20642a60eb6ca7925f7b280403"
```

**Best Practices:**
```bash
# Always commit Cargo.lock for binaries
git add Cargo.lock

# For libraries, follow crates.io recommendation (don't commit)
# Update dependencies carefully
cargo update

# Verify dependencies haven't been tampered
cargo verify-data

# Check for vulnerabilities
cargo audit
```

#### Pattern 2: Cargo Vendor (Offline)
```bash
# Vendor all dependencies
cargo vendor

# Create .cargo/config.toml
[source.crates-io]
replace-with = "vendored-sources"

[source.vendored-sources]
directory = "vendor"

# Then build
cargo build
```

**Use Case:** CI/CD without internet, supply chain security

---

### Go

#### Pattern: go.mod and go.sum
```
# go.mod
module github.com/user/myapp

go 1.21

require (
    github.com/gorilla/mux v1.8.0
    github.com/google/uuid v1.3.0
)

require (
    github.com/gorilla/context v1.1.1 // indirect
)
```

```
# go.sum
github.com/google/uuid v1.3.0 h1:7cqIQjlzS7aLJRRm+FQAfHS5sCr0/TmyREO3ygsFSE=
github.com/google/uuid v1.3.0/go.mod h1:TIyPZe4MgqvfeYDBFedMoGGpEw/LqMQaWyT/7O0LcQ=
github.com/gorilla/context v1.1.1 h1:AWwleXJkX/nhxjqjZKShlXV/CI2IBmQ+gVUe/Qd9+I=
github.com/gorilla/context v1.1.1/go.mod h1:kBGZzfjLAUO3sFANQKP3CBs5tvBP4XStQn1z7Xb8+M=
github.com/gorilla/mux v1.8.0 h1:i40ztqXznAL+3Kl/vz6/iMY8RRZa6mBGzO3WQOx0N4=
github.com/gorilla/mux v1.8.0/go.mod h1:DVbg23sWSpFRCP0SfuHzLrWAvoCM/c1CtP2Q4qg4u0=
```

**Best Practices:**
```bash
# Always commit both files
git add go.mod go.sum

# Tidy dependencies
go mod tidy

# Vendor for offline builds
go mod vendor
git add vendor/

# Verify integrity
go mod verify

# Get specific version
go get github.com/user/pkg@v1.2.3

# Update all
go get -u ./...
```

---

### .NET

#### Framework-Dependent Deployment (FDD)

```xml
<!-- Project file -->
<Project Sdk="Microsoft.NET.Sdk">
    <PropertyGroup>
        <OutputType>Exe</OutputType>
        <TargetFramework>net8.0</TargetFramework>
    </PropertyGroup>

    <ItemGroup>
        <PackageReference Include="Newtonsoft.Json" Version="13.0.3" />
        <PackageReference Include="Polly" Version="8.0.0" />
    </ItemGroup>
</Project>
```

**Publish:**
```bash
dotnet publish -c Release
# Result: ~3 MB, requires .NET runtime installed
# Shares runtime with other apps
```

**Advantages:**
- Minimal size (3 MB vs 100+ MB)
- Automatic runtime updates
- Shared runtime memory
- Ideal for container scenarios

#### Self-Contained Deployment (SCD)

```xml
<Project Sdk="Microsoft.NET.Sdk">
    <PropertyGroup>
        <OutputType>Exe</OutputType>
        <TargetFramework>net8.0</TargetFramework>
        <RuntimeIdentifier>linux-x64</RuntimeIdentifier>
        <SelfContained>true</SelfContained>
    </PropertyGroup>
</Project>
```

**Publish with Trimming (reduce size):**
```xml
<PropertyGroup>
    <PublishTrimmed>true</PublishTrimmed>
    <PublishReadyToRun>true</PublishReadyToRun>
    <PublishSingleFile>true</PublishSingleFile>
    <IncludeNativeLibrariesForSelfExtract>true</IncludeNativeLibrariesForSelfExtract>
</PropertyGroup>
```

**Build:**
```bash
dotnet publish -c Release
# Result: Single executable with all dependencies
# No runtime dependency
# Platform-specific binary
```

**Decision Matrix:**

| Criteria | FDD | SCD |
|----------|-----|-----|
| Size | 3-5 MB | 80-150 MB |
| Runtime Required | Yes (.NET) | No |
| Platform-Specific | No | Yes |
| Docker Friendly | Yes | Less ideal |
| Update Isolation | No (shared) | Yes (isolated) |
| Use Case | Cloud/containers | Offline/Edge |

---

### Java

#### Pattern: Maven with Dependency Management

```xml
<!-- pom.xml -->
<project>
    <modelVersion>4.0.0</modelVersion>
    <groupId>com.example</groupId>
    <artifactId>myapp</artifactId>
    <version>1.0.0</version>

    <properties>
        <maven.compiler.source>11</maven.compiler.source>
        <maven.compiler.target>11</maven.compiler.target>
        <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
    </properties>

    <dependencyManagement>
        <dependencies>
            <dependency>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-dependencies</artifactId>
                <version>3.0.0</version>
                <type>pom</type>
                <scope>import</scope>
            </dependency>
        </dependencies>
    </dependencyManagement>

    <dependencies>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>
        <dependency>
            <groupId>com.google.guava</groupId>
            <artifactId>guava</artifactId>
            <version>31.1-jre</version>
        </dependency>
    </dependencies>

    <build>
        <plugins>
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-shade-plugin</artifactId>
                <version>3.4.1</version>
                <executions>
                    <execution>
                        <phase>package</phase>
                        <goals>
                            <goal>shade</goal>
                        </goals>
                    </execution>
                </executions>
            </plugin>
        </plugins>
    </build>
</project>
```

**Gradle Alternative:**
```groovy
plugins {
    id 'java'
    id 'org.springframework.boot' version '3.0.0'
}

dependencies {
    implementation 'org.springframework.boot:spring-boot-starter-web'
    implementation 'com.google.guava:guava:31.1-jre'
    testImplementation 'org.junit.jupiter:junit-jupiter:5.9.0'
}

tasks.register('bootJar', org.springframework.boot.gradle.tasks.bundling.BootJar) {
    mainClass = 'com.example.Main'
}
```

**Best Practices:**
```bash
# Generate dependency tree
mvn dependency:tree

# Check for conflicts
mvn dependency:analyze

# Update dependencies
mvn versions:use-latest-versions

# Create BOM (Bill of Materials)
# Allows consuming projects to inherit versions
```

---

## Conflict Resolution

Dependency conflicts occur when multiple versions of the same package are required, or when packages have incompatible dependencies.

### DLL Hell (Windows Solutions)

**Problem:** Multiple versions of DLLs in PATH, causing wrong version to load.

#### Solutions

**1. Side-by-Side Assembly (SxS)**
```xml
<!-- myapp.exe.manifest -->
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<assembly xmlns="urn:schemas-microsoft-com:asm.v1" manifestVersion="1.0">
  <assemblyIdentity
    version="1.0.0.0"
    processorArchitecture="*"
    name="myapp"
    type="win32"
  />
  <dependency>
    <dependentAssembly>
      <assemblyIdentity
        type="win32"
        name="Microsoft.Windows.Common-Controls"
        version="6.0.0.0"
        processorArchitecture="x86"
        publicKeyToken="6595b64144ccf1df"
        language="*"
      />
    </dependentAssembly>
  </dependency>
</assembly>
```

**2. Local Deployment**
```
MyApp/
├── myapp.exe
├── mylib.dll         # Version 1.0
├── dependent.dll     # Version 2.0
└── plugins/
    └── plugin.dll    # Uses different versions
```

**3. Version Binding Redirection**
```xml
<!-- app.config -->
<configuration>
  <runtime>
    <bindingRedirect oldVersion="1.0.0.0-1.9.0.0" newVersion="2.0.0.0" />
  </runtime>
</configuration>
```

**4. Use Isolation Containers/AppContainers**
```batch
:: Run application in isolated container
RunDLL32.exe shdocvw.dll,OpenURL myapp://isolated
```

### Shared Library Management (Linux RPATH)

**Problem:** Linux applications may load wrong shared library version at runtime.

#### RPATH (Runtime Path)

```bash
# Set RPATH during compilation
gcc -o myapp myapp.c -Wl,-rpath=/opt/myapp/lib

# Or during linking
ld -o myapp myapp.o -L. -lmylib -Wl,-rpath=$ORIGIN/../lib

# Check RPATH
readelf -d myapp | grep RPATH
# Output: 0x000000000000000f (RPATH) Library rpath: [$ORIGIN/../lib]
```

**RPATH Variables:**
```bash
# $ORIGIN: Directory of executable
gcc -Wl,-rpath='$ORIGIN/../lib'

# $LIB: 32-bit or 64-bit (lib or lib64)
gcc -Wl,-rpath='$ORIGIN/../$LIB'
```

**CMake Integration:**
```cmake
# CMakeLists.txt
set(CMAKE_BUILD_RPATH "${CMAKE_BINARY_DIR}/lib")
set(CMAKE_INSTALL_RPATH "$ORIGIN/../lib")
set(CMAKE_INSTALL_RPATH_USE_LINK_PATH TRUE)

add_executable(myapp main.cpp)
target_link_directories(myapp PRIVATE ${CMAKE_BINARY_DIR}/lib)
```

**Example Directory Structure with RPATH:**
```
myapp/
├── bin/
│   └── myapp              (RPATH: $ORIGIN/../lib)
└── lib/
    ├── libutil.so.1
    ├── libcommon.so.2
    └── libui.so.3
```

#### Environment Variables (Fallback)

```bash
# Set LD_LIBRARY_PATH (less desirable, overrides RPATH)
export LD_LIBRARY_PATH=/opt/myapp/lib:$LD_LIBRARY_PATH
./myapp

# Check library search order
ldd /usr/bin/myapp

# Find dependency
ldconfig -p | grep libssl
```

#### Conan Package Manager (C++)

Conan handles RPATH automatically:

```python
# conanfile.txt
[requires]
openssl/1.1.1
zlib/1.2.11

[generators]
cmake

[options]
openssl:shared=True
```

```bash
conan install . --build=missing
cmake .
make
# Conan sets RPATH automatically
```

### Framework Conflicts (macOS)

**Problem:** macOS applications may load incompatible framework versions.

#### Install Name and Compatibility

```bash
# Check framework dependencies
otool -L /Applications/MyApp.app/Contents/MacOS/MyApp
# Output:
# /Applications/MyApp.app/Contents/MacOS/MyApp (compatibility version 1.0.0, current version 1.0.0)
# /System/Library/Frameworks/Foundation.framework/Foundation (compatibility version 300.0.0, current version 2107.0.0)

# Change install name (before shipping)
install_name_tool -change /usr/local/lib/libmylib.dylib @rpath/libmylib.dylib MyApp

# Set rpath for app bundle
install_name_tool -add_rpath @executable_path/../Frameworks MyApp

# Verify
otool -l MyApp | grep -A5 LC_RPATH
```

#### Framework Bundle Structure

```
MyApp.app/
├── Contents/
│   ├── MacOS/
│   │   └── MyApp           (executable)
│   ├── Frameworks/
│   │   └── MyFramework.framework/
│   │       ├── MyFramework (shared library)
│   │       ├── Headers/
│   │       └── Resources/
│   └── Info.plist
```

### Lock Files Comparison

| Feature | go.sum | package-lock.json | Cargo.lock | poetry.lock | Gemfile.lock |
|---------|--------|-------------------|------------|------------|--------------|
| Hash Verification | Yes | Yes | Yes | Yes | No |
| Transitive Deps | Yes | Yes | Yes | Yes | Yes |
| Format | Text | JSON | TOML | TOML | Text |
| Reproducible | Yes | Yes | Yes | Yes | Yes |
| Merge Conflicts | Low | High | Low | Low | Medium |
| Human Readable | Yes | Poor | Medium | Good | Good |
| Checksum Algorithm | SHA256 | SHA512 | SHA256 | SHA256 | SHA256 |

**When to Commit Lock Files:**
```
Commit:
✓ go.sum (always)
✓ package-lock.json (always)
✓ Cargo.lock (for binaries)
✓ poetry.lock (always)
✓ Gemfile.lock (always)

Don't commit (library projects):
✗ Cargo.lock (optional, library authors should not commit)
✗ .lock files from vendoring dependencies
```

---

## Security

Security practices for managing dependencies safely and identifying vulnerabilities.

### Vulnerability Scanning

#### npm audit (JavaScript/Node.js)

```bash
# Run audit on current project
npm audit

# Example output:
# found 5 vulnerabilities (1 low, 2 moderate, 2 high)

# Fix automatically (if available)
npm audit fix

# Fix only production dependencies
npm audit fix --production

# Generate JSON report
npm audit --json > audit-report.json

# Audit with severity threshold
npm audit --audit-level=moderate
```

**Example Security Advisory:**
```
┌─────────────────────────────────────────────────────────────────┐
│ moderate   | Use of a Broken or Risky Cryptographic Algorithm   │
│            |                                                       │
│ Package    | lodash                                              │
│ Patched in | >= 4.17.21                                          │
│ Dependency of | express [dev]                                    │
│ Path       | express > body-parser > qs > side-channel > lodash │
│ More info  | https://npmjs.com/advisories/1523                   │
└─────────────────────────────────────────────────────────────────┘
```

**CI/CD Integration:**
```yaml
# GitHub Actions
name: Security Audit
on: [push, pull_request]

jobs:
  audit:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
        with:
          node-version: '18'
      - run: npm ci
      - run: npm audit --production
```

#### Dependabot (Multi-Language Security)

Dependabot automatically scans dependencies and creates pull requests for updates.

```yaml
# .github/dependabot.yml
version: 2
updates:
  # Node.js
  - package-ecosystem: "npm"
    directory: "/"
    schedule:
      interval: "weekly"
    allow:
      - dependency-type: "direct"
    pull-request-branch-name:
      separator: "-"
    reviewers:
      - "devops-team"
    assignees:
      - "security-lead"

  # Python
  - package-ecosystem: "pip"
    directory: "/"
    schedule:
      interval: "weekly"

  # Go
  - package-ecosystem: "gomod"
    directory: "/"
    schedule:
      interval: "weekly"

  # Rust
  - package-ecosystem: "cargo"
    directory: "/"
    schedule:
      interval: "weekly"

  # Docker
  - package-ecosystem: "docker"
    directory: "/"
    schedule:
      interval: "weekly"
```

**Features:**
- Automatic vulnerability detection
- Creates pull requests for updates
- Tests updates before merging
- Groups related updates
- Respects version constraints

#### Cargo Audit (Rust)

```bash
# Check for known vulnerabilities
cargo audit

# Example output:
# Crate:     tokio
# Version:   1.0.0
# Title:     Vulnerability Title
# Date:      2021-01-15
# ID:        RUSTSEC-2021-0001
# Advisory:  https://rustsec.org/advisory/RUSTSEC-2021-0001
#
# ADVISORY DETAILS
# ...

# Generate JSON report
cargo audit --json

# Deny vulnerable crates
cargo audit deny

# Check in CI/CD
cargo audit --deny warnings
```

#### Python Poetry Security

```bash
# Built-in vulnerability checking (via pip)
pip install safety

# Check for vulnerabilities
safety check

# Using poetry (requires plugin)
poetry add --group dev pip-audit
poetry run pip-audit

# Generate SBOM with vulnerabilities
poetry export -f requirements.txt | safety check --stdin
```

#### GitHub Security Features

**Secret Scanning:**
```yaml
# Prevents committing secrets like API keys
# Automatically enabled for public repos
# Scans for patterns: GitHub tokens, AWS keys, private keys, etc.
```

**Code Scanning (CodeQL):**
```yaml
# .github/workflows/codeql-analysis.yml
name: "CodeQL"

on:
  push:
    branches: [ main ]

jobs:
  analyze:
    runs-on: ubuntu-latest

    strategy:
      fail-fast: false
      matrix:
        language: [ 'cpp', 'python', 'javascript' ]

    steps:
    - uses: actions/checkout@v3
    - uses: github/codeql-action/init@v2
      with:
        languages: ${{ matrix.language }}
    - uses: github/codeql-action/autobuild@v2
    - uses: github/codeql-action/analyze@v2
```

---

### Supply Chain Security

#### Hash Verification

Verify downloaded dependencies haven't been tampered with.

**npm with Hash Verification:**
```bash
# Generate requirements with hashes
npm install --save-exact package-name

# Use in requirements equivalent
npm ci  # Installs from lock file with hash verification
```

**Python with Hash Mode:**
```
# requirements.txt with hashes
requests==2.31.0 \
    --hash=sha256:abc123def456... \
    --hash=sha256:xyz789...

django==4.2.0 \
    --hash=sha256:def456abc123...
```

**Pip hash verification:**
```bash
pip install --require-hashes -r requirements.txt
```

**Go Hash Verification:**
```
# go.sum automatically verifies hashes
go.sum contains SHA-256 hashes for each dependency version

# Verify no tampering
go mod verify
# Output: all modules verified

# Checksum mismatch example
# go mod download github.com/user/pkg@v1.0.0
# hash mismatch
#     go: verifying github.com/user/pkg@v1.0.0: checksum mismatch
#       downloaded: h1:abc123
#       go.sum:     h1:xyz789
```

#### Dependency Pinning

Always pin exact versions in production, not ranges.

```python
# ❌ BAD: Allows any 2.x version
requests>=2.0,<3.0

# ✅ GOOD: Exact version
requests==2.31.0
```

```javascript
// ❌ BAD: Allows 2.x.x versions
"express": "^2.0.0"

// ✅ GOOD: Exact version in lock file
"express": "2.31.0"  // plus package-lock.json committed
```

```toml
# Rust: Both good (Cargo.lock enforces pinning)
serde = "1.0"           # Cargo.lock locks exact version
serde = "= 1.0.147"     # Explicit exact version
```

#### Dependency Review (GitHub)

```yaml
# .github/workflows/dependency-review.yml
name: 'Dependency Review'
on: [pull_request]

permissions:
  contents: read

jobs:
  dependency-review:
    runs-on: ubuntu-latest
    steps:
      - name: 'Checkout Repository'
        uses: actions/checkout@v3
      - name: 'Dependency Review'
        uses: actions/dependency-review-action@v3
        with:
          fail-on-severity: moderate
```

---

### SBOM Generation

Software Bill of Materials documents all components and dependencies.

#### CycloneDX (Recommended)

CycloneDX is the most comprehensive SBOM standard for vulnerability and supply chain management.

**Node.js SBOM Generation:**
```bash
# Install cyclonedx-npm
npm install -g @cyclonedx/npm

# Generate CycloneDX JSON SBOM
cyclonedx-npm --output-format json > sbom.json

# Generate XML SBOM
cyclonedx-npm --output-format xml > sbom.xml

# Specify version
cyclonedx-npm --spec-version 1.4 > sbom.json
```

**CycloneDX JSON Format Example:**
```json
{
  "bomFormat": "CycloneDX",
  "specVersion": "1.4",
  "serialNumber": "urn:uuid:3e671687-395b-41f5-a30f-a58921a69b79",
  "version": 1,
  "metadata": {
    "timestamp": "2024-01-15T10:30:00Z",
    "tools": [
      {
        "vendor": "CycloneDX",
        "name": "cyclonedx-npm",
        "version": "5.2.0"
      }
    ],
    "component": {
      "bom-ref": "pkg:npm/myapp@1.0.0",
      "type": "application",
      "name": "myapp",
      "version": "1.0.0"
    }
  },
  "components": [
    {
      "bom-ref": "pkg:npm/express@4.18.2",
      "type": "library",
      "name": "express",
      "version": "4.18.2",
      "purl": "pkg:npm/express@4.18.2",
      "licenses": [
        {
          "license": {
            "id": "MIT"
          }
        }
      ],
      "hashes": [
        {
          "alg": "SHA-1",
          "content": "5e5ab0aea51e38f629e1fc5c6f2a17e4cb22819c"
        }
      ]
    }
  ]
}
```

**Python SBOM Generation:**
```bash
# Install cyclonedx-bom
pip install cyclonedx-bom

# Generate from requirements.txt
cyclonedx-bom -o sbom.json -f json

# From poetry.lock
poetry export -f requirements.txt | cyclonedx-bom -f json -o sbom.json

# Generate and include vulnerabilities
cyclonedx-bom --include-vulnerability -o sbom.json
```

**Rust SBOM Generation:**
```bash
# Install cyclonedx-cargo
cargo install cyclonedx

# Generate SBOM
cargo cyclonedx --output json > sbom.json

# With specific format
cargo cyclonedx --output xml --spec-version 1.4 > sbom.xml
```

**Go SBOM Generation:**
```bash
# Using trivy (multiformat SBOM tool)
trivy sbom go.mod --format cyclonedx-json > sbom.json

# Or with syft
syft go.mod --output cyclonedx-json > sbom.json
```

#### SPDX (License-Focused)

SPDX is more license-focused than CycloneDX.

**SPDX JSON Example:**
```json
{
  "SPDX Version": "SPDX-2.3",
  "Data License": "CC0-1.0",
  "SBOM Format": "JSON",
  "Name": "myapp",
  "DocumentNamespace": "https://example.com/sbom/myapp-1.0.0",
  "creationInfo": {
    "created": "2024-01-15T10:30:00Z",
    "creators": ["Tool: syft-0.85.0"]
  },
  "packages": [
    {
      "SPDXID": "SPDXRef-Package-myapp",
      "name": "myapp",
      "versionInfo": "1.0.0",
      "filesAnalyzed": false,
      "externalRefs": [
        {
          "referenceCategory": "PACKAGE-MANAGER",
          "referenceType": "purl",
          "referenceLocator": "pkg:npm/myapp@1.0.0"
        }
      ]
    }
  ]
}
```

**Generate with Syft:**
```bash
# Install syft
# Visit: https://github.com/anchore/syft

# Generate SPDX JSON
syft -o spdx-json > sbom.spdx.json

# Generate SPDX XML
syft -o spdx-xml > sbom.spdx.xml

# Generate CycloneDX
syft -o cyclonedx-json > sbom.cyclonedx.json
```

#### CI/CD SBOM Generation

**GitHub Actions:**
```yaml
name: Generate SBOM

on:
  push:
    branches: [ main ]
  release:
    types: [ published ]

jobs:
  sbom:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Generate SBOM
        uses: anchore/sbom-action@v0
        with:
          path: .
          format: cyclonedx-json
          output-file: sbom.cyclonedx.json

      - name: Upload SBOM
        uses: actions/upload-artifact@v3
        with:
          name: sbom
          path: sbom.cyclonedx.json

      - name: Upload to Release
        if: github.event_name == 'release'
        uses: softprops/action-gh-release@v1
        with:
          files: sbom.cyclonedx.json
```

---

## Decision Matrices

### Bundling Strategy Selection

```
Requirement Matrix - Choose Based on Your Needs:

┌─────────────────────────┬───────────┬─────────┬──────────┬────────────┐
│ Requirement             │ Static    │ Dynamic │ Vendored │ Container  │
├─────────────────────────┼───────────┼─────────┼──────────┼────────────┤
│ Portable                │ Excellent │ Poor    │ Good     │ Excellent  │
│ Small Size              │ Poor      │ Good    │ Medium   │ Medium     │
│ Easy Updates            │ Poor      │ Excellent│ Medium   │ Excellent  │
│ Memory Efficient        │ Poor      │ Good    │ Medium   │ Medium     │
│ Simple Setup            │ Good      │ Medium  │ Medium   │ Medium     │
│ Security Control        │ Excellent │ Medium  │ Excellent│ Excellent  │
│ Offline Installation    │ Excellent │ Poor    │ Excellent│ Excellent  │
│ Version Control Friendly│ Good      │ Medium  │ Excellent│ Good       │
│ CI/CD Speed             │ Good      │ Medium  │ Good     │ Medium     │
└─────────────────────────┴───────────┴─────────┴──────────┴────────────┘

Decision Tree:

1. Is this a BINARY (executable)?
   ✓ YES → Continue to Q2
   ✗ NO (library) → Use dynamic linking with lock files

2. Do you need OFFLINE/AIRGAPPED deployment?
   ✓ YES → Use vendoring or static linking
   ✗ NO → Continue to Q3

3. Is SECURITY a top priority?
   ✓ YES → Vendoring + container isolation
   ✗ NO → Continue to Q4

4. What is PRIMARY CONSTRAINT?
   - Size → Dynamic linking
   - Portability → Static linking or containers
   - Simplicity → Docker containers
   - Control → Vendoring
```

### Language-Specific Dependency Tool Selection

```
┌────────┬───────────────┬──────────────┬─────────────┬──────────────┐
│Language│ Recommended   │ Alternative  │ Lock File   │ Key Advantage│
├────────┼───────────────┼──────────────┼─────────────┼──────────────┤
│Python  │ Poetry        │ Pipenv       │ poetry.lock │ Modern,      │
│        │               │ pip+venv     │             │ deterministic│
│        │               │              │             │              │
│Node.js │ npm + pnpm    │ Yarn         │ pnpm-lock   │ Space        │
│        │               │              │ .yaml       │ efficient    │
│        │               │              │             │              │
│Rust    │ Cargo         │ cargo-vet    │ Cargo.lock  │ Built-in     │
│        │               │              │             │ supply chain │
│        │               │              │             │ security     │
│        │               │              │             │              │
│Go      │ go mod        │ go mod       │ go.sum      │ Excellent    │
│        │               │ vendor       │             │ hash checking│
│        │               │              │             │              │
│Java    │ Maven         │ Gradle       │ maven.lock  │ Ecosystem    │
│        │               │              │ (3.9+)      │ standards    │
│        │               │              │             │              │
│.NET    │ nuget         │ paket        │ packages    │ Integration  │
│        │               │              │ .lock       │ with VS      │
│        │               │              │             │              │
│Ruby    │ Bundler       │ -            │ Gemfile.lock│ Standard     │
│        │               │              │             │ practice     │
└────────┴───────────────┴──────────────┴─────────────┴──────────────┘
```

### Conflict Resolution Strategy

```
┌──────────────────┬──────────┬──────────┬──────────┬──────────────┐
│ Conflict Type    │ Platform │ Solution │ Overhead │ Recommended  │
├──────────────────┼──────────┼──────────┼──────────┼──────────────┤
│ Version Mismatch │ Windows  │ SxS      │ Medium   │ Yes          │
│                  │          │ Manifests│          │              │
├──────────────────┼──────────┼──────────┼──────────┼──────────────┤
│ RPATH Issues     │ Linux    │ RPATH    │ Low      │ Yes          │
│ (shared objects) │          │ setting  │          │              │
├──────────────────┼──────────┼──────────┼──────────┼──────────────┤
│ Framework        │ macOS    │ Install  │ Low      │ Yes          │
│ conflicts        │          │ name tool│          │              │
├──────────────────┼──────────┼──────────┼──────────┼──────────────┤
│ Transitive deps  │ All      │ Lock     │ None     │ Always       │
│                  │          │ files    │          │              │
├──────────────────┼──────────┼──────────┼──────────┼──────────────┤
│ Multiple versions│ All      │ Vendoring│ High     │ For critical │
│ of same package  │          │          │          │ components   │
└──────────────────┴──────────┴──────────┴──────────┴──────────────┘
```

### Vulnerability Scanning Tools

```
┌──────────────┬────────────┬──────────────┬────────┬─────────────┐
│ Language     │ Tool       │ Database     │ Format │ Automation  │
├──────────────┼────────────┼──────────────┼────────┼─────────────┤
│ JavaScript   │ npm audit  │ GitHub Adv.  │ JSON   │ Built-in    │
│              │ Dependabot │              │        │ GitHub only │
├──────────────┼────────────┼──────────────┼────────┼─────────────┤
│ Python       │ safety     │ Safety DB    │ Text   │ CLI         │
│              │ pip-audit  │ PyPA         │ JSON   │ Good        │
├──────────────┼────────────┼──────────────┼────────┼─────────────┤
│ Rust         │ cargo-audit│ RustSec      │ JSON   │ Built-in    │
│              │            │ Database     │        │             │
├──────────────┼────────────┼──────────────┼────────┼─────────────┤
│ Go           │ nancy      │ OSS Index    │ JSON   │ CLI/CI       │
│              │ gosec      │ Snyk         │        │              │
├──────────────┼────────────┼──────────────┼────────┼─────────────┤
│ Java         │ Dependabot │ GitHub Adv.  │ JSON   │ GitHub only │
│              │ OWASP DC   │ NVD          │        │ Good        │
├──────────────┼────────────┼──────────────┼────────┼─────────────┤
│ Multi        │ Dependabot │ Multiple     │ JSON   │ Excellent   │
│ language     │ Snyk       │ aggregated   │        │ Integrates  │
│              │ Trivy      │              │        │ with repos  │
└──────────────┴────────────┴──────────────┴────────┴─────────────┘
```

---

## Best Practices Summary

### Universal Principles

1. **Always Commit Lock Files**
   ```
   Commit:  go.sum, package-lock.json, poetry.lock, Cargo.lock, Gemfile.lock
   Use:     These for reproducible builds across machines and time
   Verify:  Hash verification prevents tampering
   ```

2. **Pin Exact Versions in Production**
   ```
   ✓ requests==2.31.0
   ✗ requests>=2.0,<3.0
   ✗ requests^2.31.0 (without lock file)
   ```

3. **Use Virtual Environments / Isolated Spaces**
   ```bash
   # Python
   python -m venv venv

   # Node.js
   npm install (creates node_modules)

   # Go
   go mod init (creates go.mod)

   # .NET
   dotnet (manages via project file)
   ```

4. **Automate Security Scanning**
   ```yaml
   # In every CI/CD pipeline:
   - npm audit (JavaScript)
   - cargo audit (Rust)
   - safety check (Python)
   - nancy (Go)
   - OWASP Dependency-Check (Java)
   ```

5. **Maintain Dependency Inventory (SBOM)**
   ```
   Generate:  Before every release
   Store:     With release artifacts
   Monitor:   Track vulnerabilities over time
   Report:    Supply chain compliance
   ```

6. **Regular Updates**
   ```
   Security patches:     Immediately
   Minor updates:        Weekly
   Major versions:       Quarterly with testing
   Development tools:    Flexible timeline
   ```

### Language-Specific Best Practices

**Python:**
- Use Poetry for new projects
- Commit poetry.lock
- Use tox for multi-version testing
- Enable vulnerability scanning with pip-audit

**Node.js:**
- Use npm with package-lock.json
- Enable Dependabot for automatic PRs
- Run npm audit in CI/CD
- Consider pnpm for monorepos

**Rust:**
- Always commit Cargo.lock for binaries
- Run cargo audit in CI/CD
- Use cargo-vet for significant dependencies
- Document MSRV (Minimum Supported Rust Version)

**Go:**
- Always commit go.mod and go.sum
- Run go mod verify in CI/CD
- Use go mod tidy before commits
- Vendor for offline builds (executables)

**Java:**
- Use Maven or Gradle with lock files
- Run OWASP Dependency-Check
- Use Dependabot for Java projects
- Document compatibility matrix

**.NET:**
- Use nuget with package references
- Commit package metadata
- Use GitHub Dependabot
- Choose FDD for containers, SCD for offline

**General:**
- Document dependency versions in README
- Maintain CHANGELOG for dependency updates
- Automate SBOM generation in CI/CD
- Review security advisories regularly

---

## References and Further Reading

- **Go Modules:** https://go.dev/ref/mod
- **Python Poetry:** https://python-poetry.org/docs/
- **Node.js npm:** https://docs.npmjs.com/
- **Rust Cargo:** https://doc.rust-lang.org/cargo/
- **CycloneDX:** https://cyclonedx.org/
- **SPDX:** https://spdx.dev/
- **RustSec Advisory Database:** https://rustsec.org/
- **.NET Deployment:** https://learn.microsoft.com/en-us/dotnet/core/deploying/

---

**Last Updated:** November 2024
**Version:** 1.0
