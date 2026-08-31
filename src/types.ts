export type ProjectTargetType = "jailbreak_tweak" | "jailed_mod" | "native_extension";

export type BlockType =
  // Jailbreak Tweak Blocks
  | "hook"
  | "orig"
  | "skip_orig"
  | "log"
  | "modify_property"
  | "conditional"
  | "delay"
  | "notification"
  | "return_value"
  | "custom_logos"
  | "annotation"
  | "new_method"
  | "constructor"
  | "group"
  // Jailed Mod Blocks
  | "replace_asset"
  | "edit_plist"
  // Native Extension Blocks
  | "swiftui_view"
  | "extension_config";

export interface BlockData {
  id: string;
  type: BlockType;
  title: string;
  position: { x: number; y: number };
  
  // Annotation / Group
  annotationText?: string;
  groupName?: string;
  colorTheme?: string;
  width?: number;
  height?: number;

  // Hook & New Method
  targetClass?: string;
  targetMethod?: string;
  isClassMethod?: boolean;
  returnType?: string;
  methodParameters?: string;
  assignToVar?: string;

  // Log specific
  message?: string;
  logLevel?: "NSLog" | "os_log" | "HBLog";

  // Modify property
  targetObject?: string;
  propertyName?: string;
  value?: string;

  // Conditional
  condition?: string;

  // Delay
  durationSeconds?: number;

  // Notification
  titleText?: string;
  bodyText?: string;

  // Return value
  returnValue?: string;

  // Custom Logos code / Constructor
  customCode?: string;

  // Jailed Mod specific
  assetPath?: string;
  replacementUrl?: string;
  plistKey?: string;
  plistValue?: string;

  // Native Extension specific
  viewTitle?: string;
  swiftuiCode?: string;
  extensionKind?: string;

  // Connection/Flow
  nextBlockId?: string; // Sequential execution child
  elseBlockId?: string; // For conditional branches
  childrenBlockIds?: string[]; // Nested blocks inside hook
}

export interface Project {
  id: string;
  name: string;
  version: string;
  author: string;
  bundleId: string;
  projectType: ProjectTargetType;
  targetProcess: string;
  tweakFilter: string;
  description: string;
  createdAt: string;
  updatedAt: string;
  blocks: BlockData[];
}

export interface IOSClassInfo {
  className: string;
  framework: "UIKit" | "SpringBoard" | "Foundation" | "ControlCenter" | "UserNotifications" | "AudioToolbox";
  description: string;
  commonMethods: string[];
  suggestedTweakIdeas: string[];
}

export interface ChatMessage {
  id: string;
  sender: "user" | "gemini";
  text: string;
  timestamp: string;
  suggestedBlocks?: Partial<BlockData>[];
  suggestedClassName?: string;
  suggestedExplanation?: string;
  isGenerating?: boolean;
}

export type ViewMode = "studio" | "swiftui" | "code" | "headers";
