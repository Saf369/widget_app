package com.example.frontend

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.graphics.Color
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

class TimetableWidgetProvider : HomeWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        val activeTab = widgetData.getString("active_tab", "hour") ?: "hour"
        for (appWidgetId in appWidgetIds) {
            updateWidgetView(context, appWidgetManager, appWidgetId, widgetData, activeTab)
        }
    }

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        if (intent.action == "com.example.frontend.TAB_CLICKED") {
            val tab = intent.getStringExtra("tab") ?: "hour"
            val appWidgetManager = AppWidgetManager.getInstance(context)
            val componentName = android.content.ComponentName(context, TimetableWidgetProvider::class.java)
            val appWidgetIds = appWidgetManager.getAppWidgetIds(componentName)
            
            val widgetData = context.getSharedPreferences("HomeWidgetPreferences", Context.MODE_PRIVATE)
            widgetData.edit().putString("active_tab", tab).apply()
            
            for (appWidgetId in appWidgetIds) {
                updateWidgetView(context, appWidgetManager, appWidgetId, widgetData, tab)
            }
        }
    }

    private fun updateWidgetView(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int,
        widgetData: SharedPreferences,
        tab: String
    ) {
        val views = RemoteViews(context.packageName, R.layout.widget_layout)

        // 1. Reset all tabs to inactive state using Serene Pastel Academic colors
        val inactiveColor = Color.parseColor("#45474A") // on-surface-variant
        val activeColor = Color.parseColor("#FFFFFF") // on-primary
        
        views.setTextColor(R.id.tab_hour, inactiveColor)
        views.setInt(R.id.tab_hour, "setBackgroundResource", 0)

        views.setTextColor(R.id.tab_day, inactiveColor)
        views.setInt(R.id.tab_day, "setBackgroundResource", 0)

        views.setTextColor(R.id.tab_week, inactiveColor)
        views.setInt(R.id.tab_week, "setBackgroundResource", 0)

        views.setTextColor(R.id.tab_month, inactiveColor)
        views.setInt(R.id.tab_month, "setBackgroundResource", 0)

        // 2. Set Active Tab state and update content based on Tab
        when (tab) {
            "hour" -> {
                views.setTextColor(R.id.tab_hour, activeColor)
                views.setInt(R.id.tab_hour, "setBackgroundResource", R.drawable.tab_active_bg)
                views.setTextViewText(R.id.widget_title, "Current Class")
                views.setTextViewText(R.id.widget_content, "10:00 AM - AI Ethics\nHall B\n\n11:30 AM - Break")
            }
            "day" -> {
                views.setTextColor(R.id.tab_day, activeColor)
                views.setInt(R.id.tab_day, "setBackgroundResource", R.drawable.tab_active_bg)
                views.setTextViewText(R.id.widget_title, "Today's Schedule")
                views.setTextViewText(R.id.widget_content, "10:00 AM: AI Ethics (Hall B)\n11:30 AM: Break\n1:00 PM: Project Meeting")
            }
            "week" -> {
                views.setTextColor(R.id.tab_week, activeColor)
                views.setInt(R.id.tab_week, "setBackgroundResource", R.drawable.tab_active_bg)
                views.setTextViewText(R.id.widget_title, "This Week")
                views.setTextViewText(R.id.widget_content, "Mon: 2 Classes\nTue: 1 Lab\nWed: Free\nThu: 3 Classes\nFri: Presentations")
            }
            "month" -> {
                views.setTextColor(R.id.tab_month, activeColor)
                views.setInt(R.id.tab_month, "setBackgroundResource", R.drawable.tab_active_bg)
                views.setTextViewText(R.id.widget_title, "Upcoming Exams")
                views.setTextViewText(R.id.widget_content, "Oct 15: AI Midterm\nOct 22: Project Submission")
            }
        }

        // 3. Bind Clicks to natively update the widget instantly
        views.setOnClickPendingIntent(R.id.tab_hour, getTabIntent(context, appWidgetId, "hour"))
        views.setOnClickPendingIntent(R.id.tab_day, getTabIntent(context, appWidgetId, "day"))
        views.setOnClickPendingIntent(R.id.tab_week, getTabIntent(context, appWidgetId, "week"))
        views.setOnClickPendingIntent(R.id.tab_month, getTabIntent(context, appWidgetId, "month"))

        appWidgetManager.updateAppWidget(appWidgetId, views)
    }

    private fun getTabIntent(context: Context, appWidgetId: Int, tab: String): PendingIntent {
        val intent = Intent(context, TimetableWidgetProvider::class.java).apply {
            action = "com.example.frontend.TAB_CLICKED"
            putExtra("tab", tab)
            putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId)
        }
        val flags = PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        return PendingIntent.getBroadcast(context, tab.hashCode(), intent, flags)
    }
}
