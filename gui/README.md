# PhiSHRI GUI - Development Only

This folder contains the Tauri source code for building the GUI installer.

**Users should NOT be here.** Download pre-built installers from:
- https://github.com/Stryk91/PhiSHRI/releases

---

## For Developers Only

### Prerequisites
- Node.js 18+
- Rust (latest stable)
- Tauri CLI v2

### Build

```bash
npm install
npm run tauri build
```

Output: `src-tauri/target/release/bundle/`

### Dev Mode

```bash
npm run tauri dev
```

---

## Release Artifacts

After `npm run tauri build`:

| Platform | Output |
|----------|--------|
| Windows | `bundle/msi/PhiSHRI-Installer.msi` |
| Linux | `bundle/appimage/PhiSHRI-Installer.AppImage` |
| Linux | `bundle/deb/phishri-installer.deb` |
| macOS | `bundle/dmg/PhiSHRI-Installer.dmg` |

Upload these to GitHub Releases for users to download.
