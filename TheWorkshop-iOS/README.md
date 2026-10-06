# The Workshop - iOS Reverse Engineering Workstation

A professional-grade iOS app for binary analysis, function patching, and AI-powered reverse engineering. Similar to Binary Ninja or IDA Pro, built with SwiftUI.

## Features

### 🤖 AI-Powered Analysis
- **Configurable OpenAI-compatible endpoints** - Use any OpenAI-compatible API (OpenAI, LocalAI, Mistral, etc.)
- **Model preloading** - Automatically fetches available models from configured endpoints
- **Persistent configuration** - Settings saved across app sessions
- **14 AI Actions** - Analyze binaries, search functions, generate patches, find vulnerabilities, disassemble, extract strings, analyze imports, find cross-references, and more

### 🔧 Binary Patching
- **Function patching** - Hook, replace, bypass, log, modify return values
- **Inline Edit** - Replace bytes at specific addresses (Binary Ninja-style)
- **Byte Patch** - Byte-level operations (replace, insert, remove, XOR, add, subtract)
- **NOP patches** - No-operation patches
- **Call patches** - Insert function calls
- **Jump patches** - Redirect execution flow
- **Logos code generation** - Generate valid Logos syntax for Theos tweaks

### 📱 Binary Analysis
- **Load IPA, dylib, and executable files**
- **Function analysis** - View function details, addresses, sizes
- **ARM64 disassembly** - AI-powered disassembly viewer
- **Hex editor** - View and edit raw bytes
- **Symbol analysis** - Classes, protocols, symbols
- **Cross-reference finding** - Find XREFs to functions

### 🎨 User Interface
- **SwiftUI MVVM architecture** - Clean, maintainable code
- **Tab-based navigation** - Canvas, Code, Explorer, Inspector, AI Mentor, Binary Patcher, AI Agent, AI Settings
- **Visual node graph** - Drag-and-drop block canvas
- **Code generation** - Generate code for Jailbreak Tweak, Jailed Mod, Native Extension
- **Validation engine** - Validate projects before building
- **Timeline/undo system** - Full undo/redo support
- **Blueprint library** - Pre-built templates
- **Package explorer** - Browse project files

## Project Structure

```
TheWorkshop-iOS/
├── App/
│   └── TheWorkshopApp.swift          # App entry point
├── Models/                          # Data models (57 files)
│   ├── AIAgent.swift                 # AI Agent models
│   ├── AIConfiguration.swift         # AI endpoint configuration
│   ├── Block.swift                   # Visual canvas blocks
│   ├── Project.swift                 # Project model
│   └── ...
├── Services/                        # Business logic
│   ├── AIService.swift               # OpenAI-compatible API client
│   ├── AIAgentService.swift          # Interactive AI agent
│   ├── BinaryPatchingService.swift   # Binary analysis & patching
│   └── ...
├── ViewModels/                      # State management
│   ├── ProjectViewModel.swift        # Main app state
│   └── ...
├── Views/                           # SwiftUI views
│   ├── Agent/
│   │   └── AIAgentView.swift          # Main AI agent interface
│   ├── Binary/
│   │   ├── BinaryPatcherView.swift    # Binary patching UI
│   │   ├── FunctionDetailView.swift   # Function analysis
│   │   ├── DisassemblyView.swift      # ARM64 disassembly
│   │   └── ...
│   ├── Canvas/
│   │   ├── CanvasView.swift           # Visual canvas
│   │   └── ...
│   └── ContentView.swift              # Root view with tabs
├── Components/                      # Reusable UI
│   ├── WorkshopTheme.swift           # Color theme
│   └── ...
├── CodeGeneration/                  # Code generators
│   ├── LogosGenerator.swift          # Theos tweak generation
│   └── ...
└── Package.swift                     # Swift Package Manager
```

## Requirements

- **iOS 13.0+** (SwiftUI minimum)
- **Xcode 13.0+**
- **Swift 5.9+**

## Building

### Option 1: Swift Package Manager (Recommended)

```bash
# Clone the repository
git clone https://github.com/mshanghai570/The-Worksop.git
cd The-Worksop/TheWorkshop-iOS

# Build with Swift Package Manager
swift build -c release

# Or open in Xcode
xed .
```

### Option 2: Xcode Project

1. Open `TheWorkshop-iOS.xcodeproj` in Xcode
2. Select your development team in Signing & Capabilities
3. Build and run on device/simulator

### Option 3: Manual Setup

1. Create a new iOS App project in Xcode
2. Copy all files from `TheWorkshop-iOS/` into the project
3. Ensure `TheWorkshopApp.swift` is the entry point
4. Build and run

## Configuration

### AI Endpoint Setup

1. Open the app
2. Go to **AI Settings** tab
3. Enter your OpenAI-compatible endpoint URL (e.g., `https://api.openai.com/v1` or `http://localhost:8080/v1`)
4. Enter your API key
5. Tap **Test Connection** to verify
6. Tap **Load Models** to fetch available models

### Supported Endpoints
- OpenAI: `https://api.openai.com/v1`
- LocalAI: `http://localhost:8080/v1`
- Mistral: `https://api.mistral.ai/v1`
- Any OpenAI-compatible API

## Usage

### Basic Workflow

1. **Configure AI** (AI Settings tab)
   - Set endpoint URL
   - Set API key
   - Select a model

2. **Load a Binary** (Binary Patcher tab)
   - Tap "Load Binary"
   - Select an IPA, dylib, or executable
   - View functions, classes, and symbols

3. **Use AI Agent** (AI Agent tab)
   - Activate an agent
   - Send commands like:
     - "Analyze this binary"
     - "Smart patch the login function"
     - "Search for encryption functions"
     - "Find vulnerabilities"
     - "Disassemble at address 0x100004000"
   - View suggestions with confidence scores
   - Apply patches

4. **Create Patches** (Binary Patcher tab)
   - Select a function
   - Choose patch type (hook, replace, inline edit, byte patch)
   - Configure patch parameters
   - Generate Logos code
   - Apply to binary

### Advanced Features

- **Multiple Agents**: Create different agent personas for different tasks
- **Smart Patches**: AI suggests patches with confidence scores and risk levels
- **Binary Search**: Search for functions, patterns, strings, imports
- **Disassembly**: View ARM64 assembly with AI assistance
- **Cross-References**: Find where functions are called from
- **Hex Editing**: Direct byte manipulation

## Code Quality

### Architecture
- **MVVM** - Model-View-ViewModel pattern
- **Singleton Services** - Shared state management
- **Combine** - Reactive programming
- **Codable** - JSON serialization
- **Protocol-Oriented** - Extensible design

### Swift Features Used
- `@Published` properties
- `ObservableObject`
- `PassthroughSubject` for event streaming
- Async/await
- Generics
- Result builders (SwiftUI)
- Property wrappers

## Security Notes

- API keys are stored in UserDefaults (not Keychain)
- For production, consider using Keychain for API key storage
- Network requests use HTTPS by default
- Binary loading is sandboxed to the app's container

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## License

MIT License

## Acknowledgments

- Inspired by Binary Ninja and IDA Pro
- Built with SwiftUI and Combine
- Compatible with OpenAI API specification
