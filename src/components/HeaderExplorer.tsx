import React, { useState } from "react";
import { COMMON_IOS_HEADERS } from "../utils/mockHeaders";
import { BookOpen, Search, Plus, Sparkles, Code2, ArrowRight } from "lucide-react";

interface HeaderExplorerProps {
  onAddHookBlock: (className: string, methodName: string) => void;
}

export const HeaderExplorer: React.FC<HeaderExplorerProps> = ({ onAddHookBlock }) => {
  const [search, setSearch] = useState("");
  const [selectedClass, setSelectedClass] = useState(COMMON_IOS_HEADERS[0]);

  const filtered = COMMON_IOS_HEADERS.filter(
    (h) =>
      h.className.toLowerCase().includes(search.toLowerCase()) ||
      h.framework.toLowerCase().includes(search.toLowerCase()) ||
      h.description.toLowerCase().includes(search.toLowerCase())
  );

  return (
    <div className="w-full h-[calc(100vh-3rem)] bg-[#050505] text-gray-200 font-mono flex flex-col md:flex-row">
      {/* Sidebar List */}
      <div className="w-full md:w-80 h-56 md:h-full border-b md:border-b-0 md:border-r border-[#222] p-4 flex flex-col space-y-3 bg-[#0a0a0a] shrink-0">
        <div className="flex items-center space-x-2 text-[#39FF14] font-bold text-xs uppercase tracking-wider">
          <BookOpen className="w-4 h-4 text-[#39FF14]" />
          <span>iOS Framework Headers</span>
        </div>

        {/* Search */}
        <div className="relative">
          <Search className="w-3.5 h-3.5 text-gray-500 absolute left-2.5 top-2.5" />
          <input
            type="text"
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            placeholder="Search headers..."
            className="w-full bg-black border border-[#333] rounded pl-8 pr-3 py-1.5 text-xs text-white placeholder-gray-600 focus:outline-none focus:border-[#39FF14]"
          />
        </div>

        <div className="flex-1 overflow-y-auto space-y-2 pr-1">
          {filtered.map((header) => (
            <button
              key={header.className}
              onClick={() => setSelectedClass(header)}
              className={`w-full text-left p-2.5 rounded border transition-all ${
                selectedClass.className === header.className
                  ? "bg-[#111] border-[#39FF14] text-[#39FF14]"
                  : "bg-black border-[#222] text-gray-400 hover:border-[#333]"
              }`}
            >
              <div className="font-bold text-xs flex items-center justify-between">
                <span>{header.className}</span>
                <span className="text-[9px] px-1.5 py-0.5 rounded bg-[#222] text-gray-400 uppercase">
                  {header.framework}
                </span>
              </div>
              <div className="text-[10px] text-gray-500 mt-1 line-clamp-2">
                {header.description}
              </div>
            </button>
          ))}
        </div>
      </div>

      {/* Main Details View */}
      <div className="flex-1 p-6 overflow-y-auto space-y-6">
        <div className="border-b border-[#222] pb-4">
          <div className="flex items-center justify-between">
            <div>
              <div className="text-xl font-bold text-[#39FF14] font-mono">
                {selectedClass.className}
              </div>
              <div className="text-xs text-gray-400 mt-1">
                Framework: <span className="text-[#FF69B4] font-bold">{selectedClass.framework}.framework</span>
              </div>
            </div>

            <button
              onClick={() =>
                onAddHookBlock(
                  selectedClass.className,
                  selectedClass.commonMethods[0].replace(/^[+-]\s*\([^)]*\)/, "").trim()
                )
              }
              className="flex items-center space-x-2 px-4 py-1.5 bg-[#39FF14] text-black font-bold rounded hover:bg-green-400 text-xs transition-all uppercase tracking-wider"
            >
              <Plus className="w-3.5 h-3.5" />
              <span>Hook Class in Workspace</span>
            </button>
          </div>

          <p className="text-xs text-gray-400 mt-3 leading-relaxed">
            {selectedClass.description}
          </p>
        </div>

        {/* Common Methods List */}
        <div className="space-y-3">
          <div className="text-xs font-bold text-gray-400 uppercase tracking-wider flex items-center space-x-2">
            <Code2 className="w-4 h-4 text-[#39FF14]" />
            <span>Common Target Methods</span>
          </div>

          <div className="grid grid-cols-1 gap-2">
            {selectedClass.commonMethods.map((method, idx) => (
              <div
                key={idx}
                className="p-2.5 bg-black border border-[#222] rounded flex items-center justify-between hover:border-[#333] transition-all"
              >
                <code className="text-[#39FF14] text-xs font-bold">{method}</code>
                <button
                  onClick={() =>
                    onAddHookBlock(
                      selectedClass.className,
                      method.replace(/^[+-]\s*\([^)]*\)/, "").trim()
                    )
                  }
                  className="px-2 py-1 text-[10px] bg-[#111] hover:bg-[#222] text-[#39FF14] border border-[#39FF14]/40 rounded font-bold transition-all"
                >
                  Hook This Method
                </button>
              </div>
            ))}
          </div>
        </div>

        {/* Suggested Tweak Ideas */}
        <div className="space-y-3 pt-4 border-t border-[#222]">
          <div className="text-xs font-bold text-gray-400 uppercase tracking-wider flex items-center space-x-2">
            <Sparkles className="w-4 h-4 text-[#FF69B4]" />
            <span>Suggested Tweak Ideas for {selectedClass.className}</span>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
            {selectedClass.suggestedTweakIdeas.map((idea, idx) => (
              <div
                key={idx}
                className="p-2.5 bg-[#111] border border-[#222] rounded text-xs text-gray-300 flex items-start space-x-2"
              >
                <ArrowRight className="w-3.5 h-3.5 text-[#39FF14] mt-0.5 shrink-0" />
                <span>{idea}</span>
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
};
