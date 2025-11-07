# Quick Reference: Git Workflow

## Daily Development Workflow

### Starting New Work
```powershell
# Switch to dev branch
git checkout dev

# Make sure you have latest changes
git pull origin dev
```

### Making Changes
```powershell
# Make your code changes in VS Code or any editor
# ... edit files ...

# Check what changed
git status

# Stage all changes
git add .

# Or stage specific files
git add src/Settings.ps1 ui/MainWindow.xaml

# Commit with descriptive message
git commit -m "Add: Description of what you added"
# or
git commit -m "Fix: Description of what you fixed"
# or
git commit -m "Update: Description of what you improved"

# Push to dev branch
git push origin dev
```

### Creating a Release

1. **Update Version**:
   - Edit `build/Build-Config.json` → change version number
   - Edit `CHANGELOG.md` → add new version section

2. **Build Release**:
   ```powershell
   cd build
   .\Build-Portable.ps1
   ```

3. **Test the Release**:
   - Extract the ZIP
   - Run the app
   - Test all features

4. **Commit the Release**:
   ```powershell
   git add .
   git commit -m "Release: v1.1.0"
   git push origin dev
   ```

5. **Merge to Main**:
   ```powershell
   git checkout main
   git merge dev
   git push origin main
   ```

6. **Create GitHub Release**:
   - Go to https://github.com/MadAreYou/Network_Check_app/releases
   - Click "Create a new release"
   - Tag: `v1.1.0` (match your version)
   - Title: `Network Check v1.1.0`
   - Description: Copy from CHANGELOG.md
   - Upload the ZIP file from `releases/` folder
   - Publish release

## Common Git Commands

### Status and Info
```powershell
git status              # What changed?
git log --oneline       # Commit history
git branch             # List branches
git remote -v          # Show remote URL
```

### Branching
```powershell
git checkout dev       # Switch to dev
git checkout main      # Switch to main
git checkout -b feature/my-feature  # Create new branch
```

### Syncing
```powershell
git pull               # Get latest changes
git push               # Send your changes
git fetch              # Check for updates
```

### Undoing Changes
```powershell
# Discard changes to a file
git checkout -- filename.ps1

# Unstage a file
git reset HEAD filename.ps1

# Undo last commit (keep changes)
git reset --soft HEAD~1

# Undo last commit (discard changes) - CAREFUL!
git reset --hard HEAD~1
```

## Commit Message Guidelines

### Format
```
Type: Short description (50 chars or less)

Optional longer description explaining:
- Why this change was needed
- What approach you took
- Any side effects or considerations
```

### Types
- `Add:` New feature or file
- `Fix:` Bug fix
- `Update:` Improvement to existing feature
- `Refactor:` Code restructuring (no behavior change)
- `Docs:` Documentation only
- `Build:` Changes to build system
- `Style:` Formatting, no code change

### Examples
```
Add: Network adapter selection dropdown

Fix: Dark mode text color in diagnostics tab

Update: Improved speed test error handling

Docs: Add screenshots to README

Build: Update build script for v1.1.0
```

## Branch Strategy

### `main` Branch
- **Purpose**: Stable, production-ready code
- **When to update**: After thorough testing on `dev`
- **Protected**: Only merge from `dev`, no direct commits

### `dev` Branch
- **Purpose**: Active development and testing
- **When to update**: Regular commits during development
- **Testing ground**: Test features here before merging to `main`

### Feature Branches (Optional)
For larger features:
```powershell
# Create feature branch from dev
git checkout dev
git checkout -b feature/new-theme-system

# Work on feature
# ... make changes ...
git commit -m "Add: Custom theme editor"

# Merge back to dev when done
git checkout dev
git merge feature/new-theme-system

# Delete feature branch
git branch -d feature/new-theme-system
```

## File Organization

### Files Tracked by Git (26 files)
```
✓ .gitignore
✓ LICENSE
✓ README.md
✓ CHANGELOG.md
✓ CONTRIBUTING.md
✓ NetworkCheckApp.ps1
✓ speedtest.exe
✓ .github/ (templates)
✓ assets/ (icons, images)
✓ build/ (build scripts)
✓ releases/ (ZIP files only)
✓ src/ (PowerShell modules)
✓ ui/ (XAML files)
```

### Files Ignored by Git (User Data)
```
✗ config.json (user settings)
✗ exports/ (speed test results)
✗ engine.log (temporary logs)
✗ releases/*/ (extracted folders)
✗ build/temp_*/ (build temporary)
```

## Troubleshooting

### "Your branch is behind 'origin/dev'"
```powershell
git pull origin dev
```

### "Merge conflict"
1. Open the conflicted file in VS Code
2. Choose which changes to keep
3. Remove conflict markers (`<<<<<<<`, `=======`, `>>>>>>>`)
4. Save the file
5. `git add .`
6. `git commit -m "Fix: Resolve merge conflict"`

### "I committed to the wrong branch"
```powershell
# If you committed to main instead of dev
git checkout dev
git cherry-pick <commit-hash>  # Get the commit hash from git log
git checkout main
git reset --hard HEAD~1  # Remove the commit from main
```

### "I want to discard all local changes"
```powershell
git reset --hard
git clean -fd
```

## Quick Links

- **Repository**: https://github.com/MadAreYou/Network_Check_app
- **Issues**: https://github.com/MadAreYou/Network_Check_app/issues
- **Releases**: https://github.com/MadAreYou/Network_Check_app/releases
- **Pull Requests**: https://github.com/MadAreYou/Network_Check_app/pulls

## Tips

1. **Commit often**: Small, focused commits are better than large ones
2. **Test before merging**: Always test on `dev` before merging to `main`
3. **Write good messages**: Future you will thank present you
4. **Pull before push**: Get latest changes before pushing yours
5. **One feature per commit**: Makes it easier to undo if needed

---

**Need help?** Check GITHUB-SETUP-COMPLETE.md for full documentation.
