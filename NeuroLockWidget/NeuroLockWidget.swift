//
//  NeuroLockWidget.swift
//  NeuroLockWidget
//
//  Created by Rahul Chauhan on 4/15/26.
//

import WidgetKit
import SwiftUI
import AppIntents

struct Provider: TimelineProvider {
    private let appGroupName = "group.com.rc.NeuroLock.shared"
    
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), isActive: false)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), isActive: getIsActive())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let entries = [SimpleEntry(date: Date(), isActive: getIsActive())]
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
    
    private func getIsActive() -> Bool {
        let sharedDefaults = UserDefaults(suiteName: appGroupName)
        return sharedDefaults?.bool(forKey: "IsSessionActive") ?? false
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let isActive: Bool
}

struct NeuroLockWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: entry.isActive ? "lock.shield.fill" : "lock.shield")
                    .font(.title2)
                    .foregroundColor(entry.isActive ? .green : .blue)
                
                Text("NeuroLock")
                    .font(.headline)
            }
            
            Text(entry.isActive ? "Focus Active" : "Ready to focus?")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Button(intent: ToggleFocusIntent()) {
                Text(entry.isActive ? "Stop" : "Start")
                    .font(.system(size: 14, weight: .bold))
                    .frame(maxWidth: .infinity)
            }
            .tint(entry.isActive ? .red : .blue)
            .buttonStyle(.borderedProminent)
            .controlSize(.small)
        }
        .containerBackground(.fill.tertiary, for: .widget)
    }
}

struct NeuroLockWidget: Widget {
    let kind: String = "NeuroLockWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            NeuroLockWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("NeuroLock")
        .description("Quickly toggle your focus session.")
        .supportedFamilies([.systemSmall])
    }
}

#Preview(as: .systemSmall) {
    NeuroLockWidget()
} timeline: {
    SimpleEntry(date: .now, isActive: false)
    SimpleEntry(date: .now, isActive: true)
}
