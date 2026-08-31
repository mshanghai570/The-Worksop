import React, { useState } from "react";
import { Project, ChatMessage, BlockData } from "../types";
import { AIManager } from "../services/ai/AIManager";
import { AIProviderId } from "../services/ai/types";
import { AISettingsModal } from "./AISettingsModal";
import {
  Sparkles,
  Send,
  Cpu,
  Zap,
  ArrowRight,
  Check,
  Code,
  Layers,
  HelpCircle,
  Lightbulb,
  X,
  Settings,
  ShieldCheck,
  WifiOff,
  Key,
  HardDrive,
  Terminal,
  Activity
} from "lucide-react";

interface GeminiAssistantProps {
  project: Project;
  isOpen: boolean;
  onClose: () => void;
  onApplyGeneratedBlocks: (blocks: BlockData[]) => void;
}

export const GeminiAssistant: React.FC<GeminiAssistantProps> = ({
  project,
  isOpen,
  onClose,
  onApplyGeneratedBlocks,
}) => {
  const [activeProviderId, setActiveProviderId] = useState<AIProviderId>(AIManager.getActiveProviderId());
  const [isSettingsOpen, setIsSettingsOpen] = useState(false);
  const [messages, setMessages] = useState<ChatMessage[]>([
    {
      id: "init-1",
      sender: "gemini",
      text: "AI ENGINEERING COPILOT ACTIVE // Describe your iOS modification or tweak target, and I will synthesize the corresponding blueprint node graph for your canvas.",
      timestamp: new Date().toLocaleTimeString([], { hour: "2-digit", minute: "2-digit" }),
    },
  ]);

  const [input, setInput] = useState("");
  const [loading, setLoading] = useState(false);

  if (!isOpen) return null;

  const handleProviderChange = (id: AIProviderId) => {
    AIManager.setActiveProviderId(id);
    setActiveProviderId(id);
  };

  const handleSend = async (textToSend?: string) => {
    const query = textToSend || input;
    if (!query.trim() || loading) return;

    const userMsg: ChatMessage = {
      id: `user-${Date.now()}`,
      sender: "user",
      text: query,
      timestamp: new Date().toLocaleTimeString([], { hour: "2-digit", minute: "2-digit" }),
    };

    setMessages((prev) => [...prev, userMsg]);
    if (!textToSend) setInput("");
    setLoading(true);

    try {
      const response = await AIManager.generateBlocks(query, project);

      const aiMsg: ChatMessage = {
        id: `ai-${Date.now()}`,
        sender: "gemini",
        text: response.text,
        timestamp: new Date().toLocaleTimeString([], { hour: "2-digit", minute: "2-digit" }),
        suggestedBlocks: response.blocks,
      };

      setMessages((prev) => [...prev, aiMsg]);
    } catch (err: any) {
      setMessages((prev) => [
        ...prev,
        {
          id: `err-${Date.now()}`,
          sender: "gemini",
          text: `[Service Notice]: ${err.message || "Failed to process request."}`,
          timestamp: new Date().toLocaleTimeString([], { hour: "2-digit", minute: "2-digit" }),
        },
      ]);
    } finally {
      setLoading(false);
    }
  };

  const currentProvider = AIManager.getActiveProvider();

  return (
    <div className="fixed inset-y-0 right-0 w-full sm:w-[460px] bg-slate-950 border-l border-cyan-500/20 shadow-2xl z-50 flex flex-col font-mono text-xs">
      {/* Header Bar */}
      <div className="h-12 bg-slate-900/90 border-b border-slate-800 px-4 flex items-center justify-between">
        <div className="flex items-center space-x-2">
          <Terminal className="w-4 h-4 text-[#00F0FF]" />
          <span className="font-extrabold text-xs text-white uppercase tracking-wider flex items-center space-x-1.5">
            <span>AI SYNTHESIS TERMINAL</span>
            <span className="text-slate-600">//</span>
            <span className="text-[#39FF14] text-[10px]">ONLINE</span>
          </span>
        </div>

        <button
          onClick={onClose}
          className="p-1.5 rounded text-slate-500 hover:text-white hover:bg-slate-800 transition-all"
        >
          <X className="w-4 h-4" />
        </button>
      </div>

      {/* Provider Selector Control Bar */}
      <div className="p-2.5 bg-slate-900 border-b border-slate-800 flex items-center justify-between text-[11px]">
        <div className="flex items-center space-x-1 bg-slate-950 p-1 rounded border border-slate-800 overflow-x-auto max-w-[330px]">
          <button
            onClick={() => handleProviderChange("gemini")}
            className={`px-2 py-1 rounded text-[10px] font-bold transition-all shrink-0 ${
              activeProviderId === "gemini"
                ? "bg-slate-800 text-[#39FF14] border border-[#39FF14]"
                : "text-slate-500 hover:text-slate-300"
            }`}
          >
            Gemini
          </button>
          <button
            onClick={() => handleProviderChange("anthropic")}
            className={`px-2 py-1 rounded text-[10px] font-bold transition-all shrink-0 ${
              activeProviderId === "anthropic"
                ? "bg-slate-800 text-orange-400 border border-orange-400"
                : "text-slate-500 hover:text-slate-300"
            }`}
          >
            Claude
          </button>
          <button
            onClick={() => handleProviderChange("openrouter")}
            className={`px-2 py-1 rounded text-[10px] font-bold transition-all shrink-0 ${
              activeProviderId === "openrouter"
                ? "bg-slate-800 text-purple-400 border border-purple-400"
                : "text-slate-500 hover:text-slate-300"
            }`}
          >
            OpenRouter
          </button>
          <button
            onClick={() => handleProviderChange("openai_compatible")}
            className={`px-2 py-1 rounded text-[10px] font-bold transition-all shrink-0 ${
              activeProviderId === "openai_compatible"
                ? "bg-slate-800 text-cyan-400 border border-cyan-400"
                : "text-slate-500 hover:text-slate-300"
            }`}
          >
            BYOK OpenAI
          </button>
          <button
            onClick={() => handleProviderChange("local_gguf_mlx")}
            className={`px-2 py-1 rounded text-[10px] font-bold transition-all shrink-0 ${
              activeProviderId === "local_gguf_mlx"
                ? "bg-slate-800 text-pink-400 border border-pink-400"
                : "text-slate-500 hover:text-slate-300"
            }`}
          >
            GGUF/MLX
          </button>
          <button
            onClick={() => handleProviderChange("offline_local")}
            className={`px-2 py-1 rounded text-[10px] font-bold transition-all shrink-0 ${
              activeProviderId === "offline_local"
                ? "bg-slate-800 text-amber-400 border border-amber-400"
                : "text-slate-500 hover:text-slate-300"
            }`}
          >
            Offline
          </button>
        </div>

        <button
          onClick={() => setIsSettingsOpen(true)}
          className="px-2 py-1 bg-slate-900 border border-slate-700 hover:border-[#00F0FF] text-slate-300 hover:text-[#00F0FF] rounded text-[10px] font-bold flex items-center space-x-1 transition-all shrink-0"
          title="Configure API Keys and Local Models"
        >
          <Settings className="w-3.5 h-3.5 text-[#00F0FF]" />
          <span className="hidden sm:inline">Settings</span>
        </button>
      </div>

      {/* Active Mode Notice */}
      <div className="px-4 py-1.5 bg-slate-950 border-b border-slate-800 text-[10px] text-slate-400 flex items-center justify-between">
        <span className="truncate">{currentProvider.description}</span>
        {activeProviderId === "anthropic" && (
          <span className="px-1.5 py-0.5 bg-slate-900 text-orange-400 border border-orange-400/30 rounded text-[9px] shrink-0 font-bold uppercase">
            Claude Active
          </span>
        )}
        {activeProviderId === "openrouter" && (
          <span className="px-1.5 py-0.5 bg-slate-900 text-purple-400 border border-purple-400/30 rounded text-[9px] shrink-0 font-bold uppercase">
            OpenRouter Active
          </span>
        )}
        {activeProviderId === "openai_compatible" && (
          <span className="px-1.5 py-0.5 bg-slate-900 text-cyan-400 border border-cyan-400/30 rounded text-[9px] shrink-0 font-bold uppercase">
            BYOK Active
          </span>
        )}
        {activeProviderId === "local_gguf_mlx" && (
          <span className="px-1.5 py-0.5 bg-slate-900 text-pink-400 border border-pink-400/30 rounded text-[9px] shrink-0 font-bold uppercase">
            On-Device MLX/GGUF
          </span>
        )}
      </div>

      {/* Settings Modal */}
      <AISettingsModal
        isOpen={isSettingsOpen}
        onClose={() => setIsSettingsOpen(false)}
        onProviderChanged={(id) => setActiveProviderId(id)}
      />

      {/* Quick Prompt Presets */}
      <div className="p-3 border-b border-slate-800 bg-slate-900/40">
        <div className="text-[9px] text-slate-500 uppercase tracking-widest font-bold mb-2 flex items-center space-x-1">
          <Lightbulb className="w-3.5 h-3.5 text-[#00F0FF]" />
          <span>ENGINEERING PRESETS & BLUEPRINTS</span>
        </div>
        <div className="flex flex-wrap gap-1.5">
          <button
            onClick={() => handleSend("Can I make this modification without jailbreak?")}
            className="px-2 py-1 bg-slate-950 hover:bg-slate-900 border border-pink-500/40 rounded text-[10px] text-pink-400 transition-all hover:border-pink-400"
          >
            🛡️ Non-Jailbreak Check
          </button>
          <button
            onClick={() => handleSend("Explain why SpringBoard or daemon hooks require jailbreak, and how Jailed IPA patching works.")}
            className="px-2 py-1 bg-slate-950 hover:bg-slate-900 border border-slate-800 rounded text-[10px] text-slate-300 transition-all hover:border-[#00F0FF]"
          >
            ❓ Jailbreak vs Jailed IPA Limits
          </button>
          <button
            onClick={() => handleSend("Hook SBLockScreenManager lockUIFromSource with a 2s delay and log")}
            className="px-2 py-1 bg-slate-950 hover:bg-slate-900 border border-slate-800 rounded text-[10px] text-slate-300 transition-all hover:border-[#39FF14]"
          >
            🔒 Lock Screen Delay
          </button>
          <button
            onClick={() => handleSend("Create a Jailed modification to replace app assets and Info.plist display name")}
            className="px-2 py-1 bg-slate-950 hover:bg-slate-900 border border-slate-800 rounded text-[10px] text-slate-300 transition-all hover:border-cyan-400"
          >
            📦 Jailed Asset & Plist Mod
          </button>
        </div>
      </div>

      {/* Messages List */}
      <div className="flex-1 p-4 overflow-y-auto space-y-4">
        {messages.map((msg) => (
          <div
            key={msg.id}
            className={`flex flex-col ${
              msg.sender === "user" ? "items-end" : "items-start"
            }`}
          >
            <div
              className={`max-w-[88%] p-3 rounded border leading-relaxed ${
                msg.sender === "user"
                  ? "bg-slate-900 border-[#39FF14] text-[#39FF14]"
                  : "bg-slate-950 border-slate-800 text-slate-200"
              }`}
            >
              <div className="flex items-center justify-between pb-1.5 mb-1.5 border-b border-slate-800 text-[9px] text-slate-500">
                <span className="font-bold uppercase tracking-wider text-[#00F0FF]">
                  {msg.sender === "user" ? "OPERATOR" : "THE WORKSHOP LOGIC ENGINE"}
                </span>
                <span>{msg.timestamp}</span>
              </div>

              <div className="whitespace-pre-wrap">{msg.text}</div>

              {/* Suggested Block Action Button */}
              {msg.suggestedBlocks && msg.suggestedBlocks.length > 0 && (
                <div className="mt-3 pt-3 border-t border-slate-800 space-y-2">
                  <div className="text-[9px] font-bold text-slate-400 uppercase tracking-wider flex items-center space-x-1">
                    <Layers className="w-3.5 h-3.5 text-[#00F0FF]" />
                    <span>SYNTHESIZED BLUEPRINT GRAPH ({msg.suggestedBlocks.length} NODES)</span>
                  </div>

                  <div className="space-y-1 max-h-36 overflow-y-auto pr-1">
                    {msg.suggestedBlocks.map((b, idx) => (
                      <div
                        key={idx}
                        className="px-2 py-1 bg-slate-900 border border-slate-800 rounded text-[10px] flex items-center justify-between text-slate-300"
                      >
                        <span className="font-bold text-[#00F0FF] uppercase">{b.type}</span>
                        <span className="truncate max-w-[180px] text-slate-400">{b.title || b.targetClass}</span>
                      </div>
                    ))}
                  </div>

                  <button
                    onClick={() => onApplyGeneratedBlocks(msg.suggestedBlocks as BlockData[])}
                    className="w-full py-2 bg-[#00F0FF] text-black font-extrabold rounded hover:bg-cyan-300 transition-all flex items-center justify-center space-x-2 text-xs uppercase tracking-wider shadow-md"
                  >
                    <Check className="w-4 h-4" />
                    <span>APPLY GRAPH TO BLUEPRINT CANVAS</span>
                  </button>
                </div>
              )}
            </div>
          </div>
        ))}

        {loading && (
          <div className="flex items-center space-x-2 text-[#00F0FF] animate-pulse p-2.5 bg-slate-900 border border-slate-800 rounded w-fit text-[11px]">
            <Cpu className="w-4 h-4 animate-spin" />
            <span>SYNTHESIZING GRAPH LOGIC...</span>
          </div>
        )}
      </div>

      {/* Input Bar */}
      <div className="p-3 bg-slate-950 border-t border-slate-800">
        {activeProviderId === "disabled" ? (
          <div className="p-2.5 bg-rose-950/40 border border-rose-500/40 rounded text-center text-rose-400 text-[11px]">
            AI services disabled. Select a provider above to re-enable copilot logic.
          </div>
        ) : (
          <form
            onSubmit={(e) => {
              e.preventDefault();
              handleSend();
            }}
            className="flex items-center space-x-2"
          >
            <input
              type="text"
              value={input}
              onChange={(e) => setInput(e.target.value)}
              placeholder="e.g. Hook SBLockScreenManager lockUIFromSource with delay..."
              disabled={loading}
              className="flex-1 bg-slate-900 border border-slate-800 rounded px-3 py-2 text-xs text-white placeholder-slate-600 focus:outline-none focus:border-[#00F0FF]"
            />
            <button
              type="submit"
              disabled={loading || !input.trim()}
              className="p-2 bg-[#00F0FF] text-black font-bold rounded hover:bg-cyan-300 disabled:opacity-50 transition-all shadow-md"
            >
              <Send className="w-4 h-4" />
            </button>
          </form>
        )}
      </div>
    </div>
  );
};
