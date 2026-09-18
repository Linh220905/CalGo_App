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

                // Open App on Click
                val intent = Intent(context, MainActivity::class.java).apply {
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                }
                val pendingIntent = PendingIntent.getActivity(
                    context,
                    0,
                    intent,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )
                setOnClickPendingIntent(R.id.widget_root, pendingIntent)
            }

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
