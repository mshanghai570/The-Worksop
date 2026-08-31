import { AIServiceProvider, AIGenerationResponse } from "./types";
import { Project, BlockData } from "../../types";
import { validateBlockData } from "../blockRegistry";

export class LocalRuleProvider implements AIServiceProvider {
  id: "offline_local" = "offline_local";
  name = "Offline Rule Engine";
  description = "Deterministic local parser operating 100% offline without API keys or external AI calls.";

  isAvailable(): boolean {
    return true;
  }

  async generateBlocks(prompt: string, projectContext: Project): Promise<AIGenerationResponse> {
    const q = prompt.toLowerCase();

    // 1. Target Class Detection
    let targetClass = projectContext.targetProcess === "SpringBoard" ? "SBLockScreenManager" : "UIViewController";
    if (q.includes("sblockscreenmanager") || q.includes("lockscreen") || q.includes("lock screen")) {
      targetClass = "SBLockScreenManager";
    } else if (q.includes("sbiconview") || q.includes("icon") || q.includes("home screen")) {
      targetClass = "SBIconView";
    } else if (q.includes("sbapplication") || q.includes("app") || q.includes("springboard")) {
      targetClass = "SBApplication";
    } else if (q.includes("uibutton") || q.includes("button")) {
      targetClass = "UIButton";
    } else if (q.includes("uiviewcontroller") || q.includes("controller")) {
      targetClass = "UIViewController";
    } else if (q.includes("uiview") || q.includes("view")) {
      targetClass = "UIView";
    }

    // 2. Target Method Detection
    let targetMethod = "viewDidAppear:";
    if (q.includes("lockui") || q.includes("lock")) {
      targetMethod = "lockUIFromSource:withOptions:";
    } else if (q.includes("setlabel") || q.includes("label") || q.includes("badge")) {
      targetMethod = "setLabelHidden:";
    } else if (q.includes("viewwillappear")) {
      targetMethod = "viewWillAppear:";
    } else if (q.includes("viewdidload")) {
      targetMethod = "viewDidLoad";
    } else if (q.includes("background") || q.includes("layout")) {
      targetMethod = "layoutSubviews";
    }

    const hookId = `block-local-${Date.now()}-0`;
    const origId = `block-local-${Date.now()}-1`;
    const actionId = `block-local-${Date.now()}-2`;

    const blocks: BlockData[] = [
      validateBlockData({
        id: hookId,
        type: "hook",
        title: `🪝 Hook ${targetClass}`,
        position: { x: 140, y: 120 },
        targetClass,
        targetMethod,
        isClassMethod: false,
        returnType: "void",
        childrenBlockIds: [origId, actionId]
      }),
      validateBlockData({
        id: origId,
        type: "orig",
        title: "📞 Call %orig",
        position: { x: 180, y: 240 }
      })
    ];

    let explanation = `[Offline Rule Engine] Generated a Logos %hook for ${targetClass} (${targetMethod}).`;

    if (q.includes("delay") || q.includes("wait") || q.includes("timer")) {
      blocks.push(
        validateBlockData({
          id: actionId,
          type: "delay",
          title: "⏳ Dispatch Delay",
          position: { x: 180, y: 360 },
          durationSeconds: 2.0
        })
      );
      explanation += " Added dispatch_after 2.0s delay block.";
    } else if (q.includes("alert") || q.includes("notification") || q.includes("banner") || q.includes("popup")) {
      blocks.push(
        validateBlockData({
          id: actionId,
          type: "notification",
          title: "🔔 Alert Controller",
          position: { x: 180, y: 360 },
          titleText: `${projectContext.name} Alert`,
          bodyText: `Tweak action triggered in ${targetClass}!`
        })
      );
      explanation += " Added native UIAlertController banner.";
    } else if (q.includes("return") || q.includes("override") || q.includes("suppress") || q.includes("block")) {
      blocks.push(
        validateBlockData({
          id: actionId,
          type: "return_value",
          title: "↩️ Return Value",
          position: { x: 180, y: 360 },
          returnValue: "YES"
        })
      );
      explanation += " Added return value override.";
    } else if (q.includes("color") || q.includes("property") || q.includes("tint") || q.includes("hide")) {
      blocks.push(
        validateBlockData({
          id: actionId,
          type: "modify_property",
          title: "⚙️ Set Property",
          position: { x: 180, y: 360 },
          targetObject: "self.view",
          propertyName: q.includes("hide") ? "hidden" : "backgroundColor",
          value: q.includes("hide") ? "YES" : "[UIColor systemPinkColor]"
        })
      );
      explanation += " Added view property modification block.";
    } else {
      blocks.push(
        validateBlockData({
          id: actionId,
          type: "log",
          title: "📝 NSLog Message",
          position: { x: 180, y: 360 },
          message: `[${projectContext.name}] Hooked ${targetClass} ${targetMethod}`
        })
      );
      explanation += " Added NSLog console log statement.";
    }

    return {
      blocks,
      text: `${explanation}\n\nGenerated cleanly in offline mode without AI API calls. Code, Makefile, Control, and SwiftUI apps updated in workspace.`,
      providerName: this.name
    };
  }

  async chatAssist(prompt: string, projectContext: Project): Promise<string> {
    const q = prompt.toLowerCase();
    return `[Offline Knowledge Engine Response]

Regarding: "${prompt}"

Target Process: ${projectContext.targetProcess}
Target Filter: ${projectContext.tweakFilter}

Logos Recommendation:
To swizzle methods in iOS, use %hook followed by %orig in your method body.
You can view or edit all block properties in the Inspector panel or export your project as a zip at any time without internet access.`;
  }
}
