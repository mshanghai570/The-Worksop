import React, { useRef } from "react";
import { ViewMode, Project, ProjectTargetType } from "../types";
import {
  Sparkles,
  Code2,
  Smartphone,
  Layers,
  FolderOpen,
  Save,
  Download,
  Plus,
  Play,
  Terminal,
  Cpu,
  Shield,
  Activity,
  Compass,
  Zap
} from "lucide-react";

interface HeaderProps {
  project: Project;
  viewMode: ViewMode;
  setViewMode: (mode: ViewMode) => void;
  onOpenGemini: () => void;
  onNewProject: () => void;
  onImportJson: (file: File) => void;
  onExportJson: () => void;
  onExportZip: () => void;
  onLoadPreset: (presetId: string) => void;
  onRunSimulation: () => void;
  onUpdateProjectType: (targetType: ProjectTargetType) => void;
}

export const Header: React.FC<HeaderProps> = ({
  project,
  viewMode,
  setViewMode,
  onOpenGemini,
  onNewProject,
  onImportJson,
  onExportJson,
  onExportZip,
  onLoadPreset,
  onRunSimulation,
  onUpdateProjectType
}) => {
  const fileInputRef = useRef<HTMLInputElement>(null);

  const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (file) {
      onImportJson(file);
      if (fileInputRef.current) fileInputRef.current.value = "";
    }
  };

  const getTargetBadgeColor = (type: ProjectTargetType) => {
    switch (type) {
      case "jailbreak_tweak":
        return "border-cyan-500/50 text-cyan-300 bg-cyan-950/40 shadow-[0_0_8px_rgba(0,240,255,0.2)]";
      case "jailed_mod":
        return "border-amber-500/50 text-amber-300 bg-amber-950/40 shadow-[0_0_8px_rgba(255,176,0,0.2)]";
      case "native_extension":
        return "border-emerald-500/50 text-emerald-300 bg-emerald-950/40 shadow-[0_0_8px_rgba(57,255,20,0.2)]";
      default:
        return "border-slate-800 text-slate-400 bg-slate-950";
    }
  };

  return (
    <header className="min-h-12 border-b border-cyan-500/20 bg-brushed-metal-header flex flex-wrap items-center justify-between px-2 sm:px-4 py-1.5 sm:py-0 text-slate-200 font-mono select-none z-30 sticky top-0 gap-2 shadow-2xl">
      {/* Hidden File Input for Reopening Projects */}
      <input
        type="file"
        ref={fileInputRef}
        onChange={handleFileChange}
        accept=".json,.workshop"
        className="hidden"
      />

      {/* App Branding & Project Title */}
      <div className="flex items-center gap-2 sm:gap-3">
        {/* Laboratory Station Emblem */}
        <div className="flex items-center gap-2 bg-slate-950/80 px-2.5 py-1 rounded border border-slate-800 shadow-inner">
          <div className="relative flex items-center justify-center">
            <span className="w-2.5 h-2.5 rounded-full bg-[#39FF14] animate-pulse shadow-[0_0_10px_#39FF14]"></span>
            <span className="absolute w-4 h-4 rounded-full border border-[#39FF14]/40 animate-ping"></span>
          </div>
          <div className="flex flex-col">
            <span className="text-[#00F0FF] font-black tracking-widest text-[10px] uppercase leading-none">
              THE WORKSHOP
            </span>
            <span className="text-[8px] text-slate-500 font-mono tracking-tighter leading-none mt-0.5">
              LAB STATION // 01
            </span>
          </div>
        </div>

        <div className="h-4 w-px bg-slate-800"></div>

        {/* Active Project Title */}
        <div className="flex items-center gap-1.5 bg-slate-900/60 px-2 py-0.5 rounded border border-slate-800/80 text-xs">
          <span className="text-slate-500 text-[10px] font-mono">PROJ:</span>
          <span className="text-white font-bold tracking-wide truncate max-w-[120px] sm:max-w-none">
            {project.name}
          </span>
        </div>

        {/* Project Target Workflow Selector */}
        <div className="flex items-center">
          <select
            value={project.projectType || "jailbreak_tweak"}
            onChange={(e) => onUpdateProjectType(e.target.value as ProjectTargetType)}
            className={`text-[10px] font-mono font-bold border rounded px-2 py-1 focus:outline-none cursor-pointer transition-all ${getTargetBadgeColor(
              project.projectType || "jailbreak_tweak"
            )}`}
            title="Switch Target Engineering Workflow"
          >
            <option value="jailbreak_tweak" className="bg-[#0b101a] text-[#00F0FF]">
              ⚡ Jailbreak Tweak (Theos/Logos)
            </option>
            <option value="jailed_mod" className="bg-[#0b101a] text-[#FFB000]">
              ⚙️ Jailed IPA Patch (Substrate)
            </option>
            <option value="native_extension" className="bg-[#0b101a] text-[#39FF14]">
              🧩 Native SwiftUI Extension
            </option>
          </select>
        </div>

        {/* Engineering Preset Dropdown */}
        <div className="hidden xl:flex items-center">
          <select
            onChange={(e) => e.target.value && onLoadPreset(e.target.value)}
            defaultValue=""
            className="bg-slate-950 text-[10px] font-mono text-slate-400 border border-slate-800 rounded px-2 py-1 focus:outline-none focus:border-[#00F0FF] cursor-pointer hover:border-slate-700"
          >
            <option value="" disabled>
              Load Blueprint Preset...
            </option>
            <option value="lockscreen">📐 SpringBoard LockScreen Blueprint</option>
            <option value="logger">📡 Lifecycle Telemetry Logger</option>
            <option value="alert">🔔 Security Banner & Audio Relay</option>
          </select>
        </div>
      </div>

      {/* View Navigation Workbench Tabs */}
      <div className="flex bg-slate-950/90 rounded-lg border border-slate-800/90 p-0.5 overflow-x-auto max-w-full no-scrollbar shadow-inner">
        <button
          onClick={() => setViewMode("studio")}
          className={`px-2.5 sm:px-3.5 py-1 text-[10px] font-bold rounded-md transition-all whitespace-nowrap flex items-center space-x-1.5 ${
            viewMode === "studio"
              ? "bg-[#121824] text-[#00F0FF] border border-[#00F0FF]/40 shadow-[0_0_10px_rgba(0,240,255,0.2)]"
              : "text-slate-500 hover:text-slate-300"
          }`}
        >
          <Layers className="w-3 h-3 text-[#00F0FF]" />
          <span>BLUEPRINT DESK</span>
        </button>

        <button
          onClick={() => setViewMode("code")}
          className={`px-2.5 sm:px-3.5 py-1 text-[10px] font-bold rounded-md transition-all whitespace-nowrap flex items-center space-x-1.5 ${
            viewMode === "code"
              ? "bg-[#121824] text-[#39FF14] border border-[#39FF14]/40 shadow-[0_0_10px_rgba(57,255,20,0.2)]"
              : "text-slate-500 hover:text-slate-300"
          }`}
        >
          <Code2 className="w-3 h-3 text-[#39FF14]" />
          <span>LOGOS CODE</span>
        </button>

        <button
          onClick={() => setViewMode("swiftui")}
          className={`px-2.5 sm:px-3.5 py-1 text-[10px] font-bold rounded-md transition-all whitespace-nowrap flex items-center space-x-1.5 ${
            viewMode === "swiftui"
              ? "bg-[#121824] text-amber-400 border border-amber-400/40 shadow-[0_0_10px_rgba(255,176,0,0.2)]"
              : "text-slate-500 hover:text-slate-300"
          }`}
        >
          <Smartphone className="w-3 h-3 text-amber-400" />
          <span>TEST RIG</span>
        </button>

        <button
          onClick={() => setViewMode("headers")}
          className={`px-2.5 sm:px-3.5 py-1 text-[10px] font-bold rounded-md transition-all whitespace-nowrap flex items-center space-x-1.5 ${
            viewMode === "headers"
              ? "bg-[#121824] text-pink-400 border border-pink-400/40 shadow-[0_0_10px_rgba(255,105,180,0.2)]"
              : "text-slate-500 hover:text-slate-300"
          }`}
        >
          <Cpu className="w-3 h-3 text-pink-400" />
          <span>HEADERS</span>
        </button>
      </div>

      {/* Laboratory Controls & Actions */}
      <div className="flex items-center gap-1.5 sm:gap-2">
        {/* Workshop AI Assistant Trigger */}
        <button
          onClick={onOpenGemini}
          className="flex items-center space-x-1.5 px-2.5 sm:px-3 py-1 rounded bg-slate-900 border border-[#00F0FF]/40 text-[#00F0FF] text-[10px] font-bold hover:bg-[#00F0FF]/10 transition-all shadow-[0_0_12px_rgba(0,240,255,0.2)]"
        >
          <Sparkles className="w-3 h-3 text-[#00F0FF]" />
          <span className="hidden sm:inline">AI ASSISTANT</span>
          <span className="sm:hidden">AI</span>
        </button>

        {/* Quick Test Simulation */}
        <button
          onClick={onRunSimulation}
          className="flex items-center space-x-1 px-2.5 py-1 rounded bg-slate-900 border border-slate-700/80 text-slate-300 hover:border-[#39FF14] hover:text-[#39FF14] text-[10px] font-mono transition-all"
          title="Run Simulation Test Rig"
        >
          <Play className="w-3 h-3 text-[#39FF14] fill-current" />
          <span className="hidden sm:inline">SIMULATE</span>
        </button>

        {/* Reopen / Import Project File */}
        <button
          onClick={() => fileInputRef.current?.click()}
          className="p-1.5 text-slate-400 hover:text-white bg-slate-950 border border-slate-800 hover:border-slate-600 rounded transition-all"
          title="Import Blueprint File (.workshop or .json)"
        >
          <FolderOpen className="w-3.5 h-3.5" />
        </button>

        {/* Save JSON Blueprint */}
        <button
          onClick={onExportJson}
          className="p-1.5 text-slate-400 hover:text-white bg-slate-950 border border-slate-800 hover:border-slate-600 rounded transition-all"
          title="Save Blueprint JSON"
        >
          <Save className="w-3.5 h-3.5" />
        </button>

        {/* New Blank Blueprint */}
        <button
          onClick={onNewProject}
          className="p-1.5 text-slate-400 hover:text-white bg-slate-950 border border-slate-800 hover:border-slate-600 rounded transition-all"
          title="New Blank Workbench"
        >
          <Plus className="w-3.5 h-3.5" />
        </button>

        {/* Primary Build Package Button */}
        <button
          onClick={onExportZip}
          className="bg-gradient-to-r from-[#39FF14] to-[#00F0FF] text-black text-[10px] font-extrabold px-3.5 py-1.5 rounded hover:opacity-90 transition-all shadow-[0_0_15px_rgba(57,255,20,0.3)] uppercase tracking-wider flex items-center space-x-1"
        >
          <Zap className="w-3 h-3 fill-black" />
          <span>COMPILED ZIP</span>
        </button>
      </div>
    </header>
  );
};
