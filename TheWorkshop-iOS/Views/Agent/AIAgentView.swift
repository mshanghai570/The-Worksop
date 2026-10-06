//
//  Views/Agent/AIAgentView.swift
//  TheWorkshop-iOS
//  Interactive AI Agent Interface
//

import SwiftUI

public struct AIAgentView: View {
    @StateObject private var agentService = AIAgentService.shared
    @StateObject private var binaryService = BinaryPatchingService.shared
    @StateObject private var aiService = AIService.shared
    
    @State private var messageInput: String = ""
    @State private var selectedAction: AIAgentAction?
    @State private var showActionSelector: Bool = false
    @State private var showAgentSelector: Bool = false
    @State private var showSettings: Bool = false
    @State private var searchQuery: String = ""
    @State private var selectedSearchType: SearchType = .functionName
    @State private var isSearching: Bool = false
    @State private var showSmartPatch: Bool = false
    @State private var smartPatchGoal: String = ""
    @State private var showSuggestions: Bool = false

    public var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                agentHeader

                Divider().background(WorkshopTheme.cardBorder)

                // Action Bar
                if aiService.configuration.isConfigured && binaryService.loadedBinary != nil {
                    agentActionBar
                    Divider().background(WorkshopTheme.cardBorder)
                }

                // Main Content
                if let agent = agentService.activeAgent {
                    if agent.messages.isEmpty {
                        emptyState
                    } else {
                        ScrollView {
                            messageList
                        }
                    }
                } else {
                    emptyState
                }

                // Input Bar
                inputBar
            }
            .background(WorkshopTheme.deepBackground)
            .navigationTitle("AI Agent")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showSettings = true }) {
                        Image(systemName: "gearshape.fill")
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
        
        // Sheets
        .sheet(isPresented: $showActionSelector) {
            AgentActionSelectorView(
                selectedAction: $selectedAction,
                onSelect: { action in
                    selectedAction = action
                    showActionSelector = false
                    executeAction(action)
                }
            )
        }
        .sheet(isPresented: $showAgentSelector) {
            AgentSelectorView(
                selectedAgentId: agentService.activeAgent?.id,
                onSelect: { agentId in
                    _ = agentService.activateAgent(agentId)
                    showAgentSelector = false
                }
            )
        }
        .sheet(isPresented: $showSettings) {
            AgentSettingsView()
        }
        .sheet(isPresented: $showSmartPatch) {
            SmartPatchView(
                goal: $smartPatchGoal,
                onGenerate: generateSmartPatches
            )
        }
        .sheet(isPresented: $showSuggestions) {
            SuggestionsView(
                suggestions: agentService.activeAgent?.suggestions ?? [],
                onApply: { suggestionId in
                    Task {
                        do {
                            try await agentService.applySmartPatch(suggestionId)
                        } catch {
                            print("Error applying patch: \(error)")
                        }
                    }
                }
            )
        }
    }

    // MARK: - Subviews

    private var agentHeader: some View {
        HStack(spacing: 12) {
            if let agent = agentService.activeAgent {
                agentAvatar(agent: agent)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(agent.configuration.name)
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .foregroundColor(WorkshopTheme.brightText)
                    
                    HStack(spacing: 8) {
                        WorkshopBadge(
                            text: agent.configuration.agentType.displayName,
                            color: agentColor(agent: agent)
                        )
                        
                        if agent.isActive {
                            HStack(spacing: 4) {
                                Circle()
                                    .fill(WorkshopTheme.neonGreen)
                                    .frame(width: 6, height: 6)
                                Text("Active")
                                    .font(.system(size: 10, design: .monospaced))
                                    .foregroundColor(WorkshopTheme.neonGreen)
                            }
                        }
                    }
                }
                
                Spacer()
                
                Button(action: { showAgentSelector = true }) {
                    Image(systemName: "chevron.down")
                        .foregroundColor(WorkshopTheme.subtleText)
                }
            } else {
                Button(action: { showAgentSelector = true }) {
                    HStack(spacing: 6) {
                        Image(systemName: "person.fill")
                        Text("Select Agent")
                    }
                    .font(.system(size: 13, weight: .bold, design: .monospaced))
                    .foregroundColor(WorkshopTheme.subtleText)
                }
            }
        }
        .padding(12)
        .background(WorkshopTheme.darkCard)
    }

    private func agentAvatar(agent: AIAgent) -> some View {
        Image(systemName: agent.configuration.agentType.iconName)
            .font(.system(size: 20, weight: .bold))
            .foregroundColor(.black)
            .frame(width: 36, height: 36)
            .background(agentColor(agent: agent))
            .cornerRadius(10)
    }

    private func agentColor(agent: AIAgent) -> Color {
        let hexColor = agent.configuration.agentType.color
        return Color(
            red: hexColor.red,
            green: hexColor.green,
            blue: hexColor.blue,
            opacity: hexColor.alpha
        )
    }

    private var agentActionBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                // Quick Actions
                AgentActionButton(
                    icon: "magnifyingglass",
                    title: "Analyze",
                    color: WorkshopTheme.cyberCyan
                ) {
                    executeAction(.analyzeBinary)
                }

                AgentActionButton(
                    icon: "wrench.and.screwdriver.fill",
                    title: "Smart Patch",
                    color: WorkshopTheme.neonGreen
                ) {
                    showSmartPatch = true
                }

                AgentActionButton(
                    icon: "target",
                    title: "Search",
                    color: WorkshopTheme.hotPink
                ) {
                    showSearchView()
                }

                AgentActionButton(
                    icon: "shield.fill",
                    title: "Vulnerabilities",
                    color: WorkshopTheme.warningYellow
                ) {
                    executeAction(.findVulnerabilities)
                }

                AgentActionButton(
                    icon: "list.bullet.rectangle.fill",
                    title: "Disassemble",
                    color: WorkshopTheme.cyberCyan
                ) {
                    showDisassemblePrompt()
                }

                AgentActionButton(
                    icon: "lightbulb.fill",
                    title: "Suggestions",
                    color: WorkshopTheme.warningYellow
                ) {
                    showSuggestions = true
                }

                AgentActionButton(
                    icon: "plus",
                    title: "More",
                    color: WorkshopTheme.darkCard
                ) {
                    showActionSelector = true
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "sparkles")
                .font(.system(size: 48))
                .foregroundColor(WorkshopTheme.subtleText.opacity(0.4))
            
            VStack(spacing: 8) {
                Text("AI Agent Ready")
                    .font(.system(size: 18, weight: .bold, design: .monospaced))
                    .foregroundColor(WorkshopTheme.brightText)
                
                if !aiService.configuration.isConfigured {
                    Text("Configure AI provider in Settings")
                        .font(.system(size: 12))
                        .foregroundColor(WorkshopTheme.subtleText)
                } else if binaryService.loadedBinary == nil {
                    Text("Load a binary to start analyzing")
                        .font(.system(size: 12))
                        .foregroundColor(WorkshopTheme.subtleText)
                } else {
                    Text("Ask me to analyze, search, or patch the binary")
                        .font(.system(size: 12))
                        .foregroundColor(WorkshopTheme.subtleText)
                }
            }
            
            if aiService.configuration.isConfigured && binaryService.loadedBinary != nil {
                VStack(spacing: 12) {
                    Text("Try:")
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .foregroundColor(WorkshopTheme.subtleText)
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("\"Analyze this binary\"")
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundColor(WorkshopTheme.cyberCyan)
                        Text("\"Find login functions\"")
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundColor(WorkshopTheme.cyberCyan)
                        Text("\"Suggest patches for bypassing checks\"")
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundColor(WorkshopTheme.cyberCyan)
                        Text("\"Disassemble function at 0x100004000\"")
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundColor(WorkshopTheme.cyberCyan)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(24)
    }

    private var messageList: some View {
        LazyVStack(spacing: 12) {
            ForEach(agentService.activeAgent?.messages ?? []) { message in
                AgentMessageView(message: message)
            }
            
            if agentService.isProcessing {
                HStack(spacing: 8) {
                    ProgressView()
                        .scaleEffect(0.8)
                    Text("Agent is thinking...")
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundColor(WorkshopTheme.subtleText)
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(12)
    }

    private var inputBar: some View {
        HStack(spacing: 8) {
            TextField(
                "Ask the agent...",
                text: $messageInput
            )
            .font(.system(size: 13, design: .monospaced))
            .textFieldStyle(.plain)
            .padding(12)
            .background(WorkshopTheme.darkCard)
            .cornerRadius(8)
            .foregroundColor(WorkshopTheme.brightText)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(WorkshopTheme.cardBorder, lineWidth: 1)
            )
            .autocapitalization(.none)
            .disableAutocorrection(true)
            .onSubmit {
                sendMessage()
            }

            Button(action: sendMessage) {
                Image(systemName: "paperplane.fill")
                    .font(.system(size: 14, weight: .bold))
                    .padding(10)
                    .background(messageInput.isEmpty ? WorkshopTheme.darkCard : WorkshopTheme.neonGreen)
                    .foregroundColor(messageInput.isEmpty ? WorkshopTheme.subtleText : .black)
                    .cornerRadius(8)
            }
            .disabled(messageInput.isEmpty || agentService.isProcessing)
        }
        .padding(12)
        .background(WorkshopTheme.darkCard)
    }

    // MARK: - Actions

    private func sendMessage() {
        guard !messageInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let content = messageInput
        messageInput = ""
        
        Task {
            do {
                try await agentService.sendMessage(content)
            } catch {
                print("Error sending message: \(error)")
            }
        }
    }

    private func executeAction(_ action: AIAgentAction) {
        Task {
            do {
                var parameters: [String: Any] = [:]
                
                switch action {
                case .searchFunctions:
                    parameters["query"] = searchQuery
                case .searchPatterns:
                    parameters["pattern"] = searchQuery
                case .smartPatch:
                    parameters["goal"] = smartPatchGoal
                case .disassembleRegion:
                    if let address = binaryService.selectedFunctionDisassembly.first?.address {
                        parameters["address"] = String(format: "%llX", address)
                    }
                default:
                    break
                }
                
                try await agentService.sendMessage("", action: action, data: parameters)
            } catch {
                print("Error executing action: \(error)")
            }
        }
    }

    private func generateSmartPatches() {
        showSmartPatch = false
        executeAction(.suggestPatches)
    }

    private func showSearchView() {
        Task {
            do {
                let result = try await agentService.searchBinary(
                    query: searchQuery,
                    searchType: selectedSearchType
                )
                
                // Show results
                let message = AIAgentMessage(
                    type: .result,
                    content: "Found \(result.totalMatches) matches for \"\(result.query)\"",
                    action: .searchFunctions
                )
                
                if let agent = agentService.activeAgent {
                    var updatedAgent = agent
                    updatedAgent.messages.append(message)
                    agentService.activeAgent = updatedAgent
                }
            } catch {
                print("Error searching: \(error)")
            }
        }
    }

    private func showDisassemblePrompt() {
        // Show disassembly for selected function or ask for address
        if let function = binaryService.selectedFunction {
            Task {
                do {
                    let instructions = try await binaryService.disassembleFunction(function)
                    binaryService.selectedFunctionDisassembly = instructions
                    
                    let message = AIAgentMessage(
                        type: .result,
                        content: "Disassembled \(function.displayName) - \(instructions.count) instructions",
                        action: .disassembleRegion
                    )
                    
                    if let agent = agentService.activeAgent {
                        var updatedAgent = agent
                        updatedAgent.messages.append(message)
                        agentService.activeAgent = updatedAgent
                    }
                } catch {
                    print("Error disassembling: \(error)")
                }
            }
        } else {
            // Ask for address
            let message = AIAgentMessage(
                type: .system,
                content: "Please select a function to disassemble or provide an address."
            )
            
            if let agent = agentService.activeAgent {
                var updatedAgent = agent
                updatedAgent.messages.append(message)
                agentService.activeAgent = updatedAgent
            }
        }
    }
}

// MARK: - Message View

struct AgentMessageView: View {
    let message: AIAgentMessage

    var body: some View {
        HStack(spacing: 12) {
            if message.type == .agent || message.type == .result {
                agentIcon
            }
            
            VStack(alignment: .leading, spacing: 6) {
                if message.type == .action {
                    HStack(spacing: 6) {
                        Image(systemName: "bolt.fill")
                            .foregroundColor(WorkshopTheme.cyberCyan)
                        Text(message.action?.rawValue ?? "Action")
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundColor(WorkshopTheme.cyberCyan)
                    }
                }
                
                Text(message.content)
                    .font(.system(size: 13, design: .monospaced))
                    .foregroundColor(messageForegroundColor)
                    .textSelection(.enabled)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            if message.type == .user {
                Spacer()
            }
        }
        .padding(12)
        .background(messageBackgroundColor)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(messageBorderColor, lineWidth: 1)
        )
        .frame(maxWidth: .infinity, alignment: messageAlignment)
        .padding(.horizontal, message.type == .user ? 40 : 12)
    }

    private var agentIcon: some View {
        Image(systemName: "sparkles")
            .font(.system(size: 18))
            .foregroundColor(.black)
            .frame(width: 32, height: 32)
            .background(WorkshopTheme.neonGreen)
            .cornerRadius(8)
    }

    private var messageForegroundColor: Color {
        switch message.type {
        case .system: return WorkshopTheme.subtleText
        case .user: return WorkshopTheme.brightText
        case .agent: return WorkshopTheme.brightText
        case .action: return WorkshopTheme.cyberCyan
        case .result: return WorkshopTheme.neonGreen
        case .error: return WorkshopTheme.errorRed
        case .thinking: return WorkshopTheme.subtleText
        }
    }

    private var messageBackgroundColor: Color {
        switch message.type {
        case .system: return WorkshopTheme.darkCard
        case .user: return WorkshopTheme.neonGreen.opacity(0.15)
        case .agent: return WorkshopTheme.darkCard
        case .action: return WorkshopTheme.cyberCyan.opacity(0.15)
        case .result: return WorkshopTheme.neonGreen.opacity(0.1)
        case .error: return WorkshopTheme.errorRed.opacity(0.15)
        case .thinking: return WorkshopTheme.darkCard
        }
    }

    private var messageBorderColor: Color {
        switch message.type {
        case .system: return WorkshopTheme.cardBorder
        case .user: return WorkshopTheme.neonGreen
        case .agent: return WorkshopTheme.cardBorder
        case .action: return WorkshopTheme.cyberCyan
        case .result: return WorkshopTheme.neonGreen
        case .error: return WorkshopTheme.errorRed
        case .thinking: return WorkshopTheme.cardBorder
        }
    }

    private var messageAlignment: HorizontalAlignment {
        message.type == .user ? .trailing : .leading
    }
}

// MARK: - Action Button

struct AgentActionButton: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                Text(title)
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(color)
            .foregroundColor(.black)
            .cornerRadius(8)
        }
    }
}

// MARK: - Action Selector

struct AgentActionSelectorView: View {
    @Binding var selectedAction: AIAgentAction?
    let onSelect: (AIAgentAction) -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            List {
                ForEach(AIAgentAction.allCases, id: \.self) { action in
                    Button(action: { 
                        selectedAction = action
                        onSelect(action)
                        dismiss()
                    }) {
                        HStack(spacing: 12) {
                            Image(systemName: actionIcon(action))
                                .foregroundColor(actionColor(action))
                            Text(actionDisplayName(action))
                                .font(.system(size: 13, design: .monospaced))
                                .foregroundColor(WorkshopTheme.brightText)
                            Spacer()
                            if selectedAction == action {
                                Image(systemName: "checkmark")
                                    .foregroundColor(WorkshopTheme.neonGreen)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
            }
            .background(WorkshopTheme.deepBackground)
            .scrollContentBackground(.hidden)
            .navigationTitle("Select Action")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    private func actionIcon(_ action: AIAgentAction) -> String {
        switch action {
        case .analyzeBinary: return "binarycoding"
        case .searchFunctions: return "magnifyingglass"
        case .searchPatterns: return "text.magnifyingglass"
        case .smartPatch: return "wrench.and.screwdriver.fill"
        case .generateHook: return "link"
        case .explainCode: return "text.bubble.fill"
        case .findVulnerabilities: return "exclamationmark.shield.fill"
        case .suggestPatches: return "lightbulb.fill"
        case .disassembleRegion: return "list.bullet.rectangle.fill"
        case .compareBinaries: return "arrow.left.arrow.right"
        case .extractStrings: return "text.quote"
        case .analyzeImports: return "shippingbox.fill"
        case .findCrossReferences: return "arrow.triangle.2.circlepath"
        case .customCommand: return "terminal.fill"
        }
    }

    private func actionColor(_ action: AIAgentAction) -> Color {
        switch action {
        case .analyzeBinary: return WorkshopTheme.cyberCyan
        case .searchFunctions: return WorkshopTheme.neonGreen
        case .searchPatterns: return WorkshopTheme.hotPink
        case .smartPatch: return WorkshopTheme.warningYellow
        case .generateHook: return WorkshopTheme.cyberCyan
        case .explainCode: return WorkshopTheme.subtleText
        case .findVulnerabilities: return WorkshopTheme.errorRed
        case .suggestPatches: return WorkshopTheme.neonGreen
        case .disassembleRegion: return WorkshopTheme.cyberCyan
        case .compareBinaries: return WorkshopTheme.hotPink
        case .extractStrings: return WorkshopTheme.warningYellow
        case .analyzeImports: return WorkshopTheme.cyberCyan
        case .findCrossReferences: return WorkshopTheme.hotPink
        case .customCommand: return WorkshopTheme.subtleText
        }
    }

    private func actionDisplayName(_ action: AIAgentAction) -> String {
        switch action {
        case .analyzeBinary: return "Analyze Binary"
        case .searchFunctions: return "Search Functions"
        case .searchPatterns: return "Search Patterns"
        case .smartPatch: return "Smart Patch"
        case .generateHook: return "Generate Hook"
        case .explainCode: return "Explain Code"
        case .findVulnerabilities: return "Find Vulnerabilities"
        case .suggestPatches: return "Suggest Patches"
        case .disassembleRegion: return "Disassemble Region"
        case .compareBinaries: return "Compare Binaries"
        case .extractStrings: return "Extract Strings"
        case .analyzeImports: return "Analyze Imports"
        case .findCrossReferences: return "Find XREFs"
        case .customCommand: return "Custom Command"
        }
    }
}

// MARK: - Agent Selector

struct AgentSelectorView: View {
    let selectedAgentId: String?
    let onSelect: (String) -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            List {
                ForEach(AIAgentService.shared.agents) { agent in
                    Button(action: { 
                        onSelect(agent.id)
                        dismiss()
                    }) {
                        HStack(spacing: 12) {
                            agentAvatar(agent: agent)
                            VStack(alignment: .leading, spacing: 4) {
                                Text(agent.configuration.name)
                                    .font(.system(size: 13, weight: .bold, design: .monospaced))
                                    .foregroundColor(WorkshopTheme.brightText)
                                Text(agent.configuration.agentType.description)
                                    .font(.system(size: 11, design: .monospaced))
                                    .foregroundColor(WorkshopTheme.subtleText)
                            }
                            Spacer()
                            if agent.id == selectedAgentId {
                                Image(systemName: "checkmark")
                                    .foregroundColor(WorkshopTheme.neonGreen)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
            }
            .background(WorkshopTheme.deepBackground)
            .scrollContentBackground(.hidden)
            .navigationTitle("Select Agent")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button(action: createNewAgent) {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    private func agentAvatar(agent: AIAgent) -> some View {
        Image(systemName: agent.configuration.agentType.iconName)
            .font(.system(size: 18, weight: .bold))
            .foregroundColor(.black)
            .frame(width: 36, height: 36)
            .background(agentColor(agent: agent))
            .cornerRadius(10)
    }

    private func agentColor(agent: AIAgent) -> Color {
        let hexColor = agent.configuration.agentType.color
        return Color(
            red: hexColor.red,
            green: hexColor.green,
            blue: hexColor.blue,
            opacity: hexColor.alpha
        )
    }

    private func createNewAgent() {
        let newAgent = AIAgentService.shared.createAgent(
            configuration: AIAgentConfiguration(
                agentType: .custom,
                name: "New Agent",
                personality: "Custom agent personality"
            )
        )
        onSelect(newAgent.id)
        dismiss()
    }
}

// MARK: - Smart Patch View

struct SmartPatchView: View {
    @Binding var goal: String
    let onGenerate: () -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("SMART PATCH GOAL")) {
                    TextEditor(text: $goal)
                        .font(.system(size: 13, design: .monospaced))
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
                    Button(action: { 
                        onGenerate()
                        dismiss()
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "wrench.and.screwdriver.fill")
                            Text("Generate Smart Patches")
                        }
                        .font(.system(size: 13, weight: .bold, design: .monospaced))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(WorkshopTheme.neonGreen)
                        .foregroundColor(.black)
                        .cornerRadius(8)
                    }
                    .disabled(goal.isEmpty)
                }
            }
            .background(WorkshopTheme.deepBackground)
            .scrollContentBackground(.hidden)
            .navigationTitle("Smart Patch")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - Suggestions View

struct SuggestionsView: View {
    let suggestions: [SmartPatchSuggestion]
    let onApply: (String) -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 12) {
                    if suggestions.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "lightbulb.fill")
                                .font(.system(size: 24))
                                .foregroundColor(WorkshopTheme.subtleText.opacity(0.4))
                            Text("No suggestions yet")
                                .font(.system(size: 13, design: .monospaced))
                                .foregroundColor(WorkshopTheme.subtleText)
                            Text("Ask the agent to suggest patches")
                                .font(.system(size: 11))
                                .foregroundColor(WorkshopTheme.subtleText.opacity(0.6))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(24)
                    } else {
                        ForEach(suggestions) { suggestion in
                            SuggestionCard(
                                suggestion: suggestion,
                                onApply: { onApply(suggestion.id) }
                            )
                        }
                    }
                }
                .padding(12)
            }
            .background(WorkshopTheme.deepBackground)
            .navigationTitle("Patch Suggestions")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - Suggestion Card

struct SuggestionCard: View {
    let suggestion: SmartPatchSuggestion
    let onApply: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(suggestion.title)
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .foregroundColor(WorkshopTheme.brightText)
                    
                    Text(suggestion.description)
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(WorkshopTheme.subtleText)
                }
                
                Spacer()
                
                WorkshopBadge(
                    text: suggestion.patchType.rawValue.capitalized,
                    color: patchTypeColor(suggestion.patchType)
                )
            }
            
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Confidence")
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundColor(WorkshopTheme.subtleText)
                    Text(String(format: "%.0f%%", suggestion.confidence * 100))
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .foregroundColor(WorkshopTheme.neonGreen)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Risk")
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundColor(WorkshopTheme.subtleText)
                    Text(suggestion.riskLevel.rawValue)
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .foregroundColor(riskLevelColor(suggestion.riskLevel))
                }
            }
            
            Divider().background(WorkshopTheme.cardBorder)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("CODE")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(WorkshopTheme.subtleText)
                
                Text(suggestion.code)
                    .font(.system(size: 11, design: .monospaced))
                    .padding(10)
                    .background(WorkshopTheme.darkCard)
                    .cornerRadius(6)
                    .foregroundColor(WorkshopTheme.brightText)
                    .textSelection(.enabled)
            }
            
            if !suggestion.reasoning.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("REASONING")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundColor(WorkshopTheme.subtleText)
                    
                    Text(suggestion.reasoning)
                        .font(.system(size: 11, design: .monospaced))
                        .padding(10)
                        .background(WorkshopTheme.darkCard.opacity(0.5))
                        .cornerRadius(6)
                        .foregroundColor(WorkshopTheme.subtleText)
                }
            }
            
            Button(action: onApply) {
                HStack(spacing: 6) {
                    Image(systemName: suggestion.isApplied ? "checkmark" : "wrench.and.screwdriver.fill")
                    Text(suggestion.isApplied ? "Applied" : "Apply Patch")
                }
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(suggestion.isApplied ? WorkshopTheme.neonGreen : WorkshopTheme.cyberCyan)
                .foregroundColor(.black)
                .cornerRadius(8)
            }
        }
        .padding(16)
        .background(WorkshopTheme.darkCard)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(WorkshopTheme.cardBorder, lineWidth: 1)
        )
    }

    private func patchTypeColor(_ type: AIService.PatchType) -> Color {
        switch type {
        case .hook: return WorkshopTheme.neonGreen
        case .replace: return WorkshopTheme.hotPink
        case .bypass: return WorkshopTheme.warningYellow
        case .log: return WorkshopTheme.cyberCyan
        case .modifyReturn: return WorkshopTheme.hotPink
        case .inlineEdit: return WorkshopTheme.warningYellow
        case .bytePatch: return WorkshopTheme.hotPink
        case .nop: return WorkshopTheme.subtleText
        case .call: return WorkshopTheme.cyberCyan
        case .jump: return WorkshopTheme.neonGreen
        }
    }

    private func riskLevelColor(_ level: RiskLevel) -> Color {
        switch level {
        case .low: return WorkshopTheme.neonGreen
        case .medium: return WorkshopTheme.warningYellow
        case .high: return WorkshopTheme.hotPink
        case .critical: return WorkshopTheme.errorRed
        }
    }
}

// MARK: - Agent Settings View

struct AgentSettingsView: View {
    @StateObject private var agentService = AIAgentService.shared
    @State private var agentName: String = ""
    @State private var agentPersonality: String = ""
    @State private var selectedType: AIAgentType = .reverseEngineer
    @State private var temperature: Double = 0.7
    @State private var maxTokens: String = "4096"
    @State private var autoExecute: Bool = true
    @State private var showReasoning: Bool = true

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("AGENT CONFIGURATION")) {
                    Picker("Agent Type", selection: $selectedType) {
                        ForEach(AIAgentType.allCases, id: \.self) { type in
                            Text(type.displayName)
                                .tag(type)
                        }
                    }
                    .pickerStyle(.menu)
                    .tint(WorkshopTheme.neonGreen)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Agent Name")
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundColor(WorkshopTheme.subtleText)
                        TextField("Name", text: $agentName)
                            .font(.system(size: 13, design: .monospaced))
                            .textFieldStyle(.plain)
                            .padding(10)
                            .background(WorkshopTheme.darkCard)
                            .cornerRadius(8)
                            .foregroundColor(WorkshopTheme.brightText)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Personality")
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundColor(WorkshopTheme.subtleText)
                        TextEditor(text: $agentPersonality)
                            .font(.system(size: 13, design: .monospaced))
                            .padding(10)
                            .background(WorkshopTheme.darkCard)
                            .cornerRadius(8)
                            .foregroundColor(WorkshopTheme.brightText)
                            .frame(minHeight: 100)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(WorkshopTheme.cardBorder, lineWidth: 1)
                            )
                    }
                }

                Section(header: Text("AI SETTINGS")) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Temperature")
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundColor(WorkshopTheme.subtleText)
                        Slider(value: $temperature, in: 0...1, step: 0.1)
                            .tint(WorkshopTheme.neonGreen)
                        Text(String(format: "%.1f", temperature))
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundColor(WorkshopTheme.subtleText)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Max Tokens")
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundColor(WorkshopTheme.subtleText)
                        TextField("Tokens", text: $maxTokens)
                            .font(.system(size: 13, design: .monospaced))
                            .textFieldStyle(.plain)
                            .padding(10)
                            .background(WorkshopTheme.darkCard)
                            .cornerRadius(8)
                            .foregroundColor(WorkshopTheme.brightText)
                            .keyboardType(.numberPad)
                    }

                    Toggle("Auto Execute Actions", isOn: $autoExecute)
                        .font(.system(size: 12, design: .monospaced))
                        .tint(WorkshopTheme.neonGreen)

                    Toggle("Show Reasoning", isOn: $showReasoning)
                        .font(.system(size: 12, design: .monospaced))
                        .tint(WorkshopTheme.neonGreen)
                }

                Section {
                    Button(action: saveSettings) {
                        HStack(spacing: 6) {
                            Image(systemName: "checkmark")
                            Text("Save Settings")
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
            .background(WorkshopTheme.deepBackground)
            .scrollContentBackground(.hidden)
            .navigationTitle("Agent Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .onAppear {
                loadCurrentSettings()
            }
        }
        .preferredColorScheme(.dark)
    }

    private func loadCurrentSettings() {
        if let agent = agentService.activeAgent {
            selectedType = agent.configuration.agentType
            agentName = agent.configuration.name
            agentPersonality = agent.configuration.personality
            temperature = agent.configuration.temperature
            maxTokens = String(agent.configuration.maxTokens)
            autoExecute = agent.configuration.autoExecute
            showReasoning = agent.configuration.showReasoning
        }
    }

    private func saveSettings() {
        if let agent = agentService.activeAgent {
            var config = agent.configuration
            config.agentType = selectedType
            config.name = agentName
            config.personality = agentPersonality
            config.temperature = temperature
            config.maxTokens = Int(maxTokens) ?? 4096
            config.autoExecute = autoExecute
            config.showReasoning = showReasoning
            
            _ = agentService.updateAgentConfiguration(agent.id, configuration: config)
        }
        dismiss()
    }
}
