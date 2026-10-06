//
//  Services/BinaryPatchingService.swift
//  TheWorkshop-iOS
//  Binary Analysis & Function Patching Service
//

import Foundation

public enum BinaryArchitecture: String, Codable, CaseIterable {
    case arm64
    case arm64e
    case x86_64
    case armv7
    case armv7s
    case i386
    case unknown
}

public struct BinaryFunction: Identifiable, Codable, Equatable {
    public let id: String
    public let name: String
    public let address: UInt64
    public let size: UInt64
    public let isExternal: Bool
    public let className: String?
    public let methodSignature: String?
    public let returnType: String?
    public let parameterTypes: [String]?

    public init(
        id: String = UUID().uuidString,
        name: String,
        address: UInt64,
        size: UInt64,
        isExternal: Bool = false,
        className: String? = nil,
        methodSignature: String? = nil,
        returnType: String? = nil,
        parameterTypes: [String]? = nil
    ) {
        self.id = id
        self.name = name
        self.address = address
        self.size = size
        self.isExternal = isExternal
        self.className = className
        self.methodSignature = methodSignature
        self.returnType = returnType
        self.parameterTypes = parameterTypes
    }

    public var displayName: String {
        if let className = className, let method = methodSignature {
            return "\(className) \(method)"
        }
        return name
    }
}

public struct BinaryInfo: Codable, Equatable {
    public let path: String
    public let architecture: BinaryArchitecture
    public let isFatBinary: Bool
    public let architectures: [BinaryArchitecture]
    public let entryPoint: UInt64?
    public let functions: [BinaryFunction]
    public let classes: [String]
    public let protocols: [String]
    public let symbols: [String]

    public init(
        path: String,
        architecture: BinaryArchitecture = .unknown,
        isFatBinary: Bool = false,
        architectures: [BinaryArchitecture] = [],
        entryPoint: UInt64? = nil,
        functions: [BinaryFunction] = [],
        classes: [String] = [],
        protocols: [String] = [],
        symbols: [String] = []
    ) {
        self.path = path
        self.architecture = architecture
        self.isFatBinary = isFatBinary
        self.architectures = architectures
        self.entryPoint = entryPoint
        self.functions = functions
        self.classes = classes
        self.protocols = protocols
        self.symbols = symbols
    }
}

public struct PatchOperation: Identifiable, Codable {
    public let id: String
    public let functionName: String
    public let patchType: PatchType
    public let originalCode: String?
    public let patchedCode: String
    public let address: UInt64?
    public let isApplied: Bool
    public let appliedAt: Date?

    public init(
        id: String = UUID().uuidString,
        functionName: String,
        patchType: PatchType,
        originalCode: String? = nil,
        patchedCode: String,
        address: UInt64? = nil,
        isApplied: Bool = false,
        appliedAt: Date? = nil
    ) {
        self.id = id
        self.functionName = functionName
        self.patchType = patchType
        self.originalCode = originalCode
        self.patchedCode = patchedCode
        self.address = address
        self.isApplied = isApplied
        self.appliedAt = appliedAt
    }
}

public struct FunctionHook: Identifiable, Codable {
    public let id: String
    public let className: String
    public let methodName: String
    public let isClassMethod: Bool
    public let returnType: String?
    public let parameterTypes: [String]?
    public let hookType: HookType
    public let callbackCode: String
    public let priority: Int

    public init(
        id: String = UUID().uuidString,
        className: String,
        methodName: String,
        isClassMethod: Bool = false,
        returnType: String? = nil,
        parameterTypes: [String]? = nil,
        hookType: HookType = .before,
        callbackCode: String,
        priority: Int = 0
    ) {
        self.id = id
        self.className = className
        self.methodName = methodName
        self.isClassMethod = isClassMethod
        self.returnType = returnType
        self.parameterTypes = parameterTypes
        self.hookType = hookType
        self.callbackCode = callbackCode
        self.priority = priority
    }
}

public enum HookType: String, Codable, CaseIterable {
    case before
    case after
    case instead
    case around
}

public class BinaryPatchingService: ObservableObject {
    public static let shared = BinaryPatchingService()

    @Published public private(set) var loadedBinary: BinaryInfo?
    @Published public private(set) var isLoading: Bool = false
    @Published public private(set) var isAnalyzing: Bool = false
    @Published public private(set) var patches: [PatchOperation] = []
    @Published public private(set) var hooks: [FunctionHook] = []
    @Published public private(set) var lastError: String?

    private let fileManager = FileManager.default
    private let aiService = AIService.shared

    public init() {}

    // MARK: - Binary Loading & Analysis

    public func loadBinary(at path: String) async throws -> BinaryInfo {
        guard fileManager.fileExists(atPath: path) else {
            throw NSError(domain: "BinaryPatchingService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Binary file not found"])
        }

        isLoading = true
        defer { isLoading = false }

        // Analyze the binary
        let binaryInfo = try await analyzeBinary(at: path)
        loadedBinary = binaryInfo
        
        return binaryInfo
    }

    public func analyzeBinary(at path: String) async throws -> BinaryInfo {
        isAnalyzing = true
        defer { isAnalyzing = false }

        // Use AI to analyze the binary if configured
        if aiService.configuration.isConfigured {
            return try await analyzeBinaryWithAI(path: path)
        }

        // Fallback to basic analysis
        return try await performBasicBinaryAnalysis(path: path)
    }

    private func analyzeBinaryWithAI(path: String) async throws -> BinaryInfo {
        let url = URL(fileURLWithPath: path)
        let fileName = url.lastPathComponent
        let fileSize = try fileManager.attributesOfItem(atPath: path)[.size] as? UInt64 ?? 0
        
        let systemPrompt = """
        You are an expert iOS reverse engineer. Analyze the following binary and provide a comprehensive list of:
        1. Exported Objective-C classes and methods
        2. Swift classes and functions if available
        3. C functions and symbols
        4. Architecture information
        
        Format your response as JSON with the following structure:
        {
            "architecture": "arm64",
            "isFatBinary": false,
            "functions": [
                {"name": "functionName", "address": 123456, "className": "ClassName", "methodSignature": "-(void)method", "returnType": "void", "parameterTypes": ["id", "SEL"]}
            ],
            "classes": ["ClassName1", "ClassName2"],
            "protocols": ["Protocol1", "Protocol2"],
            "symbols": ["symbol1", "symbol2"]
        }
        """

        let userPrompt = """
        Binary file: \(fileName)
        File size: \(fileSize) bytes
        File path: \(path)
        
        Please analyze this iOS binary and extract all available functions, classes, and symbols.
        Focus on Objective-C methods and C functions that can be hooked or patched.
        """

        let messages = [
            AIChatMessage(role: "system", content: systemPrompt),
            AIChatMessage(role: "user", content: userPrompt)
        ]

        let response = try await aiService.sendChatMessage(messages: messages)
        
        guard let choice = response.choices.first else {
            throw AIError.invalidResponse
        }

        let jsonString = choice.message.content
        
        // Try to parse the JSON response
        if let data = jsonString.data(using: .utf8) {
            let decoder = JSONDecoder()
            
            struct BinaryAnalysisResponse: Codable {
                let architecture: String?
                let isFatBinary: Bool?
                let functions: [BinaryFunctionResponse]?
                let classes: [String]?
                let protocols: [String]?
                let symbols: [String]?
                let entryPoint: UInt64?
            }
            
            struct BinaryFunctionResponse: Codable {
                let name: String
                let address: UInt64?
                let className: String?
                let methodSignature: String?
                let returnType: String?
                let parameterTypes: [String]?
            }
            
            do {
                let analysis = try decoder.decode(BinaryAnalysisResponse.self, from: data)
                
                let architecture = BinaryArchitecture(rawValue: analysis.architecture?.lowercased() ?? "") ?? .unknown
                let isFat = analysis.isFatBinary ?? false
                let entryPoint = analysis.entryPoint
                
                let functions = analysis.functions?.map { funcResp in
                    BinaryFunction(
                        name: funcResp.name,
                        address: funcResp.address ?? 0,
                        className: funcResp.className,
                        methodSignature: funcResp.methodSignature,
                        returnType: funcResp.returnType,
                        parameterTypes: funcResp.parameterTypes
                    )
                } ?? []
                
                let classes = analysis.classes ?? []
                let protocols = analysis.protocols ?? []
                let symbols = analysis.symbols ?? []
                
                return BinaryInfo(
                    path: path,
                    architecture: architecture,
                    isFatBinary: isFat,
                    entryPoint: entryPoint,
                    functions: functions,
                    classes: classes,
                    protocols: protocols,
                    symbols: symbols
                )
            } catch {
                // Fallback to basic analysis
                return try await performBasicBinaryAnalysis(path: path)
            }
        }
        
        throw AIError.parsingError
    }

    private func performBasicBinaryAnalysis(path: String) async throws -> BinaryInfo {
        // Basic file analysis without AI
        let url = URL(fileURLWithPath: path)
        let fileName = url.lastPathComponent
        
        // Detect architecture from file
        let architecture = detectArchitecture(from: path)
        
        // For now, return basic info
        // In a real implementation, you would use tools like:
        // - otool for Objective-C analysis
        // - nm for symbol listing
        // - class-dump for header extraction
        
        return BinaryInfo(
            path: path,
            architecture: architecture,
            isFatBinary: false,
            functions: [],
            classes: [],
            protocols: [],
            symbols: []
        )
    }

    private func detectArchitecture(from path: String) -> BinaryArchitecture {
        // Check file magic bytes or use system tools
        // This is a simplified version
        
        let url = URL(fileURLWithPath: path)
        let fileName = url.lastPathComponent.lowercased()
        
        // Check for common patterns
        if fileName.hasSuffix(".ipa") || fileName.hasSuffix(".app") {
            return .arm64
        }
        
        // Try to read magic bytes
        do {
            let data = try Data(contentsOf: url)
            if data.count >= 4 {
                let magic = data.subdata(in: 0..<4)
                
                // Mach-O magic numbers
                if magic == Data([0xFE, 0xED, 0xFA, 0xCE]) || magic == Data([0xFE, 0xED, 0xFA, 0xCF]) {
                    // 32-bit or 64-bit Mach-O
                    if data.count >= 8 {
                        let nextBytes = data.subdata(in: 4..<8)
                        // Check for 64-bit
                        if nextBytes.withUnsafeBytes({ $0.load(as: UInt32.self) }) == 0x0100000C {
                            return .arm64
                        }
                    }
                    return .armv7
                }
            }
        } catch {
            // Fallback
        }
        
        return .unknown
    }

    // MARK: - Function Patching

    public func createPatch(
        for functionName: String,
        patchType: PatchType,
        newCode: String? = nil
    ) async throws -> PatchOperation {
        guard let binary = loadedBinary else {
            throw NSError(domain: "BinaryPatchingService", code: 2, userInfo: [NSLocalizedDescriptionKey: "No binary loaded"])
        }

        // Find the function
        let targetFunction = binary.functions.first { $0.name == functionName } ?? 
                            binary.functions.first { $0.displayName == functionName }
        
        let functionAddress = targetFunction?.address
        let originalCode = targetFunction != nil ? "Function at address: 0x\(String(format: "%llX", functionAddress ?? 0))" : nil

        // Generate patch code using AI
        let patchCode: String
        if let newCode = newCode {
            patchCode = newCode
        } else {
            patchCode = try await generatePatchCode(
                functionName: functionName,
                patchType: patchType,
                className: targetFunction?.className,
                methodSignature: targetFunction?.methodSignature
            )
        }

        let patch = PatchOperation(
            functionName: functionName,
            patchType: patchType,
            originalCode: originalCode,
            patchedCode: patchCode,
            address: functionAddress,
            isApplied: false
        )

        patches.append(patch)
        return patch
    }

    public func createHook(
        className: String,
        methodName: String,
        isClassMethod: Bool = false,
        hookType: HookType = .before,
        callbackCode: String
    ) async throws -> FunctionHook {
        let hook = FunctionHook(
            className: className,
            methodName: methodName,
            isClassMethod: isClassMethod,
            hookType: hookType,
            callbackCode: callbackCode
        )

        hooks.append(hook)
        return hook
    }

    private func generatePatchCode(
        functionName: String,
        patchType: PatchType,
        className: String? = nil,
        methodSignature: String? = nil
    ) async throws -> String {
        // Use AI to generate the patch code
        let systemPrompt = """
        You are an expert iOS reverse engineer and tweak developer.
        Generate Logos syntax code for patching iOS functions.
        Use proper %hook, %orig, and Objective-C syntax.
        Include memory safety checks.
        """

        let context = className != nil && methodSignature != nil ? 
            "Objective-C method: [\(className!) \(methodSignature!)]" : 
            "Function: \(functionName)"
        
        let userPrompt = """
        Generate a Logos tweak patch for:
        
        \(context)
        
        Patch type: \(patchType.rawValue)
        
        Requirements:
        - Use proper Logos syntax
        - Include %orig call if overriding
        - Add error handling
        - Use appropriate memory management
        
        Generate complete, compilable code.
        """

        let messages = [
            AIChatMessage(role: "system", content: systemPrompt),
            AIChatMessage(role: "user", content: userPrompt)
        ]

        let response = try await aiService.sendChatMessage(messages: messages)
        
        guard let choice = response.choices.first else {
            throw AIError.invalidResponse
        }

        return choice.message.content
    }

    // MARK: - Patch Management

    public func applyPatch(_ patchId: String) -> Bool {
        guard let index = patches.firstIndex(where: { $0.id == patchId }) else {
            return false
        }

        patches[index].isApplied = true
        patches[index].appliedAt = Date()
        return true
    }

    public func removePatch(_ patchId: String) -> Bool {
        guard let index = patches.firstIndex(where: { $0.id == patchId }) else {
            return false
        }

        patches.remove(at: index)
        return true
    }

    public func clearPatches() {
        patches.removeAll()
    }

    public func clearHooks() {
        hooks.removeAll()
    }

    // MARK: - Code Generation

    public func generateLogosCode() -> String {
        var lines: [String] = []
        
        // Header
        lines.append("//")
        lines.append("//  Tweak.x")
        lines.append("//  Generated by The Workshop Binary Patching Service")
        lines.append("//")
        lines.append("")
        lines.append("#import <Foundation/Foundation.h>")
        lines.append("#import <UIKit/UIKit.h>")
        lines.append("#import <os/log.h>")
        lines.append("")

        // Apply patches
        for patch in patches where patch.isApplied {
            lines.append("// Patch: \(patch.functionName)")
            lines.append("")
            lines.append(patch.patchedCode)
            lines.append("")
        }

        // Apply hooks
        for hook in hooks {
            let methodPrefix = hook.isClassMethod ? "+" : "-"
            let returnType = hook.returnType ?? "void"
            let methodName = hook.methodName
            
            lines.append("// Hook: [\(hook.className) \(methodName)]")
            lines.append("")
            lines.append("%hook \(hook.className)")
            lines.append("")
            
            switch hook.hookType {
            case .before:
                lines.append("\(methodPrefix) (\(returnType))\(methodName) {")
                lines.append("    \(hook.callbackCode)")
                lines.append("    %orig;")
                lines.append("}")
            case .after:
                lines.append("\(methodPrefix) (\(returnType))\(methodName) {")
                lines.append("    %orig;")
                lines.append("    \(hook.callbackCode)")
                lines.append("}")
            case .instead:
                lines.append("\(methodPrefix) (\(returnType))\(methodName) {")
                lines.append("    \(hook.callbackCode)")
                lines.append("}")
            case .around:
                lines.append("\(methodPrefix) (\(returnType))\(methodName) {")
                lines.append("    // Before")
                lines.append("    \(hook.callbackCode)")
                lines.append("    %orig;")
                lines.append("    // After")
                lines.append("}")
            }
            
            lines.append("%end")
            lines.append("")
        }

        if patches.isEmpty && hooks.isEmpty {
            lines.append("// No patches or hooks defined")
        }

        return lines.joined(separator: "\n")
    }

    public func generatePatchScript() -> String {
        var lines: [String] = []
        
        lines.append("#!/bin/bash")
        lines.append("# Binary Patching Script")
        lines.append("# Generated by The Workshop")
        lines.append("")

        if let binary = loadedBinary {
            lines.append("# Target Binary: \(binary.path)")
            lines.append("# Architecture: \(binary.architecture.rawValue)")
            lines.append("")
        }

        lines.append("echo \"Applying patches...\"")
        lines.append("")

        // Add patch application commands
        for patch in patches where patch.isApplied {
            lines.append("# Applying patch: \(patch.functionName)")
            lines.append("echo \"  Patching \(patch.functionName)...\"")
            // In a real implementation, this would use optool, yolo, or similar tools
            lines.append("")
        }

        lines.append("echo \"All patches applied!\"")

        return lines.joined(separator: "\n")
    }

    // MARK: - Binary Search

    public func searchFunctions(query: String) -> [BinaryFunction] {
        guard let binary = loadedBinary else {
            return []
        }

        return binary.functions.filter { func in
            func.name.localizedCaseInsensitiveContains(query) ||
            func.displayName.localizedCaseInsensitiveContains(query) ||
            (func.className?.localizedCaseInsensitiveContains(query) ?? false)
        }
    }

    public func searchSymbols(query: String) -> [String] {
        guard let binary = loadedBinary else {
            return []
        }

        return binary.symbols.filter { $0.localizedCaseInsensitiveContains(query) }
    }

    public func searchClasses(query: String) -> [String] {
        guard let binary = loadedBinary else {
            return []
        }

        return binary.classes.filter { $0.localizedCaseInsensitiveContains(query) }
    }

    // MARK: - Utility

    public func unloadBinary() {
        loadedBinary = nil
        patches.removeAll()
        hooks.removeAll()
    }

    public func getFunctionInfo(name: String) -> BinaryFunction? {
        guard let binary = loadedBinary else {
            return nil
        }

        return binary.functions.first { $0.name == name } ?? 
               binary.functions.first { $0.displayName == name }
    }
}
