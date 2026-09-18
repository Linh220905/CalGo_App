package com.calgo.calgo

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.widget.RemoteViews
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
                val homeIntent = Intent(context, MainActivity::class.java).apply {
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                }
                val homePendingIntent = PendingIntent.getActivity(
                    context,
                    0,
                    homeIntent,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )
                setOnClickPendingIntent(R.id.card_macros, homePendingIntent)
                setOnClickPendingIntent(R.id.widget_root, homePendingIntent)

                // 2. Open Camera Scan on Scan Food Button Click
                val scanIntent = Intent(context, MainActivity::class.java).apply {
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                    putExtra("route", "/scan")
                }
                val scanPendingIntent = PendingIntent.getActivity(
                    context,
                    1,
                    scanIntent,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )
                setOnClickPendingIntent(R.id.btn_scan_food, scanPendingIntent)

                // 3. Open Barcode Scanner on Barcode Button Click
                val barcodeIntent = Intent(context, MainActivity::class.java).apply {
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                    putExtra("route", "/barcode-scan")
                }
                val barcodePendingIntent = PendingIntent.getActivity(
                    context,
                    2,
                    barcodeIntent,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )
                setOnClickPendingIntent(R.id.btn_barcode, barcodePendingIntent)
            }

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
