//
//  Views/Binary/BinaryPatcherView.swift
//  TheWorkshop-iOS
//  Binary Loading & Function Patching Interface with Inline Edits and Byte Patching
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
    @State private var selectedPatchType: AIService.PatchType = .hook
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
    
    // Inline Edit State
    @State private var showInlineEditCreator: Bool = false
    @State private var inlineEditAddress: String = ""
    @State private var inlineEditOriginalBytes: String = ""
    @State private var inlineEditNewBytes: String = ""
    @State private var inlineEditLabel: String = ""
    @State private var inlineEditMode: AIService.PatchMode = .absolute
    
    // Byte Patch State
    @State private var showBytePatchCreator: Bool = false
    @State private var bytePatchAddress: String = ""
    @State private var bytePatchOperation: AIService.BytePatchOperation = .replace
    @State private var bytePatchOperand: String = ""
    @State private var bytePatchValue: String = ""
    @State private var bytePatchSize: String = "1"
    @State private var bytePatchLabel: String = ""
    
    // Disassembly State
    @State private var showDisassembly: Bool = false
    @State private var disassemblyInstructions: [Instruction] = []
    @State private var selectedInstruction: Instruction?
    @State private var isDisassembling: Bool = false

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
                    
                    if binaryService.isLoading || binaryService.isAnalyzing || isDisassembling {
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
                        
                        // Action Buttons
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                Button(action: { showHookCreator = true }) {
                                    HStack(spacing: 4) {
                                        Image(systemName: "plus")
                                        Text("Hook")
                                    }
                                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(WorkshopTheme.cyberCyan)
                                    .foregroundColor(.black)
                                    .cornerRadius(6)
                                }

                                Button(action: { showInlineEditCreator = true }) {
                                    HStack(spacing: 4) {
                                        Image(systemName: "pencil")
                                        Text("Inline Edit")
                                    }
                                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(WorkshopTheme.hotPink)
                                    .foregroundColor(.white)
                                    .cornerRadius(6)
                                }

                                Button(action: { showBytePatchCreator = true }) {
                                    HStack(spacing: 4) {
                                        Image(systemName: "hexagon.fill")
                                        Text("Byte Patch")
                                    }
                                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(WorkshopTheme.warningYellow)
                                    .foregroundColor(.black)
                                    .cornerRadius(6)
                                }

                                Button(action: disassembleSelectedFunction) {
                                    HStack(spacing: 4) {
                                        Image(systemName: "list.bullet.rectangle.fill")
                                        Text("Disassemble")
                                    }
                                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(WorkshopTheme.neonGreen)
                                    .foregroundColor(.black)
                                    .cornerRadius(6)
                                }
                                .disabled(selectedFunction == nil)

                                Button(action: { showPatchDetail = false; selectedPatch = nil }) {
                                    HStack(spacing: 4) {
                                        Image(systemName: "list.bullet")
                                        Text("Patches")
                                    }
                                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(WorkshopTheme.darkCard)
                                    .foregroundColor(WorkshopTheme.brightText)
                                    .cornerRadius(6)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 6)
                                            .stroke(WorkshopTheme.cardBorder, lineWidth: 1)
                                    )
                                }
                            }
                        }
                        
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
                        showSearchResults(in: binary)
                    } else if let binary = binaryService.loadedBinary {
                        // Show all functions when no search
                        showAllContent(in: binary)
                    } else {
                        // Empty state
                        showEmptyState()
                    }
                }
            }
            .background(WorkshopTheme.deepBackground)
            .navigationTitle("Binary Patcher")
            .navigationBarTitleDisplayMode(.inline)
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
            handleFileImport(result: result)
        }
        
        // Sheets
        .sheet(item: $selectedPatch) { patch in
            PatchDetailView(patch: patch)
        }
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
        .sheet(isPresented: $showInlineEditCreator) {
            InlineEditCreatorView(
                address: $inlineEditAddress,
                originalBytes: $inlineEditOriginalBytes,
                newBytes: $inlineEditNewBytes,
                label: $inlineEditLabel,
                mode: $inlineEditMode,
                onCreate: createInlineEdit
            )
        }
        .sheet(isPresented: $showBytePatchCreator) {
            BytePatchCreatorView(
                address: $bytePatchAddress,
                operation: $bytePatchOperation,
                operand: $bytePatchOperand,
                value: $bytePatchValue,
                size: $bytePatchSize,
                label: $bytePatchLabel,
                onCreate: createBytePatch
            )
        }
        .sheet(isPresented: $showDisassembly) {
            DisassemblyView(
                instructions: disassemblyInstructions,
                selectedInstruction: $selectedInstruction,
                onPatchAtAddress: { address in
                    bytePatchAddress = String(format: "%llX", address)
                    showBytePatchCreator = true
                    showDisassembly = false
                }
            )
        }
    }

    // MARK: - View Builders

    @ViewBuilder
    private func showSearchResults(in binary: BinaryInfo) -> some View {
        ScrollView {
            if let selectedFunction = selectedFunction {
                FunctionDetailView(
                    function: selectedFunction,
                    onPatch: { patchType, code in
                        selectedPatchType = patchType
                        customPatchCode = code
                        createPatch()
                    },
                    onDisassemble: disassembleSelectedFunction,
                    onCancel: { selectedFunction = nil }
                )
                .padding(12)
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    // Function Results
                    if !binaryService.searchFunctions(query: searchQuery).isEmpty {
                        showSection(title: "Functions", color: WorkshopTheme.neonGreen) {
                            ForEach(binaryService.searchFunctions(query: searchQuery)) { func in
                                FunctionRow(
                                    function: func,
                                    isSelected: selectedFunction?.id == func.id,
                                    onSelect: { selectedFunction = func }
                                )
                            }
                        }
                    }

                    // Class Results
                    if !binaryService.searchClasses(query: searchQuery).isEmpty {
                        showSection(title: "Classes", color: WorkshopTheme.cyberCyan) {
                            ForEach(binaryService.searchClasses(query: searchQuery), id: \.self) { className in
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

                    // Symbol Results
                    if !binaryService.searchSymbols(query: searchQuery).isEmpty {
                        showSection(title: "Symbols", color: WorkshopTheme.hotPink) {
                            ForEach(binaryService.searchSymbols(query: searchQuery), id: \.self) { symbol in
                                SymbolRow(symbol: symbol)
                            }
                        }
                    }

                    if allEmpty() {
                        showEmptySearchResults()
                    }
                }
                .padding(.vertical, 12)
            }
        }
    }

    @ViewBuilder
    private func showAllContent(in binary: BinaryInfo) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                if !binary.classes.isEmpty {
                    showSection(title: "Classes", color: WorkshopTheme.cyberCyan) {
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
                }

                if !binary.functions.isEmpty {
                    showSection(title: "Functions", color: WorkshopTheme.neonGreen) {
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
                }

                if binary.functions.isEmpty && binary.classes.isEmpty {
                    showEmptyBinary()
                }
            }
            .padding(.vertical, 12)
        }
    }

    @ViewBuilder
    private func showEmptyState() -> some View {
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

    @ViewBuilder
    private func showEmptySearchResults() -> some View {
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

    @ViewBuilder
    private func showEmptyBinary() -> some View {
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

    @ViewBuilder
    private func showSection<Content: View>(title: String, color: Color, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundColor(color)
                .padding(.horizontal, 12)
            
            content()
                .padding(.horizontal, 12)
        }
    }

    // MARK: - Helper Methods

    private func allEmpty() -> Bool {
        binaryService.searchFunctions(query: searchQuery).isEmpty &&
        binaryService.searchClasses(query: searchQuery).isEmpty &&
        binaryService.searchSymbols(query: searchQuery).isEmpty
    }

    private func handleFileImport(result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            if let url = urls.first {
                Task {
                    do {
                        try await binaryService.loadBinary(at: url.path)
                    } catch {
                        print("Error loading binary: \(error)")
                    }
                }
            }
        case .failure(let error):
            print("Error importing: \(error)")
        }
    }

    private func loadSampleBinary() {
        Task {
            let sampleFunctions = [
                BinaryFunction(
                    id: UUID().uuidString,
                    name: "lockUIFromSource:withOptions:",
                    address: 0x100004000,
                    size: 256,
                    className: "SBLockScreenManager",
                    methodSignature: "-(void)lockUIFromSource:(long long)arg1 withOptions:(id)arg2",
                    returnType: "void",
                    parameterTypes: ["long long", "id"]
                ),
                BinaryFunction(
                    id: UUID().uuidString,
                    name: "applicationDidFinishLaunching:",
                    address: 0x100005000,
                    size: 128,
                    className: "SBApplication",
                    methodSignature: "-(BOOL)applicationDidFinishLaunching:(id)arg1",
                    returnType: "BOOL",
                    parameterTypes: ["id"]
                ),
                BinaryFunction(
                    id: UUID().uuidString,
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
        disassemblyInstructions = []
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
                print("Error creating patch: \(error)")
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
                resetHookCreator()
                showHookCreator = false
                
            } catch {
                print("Error creating hook: \(error)")
            }
        }
    }

    private func resetHookCreator() {
        hookClassName = ""
        hookMethodName = ""
        hookCallbackCode = "NSLog(@\"Hook executed\");"
        isClassMethod = false
        hookType = .before
    }

    private func createInlineEdit() {
        let addressValue = UInt64(inlineEditAddress.replacingOccurrences(of: "0x", with: ""), radix: 16) ?? 0
        let originalBytesData = Data(hexString: inlineEditOriginalBytes) ?? Data()
        let newBytesData = Data(hexString: inlineEditNewBytes) ?? Data()
        
        if !newBytesData.isEmpty {
            let edit = binaryService.createInlineEdit(
                address: addressValue,
                originalBytes: originalBytesData,
                newBytes: newBytesData,
                patchMode: inlineEditMode,
                label: inlineEditLabel.isEmpty ? nil : inlineEditLabel
            )
            
            // Clear and close
            resetInlineEditCreator()
            showInlineEditCreator = false
        }
    }

    private func resetInlineEditCreator() {
        inlineEditAddress = ""
        inlineEditOriginalBytes = ""
        inlineEditNewBytes = ""
        inlineEditLabel = ""
        inlineEditMode = .absolute
    }

    private func createBytePatch() {
        let addressValue = UInt64(bytePatchAddress.replacingOccurrences(of: "0x", with: ""), radix: 16) ?? 0
        let operandData = bytePatchOperand.isEmpty ? nil : Data(hexString: bytePatchOperand)
        let valueValue = bytePatchValue.isEmpty ? nil : UInt64(bytePatchValue, radix: 16)
        let sizeValue = Int(bytePatchSize) ?? 1
        
        let patch = binaryService.createBytePatch(
            address: addressValue,
            operation: bytePatchOperation,
            operand: operandData,
            value: valueValue,
            size: sizeValue,
            label: bytePatchLabel.isEmpty ? nil : bytePatchLabel
        )
        
        // Clear and close
        resetBytePatchCreator()
        showBytePatchCreator = false
    }

    private func resetBytePatchCreator() {
        bytePatchAddress = ""
        bytePatchOperand = ""
        bytePatchValue = ""
        bytePatchSize = "1"
        bytePatchLabel = ""
    }

    private func disassembleSelectedFunction() {
        guard let funcToDisassemble = selectedFunction else { return }
        
        isDisassembling = true
        Task {
            do {
                disassemblyInstructions = try await binaryService.disassembleFunction(funcToDisassemble)
                showDisassembly = true
            } catch {
                print("Error disassembling: \(error)")
            }
            isDisassembling = false
        }
    }
}
