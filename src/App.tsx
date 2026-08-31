import React, { useState, useEffect } from "react";
import { Project, BlockData, BlockType, ViewMode, ProjectTargetType } from "./types";
import { INITIAL_DEFAULT_PROJECT } from "./utils/mockHeaders";
import { Header } from "./components/Header";
import { NodeCanvas } from "./components/NodeCanvas";
import { InspectorPanel } from "./components/InspectorPanel";
import { GeminiAssistant } from "./components/GeminiAssistant";
import { CodePanel } from "./components/CodePanel";
import { SwiftUICompanion } from "./components/SwiftUICompanion";
import { HeaderExplorer } from "./components/HeaderExplorer";
import { ErrorBoundary } from "./components/ErrorBoundary";
import { AIManager } from "./services/ai/AIManager";
import {
  saveProjectToLocalStorage,
  loadProjectFromLocalStorage,
  resetProjectToDefault,
  exportProjectToJSONFile,
  importProjectFromJSONFile,
  exportProjectToZip
} from "./services/projectService";
import { Check, Info, Sparkles, Terminal, Play } from "lucide-react";

export default function App() {
  const [project, setProject] = useState<Project>(() => loadProjectFromLocalStorage());
  const [viewMode, setViewMode] = useState<ViewMode>("studio");
  const [selectedBlockId, setSelectedBlockId] = useState<string | null>("block-1");
  const [isGeminiOpen, setIsGeminiOpen] = useState<boolean>(false);
  const [toastMessage, setToastMessage] = useState<string | null>(null);

  // Auto-save project changes to localStorage for local data persistence
  useEffect(() => {
    saveProjectToLocalStorage(project);
  }, [project]);

  const showToast = (msg: string) => {
    setToastMessage(msg);
    setTimeout(() => setToastMessage(null), 3000);
  };

  // Reset workspace
  const handleResetWorkspace = () => {
    const defaultProj = resetProjectToDefault();
    setProject(defaultProj);
    setSelectedBlockId(defaultProj.blocks[0]?.id || null);
    showToast("Workspace reset to default project");
  };

  // Block CRUD
  const handleAddBlock = (type: BlockType, customPos?: { x: number; y: number }) => {
    const id = `block-${Date.now()}`;
    const newBlock: BlockData = {
      id,
      type,
      title: `${type.toUpperCase()} Block`,
      position: customPos || { x: 180 + Math.random() * 80, y: 180 + Math.random() * 80 },
      targetClass: "UIViewController",
      targetMethod: "viewDidAppear:",
      message: "Tweak block executed",
      value: "[UIColor systemGreenColor]",
      propertyName: "backgroundColor",
      durationSeconds: 1.5,
      titleText: "Alert",
      bodyText: "Notification trigger",
      condition: "self != nil",
      returnValue: "YES"
    };

    setProject((prev) => ({
      ...prev,
      blocks: [...prev.blocks, newBlock],
      updatedAt: new Date().toISOString()
    }));

    setSelectedBlockId(id);
    showToast(`Added new ${type} block to canvas`);
  };

  const handleUpdateBlock = (updatedBlock: BlockData) => {
    setProject((prev) => ({
      ...prev,
      blocks: prev.blocks.map((b) => (b.id === updatedBlock.id ? updatedBlock : b)),
      updatedAt: new Date().toISOString()
    }));
  };

  const handleDeleteBlock = (id: string) => {
    setProject((prev) => ({
      ...prev,
      blocks: prev.blocks.filter((b) => b.id !== id),
      updatedAt: new Date().toISOString()
    }));
    if (selectedBlockId === id) setSelectedBlockId(null);
    showToast("Block deleted");
  };

  const handleDuplicateBlock = (id: string) => {
    const target = project.blocks.find((b) => b.id === id);
    if (!target) return;

    const dupId = `block-${Date.now()}`;
    const duplicated: BlockData = {
      ...target,
      id: dupId,
      title: `${target.title} (Copy)`,
      position: { x: target.position.x + 30, y: target.position.y + 30 }
    };

    setProject((prev) => ({
      ...prev,
      blocks: [...prev.blocks, duplicated],
      updatedAt: new Date().toISOString()
    }));

    setSelectedBlockId(dupId);
    showToast("Block duplicated");
  };

  const handleApplyGeneratedBlocks = (newBlocks: BlockData[]) => {
    setProject((prev) => ({
      ...prev,
      blocks: newBlocks,
      updatedAt: new Date().toISOString()
    }));
    if (newBlocks[0]) setSelectedBlockId(newBlocks[0].id);
    showToast("Applied AI block graph to workspace!");
  };

  const handleExportJson = () => {
    exportProjectToJSONFile(project);
    showToast("Project JSON saved to disk!");
  };

  const handleImportJson = async (file: File) => {
    try {
      const importedProj = await importProjectFromJSONFile(file);
      setProject(importedProj);
      if (importedProj.blocks[0]) setSelectedBlockId(importedProj.blocks[0].id);
      showToast(`Successfully reopened ${importedProj.name}!`);
    } catch (err: any) {
      showToast(`Import Error: ${err.message}`);
    }
  };

  const handleExportZip = async () => {
    try {
      await exportProjectToZip(project);
      showToast("Downloaded complete iOS App & Theos Tweak (.zip)!");
    } catch (err: any) {
      console.error(err);
      showToast("Failed to generate zip package");
    }
  };

  const handleLoadPreset = (presetId: string) => {
    if (presetId === "lockscreen") {
      setProject({
        ...INITIAL_DEFAULT_PROJECT,
        id: `proj-${Date.now()}`,
        name: "NeonLock Tweak",
        projectType: "jailbreak_tweak",
        bundleId: "com.workshop.neonlock"
      });
    } else if (presetId === "logger") {
      setProject({
        id: `proj-logger-${Date.now()}`,
        name: "AppLogger Tweak",
        version: "1.0.0",
        author: "Dev",
        bundleId: "com.workshop.applogger",
        projectType: "jailbreak_tweak",
        targetProcess: "SpringBoard",
        tweakFilter: "com.apple.springboard",
        description: "Logs view controller appearances and system events.",
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString(),
        blocks: [
          {
            id: "b-1",
            type: "hook",
            title: "🪝 Hook UIViewController",
            position: { x: 100, y: 100 },
            targetClass: "UIViewController",
            targetMethod: "viewWillAppear:",
            childrenBlockIds: ["b-2", "b-3"]
          },
          {
            id: "b-2",
            type: "orig",
            title: "📞 Call Original",
            position: { x: 140, y: 240 }
          },
          {
            id: "b-3",
            type: "log",
            title: "📝 Log Message",
            position: { x: 140, y: 360 },
            message: "App view controller presented!"
          }
        ]
      });
    } else if (presetId === "alert") {
      setProject({
        id: `proj-alert-${Date.now()}`,
        name: "BannerAlert Tweak",
        version: "1.0.0",
        author: "Dev",
        bundleId: "com.workshop.banneralert",
        projectType: "jailbreak_tweak",
        targetProcess: "SpringBoard",
        tweakFilter: "com.apple.springboard",
        description: "Presents custom alert and audio feedback on lock.",
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString(),
        blocks: [
          {
            id: "a-1",
            type: "hook",
            title: "🪝 Hook SBLockScreenManager",
            position: { x: 100, y: 100 },
            targetClass: "SBLockScreenManager",
            targetMethod: "lockUIFromSource:withOptions:",
            childrenBlockIds: ["a-2", "a-3"]
          },
          {
            id: "a-2",
            type: "orig",
            title: "📞 Call Original",
            position: { x: 140, y: 240 }
          },
          {
            id: "a-3",
            type: "notification",
            title: "🔔 Security Alert",
            position: { x: 140, y: 360 },
            titleText: "The Workshop Security",
            bodyText: "Device UI locked successfully."
          }
        ]
      });
    }
    showToast(`Loaded ${presetId} preset project!`);
  };

  const handleRunSimulation = () => {
    setViewMode("swiftui");
    showToast("Executing iOS tweak simulation test...");
  };

  const handleAddHookBlockFromHeaders = (className: string, methodName: string) => {
    const id = `block-${Date.now()}`;
    const newHook: BlockData = {
      id,
      type: "hook",
      title: `🪝 Hook ${className}`,
      position: { x: 140, y: 140 },
      targetClass: className,
      targetMethod: methodName,
      isClassMethod: false,
      returnType: "void",
      childrenBlockIds: [`block-${Date.now()}-orig`]
    };

    const newOrig: BlockData = {
      id: `block-${Date.now()}-orig`,
      type: "orig",
      title: "📞 Call Original",
      position: { x: 180, y: 280 }
    };

    setProject((prev) => ({
      ...prev,
      blocks: [...prev.blocks, newHook, newOrig],
      updatedAt: new Date().toISOString()
    }));

    setViewMode("studio");
    setSelectedBlockId(id);
    showToast(`Added ${className} hook to canvas!`);
  };

  const handleUpdateProjectType = (targetType: ProjectTargetType) => {
    setProject((prev) => ({
      ...prev,
      projectType: targetType,
      updatedAt: new Date().toISOString()
    }));
    const labelMap = {
      jailbreak_tweak: "Jailbreak Tweak (Theos/Logos)",
      jailed_mod: "Jailed Modification (IPA Patch)",
      native_extension: "Native Extension (SwiftUI)"
    };
    showToast(`Switched target project to: ${labelMap[targetType]}`);
  };

  const activeProvider = AIManager.getActiveProvider();

  return (
    <ErrorBoundary onResetProject={handleResetWorkspace}>
      <div className="w-full h-screen bg-black text-zinc-100 flex flex-col overflow-hidden font-sans select-none">
        {/* Top Header Navigation */}
        <Header
          project={project}
          viewMode={viewMode}
          setViewMode={setViewMode}
          onOpenGemini={() => setIsGeminiOpen(true)}
          onNewProject={() => {
            setProject({
              ...INITIAL_DEFAULT_PROJECT,
              id: `proj-${Date.now()}`,
              name: "New Tweak",
              blocks: []
            });
            showToast("Created new blank tweak project");
          }}
          onImportJson={handleImportJson}
          onExportJson={handleExportJson}
          onExportZip={handleExportZip}
          onLoadPreset={handleLoadPreset}
          onRunSimulation={handleRunSimulation}
          onUpdateProjectType={handleUpdateProjectType}
        />

        {/* Main Workspace Body */}
        <main className="flex-1 flex overflow-hidden relative">
          {viewMode === "studio" && (
            <>
              <NodeCanvas
                project={project}
                selectedBlockId={selectedBlockId}
                onSelectBlock={setSelectedBlockId}
                onUpdateBlock={handleUpdateBlock}
                onAddBlock={handleAddBlock}
                onDeleteBlock={handleDeleteBlock}
                onDuplicateBlock={handleDuplicateBlock}
                onOpenGemini={() => setIsGeminiOpen(true)}
              />

              <InspectorPanel
                project={project}
                selectedBlockId={selectedBlockId}
                onUpdateBlock={handleUpdateBlock}
                onDeleteBlock={handleDeleteBlock}
                onDuplicateBlock={handleDuplicateBlock}
                onClose={() => setSelectedBlockId(null)}
              />
            </>
          )}

          {viewMode === "code" && <CodePanel project={project} />}

          {viewMode === "swiftui" && (
            <SwiftUICompanion
              project={project}
              onUpdateBlock={handleUpdateBlock}
              onRunSimulation={handleRunSimulation}
            />
          )}

          {viewMode === "headers" && (
            <HeaderExplorer onAddHookBlock={handleAddHookBlockFromHeaders} />
          )}
        </main>

        {/* Bottom High-Density Status Bar */}
        <footer className="h-6 border-t border-[#222] bg-[#0a0a0a] flex items-center justify-between px-3 text-[9px] text-gray-500 font-mono z-30 select-none overflow-hidden">
          <div className="flex items-center space-x-2 sm:space-x-3 truncate">
            <span className="flex items-center space-x-1 shrink-0">
              <span className="w-1.5 h-1.5 rounded-full bg-[#39FF14] animate-pulse"></span>
              <span className="text-gray-400 font-bold">READY</span>
            </span>
            <span className="text-gray-700">|</span>
            <span className="truncate">PROCESS: {project.targetProcess}</span>
            <span className="hidden sm:inline text-gray-700">|</span>
            <span className="hidden sm:inline">BLOCKS: {project.blocks.length} NODES</span>
          </div>

          <div className="flex items-center space-x-2 sm:space-x-3 shrink-0">
            <span className="text-[#FF69B4] font-bold uppercase truncate max-w-[90px] sm:max-w-none">{activeProvider.name}</span>
            <span className="hidden sm:inline text-gray-700">|</span>
            <span className="hidden sm:inline">ARM64</span>
          </div>
        </footer>

        {/* AI Assistant Drawer */}
        <GeminiAssistant
          project={project}
          isOpen={isGeminiOpen}
          onClose={() => setIsGeminiOpen(false)}
          onApplyGeneratedBlocks={handleApplyGeneratedBlocks}
        />

        {/* Floating Toast Feedback */}
        {toastMessage && (
          <div className="fixed bottom-12 right-4 sm:bottom-8 sm:right-6 z-50 bg-[#111] border border-[#39FF14] text-[#39FF14] px-3 py-1.5 sm:px-4 sm:py-2 rounded font-mono text-xs shadow-[0_0_15px_rgba(57,255,20,0.3)] flex items-center space-x-2 animate-in slide-in-from-bottom duration-200 max-w-[calc(100vw-2rem)]">
            <Check className="w-4 h-4 text-[#39FF14] shrink-0" />
            <span className="truncate">{toastMessage}</span>
          </div>
        )}
      </div>
    </ErrorBoundary>
  );
}
