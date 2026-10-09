package com.example.frontend

import es.antonborri.home_widget.HomeWidgetGlanceWidgetReceiver

class TimetableWidgetProvider : HomeWidgetGlanceWidgetReceiver<TimetableGlanceAppWidget>() {
    override val glanceAppWidget = TimetableGlanceAppWidget()
}

class TimetableGlanceWidgetReceiver : HomeWidgetGlanceWidgetReceiver<TimetableGlanceAppWidget>() {
    override val glanceAppWidget = TimetableGlanceAppWidget()
}
