import React from "react";
import { BlockData, Project } from "../types";
import { BLOCK_TEMPLATES } from "./BlockPalette";
import { COMMON_IOS_HEADERS } from "../utils/mockHeaders";
import {
  Sliders,
  Trash2,
  Copy,
  Code,
  Layers,
  ChevronRight,
  Info,
  Sparkles,
  Link,
  Plus,
  Compass,
  Cpu,
  Activity,
  Zap
} from "lucide-react";

interface InspectorPanelProps {
  project: Project;
  selectedBlockId: string | null;
  onUpdateBlock: (updated: BlockData) => void;
  onDeleteBlock: (id: string) => void;
  onDuplicateBlock: (id: string) => void;
  onClose: () => void;
}

export const InspectorPanel: React.FC<InspectorPanelProps> = ({
  project,
  selectedBlockId,
  onUpdateBlock,
  onDeleteBlock,
  onDuplicateBlock,
  onClose,
}) => {
  if (!selectedBlockId) {
    return (
      <aside className="hidden md:flex w-80 bg-slate-950 border-l border-cyan-500/20 p-6 flex-col items-center justify-center text-center text-slate-500 font-mono text-xs z-20 shadow-2xl">
        <Sliders className="w-8 h-8 mb-3 text-cyan-500/40 animate-pulse" />
        <p className="font-extrabold text-slate-300 text-xs tracking-widest uppercase">INSPECTOR RIG IDLE</p>
        <p className="text-[10px] mt-2 text-slate-500 leading-relaxed">
          Select any blueprint node on the canvas to configure Objective-C class targets, methods, telemetry logs, or memory overrides.
        </p>
      </aside>
    );
  }

  const block = project.blocks.find((b) => b.id === selectedBlockId);

  if (!block) return null;

  const template = BLOCK_TEMPLATES.find((t) => t.type === block.type);

  return (
    <aside className="fixed inset-x-0 bottom-0 max-h-[85vh] w-full md:relative md:w-80 md:h-[calc(100vh-3rem)] md:inset-auto bg-slate-950 border-t md:border-t-0 md:border-l border-cyan-500/20 rounded-t-xl md:rounded-none p-4 overflow-y-auto z-40 text-slate-300 font-mono text-xs flex flex-col justify-between shadow-2xl">
      <div className="space-y-4">
        {/* Mobile Drag Indicator Handle */}
        <div className="md:hidden flex justify-center pb-1">
          <div className="w-10 h-1 bg-slate-800 rounded-full" />
        </div>

        {/* Instrument Panel Header */}
        <div className="flex items-center justify-between pb-3 border-b border-slate-800">
          <div className="flex items-center space-x-2">
            <div className="p-1.5 rounded bg-slate-900 border border-cyan-500/40 text-[#00F0FF]">
              {template?.icon}
            </div>
            <div>
              <div className="font-extrabold text-white text-xs">{block.title || template?.title}</div>
              <div className="text-[9px] text-[#00F0FF] font-bold uppercase tracking-wider flex items-center space-x-1">
                <span>MODULE: {block.type}</span>
                <span className="text-slate-600">//</span>
                <span className="text-slate-500 font-mono">#{block.id.slice(0, 5)}</span>
              </div>
            </div>
          </div>
          <button
            onClick={onClose}
            className="p-1 text-slate-500 hover:text-white rounded"
          >
            ✕
          </button>
        </div>

        {/* Title Customization */}
        <div className="space-y-1">
          <label className="text-[8px] uppercase text-slate-500 font-bold tracking-widest block">MODULE LABEL</label>
          <input
            type="text"
            value={block.title}
            onChange={(e) => onUpdateBlock({ ...block, title: e.target.value })}
            className="w-full bg-slate-900 border border-slate-800 rounded p-2 text-white text-xs focus:outline-none focus:border-[#00F0FF]"
          />
        </div>

        {/* 🪝 HOOK PROPERTIES */}
        {block.type === "hook" && (
          <div className="space-y-3 pt-2 border-t border-slate-800">
            <div>
              <label className="text-[8px] uppercase text-[#00F0FF] font-bold tracking-widest block mb-1">
                Target iOS Class
              </label>
              <input
                type="text"
                value={block.targetClass || ""}
                onChange={(e) => onUpdateBlock({ ...block, targetClass: e.target.value })}
                placeholder="e.g. SBLockScreenManager"
                className="w-full bg-slate-900 border border-slate-800 rounded p-2 text-[#00F0FF] font-bold text-xs focus:outline-none focus:border-[#00F0FF]"
              />
            </div>

            {/* Quick iOS Class Autocomplete Selector */}
            <div className="space-y-1">
              <label className="text-[8px] uppercase text-slate-500 tracking-widest block">Preset Framework Header</label>
              <select
                onChange={(e) => {
                  if (e.target.value) {
                    const info = COMMON_IOS_HEADERS.find((h) => h.className === e.target.value);
                    if (info) {
                      onUpdateBlock({
                        ...block,
                        targetClass: info.className,
                        targetMethod: info.commonMethods[0].replace(/^[+-]\s*\([^)]*\)/, "").trim(),
                      });
                    }
                  }
                }}
                className="w-full bg-slate-900 border border-slate-800 rounded p-1.5 text-slate-300 text-[10px]"
              >
                <option value="">Select preset header...</option>
                {COMMON_IOS_HEADERS.map((h) => (
                  <option key={h.className} value={h.className}>
                    {h.className} ({h.framework})
                  </option>
                ))}
              </select>
            </div>

            <div className="space-y-1">
              <label className="text-[8px] uppercase text-slate-500 font-bold tracking-widest block">Target Method</label>
              <input
                type="text"
                value={block.targetMethod || ""}
                onChange={(e) => onUpdateBlock({ ...block, targetMethod: e.target.value })}
                placeholder="e.g. viewDidAppear:"
                className="w-full bg-slate-900 border border-slate-800 rounded p-2 text-[#39FF14] text-xs focus:outline-none focus:border-[#39FF14]"
              />
            </div>

            <div className="grid grid-cols-2 gap-2">
              <div>
                <label className="text-[8px] uppercase text-slate-500 font-bold tracking-widest block mb-1">Scope</label>
                <select
                  value={block.isClassMethod ? "class" : "instance"}
                  onChange={(e) => onUpdateBlock({ ...block, isClassMethod: e.target.value === "class" })}
                  className="w-full bg-slate-900 border border-slate-800 rounded p-1.5 text-slate-300 text-[10px]"
                >
                  <option value="instance">- Instance (-)</option>
                  <option value="class">+ Class (+)</option>
                </select>
              </div>

              <div>
                <label className="text-[8px] uppercase text-slate-500 font-bold tracking-widest block mb-1">Return Type</label>
                <input
                  type="text"
                  value={block.returnType || "void"}
                  onChange={(e) => onUpdateBlock({ ...block, returnType: e.target.value })}
                  className="w-full bg-slate-900 border border-slate-800 rounded p-1.5 text-slate-300 text-[10px]"
                />
              </div>
            </div>
          </div>
        )}

        {/* 📝 LOG PROPERTIES */}
        {block.type === "log" && (
          <div className="space-y-3 pt-2 border-t border-slate-800">
            <div className="space-y-1">
              <label className="text-[8px] uppercase text-[#39FF14] font-bold tracking-widest block">Telemetry Console Log</label>
              <textarea
                rows={3}
                value={block.message || ""}
                onChange={(e) => onUpdateBlock({ ...block, message: e.target.value })}
                className="w-full bg-slate-900 border border-slate-800 rounded p-2 text-white text-xs focus:outline-none focus:border-[#39FF14]"
              />
            </div>
          </div>
        )}

        {/* ⚙️ MODIFY PROPERTY */}
        {block.type === "modify_property" && (
          <div className="space-y-3 pt-2 border-t border-slate-800">
            <div>
              <label className="text-[8px] uppercase text-[#00F0FF] font-bold tracking-widest block mb-1">Target Object</label>
              <input
                type="text"
                value={block.targetObject || "self"}
                onChange={(e) => onUpdateBlock({ ...block, targetObject: e.target.value })}
                className="w-full bg-slate-900 border border-slate-800 rounded p-2 text-white text-xs"
              />
            </div>
            <div>
              <label className="text-[8px] uppercase text-[#00F0FF] font-bold tracking-widest block mb-1">Property Name</label>
              <input
                type="text"
                value={block.propertyName || "view.alpha"}
                onChange={(e) => onUpdateBlock({ ...block, propertyName: e.target.value })}
                className="w-full bg-slate-900 border border-slate-800 rounded p-2 text-white text-xs"
              />
            </div>
            <div>
              <label className="text-[8px] uppercase text-[#00F0FF] font-bold tracking-widest block mb-1">Value Expression</label>
              <input
                type="text"
                value={block.value || "[UIColor systemGreenColor]"}
                onChange={(e) => onUpdateBlock({ ...block, value: e.target.value })}
                className="w-full bg-slate-900 border border-slate-800 rounded p-2 text-white text-xs"
              />
            </div>
          </div>
        )}

        {/* 🔄 CONDITIONAL */}
        {block.type === "conditional" && (
          <div className="space-y-3 pt-2 border-t border-slate-800">
            <div>
              <label className="text-[8px] uppercase text-[#39FF14] font-bold tracking-widest block mb-1">Condition Expression</label>
              <input
                type="text"
                value={block.condition || "self.view != nil"}
                onChange={(e) => onUpdateBlock({ ...block, condition: e.target.value })}
                className="w-full bg-slate-900 border border-slate-800 rounded p-2 text-[#39FF14] text-xs"
              />
            </div>
          </div>
        )}

        {/* ↩️ RETURN VALUE */}
        {block.type === "return_value" && (
          <div className="space-y-3 pt-2 border-t border-slate-800">
            <div>
              <label className="text-[8px] uppercase text-[#39FF14] font-bold tracking-widest block mb-1">Return Expression</label>
              <input
                type="text"
                value={block.returnValue || "YES"}
                onChange={(e) => onUpdateBlock({ ...block, returnValue: e.target.value })}
                className="w-full bg-slate-900 border border-slate-800 rounded p-2 text-[#39FF14] text-xs"
              />
            </div>
          </div>
        )}

        {/* 💬 ANNOTATION */}
        {block.type === "annotation" && (
          <div className="space-y-3 pt-2 border-t border-slate-800">
            <div>
              <label className="text-[8px] uppercase text-purple-400 font-bold tracking-widest block mb-1">Blueprint Note</label>
              <textarea
                rows={4}
                value={block.annotationText || ""}
                onChange={(e) => onUpdateBlock({ ...block, annotationText: e.target.value })}
                className="w-full bg-slate-900 border border-slate-800 rounded p-2 text-purple-300 text-xs font-mono"
              />
            </div>
          </div>
        )}

        {/* ➕ NEW METHOD */}
        {block.type === "new_method" && (
          <div className="space-y-3 pt-2 border-t border-slate-800">
            <div>
              <label className="text-[8px] uppercase text-amber-400 font-bold tracking-widest block mb-1">New Selector (%new)</label>
              <input
                type="text"
                value={block.targetMethod || ""}
                onChange={(e) => onUpdateBlock({ ...block, targetMethod: e.target.value })}
                placeholder="e.g. workshopCustomHandler"
                className="w-full bg-slate-900 border border-slate-800 rounded p-2 text-amber-400 text-xs"
              />
            </div>
            <div>
              <label className="text-[8px] uppercase text-slate-500 font-bold tracking-widest block mb-1">Return Type</label>
              <input
                type="text"
                value={block.returnType || "void"}
                onChange={(e) => onUpdateBlock({ ...block, returnType: e.target.value })}
                className="w-full bg-slate-900 border border-slate-800 rounded p-2 text-white text-xs"
              />
            </div>
          </div>
        )}

        {/* ⚡ CONSTRUCTOR / CODE */}
        {(block.type === "constructor" || block.type === "custom_logos") && (
          <div className="space-y-3 pt-2 border-t border-slate-800">
            <div>
              <label className="text-[8px] uppercase text-emerald-400 font-bold tracking-widest block mb-1">Raw Logos Code Snippet</label>
              <textarea
                rows={6}
                value={block.customCode || ""}
                onChange={(e) => onUpdateBlock({ ...block, customCode: e.target.value })}
                className="w-full bg-slate-900 border border-slate-800 rounded p-2 text-[#39FF14] text-xs font-mono"
              />
            </div>
          </div>
        )}

        {/* TECHNICAL SPECIFICATION BLUEPRINT PREVIEW */}
        <div className="pt-3 border-t border-slate-800 space-y-2">
          <div className="flex items-center space-x-1.5 text-[9px] font-bold text-[#00F0FF] uppercase tracking-wider">
            <Info className="w-3.5 h-3.5 text-[#00F0FF]" />
            <span>TECHNICAL SPECIFICATION & LOGOS SYNTAX</span>
          </div>

          <div className="bg-slate-900/80 border border-slate-800 rounded p-2.5 space-y-2 text-[10px] leading-relaxed text-slate-300">
            <p className="text-slate-300 font-sans">
              {getBlockExplanation(block.type)}
            </p>

            <div>
              <span className="text-[8px] text-slate-500 font-bold uppercase tracking-widest block mb-1">
                GENERATED CODE PREVIEW
              </span>
              <pre className="bg-slate-950 p-2 rounded border border-slate-800 text-[#39FF14] font-mono text-[9px] whitespace-pre-wrap overflow-x-auto shadow-inner">
                {getBlockCodePreview(block)}
              </pre>
            </div>
          </div>
        </div>
      </div>

      {/* Action Footer */}
      <div className="pt-4 border-t border-slate-800 space-y-2">
        <button
          onClick={() => onDuplicateBlock(block.id)}
          className="w-full py-1.5 bg-slate-900 hover:bg-slate-800 border border-slate-800 rounded text-slate-300 text-xs font-bold transition-all flex items-center justify-center space-x-1.5"
        >
          <Copy className="w-3.5 h-3.5" />
          <span>DUPLICATE MODULE</span>
        </button>

        <button
          onClick={() => onDeleteBlock(block.id)}
          className="w-full py-1.5 bg-rose-950/40 hover:bg-rose-900/60 border border-rose-500/30 rounded text-rose-300 text-xs font-bold transition-all flex items-center justify-center space-x-1.5"
        >
          <Trash2 className="w-3.5 h-3.5" />
          <span>PURGE MODULE</span>
        </button>
      </div>
    </aside>
  );
};

function getBlockExplanation(type: string): string {
  switch (type) {
    case "hook":
      return "Logos %hook ClassName intercepts method calls on any Objective-C class at runtime. It creates a dynamic swizzle hook using MobileSubstrate MSHookMessageEx.";
    case "orig":
      return "%orig calls the original unhooked system method. Always include %orig unless you intentionally want to suppress default iOS behavior.";
    case "skip_orig":
      return "Omitting %orig completely suppresses default iOS execution. Use this to disable system alerts, volume limits, or standard view controllers.";
    case "log":
      return "NSLog formats and writes messages to Apple System Log (syslog/OSLog). Inspect output live using Console.app or deviceconsole over USB/SSH.";
    case "modify_property":
      return "Directly mutates object properties or UI elements. In Objective-C, dot syntax (self.view.alpha) translates directly to message sends.";
    case "conditional":
      return "Evaluates an Objective-C boolean expression at runtime to dynamically branch tweak execution based on device state or preferences.";
    case "delay":
      return "Uses Grand Central Dispatch (dispatch_after) to schedule actions asynchronously on the main thread without blocking the user interface.";
    case "notification":
      return "Instantiates and presents a native UIAlertController on the key window's root view controller for system notifications or alerts.";
    case "return_value":
      return "Forces a specific method return value (e.g. returning YES for [SBLockScreenManager isUnlocked] to bypass authentication checks).";
    case "custom_logos":
      return "Inserts raw Objective-C / Logos code directly into the hooked method body for low-level or complex tweak operations.";
    case "annotation":
      return "Visual blueprint comment block for organizing visual tweak nodes into distinct functional subsystems.";
    case "new_method":
      return "%new declares a brand new Objective-C method selector on the hooked class that did not exist in the original iOS headers.";
    case "constructor":
      return "%ctor defines an entry point initializer executed immediately when dyld loads the tweak dynamic library (.dylib) into target memory.";
    case "group":
      return "%group clusters hooks together so they can be initialized selectively at runtime using %init(GroupName).";
    case "replace_asset":
      return "Jailed Modification: Replaces bundled images, sounds, or theme assets inside an unencrypted IPA package before resign.";
    case "edit_plist":
      return "Jailed Modification: Injects or modifies Info.plist keys (such as CFBundleDisplayName or UISupportedInterfaceOrientations) directly in the IPA.";
    case "swiftui_view":
      return "Native Extension: Declares a declarative SwiftUI component layout for iOS Widgets, App Extensions, or native companion screens.";
    case "extension_config":
      return "Native Extension: Configures extension target metadata, bundle identification, and WidgetKit entry points for native iOS integration.";
    default:
      return "Visual tweak node component for building iOS tweak dynamic libraries.";
  }
}

function getBlockCodePreview(block: BlockData): string {
  switch (block.type) {
    case "hook":
      return `%hook ${block.targetClass || "UIViewController"}\n${block.isClassMethod ? "+" : "-"} (${block.returnType || "void"})${block.targetMethod || "viewDidAppear:"} {\n    // Child tweak actions...\n}\n%end`;
    case "orig":
      return block.assignToVar ? `${block.assignToVar} = %orig;` : `%orig;`;
    case "skip_orig":
      return `// %orig suppressed - native method overridden`;
    case "log":
      return `NSLog(@"${block.message || "[TheWorkshop] Hook Triggered"}");`;
    case "modify_property":
      return `${block.targetObject || "self"}.${block.propertyName || "backgroundColor"} = ${block.value || "[UIColor redColor]"};`;
    case "conditional":
      return `if (${block.condition || "self != nil"}) {\n    // Conditional actions...\n}`;
    case "delay":
      return `dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(${block.durationSeconds || 1.5} * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{\n    // Delayed actions...\n});`;
    case "notification":
      return `UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"${block.titleText || "Alert"}" message:@"${block.bodyText || "Message"}" preferredStyle:UIAlertControllerStyleAlert];\n[alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];\n[[[UIApplication sharedApplication] keyWindow].rootViewController presentViewController:alert animated:YES completion:nil];`;
    case "return_value":
      return `return ${block.returnValue || "YES"};`;
    case "custom_logos":
      return block.customCode || `// Custom Logos snippet`;
    case "annotation":
      return `/* ${block.annotationText || "Canvas Note"} */`;
    case "new_method":
      return `%new\n- (${block.returnType || "void"})${block.targetMethod || "customMethod"} {\n    // New method logic\n}`;
    case "constructor":
      return `%ctor {\n    ${block.customCode || "NSLog(@\"Tweak loaded\");"}\n}`;
    case "group":
      return `%group ${block.groupName || "CustomGroup"}\n// Group hooks...\n%end`;
    case "replace_asset":
      return `cp "${block.replacementUrl || "new_asset.png"}" "extracted/Payload/App.app/${block.assetPath || "Assets.car"}"`;
    case "edit_plist":
      return `PlistBuddy -c "Set :${block.plistKey || "CFBundleDisplayName"} '${block.plistValue || "Modded App"}'" "extracted/Payload/App.app/Info.plist"`;
    case "swiftui_view":
      return `struct ${block.viewTitle || "CustomView"}: View {\n    var body: some View {\n        ${block.swiftuiCode || 'Text("Hello World")'}\n    }\n}`;
    case "extension_config":
      return `@main\nstruct ${block.titleText?.replace(/\s+/g, "") || "Widget"}Extension: Widget {\n    let kind: String = "${block.extensionKind || "widget"}"\n    // ...\n}`;
    default:
      return `// Block code output`;
  }
}

