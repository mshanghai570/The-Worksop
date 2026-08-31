import { Project, BlockData } from "../../types";

export type AIProviderId =
  | "gemini"
  | "anthropic"
  | "openrouter"
  | "openai_compatible"
  | "local_gguf_mlx"
  | "offline_local"
  | "disabled";

export interface OpenAIConfig {
  apiKey: string;
  baseUrl: string;
  modelName: string;
  temperature: number;
  customSystemPrompt?: string;
}

export interface AnthropicConfig {
  apiKey: string;
  modelName: string;
  temperature: number;
  maxTokens: number;
  customSystemPrompt?: string;
}

export interface OpenRouterConfig {
  apiKey: string;
  modelName: string;
  temperature: number;
  customSystemPrompt?: string;
  siteUrl?: string;
  siteName?: string;
}

export interface LocalModelFile {
  id: string;
  name: string;
  format: "gguf" | "mlx";
  sizeMB: number;
  quantization: string;
  estimatedRAMGB: number;
  architecture: string;
  isLoaded: boolean;
  importedAt: string;
  filePath?: string;
  contextWindow?: number;
}

export interface AIGenerationResponse {
  blocks: BlockData[];
  text: string;
  providerName: string;
  modelIdentifier?: string;
}

export interface AIServiceProvider {
  id: AIProviderId;
  name: string;
  description: string;
  isAvailable(): boolean;
  generateBlocks(prompt: string, projectContext: Project): Promise<AIGenerationResponse>;
  chatAssist(prompt: string, projectContext: Project): Promise<string>;
}

