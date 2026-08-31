//
//  WorkshopExtension.swift
//  The Workshop - iOS Native Modification & App Extension
//  Target Framework: WidgetKit & SwiftUI
//

import WidgetKit
import SwiftUI

@main
struct WorkshopExtension: Widget {
    let kind: String = "com.apple.widgetkit-extension"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: WorkshopTimelineProvider()) { entry in
            WorkshopWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("The Workshop Native Extension")
        .description("Native iOS extension target generated visually in The Workshop.")
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryCircular, .accessoryRectangular])
    }
}

struct WorkshopTimelineEntry: TimelineEntry {
    let date: Date
    let title: String
    let status: String
}

struct WorkshopTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> WorkshopTimelineEntry {
        WorkshopTimelineEntry(date: Date(), title: "The Workshop", status: "Active")
    }

    func getSnapshot(in context: Context, completion: @escaping (WorkshopTimelineEntry) -> Void) {
        completion(WorkshopTimelineEntry(date: Date(), title: "The Workshop", status: "Active"))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<WorkshopTimelineEntry>) -> Void) {
        let entry = WorkshopTimelineEntry(date: Date(), title: "The Workshop", status: "Live")
        let timeline = Timeline(entries: [entry], policy: .atEnd)
        completion(timeline)
    }
}

struct WorkshopWidgetEntryView: View {
    var entry: WorkshopTimelineProvider.Entry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "sparkles")
                    .font(.caption)
                    .foregroundStyle(.pink)
                Text(entry.title)
                    .font(.caption)
                    .bold()
                    .foregroundStyle(.white)
            }
            
            Text("Native Extension Active")
                .font(.headline)
                .foregroundStyle(.green)
            
            Text("Status: \(entry.status)")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .padding()
        .containerBackground(.black, for: .widget)
    }
}

#Preview(as: .systemSmall) {
    WorkshopExtension()
} slot: {
    WorkshopTimelineEntry(date: Date(), title: "Workshop Preview", status: "Ready")
}
