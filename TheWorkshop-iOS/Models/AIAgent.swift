//
//  Models/AIAgent.swift
//  TheWorkshop-iOS
//  Interactive AI Agent Model with State and Capabilities
//

import Foundation

// MARK: - Agent Types

public enum AIAgentType: String, Codable, CaseIterable, Identifiable {
    case reverseEngineer = "Reverse Engineer"
    case patchExpert = "Patch Expert"
    case securityResearcher = "Security Researcher"
    case tweakDeveloper = "Tweak Developer"
    case binaryAnalyzer = "Binary Analyzer"
    case custom = "Custom"

    public var id: String { rawValue }

    public var displayName: String { rawValue }

    public var description: String {
        switch self {
        case .reverseEngineer: return "Specializes in analyzing and understanding binary code"
        case .patchExpert: return "Expert at creating patches and modifications"
        case .securityResearcher: return "Focuses on finding vulnerabilities and security issues"
        case .tweakDeveloper: return "Specializes in iOS tweak development with Logos"
        case .binaryAnalyzer: return "Deep binary analysis and pattern recognition"
        case .custom: return "Custom agent with user-defined personality"
        }
    }

    public var iconName: String {
        switch self {
        case .reverseEngineer: return "person.fill.viewfinder"
        case .patchExpert: return "wrench.and.screwdriver.fill"
        case .securityResearcher: return "shield.fill"
        case .tweakDeveloper: return "hammer.fill"
        case .binaryAnalyzer: return "binarycoding"
        case .custom: return "person.fill"
        }
    }

    public var color: ColorRepresentable {
        switch self {
        case .reverseEngineer: return HexColor(red: 0.22, green: 1.0, blue: 0.08) // Neon Green
        case .patchExpert: return HexColor(red: 1.0, green: 0.0, blue: 0.5) // Hot Pink
        case .securityResearcher: return HexColor(red: 0.0, green: 0.9, blue: 1.0) // Cyber Cyan
        case .tweakDeveloper: return HexColor(red: 1.0, green: 0.8, blue: 0.0) // Warning Yellow
        case .binaryAnalyzer: return HexColor(red: 0.5, green: 0.3, blue: 1.0) // Purple
        case .custom: return HexColor(red: 0.6, green: 0.6, blue: 0.6) // Gray
        }
    }
}

// MARK: - Agent Message Types

public enum AIAgentMessageType: String, Codable {
    case system
    case user
    case agent
    case action
    case result
    case error
    case thinking
}

// MARK: - Agent Actions

public enum AIAgentAction: String, Codable {
    case analyzeBinary
    case searchFunctions
    case searchPatterns
    case smartPatch
    case generateHook
    case explainCode
    case findVulnerabilities
    case suggestPatches
    case disassembleRegion
    case compareBinaries
    case extractStrings
    case analyzeImports
    case findCrossReferences
    case customCommand
}

// MARK: - Agent State

public enum AIAgentState: String, Codable {
    case idle
    case thinking
    case working
    case waiting
    case error
    case success
}

// MARK: - Color Representable

public protocol ColorRepresentable {
    var red: Double { get }
    var green: Double { get }
    var blue: Double { get }
    var alpha: Double { get }
}

public struct HexColor: ColorRepresentable, Codable {
    public let red: Double
    public let green: Double
    public let blue: Double
    public let alpha: Double

    public init(red: Double, green: Double, blue: Double, alpha: Double = 1.0) {
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
    }
}

// MARK: - Agent Message

public struct AIAgentMessage: Identifiable, Codable {
    public let id: String
    public let type: AIAgentMessageType
    public let content: String
    public let timestamp: Date
    public let action: AIAgentAction?
    public let data: [String: AnyCodable]?
    public let isStreaming: Bool

    public init(
        id: String = UUID().uuidString,
        type: AIAgentMessageType,
        content: String,
        timestamp: Date = Date(),
        action: AIAgentAction? = nil,
        data: [String: AnyCodable]? = nil,
        isStreaming: Bool = false
    ) {
        self.id = id
        self.type = type
        self.content = content
        self.timestamp = timestamp
        self.action = action
        self.data = data
        self.isStreaming = isStreaming
    }
}

// MARK: - Agent Task

public struct AIAgentTask: Identifiable, Codable {
    public let id: String
    public let action: AIAgentAction
    public let description: String
    public let parameters: [String: AnyCodable]
    public let state: AIAgentState
    public let createdAt: Date
    public let completedAt: Date?
    public let result: AnyCodable?
    public let error: String?

    public init(
        id: String = UUID().uuidString,
        action: AIAgentAction,
        description: String,
        parameters: [String: AnyCodable] = [:],
        state: AIAgentState = .idle,
        createdAt: Date = Date(),
        completedAt: Date? = nil,
        result: AnyCodable? = nil,
        error: String? = nil
    ) {
        self.id = id
        self.action = action
        self.description = description
        self.parameters = parameters
        self.state = state
        self.createdAt = createdAt
        self.completedAt = completedAt
        self.result = result
        self.error = error
    }
}

// MARK: - Smart Patch Suggestion

public struct SmartPatchSuggestion: Identifiable, Codable {
    public let id: String
    public let title: String
    public let description: String
    public let patchType: AIService.PatchType
    public let targetAddress: UInt64?
    public let targetFunction: String?
    public let confidence: Double // 0.0 - 1.0
    public let riskLevel: RiskLevel
    public let code: String
    public let reasoning: String
    public let isApplied: Bool

    public init(
        id: String = UUID().uuidString,
        title: String,
        description: String,
        patchType: AIService.PatchType,
        targetAddress: UInt64? = nil,
        targetFunction: String? = nil,
        confidence: Double = 0.8,
        riskLevel: RiskLevel = .medium,
        code: String,
        reasoning: String,
        isApplied: Bool = false
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.patchType = patchType
        self.targetAddress = targetAddress
        self.targetFunction = targetFunction
        self.confidence = confidence
        self.riskLevel = riskLevel
        self.code = code
        self.reasoning = reasoning
        self.isApplied = isApplied
    }
}

public enum RiskLevel: String, Codable, CaseIterable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
    case critical = "Critical"

    public var color: HexColor {
        switch self {
        case .low: return HexColor(red: 0.0, green: 1.0, blue: 0.0)
        case .medium: return HexColor(red: 1.0, green: 0.8, blue: 0.0)
        case .high: return HexColor(red: 1.0, green: 0.5, blue: 0.0)
        case .critical: return HexColor(red: 1.0, green: 0.0, blue: 0.0)
        }
    }
}

// MARK: - Search Result

public struct BinarySearchResult: Identifiable, Codable {
    public let id: String
    public let query: String
    public let matches: [BinaryMatch]
    public let totalMatches: Int
    public let searchType: SearchType

    public init(
        id: String = UUID().uuidString,
        query: String,
        matches: [BinaryMatch] = [],
        totalMatches: Int = 0,
        searchType: SearchType = .functionName
    ) {
        self.id = id
        self.query = query
        self.matches = matches
        self.totalMatches = totalMatches
        self.searchType = searchType
    }
}

public enum SearchType: String, Codable, CaseIterable {
    case functionName
    case className
    case symbol
    case string
    case bytePattern
    case crossReference
    case signature
}

public struct BinaryMatch: Identifiable, Codable {
    public let id: String
    public let address: UInt64
    public let name: String
    public let type: MatchType
    public let context: String?
    public let score: Double

    public init(
        id: String = UUID().uuidString,
        address: UInt64,
        name: String,
        type: MatchType,
        context: String? = nil,
        score: Double = 1.0
    ) {
        self.id = id
        self.address = address
        self.name = name
        self.type = type
        self.context = context
        self.score = score
    }
}

public enum MatchType: String, Codable {
    case exact
    case partial
    case fuzzy
    case pattern
}

// MARK: - AnyCodable for flexible data storage

public struct AnyCodable: Codable {
    public let value: Any

    public init<T>(_ value: T) {
        self.value = value
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let string = try? container.decode(String.self) {
            self.value = string
        } else if let int = try? container.decode(Int.self) {
            self.value = int
        } else if let double = try? container.decode(Double.self) {
            self.value = double
        } else if let bool = try? container.decode(Bool.self) {
            self.value = bool
        } else if let array = try? container.decode([AnyCodable].self) {
            self.value = array.map { $0.value }
        } else if let dict = try? container.decode([String: AnyCodable].self) {
            self.value = dict.mapValues { $0.value }
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Value cannot be decoded")
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        switch value {
        case let string as String:
            try container.encode(string)
        case let int as Int:
            try container.encode(int)
        case let double as Double:
            try container.encode(double)
        case let bool as Bool:
            try container.encode(bool)
        case let array as [Any]:
            try container.encode(array.map { AnyCodable($0) })
        case let dict as [String: Any]:
            try container.encode(dict.mapValues { AnyCodable($0) })
        default:
            throw EncodingError.invalidValue(value, EncodingError.Context(codingPath: container.codingPath, debugDescription: "Value cannot be encoded"))
        }
    }
}

// MARK: - Agent Configuration

public struct AIAgentConfiguration: Codable {
    public var agentType: AIAgentType
    public var name: String
    public var personality: String
    public var capabilities: [AIAgentAction]
    public var temperature: Double
    public var maxTokens: Int
    public var autoExecute: Bool
    public var showReasoning: Bool

    public init(
        agentType: AIAgentType = .reverseEngineer,
        name: String = "Agent",
        personality: String = "Helpful and knowledgeable reverse engineering assistant",
        capabilities: [AIAgentAction] = AIAgentAction.allCases,
        temperature: Double = 0.7,
        maxTokens: Int = 4096,
        autoExecute: Bool = true,
        showReasoning: Bool = true
    ) {
        self.agentType = agentType
        self.name = name
        self.personality = personality
        self.capabilities = capabilities
        self.temperature = temperature
        self.maxTokens = maxTokens
        self.autoExecute = autoExecute
        self.showReasoning = showReasoning
    }
}

// MARK: - Main Agent Model

public struct AIAgent: Identifiable, Codable {
    public let id: String
    public var configuration: AIAgentConfiguration
    public var messages: [AIAgentMessage]
    public var tasks: [AIAgentTask]
    public var suggestions: [SmartPatchSuggestion]
    public var searchResults: [BinarySearchResult]
    public var state: AIAgentState
    public var isActive: Bool
    public var createdAt: Date
    public var updatedAt: Date

    public init(
        id: String = UUID().uuidString,
        configuration: AIAgentConfiguration = AIAgentConfiguration(),
        messages: [AIAgentMessage] = [],
        tasks: [AIAgentTask] = [],
        suggestions: [SmartPatchSuggestion] = [],
        searchResults: [BinarySearchResult] = [],
        state: AIAgentState = .idle,
        isActive: Bool = false,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.configuration = configuration
        self.messages = messages
        self.tasks = tasks
        self.suggestions = suggestions
        self.searchResults = searchResults
        self.state = state
        self.isActive = isActive
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    public var lastMessage: AIAgentMessage? {
        messages.last
    }

    public var activeTask: AIAgentTask? {
        tasks.first { $0.state == .working || $0.state == .thinking }
    }
}
