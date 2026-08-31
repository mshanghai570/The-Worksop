//
//  Services/ProjectStorageService.swift
//  TheWorkshop-iOS
//  Project JSON Persistence & Export
//

import Foundation

public class ProjectStorageService {
    public static let shared = ProjectStorageService()

    private init() {}

    public func encodeProject(_ project: Project) throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return try encoder.encode(project)
    }

    public func decodeProject(from data: Data) throws -> Project {
        let decoder = JSONDecoder()
        return try decoder.decode(Project.self, from: data)
    }

    public func saveToDocuments(project: Project) throws -> URL {
        let data = try encodeProject(project)
        let fileName = "\(project.name.lowercased().replacingOccurrences(of: " ", with: "_")).workshop"
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = docs.appendingPathComponent(fileName)
        try data.write(to: fileURL)
        return fileURL
    }

    public func exportProjectAsJSON(_ project: Project) -> String {
        if let data = try? encodeProject(project), let string = String(data: data, encoding: .utf8) {
            return string
        }
        return "{}"
    }
}
