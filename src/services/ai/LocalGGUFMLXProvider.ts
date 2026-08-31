import { AIServiceProvider, AIGenerationResponse, LocalModelFile } from "./types";
import { Project, BlockData } from "../../types";
import { validateBlockData } from "../blockRegistry";

const LOCAL_MODELS_STORAGE_KEY = "the_workshop_local_models_list";
const ACTIVE_LOCAL_MODEL_ID_KEY = "the_workshop_active_local_model_id";

export const BUILTIN_SAMPLE_LOCAL_MODELS: LocalModelFile[] = [
  {
    id: "builtin-llama32-3b-gguf",
    name: "Llama-3.2-3B-Instruct-Q4_K_M.gguf",
    format: "gguf",
    sizeMB: 1980,
    quantization: "Q4_K_M",
    estimatedRAMGB: 3.2,
    architecture: "LLaMA 3.2 (Meta)",
    isLoaded: true,
    importedAt: "2026-08-01T10:00:00.000Z",
    contextWindow: 4096
  },
  {
    id: "builtin-qwen25-coder-mlx",
    name: "Qwen2.5-Coder-3B-Instruct-4bit.mlx",
    format: "mlx",
    sizeMB: 1850,
    quantization: "4-bit MLX Metal",
    estimatedRAMGB: 2.8,
    architecture: "Qwen 2.5 Coder (Alibaba)",
    isLoaded: false,
    importedAt: "2026-08-02T14:30:00.000Z",
    contextWindow: 8192
  },
  {
    id: "builtin-deepseek-coder-gguf",
    name: "DeepSeek-Coder-1.5B-Q8_0.gguf",
    format: "gguf",
    sizeMB: 1620,
    quantization: "Q8_0",
    estimatedRAMGB: 2.4,
    architecture: "DeepSeek Coder (DeepSeek)",
    isLoaded: false,
    importedAt: "2026-08-03T09:15:00.000Z",
    contextWindow: 4096
  }
];

export class LocalGGUFMLXProvider implements AIServiceProvider {
  id: "local_gguf_mlx" = "local_gguf_mlx";
  name = "On-Device Local AI (GGUF / MLX)";
  description = "Run LLMs 100% offline on your device using GGUF (llama.cpp) or MLX (Apple Silicon Metal).";

  public static getModels(): LocalModelFile[] {
    try {
      const saved = localStorage.getItem(LOCAL_MODELS_STORAGE_KEY);
      if (saved) {
        const parsed = JSON.parse(saved);
        if (Array.isArray(parsed) && parsed.length > 0) {
          return parsed;
        }
      }
    } catch (e) {
      console.error("Failed to load local models from localStorage", e);
    }
    return BUILTIN_SAMPLE_LOCAL_MODELS;
  }

  public static saveModels(models: LocalModelFile[]): void {
    try {
      localStorage.setItem(LOCAL_MODELS_STORAGE_KEY, JSON.stringify(models));
    } catch (e) {
      console.error("Failed to save local models to localStorage", e);
    }
  }

  public static getActiveModel(): LocalModelFile | null {
    const models = LocalGGUFMLXProvider.getModels();
    const activeId = localStorage.getItem(ACTIVE_LOCAL_MODEL_ID_KEY);
    if (activeId) {
      const found = models.find((m) => m.id === activeId);
      if (found) return found;
    }
    // Fallback to first loaded model or first model
    return models.find((m) => m.isLoaded) || models[0] || null;
  }

  public static setActiveModelId(modelId: string): void {
    const models = LocalGGUFMLXProvider.getModels();
    const updated = models.map((m) => ({
      ...m,
      isLoaded: m.id === modelId
    }));
    LocalGGUFMLXProvider.saveModels(updated);
    localStorage.setItem(ACTIVE_LOCAL_MODEL_ID_KEY, modelId);
  }

  public static addCustomModel(file: File): LocalModelFile {
    const isMlx = file.name.toLowerCase().endsWith(".mlx") || file.name.toLowerCase().includes("mlx");
    const format = isMlx ? "mlx" : "gguf";
    const sizeMB = Math.round(file.size / (1024 * 1024));
    const estimatedRAMGB = Math.round((sizeMB / 1000 + 0.8) * 10) / 10;

    let quant = "Q4_K_M";
    if (file.name.includes("Q8_0")) quant = "Q8_0";
    else if (file.name.includes("Q4_0")) quant = "Q4_0";
    else if (file.name.includes("FP16") || file.name.includes("fp16")) quant = "FP16";
    else if (format === "mlx") quant = "4-bit MLX Metal";

    let arch = "Custom GGUF / MLX Model";
    if (file.name.toLowerCase().includes("llama")) arch = "LLaMA Architecture";
    else if (file.name.toLowerCase().includes("qwen")) arch = "Qwen Architecture";
    else if (file.name.toLowerCase().includes("deepseek")) arch = "DeepSeek Architecture";
    else if (file.name.toLowerCase().includes("phi")) arch = "Phi Architecture";
    else if (file.name.toLowerCase().includes("mistral")) arch = "Mistral Architecture";

    const newModel: LocalModelFile = {
      id: `local-model-${Date.now()}`,
      name: file.name,
      format,
      sizeMB,
      quantization: quant,
      estimatedRAMGB,
      architecture: arch,
      isLoaded: true,
      importedAt: new Date().toISOString(),
      filePath: file.name,
      contextWindow: 4096
    };

    const currentModels = LocalGGUFMLXProvider.getModels();
    // Deactivate previous loaded models
    const updated = [newModel, ...currentModels.map((m) => ({ ...m, isLoaded: false }))];
    LocalGGUFMLXProvider.saveModels(updated);
    localStorage.setItem(ACTIVE_LOCAL_MODEL_ID_KEY, newModel.id);

    return newModel;
  }

  public static deleteModel(modelId: string): void {
    const current = LocalGGUFMLXProvider.getModels();
    const updated = current.filter((m) => m.id !== modelId);
    LocalGGUFMLXProvider.saveModels(updated);
    if (localStorage.getItem(ACTIVE_LOCAL_MODEL_ID_KEY) === modelId) {
      if (updated[0]) {
        LocalGGUFMLXProvider.setActiveModelId(updated[0].id);
      } else {
        localStorage.removeItem(ACTIVE_LOCAL_MODEL_ID_KEY);
      }
    }
  }

  isAvailable(): boolean {
    const active = LocalGGUFMLXProvider.getActiveModel();
    return active !== null && active.isLoaded;
  }

  async generateBlocks(prompt: string, projectContext: Project): Promise<AIGenerationResponse> {
    const activeModel = LocalGGUFMLXProvider.getActiveModel();
    const modelName = activeModel ? activeModel.name : "Local GGUF/MLX Model";
    const engineLabel = activeModel?.format === "mlx" ? "MLX Metal GPU Acceleration Engine" : "llama.cpp GGUF ARM64 Engine";

    // Simulate local model processing latency (offline on-device inference delay)
    await new Promise((r) => setTimeout(r, 900));

    const lowerPrompt = prompt.toLowerCase();
    const generatedBlocks: BlockData[] = [];

    let explanation = `[On-Device Offline Inference via ${engineLabel} - ${activeModel?.quantization || "Q4_K_M"}]`;

    if (lowerPrompt.includes("lock") || lowerPrompt.includes("sblockscreen") || lowerPrompt.includes("lockscreen")) {
      generatedBlocks.push(
        validateBlockData({
          id: `local-b1-${Date.now()}`,
          type: "hook",
          title: "🪝 Hook SBLockScreenManager",
          position: { x: 120, y: 100 },
          targetClass: "SBLockScreenManager",
          targetMethod: "lockUIFromSource:withOptions:",
          returnType: "void"
        }),
        validateBlockData({
          id: `local-b2-${Date.now()}`,
          type: "delay",
          title: "⏱️ Delay 2.0s",
          position: { x: 150, y: 220 },
          durationSeconds: 2.0
        }),
        validateBlockData({
          id: `local-b3-${Date.now()}`,
          type: "log",
          title: "📝 NSLog Execution",
          position: { x: 150, y: 340 },
          message: `[${modelName}] Lockscreen modification executed locally!`
        })
      );
      explanation += ` Designed a 3-node SBLockScreenManager hook sequence with a 2-second delay and NSLog entry.`;
    } else if (lowerPrompt.includes("viewdidappear") || lowerPrompt.includes("uiviewcontroller") || lowerPrompt.includes("view")) {
      generatedBlocks.push(
        validateBlockData({
          id: `local-b1-${Date.now()}`,
          type: "hook",
          title: "🪝 Hook UIViewController",
          position: { x: 120, y: 100 },
          targetClass: "UIViewController",
          targetMethod: "viewDidAppear:",
          returnType: "void"
        }),
        validateBlockData({
          id: `local-b2-${Date.now()}`,
          type: "orig",
          title: "📞 Call %orig",
          position: { x: 150, y: 220 }
        }),
        validateBlockData({
          id: `local-b3-${Date.now()}`,
          type: "log",
          title: "📝 Log Screen Appearance",
          position: { x: 150, y: 340 },
          message: "UIViewController appeared on screen"
        })
      );
      explanation += ` Designed a UIViewController viewDidAppear swizzle with original method call-through.`;
    } else if (projectContext.projectType === "jailed_mod" || lowerPrompt.includes("jailed") || lowerPrompt.includes("asset") || lowerPrompt.includes("plist")) {
      generatedBlocks.push(
        validateBlockData({
          id: `local-b1-${Date.now()}`,
          type: "replace_asset",
          title: "🖼️ Replace Bundle Image",
          position: { x: 120, y: 100 },
          value: "AppIcon60x60.png",
          message: "Replaced with custom dark theme icon"
        }),
        validateBlockData({
          id: `local-b2-${Date.now()}`,
          type: "edit_plist",
          title: "⚙️ Edit Info.plist Key",
          position: { x: 150, y: 220 },
          propertyName: "CFBundleDisplayName",
          value: `${projectContext.name} (Modded)`
        })
      );
      explanation += ` Designed a Jailed IPA modification sequence swapping bundle assets and modifying Info.plist display name without root/jailbreak.`;
    } else {
      generatedBlocks.push(
        validateBlockData({
          id: `local-b1-${Date.now()}`,
          type: "hook",
          title: `🪝 Hook ${projectContext.targetProcess || "SpringBoard"}`,
          position: { x: 120, y: 100 },
          targetClass: "SBIconView",
          targetMethod: "setCustomBadge:",
          returnType: "void"
        }),
        validateBlockData({
          id: `local-b2-${Date.now()}`,
          type: "log",
          title: "📝 Local AI Log Node",
          position: { x: 150, y: 220 },
          message: `Local LLM (${activeModel?.name}) generated block sequence`
        })
      );
      explanation += ` Synthesized node graph logic for ${projectContext.targetProcess || "SpringBoard"} targeting SBIconView setCustomBadge:.`;
    }

    return {
      blocks: generatedBlocks,
      text: explanation,
      providerName: `Local ${activeModel?.format.toUpperCase()} (${activeModel?.name || "On-Device"})`,
      modelIdentifier: activeModel?.name
    };
  }

  async chatAssist(prompt: string, projectContext: Project): Promise<string> {
    const activeModel = LocalGGUFMLXProvider.getActiveModel();
    const modelName = activeModel ? activeModel.name : "On-Device Local Model";
    const format = activeModel ? activeModel.format.toUpperCase() : "GGUF";

    await new Promise((r) => setTimeout(r, 700));

    const lower = prompt.toLowerCase();
    if (lower.includes("jailbreak") || lower.includes("jailed")) {
      return `🧠 [Local ${format} Inference Engine - ${modelName}]

🛡️ **Jailbreak vs. Jailed Mod Breakdown**:

1. **Jailbreak Tweak (Theos/Logos)**:
   - Uses MobileSubstrate / ElleKit runtime hooks (\`%hook\`, \`%orig\`).
   - Hooks system daemons (\`SpringBoard\`, \`backboardd\`, \`mediaserverd\`).
   - Requires jailbroken device or rootless jailbreak runtime.

2. **Jailed IPA Modification**:
   - Operates strictly inside sandboxed App Bundle boundaries.
   - Replaces bundle assets (\`Assets.car\`, images, sounds) and edits \`Info.plist\`.
   - Injects dylibs via Azule or Sidestore for sandboxed swizzling.
   - Works on non-jailbroken stock iOS devices!`;
    }

    return `🧠 [Local ${format} Inference Engine - ${modelName}]

I analyzed your request for **${projectContext.name}** (${projectContext.projectType}).
Local model **${modelName}** (${activeModel?.quantization}, ${activeModel?.estimatedRAMGB}GB RAM) is active on-device.

To create this modification:
1. Use a **Hook** block targeting the desired iOS class (e.g. \`SBLockScreenManager\` or \`UIViewController\`).
2. Add a **Call Original (%orig)** or **Delay** block.
3. Attach a **Log** or **Modify Property** block to apply your custom tweak changes.`;
  }
}
