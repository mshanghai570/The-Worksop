//
//  Services/GeminiAPIService.swift
//  TheWorkshop-iOS
//  AI Workshop Assistant Integration
//

import Foundation

public struct AIGeneratedBlocksResponse: Codable {
    public let explanation: String?
    public let blocks: [Block]?
}

public class GeminiAPIService {
    public static let shared = GeminiAPIService()

    private init() {}

    public func askWorkshopAI(prompt: String, project: Project) async throws -> String {
        // Simulates query to backend Gemini endpoint
        try await Task.sleep(nanoseconds: 800_000_000)

        if prompt.lowercased().contains("jailbreak") || prompt.lowercased().contains("jailed") {
            return """
            🛡️ **Jailbreak vs. Jailed Mod Capabilities**:
            
            1. **Jailbreak Tweaks (Theos/Substrate)**:
               - Hooks process memory directly using Objective-C runtime `%hook`.
               - Accesses system daemons like `SpringBoard`, `backboardd`, or system frameworks.
               - Unlimited runtime customization.
            
            2. **Jailed IPA Patching**:
               - Operates strictly inside sandboxed App Bundle boundaries.
               - Swaps resources (`Assets.car`, images, audio), modifies `Info.plist`, or injects dylibs via Azule/Sidestore.
               - No root privileges required.
            """
        }

        return "I can help you build Logos hooks or generate custom block layouts for \(project.name). Try asking to create a SpringBoard lockscreen hook!"
    }

    public func generateBlocks(prompt: String, project: Project) async throws -> AIGeneratedBlocksResponse {
        try await Task.sleep(nanoseconds: 1_200_000_000)

        let hookBlock = Block(
            type: .hook,
            x: 80,
            y: 80,
            targetClass: "SBLockScreenManager",
            targetMethod: "lockUIFromSource:withOptions:",
            returnType: "void",
            childrenBlockIds: ["block-delay-01"]
        )

        let delayBlock = Block(
            id: "block-delay-01",
            type: .delay,
            x: 80,
            y: 220,
            durationSeconds: 2.0,
            childrenBlockIds: ["block-log-01"]
        )

        let logBlock = Block(
            id: "block-log-01",
            type: .log,
            x: 80,
            y: 340,
            message: "Lockscreen triggered via AI hook node"
        )

        return AIGeneratedBlocksResponse(
            explanation: "Generated a 3-node hook chain for `SBLockScreenManager` with a 2-second delay and NSLog output.",
            blocks: [hookBlock, delayBlock, logBlock]
        )
    }
}
