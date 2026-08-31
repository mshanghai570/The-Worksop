//
//  Models/BlockEducation.swift
//  TheWorkshop-iOS
//  Learn Mode Educational Metadata
//

import Foundation

public struct BlockEducation: Codable, Equatable {
    public let purpose: String
    public let codeExplanation: String
    public let commonMistakes: [String]
    public let documentationUrl: String

    public init(
        purpose: String,
        codeExplanation: String,
        commonMistakes: [String],
        documentationUrl: String = "https://theos.dev/docs/"
    ) {
        self.purpose = purpose
        self.codeExplanation = codeExplanation
        self.commonMistakes = commonMistakes
        self.documentationUrl = documentationUrl
    }
}
