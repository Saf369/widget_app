package com.example.frontend

import android.content.Context
import android.content.Intent
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.glance.GlanceId
import androidx.glance.GlanceModifier
import androidx.glance.Image
import androidx.glance.ImageProvider
import androidx.glance.action.ActionParameters
import androidx.glance.action.actionParametersOf
import androidx.glance.action.clickable
import androidx.glance.appwidget.GlanceAppWidget
import androidx.glance.appwidget.GlanceAppWidgetManager
import androidx.glance.appwidget.action.ActionCallback
import androidx.glance.appwidget.action.actionRunCallback
import androidx.glance.appwidget.action.actionStartActivity
import androidx.glance.appwidget.provideContent
import androidx.glance.appwidget.state.updateAppWidgetState
import androidx.glance.background
import androidx.glance.color.ColorProvider
import androidx.glance.currentState
import androidx.glance.layout.Alignment
import androidx.glance.layout.Box
import androidx.glance.layout.Column
import androidx.glance.layout.ColumnScope
import androidx.glance.layout.Row
import androidx.glance.layout.RowScope
import androidx.glance.layout.Spacer
import androidx.glance.layout.fillMaxHeight
import androidx.glance.layout.fillMaxSize
import androidx.glance.layout.fillMaxWidth
import androidx.glance.layout.height
import androidx.glance.layout.padding
import androidx.glance.layout.width
import androidx.glance.text.FontWeight
import androidx.glance.text.Text
import androidx.glance.text.TextStyle
import es.antonborri.home_widget.HomeWidgetGlanceState
import es.antonborri.home_widget.HomeWidgetGlanceStateDefinition
import java.text.SimpleDateFormat
import java.util.Calendar
import java.util.Locale
import org.json.JSONArray

val TabActionKey = ActionParameters.Key<String>("selected_tab")
val DeltaActionKey = ActionParameters.Key<Int>("hour_delta")

private fun color(c: Color) = ColorProvider(day = c, night = c)

private fun launchAppIntent(context: Context) = actionStartActivity(
    Intent(context, MainActivity::class.java).apply {
        flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
    }
)

data class GlanceTimetableEntry(
    val id: String,
    val day: String,
    val startTime: String,
    val endTime: String,
    val subject: String,
    val room: String,
    val instructor: String,
    val colorCode: String
)

private fun parseGlanceEntries(jsonStr: String?): List<GlanceTimetableEntry> {
    if (jsonStr.isNullOrBlank()) return emptyList()
    return try {
        val array = JSONArray(jsonStr)
        val list = mutableListOf<GlanceTimetableEntry>()
        for (i in 0 until array.length()) {
            val obj = array.getJSONObject(i)
            val rawDay = obj.optString("day", obj.optString("day_of_week", ""))
            val normDay = when {
                rawDay.startsWith("MON", ignoreCase = true) -> "MON"
                rawDay.startsWith("TUE", ignoreCase = true) -> "TUE"
                rawDay.startsWith("WED", ignoreCase = true) -> "WED"
                rawDay.startsWith("THU", ignoreCase = true) -> "THUR"
                rawDay.startsWith("FRI", ignoreCase = true) -> "FRI"
                rawDay.startsWith("SAT", ignoreCase = true) -> "SAT"
                rawDay.startsWith("SUN", ignoreCase = true) -> "SUN"
                else -> rawDay.trim().uppercase()
            }
            val subjectVal = obj.optString("subject", obj.optString("course_name", obj.optString("title", "Class"))).trim()
            list.add(
                GlanceTimetableEntry(
                    id = obj.optString("id", "$i"),
                    day = normDay,
                    startTime = obj.optString("start_time", obj.optString("startTime", "")).trim(),
                    endTime = obj.optString("end_time", obj.optString("endTime", "")).trim(),
                    subject = if (subjectVal.isNotEmpty()) subjectVal else "Class",
                    room = obj.optString("room", obj.optString("location", "")).trim(),
                    instructor = obj.optString("instructor", "").trim(),
                    colorCode = obj.optString("color_code", obj.optString("color", "0xFFE8CACF"))
                )
            )
        }
        list
    } catch (_: Exception) {
        emptyList()
    }
}

private fun parseTimeToMinutes(timeStr: String): Int {
    if (timeStr.isBlank()) return -1
    val clean = timeStr.trim().uppercase()
    val isPm = clean.contains("PM")
    val isAm = clean.contains("AM")
    val digitsOnly = clean.replace(Regex("[^0-9:]"), "")
    val parts = digitsOnly.split(":")
    var hour = parts.getOrNull(0)?.toIntOrNull() ?: return -1
    val minute = parts.getOrNull(1)?.toIntOrNull() ?: 0
    if (isPm && hour < 12) hour += 12
    if (isAm && hour == 12) hour = 0
    if (!isPm && !isAm && hour in 1..6) hour += 12
    return hour * 60 + minute
}

private fun parseHourAndAmPm(timeStr: String): Pair<String, String> {
    val totalMin = parseTimeToMinutes(timeStr)
    if (totalMin < 0) return Pair(timeStr, "")
    val rawHour = totalMin / 60
    val minute = totalMin % 60
    val isPm = rawHour >= 12
    val hour12 = if (rawHour % 12 == 0) 12 else rawHour % 12
    val amPm = if (isPm) "PM" else "AM"
    val hourText = if (minute == 0) "$hour12" else "$hour12:${if (minute < 10) "0$minute" else "$minute"}"
    return Pair(hourText, amPm)
}

private fun formatTimeRange(startStr: String, endStr: String): String {
    val startMin = parseTimeToMinutes(startStr)
    val endMin = parseTimeToMinutes(endStr)
    if (startMin < 0 || endMin < 0) return "$startStr – $endStr"

    fun fmt(min: Int): String {
        val h = min / 60
        val m = min % 60
        val isPm = h >= 12
        val h12 = if (h % 12 == 0) 12 else h % 12
        val amPm = if (isPm) "PM" else "AM"
        val mStr = if (m == 0) "00" else if (m < 10) "0$m" else "$m"
        return "$h12:$mStr $amPm"
    }
    val durMin = endMin - startMin
    val durStr = if (durMin > 0) {
        val hrs = durMin / 60
        val mins = durMin % 60
        when {
            hrs > 0 && mins > 0 -> " · ${hrs}h ${mins}m"
            hrs > 0 -> " · $hrs Hour${if (hrs > 1) "s" else ""}"
            else -> " · $mins min"
        }
    } else ""
    return "${fmt(startMin)} – ${fmt(endMin)}$durStr"
}

private fun getCardDrawable(colorCode: String, subject: String): Int {
    val s = subject.uppercase()
    val c = colorCode.uppercase()
    return when {
        s.contains("FREE") -> R.drawable.card_free_bg
        c.contains("E8CACF") || c.contains("D7A1A7") || s.contains("THEORY") || s.contains("MATH") -> R.drawable.card_pink_bg
        c.contains("DBD3EE") || s.contains("DESIGN") || s.contains("ENGLISH") || s.contains("MUSIC") -> R.drawable.card_purple_bg
        c.contains("CDE6E2") || c.contains("BDE4C9") || s.contains("SCIENCE") || s.contains("PDHPE") -> R.drawable.card_mint_bg
        c.contains("EFCCB8") || c.contains("E9CCAA") || s.contains("HISTORY") || s.contains("ART") -> R.drawable.card_peach_bg
        else -> R.drawable.card_pink_bg
    }
}

class TimetableGlanceAppWidget : GlanceAppWidget() {

    override val stateDefinition = HomeWidgetGlanceStateDefinition()

    override suspend fun provideGlance(context: Context, id: GlanceId) {
        provideContent {
            GlanceContent(context, currentState())
        }
    }

    @Composable
    private fun GlanceContent(context: Context, state: HomeWidgetGlanceState) {
        val prefs = state.preferences
        val activeTab = prefs.getString("active_tab", "day") ?: "day"
        val hourOffset = prefs.getInt("hour_offset", 0)
        val entriesJson = prefs.getString("timetable_entries", null)
        val entries = parseGlanceEntries(entriesJson)

        val calendar = Calendar.getInstance()
        val currentMinutes = calendar.get(Calendar.HOUR_OF_DAY) * 60 + calendar.get(Calendar.MINUTE)
        val todayKey = when (calendar.get(Calendar.DAY_OF_WEEK)) {
            Calendar.MONDAY -> "MON"
            Calendar.TUESDAY -> "TUE"
            Calendar.WEDNESDAY -> "WED"
            Calendar.THURSDAY -> "THUR"
            Calendar.FRIDAY -> "FRI"
            Calendar.SATURDAY -> "SAT"
            Calendar.SUNDAY -> "SUN"
            else -> "MON"
        }

        val locale = Locale.getDefault()
        val todayDateFormatted = SimpleDateFormat("EEE, d MMM yyyy", locale).format(calendar.time)
        val monthFormatted = SimpleDateFormat("MMMM yyyy", locale).format(calendar.time)

        val weekCalStart = (calendar.clone() as Calendar).apply {
            val dow = get(Calendar.DAY_OF_WEEK)
            val diff = if (dow == Calendar.SUNDAY) -6 else Calendar.MONDAY - dow
            add(Calendar.DAY_OF_MONTH, diff)
        }
        val weekCalEnd = (weekCalStart.clone() as Calendar).apply { add(Calendar.DAY_OF_MONTH, 6) }
        val weekFormatted = "${SimpleDateFormat("d", locale).format(weekCalStart.time)} – ${SimpleDateFormat("d MMM yyyy", locale).format(weekCalEnd.time)}"

        val dateText = when (activeTab) {
            "week" -> weekFormatted
            "month" -> monthFormatted
            else -> todayDateFormatted
        }

        Box(
            modifier = GlanceModifier
                .fillMaxSize()
                .background(ImageProvider(R.drawable.widget_outer_bg))
                .padding(18.dp)
        ) {
            Column(
                modifier = GlanceModifier.fillMaxSize()
            ) {
                WidgetHeader(context = context, activeTab = activeTab, dateText = dateText)

                Spacer(modifier = GlanceModifier.height(14.dp))

                Box(
                    modifier = GlanceModifier.fillMaxSize().defaultWeight()
                ) {
                    when (activeTab) {
                        "hour" -> HourView(context = context, hourOffset = hourOffset, entries = entries, currentMinutes = currentMinutes, todayKey = todayKey)
                        "day" -> DayView(context = context, entries = entries, currentMinutes = currentMinutes, todayKey = todayKey)
                        "week" -> WeekView(context = context, weekCalStart = weekCalStart, todayCal = calendar)
                        "month" -> MonthView(context = context, entries = entries, todayKey = todayKey, todayCal = calendar)
                        else -> DayView(context = context, entries = entries, currentMinutes = currentMinutes, todayKey = todayKey)
                    }
                }
            }
        }
    }

    @Composable
    private fun WidgetHeader(context: Context, activeTab: String, dateText: String) {
        Row(
            modifier = GlanceModifier.fillMaxWidth(),
            verticalAlignment = Alignment.Vertical.CenterVertically,
            horizontalAlignment = Alignment.Horizontal.Start
        ) {
            // Title & Date (Clickable to open App)
            Column(
                modifier = GlanceModifier.defaultWeight()
                    .clickable(launchAppIntent(context))
            ) {
                Text(
                    text = "Timetable",
                    style = TextStyle(
                        color = color(Color(0xFF181818)),
                        fontSize = 24.sp,
                        fontWeight = FontWeight.Bold
                    )
                )
                Spacer(modifier = GlanceModifier.height(2.dp))
                Text(
                    text = dateText,
                    style = TextStyle(
                        color = color(Color(0xFF726E6A)),
                        fontSize = 12.sp,
                        fontWeight = FontWeight.Medium
                    )
                )
            }

            // Tab Bar: [ Hour | Day | Week | Month ]
            TabBar(activeTab = activeTab)
        }
    }

    @Composable
    private fun TabBar(activeTab: String) {
        Row(
            modifier = GlanceModifier
                .background(ImageProvider(R.drawable.tab_bar_bg))
                .padding(3.dp),
            verticalAlignment = Alignment.Vertical.CenterVertically
        ) {
            TabItem(title = "Hour", key = "hour", isActive = activeTab == "hour")
            TabItem(title = "Day", key = "day", isActive = activeTab == "day")
            TabItem(title = "Week", key = "week", isActive = activeTab == "week")
            TabItem(title = "Month", key = "month", isActive = activeTab == "month")
        }
    }

    @Composable
    private fun TabItem(title: String, key: String, isActive: Boolean) {
        val bgModifier = if (isActive) {
            GlanceModifier.background(ImageProvider(R.drawable.tab_active_black))
                .padding(horizontal = 12.dp, vertical = 6.dp)
        } else {
            GlanceModifier.padding(horizontal = 9.dp, vertical = 6.dp)
        }

        Box(
            modifier = bgModifier.clickable(
                actionRunCallback<SwitchTabAction>(actionParametersOf(TabActionKey to key))
            ),
            contentAlignment = Alignment.Center
        ) {
            Text(
                text = title,
                style = TextStyle(
                    color = color(if (isActive) Color.White else Color(0xFF5A5550)),
                    fontSize = 12.sp,
                    fontWeight = if (isActive) FontWeight.Bold else FontWeight.Medium
                )
            )
        }
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 1. DAY VIEW (Dynamic with Live Status & Fallback)
    // ─────────────────────────────────────────────────────────────────────────
    @Composable
    private fun DayView(
        context: Context,
        entries: List<GlanceTimetableEntry>,
        currentMinutes: Int,
        todayKey: String
    ) {
        val todayEntries = entries.filter { it.day == todayKey }
        val displayEntries = if (todayEntries.isNotEmpty()) {
            todayEntries
        } else if (entries.isNotEmpty()) {
            val firstDay = entries.first().day
            entries.filter { it.day == firstDay }
        } else {
            emptyList()
        }

        if (displayEntries.isEmpty()) {
            DefaultDayView(context)
            return
        }

        val sorted = displayEntries.sortedBy { parseTimeToMinutes(it.startTime) }

        val activeIndex = sorted.indexOfFirst {
            val s = parseTimeToMinutes(it.startTime)
            val e = parseTimeToMinutes(it.endTime)
            currentMinutes in s until e
        }
        val nextIndex = if (activeIndex >= 0) activeIndex else sorted.indexOfFirst {
            val s = parseTimeToMinutes(it.startTime)
            currentMinutes < s
        }

        val startIndex = when {
            activeIndex >= 0 -> activeIndex.coerceAtMost((sorted.size - 3).coerceAtLeast(0))
            nextIndex >= 0 -> nextIndex.coerceAtMost((sorted.size - 3).coerceAtLeast(0))
            else -> (sorted.size - 3).coerceAtLeast(0)
        }

        val visibleEntries = sorted.drop(startIndex).take(3)

        Column(
            modifier = GlanceModifier.fillMaxSize()
        ) {
            visibleEntries.forEachIndexed { index, entry ->
                val (hourStr, amPmStr) = parseHourAndAmPm(entry.startTime)
                val sMin = parseTimeToMinutes(entry.startTime)
                val eMin = parseTimeToMinutes(entry.endTime)
                val isNow = currentMinutes in sMin until eMin
                val cardDrawable = getCardDrawable(entry.colorCode, entry.subject)
                val timeRangeText = formatTimeRange(entry.startTime, entry.endTime)

                Row(
                    modifier = GlanceModifier.fillMaxWidth().defaultWeight(),
                    verticalAlignment = Alignment.Vertical.CenterVertically
                ) {
                    TimeLabel(hour = hourStr, amPm = amPmStr)
                    Spacer(modifier = GlanceModifier.width(10.dp))

                    Box(
                        modifier = GlanceModifier
                            .fillMaxWidth()
                            .defaultWeight()
                            .fillMaxHeight()
                            .background(ImageProvider(cardDrawable))
                            .padding(horizontal = 14.dp, vertical = 10.dp)
                            .clickable(launchAppIntent(context)),
                        contentAlignment = Alignment.CenterStart
                    ) {
                        Row(
                            modifier = GlanceModifier.fillMaxWidth(),
                            verticalAlignment = Alignment.Vertical.CenterVertically
                        ) {
                            Column(
                                modifier = GlanceModifier.defaultWeight()
                            ) {
                                Row(
                                    verticalAlignment = Alignment.Vertical.CenterVertically
                                ) {
                                    Text(
                                        text = entry.subject,
                                        style = TextStyle(
                                            color = color(Color(0xFF181818)),
                                            fontSize = 17.sp,
                                            fontWeight = FontWeight.Bold
                                        )
                                    )
                                    if (isNow) {
                                        Spacer(modifier = GlanceModifier.width(6.dp))
                                        Box(
                                            modifier = GlanceModifier
                                                .background(ImageProvider(R.drawable.badge_now_bg))
                                                .padding(horizontal = 7.dp, vertical = 2.dp),
                                            contentAlignment = Alignment.Center
                                        ) {
                                            Text(
                                                text = "NOW",
                                                style = TextStyle(
                                                    color = color(Color.White),
                                                    fontSize = 9.sp,
                                                    fontWeight = FontWeight.Bold
                                                )
                                            )
                                        }
                                    }
                                }
                                Spacer(modifier = GlanceModifier.height(2.dp))
                                Text(
                                    text = if (entry.instructor.isNotEmpty()) "$timeRangeText · ${entry.instructor}" else timeRangeText,
                                    style = TextStyle(
                                        color = color(Color(0xFF42383D)),
                                        fontSize = 11.sp,
                                        fontWeight = FontWeight.Normal
                                    )
                                )
                            }

                            if (entry.room.isNotEmpty()) {
                                Spacer(modifier = GlanceModifier.width(6.dp))
                                Box(
                                    modifier = GlanceModifier
                                        .background(ImageProvider(if (isNow) R.drawable.badge_now_bg else R.drawable.badge_room_bg))
                                        .padding(horizontal = 10.dp, vertical = 5.dp),
                                    contentAlignment = Alignment.Center
                                ) {
                                    Text(
                                        text = entry.room,
                                        style = TextStyle(
                                            color = color(if (isNow) Color.White else Color(0xFF262322)),
                                            fontSize = 10.sp,
                                            fontWeight = FontWeight.Bold
                                        )
                                    )
                                }
                            }
                        }
                    }
                }

                if (index < visibleEntries.size - 1) {
                    Spacer(modifier = GlanceModifier.height(6.dp))
                    HorizontalLine()
                    Spacer(modifier = GlanceModifier.height(6.dp))
                }
            }
        }
    }

    @Composable
    private fun DefaultDayView(context: Context) {
        Column(
            modifier = GlanceModifier.fillMaxSize()
        ) {
            // Row 1: 10 AM - Theory Test (Takes proportional height)
            Row(
                modifier = GlanceModifier.fillMaxWidth().defaultWeight(),
                verticalAlignment = Alignment.Vertical.CenterVertically
            ) {
                // Time Column
                TimeLabel(hour = "10", amPm = "AM")
                Spacer(modifier = GlanceModifier.width(12.dp))

                // Theory Test Card (expands vertically to fill its slot)
                Box(
                    modifier = GlanceModifier
                        .fillMaxWidth()
                        .defaultWeight()
                        .fillMaxHeight()
                        .background(ImageProvider(R.drawable.card_pink_bg))
                        .padding(horizontal = 16.dp, vertical = 14.dp)
                        .clickable(launchAppIntent(context)),
                    contentAlignment = Alignment.CenterStart
                ) {
                    Row(
                        modifier = GlanceModifier.fillMaxWidth(),
                        verticalAlignment = Alignment.Vertical.CenterVertically
                    ) {
                        Column(
                            modifier = GlanceModifier.defaultWeight()
                        ) {
                            Text(
                                text = "Theory Test",
                                style = TextStyle(
                                    color = color(Color(0xFF181818)),
                                    fontSize = 18.sp,
                                    fontWeight = FontWeight.Bold
                                )
                            )
                            Spacer(modifier = GlanceModifier.height(3.dp))
                            Text(
                                text = "10:00 – 11:00 AM · 1 Hour",
                                style = TextStyle(
                                    color = color(Color(0xFF42383D)),
                                    fontSize = 11.sp,
                                    fontWeight = FontWeight.Normal
                                )
                            )
                        }

                        // Room 244 Badge
                        Box(
                            modifier = GlanceModifier
                                .background(ImageProvider(R.drawable.badge_room_bg))
                                .padding(horizontal = 12.dp, vertical = 6.dp),
                            contentAlignment = Alignment.Center
                        ) {
                            Text(
                                text = "Room 244",
                                style = TextStyle(
                                    color = color(Color(0xFF262322)),
                                    fontSize = 11.sp,
                                    fontWeight = FontWeight.Bold
                                )
                            )
                        }
                    }
                }
            }

            // Divider 1 with balanced margin
            Spacer(modifier = GlanceModifier.height(8.dp))
            HorizontalLine()
            Spacer(modifier = GlanceModifier.height(8.dp))

            // Row 2: 11 AM - Free Time (Takes proportional height)
            Row(
                modifier = GlanceModifier.fillMaxWidth().defaultWeight(),
                verticalAlignment = Alignment.Vertical.CenterVertically
            ) {
                TimeLabel(hour = "11", amPm = "AM")
                Spacer(modifier = GlanceModifier.width(12.dp))

                Box(
                    modifier = GlanceModifier
                        .fillMaxWidth()
                        .defaultWeight()
                        .fillMaxHeight()
                        .background(ImageProvider(R.drawable.card_free_bg))
                        .padding(horizontal = 16.dp, vertical = 12.dp)
                        .clickable(launchAppIntent(context)),
                    contentAlignment = Alignment.Center
                ) {
                    Column(
                        horizontalAlignment = Alignment.Horizontal.CenterHorizontally,
                        verticalAlignment = Alignment.Vertical.CenterVertically
                    ) {
                        Text(
                            text = "You have 2 hours",
                            style = TextStyle(
                                color = color(Color(0xFF6C6661)),
                                fontSize = 12.sp,
                                fontWeight = FontWeight.Normal
                            )
                        )
                        Spacer(modifier = GlanceModifier.height(2.dp))
                        Text(
                            text = "Free Time",
                            style = TextStyle(
                                color = color(Color(0xFF181818)),
                                fontSize = 17.sp,
                                fontWeight = FontWeight.Bold
                            )
                        )
                    }
                }
            }

            // Divider 2 with balanced margin
            Spacer(modifier = GlanceModifier.height(8.dp))
            HorizontalLine()
            Spacer(modifier = GlanceModifier.height(8.dp))

            // Row 3: 1 PM - Design Test (Takes proportional height)
            Row(
                modifier = GlanceModifier.fillMaxWidth().defaultWeight(),
                verticalAlignment = Alignment.Vertical.CenterVertically
            ) {
                TimeLabel(hour = "1", amPm = "PM")
                Spacer(modifier = GlanceModifier.width(12.dp))

                Box(
                    modifier = GlanceModifier
                        .fillMaxWidth()
                        .defaultWeight()
                        .fillMaxHeight()
                        .background(ImageProvider(R.drawable.card_purple_bg))
                        .padding(horizontal = 16.dp, vertical = 14.dp)
                        .clickable(launchAppIntent(context)),
                    contentAlignment = Alignment.CenterStart
                ) {
                    Row(
                        modifier = GlanceModifier.fillMaxWidth(),
                        verticalAlignment = Alignment.Vertical.CenterVertically
                    ) {
                        Column(
                            modifier = GlanceModifier.defaultWeight()
                        ) {
                            Text(
                                text = "Design Test",
                                style = TextStyle(
                                    color = color(Color(0xFF181818)),
                                    fontSize = 18.sp,
                                    fontWeight = FontWeight.Bold
                                )
                            )
                            Spacer(modifier = GlanceModifier.height(3.dp))
                            Text(
                                text = "1:00 – 2:00 PM · 1 Hour",
                                style = TextStyle(
                                    color = color(Color(0xFF383240)),
                                    fontSize = 11.sp,
                                    fontWeight = FontWeight.Normal
                                )
                            )
                        }

                        // Room 244 Badge
                        Box(
                            modifier = GlanceModifier
                                .background(ImageProvider(R.drawable.badge_room_bg))
                                .padding(horizontal = 12.dp, vertical = 6.dp),
                            contentAlignment = Alignment.Center
                        ) {
                            Text(
                                text = "Room 244",
                                style = TextStyle(
                                    color = color(Color(0xFF262322)),
                                    fontSize = 11.sp,
                                    fontWeight = FontWeight.Bold
                                )
                            )
                        }
                    }
                }
            }
        }
    }

    @Composable
    private fun TimeLabel(hour: String, amPm: String) {
        Column(
            modifier = GlanceModifier.width(36.dp),
            horizontalAlignment = Alignment.Horizontal.CenterHorizontally,
            verticalAlignment = Alignment.Vertical.CenterVertically
        ) {
            Text(
                text = hour,
                style = TextStyle(
                    color = color(Color(0xFF181818)),
                    fontSize = 22.sp,
                    fontWeight = FontWeight.Bold
                )
            )
            Text(
                text = amPm,
                style = TextStyle(
                    color = color(Color(0xFF726E6A)),
                    fontSize = 11.sp,
                    fontWeight = FontWeight.Bold
                )
            )
        }
    }

    @Composable
    private fun HorizontalLine() {
        Box(
            modifier = GlanceModifier
                .fillMaxWidth()
                .height(1.dp)
                .background(Color(0x1F000000))
        ) {}
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 2. HOUR VIEW (Dynamic with Live Progress & Fallback)
    // ─────────────────────────────────────────────────────────────────────────
    @Composable
    private fun HourView(
        context: Context,
        hourOffset: Int,
        entries: List<GlanceTimetableEntry>,
        currentMinutes: Int,
        todayKey: String
    ) {
        val todayEntries = entries.filter { it.day == todayKey }
        val displayEntries = if (todayEntries.isNotEmpty()) todayEntries else entries.filter { it.day == "MON" }.ifEmpty { entries }

        if (displayEntries.isEmpty()) {
            DefaultHourView(context, hourOffset)
            return
        }

        val sorted = displayEntries.sortedBy { parseTimeToMinutes(it.startTime) }
        val activeIndex = sorted.indexOfFirst {
            val s = parseTimeToMinutes(it.startTime)
            val e = parseTimeToMinutes(it.endTime)
            currentMinutes in s until e
        }
        val baseIndex = if (activeIndex >= 0) activeIndex else sorted.indexOfFirst {
            val s = parseTimeToMinutes(it.startTime)
            currentMinutes < s
        }.let { if (it >= 0) it else 0 }

        val targetIndex = (baseIndex + hourOffset).coerceIn(0, sorted.size - 1)
        val entry = sorted[targetIndex]

        val sMin = parseTimeToMinutes(entry.startTime)
        val eMin = parseTimeToMinutes(entry.endTime)
        val isNow = currentMinutes in sMin until eMin
        val isDone = currentMinutes >= eMin
        val isUpcoming = currentMinutes < sMin

        val statusText = when {
            isNow -> "In progress · ${entry.subject}"
            isDone -> "Completed · ${entry.subject}"
            else -> "Upcoming · ${entry.subject}"
        }

        val durMin = (eMin - sMin).coerceAtLeast(1)
        val elapsed = (currentMinutes - sMin).coerceIn(0, durMin)
        val minLeft = (eMin - currentMinutes).coerceAtLeast(0)
        val progressFrac = if (isDone) 1.0f else if (isUpcoming) 0.0f else (elapsed.toFloat() / durMin.toFloat()).coerceIn(0.05f, 1.0f)
        val barWidthDp = (180 * progressFrac).toInt().coerceIn(10, 180)

        val cardBg = getCardDrawable(entry.colorCode, entry.subject)

        Column(
            modifier = GlanceModifier.fillMaxSize()
        ) {
            // Navigation Bar (< Time Range / Status >)
            Row(
                modifier = GlanceModifier.fillMaxWidth(),
                verticalAlignment = Alignment.Vertical.CenterVertically
            ) {
                // Prev button
                Box(
                    modifier = GlanceModifier
                        .background(ImageProvider(R.drawable.circle_button_bg))
                        .padding(7.dp)
                        .clickable(
                            actionRunCallback<NavigateHourAction>(
                                actionParametersOf(DeltaActionKey to -1)
                            )
                        ),
                    contentAlignment = Alignment.Center
                ) {
                    Image(
                        provider = ImageProvider(R.drawable.ic_chevron_left),
                        contentDescription = "Previous Hour",
                        modifier = GlanceModifier.width(16.dp).height(16.dp)
                    )
                }

                // Middle Text
                Column(
                    modifier = GlanceModifier.defaultWeight(),
                    horizontalAlignment = Alignment.Horizontal.CenterHorizontally
                ) {
                    Text(
                        text = "${entry.startTime} – ${entry.endTime}",
                        style = TextStyle(
                            color = color(Color(0xFF181818)),
                            fontSize = 16.sp,
                            fontWeight = FontWeight.Bold
                        )
                    )
                    Spacer(modifier = GlanceModifier.height(2.dp))
                    Text(
                        text = statusText,
                        style = TextStyle(
                            color = color(Color(0xFF6C6661)),
                            fontSize = 12.sp,
                            fontWeight = FontWeight.Normal
                        )
                    )
                }

                // Next button
                Box(
                    modifier = GlanceModifier
                        .background(ImageProvider(R.drawable.circle_button_bg))
                        .padding(7.dp)
                        .clickable(
                            actionRunCallback<NavigateHourAction>(
                                actionParametersOf(DeltaActionKey to 1)
                            )
                        ),
                    contentAlignment = Alignment.Center
                ) {
                    Image(
                        provider = ImageProvider(R.drawable.ic_chevron_right),
                        contentDescription = "Next Hour",
                        modifier = GlanceModifier.width(16.dp).height(16.dp)
                    )
                }
            }

            Spacer(modifier = GlanceModifier.height(14.dp))

            // Main Content: Left timestamps + Right card filling vertical height
            Row(
                modifier = GlanceModifier.fillMaxWidth().defaultWeight()
            ) {
                // Left Timestamps Column
                Column(
                    modifier = GlanceModifier.width(42.dp).fillMaxHeight()
                ) {
                    Column(
                        modifier = GlanceModifier.fillMaxWidth().defaultWeight()
                    ) {
                        Text(entry.startTime, style = TextStyle(color = color(Color(0xFF726E6A)), fontSize = 11.sp, fontWeight = FontWeight.Medium))
                        Spacer(modifier = GlanceModifier.defaultWeight())
                        Text(entry.endTime, style = TextStyle(color = color(Color(0xFF726E6A)), fontSize = 11.sp, fontWeight = FontWeight.Medium))
                    }
                }

                Spacer(modifier = GlanceModifier.width(10.dp))

                // Right Card Column
                Box(
                    modifier = GlanceModifier
                        .fillMaxWidth()
                        .defaultWeight()
                        .fillMaxHeight()
                        .background(ImageProvider(cardBg))
                        .padding(16.dp)
                        .clickable(launchAppIntent(context))
                ) {
                    Column(
                        modifier = GlanceModifier.fillMaxSize()
                    ) {
                        // Card Header: Title + "Now" or Room badge
                        Row(
                            modifier = GlanceModifier.fillMaxWidth(),
                            verticalAlignment = Alignment.Vertical.CenterVertically
                        ) {
                            Text(
                                text = entry.subject,
                                style = TextStyle(
                                    color = color(Color(0xFF181818)),
                                    fontSize = 18.sp,
                                    fontWeight = FontWeight.Bold
                                ),
                                modifier = GlanceModifier.defaultWeight()
                            )

                            if (isNow) {
                                Box(
                                    modifier = GlanceModifier
                                        .background(ImageProvider(R.drawable.badge_now_bg))
                                        .padding(horizontal = 10.dp, vertical = 4.dp),
                                    contentAlignment = Alignment.Center
                                ) {
                                    Text(
                                        text = "Now",
                                        style = TextStyle(
                                            color = color(Color.White),
                                            fontSize = 10.sp,
                                            fontWeight = FontWeight.Bold
                                        )
                                    )
                                }
                            } else if (entry.room.isNotEmpty()) {
                                Box(
                                    modifier = GlanceModifier
                                        .background(ImageProvider(R.drawable.badge_room_bg))
                                        .padding(horizontal = 10.dp, vertical = 4.dp),
                                    contentAlignment = Alignment.Center
                                ) {
                                    Text(
                                        text = entry.room,
                                        style = TextStyle(
                                            color = color(Color(0xFF262322)),
                                            fontSize = 10.sp,
                                            fontWeight = FontWeight.Bold
                                        )
                                    )
                                }
                            }
                        }

                        Spacer(modifier = GlanceModifier.height(2.dp))

                        val detailLine = listOfNotNull(
                            if (entry.instructor.isNotEmpty()) entry.instructor else null,
                            if (entry.room.isNotEmpty()) entry.room else null
                        ).joinToString(" · ")

                        if (detailLine.isNotEmpty()) {
                            Text(
                                text = detailLine,
                                style = TextStyle(
                                    color = color(Color(0xFF45363D)),
                                    fontSize = 12.sp,
                                    fontWeight = FontWeight.Normal
                                )
                            )
                        }

                        Spacer(modifier = GlanceModifier.defaultWeight())

                        // Progress Bar Track
                        Row(
                            modifier = GlanceModifier
                                .fillMaxWidth()
                                .height(4.dp)
                                .background(ImageProvider(R.drawable.progress_bar_track))
                        ) {
                            Box(
                                modifier = GlanceModifier
                                    .width(barWidthDp.dp)
                                    .fillMaxHeight()
                                    .background(Color(0xFF181818))
                            ) {}
                        }

                        Spacer(modifier = GlanceModifier.height(8.dp))

                        // Bottom progress times
                        Row(
                            modifier = GlanceModifier.fillMaxWidth(),
                            verticalAlignment = Alignment.Vertical.CenterVertically
                        ) {
                            Text(
                                text = "${entry.startTime} – ${entry.endTime}",
                                style = TextStyle(
                                    color = color(Color(0xFF262322)),
                                    fontSize = 11.sp,
                                    fontWeight = FontWeight.Bold
                                ),
                                modifier = GlanceModifier.defaultWeight()
                            )
                            if (isNow) {
                                Text(
                                    text = "$minLeft min left",
                                    style = TextStyle(
                                        color = color(Color(0xFF262322)),
                                        fontSize = 11.sp,
                                        fontWeight = FontWeight.Bold
                                    )
                                )
                            } else if (isDone) {
                                Text(
                                    text = "Completed",
                                    style = TextStyle(
                                        color = color(Color(0xFF726E6A)),
                                        fontSize = 11.sp,
                                        fontWeight = FontWeight.Medium
                                    )
                                )
                            }
                        }
                    }
                }
            }
        }
    }

    @Composable
    private fun DefaultHourView(context: Context, hourOffset: Int) {
        Column(
            modifier = GlanceModifier.fillMaxSize()
        ) {
            // Navigation Bar (< 10:00 - 11:00 AM / In progress · Theory Test >)
            val timeRange = when (hourOffset) {
                -1 -> "9:00 – 10:00 AM"
                1 -> "11:00 AM – 12:00 PM"
                2 -> "1:00 – 2:00 PM"
                else -> "10:00 – 11:00 AM"
            }
            val statusText = when (hourOffset) {
                -1 -> "Completed · Studio Prep"
                1 -> "Upcoming · Free Time"
                2 -> "Upcoming · Design Test"
                else -> "In progress · Theory Test"
            }

            Row(
                modifier = GlanceModifier.fillMaxWidth(),
                verticalAlignment = Alignment.Vertical.CenterVertically
            ) {
                // Prev button
                Box(
                    modifier = GlanceModifier
                        .background(ImageProvider(R.drawable.circle_button_bg))
                        .padding(7.dp)
                        .clickable(
                            actionRunCallback<NavigateHourAction>(
                                actionParametersOf(DeltaActionKey to -1)
                            )
                        ),
                    contentAlignment = Alignment.Center
                ) {
                    Image(
                        provider = ImageProvider(R.drawable.ic_chevron_left),
                        contentDescription = "Previous Hour",
                        modifier = GlanceModifier.width(16.dp).height(16.dp)
                    )
                }

                // Middle Text
                Column(
                    modifier = GlanceModifier.defaultWeight(),
                    horizontalAlignment = Alignment.Horizontal.CenterHorizontally
                ) {
                    Text(
                        text = timeRange,
                        style = TextStyle(
                            color = color(Color(0xFF181818)),
                            fontSize = 16.sp,
                            fontWeight = FontWeight.Bold
                        )
                    )
                    Spacer(modifier = GlanceModifier.height(2.dp))
                    Text(
                        text = statusText,
                        style = TextStyle(
                            color = color(Color(0xFF6C6661)),
                            fontSize = 12.sp,
                            fontWeight = FontWeight.Normal
                        )
                    )
                }

                // Next button
                Box(
                    modifier = GlanceModifier
                        .background(ImageProvider(R.drawable.circle_button_bg))
                        .padding(7.dp)
                        .clickable(
                            actionRunCallback<NavigateHourAction>(
                                actionParametersOf(DeltaActionKey to 1)
                            )
                        ),
                    contentAlignment = Alignment.Center
                ) {
                    Image(
                        provider = ImageProvider(R.drawable.ic_chevron_right),
                        contentDescription = "Next Hour",
                        modifier = GlanceModifier.width(16.dp).height(16.dp)
                    )
                }
            }

            Spacer(modifier = GlanceModifier.height(14.dp))

            // Main Content: Left timestamps + Right cards filling vertical height
            Row(
                modifier = GlanceModifier.fillMaxWidth().defaultWeight()
            ) {
                // Left Timestamps Column
                Column(
                    modifier = GlanceModifier.width(42.dp).fillMaxHeight()
                ) {
                    // Top column covering Theory Test height
                    Column(
                        modifier = GlanceModifier.fillMaxWidth().defaultWeight()
                    ) {
                        Text("10:00", style = TextStyle(color = color(Color(0xFF726E6A)), fontSize = 11.sp, fontWeight = FontWeight.Medium))
                        Spacer(modifier = GlanceModifier.defaultWeight())
                        Text("10:15", style = TextStyle(color = color(Color(0xFF726E6A)), fontSize = 11.sp, fontWeight = FontWeight.Medium))
                        Spacer(modifier = GlanceModifier.defaultWeight())
                        Text("10:30", style = TextStyle(color = color(Color(0xFF726E6A)), fontSize = 11.sp, fontWeight = FontWeight.Medium))
                    }

                    Spacer(modifier = GlanceModifier.height(10.dp))

                    // Bottom box covering Free 15 min height
                    Box(
                        modifier = GlanceModifier.fillMaxWidth().height(52.dp),
                        contentAlignment = Alignment.CenterStart
                    ) {
                        Text("10:45", style = TextStyle(color = color(Color(0xFF726E6A)), fontSize = 11.sp, fontWeight = FontWeight.Medium))
                    }
                }

                Spacer(modifier = GlanceModifier.width(10.dp))

                // Right Cards Column
                Column(
                    modifier = GlanceModifier.fillMaxWidth().defaultWeight().fillMaxHeight()
                ) {
                    // Ongoing Card: Theory Test (Spans 10:00 - 10:45, expands with defaultWeight)
                    Box(
                        modifier = GlanceModifier
                            .fillMaxWidth()
                            .defaultWeight()
                            .background(ImageProvider(R.drawable.card_pink_bg))
                            .padding(16.dp)
                            .clickable(launchAppIntent(context))
                    ) {
                        Column(
                            modifier = GlanceModifier.fillMaxSize()
                        ) {
                            // Card Header: Title + "Now" badge
                            Row(
                                modifier = GlanceModifier.fillMaxWidth(),
                                verticalAlignment = Alignment.Vertical.CenterVertically
                            ) {
                                Text(
                                    text = "Theory Test",
                                    style = TextStyle(
                                        color = color(Color(0xFF181818)),
                                        fontSize = 18.sp,
                                        fontWeight = FontWeight.Bold
                                    ),
                                    modifier = GlanceModifier.defaultWeight()
                                )

                                Box(
                                    modifier = GlanceModifier
                                        .background(ImageProvider(R.drawable.badge_now_bg))
                                        .padding(horizontal = 10.dp, vertical = 4.dp),
                                    contentAlignment = Alignment.Center
                                ) {
                                    Text(
                                        text = "Now",
                                        style = TextStyle(
                                            color = color(Color.White),
                                            fontSize = 10.sp,
                                            fontWeight = FontWeight.Bold
                                        )
                                    )
                                }
                            }

                            Spacer(modifier = GlanceModifier.height(2.dp))

                            Text(
                                text = "Design Theory · Room 244",
                                style = TextStyle(
                                    color = color(Color(0xFF45363D)),
                                    fontSize = 12.sp,
                                    fontWeight = FontWeight.Normal
                                )
                            )

                            Spacer(modifier = GlanceModifier.defaultWeight())

                            // Progress Bar Track
                            Row(
                                modifier = GlanceModifier
                                    .fillMaxWidth()
                                    .height(4.dp)
                                    .background(ImageProvider(R.drawable.progress_bar_track))
                            ) {
                                Box(
                                    modifier = GlanceModifier
                                        .width(140.dp)
                                        .fillMaxHeight()
                                        .background(Color(0xFF181818))
                                ) {}
                            }

                            Spacer(modifier = GlanceModifier.height(8.dp))

                            // Bottom progress times
                            Row(
                                modifier = GlanceModifier.fillMaxWidth(),
                                verticalAlignment = Alignment.Vertical.CenterVertically
                            ) {
                                Text(
                                    text = "10:00 – 10:45",
                                    style = TextStyle(
                                        color = color(Color(0xFF262322)),
                                        fontSize = 11.sp,
                                        fontWeight = FontWeight.Bold
                                    ),
                                    modifier = GlanceModifier.defaultWeight()
                                )
                                Text(
                                    text = "27 min left",
                                    style = TextStyle(
                                        color = color(Color(0xFF262322)),
                                        fontSize = 11.sp,
                                        fontWeight = FontWeight.Bold
                                    )
                                )
                            }
                        }
                    }

                    Spacer(modifier = GlanceModifier.height(10.dp))

                    // Bottom Card: Free · 15 min
                    Box(
                        modifier = GlanceModifier
                            .fillMaxWidth()
                            .height(52.dp)
                            .background(ImageProvider(R.drawable.card_free_bg))
                            .padding(horizontal = 16.dp, vertical = 12.dp)
                            .clickable(launchAppIntent(context)),
                        contentAlignment = Alignment.CenterStart
                    ) {
                        Text(
                            text = "Free · 15 min",
                            style = TextStyle(
                                color = color(Color(0xFF524C47)),
                                fontSize = 12.sp,
                                fontWeight = FontWeight.Medium
                            )
                        )
                    }
                }
            }
        }
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 3. WEEK VIEW (Image 3)
    // ─────────────────────────────────────────────────────────────────────────
    @Composable
    private fun WeekView(
        context: Context,
        weekCalStart: Calendar,
        todayCal: Calendar
    ) {
        Column(
            modifier = GlanceModifier.fillMaxSize()
        ) {
            // Days Row dynamically calculated for the current week
            Row(
                modifier = GlanceModifier.fillMaxWidth(),
                verticalAlignment = Alignment.Vertical.CenterVertically
            ) {
                // Aligns exactly with the 26.dp time column below
                Spacer(modifier = GlanceModifier.width(26.dp))

                val dayNames = listOf("Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun")
                for (i in 0 until 7) {
                    val c = (weekCalStart.clone() as Calendar).apply { add(Calendar.DAY_OF_MONTH, i) }
                    val isToday = c.get(Calendar.YEAR) == todayCal.get(Calendar.YEAR) &&
                            c.get(Calendar.DAY_OF_YEAR) == todayCal.get(Calendar.DAY_OF_YEAR)
                    DayColumnHeader(
                        day = dayNames[i],
                        date = c.get(Calendar.DAY_OF_MONTH).toString(),
                        isToday = isToday
                    )
                }
            }

            Spacer(modifier = GlanceModifier.height(14.dp))

            // Schedule Grid: 5 time rows (9a, 10a, 11a, 12p, 1p) filling the vertical height evenly
            Column(
                modifier = GlanceModifier.fillMaxWidth().defaultWeight()
            ) {
                // 9a row
                WeekGridRow(
                    time = "9a",
                    monContent = { GridBlock("Studio", R.drawable.chip_mint_top_bg, context) },
                    thuContent = { GridBlock("Crit", R.drawable.chip_mint_bg, context) }
                )

                WeekDividerLine(skipColumnIndex = 0, skipFillColor = Color(0xFFBBE0CE)) // Mon continues into 10a

                // 10a row
                WeekGridRow(
                    time = "10a",
                    monContent = { GridBlock("", R.drawable.chip_mint_bottom_bg, context) },
                    tueContent = { GridBlock("Theory", R.drawable.chip_pink_bg, context) },
                    friContent = { GridBlock("Theory", R.drawable.chip_pink_bg, context) }
                )

                WeekDividerLine()

                // 11a row
                WeekGridRow(
                    time = "11a",
                    wedContent = { GridBlock("Lab", R.drawable.chip_peach_top_bg, context) }
                )

                WeekDividerLine(skipColumnIndex = 2, skipFillColor = Color(0xFFEED0A4)) // Wed continues into 12p

                // 12p row
                WeekGridRow(
                    time = "12p",
                    wedContent = { GridBlock("", R.drawable.chip_peach_bottom_bg, context) }
                )

                WeekDividerLine()

                // 1p row
                WeekGridRow(
                    time = "1p",
                    thuContent = { GridBlock("Design", R.drawable.chip_purple_bg, context) },
                    friContent = { GridBlock("Design", R.drawable.chip_purple_bg, context) }
                )
            }
        }
    }

    @Composable
    private fun WeekDividerLine(
        skipColumnIndex: Int? = null,
        skipFillColor: Color? = null
    ) {
        Row(
            modifier = GlanceModifier.fillMaxWidth().height(1.dp),
            verticalAlignment = Alignment.Vertical.CenterVertically
        ) {
            // Time column line
            Box(
                modifier = GlanceModifier
                    .width(26.dp)
                    .height(1.dp)
                    .background(Color(0x1F000000))
            ) {}

            // 7 Day column lines
            for (i in 0 until 7) {
                if (skipColumnIndex == i && skipFillColor != null) {
                    Box(
                        modifier = GlanceModifier
                            .defaultWeight()
                            .fillMaxHeight()
                            .padding(horizontal = 2.dp)
                            .background(skipFillColor)
                    ) {}
                } else if (skipColumnIndex == i) {
                    Spacer(modifier = GlanceModifier.defaultWeight())
                } else {
                    Box(
                        modifier = GlanceModifier
                            .defaultWeight()
                            .height(1.dp)
                            .background(Color(0x1F000000))
                    ) {}
                }
            }
        }
    }

    @Composable
    private fun RowScope.DayColumnHeader(day: String, date: String, isToday: Boolean) {
        Box(
            modifier = GlanceModifier.defaultWeight(),
            contentAlignment = Alignment.Center
        ) {
            if (isToday) {
                Box(
                    modifier = GlanceModifier
                        .background(ImageProvider(R.drawable.day_header_active_bg))
                        .padding(horizontal = 8.dp, vertical = 6.dp),
                    contentAlignment = Alignment.Center
                ) {
                    Column(horizontalAlignment = Alignment.Horizontal.CenterHorizontally) {
                        Text(
                            text = day,
                            style = TextStyle(
                                color = color(Color.White),
                                fontSize = 10.sp,
                                fontWeight = FontWeight.Normal
                            )
                        )
                        Spacer(modifier = GlanceModifier.height(1.dp))
                        Text(
                            text = date,
                            style = TextStyle(
                                color = color(Color.White),
                                fontSize = 13.sp,
                                fontWeight = FontWeight.Bold
                            )
                        )
                    }
                }
            } else {
                Column(horizontalAlignment = Alignment.Horizontal.CenterHorizontally) {
                    Text(
                        text = day,
                        style = TextStyle(
                            color = color(Color(0xFF726E6A)),
                            fontSize = 10.sp,
                            fontWeight = FontWeight.Normal
                        )
                    )
                    Spacer(modifier = GlanceModifier.height(1.dp))
                    Text(
                        text = date,
                        style = TextStyle(
                            color = color(Color(0xFF181818)),
                            fontSize = 13.sp,
                            fontWeight = FontWeight.Bold
                        )
                    )
                }
            }
        }
    }

    @Composable
    private fun ColumnScope.WeekGridRow(
        time: String,
        monContent: (@Composable () -> Unit)? = null,
        tueContent: (@Composable () -> Unit)? = null,
        wedContent: (@Composable () -> Unit)? = null,
        thuContent: (@Composable () -> Unit)? = null,
        friContent: (@Composable () -> Unit)? = null,
        satContent: (@Composable () -> Unit)? = null,
        sunContent: (@Composable () -> Unit)? = null
    ) {
        Row(
            modifier = GlanceModifier.fillMaxWidth().defaultWeight(),
            verticalAlignment = Alignment.Vertical.CenterVertically
        ) {
            // Time column (width 26.dp)
            Text(
                text = time,
                style = TextStyle(
                    color = color(Color(0xFF726E6A)),
                    fontSize = 11.sp,
                    fontWeight = FontWeight.Medium
                ),
                modifier = GlanceModifier.width(26.dp)
            )

            // 7 Day slot cells
            GridCell(monContent)
            GridCell(tueContent)
            GridCell(wedContent)
            GridCell(thuContent)
            GridCell(friContent)
            GridCell(satContent)
            GridCell(sunContent)
        }
    }

    @Composable
    private fun RowScope.GridCell(content: (@Composable () -> Unit)?) {
        Box(
            modifier = GlanceModifier.defaultWeight().fillMaxHeight().padding(horizontal = 2.dp),
            contentAlignment = Alignment.Center
        ) {
            content?.invoke()
        }
    }

    @Composable
    private fun GridBlock(
        label: String,
        bgRes: Int,
        context: Context,
        alignment: Alignment = Alignment.TopStart
    ) {
        Box(
            modifier = GlanceModifier
                .fillMaxSize()
                .background(ImageProvider(bgRes))
                .clickable(launchAppIntent(context))
                .padding(start = 5.dp, top = 5.dp),
            contentAlignment = alignment
        ) {
            if (label.isNotEmpty()) {
                Text(
                    text = label,
                    style = TextStyle(
                        color = color(Color(0xFF181818)),
                        fontSize = 10.sp,
                        fontWeight = FontWeight.Bold
                    )
                )
            }
        }
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 4. MONTH VIEW (Bonus / Complete experience)
    // ─────────────────────────────────────────────────────────────────────────
    @Composable
    private fun MonthView(
        context: Context,
        entries: List<GlanceTimetableEntry>,
        todayKey: String,
        todayCal: Calendar
    ) {
        Column(
            modifier = GlanceModifier.fillMaxSize()
        ) {
            // Day names row
            Row(
                modifier = GlanceModifier.fillMaxWidth(),
                verticalAlignment = Alignment.Vertical.CenterVertically
            ) {
                listOf("Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun").forEach { day ->
                    Box(modifier = GlanceModifier.defaultWeight(), contentAlignment = Alignment.Center) {
                        Text(day, style = TextStyle(color = color(Color(0xFF726E6A)), fontSize = 10.sp, fontWeight = FontWeight.Medium))
                    }
                }
            }

            Spacer(modifier = GlanceModifier.height(8.dp))

            // Calendar rows
            val weeks = listOf(
                listOf("25", "26", "27", "28", "29", "30", "31"),
                listOf("1", "2", "3", "4", "5", "6", "7"),
                listOf("8", "9", "10", "11", "12", "13", "14"),
                listOf("15", "16", "17", "18", "19", "20", "21")
            )
            val todayDateStr = todayCal.get(Calendar.DAY_OF_MONTH).toString()

            weeks.forEach { week ->
                Row(
                    modifier = GlanceModifier.fillMaxWidth().defaultWeight(),
                    verticalAlignment = Alignment.Vertical.CenterVertically
                ) {
                    week.forEach { date ->
                        val isToday = date == todayDateStr
                        Box(
                            modifier = GlanceModifier.defaultWeight(),
                            contentAlignment = Alignment.Center
                        ) {
                            if (isToday) {
                                Box(
                                    modifier = GlanceModifier
                                        .background(ImageProvider(R.drawable.badge_now_bg))
                                        .padding(horizontal = 7.dp, vertical = 3.dp),
                                    contentAlignment = Alignment.Center
                                ) {
                                    Text(
                                        date,
                                        style = TextStyle(color = color(Color.White), fontSize = 11.sp, fontWeight = FontWeight.Bold)
                                    )
                                }
                            } else {
                                Text(
                                    date,
                                    style = TextStyle(
                                        color = color(if (date.toIntOrNull() != null && date.toInt() > 20 && week == weeks[0]) Color(0xFFB0AAA4) else Color(0xFF262322)),
                                        fontSize = 11.sp,
                                        fontWeight = FontWeight.Medium
                                    )
                                )
                            }
                        }
                    }
                }
            }

            Spacer(modifier = GlanceModifier.height(10.dp))

            // Upcoming Exam / Event summary card
            val todayEntry = entries.firstOrNull { it.day == todayKey } ?: entries.firstOrNull()
            val cardTitle = todayEntry?.subject ?: "Theory Test"
            val cardSubtitle = if (todayEntry != null) "${todayEntry.startTime} – ${todayEntry.endTime}" else "10:00 – 11:00 AM"
            val cardRoom = todayEntry?.room?.ifEmpty { "Room 244" } ?: "Room 244"
            val cardBg = if (todayEntry != null) getCardDrawable(todayEntry.colorCode, todayEntry.subject) else R.drawable.card_pink_bg

            Box(
                modifier = GlanceModifier
                    .fillMaxWidth()
                    .height(56.dp)
                    .background(ImageProvider(cardBg))
                    .padding(horizontal = 14.dp, vertical = 10.dp)
                    .clickable(launchAppIntent(context)),
                contentAlignment = Alignment.CenterStart
            ) {
                Row(
                    modifier = GlanceModifier.fillMaxWidth(),
                    verticalAlignment = Alignment.Vertical.CenterVertically
                ) {
                    Column(modifier = GlanceModifier.defaultWeight()) {
                        Text(
                            text = cardTitle,
                            style = TextStyle(
                                color = color(Color(0xFF181818)),
                                fontSize = 15.sp,
                                fontWeight = FontWeight.Bold
                            )
                        )
                        Text(
                            text = cardSubtitle,
                            style = TextStyle(
                                color = color(Color(0xFF42383D)),
                                fontSize = 11.sp
                            )
                        )
                    }

                    Box(
                        modifier = GlanceModifier
                            .background(ImageProvider(R.drawable.badge_room_bg))
                            .padding(horizontal = 10.dp, vertical = 5.dp),
                        contentAlignment = Alignment.Center
                    ) {
                        Text(
                            text = cardRoom,
                            style = TextStyle(
                                color = color(Color(0xFF262322)),
                                fontSize = 11.sp,
                                fontWeight = FontWeight.Bold
                            )
                        )
                    }
                }
            }
        }
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// Interactive Action Callbacks
// ─────────────────────────────────────────────────────────────────────────────
class SwitchTabAction : ActionCallback {
    override suspend fun onAction(
        context: Context,
        glanceId: GlanceId,
        parameters: ActionParameters
    ) {
        val tab = parameters[TabActionKey] ?: "day"
        val prefs = context.getSharedPreferences("HomeWidgetPreferences", Context.MODE_PRIVATE)
        prefs.edit().putString("active_tab", tab).apply()

        // Immediately update the tapped widget instance
        updateAppWidgetState<HomeWidgetGlanceState>(
            context = context,
            definition = HomeWidgetGlanceStateDefinition(),
            glanceId = glanceId
        ) {
            HomeWidgetGlanceState(prefs)
        }
        TimetableGlanceAppWidget().update(context, glanceId)

        // Update any other widget instances
        try {
            val manager = GlanceAppWidgetManager(context)
            val glanceIds = manager.getGlanceIds(TimetableGlanceAppWidget::class.java)
            glanceIds.filter { it != glanceId }.forEach { id ->
                updateAppWidgetState<HomeWidgetGlanceState>(
                    context = context,
                    definition = HomeWidgetGlanceStateDefinition(),
                    glanceId = id
                ) {
                    HomeWidgetGlanceState(prefs)
                }
                TimetableGlanceAppWidget().update(context, id)
            }
        } catch (_: Exception) {}
    }
}

class NavigateHourAction : ActionCallback {
    override suspend fun onAction(
        context: Context,
        glanceId: GlanceId,
        parameters: ActionParameters
    ) {
        val delta = parameters[DeltaActionKey] ?: 0
        val prefs = context.getSharedPreferences("HomeWidgetPreferences", Context.MODE_PRIVATE)
        val current = prefs.getInt("hour_offset", 0)
        val newOffset = (current + delta).coerceIn(-5, 5)
        prefs.edit().putInt("hour_offset", newOffset).apply()

        // Immediately update the tapped widget instance
        updateAppWidgetState<HomeWidgetGlanceState>(
            context = context,
            definition = HomeWidgetGlanceStateDefinition(),
            glanceId = glanceId
        ) {
            HomeWidgetGlanceState(prefs)
        }
        TimetableGlanceAppWidget().update(context, glanceId)

        // Update any other widget instances
        try {
            val manager = GlanceAppWidgetManager(context)
            val glanceIds = manager.getGlanceIds(TimetableGlanceAppWidget::class.java)
            glanceIds.filter { it != glanceId }.forEach { id ->
                updateAppWidgetState<HomeWidgetGlanceState>(
                    context = context,
                    definition = HomeWidgetGlanceStateDefinition(),
                    glanceId = id
                ) {
                    HomeWidgetGlanceState(prefs)
                }
                TimetableGlanceAppWidget().update(context, id)
            }
        } catch (_: Exception) {}
    }
}
