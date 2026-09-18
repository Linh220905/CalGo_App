import ActivityKit
import WidgetKit
import SwiftUI

// MARK: - Live Activity Attributes (Required by flutter_live_activities)
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
        CalGoEntry(date: Date(), caloriesLeft: 1850, proteinLeft: 60, carbsLeft: 90, fatLeft: 30, targetCalories: 2200, consumedCalories: 350)
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

// MARK: - Home Screen Widget View (Design matches widget_preview.html)
struct CalGoWidgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family

    var progress: Double {
        guard entry.targetCalories > 0 else { return 0.0 }
        let val = Double(entry.consumedCalories) / Double(entry.targetCalories)
        return min(max(val, 0.0), 1.0)
    }

    var body: some View {
        switch family {
        case .systemSmall:
            smallWidgetView
        default:
            mediumWidgetView
        }
    }

    // MARK: - Medium Widget (3 Cards: 1 Big Left Card for Calorie Ring + Macros, 2 Small Right Action Cards)
    private var mediumWidgetView: some View {
        HStack(spacing: 8) {
            // CARD 1 (BIG LEFT): Calories Ring + Macros Stack
            HStack(spacing: 10) {
                // Calories Ring Box
                calorieRing(size: 74, strokeWidth: 6, fontSize: 15)
                    .frame(width: 76)

                // Macros Stack
                VStack(alignment: .leading, spacing: 5) {
                    macroItem(
                        icon: "🥩",
                        bgColor: Color(red: 1.0, green: 0.36, blue: 0.36, opacity: 0.15),
                        amount: "\(entry.proteinLeft)g",
                        label: "Protein left"
                    )
                    macroItem(
                        icon: "🌾",
                        bgColor: Color(red: 0.96, green: 0.62, blue: 0.04, opacity: 0.15),
                        amount: "\(entry.carbsLeft)g",
                        label: "Carbs left"
                    )
                    macroItem(
                        icon: "💧",
                        bgColor: Color(red: 0.23, green: 0.51, blue: 0.96, opacity: 0.15),
                        amount: "\(entry.fatLeft)g",
                        label: "Fats left"
                    )
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(Color(UIColor.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))

            // CARD 2 & 3 (RIGHT COLUMN): 2 Action Cards (Scan Food & Barcode)
            VStack(spacing: 8) {
                Link(destination: URL(string: "calgo://scan")!) {
                    actionCard(icon: "camera.fill", title: "Scan Food")
                }
                Link(destination: URL(string: "calgo://barcode")!) {
                    actionCard(icon: "barcode.viewfinder", title: "Barcode")
                }
            }
            .frame(width: 78)
        }
        .padding(4)
    }

    // MARK: - Small Widget (Clean Only: Calorie Ring with Progress)
    private var smallWidgetView: some View {
        VStack(spacing: 0) {
            calorieRing(size: 96, strokeWidth: 8, fontSize: 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(8)
    }

    // MARK: - Circular Progress Ring Component
    private func calorieRing(size: CGFloat, strokeWidth: CGFloat, fontSize: CGFloat) -> some View {
        ZStack {
            Circle()
                .stroke(Color.primary.opacity(0.12), lineWidth: strokeWidth)
            Circle()
                .trim(from: 0, to: CGFloat(progress))
                .stroke(
                    Color.primary,
                    style: StrokeStyle(lineWidth: strokeWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))

            VStack(spacing: 1) {
                Text("\(entry.caloriesLeft)")
                    .font(.system(size: fontSize, weight: .black, design: .rounded))
                    .foregroundColor(.primary)
                    .minimumScaleFactor(0.7)
                Text("Calories left")
                    .font(.system(size: max(fontSize * 0.44, 8), weight: .semibold))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(2)
        }
        .frame(width: size, height: size)
    }

    // MARK: - Macro Item Row
    private func macroItem(icon: String, bgColor: Color, amount: String, label: String) -> some View {
        HStack(spacing: 6) {
            Text(icon)
                .font(.system(size: 10))
                .frame(width: 18, height: 18)
                .background(bgColor)
                .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))

            VStack(alignment: .leading, spacing: 0) {
                Text(amount)
                    .font(.system(size: 11, weight: .heavy, design: .rounded))
                    .foregroundColor(.primary)
                Text(label)
                    .font(.system(size: 8, weight: .medium))
                    .foregroundColor(.secondary)
            }
        }
    }

    // MARK: - Quick Action Card
    private func actionCard(icon: String, title: String) -> some View {
        VStack(spacing: 3) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.primary)
            Text(title)
                .font(.system(size: 8.5, weight: .bold))
                .foregroundColor(.primary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.vertical, 4)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
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
                        Color(UIColor.systemGroupedBackground)
                    }
            } else {
                CalGoWidgetEntryView(entry: entry)
                    .background(Color(UIColor.systemGroupedBackground))
            }
        }
        .configurationDisplayName("CalGo Tracker")
        .description("Theo dõi calo và macro hàng ngày tiện lợi.")
        .supportedFamilies([.systemMedium, .systemSmall])
    }
}

// MARK: - Live Activity Widget (Lock Screen & Dynamic Island)
struct CalGoLiveActivity: Widget {
    let sharedDefault = UserDefaults(suiteName: "group.com.calgo.calgo")

    var body: some WidgetConfiguration {
        ActivityConfiguration(for: LiveActivitiesAppAttributes.self) { context in
            let caloriesLeft = sharedDefault?.integer(forKey: context.attributes.prefixedKey("caloriesLeft")) ?? 2000
            let proteinLeft = sharedDefault?.integer(forKey: context.attributes.prefixedKey("proteinLeft")) ?? 60
            let carbsLeft = sharedDefault?.integer(forKey: context.attributes.prefixedKey("carbsLeft")) ?? 90
            let fatLeft = sharedDefault?.integer(forKey: context.attributes.prefixedKey("fatLeft")) ?? 30
            let targetCalories = sharedDefault?.integer(forKey: context.attributes.prefixedKey("targetCalories")) ?? 2000
            let consumedCalories = sharedDefault?.integer(forKey: context.attributes.prefixedKey("consumedCalories")) ?? 0

            let progress: Double = targetCalories > 0
                ? min(max(Double(consumedCalories) / Double(targetCalories), 0.0), 1.0)
                : 0.0

            // Horizontal Lock Screen Banner matching widget_preview.html
            HStack(spacing: 12) {
                // Calorie Progress Ring
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.2), lineWidth: 5.5)
                    Circle()
                        .trim(from: 0, to: CGFloat(progress))
                        .stroke(
                            Color.white,
                            style: StrokeStyle(lineWidth: 5.5, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))

                    VStack(spacing: 0) {
                        Text("\(caloriesLeft)")
                            .font(.system(size: 15, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                        Text("kcal left")
                            .font(.system(size: 7.5, weight: .semibold))
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                .frame(width: 60, height: 60)

                // Macros Stack
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 5) {
                        Text("🥩").font(.system(size: 10))
                        Text("\(proteinLeft)g").font(.system(size: 11, weight: .bold)).foregroundColor(.white)
                        Text("Protein").font(.system(size: 9)).foregroundColor(.white.opacity(0.7))
                    }
                    HStack(spacing: 5) {
                        Text("🌾").font(.system(size: 10))
                        Text("\(carbsLeft)g").font(.system(size: 11, weight: .bold)).foregroundColor(.white)
                        Text("Carbs").font(.system(size: 9)).foregroundColor(.white.opacity(0.7))
                    }
                    HStack(spacing: 5) {
                        Text("💧").font(.system(size: 10))
                        Text("\(fatLeft)g").font(.system(size: 11, weight: .bold)).foregroundColor(.white)
                        Text("Fat").font(.system(size: 9)).foregroundColor(.white.opacity(0.7))
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                // Quick Buttons
                VStack(spacing: 4) {
                    Link(destination: URL(string: "calgo://scan")!) {
                        HStack(spacing: 4) {
                            Image(systemName: "camera.fill")
                                .font(.system(size: 9, weight: .bold))
                            Text("Scan")
                                .font(.system(size: 9, weight: .bold))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 5)
                        .background(Color.blue)
                        .cornerRadius(8)
                    }
                    Link(destination: URL(string: "calgo://barcode")!) {
                        HStack(spacing: 4) {
                            Image(systemName: "barcode.viewfinder")
                                .font(.system(size: 9, weight: .bold))
                            Text("Code")
                                .font(.system(size: 9, weight: .bold))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 5)
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(8)
                    }
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .activityBackgroundTint(Color.black.opacity(0.8))
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
                Text("\(sharedDefault?.integer(forKey: context.attributes.prefixedKey("caloriesLeft")) ?? 2000)")
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
    @WidgetBundleBuilder
    var body: some Widget {
        CalGoWidget()
        CalGoLiveActivity()
    }
}
