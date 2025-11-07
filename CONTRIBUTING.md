# Contributing to Network Check App

Thank you for considering contributing to Network Check App! This document provides guidelines and instructions for contributing.

## 🌟 How to Contribute

### Reporting Bugs

If you find a bug, please create an issue with:
- **Clear title** describing the problem
- **Steps to reproduce** the issue
- **Expected behavior** vs actual behavior
- **System information** (Windows version, PowerShell version)
- **Screenshots** if applicable

### Suggesting Features

Feature suggestions are welcome! Please create an issue with:
- **Clear description** of the feature
- **Use case** - why is this feature needed?
- **Proposed implementation** (if you have ideas)

### Pull Requests

1. **Fork the repository** to your GitHub account

2. **Clone your fork** locally:
   ```powershell
   git clone https://github.com/YOUR_USERNAME/Network_Check_app.git
   cd Network_Check_app
   ```

3. **Create a feature branch**:
   ```powershell
   git checkout -b feature/your-feature-name
   ```

4. **Make your changes**:
   - Follow the existing code style
   - Add comments for complex logic
   - Test your changes thoroughly

5. **Commit your changes**:
   ```powershell
   git add .
   git commit -m "Add: Clear description of your changes"
   ```
   
   Use conventional commit messages:
   - `Add:` for new features
   - `Fix:` for bug fixes
   - `Update:` for improvements to existing features
   - `Refactor:` for code refactoring
   - `Docs:` for documentation changes

6. **Push to your fork**:
   ```powershell
   git push origin feature/your-feature-name
   ```

7. **Create a Pull Request** on GitHub

## 📋 Development Guidelines

### Code Style

- **PowerShell**: Follow [PowerShell Practice and Style Guide](https://poshcode.gitbook.io/powershell-practice-and-style/)
- **XAML**: Maintain consistent indentation (4 spaces)
- **Comments**: Add comments for non-obvious code
- **Variables**: Use descriptive names (`$speedTestResults`, not `$str`)

### Project Structure

- `NetworkCheckApp.ps1` - Main entry point, UI initialization
- `ui/MainWindow.xaml` - WPF interface (XAML only)
- `src/*.ps1` - Modular functions (each file has specific purpose)
- `build/` - Build scripts and configuration
- `assets/` - Icons, images, static resources

### Testing

Before submitting a PR, please test:

1. **Basic functionality**:
   - Speed test runs successfully
   - Network info displays correctly
   - Diagnostic tools execute without errors
   - Settings save and load properly

2. **Theme switching**:
   - Light mode displays correctly
   - Dark mode displays correctly
   - All text is readable in both modes

3. **Error handling**:
   - Test without internet connection
   - Test with invalid paths in settings
   - Test diagnostic tools without admin rights

4. **Edge cases**:
   - No network adapter
   - Multiple network adapters
   - Empty export folder

### Adding New Features

When adding features:

1. **Keep it modular** - Add new functions to appropriate `src/*.ps1` files
2. **Update UI** - Modify `ui/MainWindow.xaml` if needed
3. **Add settings** - If configurable, add to Settings tab
4. **Update docs** - Update README.md and CHANGELOG.md
5. **Test thoroughly** - Ensure it works in both themes

## 🔧 Build Process

To build a portable release:

```powershell
cd build
.\Build-Portable.ps1
```

This creates `releases/NetworkCheck-vX.X.X-Portable.zip`

## 📝 Documentation

Please update documentation when:
- Adding new features
- Changing existing behavior
- Fixing bugs that affect usage

Update these files:
- `README.md` - Main documentation
- `CHANGELOG.md` - Version history
- `build/README.md` - If build process changes

## ❓ Questions

If you have questions:
- Check existing [Issues](https://github.com/MadAreYou/Network_Check_app/issues)
- Create a new issue with the `question` label
- Contact: juraj.madzunkov.main@gmail.com

## 📜 Code of Conduct

- Be respectful and constructive
- Welcome newcomers
- Focus on the best solution, not ego
- Help others learn and grow

## 🙏 Thank You

Every contribution, no matter how small, is appreciated!

---

Happy coding! 🚀
