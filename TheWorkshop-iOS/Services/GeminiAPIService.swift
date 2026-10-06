//
//  Services/GeminiAPIService.swift
//  TheWorkshop-iOS
//  Legacy AI Workshop Assistant Integration (now uses AIService)
//

import Foundation

public struct AIGeneratedBlocksResponse: Codable {
    public let explanation: String?
    public let blocks: [Block]?
}

public class GeminiAPIService {
    public static let shared = GeminiAPIService()

    private let aiService = AIService.shared
    private let binaryPatchingService = BinaryPatchingService.shared

    private init() {}

    public func askWorkshopAI(prompt: String, project: Project) async throws -> String {
        // Check if AI is configured
        guard aiService.configuration.isConfigured else {
            return "AI provider not configured. Please set up your OpenAI-compatible endpoint in Settings > AI Configuration."
        }

        let systemPrompt = """
        You are an experienced iOS reverse engineer and tweak developer.
        Help the user with The Workshop, a visual reverse engineering tool for iPhone.
        Provide guidance on:
        - Logos syntax and Theos tweak development
        - Hooking Objective-C methods
        - Binary patching techniques
        - Memory safety in tweaks
        - Debugging and troubleshooting
        
        Be concise and provide actionable advice.
        """

        let userPrompt = """
        User Question: \(prompt)
        
        Current Project: \(project.name)
        Target Type: \(project.projectType.displayName)
        Target Process: \(project.targetProcess)
        
        Current Blocks on Canvas:
        \(project.blocks.map { "- \($0.type.rawValue): \($0.targetClass ?? $0.targetMethod ?? $0.message ?? "")" }.joined(separator: "\n"))
        """

        let messages = [
            AIChatMessage(role: "system", content: systemPrompt),
            AIChatMessage(role: "user", content: userPrompt)
        ]

        let response = try await aiService.sendChatMessage(messages: messages)
        
        guard let choice = response.choices.first else {
            return "No response from AI provider."
        }

        return choice.message.content
    }

    public func generateBlocks(prompt: String, project: Project) async throws -> AIGeneratedBlocksResponse {
        // Check if AI is configured
        guard aiService.configuration.isConfigured else {
            return AIGeneratedBlocksResponse(
                explanation: "AI provider not configured",
                blocks: []
            )
        }

        let systemPrompt = """
        You are an expert iOS tweak developer. Generate visual block layouts for The Workshop.
        Each block should have a type and configuration properties.
        
        Available block types:
        - hook: Objective-C method hook
        - orig: Call original implementation
        - log: Console log message
        - modifyProperty: Set property value
        - conditional: If condition
        - delay: Thread delay
        - notification: Show HUD banner
        - returnValue: Override return value
        - customLogos: Raw Logos code
        - replaceAsset: Replace IPA asset
        - editPlist: Modify Info.plist
        - swiftuiView: Native SwiftUI view
        
        Respond with JSON format:
        {
            "explanation": "Brief description of generated blocks",
            "blocks": [
                {
                    "type": "hook",
                    "targetClass": "ClassName",
                    "targetMethod": "methodName",
                    "returnType": "void",
                    "x": 100,
                    "y": 100
                }
            ]
        }
        """

        let userPrompt = """
        Generate blocks for: \(prompt)
        
        Current Project: \(project.name)
        Target Type: \(project.projectType.displayName)
        """

        let messages = [
            AIChatMessage(role: "system", content: systemPrompt),
            AIChatMessage(role: "user", content: userPrompt)
        ]

        let response = try await aiService.sendChatMessage(messages: messages)
        
        guard let choice = response.choices.first else {
            return AIGeneratedBlocksResponse(explanation: "No response", blocks: [])
        }

        // Try to parse the response
        let jsonString = choice.message.content
        
        if let data = jsonString.data(using: .utf8) {
            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(AIGeneratedBlocksResponse.self, from: data)
                return response
            } catch {
                // Return fallback
                return AIGeneratedBlocksResponse(
                    explanation: choice.message.content,
                    blocks: []
                )
            }
        }

        return AIGeneratedBlocksResponse(
            explanation: choice.message.content,
            blocks: []
        )
    }

    // MARK: - Function Patching Methods

    public func generateFunctionPatch(
        functionName: String,
        binaryPath: String,
        patchType: PatchType,
        newImplementation: String? = nil,
        hookBefore: Bool = true,
        hookAfter: Bool = true,
        context: String? = nil
    ) async throws -> FunctionPatchResponse {
        try await binaryPatchingService.generatePatch(
            for: functionName,
            patchType: patchType,
            newCode: newImplementation
        )
    }

    public func analyzeBinary(at path: String) async throws -> BinaryInfo {
        try await binaryPatchingService.loadBinary(at: path)
        return binaryPatchingService.loadedBinary!
    }

    public func searchFunctions(query: String) -> [BinaryFunction] {
        binaryPatchingService.searchFunctions(query: query)
    }

    public func getLoadedBinary() -> BinaryInfo? {
        binaryPatchingService.loadedBinary
    }

    public func generateLogosCodeForPatches() -> String {
        binaryPatchingService.generateLogosCode()
    }
}
