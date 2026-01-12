# CurseForge Release Workflow

## Overview
Automated GitHub → CurseForge publishing via webhook. Push a tag, CurseForge packages and publishes automatically.

## One-Time Setup

### 1. Add Project ID to TOC
```
## X-Curse-Project-ID: YOUR_PROJECT_ID
```
Find Project ID on CurseForge project page → "About This Project"

### 2. Get CurseForge API Token
- Go to: https://www.curseforge.com/account/api-tokens
- Create token named "GitHub Webhook"

### 3. Add GitHub Webhook
- Go to: https://github.com/USERNAME/REPO/settings/hooks
- Click "Add webhook"
- **Payload URL:** https://www.curseforge.com/api/projects/{PROJECT_ID}/package?token={TOKEN}
- **Content type:** pplication/json
- **Events:** Just the push event
- **Active:** ✓

## Release Process

### Standard Release
```bash
# 1. Make changes, commit, push
git add .
git commit -m "feat: description"
git push

# 2. Create annotated tag
git tag -a 1.0.1 -m "Release v1.0.1 - description"

# 3. Push tag (triggers CurseForge)
git push origin 1.0.1
```

### Re-trigger a Release
If webhook wasn't set up when tag was pushed, or need to rebuild:
```bash
# Delete and recreate tag
git push origin --delete 1.0.1
git tag -d 1.0.1
git tag -a 1.0.1 -m "Release v1.0.1 - description"
git push origin 1.0.1
```

## Tag Naming → Release Type
| Tag Format | CurseForge Type |
|------------|-----------------|
| 1.0.1 | Release |
| 1.0.1-beta | Beta |
| 1.0.1-alpha | Alpha |

## CVarMaster Specifics
- **GitHub:** https://github.com/Stryk91/CVarMaster
- **CurseForge:** https://www.curseforge.com/wow/addons/cvarmaster
- **Project ID:** 1410205
- **Repo Path:** X:\dev\CVarMaster
- **Game Addon:** Y:\World of Warcraft\_retail_\Interface\AddOns\CVarMaster

## Sync Repo to Game Folder
```powershell
Copy-Item "X:\dev\CVarMaster\*" -Destination "Y:\World of Warcraft\_retail_\Interface\AddOns\CVarMaster" -Recurse -Force -Exclude ".git"
```

## Troubleshooting
- **No build on CurseForge:** Check webhook delivery in GitHub settings
- **Wrong release type:** Check tag name for alpha/beta keywords
- **Files missing:** Ensure .pkgmeta excludes are correct (or don't use pkgmeta)
