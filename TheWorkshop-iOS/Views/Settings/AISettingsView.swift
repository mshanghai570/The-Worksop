//
//  Views/Settings/AISettingsView.swift
//  TheWorkshop-iOS
//  AI Provider Configuration Settings
//

import SwiftUI

public struct AISettingsView: View {
    @StateObject private var aiService = AIService.shared
    @State private var endpointURL: String
    @State private var apiKey: String
    @State private var selectedModelId: String
    @State private var timeoutSeconds: String
    @State private var maxTokens: String
    @State private var temperature: String
    @State private var isTestingConnection: Bool = false
    @State private var testResult: String?
    @State private var showTestAlert: Bool = false
    @State private var isShowingAPIKey: Bool = false
    @State private var isLoadingModels: Bool = false

    @Environment(\.dismiss) private var dismiss

    public init() {
        let config = aiService.configuration
        _endpointURL = State(initialValue: config.endpointURL)
        _apiKey = State(initialValue: config.apiKey)
        _selectedModelId = State(initialValue: config.selectedModelId)
        _timeoutSeconds = State(initialValue: String(Int(config.timeoutSeconds)))
        _maxTokens = State(initialValue: String(config.maxTokens))
        _temperature = State(initialValue: String(config.temperature))
    }

    public var body: some View {
        NavigationView {
            Form {
                // Configuration Section
                Section(header: Text("AI PROVIDER CONFIGURATION")) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Endpoint URL")
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundColor(WorkshopTheme.subtleText)
                        
                        TextField(
                            "Enter OpenAI-compatible endpoint",
                            text: $endpointURL
                        )
                        .font(.system(size: 13, design: .monospaced))
                        .textFieldStyle(.plain)
                        .padding(10)
                        .background(WorkshopTheme.darkCard)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(WorkshopTheme.cardBorder, lineWidth: 1)
                        )
                        .foregroundColor(WorkshopTheme.brightText)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        
                        Text("Example: https://api.openai.com/v1 or https://your-provider.com/api/v1")
                            .font(.system(size: 10))
                            .foregroundColor(WorkshopTheme.subtleText.opacity(0.6))
                    }
                    .padding(.vertical, 8)

                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("API Key")
                                .font(.system(size: 11, weight: .bold, design: .monospaced))
                                .foregroundColor(WorkshopTheme.subtleText)
                            Spacer()
                            Button(action: { isShowingAPIKey.toggle() }) {
                                Image(systemName: isShowingAPIKey ? "eye.fill" : "eye.slash.fill")
                                    .foregroundColor(WorkshopTheme.cyberCyan)
                            }
                        }
                        
                        if isShowingAPIKey {
                            TextField(
                                "Enter API key",
                                text: $apiKey
                            )
                            .font(.system(size: 13, design: .monospaced))
                            .textFieldStyle(.plain)
                        } else {
                            SecureField(
                                "Enter API key",
                                text: $apiKey
                            )
                            .font(.system(size: 13, design: .monospaced))
                            .textFieldStyle(.plain)
                        }
                        .padding(10)
                        .background(WorkshopTheme.darkCard)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(WorkshopTheme.cardBorder, lineWidth: 1)
                        )
                        .foregroundColor(WorkshopTheme.brightText)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    }
                    .padding(.vertical, 8)
                }

                // Model Selection Section
                Section(header: HStack {
                    Text("MODEL SELECTION")
                    Spacer()
                    if isLoadingModels {
                        ProgressView()
                            .scaleEffect(0.8)
                    }
                }) {
                    if aiService.configuration.availableModels.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("No models loaded. Configure endpoint and API key, then tap 'Load Models'.")
                                .font(.system(size: 12))
                                .foregroundColor(WorkshopTheme.subtleText)
                            
                            Button(action: loadModels) {
                                HStack(spacing: 6) {
                                    Image(systemName: "arrow.clockwise")
                                    Text("Load Models")
                                }
                                .font(.system(size: 12, weight: .bold, design: .monospaced))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                                .background(WorkshopTheme.neonGreen)
                                .foregroundColor(.black)
                                .cornerRadius(8)
                            }
                            .disabled(endpointURL.isEmpty || apiKey.isEmpty)
                        }
                    } else {
                        Picker("Select Model", selection: $selectedModelId) {
                            ForEach(aiService.configuration.availableModels) { model in
                                Text(model.name)
                                    .tag(model.id)
                                    .font(.system(size: 12, design: .monospaced))
                            }
                        }
                        .pickerStyle(.menu)
                        .tint(WorkshopTheme.neonGreen)
                        
                        if let selectedModel = aiService.configuration.selectedModel {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Selected: \(selectedModel.name)")
                                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                                    .foregroundColor(WorkshopTheme.neonGreen)
                                
                                if let description = selectedModel.description {
                                    Text(description)
                                        .font(.system(size: 10))
                                        .foregroundColor(WorkshopTheme.subtleText)
                                }
                                
                                if let contextLength = selectedModel.contextLength {
                                    Text("Context: \(contextLength) tokens")
                                        .font(.system(size: 10))
                                        .foregroundColor(WorkshopTheme.subtleText)
                                }
                            }
                            .padding(.vertical, 8)
                        }
                    }
                }

                // Advanced Settings Section
                Section(header: Text("ADVANCED SETTINGS")) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Timeout (seconds)")
                                .font(.system(size: 11, weight: .bold, design: .monospaced))
                                .foregroundColor(WorkshopTheme.subtleText)
                            Spacer()
                            TextField("", text: $timeoutSeconds)
                                .font(.system(size: 12, design: .monospaced))
                                .textFieldStyle(.plain)
                                .frame(width: 60)
                                .padding(6)
                                .background(WorkshopTheme.darkCard)
                                .cornerRadius(6)
                                .foregroundColor(WorkshopTheme.brightText)
                                .keyboardType(.numberPad)
                        }
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Max Tokens")
                                .font(.system(size: 11, weight: .bold, design: .monospaced))
                                .foregroundColor(WorkshopTheme.subtleText)
                            Spacer()
                            TextField("", text: $maxTokens)
                                .font(.system(size: 12, design: .monospaced))
                                .textFieldStyle(.plain)
                                .frame(width: 60)
                                .padding(6)
                                .background(WorkshopTheme.darkCard)
                                .cornerRadius(6)
                                .foregroundColor(WorkshopTheme.brightText)
                                .keyboardType(.numberPad)
                        }
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Temperature")
                                .font(.system(size: 11, weight: .bold, design: .monospaced))
                                .foregroundColor(WorkshopTheme.subtleText)
                            Spacer()
                            TextField("", text: $temperature)
                                .font(.system(size: 12, design: .monospaced))
                                .textFieldStyle(.plain)
                                .frame(width: 60)
                                .padding(6)
                                .background(WorkshopTheme.darkCard)
                                .cornerRadius(6)
                                .foregroundColor(WorkshopTheme.brightText)
                                .keyboardType(.decimalPad)
                        }
                    }
                }

                // Connection Test Section
                Section {
                    Button(action: testConnection) {
                        HStack(spacing: 6) {
                            if isTestingConnection {
                                ProgressView()
                                    .scaleEffect(0.8)
                            } else {
                                Image(systemName: "network")
                            }
                            Text("Test Connection")
                        }
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(WorkshopTheme.cyberCyan)
                        .foregroundColor(.black)
                        .cornerRadius(8)
                    }
                    .disabled(endpointURL.isEmpty || apiKey.isEmpty || isTestingConnection)
                    
                    if let result = testResult {
                        HStack(spacing: 6) {
                            Image(systemName: result.contains("Success") ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                                .foregroundColor(result.contains("Success") ? WorkshopTheme.neonGreen : WorkshopTheme.errorRed)
                            Text(result)
                                .font(.system(size: 11, design: .monospaced))
                                .foregroundColor(result.contains("Success") ? WorkshopTheme.neonGreen : WorkshopTheme.errorRed)
                        }
                        .padding(.vertical, 8)
                    }
                }

                // Actions Section
                Section {
                    HStack(spacing: 12) {
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

                        Button(action: clearSettings) {
                            HStack(spacing: 6) {
                                Image(systemName: "trash")
                                Text("Clear")
                            }
                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(WorkshopTheme.errorRed.opacity(0.2))
                            .foregroundColor(WorkshopTheme.errorRed)
                            .cornerRadius(8)
                        }
                    }
                }
            }
            .background(WorkshopTheme.deepBackground)
            .scrollContentBackground(.hidden)
            .navigationTitle("AI Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundColor(WorkshopTheme.subtleText)
                }
            }
        }
        .preferredColorScheme(.dark)
        .onDisappear {
            saveSettings()
        }
    }

    private func loadModels() {
        isLoadingModels = true
        Task {
            do {
                try await aiService.fetchAvailableModels()
                selectedModelId = aiService.configuration.selectedModelId
            } catch {
                testResult = "Failed to load models: \(error.localizedDescription)"
            }
            isLoadingModels = false
        }
    }

    private func testConnection() {
        isTestingConnection = true
        testResult = nil
        
        Task {
            do {
                let success = try await aiService.testConnection()
                testResult = success ? "Success: Connected to AI provider" : "Failed: Could not connect"
            } catch {
                testResult = "Error: \(error.localizedDescription)"
            }
            isTestingConnection = false
        }
    }

    private func saveSettings() {
        // Validate inputs
        let timeout = TimeInterval(timeoutSeconds) ?? aiService.configuration.timeoutSeconds
        let tokens = Int(maxTokens) ?? aiService.configuration.maxTokens
        let temp = Double(temperature) ?? aiService.configuration.temperature
        
        var config = aiService.configuration
        config.endpointURL = endpointURL
        config.apiKey = apiKey
        config.selectedModelId = selectedModelId
        config.timeoutSeconds = timeout
        config.maxTokens = tokens
        config.temperature = temp
        
        aiService.updateConfiguration(config)
        testResult = "Settings saved successfully"
    }

    private func clearSettings() {
        endpointURL = ""
        apiKey = ""
        selectedModelId = ""
        timeoutSeconds = "60"
        maxTokens = "4096"
        temperature = "0.7"
        testResult = nil
        
        aiService.clearConfiguration()
    }
}
