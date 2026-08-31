import { AIServiceProvider, AIGenerationResponse, OpenRouterConfig } from "./types";
import { Project, BlockData } from "../../types";
import { validateBlockData } from "../blockRegistry";

const OPENROUTER_CONFIG_KEY = "the_workshop_openrouter_config";

export const DEFAULT_OPENROUTER_CONFIG: OpenRouterConfig = {
  apiKey: "",
  modelName: "anthropic/claude-3.5-sonnet",
  temperature: 0.7,
  customSystemPrompt: "",
  siteUrl: "https://theworkshop.app",
  siteName: "The Workshop iOS Studio"
};

export class OpenRouterProvider implements AIServiceProvider {
  id: "openrouter" = "openrouter";
  name = "OpenRouter AI";
  description = "Access 100+ top LLMs (Claude 3.5 Sonnet, DeepSeek R1, Llama 3.3 70B, Gemini 2.0) via a unified OpenRouter key.";

  public static getConfig(): OpenRouterConfig {
    try {
      const saved = localStorage.getItem(OPENROUTER_CONFIG_KEY);
      if (saved) {
        return { ...DEFAULT_OPENROUTER_CONFIG, ...JSON.parse(saved) };
      }
    } catch (e) {
      console.error("Failed to load OpenRouter config from localStorage", e);
    }
    return DEFAULT_OPENROUTER_CONFIG;
  }

  public static saveConfig(config: OpenRouterConfig): void {
    try {
      localStorage.setItem(OPENROUTER_CONFIG_KEY, JSON.stringify(config));
    } catch (e) {
      console.error("Failed to save OpenRouter config to localStorage", e);
    }
  }

  isAvailable(): boolean {
    const config = OpenRouterProvider.getConfig();
    return config.apiKey.trim().length > 0;
  }

  public static async testConnection(config: OpenRouterConfig): Promise<{ success: boolean; message: string }> {
    if (!config.apiKey.trim()) {
      return { success: false, message: "OpenRouter API Key is required." };
    }

    try {
      const res = await fetch("/api/openrouter/test-connection", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ config })
      });

      if (!res.ok) {
        const errJson = await res.json().catch(() => ({}));
        return {
          success: false,
          message: errJson.error || `HTTP ${res.status}: Failed to connect to OpenRouter API.`
        };
      }

      return {
        success: true,
        message: `Successfully connected to OpenRouter! Model ${config.modelName} is accessible.`
      };
    } catch (err: any) {
      return {
        success: false,
        message: `Connection failed: ${err.message || "Network error"}`
      };
    }
  }

  async generateBlocks(prompt: string, projectContext: Project): Promise<AIGenerationResponse> {
    const config = OpenRouterProvider.getConfig();
    if (!this.isAvailable()) {
      throw new Error("OpenRouter Provider requires a valid OpenRouter API Key in AI Settings.");
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
      const proxyRes = await fetch("/api/openrouter/generate", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ config, prompt, systemPrompt, mode: "generate-blocks" })
      });

      if (!proxyRes.ok) {
        const errJson = await proxyRes.json().catch(() => ({}));
        throw new Error(errJson.error || `HTTP ${proxyRes.status}: OpenRouter generation failed.`);
      }

      const proxyData = await proxyRes.json();
      jsonResponseText = proxyData.text || "";
    } catch (err: any) {
      throw new Error(`OpenRouter Error: ${err.message}`);
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
        id: b.id || `block-openrouter-${Date.now()}-${idx}`,
        position: b.position || { x: 160 + idx * 30, y: 120 + idx * 110 }
      })
    );

    return {
      blocks,
      text: parsed.explanation || jsonResponseText || `Generated logic graph using OpenRouter (${config.modelName})`,
      providerName: `OpenRouter (${config.modelName})`,
      modelIdentifier: config.modelName
    };
  }

  async chatAssist(prompt: string, projectContext: Project): Promise<string> {
    const config = OpenRouterProvider.getConfig();
    if (!this.isAvailable()) {
      return "OpenRouter Provider is not configured. Please enter your OpenRouter API Key in AI Settings.";
    }

    const systemPrompt = config.customSystemPrompt || `You are "The Workshop AI", an expert iOS reverse engineering mentor specializing in Logos/Theos hooks, jailed IPA modifications, and SwiftUI extension development. Project Target: ${projectContext.projectType}. Be clear, structured, and technically accurate.`;

    try {
      const proxyRes = await fetch("/api/openrouter/generate", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ config, prompt, systemPrompt, mode: "chat" })
      });

      if (!proxyRes.ok) {
        const errJson = await proxyRes.json().catch(() => ({}));
        throw new Error(errJson.error || `HTTP ${proxyRes.status}: OpenRouter API failed.`);
      }

      const proxyData = await proxyRes.json();
      return proxyData.text || "No response received from OpenRouter.";
    } catch (err: any) {
      return `Error querying OpenRouter: ${err.message}`;
    }
  }
}
