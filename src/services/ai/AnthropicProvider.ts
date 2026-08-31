import { AIServiceProvider, AIGenerationResponse, AnthropicConfig } from "./types";
import { Project, BlockData } from "../../types";
import { validateBlockData } from "../blockRegistry";

const ANTHROPIC_CONFIG_KEY = "the_workshop_anthropic_config";

export const DEFAULT_ANTHROPIC_CONFIG: AnthropicConfig = {
  apiKey: "",
  modelName: "claude-3-5-sonnet-20241022",
  temperature: 0.7,
  maxTokens: 4096,
  customSystemPrompt: ""
};

export class AnthropicProvider implements AIServiceProvider {
  id: "anthropic" = "anthropic";
  name = "Anthropic Claude";
  description = "Connect Anthropic Claude API for high-level reasoning and iOS code synthesis (Claude 3.5 Sonnet, Haiku, Opus).";

  public static getConfig(): AnthropicConfig {
    try {
      const saved = localStorage.getItem(ANTHROPIC_CONFIG_KEY);
      if (saved) {
        return { ...DEFAULT_ANTHROPIC_CONFIG, ...JSON.parse(saved) };
      }
    } catch (e) {
      console.error("Failed to load Anthropic config from localStorage", e);
    }
    return DEFAULT_ANTHROPIC_CONFIG;
  }

  public static saveConfig(config: AnthropicConfig): void {
    try {
      localStorage.setItem(ANTHROPIC_CONFIG_KEY, JSON.stringify(config));
    } catch (e) {
      console.error("Failed to save Anthropic config to localStorage", e);
    }
  }

  isAvailable(): boolean {
    const config = AnthropicProvider.getConfig();
    return config.apiKey.trim().length > 0;
  }

  public static async testConnection(config: AnthropicConfig): Promise<{ success: boolean; message: string }> {
    if (!config.apiKey.trim()) {
      return { success: false, message: "Anthropic API Key is required." };
    }

    try {
      const res = await fetch("/api/anthropic/test-connection", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ config })
      });

      if (!res.ok) {
        const errJson = await res.json().catch(() => ({}));
        return {
          success: false,
          message: errJson.error || `HTTP ${res.status}: Failed to authenticate with Anthropic API.`
        };
      }

      return {
        success: true,
        message: `Successfully connected to Anthropic API! Model ${config.modelName} is ready.`
      };
    } catch (err: any) {
      return {
        success: false,
        message: `Connection failed: ${err.message || "Network error"}`
      };
    }
  }

  async generateBlocks(prompt: string, projectContext: Project): Promise<AIGenerationResponse> {
    const config = AnthropicProvider.getConfig();
    if (!this.isAvailable()) {
      throw new Error("Anthropic Claude Provider requires a valid Anthropic API Key in Settings.");
    }

    const systemPrompt = `You are an expert iOS reverse engineering assistant for "The Workshop" visual modification studio.
Given a request, output a JSON object containing an array of visual modification block nodes.

Current Project Target: ${projectContext.projectType}
Project Target Bundle: ${projectContext.bundleId || "com.example.app"}

Output Schema ONLY (no markdown code blocks, just raw JSON):
{
  "explanation": "Brief explanation of the tweak logic",
  "blocks": [
    {
      "id": "block-1",
      "type": "hook" | "orig" | "log" | "modify_property" | "conditional" | "delay" | "notification" | "return_value" | "replace_asset" | "edit_plist" | "swiftui_view",
      "title": "Node title",
      "targetClass": "Target class name (e.g. UIViewController)",
      "targetMethod": "Target method name (e.g. viewDidAppear:)",
      "message": "Log message or detail text",
      "propertyName": "Property name if applicable",
      "value": "Value if applicable",
      "durationSeconds": 1.5
    }
  ]
}`;

    let jsonResponseText = "";

    try {
      const proxyRes = await fetch("/api/anthropic/generate", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ config, prompt, systemPrompt, mode: "generate-blocks" })
      });

      if (!proxyRes.ok) {
        const errJson = await proxyRes.json().catch(() => ({}));
        throw new Error(errJson.error || `HTTP ${proxyRes.status}: Anthropic request failed.`);
      }

      const proxyData = await proxyRes.json();
      jsonResponseText = proxyData.text || "";
    } catch (err: any) {
      throw new Error(`Anthropic Claude Error: ${err.message}`);
    }

    const cleanedJson = jsonResponseText.replace(/```json/gi, "").replace(/```/g, "").trim();

    let parsed: any = {};
    try {
      parsed = JSON.parse(cleanedJson);
    } catch (e) {
      const match = cleanedJson.match(/\{[\s\S]*\}/);
      if (match) {
        try {
          parsed = JSON.parse(match[0]);
        } catch (e2) {
          parsed = {};
        }
      }
    }

    const rawBlocks = Array.isArray(parsed.blocks) ? parsed.blocks : [];
    const blocks: BlockData[] = rawBlocks.map((b: any, idx: number) =>
      validateBlockData({
        ...b,
        id: b.id || `block-claude-${Date.now()}-${idx}`,
        position: b.position || { x: 160 + idx * 30, y: 120 + idx * 110 }
      })
    );

    return {
      blocks,
      text: parsed.explanation || jsonResponseText || `Generated logic graph using Anthropic ${config.modelName}`,
      providerName: `Anthropic Claude (${config.modelName})`,
      modelIdentifier: config.modelName
    };
  }

  async chatAssist(prompt: string, projectContext: Project): Promise<string> {
    const config = AnthropicProvider.getConfig();
    if (!this.isAvailable()) {
      return "Anthropic Claude Provider is not configured. Please enter your API Key in AI Settings.";
    }

    const systemPrompt = config.customSystemPrompt || `You are "The Workshop AI", an expert iOS reverse engineering mentor specializing in Logos/Theos hooks, jailed IPA modifications, and SwiftUI extension development. Project Target: ${projectContext.projectType}. Be clear, structured, and technically accurate.`;

    try {
      const proxyRes = await fetch("/api/anthropic/generate", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ config, prompt, systemPrompt, mode: "chat" })
      });

      if (!proxyRes.ok) {
        const errJson = await proxyRes.json().catch(() => ({}));
        throw new Error(errJson.error || `HTTP ${proxyRes.status}: Anthropic API failed.`);
      }

      const proxyData = await proxyRes.json();
      return proxyData.text || "No response received from Anthropic Claude.";
    } catch (err: any) {
      return `Error querying Anthropic Claude: ${err.message}`;
    }
  }
}
