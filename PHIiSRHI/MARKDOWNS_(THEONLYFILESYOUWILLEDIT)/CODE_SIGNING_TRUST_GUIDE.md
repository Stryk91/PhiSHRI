# CODE SIGNING & TRUST GUIDE

A comprehensive guide to code signing and trust mechanisms across Windows, macOS, Linux, and cross-platform frameworks. Includes current 2024-2025 pricing, complete workflows, and command examples.

---

## Table of Contents

1. [Windows Code Signing](#windows-code-signing)
2. [macOS Code Signing](#macos-code-signing)
3. [Linux Code Signing](#linux-code-signing)
4. [Certificate Management](#certificate-management)
5. [Cross-Platform Frameworks](#cross-platform-frameworks)
6. [CI/CD Integration](#cicd-integration)
7. [Security Best Practices](#security-best-practices)

---

## WINDOWS CODE SIGNING

### Overview

Windows code signing uses **Microsoft Authenticode** technology to digitally sign executables, installers, drivers, and other binaries. Authenticode verifies the publisher, ensures code integrity, and builds trust through SmartScreen reputation.

### Authenticode Technology

**What is Authenticode?**

- Microsoft technology that identifies software publishers
- Verifies software hasn't changed since signing
- Uses cryptographic techniques for verification
- Creates digital signatures embedded in PE (Portable Executable) files
- Supports EV (Extended Validation) and OV (Organization Validation) certificates

**Key Requirements:**

- **RSA Keys Only**: ECC keys are NOT accepted for Windows code signing
- **Minimum Key Size**: 2048-bit RSA (higher recommended for security)
- **Timestamp**: Required for signature to remain valid after certificate expiration
- **Code Signing Certificate**: From CA recognized by Microsoft (DigiCert, Sectigo, Entrust, GlobalSign)

### EV vs Standard Certificates

#### Extended Validation (EV) Code Signing

**Characteristics:**
- Highest level of authentication and trust
- Requires extended identity verification of organization
- More expensive ($279-$500/year)
- Private key must be stored on hardware token (HSM/FIPS 140 Level 2+)
- Cannot be exported

**2024 SmartScreen Update:**
- Microsoft changed policy in March 2024
- EV certificates NO LONGER provide instant SmartScreen reputation
- Still requires builds to establish reputation through organic downloads
- Must submit MSI/EXE to Microsoft for evaluation

**Pricing (2024):**
- Sectigo EV: $279-$298/year
- DigiCert EV: $499.99/year
- Entrust EV: Similar range

#### Organization Validation (OV) Code Signing

**Characteristics:**
- Standard code signing certificate
- Requires business identity verification (less stringent than EV)
- More affordable ($211-$370/year)
- Can be stored on token or software (post-June 2023: hardware required)
- Faster to obtain

**SmartScreen Behavior:**
- Must build reputation organically through downloads
- No instant trust even with OV certificate
- Timeframe varies (10 days to several weeks)
- User downloads/installs count toward reputation

**Pricing (2024):**
- Sectigo Standard: $211-$226/year
- DigiCert Standard: $369.99/year
- Additional costs (as of June 2023):
  - HSM Token: $50-150
  - Shipping: $40-90
  - Annual maintenance varies by CA

### SmartScreen Reputation

**Understanding SmartScreen:**

Windows SmartScreen (Windows Defender SmartScreen) displays warnings for unknown publishers. Reputation is built through:

1. **Certificate Trust**: Valid, recognized code signing certificate
2. **Download Count**: Organic downloads establish legitimacy
3. **User Behavior**: Few complaints/reports improve reputation
4. **Time**: Older binaries with good track record trusted faster

**Building Reputation:**

```
Timeline Examples:
- First release: ~1 month before trusted
- Second release: ~10 days
- Subsequent releases: Variable (10 days to weeks)
```

**Reputation Transfer:**
- When renewing certificate: Reputation does NOT automatically transfer
- New certificate = starting fresh reputation building
- Mitigation: Maintain certificate for max validity period
- Use same Subject/CN in renewed certificate when possible

**Submitting for Evaluation:**

While EV no longer provides instant trust, you can submit binaries:

```bash
# Submit to Microsoft for reputation evaluation
# Via Windows Defender portal: https://www.microsoft.com/en-us/wdsi/submission/
# Provide:
# - Executable file (EXE/MSI)
# - Valid code signing certificate
# - Organization details
```

### Timestamp Servers

**Importance:**

Timestamps allow signatures to remain valid AFTER certificate expiration. Without timestamping, the signature becomes invalid when the certificate expires.

**How Timestamping Works:**

1. Signing tool communicates with timestamp server
2. Server returns RFC 3161 timestamp
3. Timestamp embedded in signature
4. Signature remains valid even after certificate expires

**Common Timestamp Servers:**

```
DigiCert:
- http://timestamp.digicert.com
- https://timestamp.digicert.com

Sectigo:
- http://timestamp.sectigo.com

GlobalSign:
- http://timestamp.globalsign.com

Entrust:
- http://timestamp.entrust.net

Microsoft:
- http://timestamp.microsoft.com (legacy, deprecated)
```

**Timestamp Best Practices:**

- Always use HTTPS endpoints (more secure)
- Include `-tr` (RFC 3161) flag for modern timestamping
- Use `-fd sha256` to specify hash algorithm
- Specify `-td sha256` for timestamp digest algorithm

### Complete Windows Signing Workflow

#### Prerequisites

```bash
# 1. Obtain code signing certificate from CA
#    - Submit CSR (Certificate Signing Request)
#    - Complete identity verification
#    - Receive certificate + private key

# 2. Install Windows SDK (includes signtool.exe)
#    Download: https://developer.microsoft.com/en-us/windows/downloads/windows-sdk/
#    Default path: C:\Program Files (x86)\Windows Kits\10\bin\[version]\x64\

# 3. Import certificate to Windows Certificate Store
#    - Double-click .pfx file
#    - Enter password
#    - Select "Current User" store
#    - Certificate imported to Personal store
```

#### Signing an Executable

**Method 1: Automatic Certificate Selection**

```bash
signtool sign ^
  /tr http://timestamp.digicert.com ^
  /td sha256 ^
  /fd sha256 ^
  /a "C:\path\to\file.exe"
```

**Method 2: Specific Certificate by Thumbprint**

```bash
# First, find certificate thumbprint
certutil -store my

# Then sign with specific certificate
signtool sign ^
  /sha1 YOUR_CERTIFICATE_THUMBPRINT ^
  /tr http://timestamp.digicert.com ^
  /td sha256 ^
  /fd sha256 ^
  /as "C:\path\to\file.exe"
```

**Method 3: Certificate by Subject Name**

```bash
signtool sign ^
  /n "Subject Name" ^
  /tr http://timestamp.digicert.com ^
  /td sha256 ^
  /fd sha256 ^
  "C:\path\to\file.exe"
```

**Method 4: HSM/Token Authentication**

```bash
# For hardware token or cloud HSM
signtool sign ^
  /sha1 CERTIFICATE_THUMBPRINT ^
  /csp "PKCS#11 Provider Name" ^
  /k slot_id ^
  /tr http://timestamp.digicert.com ^
  /td sha256 ^
  /fd sha256 ^
  "C:\path\to\file.exe"
```

#### Signing MSI Installers

```bash
signtool sign ^
  /tr http://timestamp.digicert.com ^
  /td sha256 ^
  /fd sha256 ^
  /a "C:\path\to\installer.msi"
```

#### Batch Signing Multiple Files

```batch
REM Sign all EXE files in directory
for %%F in (*.exe) do (
  signtool sign ^
    /tr http://timestamp.digicert.com ^
    /td sha256 ^
    /fd sha256 ^
    /a "%%F"
)
```

#### Verifying Signatures

```bash
# Verify signature is valid
signtool verify /pa "C:\path\to\file.exe"

# Verbose output showing certificate details
signtool verify /pa /v "C:\path\to\file.exe"

# Check timestamp validity
signtool verify /pa /tw "C:\path\to\file.exe"
```

#### Azure Trusted Signing (2025)

**New Option for Individual Developers**

Microsoft's Azure Trusted Signing is the simplest option for many developers:

```bash
# Prerequisites
# - Azure account
# - Install trusted-signing-cli

# Configuration
az account set --subscription YOUR_SUBSCRIPTION_ID

# Sign executable
azure-code-sign ^
  --endpoint https://wus2.codesigning.azure.net/ ^
  --identity-type SharedTokenCacheCred ^
  --account MyCodeSigningAccount ^
  --certificate-profile MyProfile ^
  --file "C:\path\to\file.exe"
```

**Advantages:**
- $10/month subscription
- Simplest setup (no HSM needed)
- Cloud-based (no local key storage)
- Automatic timestamp handling
- Full audit trail

---

## MACOS CODE SIGNING

### Overview

macOS code signing ensures app integrity and enables distribution outside App Store. Notarization is required for all macOS applications on modern systems.

### Developer ID Certificates

**Obtaining Certificates**

1. Enroll in Apple Developer Program ($99/year for individuals)
2. Generate Developer ID certificate in Xcode or Apple Developer Portal
3. Install certificate in Keychain
4. Use for signing all macOS apps

**Certificate Types:**

- **Developer ID Application**: Sign apps for distribution
- **Developer ID Installer**: Sign PKG installers
- **Developer ID Service**: Sign privileged service tools

### The codesign Command

**Basic Signing**

```bash
# Sign an application bundle
codesign --sign "Developer ID Application: Your Name (XXXXX)" \
  --options runtime \
  --entitlements entitlements.plist \
  /path/to/Application.app

# Sign with timestamp
codesign --sign "Developer ID Application: Your Name (XXXXX)" \
  --timestamp \
  --options runtime \
  --entitlements entitlements.plist \
  /path/to/Application.app
```

**Listing Available Certificates**

```bash
# Show all Developer ID certificates in Keychain
security find-identity -v -p codesigning

# Output example:
# 1) XXXXXXXXXXXXXXXXXXXXXXXXXXXXX "Developer ID Application: Your Name (ABC123DEF456)"
```

**Signing by Certificate ID**

```bash
codesign --sign ABC123DEF456 \
  --options runtime \
  --entitlements entitlements.plist \
  /path/to/Application.app
```

**Signing Nested Code**

```bash
# Applications often contain nested frameworks/libraries
# Must sign from innermost to outermost

# Example structure:
# MyApp.app/
#   └─ Contents/Frameworks/MyFramework.framework

# Correct order:
codesign --sign "Developer ID Application: Your Name (XXXXX)" \
  --options runtime \
  MyApp.app/Contents/Frameworks/MyFramework.framework

codesign --sign "Developer ID Application: Your Name (XXXXX)" \
  --options runtime \
  --entitlements entitlements.plist \
  MyApp.app
```

**Verifying Signatures**

```bash
# Check if app is signed
codesign -v /path/to/Application.app

# Detailed verification
codesign -v -v /path/to/Application.app

# Check signature and entitlements
spctl -a -v /path/to/Application.app

# Display entitlements
codesign -d --entitlements :- /path/to/Application.app
```

### Hardened Runtime

**What is Hardened Runtime?**

macOS security feature that:
- Prevents unsigned code injection
- Disables certain runtime modifications
- Required for notarization
- Enforces code signing validation

**Enabling Hardened Runtime**

In Xcode build settings:
```
Build Settings > Code Signing > Enable Hardened Runtime = Yes
```

Or via `codesign`:
```bash
codesign --sign "Developer ID Application: Your Name (XXXXX)" \
  --options runtime \
  /path/to/Application.app
```

### Entitlements

**What are Entitlements?**

Entitlements declare capabilities your app needs:
- Camera/microphone access
- File system access
- Network access
- Keychain access
- etc.

**Entitlements.plist Example**

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <!-- Hardened runtime entitlements -->
  <key>com.apple.security.cs.allow-unsigned-executable-memory</key>
  <false/>

  <!-- File system access -->
  <key>com.apple.security.files.user-selected.read-only</key>
  <true/>
  <key>com.apple.security.files.user-selected.read-write</key>
  <true/>

  <!-- Network access -->
  <key>com.apple.security.network.client</key>
  <true/>
  <key>com.apple.security.network.server</key>
  <true/>

  <!-- Keychain access -->
  <key>keychain-access-groups</key>
  <array>
    <string>$(AppIdentifierPrefix)com.example.myapp</string>
  </array>
</dict>
</plist>
```

**Common Entitlements:**

```xml
<!-- Disable code injection protection -->
<key>com.apple.security.cs.allow-unsigned-executable-memory</key>
<true/>

<!-- Allow JIT compilation -->
<key>com.apple.security.cs.allow-jit</key>
<true/>

<!-- File access dialogs -->
<key>com.apple.security.files.user-selected.read-only</key>
<true/>

<!-- Camera/Microphone -->
<key>com.apple.security.device.camera</key>
<true/>
<key>com.apple.security.device.microphone</key>
<true/>

<!-- Debugging/Development -->
<key>com.apple.security.get-task-allow</key>
<true/>
```

### Notarization with xcrun notarytool

**What is Notarization?**

Apple's automated security scanning process that:
- Scans app for known malware
- Checks for unsafe code patterns
- Required for distribution (Gatekeeper)
- Free for registered Apple developers
- Returns notarization ticket that must be stapled

**Prerequisites**

```bash
# 1. Apple Developer account
# 2. App signed with hardened runtime and entitlements
# 3. App-specific password or notarization API key

# Create app-specific password:
# https://appleid.apple.com/account/manage
# Generate "App-specific password" for Xcode
```

**Notarization Command: Basic**

```bash
# Submit app for notarization
xcrun notarytool submit /path/to/application.dmg \
  --apple-id your@email.com \
  --team-id XXXXXXXXXX \
  --password "app-specific-password" \
  --wait
```

**Notarization Command: Using Keychain Profile**

```bash
# Store credentials in Keychain profile (recommended for CI/CD)
xcrun notarytool store-credentials "AppleNotarization" \
  --apple-id your@email.com \
  --team-id XXXXXXXXXX \
  --password "app-specific-password"

# Use stored profile
xcrun notarytool submit /path/to/application.dmg \
  --keychain-profile "AppleNotarization" \
  --wait
```

**Notarization Command: Using API Key**

```bash
# Generate App Store Connect API key
# https://appstoreconnect.apple.com/access/api/

xcrun notarytool submit /path/to/application.dmg \
  --key /path/to/AuthKey_XXX.p8 \
  --key-id XXX \
  --issuer-id XXX \
  --wait
```

**Stapling Notarization Ticket**

```bash
# After successful notarization, staple ticket to app
xcrun stapler staple /path/to/Application.app

# For DMG files (requires mounted DMG)
xcrun stapler staple /path/to/application.dmg
```

**Complete Notarization Workflow**

```bash
#!/bin/bash

APP_NAME="MyApp"
APP_PATH="/path/to/$APP_NAME.app"
DMG_PATH="/path/to/$APP_NAME.dmg"

# Step 1: Sign application
codesign --sign "Developer ID Application: Your Name (XXXXX)" \
  --options runtime \
  --entitlements entitlements.plist \
  --timestamp \
  "$APP_PATH"

# Step 2: Create DMG
hdiutil create -volname "$APP_NAME" \
  -srcfolder "$APP_PATH" \
  -ov -format UDZO \
  "$DMG_PATH"

# Step 3: Submit for notarization
NOTARIZATION_ID=$(xcrun notarytool submit "$DMG_PATH" \
  --keychain-profile "AppleNotarization" \
  --output-format json | jq -r '.id')

echo "Notarization ID: $NOTARIZATION_ID"

# Step 4: Wait for completion (or check status)
xcrun notarytool wait "$NOTARIZATION_ID" \
  --keychain-profile "AppleNotarization"

# Step 5: Staple ticket
xcrun stapler staple "$DMG_PATH"

# Step 6: Verify
spctl -a -v "$DMG_PATH"
```

**Checking Notarization Status**

```bash
# Check status of notarization
xcrun notarytool info NOTARIZATION_ID \
  --keychain-profile "AppleNotarization"

# Wait for completion
xcrun notarytool wait NOTARIZATION_ID \
  --keychain-profile "AppleNotarization"
```

### Signing PKG Installers

```bash
# Sign PKG file
productsign --sign "Developer ID Installer: Your Name (XXXXX)" \
  unsigned.pkg \
  signed.pkg

# Verify signature
pkgutil --check-signature signed.pkg

# Notarize PKG
xcrun notarytool submit signed.pkg \
  --keychain-profile "AppleNotarization" \
  --wait

# Staple notarization
xcrun stapler staple signed.pkg
```

---

## LINUX CODE SIGNING

### GPG Repository Signing

**Overview**

Linux packages (DEB, RPM) are signed using GNU Privacy Guard (GPG) at package and repository level.

**Generating GPG Keys**

```bash
# Generate new signing key
gpg --full-generate-key

# Choose options:
# - Key type: RSA (default)
# - Key size: 4096
# - Expiration: 2 years recommended
# - Name, email, comment

# List keys
gpg --list-keys
gpg --list-secret-keys

# Export public key for distribution
gpg --armor --export KEYID > public-key.asc
```

**Signing DEB Packages**

```bash
# Sign DEB using dpkg-sig
dpkg-sig -k KEYID -s builder package.deb

# Verify DEB signature
dpkg-sig --verify package.deb
```

**Creating Signed APT Repository**

```bash
#!/bin/bash

# Generate repository metadata
cd /path/to/repo

# Create Release file
apt-ftparchive release . > Release

# Sign Release file with GPG
gpg --default-key KEYID -abs -o Release.gpg Release

# InRelease (inline signature)
gpg --default-key KEYID -abs --clearsign -o InRelease Release
```

**Repository Configuration (sources.list)**

```bash
# Add repository with signature verification
# /etc/apt/sources.list.d/myrepo.list

deb [signed-by=/usr/share/keyrings/myrepo-archive-keyring.gpg] \
  https://myrepo.example.com/debian/ bullseye main

# Install public key
sudo mkdir -p /usr/share/keyrings
sudo wget https://myrepo.example.com/public-key.gpg \
  -O /usr/share/keyrings/myrepo-archive-keyring.gpg
```

**Signing RPM Packages**

```bash
# Build and sign RPM
rpmbuild -ba --sign specfile.spec

# Sign existing RPM
rpm --addsign package.rpm

# Verify RPM signature
rpm --checksig package.rpm

# Import signing key
rpm --import public-key.asc
```

### AppImage Signing

**Creating Signed AppImage**

```bash
# Build AppImage with signature
appimagetool -s ask MyApp.AppDir MyApp-x86_64.AppImage

# Or with automated key
appimagetool -s auto MyApp.AppDir MyApp-x86_64.AppImage

# Specify key ID
appimagetool -s auto -k "KEY_ID" MyApp.AppDir MyApp-x86_64.AppImage
```

**Verifying AppImage Signatures**

```bash
# Verify AppImage signature
appimagetool --check MyApp-x86_64.AppImage

# Manual GPG verification (if .sig file provided)
gpg --verify MyApp-x86_64.AppImage.sig MyApp-x86_64.AppImage
```

**Distribution with Signature**

```bash
# Create detached signature
gpg --detach-sign --armor MyApp-x86_64.AppImage
# Creates: MyApp-x86_64.AppImage.asc

# Users can verify:
gpg --verify MyApp-x86_64.AppImage.asc MyApp-x86_64.AppImage

# Or verify checksum
sha256sum MyApp-x86_64.AppImage > MyApp-x86_64.AppImage.sha256
```

### Flatpak Signing

**Building Signed Flatpak**

```bash
#!/bin/bash

# Prerequisites:
# - GPG key generated
# - Flatpak manifest ready

FLATPAK_ID="com.example.myapp"
KEY_ID="your-gpg-key-id"
BUILD_DIR="build"

# Initialize repository
ostree init --mode=bare-user-only --repo=repo

# Build and sign Flatpak
flatpak-builder \
  --repo=repo \
  --gpg-sign="$KEY_ID" \
  --force-clean \
  "$BUILD_DIR" \
  "$FLATPAK_ID.yml"
```

**Flatpak Repository Setup**

```bash
# Create repository
mkdir -p flatpak-repo
ostree init --mode=bare-user-only --repo=flatpak-repo

# Build app into repository
flatpak-builder \
  --repo=flatpak-repo \
  --gpg-sign=KEYID \
  --force-clean \
  build-dir \
  com.example.myapp.yml

# Create summary file (signed)
flatpak build-commit-from \
  flatpak-repo \
  --gpg-sign=KEYID

# Generate metadata files
flatpak build-metadata flatpak-repo \
  --gpg-sign=KEYID
```

**Installing from Signed Repository**

```bash
# Add remote repository
flatpak remote-add --gpg-import=public-key.gpg \
  myrepo \
  https://myrepo.example.com/flatpak/

# Install application
flatpak install myrepo com.example.myapp

# Verify signatures are checked
flatpak remote-info myrepo com.example.myapp
```

---

## CERTIFICATE MANAGEMENT

### CSR Generation

**Certificate Signing Request (CSR)** is a request sent to Certificate Authority to issue a code signing certificate.

**Windows: Using Certutil**

```bash
# Generate private key and CSR
certreq -new csr-template.inf request.csr

# Template file (csr-template.inf):
[NewRequest]
Subject="CN=Your Name,O=Your Company,C=US"
KeySpec=1
KeyLength=2048
Exportable=FALSE
MachineKeySet=FALSE
ProviderName="Microsoft Enhanced Cryptographic Provider v1.0"
RequestType=PKCS10
HashAlgorithm=sha256
```

**Windows: Using MMC (Microsoft Management Console)**

```
1. Open Run (Win+R) → mmc
2. File → Add/Remove Snap-in → Certificates → Add
3. Select "My user account"
4. Expand Personal → Right-click → All Tasks → Request New Certificate
5. Select "Code Signing" certificate type
6. Complete enrollment
7. View certificate in Personal store
```

**Windows: Using DigiCert Utility**

```bash
# Download DigiCertUtil.exe from DigiCert
# Double-click executable
# Select Code Signing (shield)
# Click "Create CSR"
# Follow wizard

# CSR saved to: C:\Users\[User]\DigiCert\[Cert].csr
```

**Windows: Using OpenSSL**

```bash
# Generate private key (2048-bit RSA)
openssl genrsa -out private-key.pem 2048

# Generate CSR
openssl req -new \
  -key private-key.pem \
  -out request.csr \
  -subj "/C=US/ST=State/L=City/O=Company/CN=Your Name"

# Verify CSR
openssl req -text -noout -verify -in request.csr
```

**macOS: Using Keychain Access**

```bash
# Open Keychain Access
open /Applications/Utilities/Keychain\ Access.app

# Menu: Keychain Access → Certificate Assistant →
#       Request a Certificate from a Certificate Authority

# Or command line:
security request-certificate \
  -k ~/Library/Keychains/login.keychain \
  -s /CN=Your\ Name/O=Your\ Company/C=US \
  -e your@email.com \
  -f request.csr
```

**macOS: Using OpenSSL**

```bash
# Generate private key
openssl genrsa -out private-key.pem 2048

# Generate CSR
openssl req -new \
  -key private-key.pem \
  -out request.csr \
  -subj "/C=US/ST=State/L=City/O=Company/CN=Your Name"
```

**Linux: Using OpenSSL**

```bash
# Generate private key
openssl genrsa -out private-key.pem 2048

# Generate CSR
openssl req -new \
  -key private-key.pem \
  -out request.csr \
  -subj "/C=US/ST=State/L=City/O=Company/CN=Your Name"

# Verify CSR
openssl req -text -noout -verify -in request.csr
```

### Certificate Costs (2024 Pricing)

**Standard (OV) Code Signing Certificates**

| Provider | Annual Cost | Additional Costs | Notes |
|----------|-------------|------------------|-------|
| Sectigo | $211-226 | HSM Token: $50-150, Shipping: $40-90 | Lowest cost option |
| DigiCert | $369.99 | HSM Token: $50-150, Shipping: $40-90 | Most trusted |
| Entrust | $250-300 | HSM Token: $50-150, Shipping: $40-90 | High assurance |
| GlobalSign | $300-350 | HSM Token: $50-150, Shipping: $40-90 | Established CA |
| SSL.com | $180-220 | HSM Token: Variable, Shipping: $40-90 | Affordable |

**Extended Validation (EV) Code Signing Certificates**

| Provider | Annual Cost | Additional Costs | Notes |
|----------|-------------|------------------|-------|
| Sectigo | $279-298 | HSM Token: Required, Shipping: $40-90 | Most affordable EV |
| DigiCert | $499.99 | HSM Token: Required, Shipping: $40-90 | Premium |
| Entrust | $350-400 | HSM Token: Required, Shipping: $40-90 | High assurance |

**Azure Trusted Signing (2025)**

| Service | Cost | Benefits |
|---------|------|----------|
| Azure Trusted Signing | $10/month | Simplest setup, no HSM, cloud-based, auto-timestamp |

**Key Cost Factors (June 2023 Onward)**

- **Mandatory HSM**: All certificates require FIPS 140 Level 2+ hardware storage
- **Token Fees**: $50-150 per hardware token/USB key
- **Shipping**: $40-90 for physical token delivery
- **Annual Renewal**: Full price renewal (no discounts for renewal)
- **Multi-year Discounts**: Available from most CAs (buy 2+ years)

### HSM vs Software Storage

**Hardware Security Module (HSM)**

**Advantages:**
- Private key never leaves hardware device
- Tamper-resistant (physical tampering destroys key)
- FIPS 140 Level 2+ certified
- Meets CA/B Forum requirements (mandatory since June 2023)
- Suitable for enterprise/high-security environments
- Can store multiple keys on one device

**Disadvantages:**
- Higher cost ($50-500+ per device)
- Requires physical hardware or cloud service
- Setup complexity
- Performance overhead for signing operations
- Device availability dependency

**Options:**
- Physical USB hardware token ($50-150)
- Enterprise HSM appliance ($10k+)
- Cloud-based HSM (Google HSM, AWS CloudHSM, Azure Key Vault)
- CA-hosted cloud signing service

**Software Storage (Historical)**

**Status:** No longer supported as of June 1, 2023

Previously:
- Private key stored in PKCS#12 (.pfx) file
- More convenient but less secure
- Vulnerable to key extraction if system compromised

**Cloud Signing Services (Alternative)**

```bash
# Google Cloud HSM
# Store key slot on GCP for ~$1-2/month per slot
gcloud kms keys create code-signing-key \
  --location us-west1 \
  --keyring code-signing \
  --purpose asymmetric-signing

# Azure Key Vault
# Cloud-based key storage with signing
az keyvault key create \
  --vault-name MyKeyVault \
  --name code-signing-key \
  --kty RSA \
  --size 2048 \
  --ops sign verify

# AWS CloudHSM
# Enterprise-grade hardware security module
# Starting ~$5000/month
```

### CI/CD Signing Integration

**GitHub Actions: Windows Code Signing**

```yaml
name: Sign Windows App

on: [push, workflow_dispatch]

jobs:
  sign:
    runs-on: windows-latest
    steps:
      - uses: actions/checkout@v3

      - name: Decode certificate
        shell: pwsh
        run: |
          $pfxBytes = [Convert]::FromBase64String("${{ secrets.CODE_SIGNING_CERT }}")
          [IO.File]::WriteAllBytes("cert.pfx", $pfxBytes)

      - name: Sign executable
        shell: cmd
        run: |
          signtool sign ^
            /f cert.pfx ^
            /p "${{ secrets.CERT_PASSWORD }}" ^
            /tr http://timestamp.digicert.com ^
            /td sha256 ^
            /fd sha256 ^
            build\output.exe

      - name: Clean up certificate
        shell: pwsh
        run: Remove-Item -Force cert.pfx

      - name: Upload signed artifact
        uses: actions/upload-artifact@v3
        with:
          name: signed-executable
          path: build\output.exe
```

**GitHub Actions: macOS Notarization**

```yaml
name: Notarize macOS App

on: [push, workflow_dispatch]

jobs:
  notarize:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v3

      - name: Build application
        run: |
          xcodebuild -scheme MyApp -configuration Release -archivePath build/MyApp.xcarchive
          xcodebuild -exportArchive -archivePath build/MyApp.xcarchive \
            -exportPath build/release \
            -exportOptionsPlist export-options.plist

      - name: Create DMG
        run: |
          hdiutil create -volname MyApp \
            -srcfolder build/release/MyApp.app \
            -ov -format UDZO \
            build/MyApp.dmg

      - name: Setup notarization credentials
        run: |
          echo "${{ secrets.NOTARIZATION_PASSWORD }}" | \
          xcrun notarytool store-credentials "AppleNotarization" \
            --apple-id "${{ secrets.APPLE_ID }}" \
            --team-id "${{ secrets.TEAM_ID }}" \
            --password @-

      - name: Submit for notarization
        run: |
          xcrun notarytool submit build/MyApp.dmg \
            --keychain-profile "AppleNotarization" \
            --wait

      - name: Staple notarization
        run: xcrun stapler staple build/MyApp.dmg

      - name: Verify
        run: spctl -a -v build/MyApp.dmg

      - name: Upload
        uses: actions/upload-artifact@v3
        with:
          name: notarized-app
          path: build/MyApp.dmg
```

**GitHub Actions: Linux GPG Signing**

```yaml
name: Sign Linux Package

on: [push, workflow_dispatch]

jobs:
  sign:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Import GPG key
        run: |
          mkdir -p ~/.gnupg
          echo "${{ secrets.GPG_PRIVATE_KEY }}" | gpg --batch --import
          echo "${{ secrets.GPG_PASSPHRASE }}" > /tmp/gpg-pass

      - name: Build application
        run: cargo build --release

      - name: Create AppImage
        run: appimagetool -s auto build MyApp-x86_64.AppImage

      - name: Sign with GPG
        run: |
          gpg --batch --yes \
            --passphrase-fd 3 \
            --detach-sign \
            --armor \
            MyApp-x86_64.AppImage \
            3</tmp/gpg-pass

      - name: Cleanup sensitive files
        run: |
          shred -vfz -n 3 /tmp/gpg-pass

      - name: Upload artifacts
        uses: actions/upload-artifact@v3
        with:
          name: signed-appimage
          path: |
            MyApp-x86_64.AppImage
            MyApp-x86_64.AppImage.asc
```

**GitLab CI: Code Signing**

```yaml
sign-windows:
  stage: sign
  tags:
    - windows
  script:
    - |
      $pfxBytes = [Convert]::FromBase64String($env:CODE_SIGNING_CERT)
      [IO.File]::WriteAllBytes("cert.pfx", $pfxBytes)
    - |
      signtool sign /f cert.pfx /p $env:CERT_PASSWORD `
        /tr http://timestamp.digicert.com /td sha256 /fd sha256 `
        build\output.exe
    - Remove-Item -Force cert.pfx
  artifacts:
    paths:
      - build\output.exe
  only:
    - tags

sign-macos:
  stage: sign
  tags:
    - macos
  script:
    - xcrun notarytool store-credentials "AppleNotarization"
        --apple-id "$APPLE_ID"
        --team-id "$TEAM_ID"
        --password "$NOTARIZATION_PASSWORD"
    - xcrun notarytool submit build/MyApp.dmg
        --keychain-profile "AppleNotarization"
        --wait
    - xcrun stapler staple build/MyApp.dmg
  artifacts:
    paths:
      - build/MyApp.dmg
  only:
    - tags
```

---

## CROSS-PLATFORM FRAMEWORKS

### Electron Code Signing

**Overview**

Electron apps require platform-specific signing for distribution:
- Windows: Authenticode signing
- macOS: Developer ID + notarization
- Linux: GPG signing (optional)

**Package.json Configuration**

```json
{
  "name": "my-electron-app",
  "version": "1.0.0",
  "build": {
    "appId": "com.example.my-app",
    "win": {
      "certificateFile": "path/to/cert.pfx",
      "certificatePassword": "${env.WIN_SIGNING_PASSWORD}",
      "signingHashAlgorithms": ["sha256"],
      "sign": "./customSign.js",
      "target": ["nsis", "portable"]
    },
    "mac": {
      "hardenedRuntime": true,
      "entitlements": "build/entitlements.mac.plist",
      "identity": "Developer ID Application: Your Name (XXXXX)",
      "notarize": {
        "teamId": "${env.APPLE_TEAM_ID}",
        "appleId": "${env.APPLE_ID}",
        "appleIdPassword": "${env.APPLE_PASSWORD}",
        "keychain": "AppleNotarization"
      }
    },
    "linux": {
      "target": ["AppImage"],
      "category": "Utility"
    }
  }
}
```

**electron-builder Configuration**

```javascript
// electron-builder.config.js
const config = {
  appId: 'com.example.my-app',
  files: [
    'dist/**/*',
    'node_modules/**/*',
    'package.json'
  ],

  // Windows
  win: {
    certificateFile: process.env.WIN_SIGNING_CERT_PATH,
    certificatePassword: process.env.WIN_SIGNING_PASSWORD,
    signingHashAlgorithms: ['sha256'],
    target: ['nsis', 'portable']
  },

  // macOS
  mac: {
    hardenedRuntime: true,
    entitlements: 'build/entitlements.mac.plist',
    identity: process.env.MAC_SIGNING_IDENTITY,
    notarize: {
      teamId: process.env.APPLE_TEAM_ID,
      appleId: process.env.APPLE_ID,
      appleIdPassword: process.env.APPLE_PASSWORD,
      keychain: 'AppleNotarization'
    }
  },

  // Linux
  linux: {
    target: ['AppImage']
  }
};

module.exports = config;
```

**Building and Signing**

```bash
# Windows signing
npm run build -- --win --publish never \
  -e WIN_SIGNING_PASSWORD=your_password

# macOS signing and notarization
npm run build -- --mac --publish never \
  -e APPLE_ID=your@email.com \
  -e APPLE_PASSWORD=app-specific-password \
  -e APPLE_TEAM_ID=XXXXX

# Linux AppImage
npm run build -- --linux --publish never

# All platforms
npm run build -- -mwl --publish never
```

**Custom Signing Script (customSign.js)**

```javascript
// For advanced signing scenarios
const { signAsync } = require('electron-builder');

exports.default = async function (configuration) {
  const { execSync } = require('child_process');

  // Custom Windows signing
  if (process.platform === 'win32') {
    const certPath = process.env.WIN_SIGNING_CERT_PATH;
    const password = process.env.WIN_SIGNING_PASSWORD;

    execSync(
      `signtool sign /f "${certPath}" /p "${password}" ` +
      `/tr http://timestamp.digicert.com /td sha256 /fd sha256 ` +
      `"${configuration.path}"`,
      { stdio: 'inherit' }
    );
  }
};
```

### Tauri Code Signing

**Overview**

Tauri uses platform-specific signing with configuration in tauri.conf.json.

**Tauri Configuration**

```json
{
  "build": {
    "beforeBuildCommand": "",
    "beforeDevCommand": "",
    "devPath": "../src",
    "frontendDist": "../src",
    "features": []
  },
  "bundle": {
    "active": true,
    "targets": ["deb", "rpm", "app", "msi", "dmg"],
    "identifier": "com.example.myapp",
    "icon": [
      "icons/32x32.png",
      "icons/128x128.png",
      "icons/128x128@2x.png",
      "icons/icon.icns",
      "icons/icon.ico"
    ]
  },
  "windows": [
    {
      "label": "main",
      "title": "My Tauri App",
      "width": 800,
      "height": 600
    }
  ]
}
```

**Windows Signing (Windows Platform)**

```json
{
  "windows": {
    "certificatePath": null,
    "certificatePassword": null,
    "digestAlgorithm": "sha256",
    "signingCommand": null,
    "certificateThumbprint": null,
    "timeServer": "http://timestamp.digicert.com"
  }
}
```

Build command with certificate:

```bash
# Set environment variables
export TAURI_WINDOWS_SIGNING_CERT="path/to/cert.pfx"
export TAURI_WINDOWS_SIGNING_PASSWORD="password"

# Build Windows MSI
cargo tauri build --target msi
```

**macOS Signing**

```bash
# Prerequisites
export APPLE_SIGNING_IDENTITY="Developer ID Application: Your Name (XXXXX)"
export APPLE_ID_PASSWORD="app-specific-password"
export APPLE_ID="your@email.com"
export APPLE_TEAM_ID="XXXXX"

# Build and sign
cargo tauri build --target macos
```

**Linux AppImage Signing**

```bash
# Set GPG key
export GPG_KEY_ID="your-gpg-key-id"

# Build AppImage
cargo tauri build --target appimage
```

**Cross-Platform Build Script**

```bash
#!/bin/bash
# build-all.sh - Sign app for all platforms

set -e

echo "Building for Windows..."
TAURI_WINDOWS_SIGNING_PASSWORD=$WINDOWS_CERT_PASSWORD \
TAURI_WINDOWS_SIGNING_CERT="$(pwd)/certs/windows.pfx" \
cargo tauri build --target msi

echo "Building for macOS..."
APPLE_SIGNING_IDENTITY="Developer ID Application: Your Name" \
APPLE_ID="your@email.com" \
APPLE_TEAM_ID="XXXXX" \
cargo tauri build --target macos

echo "Building for Linux..."
cargo tauri build --target appimage

echo "All builds complete!"
ls -la src-tauri/target/release/bundle/
```

**GitHub Actions: Tauri Multi-Platform Signing**

```yaml
name: Tauri Build and Sign

on:
  push:
    tags: ['v*']

jobs:
  build:
    strategy:
      matrix:
        include:
          - os: windows-latest
            target: msi
          - os: macos-latest
            target: macos
          - os: ubuntu-latest
            target: appimage

    runs-on: ${{ matrix.os }}

    steps:
      - uses: actions/checkout@v3

      - name: Setup Rust
        uses: dtolnay/rust-toolchain@stable

      - name: Setup Node
        uses: actions/setup-node@v3
        with:
          node-version: '18'

      - name: Install dependencies
        run: npm ci

      - name: Build Tauri app
        env:
          TAURI_WINDOWS_SIGNING_CERT: ${{ secrets.WIN_CERT_BASE64 }}
          TAURI_WINDOWS_SIGNING_PASSWORD: ${{ secrets.WIN_CERT_PASSWORD }}
          APPLE_SIGNING_IDENTITY: ${{ secrets.MAC_SIGNING_IDENTITY }}
          APPLE_ID: ${{ secrets.APPLE_ID }}
          APPLE_ID_PASSWORD: ${{ secrets.APPLE_PASSWORD }}
          APPLE_TEAM_ID: ${{ secrets.APPLE_TEAM_ID }}
          GPG_KEY_ID: ${{ secrets.GPG_KEY_ID }}
        run: |
          if [ "$RUNNER_OS" = "Windows" ]; then
            $pfxBytes = [Convert]::FromBase64String("$env:TAURI_WINDOWS_SIGNING_CERT")
            [IO.File]::WriteAllBytes("certs/windows.pfx", $pfxBytes)
            $env:TAURI_WINDOWS_SIGNING_CERT = "certs/windows.pfx"
          fi
          cargo tauri build --target ${{ matrix.target }}

      - name: Upload artifacts
        uses: actions/upload-artifact@v3
        with:
          name: ${{ matrix.os }}-${{ matrix.target }}
          path: src-tauri/target/release/bundle/
```

---

## SECURITY BEST PRACTICES

### Key Management

1. **Secure Storage**
   - Store private keys in HSM or hardware tokens
   - Never commit keys to version control
   - Use environment variables or secret managers in CI/CD
   - Encrypt keys in transit (HTTPS, VPN)

2. **Access Control**
   - Limit signing authority to essential personnel
   - Use role-based access for CI/CD signing
   - Maintain audit logs of all signing operations
   - Rotate signing certificates annually

3. **Key Lifecycle**
   - Generate new keys following CA requirements
   - Maintain separate keys for testing and production
   - Document certificate expiration dates
   - Plan certificate renewal 30+ days in advance

### Certificate Best Practices

1. **Always Timestamp**
   - Include RFC 3161 timestamps in all signatures
   - Use HTTPS timestamp servers
   - Signature remains valid after certificate expiration

2. **Hardware Storage**
   - Use FIPS 140 Level 2+ certified hardware
   - Physical tokens provide better security than software
   - Cloud HSM balances security and convenience

3. **Renewal Strategy**
   - Plan renewal before expiration (30 days minimum)
   - Maintain continuity for reputation building
   - Use same certificate identity when renewing

4. **Verification**
   - Always verify signatures before distribution
   - Test signatures in target environment
   - Check timestamp and certificate validity

### Reputation Building

1. **Windows SmartScreen**
   - No instant reputation even with EV certificates
   - Build reputation through organic downloads
   - Maintain consistent identity across releases
   - Submit applications for evaluation if needed

2. **macOS Gatekeeper**
   - Notarization required for all distributions
   - Hardened runtime + entitlements mandatory
   - Staple notarization tickets before distribution
   - Monitor notarization status in CI/CD

3. **Linux Trust**
   - Use well-known repositories for distribution
   - Maintain consistent GPG signing identity
   - Publish public keys prominently
   - Include signature verification documentation

### Audit and Compliance

1. **Logging**
   - Log all signing operations with timestamps
   - Record signer identity and certificate used
   - Maintain audit trail for 1+ years
   - Monitor for unauthorized access attempts

2. **Documentation**
   - Maintain certificate inventory
   - Document signing procedures and workflows
   - Keep CSR and approval records
   - Track certificate lifecycle events

3. **Incident Response**
   - Plan response to key compromise
   - Establish certificate revocation process
   - Communicate security incidents to users
   - Maintain incident response logs

---

## Summary Table: Quick Reference

| Platform | Tool | Certificate | Storage | Timestamp |
|----------|------|-------------|---------|-----------|
| **Windows** | signtool | OV or EV | HSM/Token | RFC 3161 |
| **macOS** | codesign | Developer ID | Keychain | Built-in |
| **Linux DEB** | dpkg-sig | GPG Key | File | N/A |
| **Linux RPM** | rpmsign | GPG Key | File | N/A |
| **AppImage** | appimagetool | GPG Key | File | N/A |
| **Flatpak** | flatpak-builder | GPG Key | File | N/A |

---

## Additional Resources

**Official Documentation:**
- [Microsoft Authenticode](https://learn.microsoft.com/en-us/windows-hardware/drivers/install/authenticode)
- [Apple Code Signing](https://developer.apple.com/documentation/xcode/code-signing)
- [Tauri Code Signing](https://v2.tauri.app/distribute/sign/)
- [Electron Signing](https://www.electronjs.org/docs/tutorial/code-signing)

**Certificate Authorities:**
- [DigiCert Code Signing](https://www.digicert.com/dc/code-signing/)
- [Sectigo Code Signing](https://sectigo.com/code-signing)
- [GlobalSign Code Signing](https://www.globalsign.com/en/code-signing)
- [SSL.com Code Signing](https://www.ssl.com/code-signing)

**CI/CD Integration:**
- [GitHub Actions](https://docs.github.com/en/actions)
- [GitLab CI](https://docs.gitlab.com/ee/ci/)
- [Azure DevOps](https://docs.microsoft.com/en-us/azure/devops)

---

**Last Updated:** November 2024
**Pricing Information:** Based on 2024-2025 market data
**Content Accuracy:** Verified from official documentation and current best practices
