import React, { useState, useRef } from "react";
import { BlockData, BlockType, Project } from "../types";
import { BLOCK_TEMPLATES } from "./BlockPalette";
import { BLOCK_REGISTRY } from "../services/blockRegistry";
import {
  ZoomIn,
  ZoomOut,
  RotateCcw,
  Plus,
  Trash2,
  Sparkles,
  Layers,
  Copy,
  Compass,
  Zap,
  Activity,
  Crosshair,
  Maximize2
} from "lucide-react";

interface NodeCanvasProps {
  project: Project;
  selectedBlockId: string | null;
  onSelectBlock: (id: string | null) => void;
  onUpdateBlock: (updated: BlockData) => void;
  onAddBlock: (type: BlockType, position?: { x: number; y: number }) => void;
  onDeleteBlock: (id: string) => void;
  onDuplicateBlock: (id: string) => void;
  onOpenGemini: () => void;
}

export const NodeCanvas: React.FC<NodeCanvasProps> = ({
  project,
  selectedBlockId,
  onSelectBlock,
  onUpdateBlock,
  onAddBlock,
  onDeleteBlock,
  onDuplicateBlock,
  onOpenGemini,
}) => {
  const containerRef = useRef<HTMLDivElement>(null);
  const [zoom, setZoom] = useState<number>(1);
  const [pan, setPan] = useState<{ x: number; y: number }>({ x: 0, y: 0 });
  const [isPanning, setIsPanning] = useState<boolean>(false);
  const [startPan, setStartPan] = useState<{ x: number; y: number }>({ x: 0, y: 0 });

  // Dragging node state
  const [draggingBlockId, setDraggingBlockId] = useState<string | null>(null);
  const [dragOffset, setDragOffset] = useState<{ x: number; y: number }>({ x: 0, y: 0 });

  // Quick Add Menu state
  const [isQuickAddOpen, setIsQuickAddOpen] = useState<boolean>(false);
  const [quickAddPos, setQuickAddPos] = useState<{ x: number; y: number }>({ x: 100, y: 100 });

  // Handle Pan start
  const handleMouseDown = (e: React.MouseEvent) => {
    if (e.button === 0 && (e.target as HTMLElement).classList.contains("canvas-bg")) {
      setIsPanning(true);
      setStartPan({ x: e.clientX - pan.x, y: e.clientY - pan.y });
      onSelectBlock(null);
    }
  };

  const handleMouseMove = (e: React.MouseEvent) => {
    if (isPanning) {
      setPan({ x: e.clientX - startPan.x, y: e.clientY - startPan.y });
    } else if (draggingBlockId) {
      const block = project.blocks.find((b) => b.id === draggingBlockId);
      if (block) {
        const newX = Math.round((e.clientX - pan.x - dragOffset.x) / zoom / 10) * 10;
        const newY = Math.round((e.clientY - pan.y - dragOffset.y) / zoom / 10) * 10;
        onUpdateBlock({ ...block, position: { x: newX, y: newY } });
      }
    }
  };

  const handleMouseUp = () => {
    setIsPanning(false);
    setDraggingBlockId(null);
  };

  // Touch Handlers for Mobile (iPhone / iPad) Panning & Node Dragging
  const handleTouchStart = (e: React.TouchEvent) => {
    if (e.touches.length === 1) {
      const touch = e.touches[0];
      if ((e.target as HTMLElement).classList.contains("canvas-bg")) {
        setIsPanning(true);
        setStartPan({ x: touch.clientX - pan.x, y: touch.clientY - pan.y });
        onSelectBlock(null);
      }
    }
  };

  const handleTouchMove = (e: React.TouchEvent) => {
    if (e.touches.length === 1) {
      const touch = e.touches[0];
      if (isPanning) {
        setPan({ x: touch.clientX - startPan.x, y: touch.clientY - startPan.y });
      } else if (draggingBlockId) {
        const block = project.blocks.find((b) => b.id === draggingBlockId);
        if (block) {
          const newX = Math.round((touch.clientX - pan.x - dragOffset.x) / zoom / 10) * 10;
          const newY = Math.round((touch.clientY - pan.y - dragOffset.y) / zoom / 10) * 10;
          onUpdateBlock({ ...block, position: { x: newX, y: newY } });
        }
      }
    }
  };

  const handleTouchEnd = () => {
    setIsPanning(false);
    setDraggingBlockId(null);
  };

  // Node drag start
  const handleNodeDragStart = (e: React.MouseEvent, block: BlockData) => {
    e.stopPropagation();
    onSelectBlock(block.id);
    setDraggingBlockId(block.id);
    setDragOffset({
      x: e.clientX - (block.position.x * zoom + pan.x),
      y: e.clientY - (block.position.y * zoom + pan.y),
    });
  };

  const handleNodeTouchStart = (e: React.TouchEvent, block: BlockData) => {
    e.stopPropagation();
    if (e.touches.length === 1) {
      const touch = e.touches[0];
      onSelectBlock(block.id);
      setDraggingBlockId(block.id);
      setDragOffset({
        x: touch.clientX - (block.position.x * zoom + pan.x),
        y: touch.clientY - (block.position.y * zoom + pan.y),
      });
    }
  };

  // Wheel zoom
  const handleWheel = (e: React.WheelEvent) => {
    if (e.ctrlKey || e.metaKey) {
      e.preventDefault();
      const zoomFactor = e.deltaY < 0 ? 1.1 : 0.9;
      setZoom((prev) => Math.min(Math.max(prev * zoomFactor, 0.4), 2.5));
    } else {
      setPan((prev) => ({ x: prev.x - e.deltaX, y: prev.y - e.deltaY }));
    }
  };

  const handleContextMenu = (e: React.MouseEvent) => {
    e.preventDefault();
    const rect = containerRef.current?.getBoundingClientRect();
    if (rect) {
      const x = Math.round((e.clientX - rect.left - pan.x) / zoom);
      const y = Math.round((e.clientY - rect.top - pan.y) / zoom);
      setQuickAddPos({ x, y });
      setIsQuickAddOpen(true);
    }
  };

  // Compute Intelligent Circuit / Blueprint Trace SVG lines between blocks
  const renderConnections = () => {
    const lines: React.ReactNode[] = [];

    project.blocks.forEach((block) => {
      // 1. Hook block to its children blocks
      if (block.type === "hook" && block.childrenBlockIds) {
        block.childrenBlockIds.forEach((childId) => {
          const child = project.blocks.find((b) => b.id === childId);
          if (child) {
            const startX = block.position.x + 130;
            const startY = block.position.y + 105;
            const endX = child.position.x + 130;
            const endY = child.position.y;

            const path = `M ${startX} ${startY} C ${startX} ${startY + 50}, ${endX} ${endY - 50}, ${endX} ${endY}`;

            lines.push(
              <g key={`hook-child-${block.id}-${child.id}`}>
                {/* Outer Glow Path */}
                <path
                  d={path}
                  fill="none"
                  stroke="#00F0FF"
                  strokeWidth="6"
                  className="opacity-20 blur-[3px]"
                />
                {/* Circuit Trace Secondary Wire */}
                <path
                  d={path}
                  fill="none"
                  stroke="#00F0FF"
                  strokeWidth="2.5"
                  className="opacity-80"
                />
                {/* Pulsing Energy Laser Wire */}
                <path
                  d={path}
                  fill="none"
                  stroke="url(#hook-circuit-grad)"
                  strokeWidth="2"
                  strokeDasharray="8 4"
                  className="animate-circuit-flow"
                />
                {/* Terminal Connection Pins */}
                <circle cx={startX} cy={startY} r="4" fill="#00F0FF" className="shadow-[0_0_8px_#00F0FF]" />
                <circle cx={endX} cy={endY} r="4.5" fill="#39FF14" className="shadow-[0_0_10px_#39FF14]" />
              </g>
            );
          }
        });
      }

      // 2. Chained nextBlockId connections
      if (block.nextBlockId) {
        const nextBlock = project.blocks.find((b) => b.id === block.nextBlockId);
        if (nextBlock) {
          const startX = block.position.x + 130;
          const startY = block.position.y + 120;
          const endX = nextBlock.position.x + 130;
          const endY = nextBlock.position.y;

          const path = `M ${startX} ${startY} C ${startX} ${startY + 40}, ${endX} ${endY - 40}, ${endX} ${endY}`;

          lines.push(
            <g key={`next-${block.id}-${nextBlock.id}`}>
              <path
                d={path}
                fill="none"
                stroke="#39FF14"
                strokeWidth="5"
                className="opacity-20 blur-[2px]"
              />
              <path
                d={path}
                fill="none"
                stroke="#39FF14"
                strokeWidth="2"
                strokeDasharray="6 3"
                className="animate-circuit-flow opacity-90"
              />
              <circle cx={startX} cy={startY} r="3.5" fill="#39FF14" />
              <circle cx={endX} cy={endY} r="4" fill="#39FF14" />
            </g>
          );
        }
      }
    });

    return (
      <svg className="absolute inset-0 w-full h-full pointer-events-none z-10">
        <defs>
          <linearGradient id="hook-circuit-grad" x1="0%" y1="0%" x2="0%" y2="100%">
            <stop offset="0%" stopColor="#00F0FF" />
            <stop offset="100%" stopColor="#39FF14" />
          </linearGradient>
        </defs>
        {lines}
      </svg>
    );
  };

  // Generate X/Y Drafting Rulers
  const renderDraftingRulers = () => {
    const ticks = [];
    const step = 100 * zoom;
    const startX = (pan.x % step) - step;
    const startY = (pan.y % step) - step;

    for (let x = startX; x < window.innerWidth; x += step) {
      const coordVal = Math.round((x - pan.x) / zoom);
      ticks.push(
        <div
          key={`x-${x}`}
          className="absolute text-[8px] font-mono text-cyan-500/50 flex flex-col items-center pointer-events-none"
          style={{ left: `${x}px`, top: '2px' }}
        >
          <span className="leading-none">{coordVal}mm</span>
          <div className="w-[1px] h-2 bg-cyan-500/30 mt-0.5"></div>
        </div>
      );
    }

    for (let y = startY; y < window.innerHeight; y += step) {
      const coordVal = Math.round((y - pan.y) / zoom);
      ticks.push(
        <div
          key={`y-${y}`}
          className="absolute text-[8px] font-mono text-cyan-500/50 flex items-center space-x-1 pointer-events-none"
          style={{ left: '2px', top: `${y}px` }}
        >
          <div className="h-[1px] w-2 bg-cyan-500/30"></div>
          <span className="leading-none">{coordVal}</span>
        </div>
      );
    }

    return (
      <div className="absolute inset-0 pointer-events-none z-20 overflow-hidden">
        {/* Top X Rule Bar */}
        <div className="absolute top-0 left-0 right-0 h-4 bg-slate-950/80 border-b border-cyan-500/20 backdrop-blur-sm">
          {ticks.filter((t) => t.key.startsWith("x-"))}
        </div>
        {/* Left Y Rule Bar */}
        <div className="absolute top-0 left-0 bottom-0 w-8 bg-slate-950/80 border-r border-cyan-500/20 backdrop-blur-sm hidden sm:block">
          {ticks.filter((t) => t.key.startsWith("y-"))}
        </div>
      </div>
    );
  };

  return (
    <div
      ref={containerRef}
      onMouseDown={handleMouseDown}
      onMouseMove={handleMouseMove}
      onMouseUp={handleMouseUp}
      onTouchStart={handleTouchStart}
      onTouchMove={handleTouchMove}
      onTouchEnd={handleTouchEnd}
      onWheel={handleWheel}
      onContextMenu={handleContextMenu}
      className="canvas-bg relative w-full h-[calc(100vh-3rem)] bg-blueprint-workbench overflow-hidden select-none cursor-grab active:cursor-grabbing font-mono"
      style={{
        backgroundSize: `100% 100%, ${40 * zoom}px ${40 * zoom}px, ${40 * zoom}px ${40 * zoom}px, ${8 * zoom}px ${8 * zoom}px, ${8 * zoom}px ${8 * zoom}px`,
        backgroundPosition: `center, ${pan.x}px ${pan.y}px, ${pan.x}px ${pan.y}px, ${pan.x}px ${pan.y}px, ${pan.x}px ${pan.y}px`,
      }}
    >
      {/* Drafting Axis Rulers */}
      {renderDraftingRulers()}

      {/* Zoom / Pan Matrix Layer */}
      <div
        className="absolute inset-0 origin-top-left pointer-events-none"
        style={{
          transform: `translate(${pan.x}px, ${pan.y}px) scale(${zoom})`,
        }}
      >
        {/* Render Intelligent Blueprint Circuit Connections */}
        {renderConnections()}

        {/* Render Engineering Module Nodes */}
        {project.blocks.map((block) => {
          const isSelected = selectedBlockId === block.id;
          const template = BLOCK_TEMPLATES.find((t) => t.type === block.type);
          const isHook = block.type === "hook";

          return (
            <div
              key={block.id}
              onMouseDown={(e) => handleNodeDragStart(e, block)}
              onTouchStart={(e) => handleNodeTouchStart(e, block)}
              className={`absolute pointer-events-auto w-64 rounded-lg bg-slate-950/95 border transition-all duration-200 cursor-pointer group z-20 backdrop-blur-md overflow-hidden ${
                isSelected
                  ? isHook
                    ? "border-cyan-400 shadow-[0_0_25px_rgba(0,240,255,0.35)] ring-1 ring-cyan-400/50"
                    : "border-[#39FF14] shadow-[0_0_25px_rgba(57,255,20,0.35)] ring-1 ring-[#39FF14]/50"
                  : isHook
                  ? "border-cyan-500/50 hover:border-cyan-400 shadow-[0_4px_20px_rgba(0,0,0,0.8)]"
                  : "border-slate-800 hover:border-emerald-500/50 shadow-[0_4px_20px_rgba(0,0,0,0.8)]"
              }`}
              style={{
                left: `${block.position.x}px`,
                top: `${block.position.y}px`,
              }}
            >
              {/* Technical Bracket Corner Overlays */}
              <div className="absolute top-1 left-1 text-[7px] text-cyan-500/40 pointer-events-none">+</div>
              <div className="absolute top-1 right-1 text-[7px] text-cyan-500/40 pointer-events-none">+</div>

              {/* Module Header Bar */}
              <div
                className={`px-3 py-1.5 text-[10px] font-bold flex items-center justify-between border-b ${
                  isHook
                    ? "bg-gradient-to-r from-cyan-950 via-slate-900 to-cyan-950 border-cyan-500/40 text-cyan-300"
                    : "bg-gradient-to-r from-slate-900 via-slate-800 to-slate-900 border-slate-800 text-slate-200"
                }`}
              >
                <div className="flex items-center space-x-2 truncate">
                  <span className={`w-2 h-2 rounded-full ${isHook ? "bg-[#00F0FF] shadow-[0_0_6px_#00F0FF]" : "bg-[#39FF14] shadow-[0_0_6px_#39FF14]"}`}></span>
                  <span className="uppercase tracking-wider font-bold truncate text-[10px]">
                    {block.type.toUpperCase()}: {block.targetClass || block.title || template?.title}
                  </span>
                </div>

                <div className="flex items-center space-x-1 opacity-80 hover:opacity-100">
                  <button
                    onClick={(e) => {
                      e.stopPropagation();
                      onDuplicateBlock(block.id);
                    }}
                    className="p-1 hover:bg-slate-800 rounded text-slate-400 hover:text-white transition-colors"
                    title="Duplicate Module"
                  >
                    <Copy className="w-3 h-3" />
                  </button>
                  <button
                    onClick={(e) => {
                      e.stopPropagation();
                      onDeleteBlock(block.id);
                    }}
                    className="p-1 hover:bg-slate-800 rounded text-slate-400 hover:text-rose-400 transition-colors"
                    title="Delete Module"
                  >
                    <Trash2 className="w-3 h-3" />
                  </button>
                </div>
              </div>

              {/* Node Body Details */}
              <div className="p-3 text-[10px] space-y-2 text-slate-300 font-mono bg-slate-950/80">
                {block.type === "hook" && (
                  <div>
                    <div className="flex items-center justify-between text-slate-500 mb-0.5 font-bold uppercase text-[8px] tracking-wider">
                      <span>HOOKED TARGET METHOD</span>
                      <span className="text-cyan-400 font-mono">[LOGOS]</span>
                    </div>
                    <div className="bg-slate-900/90 p-1.5 text-cyan-300 border border-cyan-500/30 font-mono rounded truncate shadow-inner">
                      {block.isClassMethod ? "+" : "-"} {block.targetMethod || "viewDidAppear:"}
                    </div>
                  </div>
                )}

                {block.type === "orig" && (
                  <div>
                    <label className="text-slate-500 block mb-0.5 font-bold uppercase text-[8px] tracking-wider">ORIGINAL CALL RELAY</label>
                    <div className="bg-slate-900/90 p-1.5 text-[#39FF14] border border-emerald-500/30 font-mono rounded flex justify-between items-center shadow-inner">
                      <span className="font-bold">%orig;</span>
                      <span className="text-slate-500 text-[8px]">SUBSTRATE PASS</span>
                    </div>
                  </div>
                )}

                {block.type === "skip_orig" && (
                  <div className="text-amber-400 bg-amber-950/30 p-1.5 border border-amber-500/30 rounded text-[9px] italic">
                    ⚠️ SUPPRESSES %orig EXECUTION
                  </div>
                )}

                {block.type === "log" && (
                  <div>
                    <label className="text-slate-500 block mb-0.5 font-bold uppercase text-[8px] tracking-wider">TELEMETRY MESSAGE LOG</label>
                    <input
                      type="text"
                      value={block.message || "Tweak Loaded!"}
                      readOnly
                      className="w-full bg-slate-900/90 border border-slate-800 p-1.5 text-slate-200 outline-none rounded font-mono text-[10px]"
                    />
                  </div>
                )}

                {block.type === "modify_property" && (
                  <div>
                    <label className="text-slate-500 block mb-0.5 font-bold uppercase text-[8px] tracking-wider">PROPERTY OVERRIDE</label>
                    <div className="text-cyan-300 bg-slate-900/90 p-1.5 rounded border border-cyan-500/30 truncate shadow-inner">
                      {block.targetObject || "self"}.{block.propertyName || "view.alpha"} = {block.value || "1.0"}
                    </div>
                  </div>
                )}

                {block.type === "conditional" && (
                  <div>
                    <label className="text-slate-500 block mb-0.5 font-bold uppercase text-[8px] tracking-wider">LOGIC BRANCH CONDITIONAL</label>
                    <div className="text-[#39FF14] bg-slate-900/90 p-1.5 rounded border border-emerald-500/30 font-mono shadow-inner">
                      if ({block.condition || "self != nil"})
                    </div>
                  </div>
                )}

                {block.type === "delay" && (
                  <div>
                    <label className="text-slate-500 block mb-0.5 font-bold uppercase text-[8px] tracking-wider">GCD ASYNC DELAY</label>
                    <div className="text-amber-300 bg-slate-900/90 p-1.5 rounded border border-amber-500/30 font-mono shadow-inner">
                      dispatch_after: {block.durationSeconds || 1.0}s
                    </div>
                  </div>
                )}

                {block.type === "notification" && (
                  <div>
                    <label className="text-slate-500 block mb-0.5 font-bold uppercase text-[8px] tracking-wider">SYSTEM BANNER ALERT</label>
                    <div className="text-slate-200 bg-slate-900/90 p-1.5 rounded border border-slate-800 font-mono text-[10px] shadow-inner">
                      {block.titleText || "Alert"}: {block.bodyText || "Message"}
                    </div>
                  </div>
                )}

                {block.type === "return_value" && (
                  <div>
                    <label className="text-slate-500 block mb-0.5 font-bold uppercase text-[8px] tracking-wider">METHOD RETURN OVERRIDE</label>
                    <div className="text-[#39FF14] font-bold bg-slate-900/90 p-1.5 rounded border border-emerald-500/30 font-mono shadow-inner">
                      return {block.returnValue || "YES"};
                    </div>
                  </div>
                )}

                {block.type === "custom_logos" && (
                  <div className="bg-slate-900/90 p-1.5 rounded border border-slate-800 font-mono text-[9px] text-[#39FF14] truncate shadow-inner">
                    {block.customCode || "// Custom Logos snippet"}
                  </div>
                )}

                {block.type === "annotation" && (
                  <div className="bg-purple-950/20 p-2 rounded border border-purple-500/30 font-mono text-[9px] text-purple-300 italic">
                    {block.annotationText || "// Engineering Note"}
                  </div>
                )}

                {block.type === "new_method" && (
                  <div>
                    <label className="text-slate-500 block mb-0.5 font-bold uppercase text-[8px] tracking-wider">NEW SELECTOR (%new)</label>
                    <div className="bg-slate-900/90 p-1.5 text-amber-400 border border-amber-500/30 font-mono rounded truncate shadow-inner">
                      %new - ({block.returnType || "void"}){block.targetMethod || "customMethod"}
                    </div>
                  </div>
                )}

                {block.type === "constructor" && (
                  <div>
                    <label className="text-slate-500 block mb-0.5 font-bold uppercase text-[8px] tracking-wider">PROCESS INITIALIZER</label>
                    <div className="bg-slate-900/90 p-1.5 text-emerald-400 border border-emerald-500/30 font-mono rounded truncate shadow-inner">
                      %ctor &#123; /* Initializer */ &#125;
                    </div>
                  </div>
                )}

                {block.type === "group" && (
                  <div>
                    <label className="text-slate-500 block mb-0.5 font-bold uppercase text-[8px] tracking-wider">LOGOS HOOK GROUP</label>
                    <div className="bg-slate-900/90 p-1.5 text-rose-400 border border-rose-500/30 font-mono rounded truncate shadow-inner">
                      %group {block.groupName || "CustomGroup"}
                    </div>
                  </div>
                )}
              </div>

              {/* Socket Pin Terminals Footbar */}
              <div className="flex justify-between items-center px-2.5 py-1 bg-slate-950 border-t border-slate-900 text-[8px] text-slate-500">
                <div className="flex items-center space-x-1">
                  <div className="w-2 h-2 rounded-full bg-[#00F0FF] shadow-[0_0_6px_#00F0FF]"></div>
                  <span>IN</span>
                </div>
                <span className="font-mono text-[7px] text-slate-600 uppercase tracking-widest">
                  #{block.id.slice(0, 6)}
                </span>
                <div className="flex items-center space-x-1">
                  <span>OUT</span>
                  <div className="w-2 h-2 rounded-full bg-[#39FF14] shadow-[0_0_6px_#39FF14]"></div>
                </div>
              </div>
            </div>
          );
        })}
      </div>

      {/* Blueprint Canvas Floating Workbench Toolbar */}
      <div className="absolute bottom-4 left-3 right-3 sm:right-auto sm:left-12 z-30 flex items-center justify-between sm:justify-start bg-slate-950/90 border border-cyan-500/30 rounded-xl p-1.5 shadow-[0_0_20px_rgba(0,0,0,0.8)] backdrop-blur-md space-x-1.5 sm:space-x-2 text-slate-300">
        <button
          onClick={() => setZoom((z) => Math.min(z + 0.15, 2.5))}
          className="p-1.5 sm:p-2 hover:bg-slate-900 rounded-lg hover:text-cyan-400 transition-all"
          title="Zoom In"
        >
          <ZoomIn className="w-3.5 h-3.5 sm:w-4 sm:h-4" />
        </button>
        <span className="text-[10px] sm:text-xs font-mono text-cyan-300 font-bold w-12 text-center">
          {Math.round(zoom * 100)}%
        </span>
        <button
          onClick={() => setZoom((z) => Math.max(z - 0.15, 0.4))}
          className="p-1.5 sm:p-2 hover:bg-slate-900 rounded-lg hover:text-cyan-400 transition-all"
          title="Zoom Out"
        >
          <ZoomOut className="w-3.5 h-3.5 sm:w-4 sm:h-4" />
        </button>
        <button
          onClick={() => {
            setZoom(1);
            setPan({ x: 0, y: 0 });
          }}
          className="p-1.5 sm:p-2 hover:bg-slate-900 rounded-lg hover:text-cyan-400 transition-all"
          title="Reset Blueprint View"
        >
          <RotateCcw className="w-3.5 h-3.5 sm:w-4 sm:h-4" />
        </button>

        <div className="h-4 w-[1px] bg-slate-800" />

        <div className="hidden lg:flex items-center space-x-2 text-[9px] text-slate-500 font-mono px-1">
          <span>X: {Math.round(pan.x)}</span>
          <span>Y: {Math.round(pan.y)}</span>
        </div>

        <div className="h-4 w-[1px] bg-slate-800 hidden lg:block" />

        <button
          onClick={() => setIsQuickAddOpen(!isQuickAddOpen)}
          className="flex items-center space-x-1 px-3 py-1.5 bg-cyan-950/60 text-[#00F0FF] border border-cyan-500/40 rounded-lg text-[11px] font-mono hover:bg-cyan-900/80 transition-all shadow-[0_0_12px_rgba(0,240,255,0.2)]"
        >
          <Plus className="w-3.5 h-3.5" />
          <span>ADD MODULE</span>
        </button>
      </div>

      {/* Quick Add Blueprint Module Palette Popover */}
      {isQuickAddOpen && (
        <div className="absolute top-12 sm:top-16 left-3 right-3 sm:right-auto sm:left-12 z-40 w-[calc(100vw-1.5rem)] sm:w-84 max-w-sm bg-slate-950/95 border border-cyan-500/40 rounded-xl shadow-2xl p-3 backdrop-blur-xl animate-in fade-in zoom-in-95 duration-150">
          <div className="flex items-center justify-between pb-2 mb-2 border-b border-slate-800">
            <span className="font-mono text-xs font-bold text-[#00F0FF] uppercase tracking-wider flex items-center space-x-1.5">
              <Layers className="w-3.5 h-3.5 text-[#00F0FF]" />
              <span>MODULE SPECIFICATIONS</span>
            </span>
            <button
              onClick={() => setIsQuickAddOpen(false)}
              className="text-xs text-slate-500 hover:text-slate-300 p-1"
            >
              ✕
            </button>
          </div>

          <div className="space-y-1.5 max-h-72 sm:max-h-80 overflow-y-auto pr-1">
            {BLOCK_TEMPLATES.filter((tmpl) => {
              const def = Object.values(BLOCK_REGISTRY).find((d) => d.type === tmpl.type);
              if (!def) return true;
              return def.supportedTargetTypes.includes(project.projectType || "jailbreak_tweak");
            }).map((tmpl) => (
              <button
                key={tmpl.type}
                onClick={() => {
                  onAddBlock(tmpl.type, quickAddPos);
                  setIsQuickAddOpen(false);
                }}
                className="w-full text-left p-2 rounded-lg border border-slate-800 bg-slate-900/60 hover:bg-slate-900 hover:border-cyan-500/50 flex items-center space-x-2.5 transition-all group"
              >
                <div className="p-1.5 rounded bg-slate-950 border border-slate-800 text-cyan-400 group-hover:text-[#39FF14] transition-colors">
                  {tmpl.icon}
                </div>
                <div>
                  <div className="font-mono font-bold text-xs text-slate-200 group-hover:text-cyan-300">
                    {tmpl.title}
                  </div>
                  <div className="text-[10px] text-slate-400 leading-tight">
                    {tmpl.description}
                  </div>
                </div>
              </button>
            ))}
          </div>
        </div>
      )}
    </div>
  );
};
