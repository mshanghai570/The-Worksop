//
//  Services/TimelineService.swift
//  TheWorkshop-iOS
//  Undo/Redo History & Timeline Engine
//

import Foundation
import Combine

public class TimelineService: ObservableObject {
    @Published public private(set) var history: [TimelineSnapshot] = []
    @Published public private(set) var currentIndex: Int = -1

    public var canUndo: Bool { currentIndex > 0 }
    public var canRedo: Bool { currentIndex < history.count - 1 }

    public init() {}

    public func recordInitialState(project: Project) {
        history = [TimelineSnapshot(actionDescription: "Project Created", project: project)]
        currentIndex = 0
    }

    public func recordAction(_ description: String, project: Project) {
        // Truncate redo stack if new action happens after undo
        if currentIndex >= 0 && currentIndex < history.count - 1 {
            history = Array(history[0...currentIndex])
        }

        let snapshot = TimelineSnapshot(actionDescription: description, project: project)
        history.append(snapshot)
        currentIndex = history.count - 1

        // Limit stack size to 50
        if history.count > 50 {
            history.removeFirst()
            currentIndex -= 1
        }
    }

    public func undo() -> Project? {
        guard canUndo else { return nil }
        currentIndex -= 1
        return history[currentIndex].project
    }

    public func redo() -> Project? {
        guard canRedo else { return nil }
        currentIndex += 1
        return history[currentIndex].project
    }

    public func jumpTo(index: Int) -> Project? {
        guard index >= 0 && index < history.count else { return nil }
        currentIndex = index
        return history[currentIndex].project
    }
}
