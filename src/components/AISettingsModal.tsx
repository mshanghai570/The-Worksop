import React, { useState, useEffect, useRef } from "react";
import { AIManager } from "../services/ai/AIManager";
import { OpenAICompatibleProvider, DEFAULT_OPENAI_CONFIG } from "../services/ai/OpenAICompatibleProvider";
import { AnthropicProvider, DEFAULT_ANTHROPIC_CONFIG } from "../services/ai/AnthropicProvider";
import { OpenRouterProvider, DEFAULT_OPENROUTER_CONFIG } from "../services/ai/OpenRouterProvider";
import { LocalGGUFMLXProvider } from "../services/ai/LocalGGUFMLXProvider";
import { AIProviderId, OpenAIConfig, AnthropicConfig, OpenRouterConfig, LocalModelFile } from "../services/ai/types";
import {
  X,
  Key,
  Globe,
  Cpu,
  Upload,
  Check,
  AlertTriangle,
  RefreshCw,
  HardDrive,
  Trash2,
  Sparkles,
  Zap,
  Sliders,
  ShieldCheck,
  FileCode,
  Layers,
  Activity,
  Bot,
  Compass
} from "lucide-react";

interface AISettingsModalProps {
  isOpen: boolean;
  onClose: () => void;
  onProviderChanged?: (providerId: AIProviderId) => void;
}

export const AISettingsModal: React.FC<AISettingsModalProps> = ({
  isOpen,
  onClose,
  onProviderChanged
}) => {
  const [activeProviderId, setActiveProviderId] = useState<AIProviderId>(AIManager.getActiveProviderId());

  // BYOK OpenAI Config State
  const [openAIConfig, setOpenAIConfig] = useState<OpenAIConfig>(OpenAICompatibleProvider.getConfig());
  
  // Anthropic Claude Config State
  const [anthropicConfig, setAnthropicConfig] = useState<AnthropicConfig>(AnthropicProvider.getConfig());

  // OpenRouter Config State
  const [openRouterConfig, setOpenRouterConfig] = useState<OpenRouterConfig>(OpenRouterProvider.getConfig());

  const [showApiKey, setShowApiKey] = useState(false);
  const [testStatus, setTestStatus] = useState<{ testing: boolean; message?: string; success?: boolean }>({ testing: false });

  // Local GGUF/MLX State
  const [localModels, setLocalModels] = useState<LocalModelFile[]>(LocalGGUFMLXProvider.getModels());
  const [activeLocalModel, setActiveLocalModel] = useState<LocalModelFile | null>(LocalGGUFMLXProvider.getActiveModel());
  const fileInputRef = useRef<HTMLInputElement>(null);

  useEffect(() => {
    if (isOpen) {
      setActiveProviderId(AIManager.getActiveProviderId());
      setOpenAIConfig(OpenAICompatibleProvider.getConfig());
      setAnthropicConfig(AnthropicProvider.getConfig());
      setOpenRouterConfig(OpenRouterProvider.getConfig());
      setLocalModels(LocalGGUFMLXProvider.getModels());
      setActiveLocalModel(LocalGGUFMLXProvider.getActiveModel());
      setTestStatus({ testing: false });
    }
  }, [isOpen]);

  if (!isOpen) return null;

  const handleProviderSelect = (id: AIProviderId) => {
    AIManager.setActiveProviderId(id);
    setActiveProviderId(id);
    if (onProviderChanged) onProviderChanged(id);
  };

  const handleSaveOpenAIConfig = () => {
    OpenAICompatibleProvider.saveConfig(openAIConfig);
    setTestStatus({ testing: false, success: true, message: "OpenAI Compatible configuration saved!" });
    setTimeout(() => setTestStatus({ testing: false }), 3000);
  };

  const handleTestOpenAIConnection = async () => {
    setTestStatus({ testing: true });
    const result = await OpenAICompatibleProvider.testConnection(openAIConfig);
    setTestStatus({
      testing: false,
      success: result.success,
      message: result.message
    });
  };

  const handleSaveAnthropicConfig = () => {
    AnthropicProvider.saveConfig(anthropicConfig);
    setTestStatus({ testing: false, success: true, message: "Anthropic Claude configuration saved!" });
    setTimeout(() => setTestStatus({ testing: false }), 3000);
  };

  const handleTestAnthropicConnection = async () => {
    setTestStatus({ testing: true });
    const result = await AnthropicProvider.testConnection(anthropicConfig);
    setTestStatus({
      testing: false,
      success: result.success,
      message: result.message
    });
  };

  const handleSaveOpenRouterConfig = () => {
    OpenRouterProvider.saveConfig(openRouterConfig);
    setTestStatus({ testing: false, success: true, message: "OpenRouter configuration saved!" });
    setTimeout(() => setTestStatus({ testing: false }), 3000);
  };

  const handleTestOpenRouterConnection = async () => {
    setTestStatus({ testing: true });
    const result = await OpenRouterProvider.testConnection(openRouterConfig);
    setTestStatus({
      testing: false,
      success: result.success,
      message: result.message
    });
  };

  const handlePresetSelect = (presetKey: string) => {
    let updated: OpenAIConfig = { ...openAIConfig };
    switch (presetKey) {
      case "openai":
        updated = {
          ...updated,
          baseUrl: "https://api.openai.com/v1",
          modelName: "gpt-4o-mini"
        };
        break;
      case "groq":
        updated = {
          ...updated,
          baseUrl: "https://api.groq.com/openai/v1",
          modelName: "llama-3.3-70b-versatile"
        };
        break;
      case "deepseek":
        updated = {
          ...updated,
          baseUrl: "https://api.deepseek.com/v1",
          modelName: "deepseek-coder"
        };
        break;
      case "together":
        updated = {
          ...updated,
          baseUrl: "https://api.together.xyz/v1",
          modelName: "Qwen/Qwen2.5-Coder-32B-Instruct"
        };
        break;
      case "ollama":
        updated = {
          ...updated,
          baseUrl: "http://localhost:11434/v1",
          modelName: "llama3.2:3b",
          apiKey: updated.apiKey || "ollama"
        };
        break;
      case "lmstudio":
        updated = {
          ...updated,
          baseUrl: "http://localhost:1234/v1",
          modelName: "local-model",
          apiKey: updated.apiKey || "lm-studio"
        };
        break;
    }
    setOpenAIConfig(updated);
  };

  const handleFileUpload = (e: React.ChangeEvent<HTMLInputElement>) => {
    const files = e.target.files;
    if (!files || files.length === 0) return;

    for (let i = 0; i < files.length; i++) {
      const file = files[i];
      LocalGGUFMLXProvider.addCustomModel(file);
    }

    const refreshed = LocalGGUFMLXProvider.getModels();
    setLocalModels(refreshed);
    setActiveLocalModel(LocalGGUFMLXProvider.getActiveModel());
  };

  const handleSelectActiveModel = (modelId: string) => {
    LocalGGUFMLXProvider.setActiveModelId(modelId);
    setLocalModels(LocalGGUFMLXProvider.getModels());
    setActiveLocalModel(LocalGGUFMLXProvider.getActiveModel());
  };

  const handleDeleteModel = (modelId: string) => {
    LocalGGUFMLXProvider.deleteModel(modelId);
    setLocalModels(LocalGGUFMLXProvider.getModels());
    setActiveLocalModel(LocalGGUFMLXProvider.getActiveModel());
  };

  return (
    <div className="fixed inset-0 z-50 bg-black/80 backdrop-blur-sm flex items-center justify-center p-4 font-mono text-xs animate-in fade-in duration-150">
      <div className="w-full max-w-2xl bg-[#0a0a0a] border border-[#222] rounded-lg shadow-2xl overflow-hidden flex flex-col max-h-[90vh]">
        {/* Modal Header */}
        <div className="h-12 bg-black border-b border-[#222] px-4 flex items-center justify-between">
          <div className="flex items-center space-x-2">
            <Sparkles className="w-4 h-4 text-[#39FF14]" />
            <span className="font-bold text-sm text-white uppercase tracking-wider">
              AI Engines & Model Configuration
            </span>
          </div>

          <button
            onClick={onClose}
            className="p-1.5 rounded text-gray-500 hover:text-white hover:bg-[#222] transition-all"
          >
            <X className="w-4 h-4" />
          </button>
        </div>

        {/* Engine Tabs Bar */}
        <div className="p-3 bg-[#111] border-b border-[#222] flex items-center gap-2 overflow-x-auto">
          <button
            onClick={() => handleProviderSelect("gemini")}
            className={`px-3 py-2 rounded text-xs font-bold transition-all flex items-center space-x-2 shrink-0 ${
              activeProviderId === "gemini"
                ? "bg-[#222] text-[#39FF14] border border-[#39FF14]"
                : "bg-black text-gray-400 hover:text-white border border-[#222]"
            }`}
          >
            <Sparkles className="w-3.5 h-3.5 text-[#39FF14]" />
            <span>Gemini</span>
          </button>

          <button
            onClick={() => handleProviderSelect("anthropic")}
            className={`px-3 py-2 rounded text-xs font-bold transition-all flex items-center space-x-2 shrink-0 ${
              activeProviderId === "anthropic"
                ? "bg-[#222] text-orange-400 border border-orange-400"
                : "bg-black text-gray-400 hover:text-white border border-[#222]"
            }`}
          >
            <Bot className="w-3.5 h-3.5 text-orange-400" />
            <span>Anthropic Claude</span>
          </button>

          <button
            onClick={() => handleProviderSelect("openrouter")}
            className={`px-3 py-2 rounded text-xs font-bold transition-all flex items-center space-x-2 shrink-0 ${
              activeProviderId === "openrouter"
                ? "bg-[#222] text-purple-400 border border-purple-400"
                : "bg-black text-gray-400 hover:text-white border border-[#222]"
            }`}
          >
            <Compass className="w-3.5 h-3.5 text-purple-400" />
            <span>OpenRouter</span>
          </button>

          <button
            onClick={() => handleProviderSelect("openai_compatible")}
            className={`px-3 py-2 rounded text-xs font-bold transition-all flex items-center space-x-2 shrink-0 ${
              activeProviderId === "openai_compatible"
                ? "bg-[#222] text-cyan-400 border border-cyan-400"
                : "bg-black text-gray-400 hover:text-white border border-[#222]"
            }`}
          >
            <Key className="w-3.5 h-3.5 text-cyan-400" />
            <span>OpenAI (BYOK)</span>
          </button>

          <button
            onClick={() => handleProviderSelect("local_gguf_mlx")}
            className={`px-3 py-2 rounded text-xs font-bold transition-all flex items-center space-x-2 shrink-0 ${
              activeProviderId === "local_gguf_mlx"
                ? "bg-[#222] text-[#FF69B4] border border-[#FF69B4]"
                : "bg-black text-gray-400 hover:text-white border border-[#222]"
            }`}
          >
            <Cpu className="w-3.5 h-3.5 text-[#FF69B4]" />
            <span>Local GGUF/MLX</span>
          </button>

          <button
            onClick={() => handleProviderSelect("offline_local")}
            className={`px-3 py-2 rounded text-xs font-bold transition-all flex items-center space-x-2 shrink-0 ${
              activeProviderId === "offline_local"
                ? "bg-[#222] text-amber-400 border border-amber-400"
                : "bg-black text-gray-400 hover:text-white border border-[#222]"
            }`}
          >
            <HardDrive className="w-3.5 h-3.5 text-amber-400" />
            <span>Offline Rules</span>
          </button>
        </div>

        {/* Modal Main Content */}
        <div className="flex-1 p-5 overflow-y-auto space-y-6">
          {/* TAB 1: GEMINI AI */}
          {activeProviderId === "gemini" && (
            <div className="space-y-4">
              <div className="p-4 bg-[#111] border border-[#222] rounded-lg space-y-2">
                <div className="flex items-center space-x-2 text-[#39FF14] font-bold text-sm">
                  <Sparkles className="w-4 h-4" />
                  <span>Google Gemini Cloud AI (Built-in)</span>
                </div>
                <p className="text-gray-400 leading-relaxed">
                  Uses the hosted <code className="text-[#39FF14]">gemini-3.6-flash</code> model via server API key. Provides fast generation for iOS Logos hooks, Jailed IPA asset swaps, and visual logic graph synthesis.
                </p>
              </div>

              <div className="p-3 bg-black border border-[#222] rounded text-gray-400 text-[11px] flex items-center space-x-2">
                <ShieldCheck className="w-4 h-4 text-[#39FF14] shrink-0" />
                <span>Ready to use out-of-the-box. Automatic fallback to local offline rule engine if network drops.</span>
              </div>
            </div>
          )}

          {/* TAB 2: ANTHROPIC CLAUDE */}
          {activeProviderId === "anthropic" && (
            <div className="space-y-5">
              <div className="space-y-1">
                <h3 className="text-sm font-bold text-white flex items-center space-x-2">
                  <Bot className="w-4 h-4 text-orange-400" />
                  <span>Anthropic Claude API Configuration</span>
                </h3>
                <p className="text-gray-400 text-[11px]">
                  Connect your Anthropic API Key for Claude 3.5 Sonnet, Claude 3.5 Haiku, and Claude 3 Opus.
                </p>
              </div>

              {/* Model Select Buttons */}
              <div className="space-y-1.5">
                <label className="text-[10px] text-gray-500 uppercase tracking-widest font-bold">
                  Quick Model Presets
                </label>
                <div className="flex flex-wrap gap-1.5">
                  <button
                    onClick={() => setAnthropicConfig({ ...anthropicConfig, modelName: "claude-3-5-sonnet-20241022" })}
                    className={`px-2.5 py-1 border rounded text-[10px] font-bold transition-all ${
                      anthropicConfig.modelName === "claude-3-5-sonnet-20241022"
                        ? "bg-orange-950/60 border-orange-500 text-orange-300"
                        : "bg-[#111] hover:bg-[#222] border-[#333] text-gray-300"
                    }`}
                  >
                    Claude 3.5 Sonnet
                  </button>
                  <button
                    onClick={() => setAnthropicConfig({ ...anthropicConfig, modelName: "claude-3-5-haiku-20241022" })}
                    className={`px-2.5 py-1 border rounded text-[10px] font-bold transition-all ${
                      anthropicConfig.modelName === "claude-3-5-haiku-20241022"
                        ? "bg-orange-950/60 border-orange-500 text-orange-300"
                        : "bg-[#111] hover:bg-[#222] border-[#333] text-gray-300"
                    }`}
                  >
                    Claude 3.5 Haiku
                  </button>
                  <button
                    onClick={() => setAnthropicConfig({ ...anthropicConfig, modelName: "claude-3-opus-20240229" })}
                    className={`px-2.5 py-1 border rounded text-[10px] font-bold transition-all ${
                      anthropicConfig.modelName === "claude-3-opus-20240229"
                        ? "bg-orange-950/60 border-orange-500 text-orange-300"
                        : "bg-[#111] hover:bg-[#222] border-[#333] text-gray-300"
                    }`}
                  >
                    Claude 3 Opus
                  </button>
                </div>
              </div>

              <div className="space-y-3 p-4 bg-[#111] border border-[#222] rounded-lg">
                <div className="space-y-1">
                  <label className="text-[10px] text-gray-400 uppercase tracking-wider font-bold">
                    Anthropic API Key
                  </label>
                  <div className="relative flex items-center">
                    <input
                      type={showApiKey ? "text" : "password"}
                      value={anthropicConfig.apiKey}
                      onChange={(e) => setAnthropicConfig({ ...anthropicConfig, apiKey: e.target.value })}
                      placeholder="sk-ant-api03-..."
                      className="w-full bg-black border border-[#333] rounded px-3 py-2 text-xs text-white placeholder-gray-600 focus:outline-none focus:border-orange-400 pr-16"
                    />
                    <button
                      type="button"
                      onClick={() => setShowApiKey(!showApiKey)}
                      className="absolute right-2 px-2 py-0.5 text-[9px] bg-[#222] text-gray-300 rounded hover:text-white"
                    >
                      {showApiKey ? "Hide" : "Show"}
                    </button>
                  </div>
                </div>

                <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                  <div className="space-y-1">
                    <label className="text-[10px] text-gray-400 uppercase tracking-wider font-bold">
                      Model Identifier
                    </label>
                    <input
                      type="text"
                      value={anthropicConfig.modelName}
                      onChange={(e) => setAnthropicConfig({ ...anthropicConfig, modelName: e.target.value })}
                      placeholder="claude-3-5-sonnet-20241022"
                      className="w-full bg-black border border-[#333] rounded px-3 py-2 text-xs text-white placeholder-gray-600 focus:outline-none focus:border-orange-400"
                    />
                  </div>

                  <div className="space-y-1">
                    <label className="text-[10px] text-gray-400 uppercase tracking-wider font-bold flex justify-between">
                      <span>Max Tokens</span>
                      <span className="text-orange-400">{anthropicConfig.maxTokens}</span>
                    </label>
                    <input
                      type="number"
                      value={anthropicConfig.maxTokens}
                      onChange={(e) => setAnthropicConfig({ ...anthropicConfig, maxTokens: parseInt(e.target.value) || 4096 })}
                      className="w-full bg-black border border-[#333] rounded px-3 py-2 text-xs text-white placeholder-gray-600 focus:outline-none focus:border-orange-400"
                    />
                  </div>
                </div>
              </div>

              {/* Status Notice */}
              {testStatus.message && (
                <div
                  className={`p-3 rounded border text-xs flex items-center space-x-2 ${
                    testStatus.success
                      ? "bg-emerald-950/40 border-emerald-500 text-emerald-300"
                      : "bg-red-950/40 border-red-500 text-red-300"
                  }`}
                >
                  {testStatus.success ? <Check className="w-4 h-4 shrink-0 text-emerald-400" /> : <AlertTriangle className="w-4 h-4 shrink-0 text-red-400" />}
                  <span>{testStatus.message}</span>
                </div>
              )}

              {/* Action Buttons */}
              <div className="flex items-center space-x-3 pt-2">
                <button
                  type="button"
                  onClick={handleTestAnthropicConnection}
                  disabled={testStatus.testing}
                  className="px-4 py-2 bg-[#222] border border-orange-500/50 hover:bg-orange-950/50 text-orange-300 font-bold rounded flex items-center space-x-2 transition-all disabled:opacity-50"
                >
                  {testStatus.testing ? <RefreshCw className="w-3.5 h-3.5 animate-spin" /> : <Globe className="w-3.5 h-3.5" />}
                  <span>{testStatus.testing ? "Testing..." : "Test Connection"}</span>
                </button>

                <button
                  type="button"
                  onClick={handleSaveAnthropicConfig}
                  className="px-4 py-2 bg-orange-500 text-black font-bold rounded hover:bg-orange-400 flex items-center space-x-2 transition-all"
                >
                  <Check className="w-3.5 h-3.5" />
                  <span>Save Configuration</span>
                </button>
              </div>
            </div>
          )}

          {/* TAB 3: OPENROUTER */}
          {activeProviderId === "openrouter" && (
            <div className="space-y-5">
              <div className="space-y-1">
                <h3 className="text-sm font-bold text-white flex items-center space-x-2">
                  <Compass className="w-4 h-4 text-purple-400" />
                  <span>OpenRouter AI Configuration</span>
                </h3>
                <p className="text-gray-400 text-[11px]">
                  Use a single API key to query 100+ top models (Claude 3.5 Sonnet, DeepSeek R1, Llama 3.3 70B, Gemini 2.0 Flash, Qwen 2.5).
                </p>
              </div>

              {/* Quick Models */}
              <div className="space-y-1.5">
                <label className="text-[10px] text-gray-500 uppercase tracking-widest font-bold">
                  Top OpenRouter Models
                </label>
                <div className="flex flex-wrap gap-1.5">
                  <button
                    onClick={() => setOpenRouterConfig({ ...openRouterConfig, modelName: "anthropic/claude-3.5-sonnet" })}
                    className={`px-2.5 py-1 border rounded text-[10px] font-bold transition-all ${
                      openRouterConfig.modelName === "anthropic/claude-3.5-sonnet"
                        ? "bg-purple-950/60 border-purple-500 text-purple-300"
                        : "bg-[#111] hover:bg-[#222] border-[#333] text-gray-300"
                    }`}
                  >
                    Claude 3.5 Sonnet
                  </button>
                  <button
                    onClick={() => setOpenRouterConfig({ ...openRouterConfig, modelName: "deepseek/deepseek-r1" })}
                    className={`px-2.5 py-1 border rounded text-[10px] font-bold transition-all ${
                      openRouterConfig.modelName === "deepseek/deepseek-r1"
                        ? "bg-purple-950/60 border-purple-500 text-purple-300"
                        : "bg-[#111] hover:bg-[#222] border-[#333] text-gray-300"
                    }`}
                  >
                    DeepSeek R1
                  </button>
                  <button
                    onClick={() => setOpenRouterConfig({ ...openRouterConfig, modelName: "meta-llama/llama-3.3-70b-instruct" })}
                    className={`px-2.5 py-1 border rounded text-[10px] font-bold transition-all ${
                      openRouterConfig.modelName === "meta-llama/llama-3.3-70b-instruct"
                        ? "bg-purple-950/60 border-purple-500 text-purple-300"
                        : "bg-[#111] hover:bg-[#222] border-[#333] text-gray-300"
                    }`}
                  >
                    Llama 3.3 70B
                  </button>
                  <button
                    onClick={() => setOpenRouterConfig({ ...openRouterConfig, modelName: "google/gemini-2.0-flash-001" })}
                    className={`px-2.5 py-1 border rounded text-[10px] font-bold transition-all ${
                      openRouterConfig.modelName === "google/gemini-2.0-flash-001"
                        ? "bg-purple-950/60 border-purple-500 text-purple-300"
                        : "bg-[#111] hover:bg-[#222] border-[#333] text-gray-300"
                    }`}
                  >
                    Gemini 2.0 Flash
                  </button>
                </div>
              </div>

              <div className="space-y-3 p-4 bg-[#111] border border-[#222] rounded-lg">
                <div className="space-y-1">
                  <label className="text-[10px] text-gray-400 uppercase tracking-wider font-bold">
                    OpenRouter API Key
                  </label>
                  <div className="relative flex items-center">
                    <input
                      type={showApiKey ? "text" : "password"}
                      value={openRouterConfig.apiKey}
                      onChange={(e) => setOpenRouterConfig({ ...openRouterConfig, apiKey: e.target.value })}
                      placeholder="sk-or-v1-..."
                      className="w-full bg-black border border-[#333] rounded px-3 py-2 text-xs text-white placeholder-gray-600 focus:outline-none focus:border-purple-400 pr-16"
                    />
                    <button
                      type="button"
                      onClick={() => setShowApiKey(!showApiKey)}
                      className="absolute right-2 px-2 py-0.5 text-[9px] bg-[#222] text-gray-300 rounded hover:text-white"
                    >
                      {showApiKey ? "Hide" : "Show"}
                    </button>
                  </div>
                </div>

                <div className="space-y-1">
                  <label className="text-[10px] text-gray-400 uppercase tracking-wider font-bold">
                    Model Path
                  </label>
                  <input
                    type="text"
                    value={openRouterConfig.modelName}
                    onChange={(e) => setOpenRouterConfig({ ...openRouterConfig, modelName: e.target.value })}
                    placeholder="anthropic/claude-3.5-sonnet"
                    className="w-full bg-black border border-[#333] rounded px-3 py-2 text-xs text-white placeholder-gray-600 focus:outline-none focus:border-purple-400"
                  />
                </div>
              </div>

              {/* Status Notice */}
              {testStatus.message && (
                <div
                  className={`p-3 rounded border text-xs flex items-center space-x-2 ${
                    testStatus.success
                      ? "bg-emerald-950/40 border-emerald-500 text-emerald-300"
                      : "bg-red-950/40 border-red-500 text-red-300"
                  }`}
                >
                  {testStatus.success ? <Check className="w-4 h-4 shrink-0 text-emerald-400" /> : <AlertTriangle className="w-4 h-4 shrink-0 text-red-400" />}
                  <span>{testStatus.message}</span>
                </div>
              )}

              {/* Action Buttons */}
              <div className="flex items-center space-x-3 pt-2">
                <button
                  type="button"
                  onClick={handleTestOpenRouterConnection}
                  disabled={testStatus.testing}
                  className="px-4 py-2 bg-[#222] border border-purple-500/50 hover:bg-purple-950/50 text-purple-300 font-bold rounded flex items-center space-x-2 transition-all disabled:opacity-50"
                >
                  {testStatus.testing ? <RefreshCw className="w-3.5 h-3.5 animate-spin" /> : <Globe className="w-3.5 h-3.5" />}
                  <span>{testStatus.testing ? "Testing..." : "Test Connection"}</span>
                </button>

                <button
                  type="button"
                  onClick={handleSaveOpenRouterConfig}
                  className="px-4 py-2 bg-purple-500 text-black font-bold rounded hover:bg-purple-400 flex items-center space-x-2 transition-all"
                >
                  <Check className="w-3.5 h-3.5" />
                  <span>Save Configuration</span>
                </button>
              </div>
            </div>
          )}

          {/* TAB 4: BYOK OPENAI COMPATIBLE */}
          {activeProviderId === "openai_compatible" && (
            <div className="space-y-5">
              <div className="space-y-1">
                <h3 className="text-sm font-bold text-white flex items-center space-x-2">
                  <Key className="w-4 h-4 text-cyan-400" />
                  <span>Bring Your Own API Key & Endpoint</span>
                </h3>
                <p className="text-gray-400 text-[11px]">
                  Connect any OpenAI-compatible provider (OpenAI, Groq, DeepSeek, Together AI, Ollama, LM Studio, etc.) by supplying your custom API key and Base URL.
                </p>
              </div>

              {/* Provider Quick Presets */}
              <div className="space-y-1.5">
                <label className="text-[10px] text-gray-500 uppercase tracking-widest font-bold">
                  Quick Endpoint Presets
                </label>
                <div className="flex flex-wrap gap-1.5">
                  <button
                    onClick={() => handlePresetSelect("openai")}
                    className="px-2.5 py-1 bg-[#111] hover:bg-[#222] border border-[#333] rounded text-[10px] text-cyan-300 font-bold transition-all"
                  >
                    OpenAI (gpt-4o-mini)
                  </button>
                  <button
                    onClick={() => handlePresetSelect("groq")}
                    className="px-2.5 py-1 bg-[#111] hover:bg-[#222] border border-[#333] rounded text-[10px] text-amber-300 font-bold transition-all"
                  >
                    Groq (Llama-3.3 70B)
                  </button>
                  <button
                    onClick={() => handlePresetSelect("deepseek")}
                    className="px-2.5 py-1 bg-[#111] hover:bg-[#222] border border-[#333] rounded text-[10px] text-purple-300 font-bold transition-all"
                  >
                    DeepSeek Coder
                  </button>
                  <button
                    onClick={() => handlePresetSelect("together")}
                    className="px-2.5 py-1 bg-[#111] hover:bg-[#222] border border-[#333] rounded text-[10px] text-blue-300 font-bold transition-all"
                  >
                    Together AI (Qwen2.5)
                  </button>
                  <button
                    onClick={() => handlePresetSelect("ollama")}
                    className="px-2.5 py-1 bg-[#111] hover:bg-[#222] border border-[#333] rounded text-[10px] text-emerald-300 font-bold transition-all"
                  >
                    Ollama (Localhost:11434)
                  </button>
                  <button
                    onClick={() => handlePresetSelect("lmstudio")}
                    className="px-2.5 py-1 bg-[#111] hover:bg-[#222] border border-[#333] rounded text-[10px] text-pink-300 font-bold transition-all"
                  >
                    LM Studio (Localhost:1234)
                  </button>
                </div>
              </div>

              {/* Form Controls */}
              <div className="space-y-3 p-4 bg-[#111] border border-[#222] rounded-lg">
                <div className="space-y-1">
                  <label className="text-[10px] text-gray-400 uppercase tracking-wider font-bold">
                    API Key
                  </label>
                  <div className="relative flex items-center">
                    <input
                      type={showApiKey ? "text" : "password"}
                      value={openAIConfig.apiKey}
                      onChange={(e) => setOpenAIConfig({ ...openAIConfig, apiKey: e.target.value })}
                      placeholder="sk-proj-..."
                      className="w-full bg-black border border-[#333] rounded px-3 py-2 text-xs text-white placeholder-gray-600 focus:outline-none focus:border-cyan-400 pr-16"
                    />
                    <button
                      type="button"
                      onClick={() => setShowApiKey(!showApiKey)}
                      className="absolute right-2 px-2 py-0.5 text-[9px] bg-[#222] text-gray-300 rounded hover:text-white"
                    >
                      {showApiKey ? "Hide" : "Show"}
                    </button>
                  </div>
                </div>

                <div className="space-y-1">
                  <label className="text-[10px] text-gray-400 uppercase tracking-wider font-bold">
                    Base Endpoint URL
                  </label>
                  <input
                    type="text"
                    value={openAIConfig.baseUrl}
                    onChange={(e) => setOpenAIConfig({ ...openAIConfig, baseUrl: e.target.value })}
                    placeholder="https://api.openai.com/v1"
                    className="w-full bg-black border border-[#333] rounded px-3 py-2 text-xs text-white placeholder-gray-600 focus:outline-none focus:border-cyan-400"
                  />
                </div>

                <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                  <div className="space-y-1">
                    <label className="text-[10px] text-gray-400 uppercase tracking-wider font-bold">
                      Model Name
                    </label>
                    <input
                      type="text"
                      value={openAIConfig.modelName}
                      onChange={(e) => setOpenAIConfig({ ...openAIConfig, modelName: e.target.value })}
                      placeholder="gpt-4o-mini"
                      className="w-full bg-black border border-[#333] rounded px-3 py-2 text-xs text-white placeholder-gray-600 focus:outline-none focus:border-cyan-400"
                    />
                  </div>

                  <div className="space-y-1">
                    <label className="text-[10px] text-gray-400 uppercase tracking-wider font-bold flex justify-between">
                      <span>Temperature</span>
                      <span className="text-cyan-400">{openAIConfig.temperature}</span>
                    </label>
                    <input
                      type="range"
                      min="0.0"
                      max="1.0"
                      step="0.1"
                      value={openAIConfig.temperature}
                      onChange={(e) => setOpenAIConfig({ ...openAIConfig, temperature: parseFloat(e.target.value) })}
                      className="w-full accent-cyan-400"
                    />
                  </div>
                </div>
              </div>

              {/* Status Notice */}
              {testStatus.message && (
                <div
                  className={`p-3 rounded border text-xs flex items-center space-x-2 ${
                    testStatus.success
                      ? "bg-emerald-950/40 border-emerald-500 text-emerald-300"
                      : "bg-red-950/40 border-red-500 text-red-300"
                  }`}
                >
                  {testStatus.success ? <Check className="w-4 h-4 shrink-0 text-emerald-400" /> : <AlertTriangle className="w-4 h-4 shrink-0 text-red-400" />}
                  <span>{testStatus.message}</span>
                </div>
              )}

              {/* Action Buttons */}
              <div className="flex items-center space-x-3 pt-2">
                <button
                  type="button"
                  onClick={handleTestOpenAIConnection}
                  disabled={testStatus.testing}
                  className="px-4 py-2 bg-[#222] border border-cyan-500/50 hover:bg-cyan-950/50 text-cyan-300 font-bold rounded flex items-center space-x-2 transition-all disabled:opacity-50"
                >
                  {testStatus.testing ? <RefreshCw className="w-3.5 h-3.5 animate-spin" /> : <Globe className="w-3.5 h-3.5" />}
                  <span>{testStatus.testing ? "Testing..." : "Test Connection"}</span>
                </button>

                <button
                  type="button"
                  onClick={handleSaveOpenAIConfig}
                  className="px-4 py-2 bg-cyan-500 text-black font-bold rounded hover:bg-cyan-400 flex items-center space-x-2 transition-all"
                >
                  <Check className="w-3.5 h-3.5" />
                  <span>Save Configuration</span>
                </button>
              </div>
            </div>
          )}

          {/* TAB 5: LOCAL GGUF & MLX MODELS */}
          {activeProviderId === "local_gguf_mlx" && (
            <div className="space-y-5">
              <div className="space-y-1">
                <h3 className="text-sm font-bold text-white flex items-center space-x-2">
                  <Cpu className="w-4 h-4 text-[#FF69B4]" />
                  <span>On-Device Local AI Models (.gguf / .mlx)</span>
                </h3>
                <p className="text-gray-400 text-[11px]">
                  Import custom local model weights directly from your device. Supported formats: <code className="text-[#FF69B4]">.gguf</code> (llama.cpp engine) and <code className="text-cyan-400">.mlx</code> (Apple Silicon Metal GPU engine).
                </p>
              </div>

              {/* Upload Drop Zone / Picker */}
              <div
                onClick={() => fileInputRef.current?.click()}
                className="p-5 bg-black border-2 border-dashed border-[#333] hover:border-[#FF69B4] rounded-lg flex flex-col items-center justify-center text-center cursor-pointer transition-all space-y-2 group"
              >
                <div className="p-2.5 bg-[#111] group-hover:bg-[#FF69B4]/10 rounded-full border border-[#222] group-hover:border-[#FF69B4]/40 transition-all">
                  <Upload className="w-5 h-5 text-gray-400 group-hover:text-[#FF69B4]" />
                </div>
                <div>
                  <span className="font-bold text-white text-xs block">
                    Click to Add .GGUF or .MLX Model Files
                  </span>
                  <span className="text-gray-500 text-[10px]">
                    Select file from your device storage or drop model file here
                  </span>
                </div>
                <input
                  ref={fileInputRef}
                  type="file"
                  multiple
                  accept=".gguf,.mlx,.bin,.safetensors,.metal"
                  onChange={handleFileUpload}
                  className="hidden"
                />
              </div>

              {/* Hardware RAM System Indicator */}
              <div className="p-3 bg-[#111] border border-[#222] rounded flex items-center justify-between text-[11px]">
                <div className="flex items-center space-x-2">
                  <Activity className="w-4 h-4 text-[#39FF14]" />
                  <span className="text-gray-300 font-bold">System Memory Footprint:</span>
                </div>
                <div className="text-right">
                  <span className="text-[#FF69B4] font-bold">
                    {activeLocalModel ? `${activeLocalModel.estimatedRAMGB} GB RAM Required` : "No Model Loaded"}
                  </span>
                  <span className="text-gray-500 block text-[9px]">Target Device: ARM64 Unified Memory</span>
                </div>
              </div>

              {/* Model Registry List */}
              <div className="space-y-2">
                <div className="text-[10px] text-gray-500 uppercase tracking-widest font-bold flex justify-between items-center">
                  <span>Imported Models ({localModels.length})</span>
                  <span>Active: {activeLocalModel?.name || "None"}</span>
                </div>

                {localModels.length === 0 ? (
                  <div className="p-4 bg-[#111] border border-[#222] rounded text-center text-gray-500">
                    No local model files added yet. Click above to import a .gguf or .mlx model.
                  </div>
                ) : (
                  <div className="space-y-2">
                    {localModels.map((m) => {
                      const isActive = activeLocalModel?.id === m.id;
                      return (
                        <div
                          key={m.id}
                          className={`p-3 bg-black border rounded-lg flex flex-col sm:flex-row sm:items-center justify-between gap-3 transition-all ${
                            isActive
                              ? "border-[#FF69B4] bg-[#FF69B4]/5 shadow-[0_0_10px_rgba(255,105,180,0.15)]"
                              : "border-[#222] hover:border-[#444]"
                          }`}
                        >
                          <div className="space-y-1">
                            <div className="flex items-center space-x-2">
                              <span
                                className={`px-1.5 py-0.5 rounded text-[9px] font-bold uppercase ${
                                  m.format === "mlx"
                                    ? "bg-cyan-950 text-cyan-300 border border-cyan-500/40"
                                    : "bg-purple-950 text-purple-300 border border-purple-500/40"
                                }`}
                              >
                                {m.format.toUpperCase()}
                              </span>
                              <span className="font-bold text-white text-xs truncate max-w-[220px] sm:max-w-[300px]">
                                {m.name}
                              </span>
                              {isActive && (
                                <span className="px-1.5 py-0.5 bg-[#FF69B4] text-black font-bold text-[9px] rounded uppercase">
                                  Active
                                </span>
                              )}
                            </div>

                            <div className="flex flex-wrap items-center gap-3 text-[10px] text-gray-400">
                              <span>Arch: <strong className="text-gray-200">{m.architecture}</strong></span>
                              <span>Size: <strong className="text-gray-200">{m.sizeMB} MB</strong></span>
                              <span>Quant: <strong className="text-gray-200">{m.quantization}</strong></span>
                              <span>RAM: <strong className="text-[#FF69B4]">{m.estimatedRAMGB} GB</strong></span>
                            </div>
                          </div>

                          <div className="flex items-center space-x-2 shrink-0">
                            {!isActive ? (
                              <button
                                onClick={() => handleSelectActiveModel(m.id)}
                                className="px-3 py-1 bg-[#222] hover:bg-[#333] border border-[#444] text-gray-200 hover:text-white rounded text-[10px] font-bold transition-all"
                              >
                                Load & Select
                              </button>
                            ) : (
                              <span className="text-[#39FF14] text-[10px] font-bold flex items-center space-x-1">
                                <Check className="w-3.5 h-3.5" />
                                <span>Loaded in RAM</span>
                              </span>
                            )}

                            <button
                              onClick={() => handleDeleteModel(m.id)}
                              className="p-1.5 text-gray-600 hover:text-red-400 hover:bg-red-950/30 rounded transition-all"
                              title="Delete model entry"
                            >
                              <Trash2 className="w-3.5 h-3.5" />
                            </button>
                          </div>
                        </div>
                      );
                    })}
                  </div>
                )}
              </div>
            </div>
          )}

          {/* TAB 6: OFFLINE RULE ENGINE */}
          {activeProviderId === "offline_local" && (
            <div className="space-y-4">
              <div className="p-4 bg-[#111] border border-[#222] rounded-lg space-y-2">
                <div className="flex items-center space-x-2 text-amber-400 font-bold text-sm">
                  <HardDrive className="w-4 h-4" />
                  <span>Offline Heuristic Rule Engine</span>
                </div>
                <p className="text-gray-400 leading-relaxed">
                  Generates iOS modification blocks using deterministically compiled heuristic rules. Requires zero network connection and zero external LLM dependencies.
                </p>
              </div>
            </div>
          )}
        </div>

        {/* Modal Footer */}
        <div className="h-12 bg-black border-t border-[#222] px-4 flex items-center justify-between">
          <span className="text-[10px] text-gray-500">
            Active Provider: <strong className="text-white uppercase">{AIManager.getActiveProvider().name}</strong>
          </span>

          <button
            onClick={onClose}
            className="px-4 py-1.5 bg-[#39FF14] text-black font-bold rounded hover:bg-green-400 transition-all text-xs uppercase tracking-wider"
          >
            Done
          </button>
        </div>
      </div>
    </div>
  );
};
