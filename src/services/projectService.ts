import JSZip from "jszip";
import { saveAs } from "file-saver";
import { Project, BlockData, ProjectTargetType } from "../types";
import { INITIAL_DEFAULT_PROJECT } from "../utils/mockHeaders";
import { validateBlockData } from "./blockRegistry";
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

const LOCAL_STORAGE_KEY = "the_workshop_active_project_v2";

/**
 * Validates and sanitizes a project structure
 */
export function validateProjectSchema(data: any): Project {
  if (!data || typeof data !== "object") {
    throw new Error("Invalid project JSON: Root must be an object");
  }

  const cleanBlocks: BlockData[] = Array.isArray(data.blocks)
    ? data.blocks.map((b: any) => validateBlockData(b))
    : INITIAL_DEFAULT_PROJECT.blocks;

  const validTargetTypes: ProjectTargetType[] = ["jailbreak_tweak", "jailed_mod", "native_extension"];
  const targetType: ProjectTargetType = validTargetTypes.includes(data.projectType)
    ? data.projectType
    : "jailbreak_tweak";

  return {
    id: typeof data.id === "string" ? data.id : `proj-${Date.now()}`,
    name: typeof data.name === "string" && data.name.trim() ? data.name : "Untitled Tweak",
    version: typeof data.version === "string" ? data.version : "0.1.0",
    author: typeof data.author === "string" ? data.author : "Developer",
    bundleId: typeof data.bundleId === "string" ? data.bundleId : "com.workshop.tweak",
    projectType: targetType,
    targetProcess: typeof data.targetProcess === "string" ? data.targetProcess : "SpringBoard",
    tweakFilter: typeof data.tweakFilter === "string" ? data.tweakFilter : "com.apple.springboard",
    description: typeof data.description === "string" ? data.description : "iOS Tweak Project",
    createdAt: typeof data.createdAt === "string" ? data.createdAt : new Date().toISOString(),
    updatedAt: new Date().toISOString(),
    blocks: cleanBlocks
  };
}

/**
 * Saves project to browser localStorage automatically
 */
export function saveProjectToLocalStorage(project: Project): void {
  try {
    const jsonStr = JSON.stringify(project);
    localStorage.setItem(LOCAL_STORAGE_KEY, jsonStr);
  } catch (err) {
    console.warn("Failed to write project to localStorage:", err);
  }
}

/**
 * Loads saved project from browser localStorage on startup
 */
export function loadProjectFromLocalStorage(): Project {
  try {
    const raw = localStorage.getItem(LOCAL_STORAGE_KEY);
    if (raw) {
      const parsed = JSON.parse(raw);
      return validateProjectSchema(parsed);
    }
  } catch (err) {
    console.warn("Failed to parse saved project from localStorage, using default:", err);
  }
  return INITIAL_DEFAULT_PROJECT;
}

/**
 * Clears saved project and resets to default
 */
export function resetProjectToDefault(): Project {
  try {
    localStorage.removeItem(LOCAL_STORAGE_KEY);
  } catch (e) {
    // ignore
  }
  return INITIAL_DEFAULT_PROJECT;
}

/**
 * Exports project as formatted JSON file
 */
export function exportProjectToJSONFile(project: Project): void {
  const cleanName = project.name.replace(/\s+/g, "").toLowerCase();
  const jsonStr = JSON.stringify(project, null, 2);
  const blob = new Blob([jsonStr], { type: "application/json;charset=utf-8" });
  saveAs(blob, `${cleanName}.workshop.json`);
}

/**
 * Imports project from a JSON string or file
 */
export async function importProjectFromJSONFile(file: File): Promise<Project> {
  return new Promise((resolve, reject) => {
    const reader = new FileReader();
    reader.onload = (e) => {
      try {
        const content = e.target?.result as string;
        const parsed = JSON.parse(content);
        const validated = validateProjectSchema(parsed);
        resolve(validated);
      } catch (err: any) {
        reject(new Error(`Failed to parse project file: ${err.message || "Invalid JSON"}`));
      }
    };
    reader.onerror = () => reject(new Error("Failed to read file from disk"));
    reader.readAsText(file);
  });
}

/**
 * Packages the entire tweak project into a zip file containing both Logos/Theos & Swift/SwiftUI iOS source code
 */
export async function exportProjectToZip(project: Project): Promise<void> {
  const zip = new JSZip();
  const cleanName = project.name.replace(/\s+/g, "");

  // 1. Logos Tweak Source File
  zip.file(`${cleanName}.x`, generateLogosCode(project));

  // 2. SwiftUI App Source Files
  zip.file(`${cleanName}App.swift`, generateSwiftUICode(project));
  zip.file("TweakModels.swift", generateSwiftModelsCode(project));
  zip.file(`${cleanName}-Bridging-Header.h`, generateSwiftBridgeHeader(project));

  // 3. Theos Build Infrastructure Files
  zip.file("Makefile", generateTheosMakefile(project));
  zip.file("control", generateControlFile(project));
  zip.file(`${cleanName}.plist`, generatePlistFilter(project));

  // 4. Jailed Modification & Native Extension Target Source Files
  zip.file("patch_ipa.sh", generateJailedPatchScript(project));
  zip.file(`${cleanName}Extension.swift`, generateNativeExtensionCode(project));

  // 5. Raw Workshop Project Schema
  zip.file("project.workshop.json", JSON.stringify(project, null, 2));

  // 5. Readme Documentation
  const readme = `# ${project.name}
Created with **The Workshop** (iOS Jailbreak Tweak Studio & Native SwiftUI App).

Target Bundle: \`${project.tweakFilter}\`
Target Process: \`${project.targetProcess}\`

---

## 📱 Option A: Build as a Native iOS App (SwiftUI)
1. Open Xcode on macOS.
2. Create a new **iOS SwiftUI App** named \`${cleanName}\`.
3. Add \`${cleanName}App.swift\`, \`TweakModels.swift\`, and \`${cleanName}-Bridging-Header.h\` to your Xcode target.
4. Build and run on iOS Simulator or physical iOS device!

---

## 🛠️ Option B: Build as a Jailbreak Tweak (Theos)
1. Install **Theos** on your macOS or jailbroken iOS environment.
2. Open terminal in this unzipped directory:
\`\`\`bash
make package
\`\`\`
3. Deploy the resulting \`.deb\` package to your device:
\`\`\`bash
make install
\`\`\`
`;
  zip.file("README.md", readme);

  const zipBlob = await zip.generateAsync({ type: "blob" });
  saveAs(zipBlob, `${cleanName.toLowerCase()}-ios-tweak-package.zip`);
}
