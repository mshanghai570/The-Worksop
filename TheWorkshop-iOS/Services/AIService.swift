//
//  Services/AIService.swift
//  TheWorkshop-iOS
//  OpenAI-Compatible API Service with Model Discovery
//

import Foundation

public enum AIError: Error {
    case invalidEndpoint
    case authenticationFailed
    case modelNotFound
    case rateLimited
    case networkError(Error)
    case parsingError
    case invalidResponse
    case noModelsAvailable
    case functionPatchingError(String)
}

public struct AIChatMessage: Codable {
    public let role: String // "system", "user", "assistant"
    public let content: String

    public init(role: String, content: String) {
        self.role = role
        self.content = content
    }
}

public struct AIChatResponse: Codable {
    public let id: String
    public let model: String
    public let choices: [AIChatChoice]
    public let usage: AIUsage?

    public init(id: String, model: String, choices: [AIChatChoice], usage: AIUsage? = nil) {
        self.id = id
        self.model = model
        self.choices = choices
        self.usage = usage
    }
}

public struct AIChatChoice: Codable {
    public let message: AIChatMessage
    public let finishReason: String?

    public init(message: AIChatMessage, finishReason: String? = nil) {
        self.message = message
        self.finishReason = finishReason
    }
}

public struct AIUsage: Codable {
    public let promptTokens: Int
    public let completionTokens: Int
    public let totalTokens: Int

    public init(promptTokens: Int, completionTokens: Int, totalTokens: Int) {
        self.promptTokens = promptTokens
        self.completionTokens = completionTokens
        self.totalTokens = totalTokens
    }
}

public struct AIModelListResponse: Codable {
    public let data: [AIModelInfo]

    public init(data: [AIModelInfo]) {
        self.data = data
    }
}

public struct AIEmbeddingRequest: Codable {
    public let input: String
    public let model: String?

    public init(input: String, model: String? = nil) {
        self.input = input
        self.model = model
    }
}

public struct AIEmbeddingResponse: Codable {
    public let data: [AIEmbeddingData]
    public let model: String

    public init(data: [AIEmbeddingData], model: String) {
        self.data = data
        self.model = model
    }
}

public struct AIEmbeddingData: Codable {
    public let embedding: [Double]
    public let index: Int

    public init(embedding: [Double], index: Int) {
        self.embedding = embedding
        self.index = index
    }
}

// Function Patching Tool Models
public struct FunctionPatchRequest: Codable {
    public let functionName: String
    public let binaryPath: String
    public let patchType: PatchType
    public let newImplementation: String?
    public let hookBefore: Bool
    public let hookAfter: Bool
    public let context: String?

    public init(
        functionName: String,
        binaryPath: String,
        patchType: PatchType,
        newImplementation: String? = nil,
        hookBefore: Bool = true,
        hookAfter: Bool = true,
        context: String? = nil
    ) {
        self.functionName = functionName
        self.binaryPath = binaryPath
        self.patchType = patchType
        self.newImplementation = newImplementation
        self.hookBefore = hookBefore
        self.hookAfter = hookAfter
        self.context = context
    }
}

public enum PatchType: String, Codable {
    case hook
    case replace
    case bypass
    case log
    case modifyReturn
}

public struct FunctionPatchResponse: Codable {
    public let success: Bool
    public let patchedFunction: String
    public let patchCode: String
    public let warnings: [String]
    public let errors: [String]

    public init(
        success: Bool,
        patchedFunction: String,
        patchCode: String,
        warnings: [String] = [],
        errors: [String] = []
    ) {
        self.success = success
        self.patchedFunction = patchedFunction
        self.patchCode = patchCode
        self.warnings = warnings
        self.errors = errors
    }
}

public class AIService: ObservableObject {
    public static let shared = AIService()

    @Published public private(set) var configuration: AIConfiguration
    @Published public private(set) var isLoadingModels: Bool = false
    @Published public private(set) var isGenerating: Bool = false
    @Published public private(set) var lastError: AIError?
    @Published public private(set) var lastResponse: String?

    private let session: URLSession
    private let userDefaultsKey = "aiConfiguration"

    public init(configuration: AIConfiguration? = nil) {
        if let config = configuration {
            self.configuration = config
        } else {
            self.configuration = AIService.loadConfiguration() ?? AIConfiguration()
        }
        self.session = URLSession(configuration: .default)
    }

    // MARK: - Configuration Management

    public func updateConfiguration(_ newConfig: AIConfiguration) {
        configuration = newConfig
        AIService.saveConfiguration(newConfig)
    }

    public func updateEndpoint(_ url: String) {
        configuration.endpointURL = url
        AIService.saveConfiguration(configuration)
    }

    public func updateAPIKey(_ key: String) {
        configuration.apiKey = key
        AIService.saveConfiguration(configuration)
    }

    public func selectModel(_ modelId: String) {
        configuration.selectedModelId = modelId
        AIService.saveConfiguration(configuration)
    }

    public func updateSettings(
        timeout: TimeInterval? = nil,
        maxTokens: Int? = nil,
        temperature: Double? = nil
    ) {
        if let timeout = timeout {
            configuration.timeoutSeconds = timeout
        }
        if let maxTokens = maxTokens {
            configuration.maxTokens = maxTokens
        }
        if let temperature = temperature {
            configuration.temperature = temperature
        }
        AIService.saveConfiguration(configuration)
    }

    private static func saveConfiguration(_ config: AIConfiguration) {
        if let encoded = try? JSONEncoder().encode(config) {
            UserDefaults.standard.set(encoded, forKey: "aiConfiguration")
        }
    }

    private static func loadConfiguration() -> AIConfiguration? {
        if let data = UserDefaults.standard.data(forKey: "aiConfiguration"),
           let config = try? JSONDecoder().decode(AIConfiguration.self, from: data) {
            return config
        }
        return nil
    }

    // MARK: - Model Discovery

    public func fetchAvailableModels() async throws -> [AIModelInfo] {
        guard configuration.isConfigured else {
            throw AIError.invalidEndpoint
        }

        isLoadingModels = true
        defer { isLoadingModels = false }

        let endpoint = configuration.endpointURL
        var urlComponents = URLComponents(string: endpoint)
        
        // Handle different API formats
        let modelsPath: String
        if endpoint.hasSuffix("/v1") || endpoint.contains("/v1/") {
            modelsPath = "/models"
        } else if endpoint.hasSuffix("/api") || endpoint.contains("/api/") {
            modelsPath = "/v1/models"
        } else {
            modelsPath = "/models"
        }
        
        urlComponents?.path = modelsPath

        guard let url = urlComponents?.url else {
            throw AIError.invalidEndpoint
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(configuration.apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw AIError.networkError(URLError(.badServerResponse))
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                if httpResponse.statusCode == 401 {
                    throw AIError.authenticationFailed
                } else if httpResponse.statusCode == 429 {
                    throw AIError.rateLimited
                }
                throw AIError.networkError(URLError(.badServerResponse))
            }

            // Parse response - handle different formats
            let models = try parseModelListResponse(data: data)
            
            // Update configuration with fetched models
            var newConfig = configuration
            newConfig.availableModels = models
            if !models.isEmpty && newConfig.selectedModelId.isEmpty {
                newConfig.selectedModelId = models[0].id
            }
            updateConfiguration(newConfig)
            
            return models
            
        } catch let error as AIError {
            lastError = error
            throw error
        } catch {
            lastError = .networkError(error)
            throw AIError.networkError(error)
        }
    }

    private func parseModelListResponse(data: Data) throws -> [AIModelInfo] {
        // Try standard OpenAI format first
        if let response = try? JSONDecoder().decode(AIModelListResponse.self, from: data) {
            return response.data
        }

        // Try alternative format where models are directly in the response
        if let models = try? JSONDecoder().decode([AIModelInfo].self, from: data) {
            return models
        }

        // Try format with "models" key
        struct ModelsWrapper: Codable {
            let models: [AIModelInfo]
        }
        if let wrapper = try? JSONDecoder().decode(ModelsWrapper.self, from: data) {
            return wrapper.models
        }

        // Try format with "data" as array
        struct DataWrapper: Codable {
            let data: [[String: Any]]
        }
        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let dataArray = json["data"] as? [[String: Any]] {
            var models: [AIModelInfo] = []
            for item in dataArray {
                let id = item["id"] as? String ?? ""
                let name = item["name"] as? String ?? item["id"] as? String ?? ""
                let description = item["description"] as? String
                let contextLength = item["context_length"] as? Int
                let supportsFunctionCalling = item["supports_function_calling"] as? Bool
                let supportsStreaming = item["supports_streaming"] as? Bool
                
                models.append(AIModelInfo(
                    id: id,
                    name: name,
                    description: description,
                    contextLength: contextLength,
                    supportsFunctionCalling: supportsFunctionCalling,
                    supportsStreaming: supportsStreaming
                ))
            }
            return models
        }

        throw AIError.parsingError
    }

    // MARK: - Chat Completion

    public func sendChatMessage(
        messages: [AIChatMessage],
        modelId: String? = nil,
        temperature: Double? = nil,
        maxTokens: Int? = nil
    ) async throws -> AIChatResponse {
        guard configuration.isConfigured else {
            throw AIError.invalidEndpoint
        }

        guard let modelId = modelId ?? configuration.selectedModelId, !modelId.isEmpty else {
            throw AIError.modelNotFound
        }

        isGenerating = true
        defer { isGenerating = false }

        let endpoint = configuration.endpointURL
        var urlComponents = URLComponents(string: endpoint)
        
        let chatPath: String
        if endpoint.hasSuffix("/v1") || endpoint.contains("/v1/") {
            chatPath = "/chat/completions"
        } else if endpoint.hasSuffix("/api") || endpoint.contains("/api/") {
            chatPath = "/v1/chat/completions"
        } else {
            chatPath = "/chat/completions"
        }
        
        urlComponents?.path = chatPath

        guard let url = urlComponents?.url else {
            throw AIError.invalidEndpoint
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(configuration.apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let requestBody: [String: Any] = [
            "model": modelId,
            "messages": messages.map { ["role": $0.role, "content": $0.content] },
            "temperature": temperature ?? configuration.temperature,
            "max_tokens": maxTokens ?? configuration.maxTokens,
            "stream": false
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)

        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw AIError.networkError(URLError(.badServerResponse))
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                if httpResponse.statusCode == 401 {
                    throw AIError.authenticationFailed
                } else if httpResponse.statusCode == 429 {
                    throw AIError.rateLimited
                }
                throw AIError.networkError(URLError(.badServerResponse))
            }

            let response = try JSONDecoder().decode(AIChatResponse.self, from: data)
            lastResponse = response.choices.first?.message.content
            return response
            
        } catch let error as AIError {
            lastError = error
            throw error
        } catch {
            lastError = .networkError(error)
            throw AIError.networkError(error)
        }
    }

    // MARK: - Function Patching

    public func generateFunctionPatch(
        functionName: String,
        binaryPath: String,
        patchType: PatchType,
        newImplementation: String? = nil,
        hookBefore: Bool = true,
        hookAfter: Bool = true,
        context: String? = nil
    ) async throws -> FunctionPatchResponse {
        guard configuration.isConfigured else {
            throw AIError.invalidEndpoint
        }

        isGenerating = true
        defer { isGenerating = false }

        let modelId = configuration.selectedModelId
        guard !modelId.isEmpty else {
            throw AIError.modelNotFound
        }

        // Build prompt for function patching
        let systemPrompt = """
        You are an expert iOS reverse engineer and tweak developer. 
        Generate Logos syntax code for patching iOS binaries. 
        Use %hook, %orig, and proper Objective-C syntax.
        Always include memory safety checks and avoid retain cycles.
        """

        let userPrompt = """
        Generate a Logos tweak patch for the following function:
        
        Function: \(functionName)
        Binary: \(binaryPath)
        Patch Type: \(patchType.rawValue)
        
        Context: \(context ?? "No additional context")
        
        Requirements:
        - Hook before execution: \(hookBefore ? "YES" : "NO")
        - Hook after execution: \(hookAfter ? "YES" : "NO")
        
        \(newImplementation != nil ? "New implementation: \n\(newImplementation!)" : "")
        
        Generate complete %hook block with proper error handling.
        """

        let messages = [
            AIChatMessage(role: "system", content: systemPrompt),
            AIChatMessage(role: "user", content: userPrompt)
        ]

        let response = try await sendChatMessage(messages: messages)
        
        guard let choice = response.choices.first else {
            throw AIError.invalidResponse
        }

        let patchCode = choice.message.content
        
        // Parse the response and create a structured patch
        return FunctionPatchResponse(
            success: true,
            patchedFunction: functionName,
            patchCode: patchCode,
            warnings: extractWarnings(from: patchCode),
            errors: []
        )
    }

    public func generatePatchForLoadedBinary(
        binaryPath: String,
        functionNames: [String],
        patchType: PatchType = .hook,
        context: String? = nil
    ) async throws -> [FunctionPatchResponse] {
        var results: [FunctionPatchResponse] = []
        
        for functionName in functionNames {
            do {
                let patch = try await generateFunctionPatch(
                    functionName: functionName,
                    binaryPath: binaryPath,
                    patchType: patchType,
                    context: context
                )
                results.append(patch)
            } catch {
                results.append(FunctionPatchResponse(
                    success: false,
                    patchedFunction: functionName,
                    patchCode: "",
                    warnings: [],
                    errors: ["Failed to generate patch: \(error.localizedDescription)"]
                ))
            }
        }
        
        return results
    }

    private func extractWarnings(from patchCode: String) -> [String] {
        var warnings: [String] = []
        
        // Check for common issues in generated code
        if !patchCode.contains("%orig") && patchCode.contains("%hook") {
            warnings.append("No %orig call found - this may override original functionality")
        }
        
        if patchCode.contains("retain") || patchCode.contains("strong") {
            warnings.append("Check for potential retain cycles")
        }
        
        if patchCode.contains("dispatch_sync(dispatch_get_main_queue()") {
            warnings.append("Potential deadlock: dispatch_sync on main queue")
        }
        
        return warnings
    }

    // MARK: - Helper Methods

    public func testConnection() async throws -> Bool {
        guard configuration.isConfigured else {
            return false
        }

        do {
            let models = try await fetchAvailableModels()
            return !models.isEmpty
        } catch {
            return false
        }
    }

    public func clearConfiguration() {
        configuration = AIConfiguration()
        AIService.saveConfiguration(configuration)
    }

    public func clearLastError() {
        lastError = nil
    }

    public func clearLastResponse() {
        lastResponse = nil
    }
}
