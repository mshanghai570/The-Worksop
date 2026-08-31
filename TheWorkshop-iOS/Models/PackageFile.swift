//
//  Models/PackageFile.swift
//  TheWorkshop-iOS
//  IDE Project Hierarchy File System Item
//

import Foundation

public enum PackageFileType: String, Codable {
    case folder
    case logosSource
    case header
    case resource
    case makefile
    case control
    case plist
}

public struct PackageFileItem: Identifiable, Codable {
    public let id: String
    public let name: String
    public let fileType: PackageFileType
    public var children: [PackageFileItem]?
    public var content: String?

    public init(
        id: String = "file-\(UUID().uuidString.prefix(8))",
        name: String,
        fileType: PackageFileType,
        children: [PackageFileItem]? = nil,
        content: String? = nil
    ) {
        self.id = id
        self.name = name
        self.fileType = fileType
        self.children = children
        self.content = content
    }
}
