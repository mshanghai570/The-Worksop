//
//  Models/Block.swift
//  TheWorkshop-iOS
//  Extensible Data-Driven Block Model
//

import Foundation

public enum BlockType: String, Codable, CaseIterable, Identifiable {
    // Jailbreak Tweak Blocks
    case hook = "hook"
    case orig = "orig"
    case skipOrig = "skip_orig"
    case log = "log"
    case modifyProperty = "modify_property"
    case conditional = "conditional"
    case delay = "delay"
    case notification = "notification"
    case returnValue = "return_value"
    case customLogos = "custom_logos"
    case annotation = "annotation"
    case newMethod = "new_method"
    case constructor = "constructor"
    case group = "group"
    
    // Jailed Mod Blocks
    case replaceAsset = "replace_asset"
    case editPlist = "edit_plist"
    
    // Native Extension Blocks
    case swiftuiView = "swiftui_view"
    case extensionConfig = "extension_config"

    public var id: String { rawValue }

    public var categoryName: String {
        switch self {
        case .hook, .orig, .skipOrig, .newMethod, .constructor, .group:
            return "Hooking"
        case .log, .modifyProperty, .notification, .returnValue, .customLogos:
            return "Actions"
        case .conditional, .delay:
            return "Control Flow"
        case .annotation:
            return "Output"
        case .replaceAsset, .editPlist:
            return "Jailed Modifications"
        case .swiftuiView, .extensionConfig:
            return "Native Extension"
        }
    }
}

public struct Block: Identifiable, Codable, Equatable {
    public var id: String
    public var type: BlockType
    
    // Canvas Position
    public var x: Double
    public var y: Double
    
    // Objective-C / Logos Properties
    public var targetClass: String?
    public var targetMethod: String?
    public var isClassMethod: Bool?
    public var returnType: String?
    public var assignToVar: String?
    public var message: String?
    public var logLevel: String?
    public var targetObject: String?
    public var propertyName: String?
    public var value: String?
    public var condition: String?
    public var durationSeconds: Double?
    public var titleText: String?
    public var bodyText: String?
    public var returnValue: String?
    public var annotationText: String?
    public var colorTheme: String?
    public var customCode: String?
    public var groupName: String?
    
    // Jailed Mod Specific
    public var assetPath: String?
    public var replacementUrl: String?
    public var plistKey: String?
    public var plistValue: String?
    
    // Native Extension Specific
    public var viewTitle: String?
    public var swiftuiCode: String?
    public var extensionKind: String?
    
    // Flow Connections
    public var nextBlockId: String?
    public var elseBlockId: String?
    public var childrenBlockIds: [String]?

    public init(
        id: String = "block-\(UUID().uuidString.prefix(8))",
        type: BlockType,
        x: Double = 100,
        y: Double = 100,
        targetClass: String? = nil,
        targetMethod: String? = nil,
        isClassMethod: Bool? = false,
        returnType: String? = nil,
        assignToVar: String? = nil,
        message: String? = nil,
        logLevel: String? = "NSLog",
        targetObject: String? = nil,
        propertyName: String? = nil,
        value: String? = nil,
        condition: String? = nil,
        durationSeconds: Double? = 1.0,
        titleText: String? = nil,
        bodyText: String? = nil,
        returnValue: String? = nil,
        annotationText: String? = nil,
        colorTheme: String? = nil,
        customCode: String? = nil,
        groupName: String? = nil,
        assetPath: String? = nil,
        replacementUrl: String? = nil,
        plistKey: String? = nil,
        plistValue: String? = nil,
        viewTitle: String? = nil,
        swiftuiCode: String? = nil,
        extensionKind: String? = nil,
        nextBlockId: String? = nil,
        elseBlockId: String? = nil,
        childrenBlockIds: [String]? = []
    ) {
        self.id = id
        self.type = type
        self.x = x
        self.y = y
        self.targetClass = targetClass
        self.targetMethod = targetMethod
        self.isClassMethod = isClassMethod
        self.returnType = returnType
        self.assignToVar = assignToVar
        self.message = message
        self.logLevel = logLevel
        self.targetObject = targetObject
        self.propertyName = propertyName
        self.value = value
        self.condition = condition
        self.durationSeconds = durationSeconds
        self.titleText = titleText
        self.bodyText = bodyText
        self.returnValue = returnValue
        self.annotationText = annotationText
        self.colorTheme = colorTheme
        self.customCode = customCode
        self.groupName = groupName
        self.assetPath = assetPath
        self.replacementUrl = replacementUrl
        self.plistKey = plistKey
        self.plistValue = plistValue
        self.viewTitle = viewTitle
        self.swiftuiCode = swiftuiCode
        self.extensionKind = extensionKind
        self.nextBlockId = nextBlockId
        self.elseBlockId = elseBlockId
        self.childrenBlockIds = childrenBlockIds
    }
}
