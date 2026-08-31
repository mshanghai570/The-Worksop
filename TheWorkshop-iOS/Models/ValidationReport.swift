//
//  Models/ValidationReport.swift
//  TheWorkshop-iOS
//  Diagnostic Engine & Experiment Validation Models
//

import Foundation

public enum ValidationSeverity: String, Codable, CaseIterable {
    case error = "ERROR"
    case warning = "WARNING"
    case suggestion = "SUGGESTION"
    case pass = "PASS"
}

public struct ValidationItem: Identifiable, Codable {
    public var id: String
    public var severity: ValidationSeverity
    public var title: String
    public var detail: String
    public var relatedBlockId: String?
    public var quickFixTitle: String?

    public init(
        id: String = "val-\(UUID().uuidString.prefix(8))",
        severity: ValidationSeverity,
        title: String,
        detail: String,
        relatedBlockId: String? = nil,
        quickFixTitle: String? = nil
    ) {
        self.id = id
        self.severity = severity
        self.title = title
        self.detail = detail
        self.relatedBlockId = relatedBlockId
        self.quickFixTitle = quickFixTitle
    }
}

public struct ValidationReport: Codable {
    public var items: [ValidationItem]
    public var isValid: Bool {
        !items.contains { $0.severity == .error }
    }

    public var errorCount: Int { items.filter { $0.severity == .error }.count }
    public var warningCount: Int { items.filter { $0.severity == .warning }.count }
    public var suggestionCount: Int { items.filter { $0.severity == .suggestion }.count }

    public init(items: [ValidationItem] = []) {
        self.items = items
    }
}
