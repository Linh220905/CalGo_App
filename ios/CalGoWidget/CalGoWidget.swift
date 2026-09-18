import ActivityKit
import WidgetKit
import SwiftUI

// MARK: - Activity Attributes for Live Activity
public struct CalGoLiveActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        public var caloriesLeft: Int
        public var proteinLeft: Int
        public var carbsLeft: Int
        public var fatLeft: Int
        public var targetCalories: Int
        public var consumedCalories: Int
    }

    public var name: String
}

// MARK: - Home Widget Timeline Provider
struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> CalGoEntry {
        CalGoEntry(date: Date(), caloriesLeft: 1450, proteinLeft: 85, carbsLeft: 120, fatLeft: 40, targetCalories: 2000, consumedCalories: 550)
    }

    func getSnapshot(in context: Context, completion: @escaping (CalGoEntry) -> ()) {
        let entry = readCurrentData()
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let entry = readCurrentData()
        let timeline = Timeline(entries: [entry], policy: .atEnd)
        completion(timeline)
    }

    private func readCurrentData() -> CalGoEntry {
        let userDefaults = UserDefaults(suiteName: "group.com.calgo.calgo")
        let caloriesLeft = userDefaults?.integer(forKey: "calories_left") ?? 2000
        let proteinLeft = userDefaults?.integer(forKey: "protein_left") ?? 60
        let carbsLeft = userDefaults?.integer(forKey: "carbs_left") ?? 90
        let fatLeft = userDefaults?.integer(forKey: "fat_left") ?? 30
        let targetCalories = userDefaults?.integer(forKey: "target_calories") ?? 2000
        let consumedCalories = userDefaults?.integer(forKey: "consumed_calories") ?? 0

        return CalGoEntry(
            date: Date(),
            caloriesLeft: caloriesLeft,
            proteinLeft: proteinLeft,
            carbsLeft: carbsLeft,
            fatLeft: fatLeft,
            targetCalories: targetCalories,
            consumedCalories: consumedCalories
        )
    }
}

struct CalGoEntry: TimelineEntry {
    let date: Date
    let caloriesLeft: Int
    let proteinLeft: Int
    let carbsLeft: Int
    let fatLeft: Int
    let targetCalories: Int
    let consumedCalories: Int
}

// MARK: - Home Screen Widget View
struct CalGoWidgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        HStack(spacing: 12) {
            // Calorie Left Circle
            VStack(spacing: 2) {
                Text("\(entry.caloriesLeft)")
                    .font(.system(size: 20, weight: .heavy, design: .rounded))
                    .foregroundColor(.primary)
                Text("kcal left")
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)

            Divider()

            // Macros List
            VStack(alignment: .leading, spacing: 5) {
                HStack(spacing: 4) {
                    Text("🥩").font(.system(size: 10))
                    Text("\(entry.proteinLeft)g P")
                        .font(.system(size: 11, weight: .bold))
                }
                HStack(spacing: 4) {
                    Text("🌾").font(.system(size: 10))
                    Text("\(entry.carbsLeft)g C")
                        .font(.system(size: 11, weight: .bold))
                }
                HStack(spacing: 4) {
                    Text("💧").font(.system(size: 10))
                    Text("\(entry.fatLeft)g F")
                        .font(.system(size: 11, weight: .bold))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .widgetURL(URL(string: "calgo://home"))
    }
}

// MARK: - Main Home Widget Configuration
struct CalGoWidget: Widget {
    let kind: String = "CalGoWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                CalGoWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                CalGoWidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("CalGo Tracker")
        .description("Theo dõi calo và macro hàng ngày tiện lợi.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// MARK: - Live Activity Widget
struct CalGoLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: CalGoLiveActivityAttributes.self) { context in
            // Lock Screen / Banner UI
            HStack(spacing: 14) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(context.state.caloriesLeft) kcal")
                        .font(.system(size: 18, weight: .heavy, design: .rounded))
                        .foregroundColor(.primary)
                    Text("Còn lại hôm nay")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.secondary)
                }

                Spacer()

                HStack(spacing: 8) {
                    VStack(alignment: .trailing, spacing: 3) {
                        Text("🥩 \(context.state.proteinLeft)g")
                            .font(.system(size: 10, weight: .bold))
                        Text("🌾 \(context.state.carbsLeft)g")
                            .font(.system(size: 10, weight: .bold))
                    }
                    VStack(alignment: .trailing, spacing: 3) {
                        Text("💧 \(context.state.fatLeft)g")
                            .font(.system(size: 10, weight: .bold))
                        Link(destination: URL(string: "calgo://scan")!) {
                            Image(systemName: "camera.fill")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.white)
                                .padding(5)
                                .background(Color.blue)
                                .clipShape(Circle())
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .activityBackgroundTint(Color.black.opacity(0.85))
            .activitySystemActionForegroundColor(Color.white)

        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    HStack {
                        Image(systemName: "flame.fill")
                            .foregroundColor(.orange)
                        Text("\(context.state.caloriesLeft) kcal")
                            .font(.system(size: 14, weight: .bold))
                    }
                    .padding(.leading, 4)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("P:\(context.state.proteinLeft) C:\(context.state.carbsLeft) F:\(context.state.fatLeft)")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.secondary)
                        .padding(.trailing, 4)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    HStack {
                        Text("Chạm để quét món ăn")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                        Spacer()
                        Link(destination: URL(string: "calgo://scan")!) {
                            Label("Quét", systemImage: "camera.fill")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(Color.blue)
                                .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal, 6)
                }
            } compactLeading: {
                Image(systemName: "flame.fill")
                    .foregroundColor(.orange)
            } compactTrailing: {
                Text("\(context.state.caloriesLeft)")
                    .font(.system(size: 12, weight: .bold))
            } minimal: {
                Image(systemName: "flame.fill")
                    .foregroundColor(.orange)
            }
            .widgetURL(URL(string: "calgo://home"))
        }
    }
}

// MARK: - Bundle Export
@main
struct CalGoWidgetBundle: WidgetBundle {
    var body: some Widget {
        CalGoWidget()
        CalGoLiveActivity()
    }
}
