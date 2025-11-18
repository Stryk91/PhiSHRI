# Platform Compatibility Guide

A comprehensive guide to developing and deploying applications across Windows, macOS, Linux, iOS, and Android platforms with version matrices, runtime requirements, and cross-compilation strategies.

---

## Table of Contents

1. [Windows](#windows)
2. [macOS](#macos)
3. [Linux](#linux)
4. [Mobile](#mobile)
5. [Cross-Compilation](#cross-compilation)
6. [Testing](#testing)

---

## Windows

### OS Version Support Matrix

| Version | Release | End of Life | Support Status | Notes |
|---------|---------|-------------|----------------|-------|
| Windows 7 | 2009 | Jan 2023 | EOL | No official support; security updates ended |
| Windows 8.1 | 2013 | Jan 2023 | EOL | No official support; security updates ended |
| Windows 10 (22H2) | 2015 | Oct 14, 2025 | Supported | Final feature update; monthly quality updates |
| Windows 11 | 2021 | Current | Supported | New versions released annually with monthly updates |

### Architecture Support

| Architecture | Support | Notes |
|--------------|---------|-------|
| x86 (32-bit) | Varies | Windows 7/8.1/10 support; Windows 11 dropped |
| x64 (64-bit) | Full | All Windows versions; preferred architecture |
| ARM64 | Windows 11+ | Native support on ARM64-based devices |

### Runtime Requirements

#### .NET Framework / .NET Core

```
Windows 7/8.1:
  - .NET Framework 4.7.2+ required
  - .NET Core 3.1 maximum (no .NET 5+)

Windows 10:
  - .NET Framework 4.8+ recommended
  - .NET 5.0+ supported
  - .NET 6.0+ recommended for new projects

Windows 11:
  - .NET 6.0+ recommended
  - .NET 8.0+ for latest features
```

#### Visual C++ Redistributables

```
Key Versions:
  - MSVC 2015 (vc_redist.x64.exe)
  - MSVC 2017 (Visual C++ Redistributable for Visual Studio 2017)
  - MSVC 2019 (Visual C++ Redistributable for Visual Studio 2019)
  - MSVC 2022 (Visual C++ Redistributable for Visual Studio 2022)

Installation:
  - Download from: https://support.microsoft.com/en-us/help/2977003
  - Automatically installed with many applications
  - Can be bundled with application installer
```

### Compatibility Modes

Windows provides compatibility modes for running older applications:

```
Available Modes:
  - Windows 95/98/ME mode
  - Windows XP Service Pack 3
  - Windows 7
  - Windows 8
  - Windows 8.1

Enabling Compatibility Mode:
  1. Right-click executable → Properties
  2. Select "Compatibility" tab
  3. Check "Run this program in compatibility mode for:"
  4. Select target OS version
  5. Apply and run

Troubleshooting:
  - Disable fullscreen optimizations
  - Run in reduced color mode (16-bit)
  - Run at 640 x 480 screen resolution
  - Disable fullscreen exclusive mode
  - Run as administrator
```

---

## macOS

### OS Version Support Matrix

| Version | Codename | Release | ARM64 Support | Minimum Kernel | Status |
|---------|----------|---------|---------------|-----------------|--------|
| 10.13 | High Sierra | 2017 | ❌ Intel only | - | EOL |
| 10.14 | Mojave | 2018 | ❌ Intel only | - | EOL |
| 10.15 | Catalina | 2019 | ❌ Intel only | - | EOL |
| 11 | Big Sur | 2020 | ✅ Yes (M1) | 11.0 | Supported |
| 12 | Monterey | 2021 | ✅ Yes (M-series) | 12.0 | Supported |
| 13 | Ventura | 2022 | ✅ Yes (M-series) | 13.0 | Supported |
| 14 | Sonoma | 2023 | ✅ Yes (M-series) | 14.0 | Supported |
| 15 | Sequoia | 2024 (Sep) | ✅ Yes (M-series) | 15.0 | Current |

### Intel vs Apple Silicon

#### Intel-based Macs (x86_64)
- Supported on macOS 10.7 (Lion) through latest version
- Full native support without translation
- All compiled binaries must be x86_64 architecture
- Performance: Native execution speed

#### Apple Silicon Macs (ARM64)
- First introduced: November 2020 (M1)
- Supported from macOS 11 (Big Sur) onward
- Cannot run macOS 10.15 Catalina or earlier
- Current generations: M1, M2, M3, M4

### Universal Binaries and lipo Command

Universal binaries support both x86_64 and ARM64 architectures in a single executable.

#### Creating Universal Binaries

```bash
# Check current architecture of binary
file /path/to/binary
# Output: Mach-O x86_64 executable ... or Mach-O arm64 executable ...

# Create universal binary from two architecture-specific binaries
lipo -create x86_64_binary arm64_binary -output universal_binary

# Extract specific architecture
lipo universal_binary -thin x86_64 -output x86_64_extracted
lipo universal_binary -thin arm64 -output arm64_extracted

# List architectures in universal binary
lipo -info universal_binary
# Output: Architectures in the binary: x86_64, arm64

# Verify binary content
otool -L universal_binary  # List dynamic library dependencies
otool -hv universal_binary # Show header info
```

#### Building Universal Binaries with Xcode

```bash
# Using Xcode build system
xcodebuild -scheme MyApp \
  -configuration Release \
  -arch x86_64 -arch arm64

# Using clang/gcc
clang -arch x86_64 -arch arm64 -o universal_app main.c

# Using Rust (targets both architectures)
rustup target add aarch64-apple-darwin
rustup target add x86_64-apple-darwin

cargo build --release --target aarch64-apple-darwin
cargo build --release --target x86_64-apple-darwin

lipo -create \
  target/aarch64-apple-darwin/release/app \
  target/x86_64-apple-darwin/release/app \
  -output app_universal
```

### Rosetta 2 Translation

Rosetta 2 enables Intel-compiled applications to run natively on Apple Silicon Macs through dynamic binary translation.

#### Key Characteristics
- **Availability**: macOS 11 (Big Sur) and later on Apple Silicon
- **Performance**: Near-native speed through Just-In-Time translation
- **Scope**: ~90% of Intel applications run successfully
- **Future**: Planned removal with macOS 28 (2027)

#### Installation
```bash
# Rosetta 2 installs automatically on first use of Intel binary
# Manual installation if needed:
softwareupdate --install-rosetta --agree-to-license

# Verify installation
pgrep oahd  # Process for Rosetta translation daemon
```

#### Detection and Handling

```bash
# Check if running under Rosetta 2
sysctl sysctl.proc_translated
# Returns: sysctl.proc_translated = 1 (under Rosetta) or = 0 (native)

# Launch application as native ARM64 (if available)
/usr/bin/arch -arm64 /path/to/app

# Force x86_64 execution via Rosetta 2
/usr/bin/arch -x86_64 /path/to/app

# Build application as native for Apple Silicon
SDKROOT=$(xcrun --sdk macosx --show-sdk-path) \
cargo build --release --target aarch64-apple-darwin
```

---

## Linux

### Distribution Compatibility Matrix

| Distribution | Version | Kernel | glibc | Init System | Status |
|--------------|---------|--------|-------|-------------|--------|
| Ubuntu | 20.04 LTS | 5.4+ | 2.31 | systemd | Supported |
| Ubuntu | 22.04 LTS | 5.15+ | 2.35 | systemd | Supported |
| Ubuntu | 24.04 LTS | 6.8+ | 2.39 | systemd | Current |
| Debian | 11 Bullseye | 5.10+ | 2.31 | systemd | Supported |
| Debian | 12 Bookworm | 6.1+ | 2.36 | systemd | Current |
| CentOS | 7 | 3.10+ | 2.17 | systemd | EOL (June 2024) |
| RHEL | 8 | 4.18+ | 2.28 | systemd | Supported |
| RHEL | 9 | 5.14+ | 2.34 | systemd | Current |
| Fedora | 40 | 6.10+ | 2.39 | systemd | Current |
| Alpine | 3.18+ | 4.14+ | musl 1.2.4+ | OpenRC | Lightweight |
| openSUSE | Leap 15.5 | 6.1+ | 2.37 | systemd | Supported |
| Arch | Rolling | Latest | 2.39+ | systemd | Bleeding edge |

### Kernel Version Requirements

#### Minimum Kernel Support

```
glibc-based systems:
  - Configured with --enable-kernel=3.2 (standard)
  - Minimum kernel: 3.2.0
  - Recommended: 4.4.0 or later for security patches

musl-based systems:
  - Minimum kernel: 2.6.39
  - Recommended: 4.4.0 or later
  - Modern toolchains: 5.15+

Bleeding-edge toolchains (2024):
  - glibc 2.39 with kernel 5.15+
  - musl 1.2.5 with kernel 4.19+
```

#### Checking System Information

```bash
# Check kernel version
uname -r
# Output: 6.1.52-generic or similar

# Check glibc version
ldd --version
# Output: ldd (Ubuntu GLIBC 2.35-0ubuntu3.4) 2.35

# Check if musl-based
ldd /bin/sh 2>&1 | grep -q musl && echo "musl" || echo "glibc"

# Check system distro
cat /etc/os-release
lsb_release -a
```

### Init Systems

#### systemd (Most Common)
```bash
# Check if systemd is active
systemctl --version

# Service management
systemctl start servicename
systemctl stop servicename
systemctl enable servicename    # Start on boot
systemctl status servicename
systemctl daemon-reload         # After modifying unit files

# Service files location
/etc/systemd/system/
/usr/lib/systemd/system/

# Example service file
[Unit]
Description=My Application
After=network.target

[Service]
ExecStart=/usr/local/bin/myapp
Restart=on-failure
RestartSec=5
User=myuser

[Install]
WantedBy=multi-user.target
```

#### OpenRC (Alpine, Gentoo)
```bash
# Service management
rc-service servicename start
rc-service servicename stop
rc-update add servicename          # Start on boot
rc-status

# Service files location
/etc/init.d/

# Example init script
#!/sbin/openrc-run
description="My Application"
command="/usr/local/bin/myapp"
command_background=true
pidfile="/var/run/${RC_SVCNAME}.pid"
```

### glibc vs musl

#### Comparison

| Aspect | glibc | musl |
|--------|-------|------|
| Compatibility | Broad, standard | Focused, lightweight |
| Performance | Full-featured | Minimal overhead |
| Licensing | LGPL | MIT |
| Size | ~2.5 MB | ~600 KB |
| POSIX | Most features | Strict compliance |
| Distributions | Debian, Ubuntu, Red Hat | Alpine, Postman |
| Binary Compatibility | Different from musl | Different from glibc |

#### Checking Libc Implementation

```bash
# For glibc binaries
ldd /bin/ls
# Output: /lib64/ld-linux-x86-64.so.2 (glibc loader)

# For musl binaries
file /bin/busybox
# Output: ELF 64-bit LSB executable ... interpreter /lib/ld-musl-x86_64.so.1

# Check system's libc
head -c 4 /lib/ld-*.so.* | od -c
```

#### Building for Different Libc

```bash
# Using GCC with glibc
gcc -o app main.c

# Using musl-gcc
apk add musl-dev    # Alpine
musl-gcc -o app main.c
# Or with libc flag
gcc -c -fPIC main.c
gcc -o app main.o -lc

# Rust targets
# For glibc (default on most systems)
rustup target add x86_64-unknown-linux-gnu

# For musl (Alpine and other musl systems)
rustup target add x86_64-unknown-linux-musl
cargo build --release --target x86_64-unknown-linux-musl

# Go targets
# For glibc
GOOS=linux GOARCH=amd64 go build -o app

# For musl (statically linked)
CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o app
```

#### Binary Compatibility Notes

- Binaries compiled for glibc **cannot** run on musl-based systems
- Binaries compiled for musl **cannot** run on glibc-based systems
- Use static linking to create portable binaries across libc implementations
- Consider container-based deployment for broader compatibility

---

## Mobile

### iOS Version Support

| iOS Version | Release | Min Device | Status | Notes |
|-------------|---------|-----------|--------|-------|
| iOS 14 | 2020 | iPhone 6s+ | Supported | Minimum for App Store submissions |
| iOS 15 | 2021 | iPhone 6s+ | Supported | Enhanced privacy features |
| iOS 16 | 2022 | iPhone 8+ | Supported | Dynamic Island, Always-On Display |
| iOS 17 | 2023 | iPhone XS+ | Supported | Interactive Widgets, StandBy |
| iOS 18 | 2024 | iPhone XS+ | Current | Apple Intelligence support |

#### Deployment Target Configuration

```swift
// In Xcode project settings or Info.plist

// Minimum iOS version an app can run on
IPHONEOS_DEPLOYMENT_TARGET = 14.0

// In Info.plist
<key>MinimumOSVersion</key>
<string>14.0</string>

// In SwiftUI
@available(iOS 14, *)
struct MyView: View {
    var body: some View {
        Text("iOS 14+")
    }
}
```

### Android API Levels and Versions

| API Level | Version | Release | Min Apps | Target Apps | Notes |
|-----------|---------|---------|----------|-------------|-------|
| 24-25 | 7.0-7.1 | 2016 | Supported | ❌ Deprecated | Nougat |
| 26-27 | 8.0-8.1 | 2017 | Supported | ❌ Deprecated | Oreo |
| 28 | 9.0 | 2018 | Supported | Supported | Pie |
| 29 | 10.0 | 2019 | Supported | Supported | Q |
| 30 | 11 | 2020 | Supported | Supported | R |
| 31-32 | 12-12L | 2021 | Supported | Supported | S |
| 33 | 13 | 2022 | Supported | Supported | T |
| 34 | 14 | 2023 | Supported | Supported | UpsideDownCake |
| 35 | 15 | 2024 | Supported | Current (Aug 2025+) | VanillaIceCream |
| 36 | 16 | 2025 | Planned | Planned | NextOS |

#### Google Play Store Requirements (2024-2025)

```
Minimum Target API Level:
  - Apps new/updated before Aug 31, 2024: API 34 (Android 14)
  - Apps new/updated after Aug 31, 2024: API 35 (Android 15)
  - Apps new/updated after Aug 31, 2025: API 36 (Android 16)

Minimum SDK Version:
  - Recommended: API 24+
  - For critical apps: API 28+

Build Configuration (Gradle):
  android {
      compileSdk 35
      defaultConfig {
          targetSdkVersion 35
          minSdkVersion 24
      }
  }
```

#### Handling Version Differences

```kotlin
// Checking runtime API level
if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
    // Android 13+ code
} else {
    // Fallback for older versions
}

// Requesting permissions (Android 6.0+)
if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
    requestPermissions(arrayOf(Manifest.permission.CAMERA), 1)
} else {
    // Already granted on install for older versions
}

// Using AndroidX for backward compatibility
implementation "androidx.appcompat:appcompat:1.6.1"
implementation "androidx.core:core:1.12.0"
```

---

## Cross-Compilation

### Rust Cross-Compilation

#### Adding Targets

```bash
# List installed targets
rustup target list

# Add target
rustup target add x86_64-unknown-linux-gnu
rustup target add x86_64-unknown-linux-musl
rustup target add aarch64-unknown-linux-gnu
rustup target add x86_64-pc-windows-msvc
rustup target add x86_64-apple-darwin
rustup target add aarch64-apple-darwin

# Complete target list
rustup target list | grep -E "installed|std"
```

#### Building for Different Targets

```bash
# Linux x86_64 (glibc)
cargo build --release --target x86_64-unknown-linux-gnu

# Linux x86_64 (musl, static linking)
cargo build --release --target x86_64-unknown-linux-musl

# Linux ARM64
cargo build --release --target aarch64-unknown-linux-gnu

# Windows from Linux/macOS
cargo build --release --target x86_64-pc-windows-gnu

# macOS Intel
cargo build --release --target x86_64-apple-darwin

# macOS Apple Silicon
cargo build --release --target aarch64-apple-darwin

# Universal macOS binary
cargo build --release --target x86_64-apple-darwin
cargo build --release --target aarch64-apple-darwin
lipo -create \
  target/x86_64-apple-darwin/release/app \
  target/aarch64-apple-darwin/release/app \
  -output app_universal
```

#### Using the 'cross' Tool

The `cross` crate provides "zero setup" cross-compilation using Docker containers.

```bash
# Install cross
cargo install cross

# Build using cross (automatically handles dependencies)
cross build --release --target aarch64-unknown-linux-gnu
cross build --release --target arm-unknown-linux-gnueabihf
cross build --release --target x86_64-unknown-linux-musl

# List supported targets
cross --version
```

#### Supported Rust Targets (2024)

```
Linux:
  - x86_64-unknown-linux-gnu
  - x86_64-unknown-linux-musl
  - i686-unknown-linux-gnu
  - aarch64-unknown-linux-gnu
  - armv7-unknown-linux-gnueabihf
  - armv5te-unknown-linux-gnueabi
  - mips-unknown-linux-gnu
  - mips64-unknown-linux-gnuabi64

macOS/Darwin:
  - x86_64-apple-darwin
  - aarch64-apple-darwin

Windows:
  - x86_64-pc-windows-msvc
  - x86_64-pc-windows-gnu
  - i686-pc-windows-msvc
  - i686-pc-windows-gnu
  - aarch64-pc-windows-msvc

WebAssembly:
  - wasm32-unknown-unknown
  - wasm32-wasi

Mobile:
  - aarch64-linux-android
  - armv7-linux-androideabi
  - aarch64-apple-ios
  - aarch64-apple-ios-sim
```

### Go Cross-Compilation

Go provides excellent built-in cross-compilation support through GOOS and GOARCH environment variables.

#### Finding Supported Platforms

```bash
# List all supported platform combinations
go tool dist list

# Filter for specific OS
go tool dist list | grep linux
go tool dist list | grep windows
go tool dist list | grep darwin

# Check specific version support
go tool dist list -json  # Machine-readable format
```

#### GOOS and GOARCH Values

| GOOS | GOARCH | Description |
|------|--------|-------------|
| linux | amd64 | Linux 64-bit (Intel/AMD) |
| linux | arm64 | Linux 64-bit (ARM/Apple Silicon) |
| linux | 386 | Linux 32-bit |
| linux | arm | Linux ARM (32-bit, v6/v7) |
| linux | mips | Linux MIPS (32-bit) |
| linux | ppc64 | Linux PowerPC (64-bit) |
| windows | amd64 | Windows 64-bit |
| windows | 386 | Windows 32-bit |
| windows | arm64 | Windows ARM64 |
| darwin | amd64 | macOS Intel |
| darwin | arm64 | macOS Apple Silicon |
| android | arm64 | Android ARM64 |
| android | arm | Android ARM (32-bit) |
| ios | arm64 | iOS (ARM64) |
| freebsd | amd64 | FreeBSD 64-bit |
| solaris | amd64 | Solaris/Illumos |

#### Building for Different Platforms

```bash
# Basic cross-compilation
GOOS=linux GOARCH=amd64 go build -o app-linux-amd64

# Linux targets
GOOS=linux GOARCH=amd64 go build -o app-linux-amd64
GOOS=linux GOARCH=arm64 go build -o app-linux-arm64
GOOS=linux GOARCH=arm GOARM=7 go build -o app-linux-armv7

# macOS targets
GOOS=darwin GOARCH=amd64 go build -o app-darwin-amd64
GOOS=darwin GOARCH=arm64 go build -o app-darwin-arm64

# Windows targets
GOOS=windows GOARCH=amd64 go build -o app-windows-amd64.exe
GOOS=windows GOARCH=arm64 go build -o app-windows-arm64.exe

# Android targets
GOOS=android GOARCH=arm64 go build -o libapp.so

# FreeBSD
GOOS=freebsd GOARCH=amd64 go build -o app-freebsd-amd64

# Build with CGo (requires cross-compiler)
CGO_ENABLED=1 GOOS=linux GOARCH=arm64 CC=aarch64-linux-gnu-gcc go build
```

#### Build Script Example

```bash
#!/bin/bash

# Cross-compilation build script
PLATFORMS=(
  "linux/amd64"
  "linux/arm64"
  "windows/amd64"
  "darwin/amd64"
  "darwin/arm64"
)

for platform in "${PLATFORMS[@]}"; do
  IFS='/' read -r GOOS GOARCH <<< "$platform"
  output_name="app-${GOOS}-${GOARCH}"
  [[ "$GOOS" == "windows" ]] && output_name="${output_name}.exe"

  echo "Building for ${GOOS}/${GOARCH}..."
  GOOS=$GOOS GOARCH=$GOARCH go build -o "$output_name" .
done
```

### Docker Multi-Platform Builds

#### Docker buildx Setup

```bash
# Install Docker buildx (comes with Docker Desktop)
docker buildx version

# Create a new builder instance
docker buildx create --name multiarch --driver docker-container
docker buildx use multiarch

# List available builders
docker buildx ls
```

#### Building Multi-Platform Images

```bash
# Simple multi-platform build
docker buildx build \
  --platform linux/amd64,linux/arm64,linux/arm/v7 \
  -t myapp:latest \
  --push \
  .

# Build without pushing (local only)
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  -t myapp:latest \
  --load \
  .

# Load only works with single platform; for multi, use --push
```

#### Multi-Stage Dockerfile with Cross-Compilation

```dockerfile
# Multi-platform Go application
FROM --platform=$BUILDPLATFORM golang:1.22 as builder

ARG TARGETOS
ARG TARGETARCH

WORKDIR /build
COPY . .

RUN GOOS=$TARGETOS GOARCH=$TARGETARCH CGO_ENABLED=0 \
    go build -o app .

# Final image
FROM --platform=$TARGETPLATFORM alpine:latest

COPY --from=builder /build/app /app
ENTRYPOINT ["/app"]
```

#### Rust Multi-Platform Build

```dockerfile
FROM --platform=$BUILDPLATFORM rust:1.75 as builder

ARG TARGETPLATFORM
ARG BUILDPLATFORM

WORKDIR /build
COPY . .

RUN case $TARGETPLATFORM in \
      "linux/amd64") TARGET=x86_64-unknown-linux-gnu ;; \
      "linux/arm64") TARGET=aarch64-unknown-linux-gnu ;; \
      "linux/arm/v7") TARGET=armv7-unknown-linux-gnueabihf ;; \
    esac && \
    rustup target add $TARGET && \
    cargo build --release --target $TARGET

FROM scratch
COPY --from=builder /build/target/*/release/app /app
ENTRYPOINT ["/app"]
```

#### Supported Platform Formats

```
docker buildx build --platform <PLATFORM>,<PLATFORM>,...

Common Platforms:
  - linux/amd64      (x86_64)
  - linux/arm64      (ARM v8 / 64-bit)
  - linux/arm/v7     (ARM v7 / 32-bit)
  - linux/arm/v6     (ARM v6 / 32-bit)
  - linux/ppc64le    (PowerPC)
  - linux/s390x      (IBM System z)
  - windows/amd64    (Windows 64-bit)
  - darwin/amd64     (macOS Intel)
  - darwin/arm64     (macOS Apple Silicon)
```

---

## Testing

### VM Setup and Configuration

#### Local VM Testing with VirtualBox/Hyper-V

```bash
# VirtualBox example - Ubuntu 22.04 VM
VBoxManage createvm --name ubuntu-test --ostype Ubuntu --register
VBoxManage modifyvm ubuntu-test --memory 4096 --cpus 2
VBoxManage createmedium disk --filename ubuntu-test.vdi --size 50000
VBoxManage storageattach ubuntu-test --storagectl SATA \
  --port 0 --device 0 --type hdd --medium ubuntu-test.vdi
VBoxManage startvm ubuntu-test --type headless

# Check VM status
VBoxManage list vms
VBoxManage showvminfo ubuntu-test

# SSH into running VM
ssh user@localhost -p 2222
```

#### Quick Testing Environments

```bash
# Docker for lightweight testing
docker run -it ubuntu:22.04 /bin/bash
docker run -it debian:12 /bin/bash
docker run -it fedora:40 /bin/bash
docker run -it alpine:3.18 /bin/bash

# Podman (rootless alternative)
podman run -it ubuntu:22.04 /bin/bash

# Multipass (lightweight VM manager)
multipass launch ubuntu --name test-vm
multipass exec test-vm -- /bin/bash
multipass delete test-vm
```

### CI/CD Matrix Testing

#### GitHub Actions Matrix Strategy

```yaml
name: Multi-Platform Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ${{ matrix.os }}
    strategy:
      matrix:
        os: [ubuntu-20.04, ubuntu-22.04, windows-2022, macos-12, macos-13]
        go-version: ['1.20', '1.21', '1.22']
        arch: [amd64, arm64]
        exclude:
          # Exclude unsupported combinations
          - os: windows-2022
            arch: arm64
          - os: macos-12
            arch: arm64

    steps:
      - uses: actions/checkout@v4

      - name: Set up Go
        uses: actions/setup-go@v4
        with:
          go-version: ${{ matrix.go-version }}

      - name: Build
        run: |
          GOOS=${{ runner.os == 'Windows' && 'windows' || runner.os == 'macOS' && 'darwin' || 'linux' }} \
          GOARCH=${{ matrix.arch }} \
          go build -v ./...

      - name: Test
        run: go test -v ./...
```

#### Complex Matrix with Build Parameters

```yaml
jobs:
  build:
    runs-on: ${{ matrix.runner }}
    strategy:
      matrix:
        include:
          - runner: ubuntu-latest
            os: linux
            arch: amd64
            libc: glibc

          - runner: ubuntu-latest
            os: linux
            arch: amd64
            libc: musl

          - runner: ubuntu-latest
            os: linux
            arch: arm64
            libc: glibc

          - runner: macos-13
            os: darwin
            arch: amd64

          - runner: macos-14
            os: darwin
            arch: arm64

          - runner: windows-2022
            os: windows
            arch: amd64

      max-parallel: 4

    steps:
      - uses: actions/checkout@v4

      - name: Build for ${{ matrix.os }}/${{ matrix.arch }}
        run: |
          ./scripts/build.sh \
            --os ${{ matrix.os }} \
            --arch ${{ matrix.arch }} \
            --libc ${{ matrix.libc }}

      - name: Upload artifacts
        uses: actions/upload-artifact@v3
        with:
          name: build-${{ matrix.os }}-${{ matrix.arch }}
          path: dist/
```

#### GitLab CI Matrix Example

```yaml
test:
  image: $IMAGE
  parallel:
    matrix:
      - IMAGE: ubuntu:20.04
        GO_VERSION: "1.20"
      - IMAGE: ubuntu:22.04
        GO_VERSION: "1.21"
      - IMAGE: debian:12
        GO_VERSION: "1.22"
      - IMAGE: alpine:3.18
        GO_VERSION: "1.22"

  before_script:
    - apt-get update && apt-get install -y golang-${GO_VERSION}

  script:
    - go version
    - go build -v ./...
    - go test -v ./...
```

### Cloud Testing Services

#### BrowserStack

Best for: Web applications, cross-browser testing, mobile web

```
Features:
  - 20,000+ real devices and browsers
  - Real-time testing, automated testing, visual testing
  - Geolocation testing
  - Network throttling
  - Screenshot comparison

Pricing:
  - Live Testing: $39/month
  - Virtual Cloud (automated): $149/month
  - Enterprise plans available

Integration Example (Selenium):
  from selenium import webdriver
  from selenium.webdriver.common.by import By

  capabilities = {
    'browserName': 'Chrome',
    'browserVersion': 'latest',
    'platformName': 'Windows',
    'bstack:options': {
      'projectName': 'MyProject',
      'buildName': 'Build 1',
      'sessionName': 'Test Session'
    }
  }

  driver = webdriver.Remote(
    command_executor='https://USERNAME:ACCESS_KEY@hub.browserstack.com/wd/hub',
    desired_capabilities=capabilities
  )
```

#### Sauce Labs

Best for: Comprehensive testing, detailed analytics, CI/CD integration

```
Features:
  - 7,500+ real devices
  - 1,700+ emulators and simulators
  - Video recording of tests
  - Detailed logs and screenshots
  - Native and hybrid app testing
  - Extensive CI/CD integrations

Pricing:
  - Concurrent tests: $299/month per concurrent test
  - Unlimited users and testing minutes
  - Volume discounts available

Supported Platforms (2024):
  - Web: Chrome, Firefox, Safari, Edge
  - Mobile: iOS 12-18, Android 7-15
  - Desktop: Windows, macOS
```

#### LambdaTest

Best for: Budget-friendly, extensive browser support, automation testing

```
Features:
  - 3,000+ browsers and devices
  - Real-time testing
  - Automated screenshot testing
  - Network simulation
  - Responsive design testing

Pricing:
  - Pay-as-you-go: Starting at $7/month
  - Unlimited plans: $49/month

Quick Start:
  capabilities = {
    'platform': 'Windows 10',
    'browserName': 'Chrome',
    'version': 'latest',
    'name': 'Test Case 1',
    'build': 'Build 1',
    'network': True,
    'video': True,
    'console': True
  }
```

#### AWS Device Farm

Best for: Native mobile app testing, high volume, AWS integration

```
Features:
  - 2,000+ physical devices
  - Automated and interactive testing
  - Appium, Calabash, and UI Automator support
  - Video recording and logs
  - Parallel test execution

Pricing:
  - $0.17 per device-minute
  - Compute-based billing
  - Free tier available (250 device-minutes/month)

AWS CLI Example:
  aws devicefarm create-project --name "MyApp"
  aws devicefarm create-device-pool --project-arn arn:...
  aws devicefarm schedule-run \
    --project-arn arn:... \
    --app-arn arn:...
```

#### Testing Strategy Recommendations

```
Small Project (MVP):
  ✓ Use free tiers (BrowserStack, Device Farm)
  ✓ Local VM testing for critical platforms
  ✓ GitHub Actions CI/CD with 2-3 key matrix builds
  ✓ Cost: $0-100/month

Growing Project:
  ✓ Cloud testing service for web (Sauce Labs or BrowserStack)
  ✓ GitHub Actions for CI/CD matrix (multiple OS/versions)
  ✓ Device Farm for mobile app testing
  ✓ Cost: $100-500/month

Enterprise:
  ✓ Multiple cloud testing services
  ✓ Dedicated test infrastructure
  ✓ Local device lab
  ✓ Custom automation frameworks
  ✓ Cost: $500-5000+/month
```

---

## Best Practices Summary

1. **Version Targeting**: Always test with minimum and maximum supported versions
2. **Architecture Coverage**: Test on both Intel and ARM when relevant
3. **Continuous Integration**: Implement matrix testing for all major platform combinations
4. **Dependency Management**: Document runtime requirements and provide installation guides
5. **Static Linking**: Use static compilation when cross-platform compatibility is critical
6. **Container Deployment**: Docker multi-platform builds for maximum portability
7. **Compatibility Modes**: Test fallback code paths for older OS versions
8. **Documentation**: Maintain platform-specific guides for users and developers

---

## References

- [Microsoft Windows Lifecycle Fact Sheet](https://learn.microsoft.com/en-us/lifecycle/faq/windows)
- [Apple macOS Release Notes](https://developer.apple.com/documentation/macos-release-notes)
- [Linux Kernel Documentation](https://www.kernel.org/doc/html/latest/)
- [Google Play Target API Levels](https://developer.android.com/google-play/requirements/target-api-level)
- [Rust Platform Support](https://doc.rust-lang.org/nightly/rustc/platform-support.html)
- [Go Operating Systems](https://golang.org/doc/install/source#environment)
- [Docker Buildx Documentation](https://docs.docker.com/build/architecture/)

---

**Document Version**: 1.0
**Last Updated**: November 2024
**Status**: Current for 2024 OS versions
