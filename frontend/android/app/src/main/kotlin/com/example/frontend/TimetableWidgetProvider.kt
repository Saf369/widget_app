package com.example.frontend

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.graphics.BitmapFactory
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider
import es.antonborri.home_widget.HomeWidgetBackgroundIntent
import android.net.Uri
import java.io.File

class TimetableWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.widget_layout)
            
            // Set Intents for Tabs
            val intentHour = HomeWidgetBackgroundIntent.getBroadcast(context, Uri.parse("timetableWidget://tabClicked?tab=hour"))
            views.setOnClickPendingIntent(R.id.btn_hour, intentHour)
            
            val intentDay = HomeWidgetBackgroundIntent.getBroadcast(context, Uri.parse("timetableWidget://tabClicked?tab=day"))
            views.setOnClickPendingIntent(R.id.btn_day, intentDay)
            
            val intentWeek = HomeWidgetBackgroundIntent.getBroadcast(context, Uri.parse("timetableWidget://tabClicked?tab=week"))
            views.setOnClickPendingIntent(R.id.btn_week, intentWeek)
            
            val intentMonth = HomeWidgetBackgroundIntent.getBroadcast(context, Uri.parse("timetableWidget://tabClicked?tab=month"))
            views.setOnClickPendingIntent(R.id.btn_month, intentMonth)

            // The image path saved by Flutter
            val imageName = widgetData.getString("timetable_widget_image", null)
            
            if (imageName != null) {
                val imageFile = File(imageName)
                if (imageFile.exists()) {
                    val bitmap = BitmapFactory.decodeFile(imageFile.absolutePath)
                    views.setImageViewBitmap(R.id.widget_image, bitmap)
                }
            }

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
