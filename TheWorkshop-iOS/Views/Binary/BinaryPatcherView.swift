//
//  Views/Binary/BinaryPatcherView.swift
//  TheWorkshop-iOS
//  Binary Loading & Function Patching Interface
//

import SwiftUI
import UniformTypeIdentifiers

public struct BinaryPatcherView: View {
    @StateObject private var binaryService = BinaryPatchingService.shared
    @StateObject private var aiService = AIService.shared
    
    @State private var binaryPath: String = ""
    @State private var isShowingFileImporter: Bool = false
    @State private var searchQuery: String = ""
    @State private var selectedFunction: BinaryFunction?
    @State private var selectedPatchType: PatchType = .hook
    @State private var customPatchCode: String = ""
    @State private var isGeneratingPatch: Bool = false
    @State private var showPatchDetail: Bool = false
    @State private var selectedPatch: PatchOperation?
    @State private var showHookCreator: Bool = false
    @State private var hookClassName: String = ""
    @State private var hookMethodName: String = ""
    @State private var hookCallbackCode: String = "NSLog(@\"Hook executed\");"
    @State private var isClassMethod: Bool = false
    @State private var hookType: HookType = .before

    public var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                HStack(spacing: 12) {
                    Image(systemName: "binarycoding")
                        .foregroundColor(WorkshopTheme.hotPink)
                    Text("BINARY PATCHER")
                        .font(.system(size: 13, weight: .bold, design: .monospaced))
                        .foregroundColor(WorkshopTheme.subtleText)
                    
                    Spacer()
                    
                    if binaryService.isLoading || binaryService.isAnalyzing {
                        ProgressView()
                            .scaleEffect(0.8)
                    }
                }
                .padding(12)
                .background(WorkshopTheme.darkCard)

                Divider().background(WorkshopTheme.cardBorder)

                // Binary Load Section
                VStack(alignment: .leading, spacing: 12) {
                    if let binary = binaryService.loadedBinary {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(WorkshopTheme.neonGreen)
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Loaded: \(URL(fileURLWithPath: binary.path).lastPathComponent)")
                                    .font(.system(size: 13, weight: .bold, design: .monospaced))
                                    .foregroundColor(WorkshopTheme.brightText)
                                Text("Architecture: \(binary.architecture.rawValue) \(binary.isFatBinary ? "(Fat Binary)" : "")")
                                    .font(.system(size: 11, design: .monospaced))
                                    .foregroundColor(WorkshopTheme.subtleText)
                            }
                            Spacer()
                            Button(action: unloadBinary) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(WorkshopTheme.errorRed)
                            }
                        }
                        .padding(10)
                        .background(WorkshopTheme.neonGreen.opacity(0.1))
                        .cornerRadius(8)
                        
                        HStack(spacing: 12) {
                            VStack {
                                Text("\(binary.functions.count)")
                                    .font(.system(size: 18, weight: .bold, design: .monospaced))
                                    .foregroundColor(WorkshopTheme.neonGreen)
                                Text("Functions")
                                    .font(.system(size: 10, design: .monospaced))
                                    .foregroundColor(WorkshopTheme.subtleText)
                            }
                            
                            VStack {
                                Text("\(binary.classes.count)")
                                    .font(.system(size: 18, weight: .bold, design: .monospaced))
                                    .foregroundColor(WorkshopTheme.cyberCyan)
                                Text("Classes")
                                    .font(.system(size: 10, design: .monospaced))
                                    .foregroundColor(WorkshopTheme.subtleText)
                            }
                            
                            VStack {
                                Text("\(binary.symbols.count)")
                                    .font(.system(size: 18, weight: .bold, design: .monospaced))
                                    .foregroundColor(WorkshopTheme.hotPink)
                                Text("Symbols")
                                    .font(.system(size: 10, design: .monospaced))
                                    .foregroundColor(WorkshopTheme.subtleText)
                            }
                            
                            Spacer()
                            
                            Button(action: { showHookCreator = true }) {
                                HStack(spacing: 4) {
                                    Image(systemName: "plus")
                                    Text("Add Hook")
                                }
                                .font(.system(size: 11, weight: .bold, design: .monospaced))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(WorkshopTheme.cyberCyan)
                                .foregroundColor(.black)
                                .cornerRadius(6)
                            }
                        }
                    } else {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("No binary loaded")
                                .font(.system(size: 13, weight: .bold, design: .monospaced))
                                .foregroundColor(WorkshopTheme.subtleText)
                            Text("Load an iOS binary (IPA, dylib, or executable) to analyze and patch functions.")
                                .font(.system(size: 11))
                                .foregroundColor(WorkshopTheme.subtleText.opacity(0.6))
                            
                            HStack(spacing: 12) {
                                Button(action: { isShowingFileImporter = true }) {
                                    HStack(spacing: 6) {
                                        Image(systemName: "folder.fill.badge.plus")
                                        Text("Load Binary")
                                    }
                                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .background(WorkshopTheme.neonGreen)
                                    .foregroundColor(.black)
                                    .cornerRadius(8)
                                }
                                
                                Button(action: loadSampleBinary) {
                                    HStack(spacing: 6) {
                                        Image(systemName: "doc.on.clipboard")
                                        Text("Sample")
                                    }
                                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .background(WorkshopTheme.darkCard)
                                    .foregroundColor(WorkshopTheme.brightText)
                                    .cornerRadius(8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(WorkshopTheme.cardBorder, lineWidth: 1)
                                    )
                                }
                            }
                        }
                        .padding(12)
                        .background(WorkshopTheme.warningYellow.opacity(0.1))
                        .cornerRadius(8)
                    }
                }
                .padding(12)

                Divider().background(WorkshopTheme.cardBorder)

                // Search & Filter
                if binaryService.loadedBinary != nil {
                    HStack(spacing: 8) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(WorkshopTheme.cyberCyan)
                        TextField(
                            "Search functions, classes, symbols...",
                            text: $searchQuery
                        )
                        .font(.system(size: 12, design: .monospaced))
                        .textFieldStyle(.plain)
                        .padding(8)
                        .background(WorkshopTheme.darkCard)
                        .cornerRadius(6)
                        .foregroundColor(WorkshopTheme.brightText)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(WorkshopTheme.cardBorder, lineWidth: 1)
                        )
                    }
                    .padding(12)

                    Divider().background(WorkshopTheme.cardBorder)
                }

                // Main Content Area
                ZStack {
                    if binaryService.isLoading || binaryService.isAnalyzing {
                        VStack(spacing: 12) {
                            ProgressView()
                                .scaleEffect(1.5)
                            Text("Analyzing binary...")
                                .font(.system(size: 13, design: .monospaced))
                                .foregroundColor(WorkshopTheme.subtleText)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else if let binary = binaryService.loadedBinary, !searchQuery.isEmpty {
                        // Search Results
                        ScrollView {
                            if let selectedFunction = selectedFunction {
                                FunctionDetailView(
                                    function: selectedFunction,
                                    onPatch: { patchType, code in
                                        selectedPatchType = patchType
                                        customPatchCode = code
                                        createPatch()
                                    },
                                    onCancel: { selectedFunction = nil }
                                )
                                .padding(12)
                            } else {
                                VStack(alignment: .leading, spacing: 8) {
                                    // Function Results
                                    if !binaryService.searchFunctions(query: searchQuery).isEmpty {
                                        Text("Functions")
                                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                                            .foregroundColor(WorkshopTheme.neonGreen)
                                            .padding(.horizontal, 12)
                                        
                                        ForEach(binaryService.searchFunctions(query: searchQuery)) { func in
                                            FunctionRow(
                                                function: func,
                                                isSelected: selectedFunction?.id == func.id,
                                                onSelect: { selectedFunction = func }
                                            )
                                        }
                                    }

                                    // Class Results
                                    if !binaryService.searchClasses(query: searchQuery).isEmpty {
                                        Text("Classes")
                                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                                            .foregroundColor(WorkshopTheme.cyberCyan)
                                            .padding(.horizontal, 12)
                                        
                                        ForEach(binaryService.searchClasses(query: searchQuery), id: \.self) { className in
                                            ClassRow(
                                                className: className,
                                                onSelect: { 
                                                    // Find functions in this class
                                                    let classFunctions = binary.functions.filter { $0.className == className }
                                                    if let firstFunc = classFunctions.first {
                                                        selectedFunction = firstFunc
                                                    }
                                                }
                                            )
                                        }
                                    }

                                    // Symbol Results
                                    if !binaryService.searchSymbols(query: searchQuery).isEmpty {
                                        Text("Symbols")
                                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                                            .foregroundColor(WorkshopTheme.hotPink)
                                            .padding(.horizontal, 12)
                                        
                                        ForEach(binaryService.searchSymbols(query: searchQuery), id: \.self) { symbol in
                                            SymbolRow(symbol: symbol)
                                        }
                                    }

                                    if binaryService.searchFunctions(query: searchQuery).isEmpty &&
                       binaryService.searchClasses(query: searchQuery).isEmpty &&
                       binaryService.searchSymbols(query: searchQuery).isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 24))
                                .foregroundColor(WorkshopTheme.subtleText.opacity(0.4))
                            Text("No results found for \"\(searchQuery)\"")
                                .font(.system(size: 12))
                                .foregroundColor(WorkshopTheme.subtleText)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                                }
                                .padding(.vertical, 12)
                            }
                        }
                    } else if let binary = binaryService.loadedBinary {
                        // Show all functions when no search
                        ScrollView {
                            VStack(alignment: .leading, spacing: 12) {
                                if !binary.classes.isEmpty {
                                    Text("Classes")
                                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                                        .foregroundColor(WorkshopTheme.cyberCyan)
                                        .padding(.horizontal, 12)
                                    
                                    LazyVStack(spacing: 4) {
                                        ForEach(binary.classes, id: \.self) { className in
                                            ClassRow(
                                                className: className,
                                                onSelect: { 
                                                    let classFunctions = binary.functions.filter { $0.className == className }
                                                    if let firstFunc = classFunctions.first {
                                                        selectedFunction = firstFunc
                                                    }
                                                }
                                            )
                                        }
                                    }
                                }

                                if !binary.functions.isEmpty {
                                    Text("Functions")
                                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                                        .foregroundColor(WorkshopTheme.neonGreen)
                                        .padding(.horizontal, 12)
                                    
                                    LazyVStack(spacing: 4) {
                                        ForEach(binary.functions) { func in
                                            FunctionRow(
                                                function: func,
                                                isSelected: selectedFunction?.id == func.id,
                                                onSelect: { selectedFunction = func }
                                            )
                                        }
                                    }
                                }

                                if binary.functions.isEmpty && binary.classes.isEmpty {
                                    VStack(spacing: 12) {
                                        Image(systemName: "binarycoding")
                                            .font(.system(size: 24))
                                            .foregroundColor(WorkshopTheme.subtleText.opacity(0.4))
                                        Text("Binary loaded but no functions extracted")
                                            .font(.system(size: 12))
                                            .foregroundColor(WorkshopTheme.subtleText)
                                        Text("Use AI analysis for better results")
                                            .font(.system(size: 10))
                                            .foregroundColor(WorkshopTheme.subtleText.opacity(0.6))
                                    }
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                }
                            }
                            .padding(.vertical, 12)
                        }
                    } else {
                        // Empty state
                        VStack(spacing: 12) {
                            Image(systemName: "binarycoding")
                                .font(.system(size: 32))
                                .foregroundColor(WorkshopTheme.subtleText.opacity(0.4))
                            Text("Load a binary to start patching")
                                .font(.system(size: 13, design: .monospaced))
                                .foregroundColor(WorkshopTheme.subtleText)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
            }
            .background(WorkshopTheme.deepBackground)
            .navigationTitle("Binary Patcher")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .primaryAction) {
                    if binaryService.loadedBinary != nil {
                        Button(action: { showPatchDetail = false; selectedPatch = nil }) {
                            Image(systemName: "list.bullet")
                        }
                        .disabled(!showPatchDetail)
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
        
        // File Importer
        .fileImporter(
            isPresented: $isShowingFileImporter,
            allowedContentTypes: [.folder, .data, UTType(filenameExtension: "ipa", conformingTo: .data),
                                   UTType(filenameExtension: "dylib", conformingTo: .data),
                                   UTType(filenameExtension: "app", conformingTo: .folder)],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                if let url = urls.first {
                    Task {
                        do {
                            try await binaryService.loadBinary(at: url.path)
                        } catch {
                            // Show error
                        }
                    }
                }
            case .failure(let error):
                print("Error importing: \(error)")
            }
        }
        
        // Patch Detail Sheet
        .sheet(item: $selectedPatch) { patch in
            PatchDetailView(patch: patch)
        }
        
        // Hook Creator Sheet
        .sheet(isPresented: $showHookCreator) {
            HookCreatorView(
                className: $hookClassName,
                methodName: $hookMethodName,
                isClassMethod: $isClassMethod,
                hookType: $hookType,
                callbackCode: $hookCallbackCode,
                onCreate: createHook
            )
        }
    }

    private func loadSampleBinary() {
        Task {
            // Create a sample binary info for demonstration
            let sampleFunctions = [
                BinaryFunction(
                    name: "lockUIFromSource:withOptions:",
                    address: 0x100004000,
                    size: 256,
                    className: "SBLockScreenManager",
                    methodSignature: "-(void)lockUIFromSource:(long long)arg1 withOptions:(id)arg2",
                    returnType: "void",
                    parameterTypes: ["long long", "id"]
                ),
                BinaryFunction(
                    name: "applicationDidFinishLaunching:",
                    address: 0x100005000,
                    size: 128,
                    className: "SBApplication",
                    methodSignature: "-(BOOL)applicationDidFinishLaunching:(id)arg1",
                    returnType: "BOOL",
                    parameterTypes: ["id"]
                ),
                BinaryFunction(
                    name: "touchesBegan:withEvent:",
                    address: 0x100006000,
                    size: 96,
                    className: "UIButton",
                    methodSignature: "-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event",
                    returnType: "void",
                    parameterTypes: ["NSSet *", "UIEvent *"]
                )
            ]
            
            let sampleBinary = BinaryInfo(
                path: "/Applications/SpringBoard.app/SpringBoard",
                architecture: .arm64,
                isFatBinary: false,
                functions: sampleFunctions,
                classes: ["SBLockScreenManager", "SBApplication", "UIButton", "UIViewController"],
                protocols: ["UIApplicationDelegate"],
                symbols: ["_lockUIFromSource", "_applicationDidFinishLaunching", "_touchesBegan"]
            )
            
            binaryService.loadedBinary = sampleBinary
        }
    }

    private func unloadBinary() {
        binaryService.unloadBinary()
        selectedFunction = nil
        searchQuery = ""
    }

    private func createPatch() {
        guard let funcToPatch = selectedFunction else { return }
        
        isGeneratingPatch = true
        Task {
            do {
                let patch = try await binaryService.createPatch(
                    for: funcToPatch.displayName,
                    patchType: selectedPatchType,
                    newCode: customPatchCode.isEmpty ? nil : customPatchCode
                )
                selectedPatch = patch
                showPatchDetail = true
            } catch {
                // Show error
            }
            isGeneratingPatch = false
        }
    }

    private func createHook() {
        Task {
            do {
                try await binaryService.createHook(
                    className: hookClassName,
                    methodName: hookMethodName,
                    isClassMethod: isClassMethod,
                    hookType: hookType,
                    callbackCode: hookCallbackCode
                )
                
                // Clear and close
                hookClassName = ""
                hookMethodName = ""
                hookCallbackCode = "NSLog(@\"Hook executed\");"
                isClassMethod = false
                hookType = .before
                showHookCreator = false
                
            } catch {
                // Show error
            }
        }
    }
}

// MARK: - Subviews

struct FunctionRow: View {
    let function: BinaryFunction
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    if let className = function.className {
                        Text(className)
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundColor(WorkshopTheme.cyberCyan)
                    }
                    Text(function.name)
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(WorkshopTheme.brightText)
                    Spacer()
                    Text("0x\(String(format: "%llX", function.address))")
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundColor(WorkshopTheme.subtleText)
                }
                
                if let methodSignature = function.methodSignature {
                    Text(methodSignature)
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundColor(WorkshopTheme.subtleText)
                }
            }
            .padding(10)
            .background(isSelected ? WorkshopTheme.neonGreen.opacity(0.15) : WorkshopTheme.darkCard)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? WorkshopTheme.neonGreen : WorkshopTheme.cardBorder, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

struct ClassRow: View {
    let className: String
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 8) {
                Image(systemName: "cube.fill")
                    .foregroundColor(WorkshopTheme.cyberCyan)
                Text(className)
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundColor(WorkshopTheme.brightText)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(WorkshopTheme.subtleText)
            }
            .padding(10)
            .background(WorkshopTheme.darkCard)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(WorkshopTheme.cardBorder, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

struct SymbolRow: View {
    let symbol: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "terminal.fill")
                .foregroundColor(WorkshopTheme.hotPink)
            Text(symbol)
                .font(.system(size: 11, design: .monospaced))
                .foregroundColor(WorkshopTheme.brightText)
        }
        .padding(10)
        .background(WorkshopTheme.darkCard)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(WorkshopTheme.cardBorder, lineWidth: 1)
        )
    }
}

struct FunctionDetailView: View {
    let function: BinaryFunction
    let onPatch: (PatchType, String) -> Void
    let onCancel: () -> Void

    @State private var selectedPatchType: PatchType = .hook
    @State private var customCode: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "function")
                    .foregroundColor(WorkshopTheme.neonGreen)
                Text("FUNCTION DETAIL")
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundColor(WorkshopTheme.subtleText)
                Spacer()
                Button(action: onCancel) {
                    Image(systemName: "xmark")
                        .foregroundColor(WorkshopTheme.subtleText)
                }
            }

            Divider().background(WorkshopTheme.cardBorder)

            VStack(alignment: .leading, spacing: 8) {
                Text(function.displayName)
                    .font(.system(size: 16, weight: .bold, design: .monospaced))
                    .foregroundColor(WorkshopTheme.neonGreen)
                
                if let methodSignature = function.methodSignature {
                    Text(methodSignature)
                        .font(.system(size: 13, design: .monospaced))
                        .foregroundColor(WorkshopTheme.cyberCyan)
                }
                
                HStack(spacing: 16) {
                    VStack(alignment: .leading) {
                        Text("Address")
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundColor(WorkshopTheme.subtleText)
                        Text("0x\(String(format: "%llX", function.address))")
                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                            .foregroundColor(WorkshopTheme.brightText)
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Size")
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundColor(WorkshopTheme.subtleText)
                        Text("\(function.size) bytes")
                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                            .foregroundColor(WorkshopTheme.brightText)
                    }
                    
                    if let returnType = function.returnType {
                        VStack(alignment: .leading) {
                            Text("Returns")
                                .font(.system(size: 10, design: .monospaced))
                                .foregroundColor(WorkshopTheme.subtleText)
                            Text(returnType)
                                .font(.system(size: 12, weight: .bold, design: .monospaced))
                                .foregroundColor(WorkshopTheme.brightText)
                        }
                    }
                }
            }

            Divider().background(WorkshopTheme.cardBorder)

            VStack(alignment: .leading, spacing: 8) {
                Text("CREATE PATCH")
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundColor(WorkshopTheme.subtleText)
                
                Picker("Patch Type", selection: $selectedPatchType) {
                    ForEach(PatchType.allCases, id: \.self) { type in
                        Text(type.rawValue.capitalized)
                            .tag(type)
                    }
                }
                .pickerStyle(.segmented)
                .tint(WorkshopTheme.neonGreen)

                TextEditor(text: $customCode)
                    .font(.system(size: 12, design: .monospaced))
                    .padding(10)
                    .background(WorkshopTheme.darkCard)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(WorkshopTheme.cardBorder, lineWidth: 1)
                    )
                    .foregroundColor(WorkshopTheme.brightText)
                    .frame(minHeight: 100)

                Button(action: { onPatch(selectedPatchType, customCode) }) {
                    HStack(spacing: 6) {
                        Image(systemName: "wrench.and.screwdriver.fill")
                        Text("Generate Patch")
                    }
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(WorkshopTheme.neonGreen)
                    .foregroundColor(.black)
                    .cornerRadius(8)
                }
            }
        }
        .padding(16)
        .background(WorkshopTheme.deepBackground)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(WorkshopTheme.cardBorder, lineWidth: 1)
        )
    }
}

struct PatchDetailView: View {
    let patch: PatchOperation

    @State private var isApplied: Bool

    init(patch: PatchOperation) {
        self.patch = patch
        _isApplied = State(initialValue: patch.isApplied)
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: isApplied ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(isApplied ? WorkshopTheme.neonGreen : WorkshopTheme.subtleText)
                            Text(patch.functionName)
                                .font(.system(size: 18, weight: .bold, design: .monospaced))
                                .foregroundColor(WorkshopTheme.brightText)
                        }

                        HStack(spacing: 16) {
                            WorkshopBadge(text: patch.patchType.rawValue.capitalized, color: WorkshopTheme.hotPink)
                            if let address = patch.address {
                                Text("0x\(String(format: "%llX", address))")
                                    .font(.system(size: 11, design: .monospaced))
                                    .foregroundColor(WorkshopTheme.subtleText)
                            }
                        }
                    }

                    Divider().background(WorkshopTheme.cardBorder)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("PATCH CODE")
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundColor(WorkshopTheme.subtleText)
                        
                        Text(patch.patchedCode)
                            .font(.system(size: 12, design: .monospaced))
                            .padding(12)
                            .background(WorkshopTheme.darkCard)
                            .cornerRadius(8)
                            .foregroundColor(WorkshopTheme.brightText)
                            .textSelection(.enabled)
                    }

                    if let original = patch.originalCode {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("ORIGINAL")
                                .font(.system(size: 11, weight: .bold, design: .monospaced))
                                .foregroundColor(WorkshopTheme.subtleText)
                            
                            Text(original)
                                .font(.system(size: 11, design: .monospaced))
                                .padding(12)
                                .background(WorkshopTheme.darkCard)
                                .cornerRadius(8)
                                .foregroundColor(WorkshopTheme.subtleText)
                        }
                    }

                    Divider().background(WorkshopTheme.cardBorder)

                    HStack(spacing: 12) {
                        Button(action: toggleApplied) {
                            HStack(spacing: 6) {
                                Image(systemName: isApplied ? "checkmark" : "arrow.clockwise")
                                Text(isApplied ? "Applied" : "Apply Patch")
                            }
                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(isApplied ? WorkshopTheme.neonGreen : WorkshopTheme.cyberCyan)
                            .foregroundColor(.black)
                            .cornerRadius(8)
                        }

                        Button(action: copyCode) {
                            HStack(spacing: 6) {
                                Image(systemName: "doc.on.doc")
                                Text("Copy Code")
                            }
                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(WorkshopTheme.darkCard)
                            .foregroundColor(WorkshopTheme.brightText)
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(WorkshopTheme.cardBorder, lineWidth: 1)
                            )
                        }
                    }
                }
                .padding(16)
            }
            .background(WorkshopTheme.deepBackground)
            .navigationTitle("Patch Detail")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        // Dismiss
                    }
                    .foregroundColor(WorkshopTheme.subtleText)
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    private func toggleApplied() {
        isApplied.toggle()
        var updatedPatch = patch
        updatedPatch.isApplied = isApplied
        updatedPatch.appliedAt = isApplied ? Date() : nil
        
        if let index = BinaryPatchingService.shared.patches.firstIndex(where: { $0.id == patch.id }) {
            BinaryPatchingService.shared.patches[index] = updatedPatch
        }
    }

    private func copyCode() {
        #if os(iOS)
        UIPasteboard.general.string = patch.patchedCode
        #endif
    }
}

struct HookCreatorView: View {
    @Binding var className: String
    @Binding var methodName: String
    @Binding var isClassMethod: Bool
    @Binding var hookType: HookType
    @Binding var callbackCode: String
    
    let onCreate: () -> Void

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("HOOK CONFIGURATION")) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Class Name")
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundColor(WorkshopTheme.subtleText)
                        TextField("Enter class name", text: $className)
                            .font(.system(size: 13, design: .monospaced))
                            .textFieldStyle(.plain)
                            .padding(10)
                            .background(WorkshopTheme.darkCard)
                            .cornerRadius(8)
                            .foregroundColor(WorkshopTheme.brightText)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Method Name")
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundColor(WorkshopTheme.subtleText)
                        TextField("Enter method name", text: $methodName)
                            .font(.system(size: 13, design: .monospaced))
                            .textFieldStyle(.plain)
                            .padding(10)
                            .background(WorkshopTheme.darkCard)
                            .cornerRadius(8)
                            .foregroundColor(WorkshopTheme.brightText)
                    }

                    Toggle("Class Method", isOn: $isClassMethod)
                        .font(.system(size: 12, design: .monospaced))
                        .tint(WorkshopTheme.neonGreen)
                }

                Section(header: Text("HOOK TYPE")) {
                    Picker("Hook Type", selection: $hookType) {
                        ForEach(HookType.allCases, id: \.self) { type in
                            Text(type.rawValue.capitalized)
                                .tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                    .tint(WorkshopTheme.neonGreen)
                }

                Section(header: Text("CALLBACK CODE")) {
                    TextEditor(text: $callbackCode)
                        .font(.system(size: 12, design: .monospaced))
                        .padding(10)
                        .background(WorkshopTheme.darkCard)
                        .cornerRadius(8)
                        .foregroundColor(WorkshopTheme.brightText)
                        .frame(minHeight: 120)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(WorkshopTheme.cardBorder, lineWidth: 1)
                        )
                }

                Section {
                    Button(action: onCreate) {
                        HStack(spacing: 6) {
                            Image(systemName: "plus.circle.fill")
                            Text("Create Hook")
                        }
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(WorkshopTheme.neonGreen)
                        .foregroundColor(.black)
                        .cornerRadius(8)
                    }
                    .disabled(className.isEmpty || methodName.isEmpty)
                }
            }
            .background(WorkshopTheme.deepBackground)
            .scrollContentBackground(.hidden)
            .navigationTitle("Create Hook")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        // Dismiss
                    }
                    .foregroundColor(WorkshopTheme.subtleText)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}
