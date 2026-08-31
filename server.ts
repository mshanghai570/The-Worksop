import express from "express";
import path from "path";
import { fileURLToPath } from "url";
import { createServer as createViteServer } from "vite";
import { GoogleGenAI } from "@google/genai";
import dotenv from "dotenv";

dotenv.config();

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

async function startServer() {
  const app = express();
  const PORT = 3000;

  app.use(express.json());

  // Initialize Gemini AI
  const ai = new GoogleGenAI({
    apiKey: process.env.GEMINI_API_KEY || "",
    httpOptions: {
      headers: {
        "User-Agent": "aistudio-build",
      },
    },
  });

  // API Endpoints
  app.get("/api/health", (req, res) => {
    res.json({ status: "ok", app: "The Workshop Backend" });
  });

  // Gemini AI Assistant endpoint
  app.post("/api/gemini/assist", async (req, res) => {
    try {
      const { prompt, projectContext, mode } = req.body;

      if (!process.env.GEMINI_API_KEY) {
        return res.status(500).json({
          error: "GEMINI_API_KEY is not configured in environment.",
        });
      }

      const systemInstruction = `You are "The Workshop AI", an expert iOS reverse engineer and modification architect.
The Workshop supports 3 distinct iOS Modification Project Targets:

1. JAILBREAK TWEAK PROJECT (jailbreak_tweak)
   - Uses Logos/Theos syntax (%hook, %orig, %group, %ctor, MobileSubstrate/ElleKit).
   - Capable of modifying system daemons, SpringBoard, kernel-level/rootless/rootful hooks, and cross-app swizzling.
   - Requirement: Jailbroken device or rootless jailbreak runtime.

2. JAILED MODIFICATION PROJECT (jailed_mod)
   - Operates within normal iOS app sandbox & signing restrictions (no jailbreak required).
   - Uses IPA repackaging, Optool/Azule dylib injection, Info.plist overrides, and bundle asset replacement (Images, Audio, Plists).
   - Ideal for sideloaded IPAs via AltStore, Sideloadly, or TrollStore.

3. NATIVE EXTENSION / APP PROJECT (native_extension)
   - Uses native Swift & SwiftUI frameworks (WidgetKit, App Extensions, Share Extensions, Custom UI views).
   - Compliant with App Store / official iOS capabilities.

GUIDANCE RULES FOR USER QUESTIONS:
- When users ask "Can I make this modification without jailbreak?" or inquire about jailbreak vs jailed limitations:
  - Explain clearly whether the requested behavior requires jailbreak access (e.g. system-wide SpringBoard hooking, cross-app swizzling, root filesystem access) or if it can be achieved as a Jailed Modification (IPA asset swap, Plist key injection, sandboxed dylib hook) or Native Extension.
  - Explain WHY a method requires jailbreak or why it can be packaged cleanly as an IPA or extension.
  - Recommend the appropriate Project Type ("jailbreak_tweak", "jailed_mod", or "native_extension").

Current Tweak/Mod Project Context:
${JSON.stringify(projectContext || {}, null, 2)}

Requested Task: ${mode || "general"}`;

      const response = await ai.models.generateContent({
        model: "gemini-3.6-flash",
        contents: prompt,
        config: {
          systemInstruction,
          temperature: 0.7,
        },
      });

      res.json({ text: response.text });
    } catch (error: any) {
      console.error("Gemini assistant error:", error);
      res.status(500).json({ error: error?.message || "Failed to query Gemini AI" });
    }
  });

  // Gemini AI Node Auto-Generator Endpoint (returns structured JSON blocks)
  app.post("/api/gemini/generate-blocks", async (req, res) => {
    try {
      const { prompt, projectContext } = req.body;

      if (!process.env.GEMINI_API_KEY) {
        return res.status(500).json({
          error: "GEMINI_API_KEY is not configured in environment.",
        });
      }

      const systemInstruction = `You are a visual block layout generator for "The Workshop" iOS Modification Studio.
Given a natural language request, generate a JSON representation of modification blocks compatible with the project target type (${projectContext?.projectType || "jailbreak_tweak"}).

Available block types across project targets:
1. Jailbreak Tweak Blocks:
   - hook: { id, type: "hook", targetClass, targetMethod, isClassMethod, returnType }
   - orig: { id, type: "orig", assignToVar }
   - skip_orig: { id, type: "skip_orig" }
   - log: { id, type: "log", message, logLevel: "NSLog" | "os_log" | "HBLog" }
   - modify_property: { id, type: "modify_property", targetObject, propertyName, value }
   - conditional: { id, type: "conditional", condition }
   - delay: { id, type: "delay", durationSeconds }
   - notification: { id, type: "notification", titleText, bodyText }
   - return_value: { id, type: "return_value", returnValue }
   - custom_logos: { id, type: "custom_logos", customCode }
   - group: { id, type: "group", groupName }

2. Jailed Modification Blocks:
   - replace_asset: { id, type: "replace_asset", assetPath, replacementUrl }
   - edit_plist: { id, type: "edit_plist", plistKey, plistValue }

3. Native Extension Blocks:
   - swiftui_view: { id, type: "swiftui_view", viewTitle, swiftuiCode }
   - extension_config: { id, type: "extension_config", extensionKind, titleText }

Return ONLY a valid JSON object matching this schema:
{
  "explanation": "Brief explanation of the generated modification workflow",
  "recommendedClassName": "Target iOS class name e.g. UIViewController or SBIconView",
  "blocks": [
    ... array of block objects with unique string ids (block-1, block-2, etc.)
  ]
}`;

      const response = await ai.models.generateContent({
        model: "gemini-3.6-flash",
        contents: prompt,
        config: {
          systemInstruction,
          responseMimeType: "application/json",
        },
      });

      res.json(JSON.parse(response.text || "{}"));
    } catch (error: any) {
      console.error("Gemini generate-blocks error:", error);
      res.status(500).json({ error: error?.message || "Failed to generate blocks" });
    }
  });

  // OpenAI Compatible Proxy Test Connection Endpoint
  app.post("/api/openai-compatible/test-connection", async (req, res) => {
    try {
      const { config } = req.body;
      if (!config || !config.baseUrl) {
        return res.status(400).json({ error: "Missing Base URL in OpenAI configuration." });
      }

      const cleanUrl = config.baseUrl.replace(/\/+$/, "");
      const targetUrl = `${cleanUrl}/models`;

      const headers: Record<string, string> = { "Content-Type": "application/json" };
      if (config.apiKey && config.apiKey.trim()) {
        headers["Authorization"] = `Bearer ${config.apiKey.trim()}`;
      }

      const response = await fetch(targetUrl, {
        method: "GET",
        headers
      });

      if (!response.ok) {
        const errText = await response.text().catch(() => "");
        return res.status(response.status).json({
          error: `Endpoint responded with status ${response.status}: ${errText || response.statusText}`
        });
      }

      const data = await response.json().catch(() => ({}));
      res.json({ success: true, modelsCount: Array.isArray(data?.data) ? data.data.length : undefined });
    } catch (err: any) {
      res.status(500).json({ error: `Proxy connection failed: ${err.message}` });
    }
  });

  // OpenAI Compatible Proxy Generation Endpoint
  app.post("/api/openai-compatible/generate", async (req, res) => {
    try {
      const { config, prompt, projectContext, mode } = req.body;
      if (!config || !config.baseUrl) {
        return res.status(400).json({ error: "Missing OpenAI configuration or Base URL." });
      }

      const cleanUrl = config.baseUrl.replace(/\/+$/, "");
      const endpoint = `${cleanUrl}/chat/completions`;

      const systemPrompt = mode === "generate-blocks"
        ? `You are a visual modification block graph generator for "The Workshop" iOS studio. Project Target: ${projectContext?.projectType || "jailbreak_tweak"}. Output valid JSON with "explanation" and "blocks" array.`
        : config.customSystemPrompt || `You are "The Workshop AI", an expert iOS reverse engineering mentor. Project Target: ${projectContext?.projectType || "jailbreak_tweak"}.`;

      const headers: Record<string, string> = { "Content-Type": "application/json" };
      if (config.apiKey && config.apiKey.trim()) {
        headers["Authorization"] = `Bearer ${config.apiKey.trim()}`;
      }

      const response = await fetch(endpoint, {
        method: "POST",
        headers,
        body: JSON.stringify({
          model: config.modelName || "gpt-4o-mini",
          temperature: config.temperature ?? 0.7,
          messages: [
            { role: "system", content: systemPrompt },
            { role: "user", content: prompt }
          ]
        })
      });

      if (!response.ok) {
        const errText = await response.text().catch(() => "");
        return res.status(response.status).json({
          error: `Provider HTTP ${response.status}: ${errText || response.statusText}`
        });
      }

      const data = await response.json();
      const content = data.choices?.[0]?.message?.content || "";
      res.json({ text: content, content });
    } catch (err: any) {
      res.status(500).json({ error: `Proxy generation error: ${err.message}` });
    }
  });

  // Anthropic Claude Proxy Endpoints
  app.post("/api/anthropic/test-connection", async (req, res) => {
    try {
      const { config } = req.body;
      if (!config || !config.apiKey) {
        return res.status(400).json({ error: "Missing Anthropic API Key." });
      }

      const response = await fetch("https://api.anthropic.com/v1/messages", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "x-api-key": config.apiKey.trim(),
          "anthropic-version": "2023-06-01"
        },
        body: JSON.stringify({
          model: config.modelName || "claude-3-5-sonnet-20241022",
          max_tokens: 10,
          messages: [{ role: "user", content: "Ping" }]
        })
      });

      if (!response.ok) {
        const errText = await response.text().catch(() => "");
        return res.status(response.status).json({
          error: `Anthropic API error ${response.status}: ${errText || response.statusText}`
        });
      }

      res.json({ success: true });
    } catch (err: any) {
      res.status(500).json({ error: `Anthropic connection error: ${err.message}` });
    }
  });

  app.post("/api/anthropic/generate", async (req, res) => {
    try {
      const { config, prompt, systemPrompt } = req.body;
      if (!config || !config.apiKey) {
        return res.status(400).json({ error: "Missing Anthropic API Key." });
      }

      const response = await fetch("https://api.anthropic.com/v1/messages", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "x-api-key": config.apiKey.trim(),
          "anthropic-version": "2023-06-01"
        },
        body: JSON.stringify({
          model: config.modelName || "claude-3-5-sonnet-20241022",
          max_tokens: config.maxTokens || 4096,
          temperature: config.temperature ?? 0.7,
          system: systemPrompt || "You are an AI assistant.",
          messages: [{ role: "user", content: prompt }]
        })
      });

      if (!response.ok) {
        const errText = await response.text().catch(() => "");
        return res.status(response.status).json({
          error: `Anthropic HTTP ${response.status}: ${errText || response.statusText}`
        });
      }

      const data = await response.json();
      const text = data.content?.[0]?.text || "";
      res.json({ text });
    } catch (err: any) {
      res.status(500).json({ error: `Anthropic proxy error: ${err.message}` });
    }
  });

  // OpenRouter Proxy Endpoints
  app.post("/api/openrouter/test-connection", async (req, res) => {
    try {
      const { config } = req.body;
      if (!config || !config.apiKey) {
        return res.status(400).json({ error: "Missing OpenRouter API Key." });
      }

      const response = await fetch("https://openrouter.ai/api/v1/models", {
        method: "GET",
        headers: {
          "Authorization": `Bearer ${config.apiKey.trim()}`,
          "HTTP-Referer": config.siteUrl || "https://theworkshop.app",
          "X-Title": config.siteName || "The Workshop iOS Studio"
        }
      });

      if (!response.ok) {
        const errText = await response.text().catch(() => "");
        return res.status(response.status).json({
          error: `OpenRouter error ${response.status}: ${errText || response.statusText}`
        });
      }

      res.json({ success: true });
    } catch (err: any) {
      res.status(500).json({ error: `OpenRouter connection error: ${err.message}` });
    }
  });

  app.post("/api/openrouter/generate", async (req, res) => {
    try {
      const { config, prompt, systemPrompt } = req.body;
      if (!config || !config.apiKey) {
        return res.status(400).json({ error: "Missing OpenRouter API Key." });
      }

      const response = await fetch("https://openrouter.ai/api/v1/chat/completions", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "Authorization": `Bearer ${config.apiKey.trim()}`,
          "HTTP-Referer": config.siteUrl || "https://theworkshop.app",
          "X-Title": config.siteName || "The Workshop iOS Studio"
        },
        body: JSON.stringify({
          model: config.modelName || "anthropic/claude-3.5-sonnet",
          temperature: config.temperature ?? 0.7,
          messages: [
            { role: "system", content: systemPrompt || "You are an AI assistant." },
            { role: "user", content: prompt }
          ]
        })
      });

      if (!response.ok) {
        const errText = await response.text().catch(() => "");
        return res.status(response.status).json({
          error: `OpenRouter HTTP ${response.status}: ${errText || response.statusText}`
        });
      }

      const data = await response.json();
      const text = data.choices?.[0]?.message?.content || "";
      res.json({ text });
    } catch (err: any) {
      res.status(500).json({ error: `OpenRouter proxy error: ${err.message}` });
    }
  });

  // Vite middleware for development
  if (process.env.NODE_ENV !== "production") {
    const vite = await createViteServer({
      server: { middlewareMode: true },
      appType: "spa",
    });
    app.use(vite.middlewares);
  } else {
    const distPath = path.join(process.cwd(), "dist");
    app.use(express.static(distPath));
    app.get("*", (req, res) => {
      res.sendFile(path.join(distPath, "index.html"));
    });
  }

  app.listen(PORT, "0.0.0.0", () => {
    console.log(`The Workshop server running on http://localhost:${PORT}`);
  });
}

startServer();
