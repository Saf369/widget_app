import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/schedule.dart';

const List<String> _months = [
  '', 'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'
];

const List<String> _weekDaysFull = [
  '', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
];

const List<String> _weekDaysShort = [
  '', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'
];

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  DateTime _currentMonth = DateTime.now();
  DateTime _selectedDate = DateTime.now();

  void _changeMonth(int offset) {
    setState(() {
      int newMonth = _currentMonth.month + offset;
      int newYear = _currentMonth.year;
      if (newMonth > 12) {
        newMonth -= 12;
        newYear++;
      } else if (newMonth < 1) {
        newMonth += 12;
        newYear--;
      }
      _currentMonth = DateTime(newYear, newMonth);
    });
  }

  void _selectDate(DateTime date) {
    setState(() {
      _selectedDate = date;
      if (date.month != _currentMonth.month || date.year != _currentMonth.year) {
        _currentMonth = DateTime(date.year, date.month);
      }
    });
  }

  String _getShortDayName(int weekday) {
    // 1 = Monday, 7 = Sunday
    switch (weekday) {
      case 1: return 'MON';
      case 2: return 'TUE';
      case 3: return 'WED';
      case 4: return 'THUR';
      case 5: return 'FRI';
      case 6: return 'SAT';
      case 7: return 'SUN';
      default: return 'MON';
    }
  }

  List<TimetableEntry> _getEntriesForDate(DateTime date) {
    String shortName = _getShortDayName(date.weekday);
    return globalTimetable.where((e) => e.day.toUpperCase() == shortName).toList();
  }

  @override
  Widget build(BuildContext context) {
    final todaysEntries = _getEntriesForDate(_selectedDate);

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF7F6F2),
        borderRadius: BorderRadius.all(Radius.circular(44)),
      ),
      child: CustomScrollView(
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: _ScheduleHeaderDelegate(
              currentMonth: _currentMonth,
              selectedDate: _selectedDate,
              onChangeMonth: _changeMonth,
              onSelectDate: _selectDate,
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 120),
            sliver: todaysEntries.isEmpty 
              ? SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(40.0),
                      child: Text(
                        "No classes today",
                        style: GoogleFonts.urbanist(
                          color: Colors.grey,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                )
              : SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final entry = todaysEntries[index];
                      // split "10:30" into "10:30" and "" or just use the start time directly
                      String timeLabel = entry.startTime.replaceAll(RegExp(r'[a-zA-Z\s]'), '');
                      String suffix = entry.startTime.toUpperCase().contains('PM') ? 'PM' : 'AM';
                      
                      // If no AM/PM, try to guess
                      if (!entry.startTime.toUpperCase().contains('AM') && !entry.startTime.toUpperCase().contains('PM')) {
                         int hour = int.tryParse(timeLabel.split(':').first) ?? 0;
                         if (hour >= 1 && hour <= 6) {
                           suffix = 'PM'; // roughly afternoon
                         } else {
                           suffix = 'AM';
                         }
                      }

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 24.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _TimeLabel(label: timeLabel, suffix: suffix),
                            const SizedBox(width: 16),
                            Expanded(child: _DynamicClassCard(entry: entry)),
                          ],
                        ),
                      );
                    },
                    childCount: todaysEntries.length,
                  ),
                ),
          ),
        ],
      ),
    );
  }
}

class _DynamicClassCard extends StatelessWidget {
  final TimetableEntry entry;
  const _DynamicClassCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    // Generate a color based on subject name
    final colors = [
      const Color(0xFFE9CCAA), // Yellow
      const Color(0xFFD7A1A7), // Pink
      const Color(0xFFBDE4C9), // Green
      const Color(0xFFC4B9DC), // Purple
      const Color(0xFFB5E2FA), // Light Blue
    ];
    int colorIndex = entry.subject.length % colors.length;
    Color bgColor = colors[colorIndex];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                entry.subject,
                style: GoogleFonts.urbanist(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.5,
                  color: const Color(0xFF111315),
                ),
              ),
              const Icon(Icons.more_horiz, color: Color(0xFF111315)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.access_time, size: 16, color: Color(0xFF111315)),
              const SizedBox(width: 6),
              Text(
                '${entry.startTime} - ${entry.endTime}',
                style: GoogleFonts.urbanist(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF111315).withOpacity(0.8),
                ),
              ),
            ],
          ),
          if (entry.room.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 16, color: Color(0xFF111315)),
                const SizedBox(width: 6),
                Text(
                  entry.room,
                  style: GoogleFonts.urbanist(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF111315).withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ]
        ],
      ),
    );
  }
}

class _ScheduleHeaderDelegate extends SliverPersistentHeaderDelegate {
  final DateTime currentMonth;
  final DateTime selectedDate;
  final void Function(int) onChangeMonth;
  final void Function(DateTime) onSelectDate;

  _ScheduleHeaderDelegate({
    required this.currentMonth,
    required this.selectedDate,
    required this.onChangeMonth,
    required this.onSelectDate,
  });

  @override
  double get maxExtent => 535.0;

  @override
  double get minExtent => 240.0;

  @override
  bool shouldRebuild(covariant _ScheduleHeaderDelegate oldDelegate) {
    return oldDelegate.currentMonth != currentMonth || oldDelegate.selectedDate != selectedDate;
  }

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final progress = shrinkOffset / (maxExtent - minExtent);
    final percent = progress.clamp(0.0, 1.0);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        border: Border.all(color: const Color(0xFFF1F5F9).withOpacity(0.8), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 40,
            offset: const Offset(0, 20),
            spreadRadius: -15,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 1,
            spreadRadius: 1,
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top fixed part
              _buildTopBar(context),
              
              const SizedBox(height: 28),
              
              // Animated calendar body
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Expanded Month View
                    if (percent < 1.0)
                      Opacity(
                        opacity: (1 - percent).clamp(0.0, 1.0),
                        child: IgnorePointer(
                          ignoring: percent > 0.0,
                          child: Transform.translate(
                            offset: Offset(0, -40 * percent),
                            child: OverflowBox(
                              alignment: Alignment.topCenter,
                              maxHeight: double.infinity,
                              child: _ExpandedMonthCalendar(
                                currentMonth: currentMonth,
                                selectedDate: selectedDate,
                                onSelectDate: onSelectDate,
                              ),
                            ),
                          ),
                        ),
                      ),
                    // Collapsed Week View
                    if (percent > 0.0)
                      Opacity(
                        opacity: percent.clamp(0.0, 1.0),
                        child: IgnorePointer(
                          ignoring: percent < 1.0,
                          child: Transform.translate(
                            offset: Offset(0, 40 * (1 - percent)),
                            child: OverflowBox(
                              alignment: Alignment.topCenter,
                              maxHeight: double.infinity,
                              child: _buildWeekRow(),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 16),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),
              const SizedBox(height: 16),
              
              // Bottom status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFF111315),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${_weekDaysFull[selectedDate.weekday]}, ${_months[selectedDate.month]} ${selectedDate.day}, ${selectedDate.year}',
                        style: GoogleFonts.urbanist(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF111315),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'SELECTED',
                    style: GoogleFonts.urbanist(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.0,
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Row(
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: () => onChangeMonth(-1),
              child: const Icon(Icons.chevron_left, color: Color(0xFF111315), size: 28),
            ),
            const SizedBox(width: 8),
            Text(
              '${_months[currentMonth.month]}, ${currentMonth.year}',
              style: GoogleFonts.urbanist(
                fontSize: 32,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF111315),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => onChangeMonth(1),
              child: const Icon(Icons.chevron_right, color: Color(0xFF111315), size: 28),
            ),
          ],
        ),
        const Spacer(),
        GestureDetector(
          onTap: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => Padding(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 40,
                ),
                child: const _NewScheduleSheet(),
              ),
            );
          },
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFFFAFAFA),
              shape: BoxShape.circle,
              border: Border.all(
                  color: const Color(0xFFECECED), width: 1.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(Icons.add,
                color: Color(0xFF111315), size: 24),
          ),
        ),
      ],
    );
  }

  Widget _buildWeekRow() {
    int daysToSubtract = selectedDate.weekday - 1;
    DateTime startOfWeek = selectedDate.subtract(Duration(days: daysToSubtract));

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (index) {
        DateTime date = startOfWeek.add(Duration(days: index));
        bool isActive = date.year == selectedDate.year && date.month == selectedDate.month && date.day == selectedDate.day;
        
        return GestureDetector(
          onTap: () => onSelectDate(date),
          child: _DayCell(
            day: _weekDaysShort[date.weekday],
            date: date.day.toString(),
            isActive: isActive,
          ),
        );
      }),
    );
  }
}


class _DayCell extends StatelessWidget {
  final String day;
  final String date;
  final bool isActive;
  const _DayCell({required this.day, required this.date, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 56, // aspect 1/1.22
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF111315) : const Color(0xFFF2F3F4),
        borderRadius: BorderRadius.circular(26),
        boxShadow: isActive ? [
          BoxShadow(
            color: const Color(0xFF111315).withOpacity(0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
            spreadRadius: -2,
          )
        ] : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            day,
            style: GoogleFonts.urbanist(
              fontSize: 12,
              fontWeight: isActive ? FontWeight.w500 : FontWeight.w400,
              color: isActive ? Colors.white.withOpacity(0.9) : const Color(0xFF65696E),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            date,
            style: GoogleFonts.urbanist(
              fontSize: 19,
              fontWeight: FontWeight.w400,
              height: 1.0,
              color: isActive ? Colors.white : const Color(0xFF111315),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimeLabel extends StatelessWidget {
  final String label;
  final String suffix;
  const _TimeLabel({required this.label, required this.suffix});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: GoogleFonts.urbanist(
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF202020))),
          Text(suffix,
              style: GoogleFonts.urbanist(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  color: const Color(0xFF9CA3AF))),
        ],
      ),
    );
  }
}



class _ExpandedMonthCalendar extends StatelessWidget {
  final DateTime currentMonth;
  final DateTime selectedDate;
  final void Function(DateTime) onSelectDate;

  const _ExpandedMonthCalendar({
    required this.currentMonth,
    required this.selectedDate,
    required this.onSelectDate,
  });

  @override
  Widget build(BuildContext context) {
    final daysOfWeek = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    
    final firstDayOfMonth = DateTime(currentMonth.year, currentMonth.month, 1);
    final daysToSubtract = firstDayOfMonth.weekday - 1; // Mon=1 -> 0
    final startDate = firstDayOfMonth.subtract(Duration(days: daysToSubtract));
    
    final dates = List.generate(42, (index) => startDate.add(Duration(days: index)));

    return Column(
      children: [
        // Days of week header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: daysOfWeek.map((day) {
            return SizedBox(
              width: 42,
              child: Center(
                child: Text(
                  day,
                  style: GoogleFonts.urbanist(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF94A3B8), // Gray
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        // Grid of dates
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 1.1, // Even shorter to aggressively save vertical space
          ),
          itemCount: 42,
          itemBuilder: (context, index) {
            final date = dates[index];
            final isNextMonth = date.month != currentMonth.month;
            final isSelected = date.year == selectedDate.year && date.month == selectedDate.month && date.day == selectedDate.day;
            
            // Determine events randomly for visual
            List<Color> events = [];
            if (!isNextMonth) {
              if (date.day % 7 == 3) events = [const Color(0xFFBDE4C9)]; // Green
              if (date.day % 5 == 1) events = [const Color(0xFFD7A1A7)]; // Pink
              if (date.day % 8 == 2) events = [const Color(0xFFE9CCAA)]; // Yellow
              if (date.day % 4 == 0) events = [const Color(0xFFC4B9DC)]; // Purple
              if (date.day == 14) events = [const Color(0xFFD7A1A7), const Color(0xFFC4B9DC)];
            }

            return GestureDetector(
              onTap: () => onSelectDate(date),
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF111315) : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: isSelected ? [
                    BoxShadow(
                      color: const Color(0xFF111315).withOpacity(0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    )
                  ] : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      date.day.toString(),
                      style: GoogleFonts.urbanist(
                        fontSize: 16,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                        color: isNextMonth 
                            ? const Color(0xFFCBD5E1) 
                            : isSelected ? Colors.white : const Color(0xFF111315),
                      ),
                    ),
                    if (events.isNotEmpty) const SizedBox(height: 6),
                    if (events.isNotEmpty)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: events.map((color) => Container(
                          width: 14,
                          height: 4,
                          margin: const EdgeInsets.symmetric(horizontal: 1.5),
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        )).toList(),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 8),
        // Legend
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _LegendItem(color: Color(0xFFD7A1A7), label: 'Theory'),
            SizedBox(width: 16),
            _LegendItem(color: Color(0xFFC4B9DC), label: 'Design'),
            SizedBox(width: 16),
            _LegendItem(color: Color(0xFFBDE4C9), label: 'Studio'),
            SizedBox(width: 16),
            _LegendItem(color: Color(0xFFE9CCAA), label: 'Lab'),
          ],
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  
  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.urbanist(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF64748B),
          ),
        ),
      ],
    );
  }
}

class _NewScheduleSheet extends StatefulWidget {
  const _NewScheduleSheet();

  @override
  State<_NewScheduleSheet> createState() => _NewScheduleSheetState();
}

class _NewScheduleSheetState extends State<_NewScheduleSheet> {
  int _selectedColorIndex = 0;
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  
  final _colors = [
    {'name': 'Theory', 'color': const Color(0xFFD7A1A7)},
    {'name': 'Design', 'color': const Color(0xFFC4B9DC)},
    {'name': 'Studio', 'color': const Color(0xFFBDE4C9)},
    {'name': 'Lab', 'color': const Color(0xFFE9CCAA)},
  ];

  @override
  void dispose() {
    _dateController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF111315),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      final monthStr = _months[picked.month].substring(0, 3);
      final dayStr = _weekDaysShort[picked.weekday];
      setState(() {
        _dateController.text = "$dayStr, ${picked.day} $monthStr ${picked.year}";
      });
    }
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final min = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return "$hour:$min $period";
  }

  Future<void> _selectTime() async {
    final TimeOfDay? start = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF111315),
            ),
          ),
          child: child!,
        );
      },
    );
    if (start != null) {
      if (!mounted) return;
      final TimeOfDay? end = await showTimePicker(
        context: context,
        initialTime: TimeOfDay(hour: (start.hour + 1) % 24, minute: start.minute),
        helpText: 'SELECT END TIME',
        builder: (context, child) {
          return Theme(
            data: ThemeData.light().copyWith(
              colorScheme: const ColorScheme.light(
                primary: Color(0xFF111315),
              ),
            ),
            child: child!,
          );
        },
      );
      setState(() {
        if (end != null) {
          _timeController.text = "${_formatTime(start)} – ${_formatTime(end)}";
        } else {
          _timeController.text = _formatTime(start);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF7F6F2),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(32),
                topRight: Radius.circular(32),
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                )
              ]
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('New Schedule', style: GoogleFonts.urbanist(fontSize: 28, fontWeight: FontWeight.w500, color: const Color(0xFF111315))),
                    const SizedBox(height: 4),
                    Text('Add a class, test or session', style: GoogleFonts.urbanist(fontSize: 14, color: const Color(0xFF94A3B8))),
                  ],
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: const Icon(Icons.close, color: Color(0xFF111315)),
                  ),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('TITLE'),
                  _buildTextField(hint: 'Theory Test'),
                  const SizedBox(height: 20),
                  
                  _buildLabel('DESCRIPTION'),
                  _buildTextField(hint: 'Covers main ideas and principles from the Design Theory topic.', maxLines: 3),
                  const SizedBox(height: 20),
                  
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('DATE'),
                            _buildTextField(
                              hint: 'Fri, 14 Jun 2026',
                              controller: _dateController,
                              readOnly: true,
                              onTap: _selectDate,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('TIME'),
                            _buildTextField(
                              hint: '10:00 – 11:00 AM',
                              controller: _timeController,
                              readOnly: true,
                              onTap: _selectTime,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('ROOM'),
                            _buildTextField(hint: '244'),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('POINTS'),
                            _buildTextField(hint: '40'),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  _buildLabel('COLOR'),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(_colors.length, (index) {
                      final isSelected = _selectedColorIndex == index;
                      final item = _colors[index];
                      return GestureDetector(
                        onTap: () => setState(() => _selectedColorIndex = index),
                        child: Column(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: item['color'] as Color,
                                shape: BoxShape.circle,
                                border: isSelected 
                                    ? Border.all(color: const Color(0xFF111315), width: 2) 
                                    : Border.all(color: Colors.white, width: 2),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              item['name'] as String,
                              style: GoogleFonts.urbanist(
                                fontSize: 13,
                                color: const Color(0xFF5A5A60),
                              ),
                            )
                          ],
                        ),
                      );
                    }),
                  ),
                  
                  const SizedBox(height: 48),
                  
                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF111315),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                        elevation: 0,
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Save Schedule',
                        style: GoogleFonts.urbanist(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        text,
        style: GoogleFonts.urbanist(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.0,
          color: const Color(0xFF94A3B8),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String hint, 
    int maxLines = 1,
    bool readOnly = false,
    VoidCallback? onTap,
    TextEditingController? controller,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        readOnly: readOnly,
        onTap: onTap,
        style: GoogleFonts.urbanist(fontSize: 15, color: const Color(0xFF111315)),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.urbanist(fontSize: 15, color: const Color(0xFF94A3B8)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
