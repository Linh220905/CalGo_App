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
        CalGoEntry(
            date: Date(),
            caloriesLeft: 1850,
            proteinLeft: 60,
            targetProtein: 130,
            consumedProtein: 70,
            carbsLeft: 90,
            targetCarbs: 200,
            consumedCarbs: 110,
            fatLeft: 30,
            targetFat: 60,
            consumedFat: 30,
            targetCalories: 2200,
            consumedCalories: 350
        )
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
        let targetCalories = userDefaults?.integer(forKey: "target_calories") ?? 2000
        let consumedCalories = userDefaults?.integer(forKey: "consumed_calories") ?? 0

        let proteinLeft = userDefaults?.integer(forKey: "protein_left") ?? 60
        let targetProtein = userDefaults?.integer(forKey: "target_protein") ?? 130
        let consumedProtein = userDefaults?.integer(forKey: "consumed_protein") ?? 0

        let carbsLeft = userDefaults?.integer(forKey: "carbs_left") ?? 90
        let targetCarbs = userDefaults?.integer(forKey: "target_carbs") ?? 200
        let consumedCarbs = userDefaults?.integer(forKey: "consumed_carbs") ?? 0

        let fatLeft = userDefaults?.integer(forKey: "fat_left") ?? 30
        let targetFat = userDefaults?.integer(forKey: "target_fat") ?? 60
        let consumedFat = userDefaults?.integer(forKey: "consumed_fat") ?? 0

        return CalGoEntry(
            date: Date(),
            caloriesLeft: caloriesLeft,
            proteinLeft: proteinLeft,
            targetProtein: targetProtein,
            consumedProtein: consumedProtein,
            carbsLeft: carbsLeft,
            targetCarbs: targetCarbs,
            consumedCarbs: consumedCarbs,
            fatLeft: fatLeft,
            targetFat: targetFat,
            consumedFat: consumedFat,
            targetCalories: targetCalories,
            consumedCalories: consumedCalories
        )
    }
}

struct CalGoEntry: TimelineEntry {
    let date: Date
    let caloriesLeft: Int
    let proteinLeft: Int
    let targetProtein: Int
    let consumedProtein: Int
    let carbsLeft: Int
    let targetCarbs: Int
    let consumedCarbs: Int
    let fatLeft: Int
    let targetFat: Int
    let consumedFat: Int
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

    var proteinProgress: Double {
        guard entry.targetProtein > 0 else { return 0.0 }
        return min(max(Double(entry.consumedProtein) / Double(entry.targetProtein), 0.0), 1.0)
    }

    var carbsProgress: Double {
        guard entry.targetCarbs > 0 else { return 0.0 }
        return min(max(Double(entry.consumedCarbs) / Double(entry.targetCarbs), 0.0), 1.0)
    }

    var fatProgress: Double {
        guard entry.targetFat > 0 else { return 0.0 }
        return min(max(Double(entry.consumedFat) / Double(entry.targetFat), 0.0), 1.0)
    }

    var body: some View {
        switch family {
        case .systemSmall:
            smallWidgetView
        default:
            mediumWidgetView
        }
    }

    // MARK: - Medium Widget (Matching Cal AI Style: Full Left Card for Calories & Macros with circular progress rings, 2 Clean Action Cards on Right)
    private var mediumWidgetView: some View {
        HStack(spacing: 8) {
            // CARD 1 (BIG LEFT - FULL CARD): Calories Ring + Macros Stack with Circular Progress Rings
            HStack(spacing: 12) {
                // Large Calories Progress Ring
                calorieRing(size: 88, strokeWidth: 7, fontSize: 18)
                    .frame(width: 90)

                // 3 Macro Items with Circular Progress Rings
                VStack(alignment: .leading, spacing: 7) {
                    macroProgressItem(
                        icon: "🥩",
                        progress: proteinProgress,
                        ringColor: Color(red: 1.0, green: 0.36, blue: 0.36),
                        amount: "\(entry.proteinLeft)g",
                        label: "Protein left"
                    )
                    macroProgressItem(
                        icon: "🌾",
                        progress: carbsProgress,
                        ringColor: Color(red: 0.96, green: 0.62, blue: 0.04),
                        amount: "\(entry.carbsLeft)g",
                        label: "Carbs left"
                    )
                    macroProgressItem(
                        icon: "💧",
                        progress: fatProgress,
                        ringColor: Color(red: 0.23, green: 0.51, blue: 0.96),
                        amount: "\(entry.fatLeft)g",
                        label: "Fats left"
                    )
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(UIColor.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))

            // CARD 2 & 3 (RIGHT COLUMN): 2 Separate Action Cards
            VStack(spacing: 8) {
                Link(destination: URL(string: "calgo://scan")!) {
                    actionCard(icon: "camera.viewfinder", title: "Scan Food")
                }
                Link(destination: URL(string: "calgo://barcode")!) {
                    actionCard(icon: "barcode.viewfinder", title: "Barcode")
                }
            }
            .frame(width: 82)
        }
        .padding(2)
    }

    // MARK: - Small Widget (Calorie Ring + Scan Food Action Button)
    private var smallWidgetView: some View {
        VStack(spacing: 8) {
            calorieRing(size: 76, strokeWidth: 6.5, fontSize: 16)
                .frame(maxHeight: .infinity)

            Link(destination: URL(string: "calgo://scan")!) {
                HStack(spacing: 4) {
                    Image(systemName: "plus")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.primary)
                    Text("Ghi món ăn")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 6)
                .background(Color(UIColor.secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(8)
    }

    // MARK: - Circular Progress Ring Component
    private func calorieRing(size: CGFloat, strokeWidth: CGFloat, fontSize: CGFloat) -> some View {
        ZStack {
            Circle()
                .stroke(Color.primary.opacity(0.08), lineWidth: strokeWidth)
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
                    .font(.system(size: max(fontSize * 0.40, 7.5), weight: .semibold))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(2)
        }
        .frame(width: size, height: size)
    }

    // MARK: - Macro Item Row with Circular Progress Ring & Icon inside
    private func macroProgressItem(
        icon: String,
        progress: Double,
        ringColor: Color,
        amount: String,
        label: String
    ) -> some View {
        HStack(spacing: 8) {
            ZStack {
                Circle()
                    .stroke(ringColor.opacity(0.15), lineWidth: 2.5)
                Circle()
                    .trim(from: 0, to: CGFloat(progress))
                    .stroke(
                        ringColor,
                        style: StrokeStyle(lineWidth: 2.5, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))

                Text(icon)
                    .font(.system(size: 11))
            }
            .frame(width: 25, height: 25)

            VStack(alignment: .leading, spacing: 0) {
                Text(amount)
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                Text(label)
                    .font(.system(size: 9.5, weight: .medium))
                    .foregroundColor(.secondary)
            }
        }
    }

    // MARK: - Quick Action Card
    private func actionCard(icon: String, title: String) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.primary)
            Text(title)
                .font(.system(size: 9.5, weight: .bold))
                .foregroundColor(.primary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.vertical, 6)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
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
            let targetCalories = sharedDefault?.integer(forKey: context.attributes.prefixedKey("targetCalories")) ?? 2000
            let consumedCalories = sharedDefault?.integer(forKey: context.attributes.prefixedKey("consumedCalories")) ?? 0

            let proteinLeft = sharedDefault?.integer(forKey: context.attributes.prefixedKey("proteinLeft")) ?? 60
            let targetProtein = sharedDefault?.integer(forKey: context.attributes.prefixedKey("targetProtein")) ?? 130
            let consumedProtein = sharedDefault?.integer(forKey: context.attributes.prefixedKey("consumedProtein")) ?? 0

            let carbsLeft = sharedDefault?.integer(forKey: context.attributes.prefixedKey("carbsLeft")) ?? 90
            let targetCarbs = sharedDefault?.integer(forKey: context.attributes.prefixedKey("targetCarbs")) ?? 200
            let consumedCarbs = sharedDefault?.integer(forKey: context.attributes.prefixedKey("consumedCarbs")) ?? 0

            let fatLeft = sharedDefault?.integer(forKey: context.attributes.prefixedKey("fatLeft")) ?? 30
            let targetFat = sharedDefault?.integer(forKey: context.attributes.prefixedKey("targetFat")) ?? 60
            let consumedFat = sharedDefault?.integer(forKey: context.attributes.prefixedKey("consumedFat")) ?? 0

            let calProgress: Double = targetCalories > 0
                ? min(max(Double(consumedCalories) / Double(targetCalories), 0.0), 1.0)
                : 0.0
            let proteinProgress: Double = targetProtein > 0
                ? min(max(Double(consumedProtein) / Double(targetProtein), 0.0), 1.0)
                : 0.0
            let carbsProgress: Double = targetCarbs > 0
                ? min(max(Double(consumedCarbs) / Double(targetCarbs), 0.0), 1.0)
                : 0.0
            let fatProgress: Double = targetFat > 0
                ? min(max(Double(consumedFat) / Double(targetFat), 0.0), 1.0)
                : 0.0

            // Horizontal Lock Screen Banner matching widget_preview.html
            HStack(spacing: 8) {
                // 1. Calories Ring Box
                ZStack {
                    Circle()
                        .stroke(Color.primary.opacity(0.12), lineWidth: 6.5)
                    Circle()
                        .trim(from: 0, to: CGFloat(calProgress))
                        .stroke(
                            Color.primary,
                            style: StrokeStyle(lineWidth: 6.5, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))

                    VStack(spacing: 1) {
                        Text("\(caloriesLeft)")
                            .font(.system(size: 16, weight: .black, design: .rounded))
                            .foregroundColor(.primary)
                            .minimumScaleFactor(0.7)
                        Text("Calories left")
                            .font(.system(size: 7.5, weight: .semibold))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                }
                .frame(width: 76, height: 76)

                // 2. Macros List (Mini Progress Rings with Icons inside)
                VStack(alignment: .leading, spacing: 6) {
                    // Protein Row
                    HStack(spacing: 7) {
                        ZStack {
                            Circle()
                                .stroke(Color(red: 1.0, green: 0.36, blue: 0.36).opacity(0.15), lineWidth: 2.5)
                            Circle()
                                .trim(from: 0, to: CGFloat(proteinProgress))
                                .stroke(
                                    Color(red: 1.0, green: 0.36, blue: 0.36),
                                    style: StrokeStyle(lineWidth: 2.5, lineCap: .round)
                                )
                                .rotationEffect(.degrees(-90))
                            Text("🥩")
                                .font(.system(size: 11))
                        }
                        .frame(width: 24, height: 24)

                        VStack(alignment: .leading, spacing: 0) {
                            Text("\(proteinLeft)g")
                                .font(.system(size: 12.5, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                            Text("Protein left")
                                .font(.system(size: 9, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                    }

                    // Carbs Row
                    HStack(spacing: 7) {
                        ZStack {
                            Circle()
                                .stroke(Color(red: 0.96, green: 0.62, blue: 0.04).opacity(0.15), lineWidth: 2.5)
                            Circle()
                                .trim(from: 0, to: CGFloat(carbsProgress))
                                .stroke(
                                    Color(red: 0.96, green: 0.62, blue: 0.04),
                                    style: StrokeStyle(lineWidth: 2.5, lineCap: .round)
                                )
                                .rotationEffect(.degrees(-90))
                            Text("🌾")
                                .font(.system(size: 11))
                        }
                        .frame(width: 24, height: 24)

                        VStack(alignment: .leading, spacing: 0) {
                            Text("\(carbsLeft)g")
                                .font(.system(size: 12.5, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                            Text("Carbs left")
                                .font(.system(size: 9, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                    }

                    // Fats Row
                    HStack(spacing: 7) {
                        ZStack {
                            Circle()
                                .stroke(Color(red: 0.23, green: 0.51, blue: 0.96).opacity(0.15), lineWidth: 2.5)
                            Circle()
                                .trim(from: 0, to: CGFloat(fatProgress))
                                .stroke(
                                    Color(red: 0.23, green: 0.51, blue: 0.96),
                                    style: StrokeStyle(lineWidth: 2.5, lineCap: .round)
                                )
                                .rotationEffect(.degrees(-90))
                            Text("💧")
                                .font(.system(size: 11))
                        }
                        .frame(width: 24, height: 24)

                        VStack(alignment: .leading, spacing: 0) {
                            Text("\(fatLeft)g")
                                .font(.system(size: 12.5, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                            Text("Fats left")
                                .font(.system(size: 9, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 4)

                // 3. Actions Stack (2 Clean Action Cards: Scan Food & Barcode)
                VStack(spacing: 6) {
                    Link(destination: URL(string: "calgo://scan")!) {
                        VStack(spacing: 3) {
                            Image(systemName: "camera.viewfinder")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.primary)
                            Text("Scan Food")
                                .font(.system(size: 8.5, weight: .bold))
                                .foregroundColor(.primary)
                                .lineLimit(1)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(.vertical, 5)
                        .background(Color(UIColor.secondarySystemGroupedBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }

                    Link(destination: URL(string: "calgo://barcode")!) {
                        VStack(spacing: 3) {
                            Image(systemName: "barcode.viewfinder")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.primary)
                            Text("Barcode")
                                .font(.system(size: 8.5, weight: .bold))
                                .foregroundColor(.primary)
                                .lineLimit(1)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(.vertical, 5)
                        .background(Color(UIColor.secondarySystemGroupedBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                }
                .frame(width: 78)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .activityBackgroundTint(Color(UIColor.systemBackground).opacity(0.85))
            .activitySystemActionForegroundColor(Color.primary)

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
