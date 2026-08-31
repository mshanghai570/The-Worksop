import { AIServiceProvider, AIGenerationResponse } from "./types";
import { Project } from "../../types";

export class DisabledAIProvider implements AIServiceProvider {
  id: "disabled" = "disabled";
  name = "AI Disabled";
  description = "AI services are turned off. All block building, editing, and code generation run manually in the workspace.";

  isAvailable(): boolean {
    return false;
  }

  async generateBlocks(): Promise<AIGenerationResponse> {
    throw new Error("AI Assistant is currently disabled in settings. Enable AI Assistant or switch to Offline Local Mode.");
  }

  async chatAssist(): Promise<string> {
    return "AI Assistant is currently disabled in Settings. All visual block tools, code generators, and header explorers are fully operational manually without AI.";
  }
}
