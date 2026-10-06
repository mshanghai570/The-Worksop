//
//  Services/AIAgentService.swift
//  TheWorkshop-iOS
//  Interactive AI Agent Service for Binary Analysis and Smart Patching
//

import Foundation
import Combine

// MARK: - Agent Events

public enum AIAgentEvent {
    case messageReceived(AIAgentMessage)
    case messageUpdated(AIAgentMessage)
    case taskStarted(AIAgentTask)
    case taskCompleted(AIAgentTask)
    case taskFailed(AIAgentTask, Error)
    case stateChanged(AIAgentState)
    case suggestionsUpdated([SmartPatchSuggestion])
    case searchResultsUpdated([BinarySearchResult])
    case agentActivated
    case agentDeactivated
}

// MARK: - Agent Errors

public enum AIAgentError: Error {
    case agentNotConfigured
    case aiNotConfigured
    case noBinaryLoaded
    case invalidAction
    case noResultsFound
    case binaryAnalysisFailed
    case patchGenerationFailed
    case searchFailed
    case networkError(Error)
}

// MARK: - Agent Service

public class AIAgentService: ObservableObject {
    public static let shared = AIAgentService()

    @Published public private(set) var agents: [AIAgent] = []
    @Published public private(set) var activeAgent: AIAgent?
    @Published public private(set) var isProcessing: Bool = false
    @Published public private(set) var lastError: AIAgentError?
    @Published public private(set) var eventStream = PassthroughSubject<AIAgentEvent, Never>()

    private let aiService = AIService.shared
    private let binaryService = BinaryPatchingService.shared
    private var cancellables = Set<AnyCancellable>()

    public init() {
        // Create default agent
        createDefaultAgent()
    }

    // MARK: - Agent Management

    public func createDefaultAgent() -> AIAgent {
        let agent = AIAgent(
            configuration: AIAgentConfiguration(
                agentType: .reverseEngineer,
                name: "Reverse Engineering Agent",
                personality: """
                You are an expert iOS reverse engineer and binary analysis specialist.
                You help users analyze binaries, find functions, understand code, and create patches.
                Be precise, technical, and provide actionable insights.
                """,
                capabilities: [.analyzeBinary, .searchFunctions, .searchPatterns, .smartPatch, .generateHook, .explainCode, .findVulnerabilities, .suggestPatches, .disassembleRegion],
                temperature: 0.3,
                maxTokens: 4096,
                autoExecute: true,
                showReasoning: true
            )
        )
        
        agents.append(agent)
        activeAgent = agent
        return agent
    }

    public func createAgent(configuration: AIAgentConfiguration) -> AIAgent {
        let agent = AIAgent(configuration: configuration)
        agents.append(agent)
        
        if activeAgent == nil {
            activeAgent = agent
        }
        
        return agent
    }

    public func activateAgent(_ agentId: String) -> Bool {
        if let agent = agents.first(where: { $0.id == agentId }) {
            activeAgent = agent
            eventStream.send(.agentActivated)
            return true
        }
        return false
    }

    public func deactivateAgent() {
        activeAgent = nil
        eventStream.send(.agentDeactivated)
    }

    public func deleteAgent(_ agentId: String) -> Bool {
        if let index = agents.firstIndex(where: { $0.id == agentId }) {
            if activeAgent?.id == agentId {
                activeAgent = nil
            }
            agents.remove(at: index)
            return true
        }
        return false
    }

    public func updateAgentConfiguration(_ agentId: String, configuration: AIAgentConfiguration) -> Bool {
        if let index = agents.firstIndex(where: { $0.id == agentId }) {
            agents[index].configuration = configuration
            agents[index].updatedAt = Date()
            
            if activeAgent?.id == agentId {
                activeAgent?.configuration = configuration
                activeAgent?.updatedAt = Date()
            }
            
            return true
        }
        return false
    }

    // MARK: - Message Handling

    public func sendMessage(_ content: String, action: AIAgentAction? = nil, data: [String: Any]? = nil) async throws -> AIAgentMessage {
        guard let agent = activeAgent else {
            throw AIAgentError.agentNotConfigured
        }

        guard aiService.configuration.isConfigured else {
            throw AIAgentError.aiNotConfigured
        }

        isProcessing = true
        defer { isProcessing = false }

        // Create user message
        let userMessage = AIAgentMessage(
            type: .user,
            content: content,
            action: action
        )
        
        addMessage(userMessage, to: agent)
        
        // Handle actions
        if let action = action {
            let task = AIAgentTask(
                action: action,
                description: "Executing: \(action.rawValue)",
                parameters: data?.mapValues { AnyCodable($0) } ?? [:],
                state: .working
            )
            
            addTask(task, to: agent)
            eventStream.send(.taskStarted(task))
            
            do {
                let result = try await executeAction(action, parameters: data ?? [:], agent: agent)
                
                task.state = .success
                task.completedAt = Date()
                task.result = AnyCodable(result)
                
                updateTask(task, in: agent)
                eventStream.send(.taskCompleted(task))
                
                return userMessage
            } catch {
                task.state = .error
                task.completedAt = Date()
                task.error = error.localizedDescription
                
                updateTask(task, in: agent)
                eventStream.send(.taskFailed(task, error))
                
                throw error
            }
        } else {
            // Regular chat message
            let response = try await generateAgentResponse(for: content, agent: agent)
            return response
        }
    }

    private func executeAction(_ action: AIAgentAction, parameters: [String: Any], agent: AIAgent) async throws -> Any {
        switch action {
        case .analyzeBinary:
            return try await analyzeBinary(parameters: parameters)
        
        case .searchFunctions:
            return try await searchFunctions(parameters: parameters)
        
        case .searchPatterns:
            return try await searchPatterns(parameters: parameters)
        
        case .smartPatch:
            return try await smartPatch(parameters: parameters)
        
        case .generateHook:
            return try await generateHook(parameters: parameters)
        
        case .explainCode:
            return try await explainCode(parameters: parameters)
        
        case .findVulnerabilities:
            return try await findVulnerabilities(parameters: parameters)
        
        case .suggestPatches:
            return try await suggestPatches(parameters: parameters)
        
        case .disassembleRegion:
            return try await disassembleRegion(parameters: parameters)
        
        case .compareBinaries:
            return try await compareBinaries(parameters: parameters)
        
        case .extractStrings:
            return try await extractStrings(parameters: parameters)
        
        case .analyzeImports:
            return try await analyzeImports(parameters: parameters)
        
        case .findCrossReferences:
            return try await findCrossReferences(parameters: parameters)
        
        case .customCommand:
            return try await executeCustomCommand(parameters: parameters)
        }
    }

    // MARK: - Action Implementations

    private func analyzeBinary(parameters: [String: Any]) async throws -> [String: Any] {
        guard let binary = binaryService.loadedBinary else {
            throw AIAgentError.noBinaryLoaded
        }

        let systemPrompt = """
        You are an expert binary analyzer. Analyze the following iOS binary and provide:
        1. Architecture and file type
        2. Main entry points
        3. Interesting functions for reverse engineering
        4. Potential security concerns
        5. Suggested next steps for analysis
        
        Be thorough and technical.
        """

        let userPrompt = """
        Analyze this iOS binary:
        - Path: \(binary.path)
        - Architecture: \(binary.architecture.rawValue)
        - Functions: \(binary.functions.count)
        - Classes: \(binary.classes.count)
        - Symbols: \(binary.symbols.count)
        
        Functions:
        \(binary.functions.prefix(20).map { "- \($0.displayName) at 0x\(String(format: "%llX", $0.address))" }.joined(separator: "\n"))
        
        Classes:
        \(binary.classes.prefix(20).map { "- \($0)" }.joined(separator: "\n"))
        """

        let response = try await sendAgentMessage(systemPrompt: systemPrompt, userPrompt: userPrompt)
        
        return [
            "analysis": response,
            "binaryPath": binary.path,
            "architecture": binary.architecture.rawValue,
            "functionCount": binary.functions.count,
            "classCount": binary.classes.count
        ]
    }

    private func searchFunctions(parameters: [String: Any]) async throws -> [String: Any] {
        guard let binary = binaryService.loadedBinary else {
            throw AIAgentError.noBinaryLoaded
        }

        let query = parameters["query"] as? String ?? ""
        let useAI = parameters["useAI"] as? Bool ?? true

        if useAI && aiService.configuration.isConfigured {
            let systemPrompt = """
            You are an expert at finding functions in iOS binaries. 
            Search for functions matching the description and provide:
            - Function names
            - Addresses
            - Purpose
            - Cross-references
            """

            let userPrompt = """
            Search for functions matching: \(query)
            
            Available functions:
            \(binary.functions.map { "- \($0.displayName) at 0x\(String(format: "%llX", $0.address))" }.joined(separator: "\n"))
            """

            let response = try await sendAgentMessage(systemPrompt: systemPrompt, userPrompt: userPrompt)
            
            return [
                "query": query,
                "results": response,
                "matches": binaryService.searchFunctions(query: query).map { 
                    [
                        "name": $0.displayName,
                        "address": String(format: "%llX", $0.address),
                        "size": $0.size
                    ]
                }
            ]
        } else {
            let matches = binaryService.searchFunctions(query: query)
            return [
                "query": query,
                "matches": matches.map { 
                    [
                        "name": $0.displayName,
                        "address": String(format: "%llX", $0.address),
                        "size": $0.size
                    ]
                }
            ]
        }
    }

    private func searchPatterns(parameters: [String: Any]) async throws -> [String: Any] {
        guard let binary = binaryService.loadedBinary else {
            throw AIAgentError.noBinaryLoaded
        }

        let pattern = parameters["pattern"] as? String ?? ""
        let patternType = parameters["type"] as? String ?? "bytes"

        let systemPrompt = """
        You are an expert at pattern matching in binaries.
        Search for the following pattern and explain what it might be:
        """

        let userPrompt = """
        Search for pattern: \(pattern)
        Pattern type: \(patternType)
        
        Context: This is an iOS \(binary.architecture.rawValue) binary with \(binary.functions.count) functions.
        """

        let response = try await sendAgentMessage(systemPrompt: systemPrompt, userPrompt: userPrompt)
        
        return [
            "pattern": pattern,
            "type": patternType,
            "analysis": response,
            "suggestions": [
                "Try searching for cross-references to this pattern",
                "Check if this is part of a known library",
                "Look for similar patterns in the binary"
            ]
        ]
    }

    private func smartPatch(parameters: [String: Any]) async throws -> [String: Any] {
        guard let binary = binaryService.loadedBinary else {
            throw AIAgentError.noBinaryLoaded
        }

        let target = parameters["target"] as? String ?? ""
        let goal = parameters["goal"] as? String ?? ""
        let patchType = parameters["patchType"] as? String ?? ""

        let systemPrompt = """
        You are an expert iOS tweak developer. 
        Generate smart patch suggestions for the following target:
        
        Requirements:
        - Provide patch type (hook, inlineEdit, bytePatch, etc.)
        - Include confidence score (0.0-1.0)
        - Include risk level (low, medium, high, critical)
        - Provide complete patch code
        - Explain reasoning
        """

        let userPrompt = """
        Create a smart patch for:
        - Target: \(target)
        - Goal: \(goal)
        - Preferred patch type: \(patchType)
        
        Context:
        - Binary: \(binary.path)
        - Architecture: \(binary.architecture.rawValue)
        - Available functions: \(binary.functions.count)
        
        \(target.isEmpty ? "Find interesting functions to patch" : "Focus on the specified target")
        """

        let response = try await sendAgentMessage(systemPrompt: systemPrompt, userPrompt: userPrompt)
        
        // Parse suggestions from response
        let suggestions = parseSmartPatchSuggestions(from: response, target: target)
        
        // Store suggestions in active agent
        if let agent = activeAgent {
            var updatedAgent = agent
            updatedAgent.suggestions = suggestions
            activeAgent = updatedAgent
            
            if let index = agents.firstIndex(where: { $0.id == agent.id }) {
                agents[index] = updatedAgent
            }
            
            eventStream.send(.suggestionsUpdated(suggestions))
        }
        
        return [
            "target": target,
            "goal": goal,
            "suggestions": suggestions.map { 
                [
                    "title": $0.title,
                    "description": $0.description,
                    "patchType": $0.patchType.rawValue,
                    "confidence": $0.confidence,
                    "riskLevel": $0.riskLevel.rawValue,
                    "code": $0.code
                ]
            }
        ]
    }

    private func generateHook(parameters: [String: Any]) async throws -> [String: Any] {
        let className = parameters["className"] as? String ?? ""
        let methodName = parameters["methodName"] as? String ?? ""
        let hookType = parameters["hookType"] as? String ?? "before"
        let callback = parameters["callback"] as? String ?? ""

        let systemPrompt = """
        You are an expert at creating Cydia Substrate hooks.
        Generate a %hook block for the specified method with:
        - Proper Objective-C syntax
        - %orig call if needed
        - Memory safety
        - Error handling
        """

        let userPrompt = """
        Generate a hook for:
        - Class: \(className)
        - Method: \(methodName)
        - Hook type: \(hookType)
        - Custom callback: \(callback.isEmpty ? "None" : callback)
        
        \(callback.isEmpty ? "Generate a useful default callback" : "Use the specified callback code")
        """

        let response = try await sendAgentMessage(systemPrompt: systemPrompt, userPrompt: userPrompt)
        
        return [
            "className": className,
            "methodName": methodName,
            "hookType": hookType,
            "code": response
        ]
    }

    private func explainCode(parameters: [String: Any]) async throws -> [String: Any] {
        let code = parameters["code"] as? String ?? ""
        let address = parameters["address"] as? String ?? ""
        let context = parameters["context"] as? String ?? ""

        let systemPrompt = """
        You are an expert at explaining iOS binary code and assembly.
        Explain the following code in detail:
        - What it does
        - How it works
        - Potential vulnerabilities
        - Suggested modifications
        """

        let userPrompt = """
        Explain this code:
        
        \(code.isEmpty ? "Analyze the binary context" : "Code:\n\(code)")
        
        \(address.isEmpty ? "" : "Address: 0x\(address)")
        \(context.isEmpty ? "" : "Context: \(context)")
        """

        let response = try await sendAgentMessage(systemPrompt: systemPrompt, userPrompt: userPrompt)
        
        return [
            "code": code,
            "address": address,
            "explanation": response
        ]
    }

    private func findVulnerabilities(parameters: [String: Any]) async throws -> [String: Any] {
        guard let binary = binaryService.loadedBinary else {
            throw AIAgentError.noBinaryLoaded
        }

        let focusArea = parameters["focus"] as? String ?? "all"

        let systemPrompt = """
        You are a security researcher specializing in iOS binaries.
        Analyze the following binary for potential vulnerabilities:
        - Memory corruption issues
        - Insecure storage
        - Hardcoded secrets
        - Improper validation
        - Race conditions
        - Privilege escalation
        
        Provide:
        1. List of potential vulnerabilities
        2. Severity rating for each
        3. Recommended fixes
        4. Proof of concept if applicable
        """

        let userPrompt = """
        Find vulnerabilities in this iOS binary:
        - Path: \(binary.path)
        - Architecture: \(binary.architecture.rawValue)
        - Focus area: \(focusArea)
        
        Functions:
        \(binary.functions.prefix(30).map { "- \($0.displayName) at 0x\(String(format: "%llX", $0.address))" }.joined(separator: "\n"))
        """

        let response = try await sendAgentMessage(systemPrompt: systemPrompt, userPrompt: userPrompt)
        
        return [
            "focus": focusArea,
            "vulnerabilities": response
        ]
    }

    private func suggestPatches(parameters: [String: Any]) async throws -> [String: Any] {
        guard let binary = binaryService.loadedBinary else {
            throw AIAgentError.noBinaryLoaded
        }

        let goal = parameters["goal"] as? String ?? ""

        let systemPrompt = """
        You are an expert iOS tweak developer.
        Suggest patches to achieve the following goal:
        
        For each suggestion:
        - Patch type (hook, inlineEdit, bytePatch, etc.)
        - Target function/address
        - Patch code
        - Confidence score
        - Risk level
        - Reasoning
        """

        let userPrompt = """
        Suggest patches for: \(goal)
        
        Binary context:
        - Path: \(binary.path)
        - Architecture: \(binary.architecture.rawValue)
        - Functions: \(binary.functions.count)
        
        Available functions:
        \(binary.functions.prefix(20).map { "- \($0.displayName)" }.joined(separator: "\n"))
        """

        let response = try await sendAgentMessage(systemPrompt: systemPrompt, userPrompt: userPrompt)
        
        return [
            "goal": goal,
            "suggestions": response
        ]
    }

    private func disassembleRegion(parameters: [String: Any]) async throws -> [String: Any] {
        let address = parameters["address"] as? String ?? ""
        let size = parameters["size"] as? Int ?? 256
        let functionName = parameters["function"] as? String ?? ""

        let systemPrompt = """
        You are an expert ARM64 disassembler.
        Disassemble the following region and provide:
        - Assembly instructions
        - Control flow analysis
        - Interesting patterns
        - Potential optimizations
        """

        let addressValue = UInt64(address.replacingOccurrences(of: "0x", with: ""), radix: 16) ?? 0
        
        let userPrompt = """
        Disassemble region at 0x\(address) (\(size) bytes)
        \(functionName.isEmpty ? "" : "Function: \(functionName)")
        
        Provide:
        1. Assembly listing with addresses
        2. Control flow graph
        3. Interesting instructions
        4. Suggested patch points
        """

        let response = try await sendAgentMessage(systemPrompt: systemPrompt, userPrompt: userPrompt)
        
        // Also get actual disassembly if AI configured
        var disassembly: [Instruction] = []
        if aiService.configuration.isConfigured {
            do {
                disassembly = try await binaryService.disassembleFunction(at: addressValue, size: size)
            } catch {
                // Continue with AI response only
            }
        }
        
        return [
            "address": address,
            "size": size,
            "disassembly": response,
            "instructions": disassembly.map { 
                [
                    "address": String(format: "%llX", $0.address),
                    "mnemonic": $0.mnemonic,
                    "operands": $0.operands.joined(separator: ", "),
                    "bytes": $0.hexBytes,
                    "isBranch": $0.isBranch
                ]
            }
        ]
    }

    private func extractStrings(parameters: [String: Any]) async throws -> [String: Any] {
        guard let binary = binaryService.loadedBinary else {
            throw AIAgentError.noBinaryLoaded
        }

        let minLength = parameters["minLength"] as? Int ?? 4

        let systemPrompt = """
        You are analyzing strings in an iOS binary.
        Identify interesting strings that might contain:
        - URLs
        - API keys
        - Hardcoded credentials
        - File paths
        - Error messages
        - Configuration values
        
        Categorize and explain the purpose of each interesting string.
        """

        let userPrompt = """
        Extract and analyze strings from this binary:
        - Path: \(binary.path)
        - Minimum length: \(minLength)
        
        Focus on:
        - Security-sensitive strings
        - Configuration strings
        - Interesting URLs or paths
        """

        let response = try await sendAgentMessage(systemPrompt: systemPrompt, userPrompt: userPrompt)
        
        return [
            "minLength": minLength,
            "strings": response
        ]
    }

    private func analyzeImports(parameters: [String: Any]) async throws -> [String: Any] {
        guard let binary = binaryService.loadedBinary else {
            throw AIAgentError.noBinaryLoaded
        }

        let systemPrompt = """
        You are analyzing imports and dependencies in an iOS binary.
        Identify:
        - External libraries
        - Framework usage
        - Dynamic library loading
        - Interesting imports for reverse engineering
        """

        let userPrompt = """
        Analyze imports in this binary:
        - Path: \(binary.path)
        - Architecture: \(binary.architecture.rawValue)
        - Symbols: \(binary.symbols.count)
        
        Symbols:
        \(binary.symbols.prefix(50).joined(separator: "\n"))
        """

        let response = try await sendAgentMessage(systemPrompt: systemPrompt, userPrompt: userPrompt)
        
        return [
            "analysis": response,
            "symbolCount": binary.symbols.count
        ]
    }

    private func findCrossReferences(parameters: [String: Any]) async throws -> [String: Any] {
        guard let binary = binaryService.loadedBinary else {
            throw AIAgentError.noBinaryLoaded
        }

        let target = parameters["target"] as? String ?? ""
        let targetAddress = parameters["address"] as? String ?? ""

        let systemPrompt = """
        You are finding cross-references (XREFs) in a binary.
        Find all references to the target and explain:
        - Who calls this function
        - Who references this data
        - Call graph
        - Data flow
        """

        let userPrompt = """
        Find cross-references to: \(target)
        \(targetAddress.isEmpty ? "" : "Address: 0x\(targetAddress)")
        
        Binary context:
        - Path: \(binary.path)
        - Functions: \(binary.functions.count)
        
        Functions that might reference the target:
        \(binary.functions.prefix(30).map { "- \($0.displayName)" }.joined(separator: "\n"))
        """

        let response = try await sendAgentMessage(systemPrompt: systemPrompt, userPrompt: userPrompt)
        
        return [
            "target": target,
            "address": targetAddress,
            "crossReferences": response
        ]
    }

    private func executeCustomCommand(parameters: [String: Any]) async throws -> [String: Any] {
        let command = parameters["command"] as? String ?? ""
        
        let systemPrompt = """
        You are a reverse engineering assistant.
        Execute the following custom command and provide detailed results.
        """

        let userPrompt = "Custom command: \(command)"

        let response = try await sendAgentMessage(systemPrompt: systemPrompt, userPrompt: userPrompt)
        
        return [
            "command": command,
            "result": response
        ]
    }

    // MARK: - Helper Methods

    private func sendAgentMessage(systemPrompt: String, userPrompt: String) async throws -> String {
        guard aiService.configuration.isConfigured else {
            throw AIAgentError.aiNotConfigured
        }

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

    private func parseSmartPatchSuggestions(from response: String, target: String) -> [SmartPatchSuggestion] {
        var suggestions: [SmartPatchSuggestion] = []
        
        // Try to parse structured response
        if let data = response.data(using: .utf8) {
            do {
                struct SuggestionResponse: Codable {
                    let suggestions: [SuggestionItem]?
                    let patches: [SuggestionItem]?
                }
                
                struct SuggestionItem: Codable {
                    let title: String?
                    let description: String?
                    let patchType: String?
                    let targetAddress: String?
                    let targetFunction: String?
                    let confidence: Double?
                    let riskLevel: String?
                    let code: String?
                    let reasoning: String?
                }
                
                let decoded = try JSONDecoder().decode(SuggestionResponse.self, from: data)
                
                let items = decoded.suggestions ?? decoded.patches ?? []
                
                for item in items {
                    let patchType = AIService.PatchType(rawValue: item.patchType?.lowercased() ?? "") ?? .hook
                    let riskLevel = RiskLevel(rawValue: item.riskLevel?.capitalized ?? "") ?? .medium
                    let address = item.targetAddress != nil ? UInt64(item.targetAddress!.replacingOccurrences(of: "0x", with: ""), radix: 16) : nil
                    
                    suggestions.append(SmartPatchSuggestion(
                        title: item.title ?? "Suggestion",
                        description: item.description ?? "",
                        patchType: patchType,
                        targetAddress: address,
                        targetFunction: item.targetFunction,
                        confidence: item.confidence ?? 0.8,
                        riskLevel: riskLevel,
                        code: item.code ?? "",
                        reasoning: item.reasoning ?? ""
                    ))
                }
                
                if !suggestions.isEmpty {
                    return suggestions
                }
            } catch {
                // Continue to fallback parsing
            }
        }

        // Fallback: Parse from markdown/text
        let lines = response.components(separatedBy: .newlines)
        var currentSuggestion: SmartPatchSuggestion?
        
        for line in lines {
            if line.contains("Suggestion") || line.contains("Patch") || line.contains("Idea") {
                if let current = currentSuggestion {
                    suggestions.append(current)
                }
                currentSuggestion = SmartPatchSuggestion(
                    title: line,
                    description: "",
                    patchType: .hook,
                    confidence: 0.8,
                    code: "",
                    reasoning: ""
                )
            } else if let current = currentSuggestion {
                if line.contains("Type:") || line.contains("Patch Type:") {
                    let parts = line.components(separatedBy: ":")
                    if parts.count > 1 {
                        let typeString = parts[1].trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
                        current.patchType = AIService.PatchType(rawValue: typeString) ?? .hook
                    }
                } else if line.contains("Confidence:") {
                    let parts = line.components(separatedBy: ":")
                    if parts.count > 1 {
                        let confidenceString = parts[1].trimmingCharacters(in: .whitespacesAndNewlines)
                        current.confidence = Double(confidenceString) ?? 0.8
                    }
                } else if line.contains("Risk:") {
                    let parts = line.components(separatedBy: ":")
                    if parts.count > 1 {
                        let riskString = parts[1].trimmingCharacters(in: .whitespacesAndNewlines).capitalized
                        current.riskLevel = RiskLevel(rawValue: riskString) ?? .medium
                    }
                } else if line.contains("```") {
                    // Code block
                    if !current.code.isEmpty {
                        current.code = ""
                    }
                } else if !line.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    if current.code.isEmpty && (line.hasPrefix(" ") || line.hasPrefix("\t")) {
                        current.code = line
                    } else if !current.code.isEmpty {
                        current.code += "\n" + line
                    } else if current.description.isEmpty {
                        current.description = line
                    } else {
                        current.reasoning += (current.reasoning.isEmpty ? "" : "\n") + line
                    }
                }
            }
        }

        if let current = currentSuggestion {
            suggestions.append(current)
        }

        return suggestions
    }

    // MARK: - Message Management

    private func addMessage(_ message: AIAgentMessage, to agent: inout AIAgent) {
        var updatedAgent = agent
        updatedAgent.messages.append(message)
        updatedAgent.updatedAt = Date()
        agent = updatedAgent
        
        eventStream.send(.messageReceived(message))
    }

    private func addMessage(_ message: AIAgentMessage, to agent: AIAgent) {
        if var mutableAgent = agent {
            addMessage(message, to: &mutableAgent)
        }
    }

    private func addTask(_ task: AIAgentTask, to agent: inout AIAgent) {
        var updatedAgent = agent
        updatedAgent.tasks.append(task)
        updatedAgent.updatedAt = Date()
        agent = updatedAgent
    }

    private func addTask(_ task: AIAgentTask, to agent: AIAgent) {
        if var mutableAgent = agent {
            addTask(task, to: &mutableAgent)
        }
    }

    private func updateTask(_ task: AIAgentTask, in agent: inout AIAgent) {
        if let index = agent.tasks.firstIndex(where: { $0.id == task.id }) {
            var updatedAgent = agent
            updatedAgent.tasks[index] = task
            updatedAgent.updatedAt = Date()
            agent = updatedAgent
        }
    }

    private func updateTask(_ task: AIAgentTask, in agent: AIAgent) {
        if var mutableAgent = agent {
            updateTask(task, in: &mutableAgent)
        }
    }

    private func generateAgentResponse(for message: String, agent: AIAgent) async throws -> AIAgentMessage {
        let systemPrompt = """
        You are \(agent.configuration.name), a \(agent.configuration.agentType.displayName).
        \(agent.configuration.personality)
        
        Current context:
        - You are assisting with iOS binary reverse engineering
        - Be technical and precise
        - Provide actionable insights
        - Explain your reasoning
        """

        let messages = [
            AIChatMessage(role: "system", content: systemPrompt),
            AIChatMessage(role: "user", content: message)
        ]

        let response = try await aiService.sendChatMessage(messages: messages)
        
        guard let choice = response.choices.first else {
            throw AIError.invalidResponse
        }

        let agentMessage = AIAgentMessage(
            type: .agent,
            content: choice.message.content
        )
        
        addMessage(agentMessage, to: agent)
        
        return agentMessage
    }

    // MARK: - Smart Patch Application

    public func applySmartPatch(_ suggestionId: String) async throws -> PatchOperation {
        guard let agent = activeAgent else {
            throw AIAgentError.agentNotConfigured
        }

        guard let suggestion = agent.suggestions.first(where: { $0.id == suggestionId }) else {
            throw AIAgentError.invalidAction
        }

        let patch = try await binaryService.createPatch(
            for: suggestion.targetFunction ?? "unknown",
            patchType: suggestion.patchType,
            newCode: suggestion.code
        )

        // Mark suggestion as applied
        var updatedSuggestion = suggestion
        updatedSuggestion.isApplied = true
        
        var updatedAgent = agent
        if let index = updatedAgent.suggestions.firstIndex(where: { $0.id == suggestionId }) {
            updatedAgent.suggestions[index] = updatedSuggestion
        }
        activeAgent = updatedAgent
        
        if let index = agents.firstIndex(where: { $0.id == agent.id }) {
            agents[index] = updatedAgent
        }
        
        eventStream.send(.suggestionsUpdated(updatedAgent.suggestions))
        
        return patch
    }

    // MARK: - Search

    public func searchBinary(query: String, searchType: SearchType = .functionName) async throws -> BinarySearchResult {
        guard let binary = binaryService.loadedBinary else {
            throw AIAgentError.noBinaryLoaded
        }

        var matches: [BinaryMatch] = []
        
        switch searchType {
        case .functionName:
            let funcMatches = binaryService.searchFunctions(query: query)
            matches = funcMatches.map { 
                BinaryMatch(
                    address: $0.address,
                    name: $0.displayName,
                    type: .exact,
                    context: $0.methodSignature,
                    score: 1.0
                )
            }
        
        case .className:
            let classMatches = binaryService.searchClasses(query: query)
            matches = classMatches.map { 
                BinaryMatch(
                    address: 0,
                    name: $0,
                    type: .exact,
                    context: nil,
                    score: 1.0
                )
            }
        
        case .symbol:
            let symbolMatches = binaryService.searchSymbols(query: query)
            matches = symbolMatches.map { 
                BinaryMatch(
                    address: 0,
                    name: $0,
                    type: .exact,
                    context: nil,
                    score: 1.0
                )
            }
        
        case .string, .bytePattern, .crossReference, .signature:
            // Use AI for advanced search
            let systemPrompt = """
            You are searching a binary for patterns.
            Find matches for: \(query)
            Search type: \(searchType.rawValue)
            
            Provide matches as JSON:
            [
                {"address": 123456, "name": "match_name", "type": "exact", "context": "...", "score": 0.95}
            ]
            """

            let userPrompt = """
            Search binary for: \(query)
            Type: \(searchType.rawValue)
            
            Binary has \(binary.functions.count) functions and \(binary.symbols.count) symbols.
            """

            let response = try await sendAgentMessage(systemPrompt: systemPrompt, userPrompt: userPrompt)
            
            // Parse matches from response
            if let data = response.data(using: .utf8) {
                do {
                    let decodedMatches = try JSONDecoder().decode([BinaryMatch].self, from: data)
                    matches = decodedMatches
                } catch {
                    // Fallback: create match from response
                    matches = [BinaryMatch(
                        address: 0,
                        name: "AI Search Result",
                        type: .pattern,
                        context: response,
                        score: 0.8
                    )]
                }
            }
        }

        let result = BinarySearchResult(
            query: query,
            matches: matches,
            totalMatches: matches.count,
            searchType: searchType
        )

        if let agent = activeAgent {
            var updatedAgent = agent
            updatedAgent.searchResults.append(result)
            activeAgent = updatedAgent
            
            if let index = agents.firstIndex(where: { $0.id == agent.id }) {
                agents[index] = updatedAgent
            }
            
            eventStream.send(.searchResultsUpdated(updatedAgent.searchResults))
        }

        return result
    }

    // MARK: - Agent Control

    public func startAgentSession() {
        if let agent = activeAgent {
            var updatedAgent = agent
            updatedAgent.isActive = true
            updatedAgent.state = .idle
            updatedAgent.messages = []
            updatedAgent.tasks = []
            activeAgent = updatedAgent
            
            if let index = agents.firstIndex(where: { $0.id == agent.id }) {
                agents[index] = updatedAgent
            }
        }
    }

    public func endAgentSession() {
        if let agent = activeAgent {
            var updatedAgent = agent
            updatedAgent.isActive = false
            updatedAgent.state = .idle
            activeAgent = updatedAgent
            
            if let index = agents.firstIndex(where: { $0.id == agent.id }) {
                agents[index] = updatedAgent
            }
        }
    }

    public func clearAgentMessages() {
        if let agent = activeAgent {
            var updatedAgent = agent
            updatedAgent.messages = []
            activeAgent = updatedAgent
            
            if let index = agents.firstIndex(where: { $0.id == agent.id }) {
                agents[index] = updatedAgent
            }
        }
    }

    public func clearAgentTasks() {
        if let agent = activeAgent {
            var updatedAgent = agent
            updatedAgent.tasks = []
            activeAgent = updatedAgent
            
            if let index = agents.firstIndex(where: { $0.id == agent.id }) {
                agents[index] = updatedAgent
            }
        }
    }

    public func clearAllAgentData() {
        if let agent = activeAgent {
            var updatedAgent = agent
            updatedAgent.messages = []
            updatedAgent.tasks = []
            updatedAgent.suggestions = []
            updatedAgent.searchResults = []
            activeAgent = updatedAgent
            
            if let index = agents.firstIndex(where: { $0.id == agent.id }) {
                agents[index] = updatedAgent
            }
        }
    }
}
