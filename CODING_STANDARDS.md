# Repository Coding Standards

## Swift Conventions
- **Indentation:** 4-space indentation.
- **Syntax:** Prefer `async/await` over completion handlers; use `struct` for models.
- **Formatting:** No manual wrapping of long lines; rely on Xcode indentation 'Ctrl-i', or format File 'Ctrl-Shift-i', or swift-format.
- **Method Braces:** Open on the same line, close on a new line.

## Architecture & UI
- **Pattern:** Use MVVM (Model-View-ViewModel) with SwiftUI.
- **Views:** Keep Views declarative and thin. Move logic to ViewModels.
- **Components:** Default to small, focused components rather than "God Views".
- **API Design:** Use [Swift API Design Guidelines](https://www.swift.org/documentation/api-design-guidelines/)

## Testing
- **Framework:** Use `Swift Testing` for new logic.
- **Coverage:** Write unit tests for all ViewModels and business logic.

## Dependency & Constraints
- **Package Manager:** Use Swift Package Manager (SPM).
- **License:** No GPL licensed components allowed; restrict to MIT/BSD.

## Git & Commits
- **Messages:** Use descriptive messages, e.g., "Fix crash on login".
