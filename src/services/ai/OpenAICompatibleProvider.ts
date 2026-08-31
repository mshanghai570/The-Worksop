import { AIServiceProvider, AIGenerationResponse, OpenAIConfig } from "./types";
import { Project, BlockData } from "../../types";
import { validateBlockData } from "../blockRegistry";

const OPENAI_CONFIG_STORAGE_KEY = "the_workshop_openai_config";

export const DEFAULT_OPENAI_CONFIG: OpenAIConfig = {
  apiKey: "",
  baseUrl: "https://api.openai.com/v1",
  modelName: "gpt-4o-mini",
  temperature: 0.7,
  customSystemPrompt: ""
};

export class OpenAICompatibleProvider implements AIServiceProvider {
  id: "openai_compatible" = "openai_compatible";
  name = "BYOK OpenAI Compatible";
  description = "Bring Your Own Key: Connect OpenAI, Groq, DeepSeek, Ollama, or any custom API endpoint.";

  public static getConfig(): OpenAIConfig {
    try {
      const saved = localStorage.getItem(OPENAI_CONFIG_STORAGE_KEY);
      if (saved) {
        return { ...DEFAULT_OPENAI_CONFIG, ...JSON.parse(saved) };
      }
    } catch (e) {
      console.error("Failed to load OpenAI config from localStorage", e);
    }
    return DEFAULT_OPENAI_CONFIG;
  }

  public static saveConfig(config: OpenAIConfig): void {
    try {
      localStorage.setItem(OPENAI_CONFIG_STORAGE_KEY, JSON.stringify(config));
    } catch (e) {
      console.error("Failed to save OpenAI config to localStorage", e);
    }
  }

  isAvailable(): boolean {
    const config = OpenAICompatibleProvider.getConfig();
    // Localhost endpoints (e.g., Ollama or LM Studio) don't strictly require API keys
    const isLocal = config.baseUrl.includes("localhost") || config.baseUrl.includes("127.0.0.1");
    return (isLocal || config.apiKey.trim().length > 0) && config.baseUrl.trim().length > 0;
  }

  public static async testConnection(config: OpenAIConfig): Promise<{ success: boolean; message: string; modelsCount?: number }> {
    const cleanUrl = config.baseUrl.replace(/\/+$/, "");
    const targetUrl = `${cleanUrl}/models`;

    try {
      const headers: Record<string, string> = {
        "Content-Type": "application/json"
      };
      if (config.apiKey.trim()) {
        headers["Authorization"] = `Bearer ${config.apiKey.trim()}`;
      }

      const controller = new AbortController();
      const timeoutId = setTimeout(() => controller.abort(), 8000);

      const res = await fetch(targetUrl, {
        method: "GET",
        headers,
        signal: controller.signal
      }).catch(async () => {
        // Fallback to server-side proxy endpoint if browser CORS blocks custom endpoint
        const proxyRes = await fetch("/api/openai-compatible/test-connection", {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({ config })
        });
        return proxyRes;
      });

      clearTimeout(timeoutId);

      if (!res.ok) {
        const text = await res.text().catch(() => "");
        return {
          success: false,
          message: `Endpoint responded with status ${res.status}: ${text || res.statusText}`
        };
      }

      const data = await res.json().catch(() => ({}));
      const modelsCount = Array.isArray(data?.data) ? data.data.length : undefined;

      return {
        success: true,
        message: `Successfully connected to ${cleanUrl}! Model ${config.modelName} is ready.`,
        modelsCount
      };
    } catch (err: any) {
      return {
        success: false,
        message: `Connection failed: ${err.message || "Network unreachable or CORS restricted"}`
      };
    }
  }

  async generateBlocks(prompt: string, projectContext: Project): Promise<AIGenerationResponse> {
    const config = OpenAICompatibleProvider.getConfig();
    if (!this.isAvailable()) {
      throw new Error("OpenAI Compatible Provider requires a valid API Key or Base URL in settings.");
    }

    const cleanUrl = config.baseUrl.replace(/\/+$/, "");
    const endpoint = `${cleanUrl}/chat/completions`;

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

    const headers: Record<string, string> = {
      "Content-Type": "application/json"
    };
    if (config.apiKey.trim()) {
      headers["Authorization"] = `Bearer ${config.apiKey.trim()}`;
    }

    const requestBody = {
      model: config.modelName || "gpt-4o-mini",
      temperature: config.temperature ?? 0.7,
      messages: [
        { role: "system", content: systemPrompt },
        { role: "user", content: prompt }
      ]
    };

    let jsonResponseText = "";

    try {
      // Try direct call
      const res = await fetch(endpoint, {
        method: "POST",
        headers,
        body: JSON.stringify(requestBody)
      });

      if (!res.ok) {
        throw new Error(`Provider HTTP ${res.status}: ${res.statusText}`);
      }

      const data = await res.json();
      jsonResponseText = data.choices?.[0]?.message?.content || "";
    } catch (directErr: any) {
      // Try backend proxy fallback
      const proxyRes = await fetch("/api/openai-compatible/generate", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ config, prompt, projectContext, mode: "generate-blocks" })
      });

      if (!proxyRes.ok) {
        const errJson = await proxyRes.json().catch(() => ({}));
        throw new Error(errJson.error || directErr.message || "Failed to reach OpenAI compatible endpoint.");
      }

      const proxyData = await proxyRes.json();
      jsonResponseText = proxyData.text || proxyData.content || "";
    }

    // Clean JSON markdown blocks if present
    const cleanedJson = jsonResponseText.replace(/```json/gi, "").replace(/```/g, "").trim();

    let parsed: any = {};
    try {
      parsed = JSON.parse(cleanedJson);
    } catch (e) {
      // If parsing fails, extract blocks array using regex or fallback
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
        id: b.id || `block-byok-${Date.now()}-${idx}`,
        position: b.position || { x: 160 + idx * 30, y: 120 + idx * 110 }
      })
    );

    return {
      blocks,
      text: parsed.explanation || jsonResponseText || `Generated logic graph using ${config.modelName}`,
      providerName: `${this.name} (${config.modelName})`,
      modelIdentifier: config.modelName
    };
  }

  async chatAssist(prompt: string, projectContext: Project): Promise<string> {
    const config = OpenAICompatibleProvider.getConfig();
    if (!this.isAvailable()) {
      return "OpenAI Compatible Provider is not configured. Please enter your API Key and Base URL in AI Settings.";
    }

    const cleanUrl = config.baseUrl.replace(/\/+$/, "");
    const endpoint = `${cleanUrl}/chat/completions`;

    const systemPrompt = config.customSystemPrompt || `You are "The Workshop AI", an expert iOS reverse engineering mentor specializing in Logos/Theos hooks, jailed IPA modifications, and SwiftUI extension development. Project Target: ${projectContext.projectType}. Be clear, structured, and technically accurate.`;

    const headers: Record<string, string> = {
      "Content-Type": "application/json"
    };
    if (config.apiKey.trim()) {
      headers["Authorization"] = `Bearer ${config.apiKey.trim()}`;
    }

    const requestBody = {
      model: config.modelName || "gpt-4o-mini",
      temperature: config.temperature ?? 0.7,
      messages: [
        { role: "system", content: systemPrompt },
        { role: "user", content: prompt }
      ]
    };

    try {
      const res = await fetch(endpoint, {
        method: "POST",
        headers,
        body: JSON.stringify(requestBody)
      });

      if (!res.ok) {
        throw new Error(`HTTP ${res.status}: ${res.statusText}`);
      }

      const data = await res.json();
      return data.choices?.[0]?.message?.content || "No response text received from provider.";
    } catch (directErr: any) {
      // Try server proxy fallback
      const proxyRes = await fetch("/api/openai-compatible/generate", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ config, prompt, projectContext, mode: "chat" })
      });

      if (!proxyRes.ok) {
        const errJson = await proxyRes.json().catch(() => ({}));
        throw new Error(errJson.error || directErr.message || "Failed to query OpenAI compatible endpoint.");
      }

      const proxyData = await proxyRes.json();
      return proxyData.text || "No response received from proxy endpoint.";
    }
  }
}
