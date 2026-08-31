//
//  ViewModels/ProjectViewModel.swift
//  TheWorkshop-iOS
//  Studio State & IDE Orchestration ViewModel
//

import SwiftUI
import Combine

public enum StudioTab: String, CaseIterable, Identifiable {
    case canvas = "Visual Canvas"
    case code = "Split Code Sync"
    case explorer = "Package Explorer"
    case inspector = "Inspector"
    case assistant = "AI Mentor Review"

    public var id: String { rawValue }
}

public class ProjectViewModel: ObservableObject {
    @Published public var projectManager: ProjectManager
    @Published public var activeTab: StudioTab = .canvas
    @Published public var selectedBlockId: String? = nil {
        didSet {
            highlightCodeForSelectedBlock()
        }
    }
    @Published public var isGeminiLoading: Bool = false
    @Published public var statusToastMessage: String? = nil
    @Published public var highlightedCodeRange: NSRange? = nil
    @Published public var validationReport: ValidationReport = ValidationReport()
    @Published public var isShowingBlueprintLibrary: Bool = false
    @Published public var isShowingExperimentValidation: Bool = false
    @Published public var isShowingTimelineDrawer: Bool = false
    @Published public var selectedPackageFileId: String = "logos-tweak-x"

    public let timelineService = TimelineService()

    private var cancellables = Set<AnyCancellable>()

    public var project: Project {
        get { projectManager.currentProject }
        set {
            projectManager.currentProject = newValue
            runValidation()
        }
    }

    public var selectedBlock: Block? {
        get {
            guard let id = selectedBlockId else { return nil }
            return project.blocks.first(where: { $0.id == id })
        }
        set {
            guard let updated = newValue, let index = project.blocks.firstIndex(where: { $0.id == updated.id }) else { return }
            project.blocks[index] = updated
            recordAction("Updated Block properties")
        }
    }

    public init(projectManager: ProjectManager = ProjectManager()) {
        self.projectManager = projectManager
        
        projectManager.objectWillChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)

        timelineService.recordInitialState(project: projectManager.currentProject)
        runValidation()
    }

    public func runValidation() {
        validationReport = ValidationService.shared.validate(project: projectManager.currentProject)
    }

    public func recordAction(_ desc: String) {
        timelineService.recordAction(desc, project: projectManager.currentProject)
        runValidation()
    }

    public func undo() {
        if let restored = timelineService.undo() {
            projectManager.currentProject = restored
            showToast("Undo: \(timelineService.history[timelineService.currentIndex].actionDescription)")
            runValidation()
        }
    }

    public func redo() {
        if let restored = timelineService.redo() {
            projectManager.currentProject = restored
            showToast("Redo: \(timelineService.history[timelineService.currentIndex].actionDescription)")
            runValidation()
        }
    }

    public func updateTargetType(_ type: ProjectTargetType) {
        projectManager.updateTargetType(type)
        selectedBlockId = nil
        recordAction("Switched target to \(type.displayName)")
        showToast("Switched workflow target to \(type.displayName)")
    }

    public func loadBlueprint(_ blueprint: BlueprintTemplate) {
        projectManager.updateTargetType(blueprint.targetType)
        project.blocks = blueprint.blocks
        project.connections = blueprint.connections
        selectedBlockId = blueprint.blocks.first?.id
        recordAction("Loaded Blueprint: \(blueprint.title)")
        showToast("Loaded blueprint: \(blueprint.title)")
    }

    public func addBlock(type: BlockType) {
        let newX = Double.random(in: 60...240)
        let newY = Double.random(in: 60...280)

        var newBlock = Block(type: type, x: newX, y: newY)

        switch type {
        case .hook:
            newBlock.targetClass = "SpringBoard"
            newBlock.targetMethod = "applicationDidFinishLaunching:"
            newBlock.returnType = "void"
        case .log:
            newBlock.message = "Method executed"
        case .delay:
            newBlock.durationSeconds = 1.0
        case .replaceAsset:
            newBlock.assetPath = "Assets.car"
            newBlock.replacementUrl = "./replacement.car"
        case .editPlist:
            newBlock.plistKey = "CFBundleDisplayName"
            newBlock.plistValue = "Modified App"
        case .swiftuiView:
            newBlock.viewTitle = "CustomOverlay"
        default:
            break
        }

        project.blocks.append(newBlock)
        selectedBlockId = newBlock.id
        recordAction("Added \(type.rawValue.capitalized) block")
        showToast("Added \(type.rawValue.capitalized) block")
    }

    public func updateBlockPosition(id: String, newX: Double, newY: Double) {
        if let index = project.blocks.firstIndex(where: { $0.id == id }) {
            project.blocks[index].x = newX
            project.blocks[index].y = newY
        }
    }

    public func deleteBlock(id: String) {
        project.blocks.removeAll(where: { $0.id == id })
        project.connections.removeAll(where: { $0.fromBlockId == id || $0.toBlockId == id })
        if selectedBlockId == id {
            selectedBlockId = nil
        }
        recordAction("Deleted Block")
        showToast("Deleted block from canvas")
    }

    public func highlightCodeForSelectedBlock() {
        guard let selectedId = selectedBlockId, let block = project.blocks.first(where: { $0.id == selectedId }) else {
            highlightedCodeRange = nil
            return
        }

        let fullCode = generateCodeForCurrentTarget()
        var searchTerm = ""
        if let cls = block.targetClass, !cls.isEmpty {
            searchTerm = cls
        } else if let msg = block.message, !msg.isEmpty {
            searchTerm = msg
        } else if let custom = block.customCode, !custom.isEmpty {
            searchTerm = String(custom.prefix(15))
        }

        if !searchTerm.isEmpty, let range = fullCode.range(of: searchTerm) {
            let nsRange = NSRange(range, in: fullCode)
            highlightedCodeRange = nsRange
        } else {
            highlightedCodeRange = nil
        }
    }

    public func showToast(_ message: String) {
        statusToastMessage = message
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { [weak self] in
            if self?.statusToastMessage == message {
                self?.statusToastMessage = nil
            }
        }
    }

    public func generateCodeForCurrentTarget() -> String {
        switch project.projectType {
        case .jailbreakTweak:
            return LogosGenerator().generateCode(for: project)
        case .jailedMod:
            return JailedModGenerator().generateCode(for: project)
        case .nativeExtension:
            return ExtensionGenerator().generateCode(for: project)
        }
    }
}
