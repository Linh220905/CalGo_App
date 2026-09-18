import ActivityKit
import WidgetKit
import SwiftUI

// MARK: - Live Activity Attributes (Required by flutter_live_activities plugin)
struct LiveActivitiesAppAttributes: ActivityAttributes, Identifiable {
    public typealias LiveDeliveryData = ContentState

    public struct ContentState: Codable, Hashable {
        var appGroupId: String
    }

    var id = UUID()
}

extension LiveActivitiesAppAttributes {
    func prefixedKey(_ key: String) -> String {
        return "\(id)_\(key)"
    }
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

    var progress: Double {
        guard entry.targetCalories > 0 else { return 0.0 }
        let val = Double(entry.consumedCalories) / Double(entry.targetCalories)
        return min(max(val, 0.0), 1.0)
    }

    var body: some View {
        HStack(spacing: 12) {
            // Left: Circular Progress with Calories Left
            ZStack {
                Circle()
                    .stroke(Color.primary.opacity(0.12), lineWidth: 5.5)
                Circle()
                    .trim(from: 0, to: CGFloat(progress))
                    .stroke(
                        Color.primary,
                        style: StrokeStyle(lineWidth: 5.5, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))

                VStack(spacing: 1) {
                    Text("\(entry.caloriesLeft)")
                        .font(.system(size: 16, weight: .black, design: .rounded))
                        .foregroundColor(.primary)
                        .minimumScaleFactor(0.7)
                    Text("kcal left")
                        .font(.system(size: 8, weight: .semibold))
                        .foregroundColor(.secondary)
                }
                .padding(4)
            }
            .frame(width: 72, height: 72)
            .frame(maxWidth: .infinity)

            // Right: Clean Macro Rows
            VStack(alignment: .leading, spacing: 6) {
                macroRow(icon: "🥩", amount: "\(entry.proteinLeft)g", label: "Protein")
                macroRow(icon: "🌾", amount: "\(entry.carbsLeft)g", label: "Carbs")
                macroRow(icon: "💧", amount: "\(entry.fatLeft)g", label: "Fat")
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .widgetURL(URL(string: "calgo://home"))
    }

    @ViewBuilder
    private func macroRow(icon: String, amount: String, label: String) -> some View {
        HStack(spacing: 5) {
            Text(icon)
                .font(.system(size: 11))
            VStack(alignment: .leading, spacing: 0) {
                Text(amount)
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                Text(label)
                    .font(.system(size: 8, weight: .medium))
                    .foregroundColor(.secondary)
            }
        }
    }
}

// MARK: - Main Home Widget Configuration
struct CalGoWidget: Widget {
    let kind: String = "CalGoWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                CalGoWidgetEntryView(entry: entry)
                    .containerBackground(for: .widget) {
                        Color(UIColor.secondarySystemBackground)
                    }
            } else {
                CalGoWidgetEntryView(entry: entry)
                    .background(Color(UIColor.secondarySystemBackground))
            }
        }
        .configurationDisplayName("CalGo Tracker")
        .description("Theo dõi calo và macro hàng ngày tiện lợi.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// MARK: - Live Activity Widget (Compatible with flutter_live_activities)
struct CalGoLiveActivity: Widget {
    let sharedDefault = UserDefaults(suiteName: "group.com.calgo.calgo")

    var body: some WidgetConfiguration {
        ActivityConfiguration(for: LiveActivitiesAppAttributes.self) { context in
            // Lock Screen / Banner UI
            let caloriesLeft = sharedDefault?.integer(forKey: context.attributes.prefixedKey("caloriesLeft")) ?? 2000
            let proteinLeft = sharedDefault?.integer(forKey: context.attributes.prefixedKey("proteinLeft")) ?? 60
            let carbsLeft = sharedDefault?.integer(forKey: context.attributes.prefixedKey("carbsLeft")) ?? 90
            let fatLeft = sharedDefault?.integer(forKey: context.attributes.prefixedKey("fatLeft")) ?? 30

            HStack(spacing: 14) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(caloriesLeft) kcal")
                        .font(.system(size: 18, weight: .heavy, design: .rounded))
                        .foregroundColor(.primary)
                    Text("Còn lại hôm nay")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.secondary)
                }

                Spacer()

                HStack(spacing: 8) {
                    VStack(alignment: .trailing, spacing: 3) {
                        Text("🥩 \(proteinLeft)g")
                            .font(.system(size: 10, weight: .bold))
                        Text("🌾 \(carbsLeft)g")
                            .font(.system(size: 10, weight: .bold))
                    }
                    VStack(alignment: .trailing, spacing: 3) {
                        Text("💧 \(fatLeft)g")
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
            let caloriesLeft = sharedDefault?.integer(forKey: context.attributes.prefixedKey("caloriesLeft")) ?? 2000
            let proteinLeft = sharedDefault?.integer(forKey: context.attributes.prefixedKey("proteinLeft")) ?? 60
            let carbsLeft = sharedDefault?.integer(forKey: context.attributes.prefixedKey("carbsLeft")) ?? 90
            let fatLeft = sharedDefault?.integer(forKey: context.attributes.prefixedKey("fatLeft")) ?? 30

            return DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    HStack {
                        Image(systemName: "flame.fill")
                            .foregroundColor(.orange)
                        Text("\(caloriesLeft) kcal")
                            .font(.system(size: 14, weight: .bold))
                    }
                    .padding(.leading, 4)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("P:\(proteinLeft) C:\(carbsLeft) F:\(fatLeft)")
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
                Text("\(caloriesLeft)")
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
    var body: some WidgetConfiguration {
        CalGoWidget()
        CalGoLiveActivity()
    }
}
