import { AIServiceProvider, AIGenerationResponse } from "./types";
import { Project, BlockData } from "../../types";
import { validateBlockData } from "../blockRegistry";

export class GeminiProvider implements AIServiceProvider {
  id: "gemini" = "gemini";
  name = "Google Gemini AI";
  description = "Cloud AI model (gemini-3.6-flash) for generating iOS Logos swizzle block graphs.";

  isAvailable(): boolean {
    return true; // Endpoint reachable, handles missing key gracefully
  }

  async generateBlocks(prompt: string, projectContext: Project): Promise<AIGenerationResponse> {
    const res = await fetch("/api/gemini/generate-blocks", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ prompt, projectContext }),
    });

    if (!res.ok) {
      const errJson = await res.json().catch(() => ({}));
      throw new Error(errJson.error || "Gemini backend service error");
    }

    const data = await res.json();
    const rawBlocks = Array.isArray(data.blocks) ? data.blocks : [];

    const constructedBlocks: BlockData[] = rawBlocks.map((b: any, idx: number) => {
      return validateBlockData({
        ...b,
        id: b.id || `block-gemini-${Date.now()}-${idx}`,
        position: b.position || { x: 160 + idx * 20, y: 120 + idx * 100 }
      });
    });

    return {
      blocks: constructedBlocks,
      text: data.explanation || "Generated tweak block graph using Gemini AI.",
      providerName: this.name
    };
  }

  async chatAssist(prompt: string, projectContext: Project): Promise<string> {
    const res = await fetch("/api/gemini/assist", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ prompt, projectContext, mode: "general" }),
    });

    if (!res.ok) {
      const errJson = await res.json().catch(() => ({}));
      throw new Error(errJson.error || "Gemini assistant service unavailable");
    }

    const data = await res.json();
    return data.text || "No response received from Gemini.";
  }
}
