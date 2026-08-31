import React, { useState } from "react";
import { Project } from "../types";
import {
  generateLogosCode,
  generateTheosMakefile,
  generateControlFile,
  generatePlistFilter,
  generateSwiftUICode,
  generateSwiftModelsCode,
  generateSwiftBridgeHeader,
  generateJailedPatchScript,
  generateNativeExtensionCode
} from "../utils/codeGenerator";
import { Copy, Check, Download, Code, FileText, Settings, ShieldCheck, Smartphone, Terminal, AppWindow } from "lucide-react";

interface CodePanelProps {
  project: Project;
}

export const CodePanel: React.FC<CodePanelProps> = ({ project }) => {
  const [activeTab, setActiveTab] = useState<
    "logos" | "swiftui" | "swiftmodels" | "bridge" | "makefile" | "control" | "filter" | "jailed_script" | "native_ext" | "json"
  >("logos");
  const [copied, setCopied] = useState(false);

  const cleanName = project.name.replace(/\s+/g, "");

  const logosCode = generateLogosCode(project);
  const swiftUICode = generateSwiftUICode(project);
  const swiftModelsCode = generateSwiftModelsCode(project);
  const bridgeHeaderCode = generateSwiftBridgeHeader(project);
  const makefileCode = generateTheosMakefile(project);
  const controlCode = generateControlFile(project);
  const filterCode = generatePlistFilter(project);
  const jailedScriptCode = generateJailedPatchScript(project);
  const nativeExtCode = generateNativeExtensionCode(project);
  const jsonCode = JSON.stringify(project, null, 2);

  const getActiveContent = () => {
    switch (activeTab) {
      case "logos":
        return { filename: `${cleanName}.x`, code: logosCode };
      case "swiftui":
        return { filename: `${cleanName}App.swift`, code: swiftUICode };
      case "swiftmodels":
        return { filename: "TweakModels.swift", code: swiftModelsCode };
      case "bridge":
        return { filename: `${cleanName}-Bridging-Header.h`, code: bridgeHeaderCode };
      case "makefile":
        return { filename: "Makefile", code: makefileCode };
      case "control":
        return { filename: "control", code: controlCode };
      case "filter":
        return { filename: `${cleanName}.plist`, code: filterCode };
      case "jailed_script":
        return { filename: "patch_ipa.sh", code: jailedScriptCode };
      case "native_ext":
        return { filename: `${cleanName}Extension.swift`, code: nativeExtCode };
      case "json":
        return { filename: "project.json", code: jsonCode };
    }
  };

  const { filename, code } = getActiveContent();

  const handleCopy = () => {
    navigator.clipboard.writeText(code);
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  };

  const handleDownloadFile = () => {
    const blob = new Blob([code], { type: "text/plain;charset=utf-8" });
    const url = URL.createObjectURL(blob);
    const link = document.createElement("a");
    link.href = url;
    link.download = filename;
    link.click();
    URL.revokeObjectURL(url);
  };

  return (
    <div className="w-full h-[calc(100vh-3rem)] bg-slate-950 text-slate-200 font-mono flex flex-col">
      {/* File Tab Bar */}
      <div className="min-h-10 h-auto py-1.5 px-3 sm:px-4 bg-slate-900 border-b border-slate-800 flex flex-col sm:flex-row items-stretch sm:items-center justify-between gap-2">
        <div className="flex items-center space-x-1 overflow-x-auto no-scrollbar whitespace-nowrap max-w-full">
          <button
            onClick={() => setActiveTab("logos")}
            className={`px-2.5 py-1 rounded text-[10px] font-bold transition-all flex items-center space-x-1.5 shrink-0 ${
              activeTab === "logos"
                ? "bg-slate-800 text-[#39FF14] border border-[#39FF14]"
                : "text-slate-500 hover:text-slate-300"
            }`}
          >
            <Code className="w-3 h-3 text-[#39FF14]" />
            <span>{cleanName}.x (Logos)</span>
          </button>

          <button
            onClick={() => setActiveTab("swiftui")}
            className={`px-2.5 py-1 rounded text-[10px] font-bold transition-all flex items-center space-x-1.5 shrink-0 ${
              activeTab === "swiftui"
                ? "bg-slate-800 text-pink-400 border border-pink-400"
                : "text-slate-500 hover:text-slate-300"
            }`}
          >
            <Smartphone className="w-3 h-3 text-pink-400" />
            <span>{cleanName}App.swift</span>
          </button>

          <button
            onClick={() => setActiveTab("swiftmodels")}
            className={`px-2.5 py-1 rounded text-[10px] font-bold transition-all flex items-center space-x-1.5 shrink-0 ${
              activeTab === "swiftmodels"
                ? "bg-slate-800 text-pink-400 border border-pink-400"
                : "text-slate-500 hover:text-slate-300"
            }`}
          >
            <Code className="w-3 h-3 text-pink-400" />
            <span>TweakModels.swift</span>
          </button>

          <button
            onClick={() => setActiveTab("bridge")}
            className={`px-2.5 py-1 rounded text-[10px] font-bold transition-all flex items-center space-x-1.5 shrink-0 ${
              activeTab === "bridge"
                ? "bg-slate-800 text-[#00F0FF] border border-[#00F0FF]"
                : "text-slate-500 hover:text-slate-300"
            }`}
          >
            <Code className="w-3 h-3 text-[#00F0FF]" />
            <span>Bridging-Header.h</span>
          </button>

          <button
            onClick={() => setActiveTab("makefile")}
            className={`px-2.5 py-1 rounded text-[10px] font-bold transition-all flex items-center space-x-1.5 shrink-0 ${
              activeTab === "makefile"
                ? "bg-slate-800 text-[#39FF14] border border-[#39FF14]"
                : "text-slate-500 hover:text-slate-300"
            }`}
          >
            <FileText className="w-3 h-3 text-[#00F0FF]" />
            <span>Makefile</span>
          </button>

          <button
            onClick={() => setActiveTab("control")}
            className={`px-2.5 py-1 rounded text-[10px] font-bold transition-all flex items-center space-x-1.5 shrink-0 ${
              activeTab === "control"
                ? "bg-slate-800 text-pink-400 border border-pink-400"
                : "text-slate-500 hover:text-slate-300"
            }`}
          >
            <Settings className="w-3 h-3 text-pink-400" />
            <span>control</span>
          </button>

          <button
            onClick={() => setActiveTab("filter")}
            className={`px-2.5 py-1 rounded text-[10px] font-bold transition-all flex items-center space-x-1.5 shrink-0 ${
              activeTab === "filter"
                ? "bg-slate-800 text-[#39FF14] border border-[#39FF14]"
                : "text-slate-500 hover:text-slate-300"
            }`}
          >
            <ShieldCheck className="w-3 h-3 text-purple-400" />
            <span>Filter Plist</span>
          </button>

          <button
            onClick={() => setActiveTab("jailed_script")}
            className={`px-2.5 py-1 rounded text-[10px] font-bold transition-all flex items-center space-x-1.5 shrink-0 ${
              activeTab === "jailed_script"
                ? "bg-slate-800 text-pink-500 border border-pink-500"
                : "text-slate-500 hover:text-slate-300"
            }`}
          >
            <Terminal className="w-3 h-3 text-pink-500" />
            <span>patch_ipa.sh</span>
          </button>

          <button
            onClick={() => setActiveTab("native_ext")}
            className={`px-2.5 py-1 rounded text-[10px] font-bold transition-all flex items-center space-x-1.5 shrink-0 ${
              activeTab === "native_ext"
                ? "bg-slate-800 text-emerald-400 border border-emerald-400"
                : "text-slate-500 hover:text-slate-300"
            }`}
          >
            <AppWindow className="w-3 h-3 text-emerald-400" />
            <span>Extension.swift</span>
          </button>

          <button
            onClick={() => setActiveTab("json")}
            className={`px-2.5 py-1 rounded text-[10px] font-bold transition-all flex items-center space-x-1.5 shrink-0 ${
              activeTab === "json"
                ? "bg-slate-800 text-[#39FF14] border border-[#39FF14]"
                : "text-slate-500 hover:text-slate-300"
            }`}
          >
            <Code className="w-3 h-3 text-amber-400" />
            <span>project.json</span>
          </button>
        </div>

        {/* Copy & Download Actions */}
        <div className="flex items-center space-x-2 shrink-0">
          <button
            onClick={handleCopy}
            className="flex items-center space-x-1.5 px-3 py-1 bg-slate-900 hover:bg-slate-800 border border-slate-700 rounded text-[10px] text-slate-300 font-bold transition-all"
          >
            {copied ? (
              <>
                <Check className="w-3 h-3 text-[#39FF14]" />
                <span className="text-[#39FF14]">COPIED</span>
              </>
            ) : (
              <>
                <Copy className="w-3 h-3" />
                <span>COPY CODE</span>
              </>
            )}
          </button>

          <button
            onClick={handleDownloadFile}
            className="flex items-center space-x-1.5 px-3 py-1 bg-[#00F0FF] text-black font-extrabold rounded text-[10px] transition-all hover:bg-cyan-300 uppercase tracking-wider shadow-md"
          >
            <Download className="w-3 h-3" />
            <span>EXPORT {filename}</span>
          </button>
        </div>
      </div>

      {/* Code Viewer Body */}
      <div className="flex-1 p-6 overflow-auto bg-slate-950 font-mono text-xs leading-relaxed relative">
        <pre className="text-[#39FF14] whitespace-pre font-mono select-text selection:bg-slate-800 selection:text-[#00F0FF]">
          <code>{code}</code>
        </pre>
      </div>
    </div>
  );
};

