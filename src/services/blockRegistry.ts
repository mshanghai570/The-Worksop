import { BlockType, BlockData, ProjectTargetType } from "../types";

export interface BlockPropertyField {
  key: keyof BlockData;
  label: string;
  type: "text" | "number" | "boolean" | "select" | "code";
  options?: { label: string; value: string }[];
  placeholder?: string;
  description?: string;
}

export interface BlockDefinition {
  type: BlockType;
  title: string;
  category: "Hooking" | "Actions" | "Control Flow" | "Output" | "Jailed Modifications" | "Native Extension";
  badgeColor: string; // HEX or Tailwind color
  borderColor: string;
  textColor: string;
  description: string;
  supportedTargetTypes: ProjectTargetType[];
  defaultValues: Partial<BlockData>;
  fields: BlockPropertyField[];
}

export const BLOCK_REGISTRY: Record<BlockType, BlockDefinition> = {
  hook: {
    type: "hook",
    title: "Logos Method Hook",
    category: "Hooking",
    badgeColor: "#FF69B4",
    borderColor: "#FF69B4",
    textColor: "#FF69B4",
    description: "Hooks an Objective-C class and selector using Logos %hook syntax.",
    supportedTargetTypes: ["jailbreak_tweak", "jailed_mod"],
    defaultValues: {
      targetClass: "UIViewController",
      targetMethod: "viewDidAppear:",
      isClassMethod: false,
      returnType: "void",
      methodParameters: "BOOL animated"
    },
    fields: [
      { key: "targetClass", label: "Target Class Name", type: "text", placeholder: "e.g. SBLockScreenManager" },
      { key: "targetMethod", label: "Target Method Selector", type: "text", placeholder: "e.g. viewDidAppear:" },
      {
        key: "isClassMethod",
        label: "Method Type",
        type: "select",
        options: [
          { label: "Instance Method (-)", value: "false" },
          { label: "Class Method (+)", value: "true" }
        ]
      },
      { key: "returnType", label: "Return Type", type: "text", placeholder: "e.g. void or BOOL" },
      { key: "methodParameters", label: "Method Parameters Signature", type: "text", placeholder: "e.g. BOOL animated" }
    ]
  },
  orig: {
    type: "orig",
    title: "Call %orig",
    category: "Hooking",
    badgeColor: "#39FF14",
    borderColor: "#39FF14",
    textColor: "#39FF14",
    description: "Executes the original implementation of the hooked method.",
    supportedTargetTypes: ["jailbreak_tweak", "jailed_mod"],
    defaultValues: {
      assignToVar: ""
    },
    fields: [
      { key: "assignToVar", label: "Assign Return Value to Variable", type: "text", placeholder: "e.g. id originalResult = " }
    ]
  },
  skip_orig: {
    type: "skip_orig",
    title: "Suppress Original (%orig)",
    category: "Hooking",
    badgeColor: "#FF4500",
    borderColor: "#FF4500",
    textColor: "#FF4500",
    description: "Prevents original method execution (disables default iOS behavior).",
    supportedTargetTypes: ["jailbreak_tweak", "jailed_mod"],
    defaultValues: {},
    fields: []
  },
  log: {
    type: "log",
    title: "Console Log (NSLog)",
    category: "Output",
    badgeColor: "#00E5FF",
    borderColor: "#00E5FF",
    textColor: "#00E5FF",
    description: "Outputs a message to syslog or OSLog for debugging.",
    supportedTargetTypes: ["jailbreak_tweak", "jailed_mod", "native_extension"],
    defaultValues: {
      message: "[TheWorkshop] Tweak Hook Triggered",
      logLevel: "NSLog"
    },
    fields: [
      { key: "message", label: "Log Message Text", type: "text", placeholder: "e.g. [MyTweak] Hooked successfully" },
      {
        key: "logLevel",
        label: "Logging Framework",
        type: "select",
        options: [
          { label: "NSLog (Standard)", value: "NSLog" },
          { label: "os_log (Modern OS)", value: "os_log" },
          { label: "HBLog (Theos/Cydia)", value: "HBLog" }
        ]
      }
    ]
  },
  modify_property: {
    type: "modify_property",
    title: "Modify View / Property",
    category: "Actions",
    badgeColor: "#E040FB",
    borderColor: "#E040FB",
    textColor: "#E040FB",
    description: "Sets a property or view attribute on target object.",
    supportedTargetTypes: ["jailbreak_tweak", "jailed_mod", "native_extension"],
    defaultValues: {
      targetObject: "self.view",
      propertyName: "backgroundColor",
      value: "[UIColor systemPinkColor]"
    },
    fields: [
      { key: "targetObject", label: "Target Object", type: "text", placeholder: "e.g. self.view or self" },
      { key: "propertyName", label: "Property Name", type: "text", placeholder: "e.g. backgroundColor or hidden" },
      { key: "value", label: "Value / Objective-C Expression", type: "text", placeholder: "e.g. [UIColor redColor] or YES" }
    ]
  },
  conditional: {
    type: "conditional",
    title: "If / Else Condition",
    category: "Control Flow",
    badgeColor: "#FFD700",
    borderColor: "#FFD700",
    textColor: "#FFD700",
    description: "Branch execution based on a runtime Objective-C boolean expression.",
    supportedTargetTypes: ["jailbreak_tweak", "jailed_mod", "native_extension"],
    defaultValues: {
      condition: "self != nil"
    },
    fields: [
      { key: "condition", label: "Boolean Condition Expression", type: "text", placeholder: "e.g. [self isUnlocked] == YES" }
    ]
  },
  delay: {
    type: "delay",
    title: "Dispatch Delay (dispatch_after)",
    category: "Control Flow",
    badgeColor: "#00E676",
    borderColor: "#00E676",
    textColor: "#00E676",
    description: "Executes block actions after a specified time delay using GCD.",
    supportedTargetTypes: ["jailbreak_tweak", "jailed_mod", "native_extension"],
    defaultValues: {
      durationSeconds: 1.5
    },
    fields: [
      { key: "durationSeconds", label: "Delay Duration (Seconds)", type: "number", placeholder: "1.5" }
    ]
  },
  notification: {
    type: "notification",
    title: "UI Banner / Alert",
    category: "Output",
    badgeColor: "#FF9100",
    borderColor: "#FF9100",
    textColor: "#FF9100",
    description: "Presents a native UIAlertController on key window.",
    supportedTargetTypes: ["jailbreak_tweak", "jailed_mod", "native_extension"],
    defaultValues: {
      titleText: "The Workshop Alert",
      bodyText: "Tweak action executed live on device."
    },
    fields: [
      { key: "titleText", label: "Alert Title", type: "text", placeholder: "Alert Title" },
      { key: "bodyText", label: "Alert Body Message", type: "text", placeholder: "Message body..." }
    ]
  },
  return_value: {
    type: "return_value",
    title: "Override Return Value",
    category: "Control Flow",
    badgeColor: "#D500F9",
    borderColor: "#D500F9",
    textColor: "#D500F9",
    description: "Forces method to return a specific value, bypassing default return.",
    supportedTargetTypes: ["jailbreak_tweak", "jailed_mod"],
    defaultValues: {
      returnValue: "YES"
    },
    fields: [
      { key: "returnValue", label: "Return Value Expression", type: "text", placeholder: "e.g. YES, nil, or 100" }
    ]
  },
  custom_logos: {
    type: "custom_logos",
    title: "Custom Logos Code Block",
    category: "Actions",
    badgeColor: "#00B0FF",
    borderColor: "#00B0FF",
    textColor: "#00B0FF",
    description: "Raw Logos / Objective-C snippet inserted directly into method body.",
    supportedTargetTypes: ["jailbreak_tweak", "jailed_mod"],
    defaultValues: {
      customCode: "// Insert custom Logos snippet\nif ([self respondsToSelector:@selector(reload)]) {\n    [self reload];\n}"
    },
    fields: [
      { key: "customCode", label: "Logos / Obj-C Code Snippet", type: "code", placeholder: "// Code..." }
    ]
  },
  annotation: {
    type: "annotation",
    title: "Comment / Annotation Box",
    category: "Control Flow",
    badgeColor: "#7C4DFF",
    borderColor: "#7C4DFF",
    textColor: "#7C4DFF",
    description: "Unreal Blueprint style visual comment block for organizing canvas sections.",
    supportedTargetTypes: ["jailbreak_tweak", "jailed_mod", "native_extension"],
    defaultValues: {
      annotationText: "// Tweak Logic Annotation: LockScreen customization sub-system",
      colorTheme: "#7C4DFF"
    },
    fields: [
      { key: "annotationText", label: "Comment / Note Text", type: "text", placeholder: "Enter note..." },
      { key: "colorTheme", label: "Border Color Accent", type: "text", placeholder: "#7C4DFF" }
    ]
  },
  new_method: {
    type: "new_method",
    title: "Add New Method (%new)",
    category: "Hooking",
    badgeColor: "#FFAB00",
    borderColor: "#FFAB00",
    textColor: "#FFAB00",
    description: "Declares a brand new method on the target hooked class using Logos %new.",
    supportedTargetTypes: ["jailbreak_tweak", "jailed_mod"],
    defaultValues: {
      targetMethod: "workshopCustomAction",
      returnType: "void",
      methodParameters: ""
    },
    fields: [
      { key: "targetMethod", label: "New Method Name", type: "text", placeholder: "e.g. workshopCustomHandler" },
      { key: "returnType", label: "Return Type", type: "text", placeholder: "void" },
      { key: "methodParameters", label: "Method Parameters", type: "text", placeholder: "" }
    ]
  },
  constructor: {
    type: "constructor",
    title: "Tweak Initializer (%ctor)",
    category: "Hooking",
    badgeColor: "#64DD17",
    borderColor: "#64DD17",
    textColor: "#64DD17",
    description: "Executes on dynamic library load when the target process launches.",
    supportedTargetTypes: ["jailbreak_tweak", "jailed_mod"],
    defaultValues: {
      customCode: "NSLog(@\"[TheWorkshop] Tweak initialized in %s\", getprogname());"
    },
    fields: [
      { key: "customCode", label: "Constructor Code", type: "code", placeholder: "// Code..." }
    ]
  },
  group: {
    type: "group",
    title: "Logos Group (%group)",
    category: "Hooking",
    badgeColor: "#FF3D00",
    borderColor: "#FF3D00",
    textColor: "#FF3D00",
    description: "Groups hooks together so they can be selectively initialized with %init(Group).",
    supportedTargetTypes: ["jailbreak_tweak"],
    defaultValues: {
      groupName: "iOS16Hooks"
    },
    fields: [
      { key: "groupName", label: "Group Name", type: "text", placeholder: "e.g. LockScreenGroup" }
    ]
  },
  replace_asset: {
    type: "replace_asset",
    title: "Replace Bundle Asset",
    category: "Jailed Modifications",
    badgeColor: "#FF007F",
    borderColor: "#FF007F",
    textColor: "#FF007F",
    description: "Replaces image assets or audio files inside the target app bundle without code swizzling.",
    supportedTargetTypes: ["jailed_mod"],
    defaultValues: {
      assetPath: "AppIcon60x60@2x.png",
      replacementUrl: "https://workshop.internal/assets/custom_icon.png"
    },
    fields: [
      { key: "assetPath", label: "Target Asset Relative Path", type: "text", placeholder: "e.g. Assets.car or AppIcon60x60@2x.png" },
      { key: "replacementUrl", label: "Replacement Asset Source", type: "text", placeholder: "e.g. custom_icon.png" }
    ]
  },
  edit_plist: {
    type: "edit_plist",
    title: "Edit Info.plist / Entitlements",
    category: "Jailed Modifications",
    badgeColor: "#7B1FA2",
    borderColor: "#7B1FA2",
    textColor: "#7B1FA2",
    description: "Injects or overrides key-value metadata in Info.plist (e.g. UISupportedInterfaceOrientations, UIRequiresFullScreen).",
    supportedTargetTypes: ["jailed_mod"],
    defaultValues: {
      plistKey: "UIRequiresFullScreen",
      plistValue: "true"
    },
    fields: [
      { key: "plistKey", label: "Plist Key Name", type: "text", placeholder: "e.g. UISupportedInterfaceOrientations" },
      { key: "plistValue", label: "Plist Value (XML / String / Bool)", type: "text", placeholder: "e.g. true or <array>...</array>" }
    ]
  },
  swiftui_view: {
    type: "swiftui_view",
    title: "SwiftUI Widget / View Component",
    category: "Native Extension",
    badgeColor: "#00E676",
    borderColor: "#00E676",
    textColor: "#00E676",
    description: "Defines a native declarative SwiftUI view for lock screen widgets or app extensions.",
    supportedTargetTypes: ["native_extension", "jailed_mod"],
    defaultValues: {
      viewTitle: "WorkshopWidgetView",
      swiftuiCode: "Text(\"Workshop Widget\").font(.headline).foregroundStyle(.pink)"
    },
    fields: [
      { key: "viewTitle", label: "SwiftUI View Struct Name", type: "text", placeholder: "e.g. LockScreenWidgetView" },
      { key: "swiftuiCode", label: "SwiftUI Body Expression", type: "code", placeholder: "VStack { Text(\"Hello\") }" }
    ]
  },
  extension_config: {
    type: "extension_config",
    title: "Configure App Extension",
    category: "Native Extension",
    badgeColor: "#00B0FF",
    borderColor: "#00B0FF",
    textColor: "#00B0FF",
    description: "Configures WidgetKit / Keyboard / Share extension extension point identifier.",
    supportedTargetTypes: ["native_extension"],
    defaultValues: {
      extensionKind: "com.apple.widgetkit-extension",
      titleText: "Workshop LockScreen Widget"
    },
    fields: [
      { key: "extensionKind", label: "Extension Point Identifier", type: "text", placeholder: "e.g. com.apple.widgetkit-extension" },
      { key: "titleText", label: "Extension Display Name", type: "text", placeholder: "e.g. My Custom Extension" }
    ]
  }
};

/**
 * Validates a block object against data registry requirements
 */
export function validateBlockData(block: Partial<BlockData>): BlockData {
  const definition = BLOCK_REGISTRY[block.type as BlockType] || BLOCK_REGISTRY.hook;
  
  return {
    id: block.id || `block-${Date.now()}-${Math.floor(Math.random() * 1000)}`,
    type: definition.type,
    title: block.title || definition.title,
    position: block.position || { x: 150, y: 150 },
    annotationText: block.annotationText || definition.defaultValues.annotationText,
    groupName: block.groupName || definition.defaultValues.groupName,
    colorTheme: block.colorTheme || definition.defaultValues.colorTheme,
    width: block.width || 280,
    height: block.height || 140,
    targetClass: block.targetClass || definition.defaultValues.targetClass,
    targetMethod: block.targetMethod || definition.defaultValues.targetMethod,
    isClassMethod: block.isClassMethod ?? definition.defaultValues.isClassMethod,
    returnType: block.returnType || definition.defaultValues.returnType,
    methodParameters: block.methodParameters || definition.defaultValues.methodParameters,
    assignToVar: block.assignToVar || definition.defaultValues.assignToVar,
    message: block.message || definition.defaultValues.message,
    logLevel: block.logLevel || definition.defaultValues.logLevel,
    targetObject: block.targetObject || definition.defaultValues.targetObject,
    propertyName: block.propertyName || definition.defaultValues.propertyName,
    value: block.value || definition.defaultValues.value,
    condition: block.condition || definition.defaultValues.condition,
    durationSeconds: block.durationSeconds ?? definition.defaultValues.durationSeconds,
    titleText: block.titleText || definition.defaultValues.titleText,
    bodyText: block.bodyText || definition.defaultValues.bodyText,
    returnValue: block.returnValue || definition.defaultValues.returnValue,
    customCode: block.customCode || definition.defaultValues.customCode,
    assetPath: block.assetPath || definition.defaultValues.assetPath,
    replacementUrl: block.replacementUrl || definition.defaultValues.replacementUrl,
    plistKey: block.plistKey || definition.defaultValues.plistKey,
    plistValue: block.plistValue || definition.defaultValues.plistValue,
    viewTitle: block.viewTitle || definition.defaultValues.viewTitle,
    swiftuiCode: block.swiftuiCode || definition.defaultValues.swiftuiCode,
    extensionKind: block.extensionKind || definition.defaultValues.extensionKind,
    nextBlockId: block.nextBlockId,
    elseBlockId: block.elseBlockId,
    childrenBlockIds: block.childrenBlockIds || []
  };
}
