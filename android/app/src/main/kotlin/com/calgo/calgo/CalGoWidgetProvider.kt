package com.calgo.calgo

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.net.Uri
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

class CalGoWidgetProvider : HomeWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.calgo_widget_layout).apply {
                val caloriesLeft = widgetData.getInt("calories_left", 2000)
                val proteinLeft = widgetData.getInt("protein_left", 60)
                val carbsLeft = widgetData.getInt("carbs_left", 90)
                val fatLeft = widgetData.getInt("fat_left", 30)

                setTextViewText(R.id.tv_calories_left, "$caloriesLeft")
                setTextViewText(R.id.tv_protein_left, "🥩 ${proteinLeft}g P")
                setTextViewText(R.id.tv_carbs_left, "🌾 ${carbsLeft}g C")
                setTextViewText(R.id.tv_fat_left, "💧 ${fatLeft}g F")

                // 1. Open App / Home on Left Card Click
                val homePendingIntent = HomeWidgetLaunchIntent.getActivity(
                    context,
                    MainActivity::class.java,
                    Uri.parse("calgo://home")
                )
                setOnClickPendingIntent(R.id.card_macros, homePendingIntent)
                setOnClickPendingIntent(R.id.widget_root, homePendingIntent)

                // 2. Open Camera Scan on Scan Food Button Click
                val scanPendingIntent = HomeWidgetLaunchIntent.getActivity(
                    context,
                    MainActivity::class.java,
                    Uri.parse("calgo://scan")
                )
                setOnClickPendingIntent(R.id.btn_scan_food, scanPendingIntent)

                // 3. Open Barcode Scanner on Barcode Button Click
                val barcodePendingIntent = HomeWidgetLaunchIntent.getActivity(
                    context,
                    MainActivity::class.java,
                    Uri.parse("calgo://barcode")
                )
                setOnClickPendingIntent(R.id.btn_barcode, barcodePendingIntent)
            }

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
