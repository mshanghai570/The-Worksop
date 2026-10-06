//
//  Views/Binary/BinaryPatcherComponents.swift
//  TheWorkshop-iOS
//  Binary Patcher Component Views
//

import SwiftUI

// MARK: - Function Row

struct FunctionRow: View {
    let function: BinaryFunction
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    if let className = function.className {
                        Text(className)
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundColor(WorkshopTheme.cyberCyan)
                    }
                    Text(function.name)
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(WorkshopTheme.brightText)
                    Spacer()
                    Text("0x\(String(format: "%llX", function.address))")
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundColor(WorkshopTheme.subtleText)
                }
                
                if let methodSignature = function.methodSignature {
                    Text(methodSignature)
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundColor(WorkshopTheme.subtleText)
                }
            }
            .padding(10)
            .background(isSelected ? WorkshopTheme.neonGreen.opacity(0.15) : WorkshopTheme.darkCard)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? WorkshopTheme.neonGreen : WorkshopTheme.cardBorder, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Class Row

struct ClassRow: View {
    let className: String
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 8) {
                Image(systemName: "cube.fill")
                    .foregroundColor(WorkshopTheme.cyberCyan)
                Text(className)
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundColor(WorkshopTheme.brightText)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(WorkshopTheme.subtleText)
            }
            .padding(10)
            .background(WorkshopTheme.darkCard)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(WorkshopTheme.cardBorder, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Symbol Row

struct SymbolRow: View {
    let symbol: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "terminal.fill")
                .foregroundColor(WorkshopTheme.hotPink)
            Text(symbol)
                .font(.system(size: 11, design: .monospaced))
                .foregroundColor(WorkshopTheme.brightText)
        }
        .padding(10)
        .background(WorkshopTheme.darkCard)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(WorkshopTheme.cardBorder, lineWidth: 1)
        )
    }
}

// MARK: - Instruction Row

struct InstructionRow: View {
    let instruction: Instruction
    let isSelected: Bool
    let onSelect: () -> Void
    let onPatch: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 8) {
                Text("0x\(String(format: "%llX", instruction.address))")
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(WorkshopTheme.subtleText)
                    .frame(width: 80, alignment: .trailing)

                Text(instruction.hexBytes)
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(WorkshopTheme.hotPink)
                    .frame(width: 120, alignment: .leading)

                Text(instruction.fullDisassembly)
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(WorkshopTheme.brightText)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Button(action: onPatch) {
                    Image(systemName: "hexagon.fill")
                        .foregroundColor(WorkshopTheme.warningYellow)
                }
            }
            .padding(8)
            .background(isSelected ? WorkshopTheme.cyberCyan.opacity(0.15) : WorkshopTheme.darkCard)
            .cornerRadius(6)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(isSelected ? WorkshopTheme.cyberCyan : WorkshopTheme.cardBorder, lineWidth: 1)
            )
            .onTapGesture(perform: onSelect)

            if let comment = instruction.comment, !comment.isEmpty {
                Text(comment)
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundColor(WorkshopTheme.subtleText)
                    .padding(.leading, 8)
            }
        }
    }
}

// MARK: - Data Extensions

extension Data {
    init?(hexString: String) {
        let cleaned = hexString.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "0x", with: "")
        guard cleaned.count % 2 == 0 else { return nil }
        
        var bytes = [UInt8]()
        var index = cleaned.startIndex
        
        while index < cleaned.endIndex {
            let nextIndex = cleaned.index(index, offsetBy: 2)
            let byteString = String(cleaned[index..<nextIndex])
            if let byte = UInt8(byteString, radix: 16) {
                bytes.append(byte)
            } else {
                return nil
            }
            index = nextIndex
        }
        
        self.init(bytes)
    }
}

extension String {
    func toHexData() -> Data? {
        Data(hexString: self)
    }
}
