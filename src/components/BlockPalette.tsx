import React from "react";
import { BlockType } from "../types";
import { BLOCK_REGISTRY } from "../services/blockRegistry";
import {
  Layers,
  PhoneCall,
  Ban,
  FileText,
  Settings,
  GitBranch,
  Clock,
  Bell,
  CornerDownLeft,
  Code,
  MessageSquare,
  PlusCircle,
  Zap,
  FolderPlus,
  Image,
  FileCode,
  Smartphone,
  AppWindow
} from "lucide-react";

export interface BlockTemplate {
  type: BlockType;
  title: string;
  icon: React.ReactNode;
  category: string;
  description: string;
  color: string;
  borderAccent: string;
}

const ICON_MAP: Record<BlockType, React.ReactNode> = {
  hook: <Layers className="w-4 h-4 text-[#FF69B4]" />,
  orig: <PhoneCall className="w-4 h-4 text-[#39FF14]" />,
  skip_orig: <Ban className="w-4 h-4 text-rose-400" />,
  log: <FileText className="w-4 h-4 text-[#00E5FF]" />,
  modify_property: <Settings className="w-4 h-4 text-[#E040FB]" />,
  conditional: <GitBranch className="w-4 h-4 text-[#FFD700]" />,
  delay: <Clock className="w-4 h-4 text-[#00E676]" />,
  notification: <Bell className="w-4 h-4 text-[#FF9100]" />,
  return_value: <CornerDownLeft className="w-4 h-4 text-[#D500F9]" />,
  custom_logos: <Code className="w-4 h-4 text-[#00B0FF]" />,
  annotation: <MessageSquare className="w-4 h-4 text-[#7C4DFF]" />,
  new_method: <PlusCircle className="w-4 h-4 text-[#FFAB00]" />,
  constructor: <Zap className="w-4 h-4 text-[#64DD17]" />,
  group: <FolderPlus className="w-4 h-4 text-[#FF3D00]" />,
  replace_asset: <Image className="w-4 h-4 text-[#FF007F]" />,
  edit_plist: <FileCode className="w-4 h-4 text-[#7B1FA2]" />,
  swiftui_view: <Smartphone className="w-4 h-4 text-[#00E676]" />,
  extension_config: <AppWindow className="w-4 h-4 text-[#00B0FF]" />
};

export const BLOCK_TEMPLATES: BlockTemplate[] = Object.values(BLOCK_REGISTRY).map((def) => ({
  type: def.type,
  title: def.title,
  icon: ICON_MAP[def.type] || <Code className="w-4 h-4 text-gray-300" />,
  category: def.category,
  description: def.description,
  color: "bg-[#111] border border-[#222] text-white hover:border-emerald-500",
  borderAccent: def.borderColor
}));
