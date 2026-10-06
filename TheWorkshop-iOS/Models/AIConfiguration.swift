//
//  Models/AIConfiguration.swift
//  TheWorkshop-iOS
//  OpenAI-Compatible Endpoint Configuration
//

import Foundation

public struct AIModelInfo: Identifiable, Codable, Equatable {
    public let id: String
    public let name: String
    public let description: String?
    public let contextLength: Int?
    public let supportsFunctionCalling: Bool?
    public let supportsStreaming: Bool?

    public init(
        id: String,
        name: String,
        description: String? = nil,
        contextLength: Int? = nil,
        supportsFunctionCalling: Bool? = nil,
        supportsStreaming: Bool? = nil
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.contextLength = contextLength
        self.supportsFunctionCalling = supportsFunctionCalling
        self.supportsStreaming = supportsStreaming
    }
}

public struct AIConfiguration: Codable, Equatable {
    public var isEnabled: Bool
    public var endpointURL: String
    public var apiKey: String
    public var selectedModelId: String
    public var availableModels: [AIModelInfo]
    public var timeoutSeconds: TimeInterval
    public var maxTokens: Int
    public var temperature: Double

    public init(
        isEnabled: Bool = false,
        endpointURL: String = "https://api.openai.com/v1",
        apiKey: String = "",
        selectedModelId: String = "",
        availableModels: [AIModelInfo] = [],
        timeoutSeconds: TimeInterval = 60,
        maxTokens: Int = 4096,
        temperature: Double = 0.7
    ) {
        self.isEnabled = isEnabled
        self.endpointURL = endpointURL
        self.apiKey = apiKey
        self.selectedModelId = selectedModelId
        self.availableModels = availableModels
        self.timeoutSeconds = timeoutSeconds
        self.maxTokens = maxTokens
        self.temperature = temperature
    }

    public var selectedModel: AIModelInfo? {
        availableModels.first { $0.id == selectedModelId }
    }

    public var isConfigured: Bool {
        !endpointURL.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
