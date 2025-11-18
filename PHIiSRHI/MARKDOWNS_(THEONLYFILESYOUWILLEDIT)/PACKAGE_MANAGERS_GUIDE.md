# Comprehensive Package Managers Guide (2024-2025)

A complete reference guide covering system package managers, language-specific package managers, and developer tools with installation commands, package creation templates, publishing processes, and detailed comparisons.

---

## Table of Contents

1. [System Package Managers](#system-package-managers)
   - [Windows](#windows)
   - [macOS](#macos)
   - [Linux](#linux)
   - [Cross-Platform](#cross-platform)
2. [Language Package Managers](#language-package-managers)
   - [JavaScript](#javascript)
   - [Python](#python)
   - [Rust](#rust)
   - [Go](#go)
   - [Java](#java)
   - [C#/.NET](#cnet)
   - [C++](#c)
3. [Developer Tools](#developer-tools)
4. [Comparison Tables](#comparison-tables)

---

# System Package Managers

## Windows

### Winget (Windows Package Manager)

**Overview:** The official Windows package manager that ships with Windows 11. Pre-installed, free, and open-source.

#### Installation
```bash
# Winget comes pre-installed with Windows 11
# For Windows 10, install from Microsoft Store or GitHub
winget --version  # Check if installed

# Update winget
winget upgrade winget
```

#### Package Creation

Create a manifest file (`.yaml`) for your package:

**File Structure:**
```
manifests/
  c/
    companyname/
      appname/
        1.0.0/
          companyname.appname.yaml
          companyname.appname.locale.en-US.yaml
          companyname.appname.installer.yaml
```

**Example Manifest (companyname.appname.yaml):**
```yaml
PackageIdentifier: companyname.appname
PackageVersion: 1.0.0
PackageName: Application Name
Publisher: Company Name
PackageUrl: https://github.com/company/app
License: MIT
ShortDescription: Brief description of the app
Description: Longer description of what the app does
```

**Installer Manifest (companyname.appname.installer.yaml):**
```yaml
PackageIdentifier: companyname.appname
PackageVersion: 1.0.0
InstallerType: msi
Installers:
  - Architecture: x64
    InstallerUrl: https://example.com/app-1.0.0-x64.msi
    InstallerSha256: HASH_HERE
    InstallerLocale: en-US
    Scope: machine
```

#### Publishing Process
1. Fork the community repository: https://github.com/microsoft/winget-pkgs
2. Create a new branch with your package
3. Add manifest files in the correct directory structure
4. Submit a Pull Request
5. Microsoft reviews and validates (typically 1-2 weeks)
6. Upon approval, the package is available via `winget install`

#### Installation Commands
```bash
# Install a package
winget install appname

# Search for packages
winget search appname

# Upgrade installed packages
winget upgrade appname

# List installed packages
winget list

# Remove a package
winget uninstall appname
```

---

### Chocolatey

**Overview:** Mature Windows package manager with 10,000+ packages. Some features require premium subscription.

#### Installation
```bash
# Run PowerShell as Administrator
Set-ExecutionPolicy Bypass -Scope Process -Force
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# Verify installation
choco --version
```

#### Package Creation

**Directory Structure:**
```
mypackage/
  mypackage.nuspec
  tools/
    chocolateyinstall.ps1
    chocolateyuninstall.ps1
    LICENSE.txt
```

**Example .nuspec (mypackage.nuspec):**
```xml
<?xml version="1.0" encoding="utf-8"?>
<package xmlns="http://schemas.microsoft.com/packaging/2015/06/nuspec.xsd">
  <metadata>
    <id>mypackage</id>
    <version>1.0.0</version>
    <title>My Package</title>
    <authors>Your Name</authors>
    <owners>Your Name</owners>
    <description>Package description here</description>
    <projectUrl>https://github.com/yourname/mypackage</projectUrl>
    <licenseUrl>https://github.com/yourname/mypackage/blob/main/LICENSE</licenseUrl>
    <requireLicenseAcceptance>false</requireLicenseAcceptance>
    <tags>application tool</tags>
    <dependencies>
      <dependency id="vcredist2015" version="1.0" />
    </dependencies>
  </metadata>
  <files>
    <file src="tools\**" target="tools" />
  </files>
</package>
```

**Install Script (tools/chocolateyinstall.ps1):**
```powershell
$ErrorActionPreference = 'Stop'

$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$url64 = 'https://example.com/myapp-1.0.0-x64.exe'
$checksum64 = 'YOUR_SHA256_HASH'

$packageArgs = @{
  packageName    = $env:ChocolateyPackageName
  fileType       = 'EXE'
  url64bit       = $url64
  checksum64     = $checksum64
  checksumType64 = 'sha256'
  silentArgs     = '/S'
  validExitCodes = @(0)
}

Install-ChocolateyPackage @packageArgs
```

#### Publishing Process
1. Create Chocolatey account at https://chocolatey.org/
2. Create `.nuspec` and install/uninstall scripts
3. Pack the package: `choco pack mypackage.nuspec`
4. Push to Chocolatey: `choco push mypackage.1.0.0.nupkg --api-key YOUR_API_KEY`
5. Package is immediately available: `choco install mypackage`

#### Common Commands
```bash
# Install package
choco install appname

# Search for packages
choco search appname

# Upgrade all packages
choco upgrade all

# List installed packages
choco list

# Remove a package
choco uninstall appname
```

---

### Scoop

**Overview:** User-friendly Windows package manager focusing on portable, command-line applications. Installs per-user, no admin required.

#### Installation
```powershell
# Run PowerShell (not necessarily as Admin)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
iwr -useb get.scoop.sh | iex

# Verify
scoop --version
```

#### Package Creation

**Directory Structure:**
```
scoop-bucket/
  bucket/
    myapp.json
```

**Example Manifest (bucket/myapp.json):**
```json
{
  "version": "1.0.0",
  "description": "Description of your app",
  "homepage": "https://example.com/myapp",
  "license": "MIT",
  "url": "https://example.com/myapp-1.0.0.zip",
  "hash": "sha256:YOUR_SHA256_HASH",
  "bin": "myapp.exe",
  "shortcuts": [
    [
      "MyApp.exe",
      "My Application"
    ]
  ],
  "checkver": {
    "github": "yourname/myapp"
  },
  "autoupdate": {
    "url": "https://github.com/yourname/myapp/releases/download/v$version/myapp-$version.zip",
    "hash": {
      "url": "$url.sha256"
    }
  }
}
```

#### Publishing Process
1. Create a GitHub repository for your bucket (e.g., `scoop-mybucket`)
2. Create `bucket/` directory with JSON manifests
3. Users add your bucket: `scoop bucket add mybucket https://github.com/yourname/scoop-mybucket`
4. Install from your bucket: `scoop install mybucket/myapp`
5. For official registry, submit to https://github.com/ScoopInstaller/Main

#### Common Commands
```bash
# Install package
scoop install appname

# Search for packages
scoop search appname

# Update all apps
scoop update *

# List installed apps
scoop list

# Remove app
scoop uninstall appname

# Add custom bucket
scoop bucket add mybucket https://github.com/user/scoop-mybucket
```

---

## macOS

### Homebrew

**Overview:** The most popular macOS package manager. Uses formulas written in Ruby. Works on both Intel and Apple Silicon.

#### Installation
```bash
# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Verify
brew --version

# Add to PATH (for Apple Silicon/M1+)
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
```

#### Package Creation (Formula)

**Directory Structure:**
```
homebrew-myformulas/
  Formula/
    myapp.rb
```

**Example Formula (Formula/myapp.rb):**
```ruby
class Myapp < Formula
  desc "Description of your app"
  homepage "https://example.com/myapp"
  url "https://github.com/yourname/myapp/archive/v1.0.0.tar.gz"
  sha256 "YOUR_SHA256_HASH"
  license "MIT"

  depends_on "python@3.11"
  depends_on "openssl"

  def install
    system "make", "install", "PREFIX=#{prefix}"
    bin.install "myapp"
  end

  test do
    system "#{bin}/myapp", "--version"
  end
end
```

#### Publishing Process
1. Create a GitHub repository (e.g., `homebrew-myapp`)
2. Add formula in `Formula/` directory
3. Users tap your repository: `brew tap yourname/myapp`
4. Install: `brew install myapp`
5. For official Homebrew core, submit PR to https://github.com/Homebrew/homebrew-core

#### Common Commands
```bash
# Install formula
brew install appname

# Search for formulas
brew search appname

# List installed packages
brew list

# Update Homebrew
brew update

# Upgrade packages
brew upgrade appname

# Remove package
brew uninstall appname

# Add custom tap (repository)
brew tap yourname/formulas https://github.com/yourname/homebrew-formulas
```

---

### MacPorts

**Overview:** Comprehensive package manager with strong legacy support. Uses Tcl-based Portfiles. Better for older macOS versions.

#### Installation
```bash
# Download .pkg from https://www.macports.org/install.php
sudo installer -pkg MacPorts-VERSION.pkg -target /

# Verify
sudo port -v

# Update to latest version
sudo port selfupdate
```

#### Package Creation (Portfile)

**Directory Structure:**
```
myport/
  Portfile
  files/
    patch-Makefile.diff
```

**Example Portfile:**
```tcl
# -*- coding: utf-8; mode: tcl; tab-width: 4; indent-tabs-mode: nil; c-basic-offset: 4 -*- vim:fenc=utf-8:ft=tcl:et:sw=4:ts=4:sts=4

PortSystem          1.0

name                myapp
version             1.0.0
revision            0
categories          category subcategory
platforms           darwin
maintainers         {your.email@example.com:yourname}
license             MIT

description         Short description
long_description    Longer description of what the port does

homepage            https://example.com/myapp
master_sites        github:yourname:myapp:v${version}
distname            myapp-${version}
checksums           sha256 YOUR_SHA256_HASH

depends_build-append port:pkgconfig
depends_lib-append  port:openssl \
                    port:zlib

use_configure       yes

configure.args-append --prefix=${prefix}

build.target        all

destroot.target     install
destroot.destdir    DESTDIR=${destroot}

test.run            yes
test.target         test
```

#### Publishing Process
1. Create Portfile and required support files
2. Submit via SourceForge or GitHub to MacPorts project
3. Port maintainers review and integrate
4. Once accepted, available via `sudo port install myapp`

#### Common Commands
```bash
# Search for ports
sudo port search appname

# Install port
sudo port install appname

# List installed ports
sudo port installed

# Upgrade all ports
sudo port upgrade outdated

# Remove port
sudo port uninstall appname

# Update port tree
sudo port selfupdate
```

---

## Linux

### APT (Debian/Ubuntu)

**Overview:** Standard package manager for Debian-based distributions. Uses .deb packages.

#### Installation
```bash
# APT comes pre-installed on Debian/Ubuntu/Linux Mint

# Update package lists
sudo apt update

# Upgrade packages
sudo apt upgrade
```

#### Package Creation (.deb)

**Directory Structure:**
```
myapp/
  debian/
    changelog
    compat
    control
    copyright
    install
    rules
  src/
    main.py
```

**debian/control:**
```
Source: myapp
Section: utils
Priority: optional
Maintainer: Your Name <email@example.com>
Build-Depends: debhelper (>= 11)
Standards-Version: 4.6.0

Package: myapp
Architecture: all
Depends: python3, ${misc:Depends}
Description: Short description
 Long description of what the
 application does on multiple lines.
```

**debian/rules:**
```makefile
#!/usr/bin/make -f
%:
	dh $@

override_dh_auto_build:
	mkdir -p $(CURDIR)/debian/myapp/usr/bin
	cp src/main.py $(CURDIR)/debian/myapp/usr/bin/myapp

override_dh_auto_install:
	chmod +x $(CURDIR)/debian/myapp/usr/bin/myapp
```

#### Building a .deb Package
```bash
# Using debuild
debuild -us -uc

# Or using dpkg-buildpackage
dpkg-buildpackage -us -uc

# Resulting .deb file will be in parent directory
```

#### Publishing Process
1. Build the .deb package
2. For unofficial distribution: host on personal repository or upload to PPA
3. For Ubuntu PPA: https://launchpad.net/~/+add-ppa
4. For official Debian: join Debian, create account, submit package via mentors.debian.net

#### Common Commands
```bash
# Search for packages
apt search appname

# Install package
sudo apt install appname

# Update package lists
sudo apt update

# Upgrade all packages
sudo apt upgrade

# Remove package
sudo apt remove appname

# List installed packages
apt list --installed
```

---

### DNF (Fedora/RHEL/CentOS)

**Overview:** Modern replacement for YUM. RPM-based package manager.

#### Installation
```bash
# DNF comes pre-installed on Fedora/RHEL

# Verify
dnf --version

# Update
sudo dnf upgrade
```

#### Package Creation (.rpm)

**Directory Structure:**
```
SOURCES/
  myapp-1.0.0.tar.gz
SPECS/
  myapp.spec
```

**Example SPEC file (myapp.spec):**
```spec
Name:           myapp
Version:        1.0.0
Release:        1%{?dist}
Summary:        Short description
License:        MIT

URL:            https://example.com/myapp
Source0:        %{url}/archive/v%{version}.tar.gz
BuildRequires:  gcc make

%description
Longer description of the application.

%prep
%setup -q

%build
make

%install
make install DESTDIR=%{buildroot}

%files
%license LICENSE
%doc README.md
%{_bindir}/myapp

%changelog
* Mon Jan 15 2024 Your Name <email@example.com> - 1.0.0-1
- Initial release
```

#### Building an RPM
```bash
# Using rpmbuild
rpmbuild -ba myapp.spec

# Or using fedpkg
fedpkg build --scratch

# Resulting RPM in ~/rpmbuild/RPMS/
```

#### Publishing Process
1. Build the .rpm package
2. For Fedora: submit to Fedora Project via Bodhi
3. For RHEL: submit to RHEL AppStream or use custom repository
4. Host on Copr (Community Packages) for easy distribution

#### Common Commands
```bash
# Search for packages
dnf search appname

# Install package
sudo dnf install appname

# Upgrade all packages
sudo dnf upgrade

# Remove package
sudo dnf remove appname

# List installed packages
dnf list installed

# Enable repository
sudo dnf config-manager --add-repo URL
```

---

### Pacman (Arch Linux)

**Overview:** Fast, lightweight package manager. PKGBUILD scripts define packages.

#### Installation
```bash
# Pacman comes pre-installed on Arch Linux

# Initialize pacman
sudo pacman-key --init

# Update all packages
sudo pacman -Syu
```

#### Package Creation (PKGBUILD)

**Directory Structure:**
```
myapp/
  PKGBUILD
```

**Example PKGBUILD:**
```bash
# Maintainer: Your Name <email@example.com>
pkgname=myapp
pkgver=1.0.0
pkgrel=1
pkgdesc="Short description"
arch=('x86_64')
url="https://example.com/myapp"
license=('MIT')
depends=('glibc')
makedepends=('git' 'gcc')
source=("${url}/archive/v${pkgver}.tar.gz")
sha256sums=('YOUR_SHA256_HASH')

build() {
  cd "${pkgname}-${pkgver}"
  make
}

package() {
  cd "${pkgname}-${pkgver}"
  make DESTDIR="${pkgdir}" install
}
```

#### Building an Arch Package
```bash
# In directory with PKGBUILD
makepkg -si

# -s: install dependencies
# -i: install built package
```

#### Publishing Process
1. Create PKGBUILD and build package
2. For AUR (Arch User Repository): https://aur.archlinux.org/
3. Create AUR account and SSH key
4. `git clone ssh://aur@aur.archlinux.org/myapp.git`
5. Add PKGBUILD and .SRCINFO
6. Push to AUR

#### Common Commands
```bash
# Search for packages
pacman -Ss appname

# Install package
sudo pacman -S appname

# Upgrade all packages
sudo pacman -Syu

# Remove package
sudo pacman -R appname

# List installed packages
pacman -Q

# Install from AUR
yay -S appname
# (requires yay AUR helper)
```

---

### Zypper (openSUSE)

**Overview:** Package manager for openSUSE and SUSE Linux. RPM-based with excellent conflict resolution.

#### Installation
```bash
# Zypper comes pre-installed on openSUSE

# Verify
zypper --version

# Refresh package database
sudo zypper refresh
```

#### Package Creation (.rpm via Zypper)

**Uses the same .spec format as DNF/RPM** (see DNF section above)

#### Building an RPM for openSUSE
```bash
# Using osc (openSUSE command-line tool)
osc checkout home:youruser/myapp
cd home:youruser/myapp
# Edit spec file and sources
osc add SOURCES/*
osc commit

# Or build locally
rpmbuild -ba myapp.spec
```

#### Publishing Process
1. Build .rpm package
2. For official openSUSE: submit via Open Build Service (OBS)
3. Create account at https://build.opensuse.org/
4. Create project and package
5. Upload .spec and sources
6. OBS builds across all supported architectures

#### Common Commands
```bash
# Search for packages
zypper search appname

# Install package
sudo zypper install appname

# Update all packages
sudo zypper update

# Remove package
sudo zypper remove appname

# List repositories
zypper repos

# Add repository
sudo zypper addrepo URL alias
```

---

## Cross-Platform

### Nix

**Overview:** Functional package manager with strong reproducibility guarantees. Works on Linux and macOS.

#### Installation

**Linux:**
```bash
# Download installation script
curl -L https://nixos.org/nix/install | sh

# Reload shell
. ~/.nix-profile/etc/profile.d/nix.sh
```

**macOS:**
```bash
# Install Nix
curl -L https://nixos.org/nix/install | sh

# For Apple Silicon
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

#### Package Creation (Nix Expression)

**Example derivation.nix:**
```nix
{ pkgs ? import <nixpkgs> {} }:

pkgs.stdenv.mkDerivation rec {
  pname = "myapp";
  version = "1.0.0";

  src = pkgs.fetchFromGitHub {
    owner = "yourname";
    repo = "myapp";
    rev = "v${version}";
    sha256 = "sha256-YOUR_HASH_HERE==";
  };

  buildInputs = with pkgs; [ gcc python3 ];
  propagatedBuildInputs = with pkgs; [ zlib openssl ];

  configurePhase = ''
    ./configure --prefix=$out
  '';

  buildPhase = ''
    make
  '';

  installPhase = ''
    make install
  '';

  meta = with pkgs.lib; {
    description = "Description of the application";
    homepage = "https://example.com/myapp";
    license = licenses.mit;
    maintainers = [ maintainers.yourname ];
    platforms = platforms.unix;
  };
}
```

#### Publishing Process
1. Create expression in nixpkgs repository
2. Submit PR to https://github.com/NixOS/nixpkgs
3. Maintainers review for quality and standard compliance
4. Upon merge, available via `nix-env -iA nixpkgs.myapp`
5. Or include in configuration.nix for declarative management

#### Common Commands
```bash
# Search for packages
nix search nixpkgs myapp

# Install package
nix-env -iA nixpkgs.myapp

# List installed packages
nix-env -q

# Remove package
nix-env -e myapp

# Create reproducible shell
nix-shell -p python3 nodejs

# Declarative system management (NixOS)
sudo nixos-rebuild switch
```

---

### Conda

**Overview:** Multi-language, cross-platform package manager. Includes pre-compiled binaries. Works on Windows, macOS, Linux.

#### Installation

**Miniconda (lightweight):**
```bash
# Download and install
curl -O https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
bash Miniconda3-latest-Linux-x86_64.sh

# Or using installer
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-arm64.sh
bash Miniconda3-latest-MacOSX-arm64.sh
```

**Anaconda Distribution:**
```bash
# Download from https://www.anaconda.com/download
# Run installer and follow prompts
bash Anaconda3-2024.02-Linux-x86_64.sh
```

#### Package Creation

**meta.yaml (conda package metadata):**
```yaml
package:
  name: myapp
  version: 1.0.0

source:
  url: https://github.com/yourname/myapp/archive/v1.0.0.tar.gz
  sha256: YOUR_SHA256_HASH

build:
  number: 0
  skip: True  # [win32]
  string: py39_0  # [py39]

requirements:
  build:
    - {{ compiler('c') }}
    - {{ compiler('cxx') }}
  host:
    - python
    - numpy
    - setuptools
  run:
    - python
    - numpy

test:
  imports:
    - myapp

about:
  home: https://github.com/yourname/myapp
  license: MIT
  license_family: MIT
  license_file: LICENSE
  summary: Short description
  description: Long description
  doc_url: https://docs.example.com
  dev_url: https://github.com/yourname/myapp

extra:
  recipe-maintainers:
    - yourname
```

#### Building and Publishing
```bash
# Install conda-build
conda install conda-build conda-verify

# Build the package
conda build .

# Convert to other platforms
conda convert -p all -o output_dir path/to/myapp-1.0.0-py39_0.tar.bz2

# Upload to Anaconda Cloud
anaconda upload /path/to/myapp-1.0.0-py39_0.tar.bz2
```

#### Publishing to Conda-Forge
1. Fork conda-forge/staged-recipes
2. Create PR with package recipe
3. Maintainers review and merge
4. Automated system builds and publishes
5. Package available via `conda install -c conda-forge myapp`

#### Common Commands
```bash
# Search for packages
conda search myapp

# Install package
conda install myapp

# Install from specific channel
conda install -c conda-forge myapp

# List installed packages
conda list

# Update all packages
conda update --all

# Create environment
conda create -n myenv python=3.11 numpy pandas

# Activate environment
conda activate myenv

# Export environment
conda env export > environment.yml

# Create from file
conda env create -f environment.yml
```

---

# Language Package Managers

## JavaScript

### npm (Node Package Manager)

**Overview:** Default package manager for Node.js. Largest package registry. Part of Node.js installation.

#### Installation
```bash
# Included with Node.js
# Download from https://nodejs.org/
node --version
npm --version

# Upgrade npm separately
npm install -g npm@latest
```

#### Package Creation (package.json)

**Example package.json:**
```json
{
  "name": "@yourname/mylib",
  "version": "1.0.0",
  "description": "Useful library for doing things",
  "main": "dist/index.js",
  "module": "dist/index.esm.js",
  "types": "dist/index.d.ts",
  "files": [
    "dist",
    "README.md",
    "LICENSE"
  ],
  "scripts": {
    "build": "tsc",
    "test": "jest",
    "prepublishOnly": "npm run test && npm run build"
  },
  "keywords": ["utility", "helper"],
  "author": "Your Name <email@example.com>",
  "license": "MIT",
  "repository": {
    "type": "git",
    "url": "https://github.com/yourname/mylib.git"
  },
  "bugs": {
    "url": "https://github.com/yourname/mylib/issues"
  },
  "homepage": "https://github.com/yourname/mylib#readme",
  "devDependencies": {
    "typescript": "^5.0.0",
    "jest": "^29.0.0"
  },
  "peerDependencies": {
    "react": ">=18.0.0"
  }
}
```

#### Publishing to npm
```bash
# Create npm account at https://www.npmjs.com/
# Login locally
npm login

# Verify scoped package
npm publish --access public

# Update version
npm version patch  # 1.0.0 -> 1.0.1
npm version minor  # 1.0.0 -> 1.1.0
npm version major  # 1.0.0 -> 2.0.0

# Publish new version
npm publish

# View package
npm view @yourname/mylib
```

#### Common Commands
```bash
# Initialize new project
npm init

# Install dependencies
npm install

# Install specific package
npm install lodash

# Install dev dependency
npm install --save-dev typescript

# Install globally
npm install -g live-server

# Update packages
npm update

# List dependencies
npm list

# Remove package
npm uninstall lodash

# Run scripts from package.json
npm run build
npm test
```

---

### Yarn

**Overview:** Fast, reliable package manager. Excellent for monorepos. Modern approach with workspaces.

#### Installation
```bash
# Install with npm
npm install -g yarn

# Or with Homebrew
brew install yarn

# Verify
yarn --version

# Upgrade to latest
yarn set version stable
```

#### Package Creation

**Same package.json as npm** (see above)

**Additional yarn-specific features (yarn.lock):**
Yarn creates a `yarn.lock` file automatically with exact versions and checksums for reproducible installs.

**Monorepo setup (workspaces):**
```json
{
  "private": true,
  "workspaces": [
    "packages/core",
    "packages/ui",
    "packages/cli"
  ]
}
```

#### Publishing to npm (via Yarn)
```bash
# Create account at https://www.npmjs.com/
# Login
yarn npm login

# Publish
yarn npm publish

# Publish specific workspace
yarn workspace @yourname/core npm publish
```

#### Common Commands
```bash
# Initialize project
yarn init

# Install dependencies
yarn install
# Or shorthand
yarn

# Add dependency
yarn add lodash

# Add dev dependency
yarn add --dev typescript

# Add globally
yarn global add live-server

# Update dependencies
yarn upgrade

# List dependencies
yarn list

# Remove package
yarn remove lodash

# Run scripts
yarn build
yarn test

# Workspace commands
yarn workspace core add lodash
yarn workspaces run test
```

---

### pnpm

**Overview:** Fast, disk-space efficient package manager. Up to 70% less disk usage than npm/Yarn. Monorepo-first.

#### Installation
```bash
# Install with npm
npm install -g pnpm

# Or with Homebrew
brew install pnpm

# Or standalone installer
curl -fsSL https://get.pnpm.io/install.sh | sh -

# Verify
pnpm --version

# Upgrade
pnpm self-update
```

#### Package Creation

**Same package.json as npm/Yarn**

**pnpm-workspace.yaml (monorepo setup):**
```yaml
packages:
  - 'packages/*'
  - 'apps/*'
```

**Or in package.json:**
```json
{
  "pnpm": {
    "overrides": {
      "react": "^18.0.0"
    },
    "peerDependencyRules": {
      "allowedVersions": {
        "react": "16 || 17 || 18"
      }
    }
  }
}
```

#### Publishing (same as npm)
```bash
pnpm login
pnpm publish
```

#### Common Commands
```bash
# Install dependencies (creates pnpm-lock.yaml)
pnpm install

# Add dependency
pnpm add lodash

# Add dev dependency
pnpm add -D typescript

# Add to monorepo workspace
pnpm add --filter=core lodash

# Update dependencies
pnpm update

# List dependencies
pnpm list

# Remove package
pnpm remove lodash

# Run scripts
pnpm run build
pnpm test

# Workspace commands
pnpm -r test
pnpm --filter=core build
```

---

### Bun

**Overview:** Ultra-fast all-in-one JavaScript runtime. Includes package manager, bundler, test runner, and server. 30x faster than npm.

#### Installation
```bash
# Official installer
curl -fsSL https://bun.sh/install | bash

# Or with Homebrew
brew install oven-sh/bun/bun

# Or from source
npm install -g bun

# Verify
bun --version
```

#### Package Creation

**Same package.json as other managers**

**bun.lockb (binary lock file):**
Bun generates a compact binary lock file automatically. It's optimized for performance and smaller file size.

#### Publishing (npm compatible)
```bash
# Login to npm
bun login

# Publish
bun publish

# Version
bun version patch
bun version minor
bun version major
```

#### Common Commands
```bash
# Install dependencies
bun install

# Add dependency
bun add lodash

# Add dev dependency
bun add --save-dev typescript

# Remove package
bun remove lodash

# Run scripts
bun run build
bun test

# Create new project
bun create react app-name

# Start development server
bun run dev

# Build for production
bun run build
```

---

## Python

### pip

**Overview:** Default package manager for Python. Installs packages from PyPI.

#### Installation
```bash
# Included with Python 3.4+
python3 -m pip --version

# Upgrade pip
python3 -m pip install --upgrade pip
```

#### Package Creation

**Directory structure:**
```
mypackage/
  mypackage/
    __init__.py
    module.py
  tests/
    test_module.py
  setup.py
  pyproject.toml
  README.md
  LICENSE
```

**setup.py (traditional):**
```python
from setuptools import setup, find_packages

setup(
    name="mypackage",
    version="1.0.0",
    author="Your Name",
    author_email="email@example.com",
    description="Short description",
    long_description=open("README.md").read(),
    long_description_content_type="text/markdown",
    url="https://github.com/yourname/mypackage",
    packages=find_packages(),
    classifiers=[
        "Programming Language :: Python :: 3",
        "Programming Language :: Python :: 3.8",
        "Programming Language :: Python :: 3.9",
        "Programming Language :: Python :: 3.10",
        "License :: OSI Approved :: MIT License",
        "Operating System :: OS Independent",
    ],
    python_requires=">=3.8",
    install_requires=[
        "requests>=2.25.0",
        "click>=8.0",
    ],
    extras_require={
        "dev": ["pytest", "black", "flake8"],
    },
)
```

**pyproject.toml (modern, PEP 517):**
```toml
[build-system]
requires = ["setuptools>=61.0", "wheel"]
build-backend = "setuptools.build_meta"

[project]
name = "mypackage"
version = "1.0.0"
description = "Short description"
readme = "README.md"
requires-python = ">=3.8"
license = {text = "MIT"}
authors = [
    {name = "Your Name", email = "email@example.com"}
]
keywords = ["utility", "helper"]
classifiers = [
    "Programming Language :: Python :: 3",
    "Programming Language :: Python :: 3.8",
    "Programming Language :: Python :: 3.9",
    "Programming Language :: Python :: 3.10",
]

dependencies = [
    "requests>=2.25.0",
    "click>=8.0",
]

[project.optional-dependencies]
dev = ["pytest", "black", "flake8"]

[project.urls]
Homepage = "https://github.com/yourname/mypackage"
Issues = "https://github.com/yourname/mypackage/issues"

[project.scripts]
myapp = "mypackage.cli:main"
```

#### Building and Publishing
```bash
# Install build tools
pip install --upgrade build twine

# Build distribution
python -m build

# Creates: dist/mypackage-1.0.0-py3-none-any.whl and .tar.gz

# Create PyPI account: https://pypi.org/

# Upload to TestPyPI first (optional)
python -m twine upload --repository testpypi dist/*

# Upload to PyPI
python -m twine upload dist/*

# Requires ~/.pypirc:
# [distutils]
# index-servers =
#     pypi
#     testpypi
#
# [pypi]
# username = __token__
# password = pypi-AgEIcHlwaS5vcmc...

# Or use environment variable
export TWINE_PASSWORD=pypi-AgEIcHlwaS5vcmc...
python -m twine upload dist/*
```

#### Common Commands
```bash
# Install package
pip install mypackage

# Install specific version
pip install mypackage==1.0.0

# Install from git
pip install git+https://github.com/yourname/mypackage.git

# Create virtual environment
python -m venv venv

# Activate virtual environment
source venv/bin/activate  # Linux/macOS
venv\Scripts\activate     # Windows

# Install from requirements file
pip install -r requirements.txt

# Generate requirements file
pip freeze > requirements.txt

# Upgrade package
pip install --upgrade mypackage

# Uninstall package
pip uninstall mypackage

# List installed packages
pip list
```

---

### Poetry

**Overview:** Modern dependency management and packaging. Simplifies Python project setup with pyproject.toml.

#### Installation
```bash
# Official installer (recommended)
curl -sSL https://install.python-poetry.org | python3 -

# Or with Homebrew
brew install poetry

# Or with pip
pip install poetry

# Verify
poetry --version
```

#### Package Creation

**pyproject.toml (Poetry format):**
```toml
[tool.poetry]
name = "mypackage"
version = "1.0.0"
description = "Short description"
authors = ["Your Name <email@example.com>"]
readme = "README.md"
license = "MIT"
repository = "https://github.com/yourname/mypackage"
keywords = ["utility"]

[tool.poetry.dependencies]
python = "^3.8"
requests = "^2.25.0"
click = "^8.0"

[tool.poetry.group.dev.dependencies]
pytest = "^7.0"
black = "^22.0"
flake8 = "^4.0"

[tool.poetry.scripts]
myapp = "mypackage.cli:main"

[build-system]
requires = ["poetry-core"]
build-backend = "poetry.core.masonry.api"
```

#### Initialize and Publishing
```bash
# Create new project
poetry new mypackage

# Or initialize existing project
poetry init

# Install dependencies
poetry install

# Add dependency
poetry add requests

# Add dev dependency
poetry add --group dev pytest

# Create virtual environment
poetry shell

# Build package
poetry build

# Creates: dist/mypackage-1.0.0-py3-none-any.whl and .tar.gz

# Configure PyPI credentials
poetry config pypi-token.pypi pypi-AgEIcHlwaS5vcmc...

# Or interactively
poetry config --interactive

# Publish to PyPI
poetry publish

# Publish to custom repository
poetry config repositories.custom https://example.com/pypi/
poetry publish -r custom
```

#### Common Commands
```bash
# Install dependencies from lock file
poetry install

# Add dependency
poetry add flask

# Add dev dependency
poetry add --group dev black

# Update dependencies
poetry update

# Show dependency tree
poetry show --tree

# Run command in venv
poetry run python script.py

# Activate virtual environment
poetry shell

# Deactivate
exit

# Lock dependencies
poetry lock --no-update

# Remove package
poetry remove flask

# Run tests
poetry run pytest
```

---

## Rust

### Cargo

**Overview:** Official Rust package manager. Handles compilation, testing, documentation, and publishing to crates.io.

#### Installation
```bash
# Install Rust (includes Cargo)
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# Verify
cargo --version
rustc --version

# Update Rust
rustup update
```

#### Package Creation (Crate)

**Cargo.toml:**
```toml
[package]
name = "mylib"
version = "1.0.0"
edition = "2021"
license = "MIT"
description = "A useful Rust library"
repository = "https://github.com/yourname/mylib"
homepage = "https://docs.rs/mylib"
documentation = "https://docs.rs/mylib"
readme = "README.md"
keywords = ["utility", "helper"]
categories = ["development-tools"]
authors = ["Your Name <email@example.com>"]
publish = true  # Enable publishing to crates.io

[dependencies]
serde = { version = "1.0", features = ["derive"] }
regex = "1"

[dev-dependencies]
criterion = "0.5"

[[bench]]
name = "benchmarks"
harness = false

[profile.release]
opt-level = 3
lto = true
```

**Example library code (src/lib.rs):**
```rust
//! # My Lib
//!
//! A useful Rust library for doing things.
//!
//! # Examples
//!
//! ```
//! use mylib::useful_function;
//!
//! assert_eq!(useful_function(1, 2), 3);
//! ```

/// Adds two numbers together.
///
/// # Arguments
///
/// * `a` - First number
/// * `b` - Second number
///
/// # Returns
///
/// The sum of a and b
pub fn useful_function(a: i32, b: i32) -> i32 {
    a + b
}
```

#### Publishing to crates.io
```bash
# Create account at https://crates.io/
# Obtain API token from https://crates.io/me

# Configure Cargo
cargo login YOUR_API_TOKEN

# Or set environment variable
export CARGO_REGISTRY_TOKEN=YOUR_API_TOKEN

# Build and test before publishing
cargo build
cargo test

# Generate documentation
cargo doc --open

# Verify package contents
cargo package

# Dry run to check for errors
cargo publish --dry-run

# Publish
cargo publish

# Once published, cannot be un-published (can be yanked)
# Yank a version (prevents new downloads)
cargo yank --vers 1.0.0

# Un-yank
cargo yank --vers 1.0.0 --undo
```

#### Common Commands
```bash
# Create new binary project
cargo new myapp

# Create new library
cargo new --lib mylib

# Build project
cargo build

# Build release
cargo build --release

# Run project
cargo run

# Run with arguments
cargo run -- --flag value

# Test
cargo test

# Generate documentation
cargo doc --no-deps --open

# Format code
cargo fmt

# Lint code
cargo clippy

# Check without building
cargo check

# Add dependency
cargo add serde

# Update dependencies
cargo update

# List dependencies
cargo tree
```

---

## Go

### Go Modules

**Overview:** Official Go dependency management system. Built into Go 1.11+.

#### Installation
```bash
# Go includes go modules
go version

# Enable modules for a project
go mod init github.com/yourname/mymodule
```

#### Package Creation

**go.mod file:**
```
module github.com/yourname/mymodule

go 1.21

require (
    github.com/gorilla/mux v1.8.0
    gopkg.in/yaml.v3 v3.0.0
)

require (
    github.com/foo/bar v1.2.3 // indirect
)
```

**Example package (mymodule/main.go):**
```go
package main

import (
    "fmt"
    "github.com/gorilla/mux"
)

func main() {
    router := mux.NewRouter()
    router.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
        fmt.Fprintf(w, "Hello, World!")
    })
    http.ListenAndServe(":8080", router)
}
```

#### Publishing (GitHub)
1. Create repository on GitHub
2. Go modules are automatically available at `github.com/yourname/mymodule`
3. Tag releases with semantic versioning: `git tag v1.0.0`
4. Push tags: `git push --tags`
5. Users import: `import "github.com/yourname/mymodule"`

#### Common Commands
```bash
# Initialize module
go mod init github.com/yourname/mymodule

# Download dependencies
go mod download

# Add dependency
go get github.com/gorilla/mux

# Update dependencies
go get -u ./...

# Tidy dependencies
go mod tidy

# Verify module
go mod verify

# Graph dependencies
go mod graph

# Build
go build

# Run
go run main.go

# Test
go test ./...

# View module info
go list -m all
```

---

## Java

### Maven

**Overview:** Build automation and dependency management for Java. XML configuration.

#### Installation
```bash
# Homebrew
brew install maven

# Or download from https://maven.apache.org/download.cgi
wget https://dlcdn.apache.org/maven/maven-3/3.9.4/binaries/apache-maven-3.9.4-bin.zip
unzip apache-maven-3.9.4-bin.zip

# Verify
mvn --version
```

#### Package Creation (POM)

**pom.xml (Project Object Model):**
```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0">
  <modelVersion>4.0.0</modelVersion>

  <groupId>com.yourcompany</groupId>
  <artifactId>mylib</artifactId>
  <version>1.0.0</version>
  <packaging>jar</packaging>

  <name>My Library</name>
  <description>A useful Java library</description>
  <url>https://github.com/yourname/mylib</url>

  <licenses>
    <license>
      <name>MIT License</name>
      <url>https://opensource.org/licenses/MIT</url>
    </license>
  </licenses>

  <developers>
    <developer>
      <name>Your Name</name>
      <email>email@example.com</email>
    </developer>
  </developers>

  <scm>
    <connection>scm:git:https://github.com/yourname/mylib.git</connection>
    <url>https://github.com/yourname/mylib</url>
  </scm>

  <properties>
    <maven.compiler.source>11</maven.compiler.source>
    <maven.compiler.target>11</maven.compiler.target>
    <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
  </properties>

  <dependencies>
    <dependency>
      <groupId>junit</groupId>
      <artifactId>junit</artifactId>
      <version>4.13.2</version>
      <scope>test</scope>
    </dependency>
    <dependency>
      <groupId>org.slf4j</groupId>
      <artifactId>slf4j-api</artifactId>
      <version>2.0.7</version>
    </dependency>
  </dependencies>

  <build>
    <plugins>
      <plugin>
        <groupId>org.apache.maven.plugins</groupId>
        <artifactId>maven-shade-plugin</artifactId>
        <version>3.4.1</version>
      </plugin>
      <plugin>
        <groupId>org.apache.maven.plugins</groupId>
        <artifactId>maven-javadoc-plugin</artifactId>
        <version>3.5.0</version>
      </plugin>
      <plugin>
        <groupId>org.apache.maven.plugins</groupId>
        <artifactId>maven-source-plugin</artifactId>
        <version>3.3.0</version>
      </plugin>
    </plugins>
  </build>

  <distributionManagement>
    <snapshotRepository>
      <id>ossrh</id>
      <url>https://s01.oss.sonatype.org/content/repositories/snapshots</url>
    </snapshotRepository>
    <repository>
      <id>ossrh</id>
      <url>https://s01.oss.sonatype.org/service/local/staging/deploy/maven2/</url>
    </repository>
  </distributionManagement>
</project>
```

#### Publishing to Maven Central
```bash
# Create account at https://s01.oss.sonatype.org/

# Configure ~/.m2/settings.xml:
# <server>
#   <id>ossrh</id>
#   <username>your_sonatype_username</username>
#   <password>your_sonatype_password</password>
# </server>

# Build and test
mvn clean package

# Deploy to staging
mvn clean deploy

# Release from staging (web UI at https://s01.oss.sonatype.org/)
```

#### Common Commands
```bash
# Initialize project
mvn archetype:generate -DgroupId=com.company -DartifactId=myapp

# Compile
mvn compile

# Test
mvn test

# Build JAR
mvn package

# Install to local repository
mvn install

# Deploy to repository
mvn deploy

# Run unit tests
mvn test

# Generate documentation
mvn javadoc:javadoc

# Clean
mvn clean
```

---

### Gradle

**Overview:** Modern build automation. Groovy or Kotlin DSL. Better for Android and large projects.

#### Installation
```bash
# Homebrew
brew install gradle

# Or sdkman
curl -s "https://get.sdkman.io" | bash
sdk install gradle

# Verify
gradle --version
```

#### Package Creation

**build.gradle (Groovy):**
```gradle
plugins {
    id 'java-library'
    id 'publishing'
    id 'signing'
}

group = 'com.yourcompany'
version = '1.0.0'

java {
    sourceCompatibility = JavaVersion.VERSION_11
    targetCompatibility = JavaVersion.VERSION_11
    withSourcesJar()
    withJavadocJar()
}

repositories {
    mavenCentral()
}

dependencies {
    implementation 'org.slf4j:slf4j-api:2.0.7'

    testImplementation 'junit:junit:4.13.2'
}

publishing {
    publications {
        mavenJava(MavenPublication) {
            from components.java

            pom {
                name = 'My Library'
                description = 'A useful Java library'
                url = 'https://github.com/yourname/mylib'

                licenses {
                    license {
                        name = 'MIT License'
                        url = 'https://opensource.org/licenses/MIT'
                    }
                }

                developers {
                    developer {
                        id = 'yourname'
                        name = 'Your Name'
                        email = 'email@example.com'
                    }
                }

                scm {
                    connection = 'scm:git:https://github.com/yourname/mylib.git'
                    url = 'https://github.com/yourname/mylib'
                }
            }
        }
    }

    repositories {
        maven {
            name = 'ossrh'
            url = 'https://s01.oss.sonatype.org/service/local/staging/deploy/maven2/'
            credentials {
                username project.findProperty('ossrhUsername') ?: System.getenv('OSSRH_USERNAME')
                password project.findProperty('ossrhPassword') ?: System.getenv('OSSRH_PASSWORD')
            }
        }
    }
}

signing {
    sign publishing.publications.mavenJava
}

tasks.named('test') {
    useJUnitPlatform()
}
```

#### Publishing to Maven Central
```bash
# Build
gradle build

# Publish
gradle publish

# Requires OSSRH credentials and GPG signing
```

#### Common Commands
```bash
# Initialize project
gradle init

# Build
gradle build

# Run tests
gradle test

# Run specific task
gradle :subproject:task

# List tasks
gradle tasks

# Clean
gradle clean

# Build without tests
gradle assemble

# Run application
gradle run

# Dependency tree
gradle dependencies

# Update dependencies
gradle dependencyUpdates
```

---

## C#/.NET

### NuGet

**Overview:** Package manager for .NET/C#. Hosts 350,000+ packages. Integrated with Visual Studio.

#### Installation
```bash
# NuGet comes with Visual Studio or .NET SDK

# Or standalone
dotnet --version

# Verify NuGet
dotnet nuget --version
```

#### Package Creation

**Project file (.csproj):**
```xml
<Project Sdk="Microsoft.NET.Sdk">

  <PropertyGroup>
    <TargetFrameworks>net6.0;net7.0;net8.0</TargetFrameworks>
    <LangVersion>latest</LangVersion>
    <Nullable>enable</Nullable>

    <!-- Package metadata -->
    <PackageId>MyCompany.MyLib</PackageId>
    <Version>1.0.0</Version>
    <Authors>Your Name</Authors>
    <Company>Your Company</Company>
    <Description>A useful .NET library</Description>
    <PackageDescription>Longer description for nuget.org</PackageDescription>
    <PackageTags>utility;helper</PackageTags>
    <PackageProjectUrl>https://github.com/yourname/mylib</PackageProjectUrl>
    <RepositoryUrl>https://github.com/yourname/mylib</RepositoryUrl>
    <RepositoryType>git</RepositoryType>
    <PackageLicenseExpression>MIT</PackageLicenseExpression>
    <GenerateDocumentationFile>true</GenerateDocumentationFile>

    <!-- Enable publishing -->
    <PublishRepositoryUrl>true</PublishRepositoryUrl>
    <IncludeSymbols>true</IncludeSymbols>
    <SymbolPackageFormat>snupkg</SymbolPackageFormat>
  </PropertyGroup>

  <ItemGroup>
    <PackageReference Include="Serilog" Version="2.10.0" />
  </ItemGroup>

  <ItemGroup>
    <PackageReference Include="xunit" Version="2.4.2" />
    <PackageReference Include="xunit.runner.visualstudio" Version="2.4.5">
      <PrivateAssets>all</PrivateAssets>
      <IncludeAssets>runtime; build; native; contentfiles; analyzers</IncludeAssets>
    </PackageReference>
  </ItemGroup>

</Project>
```

**Example class with XML documentation:**
```csharp
namespace MyCompany.MyLib;

/// <summary>
/// A useful utility class.
/// </summary>
public class UtilityClass
{
    /// <summary>
    /// Adds two numbers together.
    /// </summary>
    /// <param name="a">First number</param>
    /// <param name="b">Second number</param>
    /// <returns>The sum of a and b</returns>
    public static int Add(int a, int b) => a + b;
}
```

#### Publishing to NuGet
```bash
# Create account at https://www.nuget.org/

# Build package
dotnet pack --configuration Release

# Create API key at https://www.nuget.org/account/apikeys

# Push to NuGet
dotnet nuget push bin/Release/MyCompany.MyLib.1.0.0.nupkg --api-key YOUR_API_KEY --source https://api.nuget.org/v3/index.json

# Push symbols
dotnet nuget push bin/Release/MyCompany.MyLib.1.0.0.snupkg --api-key YOUR_API_KEY --source https://api.nuget.org/v3/index.json
```

#### Common Commands
```bash
# Create new project
dotnet new classlib -n MyLib

# Restore dependencies
dotnet restore

# Build
dotnet build

# Run tests
dotnet test

# Create NuGet package
dotnet pack

# Add NuGet package
dotnet add package Serilog

# Remove package
dotnet remove package Serilog

# List packages
dotnet list package

# Update packages
dotnet add package Serilog --version "latest"

# Search packages
dotnet nuget search serilog

# Configure NuGet source
dotnet nuget add source https://nuget.example.com/index.json -n CustomSource
```

---

## C++

### vcpkg

**Overview:** C++ library manager by Microsoft. Cross-platform. Pre-compiled binaries for fast setup.

#### Installation
```bash
# Clone repository
git clone https://github.com/Microsoft/vcpkg.git
cd vcpkg

# Bootstrap
./bootstrap-vcpkg.sh        # Linux/macOS
./bootstrap-vcpkg.bat       # Windows

# Add to PATH (optional)
export PATH="$PWD:$PATH"
```

#### Package Creation

**vcpkg.json (manifest mode):**
```json
{
  "name": "mylib",
  "version": "1.0.0",
  "description": "A useful C++ library",
  "homepage": "https://github.com/yourname/mylib",
  "license": "MIT",
  "dependencies": [
    "nlohmann-json",
    "zlib",
    {
      "name": "boost",
      "features": ["system", "filesystem"]
    }
  ]
}
```

**portfile.cmake (for vcpkg registry):**
```cmake
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO yourname/mylib
    REF v${VERSION}
    SHA512 YOUR_SHA512_HASH
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_copy_pdbs()

file(INSTALL "${SOURCE_PATH}/LICENSE"
     DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
     RENAME copyright)
```

#### Publishing
```bash
# Submit to https://github.com/Microsoft/vcpkg
# Fork repo, add port, submit PR

# Or create custom registry
# Host on GitHub or self-hosted server
# Users: vcpkg --overlay-ports=path/to/ports
```

#### Common Commands
```bash
# List available packages
vcpkg list

# Search for package
vcpkg search zlib

# Install package
vcpkg install zlib

# Install for specific triplet
vcpkg install zlib:x64-windows

# Remove package
vcpkg remove zlib:x64-windows

# Update database
vcpkg update

# Integrate with Visual Studio
vcpkg integrate install

# CMake integration
cmake .. -DCMAKE_TOOLCHAIN_FILE=[vcpkg]/scripts/buildsystems/vcpkg.cmake
```

---

### Conan

**Overview:** C/C++ package manager. Supports multiple build systems and compilers.

#### Installation
```bash
# Using pip (requires Python 3.6+)
pip install conan

# Or standalone installer
# Download from https://conan.io/download.html

# Verify
conan --version
```

#### Package Creation

**conanfile.py:**
```python
from conan import ConanFile
from conan.tools.cmake import CMake, cmake_layout

class MyLibConan(ConanFile):
    name = "mylib"
    version = "1.0.0"

    author = "Your Name <email@example.com>"
    license = "MIT"
    url = "https://github.com/yourname/mylib"
    homepage = "https://github.com/yourname/mylib"
    description = "A useful C++ library"
    topics = ("utility", "helper")

    settings = "os", "compiler", "build_type", "arch"
    options = {"shared": [True, False], "fPIC": [True, False]}
    default_options = {"shared": False, "fPIC": True}

    exports_sources = "src/*", "include/*", "CMakeLists.txt"

    requires = "zlib/1.2.13", "openssl/3.1.0"

    def layout(self):
        cmake_layout(self)

    def generate(self):
        tc = CMakeToolchain(self)
        tc.generate()
        deps = CMakeDeps(self)
        deps.generate()

    def build(self):
        cmake = CMake(self)
        cmake.configure()
        cmake.build()

    def package(self):
        cmake = CMake(self)
        cmake.install()

    def package_info(self):
        self.cpp_info.libs = ["mylib"]
```

#### Publishing
```bash
# Create Conan Center account
# https://conan.io/

# Create package
conan create . --build=missing

# Upload to Conan Center
conan upload mylib/1.0.0@ -r conancenter

# Or self-hosted repository
conan remote add myrepo https://my-repo.com
conan upload mylib/1.0.0@ -r myrepo
```

#### Common Commands
```bash
# Create package
conan create .

# Create with options
conan create . -o shared=True

# Install dependencies
conan install . --build=missing

# Search packages
conan search zlib

# List remotes
conan remote list

# Add remote
conan remote add myrepo https://my-repo.com

# Upload package
conan upload mylib/1.0.0@

# Remove package
conan remove mylib/1.0.0@
```

---

# Developer Tools

## asdf

**Overview:** Version manager for multiple programming languages. Single tool replaces rbenv, nvm, pyenv, etc.

#### Installation
```bash
# Homebrew
brew install asdf

# Or git
git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.13.0

# Add to shell
echo '. "$HOME/.asdf/asdf.sh"' >> ~/.bashrc
echo '. "$HOME/.asdf/asdf.sh"' >> ~/.zprofile
```

#### Setup

**.tool-versions file (project root):**
```
nodejs 18.12.0
python 3.11.5
ruby 3.2.0
go 1.21.0
rust 1.73.0
```

#### Usage
```bash
# Add plugins
asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs.git
asdf plugin add python
asdf plugin add ruby
asdf plugin add go
asdf plugin add rust

# List available versions
asdf list-all nodejs

# Install version
asdf install nodejs 18.12.0

# Set global version
asdf global nodejs 18.12.0

# Set project version (creates .tool-versions)
asdf local nodejs 18.12.0

# Current version
asdf current nodejs

# List installed versions
asdf list nodejs

# Update plugins
asdf plugin update --all

# Remove version
asdf uninstall nodejs 18.12.0
```

#### Integration with direnv
```bash
# Install asdf-direnv plugin
asdf plugin add direnv https://github.com/asdf-community/asdf-direnv.git

# Install direnv
asdf install direnv latest
asdf global direnv latest

# Create .envrc in project
echo 'use asdf' > .envrc
direnv allow

# Now environment variables load automatically
```

---

## mise

**Overview:** Rust-powered version manager. Replacement for asdf, direnv, and make. Fast performance.

#### Installation
```bash
# Homebrew
brew install mise

# Or standalone
curl https://mise.jdx.dev/install.sh | sh

# Verify
mise --version
```

#### Setup

**.mise.toml file (project root):**
```toml
[env]
NODE_ENV = "development"
PYTHON_PATH = "/opt/python"

[tools]
node = "18.12.0"
python = "3.11.5"
ruby = "3.2.0"

[tasks]
build = "make build"
test = "make test"
dev = "npm run dev"

[tasks.format]
run = "black . && prettier --write ."
description = "Format code"
```

#### Usage
```bash
# Install tool
mise use node@18.12.0

# Add multiple tools
mise use python@3.11.5 ruby@3.2.0

# List available versions
mise ls-remote node

# Current environment
mise current

# Show installed
mise ls

# Run task
mise run build
mise run test

# Set environment variable
mise set NODE_ENV=production

# Use in shell
eval "$(mise activate)"

# Update tools
mise upgrade
```

---

## direnv

**Overview:** Load/unload environment variables based on directory. Perfect for project-specific configurations.

#### Installation
```bash
# Homebrew
brew install direnv

# Or manual
wget https://github.com/direnv/direnv/releases/download/v2.33.0/direnv.linux-amd64
chmod +x direnv.linux-amd64
sudo mv direnv.linux-amd64 /usr/local/bin/direnv

# Hook into shell
# Add to ~/.bashrc or ~/.zshrc:
eval "$(direnv hook bash)"
# or
eval "$(direnv hook zsh)"
```

#### Setup

**.envrc file (project root):**
```bash
# Load Python virtualenv
layout python3

# Load Node.js versions
use nvm

# Set custom variables
export NODE_ENV="development"
export DATABASE_URL="postgresql://localhost/mydb"

# Load from .env file
dotenv

# Add to PATH
path_add PATH ./bin

# Use asdf
use asdf
```

#### Usage
```bash
# Create .envrc
touch .envrc

# Edit and save
nano .envrc

# Approve changes
direnv allow

# View current env
direnv dump

# Reload
direnv reload

# Don't load for this directory
direnv deny

# Status
direnv status
```

---

## devbox

**Overview:** Jetify Devbox provides isolated development environments using Nix without learning Nix.

#### Installation
```bash
# Download and install
curl -fsSL https://get.jetify.com/devbox | bash

# Or with Homebrew
brew install jetify/devbox/devbox

# Verify
devbox version
```

#### Setup

**devbox.json (project root):**
```json
{
  "packages": [
    "nodejs@18",
    "python@3.11",
    "postgresql@15",
    "redis@7",
    "golang@1.21"
  ],
  "shell": {
    "init_hook": [
      "echo 'Welcome to devbox!'"
    ],
    "scripts": {
      "build": "npm run build",
      "dev": "npm run dev",
      "test": "npm test"
    }
  }
}
```

#### Usage
```bash
# Initialize new devbox
devbox init

# Enter isolated shell
devbox shell

# Or pure shell (no host environment leakage)
devbox shell --pure

# Add packages
devbox add nodejs python

# List packages
devbox packages

# Remove package
devbox rm python@3.10

# Run scripts
devbox run build
devbox run dev

# Exit shell
exit

# Create shell script wrapper
devbox generate direnv   # Generate .envrc
devbox generate flake    # Generate flake.nix for NixOS
```

---

# Comparison Tables

## System Package Managers Comparison

| Feature | winget | Chocolatey | Scoop | Homebrew | MacPorts | apt | dnf | pacman | zypper | Nix | Conda |
|---------|--------|-----------|--------|----------|----------|-----|-----|---------|---------|-----|-------|
| **OS** | Windows 11 | Windows | Windows | macOS/Linux | macOS | Linux | Linux | Linux | Linux | Linux/macOS | Cross-platform |
| **Installation** | Built-in | Requires install | Requires install | brew | port | apt | dnf | pacman | zypper | Manual setup | Miniconda |
| **Package count** | 8,000+ | 10,000+ | 4,000+ | 30,000+ | 27,000+ | 60,000+ | 50,000+ | 80,000+ | 30,000+ | 120,000+ | 50,000+ |
| **Admin required** | No | Yes | No | No | Yes | Yes | Yes | Yes | Yes | No | No |
| **Binary packages** | Yes | Yes | Yes | Yes | Compiles | .deb | .rpm | Compiles | .rpm | Stores | Pre-compiled |
| **Speed** | Good | Good | Very good | Good | Slower | Fast | Fast | Very fast | Fast | Varies | Good |
| **Reproducibility** | Limited | Limited | Limited | Limited | Limited | Limited | Limited | Limited | Limited | Excellent | Excellent |
| **Learning curve** | Easy | Easy | Easy | Easy | Moderate | Easy | Easy | Easy | Easy | Steep | Easy |
| **Community** | Growing | Large | Growing | Large | Small | Very large | Large | Large | Small | Growing | Large |
| **Recommended for** | Modern Windows | Power users | Portable apps | macOS devs | Legacy macOS | Linux devs | Fedora/RHEL | Arch users | openSUSE | Reproducible builds | Data science |

---

## Language Package Managers Comparison

| Feature | npm | Yarn | pnpm | Bun | pip | Poetry | cargo | go mod | Maven | Gradle | NuGet | vcpkg | Conan |
|---------|-----|------|------|-----|-----|--------|-------|--------|-------|--------|-------|-------|-------|
| **Language** | JavaScript | JavaScript | JavaScript | JavaScript | Python | Python | Rust | Go | Java | Java | C#/.NET | C++ | C++ |
| **Speed** | Moderate | Good | Excellent | Excellent | Moderate | Good | Fast | Fast | Moderate | Good | Good | Varies | Varies |
| **Disk usage** | High | Moderate | Low (70% less) | Low | Moderate | Moderate | Low | Low | Moderate | Moderate | Low | Varies | Varies |
| **Lock files** | package-lock.json | yarn.lock | pnpm-lock.yaml | bun.lockb | requirements.txt | poetry.lock | Cargo.lock | go.sum | pom.xml | gradle.lock | packages.lock.json | vcpkg.lock | conanlock.txt |
| **Workspaces** | Limited | Excellent | Excellent | Good | Limited | Limited | Yes | Yes (modules) | Multi-module | Excellent | Limited | Limited | Limited |
| **Registry** | npm.js | npm.js | npm.js | npm.js | PyPI | PyPI | crates.io | github.com | Maven Central | Maven Central | nuget.org | vcpkg | Conan Center |
| **Registry size** | 3M+ packages | 3M+ packages | 3M+ packages | 3M+ packages | 500K+ packages | 500K+ packages | 150K+ crates | N/A (repos) | 550K+ artifacts | 550K+ artifacts | 350K+ packages | 5K+ ports | 1500+ packages |
| **Reproducibility** | Good | Excellent | Excellent | Excellent | Good | Excellent | Excellent | Excellent | Good | Good | Good | Good | Good |
| **Native support** | Yes | Yes | Yes | Yes | Yes | Yes | Yes | Yes | Yes | Yes | Yes | No (C++) | No (Python) |
| **Best for** | Web development | Large projects | Monorepos | Performance | Data science | Modern Python | System tools | Microservices | Enterprise | Android/large | .NET projects | C++ libraries | C/C++ projects |

---

## Developer Tools Comparison

| Feature | asdf | mise | devbox | direnv |
|---------|------|------|--------|--------|
| **Language** | Shell | Rust | Rust | C |
| **Speed** | Good | Excellent | Excellent | Excellent |
| **Multiple tools** | Yes | Yes | Yes | No (env vars) |
| **Environment variables** | No | Yes | Yes | Yes |
| **Task runner** | No | Yes | No | No |
| **Configuration file** | .tool-versions | .mise.toml | devbox.json | .envrc |
| **Plugins** | Yes (100+) | Built-in | No | No |
| **Reproducibility** | Good | Excellent | Excellent | Good |
| **Learning curve** | Easy | Moderate | Easy | Easy |
| **Startup time** | Moderate | Very fast | Fast | Very fast |
| **Nix integration** | Yes (plugin) | Yes (built-in) | Yes (native) | Limited |
| **Installation method** | Git/brew | Brew/standalone | Brew/download | Brew/manual |
| **Active development** | Yes | Yes | Yes | Yes |
| **Use case** | Version management | All-in-one tool | Isolated environments | Environment loading |

---

## JavaScript Package Managers Feature Matrix

| Feature | npm | Yarn | pnpm | Bun |
|---------|-----|------|------|-----|
| **Install time (1000 deps)** | ~40s | ~30s | ~10s | ~1s |
| **Disk usage (node_modules)** | 500MB+ | 500MB+ | 150MB | 150MB |
| **Monorepo support** | Basic | Excellent | Excellent | Good |
| **Offline installation** | Yes | Yes | Yes | Yes |
| **Zero-install** | No | Yes | No | No |
| **Plug'n'Play (PnP)** | No | Yes | No | Yes |
| **Corepack integration** | Yes | Yes | Yes | No |
| **Public registry** | npm.js | npm.js | npm.js | npm.js |
| **Private packages** | Yes | Yes | Yes | Yes |
| **SBOM generation** | Yes | No | No | No |
| **Audit command** | Yes | Yes | Yes | Yes |
| **Dedupe** | Yes | Yes | Yes | Yes |
| **Flat installs** | Old | No | No | No |
| **Hoisting** | Yes | Yes | No | No |

---

## Publishing Complexity Comparison

| Manager | Account setup | Local configuration | Building | Upload | Time to publish |
|---------|---------------|-------------------|----------|--------|-----------------|
| **npm** | Easy | Easy | Automatic | `npm publish` | 1 minute |
| **Yarn** | Same as npm | Easy | Automatic | `yarn npm publish` | 1 minute |
| **pnpm** | Same as npm | Easy | Automatic | `pnpm publish` | 1 minute |
| **pip** | Moderate | Moderate | `python -m build` | `twine upload` | 5 minutes |
| **Poetry** | Easy | Auto-configured | `poetry build` | `poetry publish` | 3 minutes |
| **Cargo** | Easy | `cargo login` | Automatic | `cargo publish` | 2 minutes |
| **Maven** | Complex | Complex | `mvn deploy` | Automated | 30+ minutes |
| **Gradle** | Complex | Complex | `gradle publish` | Automated | 30+ minutes |
| **NuGet** | Easy | `dotnet nuget` | `dotnet pack` | `dotnet nuget push` | 5 minutes |
| **Homebrew** | None | Fork & PR | Manual | GitHub PR | 1-2 weeks |
| **vcpkg** | None | Fork & PR | Automated | GitHub PR | 1-2 weeks |

---

## When to Use Each Package Manager

### System Package Managers
- **winget**: Windows 11 users wanting simplicity
- **Chocolatey**: Windows users needing advanced features
- **Scoop**: Windows users wanting Linux-like experience
- **Homebrew**: macOS developers (standard choice)
- **apt**: Debian/Ubuntu/Linux Mint users
- **dnf**: Fedora/RHEL/CentOS users
- **pacman**: Arch Linux users
- **zypper**: openSUSE/SUSE users
- **Nix**: Teams requiring reproducibility
- **Conda**: Data scientists, Python-heavy stacks

### Language Package Managers
- **npm**: Default for JavaScript/Node.js projects
- **Yarn**: Large projects, monorepos, teams
- **pnpm**: Monorepos, disk-conscious developers
- **Bun**: Performance-critical projects, edge computing
- **pip**: Simple Python projects, data science
- **Poetry**: Modern Python projects, team development
- **Cargo**: All Rust projects (mandatory)
- **Go modules**: All Go projects (mandatory)
- **Maven**: Enterprise Java, complex builds
- **Gradle**: Android, Kotlin, large Java projects
- **NuGet**: All .NET/C# projects (mandatory)
- **vcpkg**: Microsoft-centric C++ teams
- **Conan**: Cross-platform C++ projects

### Developer Tools
- **asdf**: Multi-language version management
- **mise**: Want asdf with extra features (faster, tasks)
- **devbox**: Need isolated, reproducible dev environments
- **direnv**: Just need environment variable management

---

This comprehensive guide provides everything needed to understand, create packages for, and publish to major package managers in 2024-2025.
