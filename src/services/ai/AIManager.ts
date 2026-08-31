import { AIServiceProvider, AIProviderId, AIGenerationResponse } from "./types";
import { GeminiProvider } from "./GeminiProvider";
import { AnthropicProvider } from "./AnthropicProvider";
import { OpenRouterProvider } from "./OpenRouterProvider";
import { OpenAICompatibleProvider } from "./OpenAICompatibleProvider";
import { LocalGGUFMLXProvider } from "./LocalGGUFMLXProvider";
import { LocalRuleProvider } from "./LocalRuleProvider";
import { DisabledAIProvider } from "./DisabledAIProvider";
import { Project } from "../../types";

const AI_PROVIDER_STORAGE_KEY = "the_workshop_ai_provider_preference";

export class AIManager {
  private static providers: Record<AIProviderId, AIServiceProvider> = {
    gemini: new GeminiProvider(),
    anthropic: new AnthropicProvider(),
    openrouter: new OpenRouterProvider(),
    openai_compatible: new OpenAICompatibleProvider(),
    local_gguf_mlx: new LocalGGUFMLXProvider(),
    offline_local: new LocalRuleProvider(),
    disabled: new DisabledAIProvider()
  };

  private static activeProviderId: AIProviderId = AIManager.loadSavedProviderId();

  private static loadSavedProviderId(): AIProviderId {
    try {
      const saved = localStorage.getItem(AI_PROVIDER_STORAGE_KEY) as AIProviderId;
      if (saved && AIManager.providers[saved]) {
        return saved;
      }
    } catch (e) {
      // ignore
    }
    return "gemini"; // Default to Gemini, will automatically fallback to offline_local on failure
  }

  public static getActiveProviderId(): AIProviderId {
    return AIManager.activeProviderId;
  }

  public static setActiveProviderId(id: AIProviderId): void {
    if (AIManager.providers[id]) {
      AIManager.activeProviderId = id;
      try {
        localStorage.setItem(AI_PROVIDER_STORAGE_KEY, id);
      } catch (e) {
        // ignore
      }
    }
  }

  public static getActiveProvider(): AIServiceProvider {
    return AIManager.providers[AIManager.activeProviderId] || AIManager.providers.gemini;
  }

  public static getAllProviders(): AIServiceProvider[] {
    return Object.values(AIManager.providers);
  }

  /**
   * Generates block graph using active provider, with automatic fallback to offline local rule engine if network/API fails
   */
  public static async generateBlocks(prompt: string, projectContext: Project): Promise<AIGenerationResponse> {
    const provider = AIManager.getActiveProvider();

    if (provider.id === "disabled") {
      throw new Error("AI services are disabled in settings.");
    }

    try {
      return await provider.generateBlocks(prompt, projectContext);
    } catch (err: any) {
      console.warn(`Primary AI Provider (${provider.name}) failed: ${err.message}. Falling back to Offline Rule Engine.`);
      const fallbackProvider = AIManager.providers.offline_local;
      const result = await fallbackProvider.generateBlocks(prompt, projectContext);
      result.text = `[Fallback Notice: Primary AI unavailable (${err.message}). Used Offline Local Rule Engine]\n\n${result.text}`;
      return result;
    }
  }

  /**
   * Queries chat assist using active provider with fallback
   */
  public static async chatAssist(prompt: string, projectContext: Project): Promise<string> {
    const provider = AIManager.getActiveProvider();

    if (provider.id === "disabled") {
      return await provider.chatAssist(prompt, projectContext);
    }

    try {
      return await provider.chatAssist(prompt, projectContext);
    } catch (err: any) {
      console.warn(`Primary AI Provider (${provider.name}) failed: ${err.message}. Falling back to Offline Local Engine.`);
      const fallbackProvider = AIManager.providers.offline_local;
      return await fallbackProvider.chatAssist(prompt, projectContext);
    }
  }
}
