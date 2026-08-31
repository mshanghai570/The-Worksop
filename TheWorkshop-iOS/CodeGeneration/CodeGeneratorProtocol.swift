//
//  CodeGeneration/CodeGeneratorProtocol.swift
//  TheWorkshop-iOS
//  Decoupled Generator Interface
//

import Foundation

public protocol CodeGeneratorProtocol {
    func generateCode(for project: Project) -> String
    func supportedTargetType() -> ProjectTargetType
}
