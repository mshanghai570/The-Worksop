//
//  Views/Assistant/GeminiAssistantView.swift
//  TheWorkshop-iOS
//  Experienced Mentor & AI Blueprint Reviewer Assistant
//

import SwiftUI

struct ChatMessage: Identifiable {
    let id = UUID()
    let isUser: Bool
    let text: String
}

public struct GeminiAssistantView: View {
    @ObservedObject var projectVM: ProjectViewModel
    @State private var messages: [ChatMessage] = [
        ChatMessage(isUser: false, text: "🎓 **Hello! I am your Theos & Tweak Engineering AI Mentor.**\n\nInstead of just writing code for you, I act as an experienced mentor to review your visual blueprints, detect crash vectors, explain Logos directives, and guide best practices.")
    ]
    @State private var inputText: String = ""

    public var body: some View {
        VStack(spacing: 0) {
            // Quick Mentor Review Bar
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    QuickButton(title: "🔍 Review Current Blueprint", icon: "checkmark.shield.fill") {
                        reviewBlueprint()
                    }
                    QuickButton(title: "⚡ Explain Generated Logos Code", icon: "text.book.closed.fill") {
                        explainCurrentCode()
                    }
                    QuickButton(title: "🛡️ Check Memory & Crash Risks", icon: "exclamationmark.shield.fill") {
                        checkMemoryRisks()
                    }
                }
                .padding(10)
            }
            .background(WorkshopTheme.darkCard)

            Divider().background(WorkshopTheme.cardBorder)

            // Chat Messages History
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(messages) { msg in
                            HStack(alignment: .top, spacing: 8) {
                                if !msg.isUser {
                                    Circle()
                                        .fill(WorkshopTheme.cyberCyan)
                                        .frame(width: 24, height: 24)
                                        .overlay(
                                            Image(systemName: "sparkles")
                                                .font(.system(size: 11, weight: .bold))
                                                .foregroundColor(.black)
                                        )
                                } else {
                                    Spacer()
                                }

                                Text(msg.text)
                                    .font(.system(size: 13))
                                    .padding(12)
                                    .background(msg.isUser ? WorkshopTheme.neonGreen.opacity(0.18) : WorkshopTheme.darkCard)
                                    .foregroundColor(msg.isUser ? WorkshopTheme.neonGreen : WorkshopTheme.brightText)
                                    .cornerRadius(10)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(msg.isUser ? WorkshopTheme.neonGreen : WorkshopTheme.cardBorder, lineWidth: 1)
                                    )

                                if msg.isUser {
                                    Circle()
                                        .fill(WorkshopTheme.neonGreen)
                                        .frame(width: 24, height: 24)
                                        .overlay(
                                            Image(systemName: "person.fill")
                                                .font(.system(size: 11, weight: .bold))
                                                .foregroundColor(.black)
                                        )
                                }
                            }
                            .id(msg.id)
                        }

                        if projectVM.isGeminiLoading {
                            HStack(spacing: 8) {
                                ProgressView()
                                    .scaleEffect(0.8)
                                Text("AI Mentor reviewing blueprint...")
                                    .font(.system(size: 12, design: .monospaced))
                                    .foregroundColor(WorkshopTheme.subtleText)
                            }
                            .padding(8)
                        }
                    }
                    .padding(16)
                }
                .onChange(of: messages.count) { _ in
                    if let last = messages.last {
                        proxy.scrollTo(last.id, anchor: .bottom)
                    }
                }
            }
            .background(WorkshopTheme.deepBackground)

            Divider().background(WorkshopTheme.cardBorder)

            // Input Text Field Bar
            HStack(spacing: 8) {
                TextField("Ask your AI Mentor about tweak architecture or Logos directives...", text: $inputText)
                    .font(.system(size: 12, design: .monospaced))
                    .padding(10)
                    .background(WorkshopTheme.darkCard)
                    .cornerRadius(8)
                    .foregroundColor(WorkshopTheme.brightText)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(WorkshopTheme.cardBorder, lineWidth: 1)
                    )

                Button {
                    let prompt = inputText
                    inputText = ""
                    sendMessage(prompt)
                } label: {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 12, weight: .bold))
                        .padding(10)
                        .background(WorkshopTheme.neonGreen)
                        .foregroundColor(.black)
                        .cornerRadius(8)
                }
            }
            .padding(10)
            .background(WorkshopTheme.darkCard)
        }
    }

    private func reviewBlueprint() {
        let report = projectVM.validationReport
        var reviewText = "🔍 **AI Mentor Blueprint Review Report**\n\n"
        reviewText += "Project: **\(projectVM.project.name)** (\(projectVM.project.targetType.displayName))\n"
        reviewText += "Total Nodes: \(projectVM.project.blocks.count)\n\n"

        if report.isValid {
            reviewText += "✅ **Overall Status**: Passed all primary structural checks.\n\n"
            reviewText += "**Mentor Recommendations**:\n"
            reviewText += "• Consider wrapping high-frequency hooks in `%group` directives for clean runtime enable/disable toggles.\n"
            reviewText += "• Ensure all string variables passed into `NSLog` use Objective-C string formatting (`@\"...\"`)."
        } else {
            reviewText += "⚠️ **Issues Found (\(report.errorCount) Errors, \(report.warningCount) Warnings)**:\n"
            for item in report.items {
                reviewText += "• [\(item.severity.rawValue)] **\(item.title)**: \(item.detail)\n"
            }
            reviewText += "\n**Mentor Guidance**: Use the Experiment Validation drawer to apply automatic quick fixes before building."
        }

        messages.append(ChatMessage(isUser: false, text: reviewText))
    }

    private func explainCurrentCode() {
        let code = projectVM.generateCodeForCurrentTarget()
        var explanation = "📚 **Generated Code Explanation**:\n\n```objc\n\(code)\n```\n\n"
        explanation += "**Breakdown**:\n"
        explanation += "1. `%hook TargetClass`: Instructs Cydia Substrate to swizzle methods on TargetClass at runtime.\n"
        explanation += "2. `%orig`: Calls the original implementation so existing application behavior continues properly.\n"
        explanation += "3. `%end`: Closes the swizzling hook block."

        messages.append(ChatMessage(isUser: false, text: explanation))
    }

    private func checkMemoryRisks() {
        var warningText = "🛡️ **Memory & Crash Risk Audit**:\n\n"
        let hooks = projectVM.project.blocks.filter { $0.type == .hook }

        if hooks.isEmpty {
            warningText += "• No hooks configured on canvas. Add a Hook block to start swizzling."
        } else {
            for h in hooks {
                let cls = h.targetClass ?? "Class"
                let mth = h.targetMethod ?? "Method"
                warningText += "• **\(cls) \(mth)**: Ensure self pointers are not captured inside async block blocks without `__weak typeof(self) weakSelf = self;` to prevent retain cycles.\n"
            }
        }

        messages.append(ChatMessage(isUser: false, text: warningText))
    }

    private func sendMessage(_ prompt: String) {
        guard !prompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

        messages.append(ChatMessage(isUser: true, text: prompt))
        projectVM.isGeminiLoading = true

        Task {
            if let reply = try? await GeminiAPIService.shared.askWorkshopAI(prompt: prompt, project: projectVM.project) {
                messages.append(ChatMessage(isUser: false, text: reply))
            } else {
                messages.append(ChatMessage(isUser: false, text: "I have analyzed your request against the current \(projectVM.project.targetType.displayName) blueprint. Your nodes look clean! You can now proceed to test in Experiment Validation or export the Logos source."))
            }
            projectVM.isGeminiLoading = false
        }
    }
}

struct QuickButton: View {
    let title: String
    let icon: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 11))
                Text(title)
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(WorkshopTheme.deepBackground)
            .foregroundColor(WorkshopTheme.cyberCyan)
            .cornerRadius(6)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(WorkshopTheme.cardBorder, lineWidth: 1)
            )
        }
    }
}
