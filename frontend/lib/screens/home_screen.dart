import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/schedule.dart';
import 'upload_timetable_screen.dart';

// ── Models & Helpers ──────────────────────────────────────────────────────

String _formatDate(DateTime date) {
  const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  const weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
  return '${weekdays[date.weekday - 1]},\n${date.day} ${months[date.month - 1]}';
}

String _shortWeekday(int weekday) {
  const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  return days[weekday - 1];
}

String _formatTime(DateTime time) {
  final h = time.hour > 12 ? time.hour - 12 : (time.hour == 0 ? 12 : time.hour);
  final m = time.minute.toString().padLeft(2, '0');
  final ampm = time.hour >= 12 ? 'PM' : 'AM';
  return '$h:$m $ampm';
}

Color _hexToColor(String hexStr, int index) {
  try {
    String clean = hexStr.replaceAll('#', '').replaceAll('0x', '').replaceAll('0X', '');
    if (clean.length == 6) clean = 'FF$clean';
    return Color(int.parse(clean, radix: 16));
  } catch (_) {
    final colors = [
      const Color(0xFFE8CACF),
      const Color(0xFFCDE6E2),
      const Color(0xFFDBD3EE),
      const Color(0xFFEFCCB8),
      const Color(0xFFE9CCAA),
      const Color(0xFFBDE4C9),
      const Color(0xFFB5E2FA),
    ];
    return colors[index % colors.length];
  }
}

Color _darkenColor(Color c) {
  final hsl = HSLColor.fromColor(c);
  return hsl.withLightness((hsl.lightness - 0.15).clamp(0.0, 1.0)).toColor();
}

IconData _iconForSubject(String subject) {
  final s = subject.toLowerCase();
  if (s.contains('math') || s.contains('calc') || s.contains('algebra')) return Icons.functions_rounded;
  if (s.contains('code') || s.contains('cs') || s.contains('prog') || s.contains('comp')) return Icons.code_rounded;
  if (s.contains('art') || s.contains('design') || s.contains('visual')) return Icons.brush_rounded;
  if (s.contains('music')) return Icons.music_note_rounded;
  if (s.contains('hist')) return Icons.history_edu_rounded;
  if (s.contains('science') || s.contains('chem') || s.contains('bio') || s.contains('phy')) return Icons.science_rounded;
  if (s.contains('geo')) return Icons.public_rounded;
  if (s.contains('lang') || s.contains('eng') || s.contains('lote')) return Icons.translate_rounded;
  if (s.contains('drama') || s.contains('theater')) return Icons.theater_comedy_rounded;
  return Icons.school_rounded;
}

class Course {
  final String title;
  final String subtitle;
  final DateTime startTime;
  final DateTime endTime;
  final String room;
  final Color color;
  final Color iconColor;
  final IconData icon;

  Course(this.title, this.subtitle, this.startTime, this.endTime, this.room, this.color, this.iconColor, this.icon);

  bool isHappeningNow(DateTime now) => now.isAfter(startTime) && now.isBefore(endTime);
  bool isCompleted(DateTime now) => now.isAfter(endTime);
  bool isUpcoming(DateTime now) => now.isBefore(startTime);

  double progress(DateTime now) {
    if (now.isBefore(startTime)) return 0.0;
    if (now.isAfter(endTime)) return 1.0;
    final totalSec = endTime.difference(startTime).inSeconds;
    if (totalSec <= 0) return 1.0;
    final elapsedSec = now.difference(startTime).inSeconds;
    return (elapsedSec / totalSec).clamp(0.0, 1.0);
  }

  int minutesRemaining(DateTime now) {
    if (now.isAfter(endTime)) return 0;
    return endTime.difference(now).inMinutes;
  }
}

// ── Screen ────────────────────────────────────────────────────────────────

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late DateTime _selectedDate;
  late Timer _timer;
  bool _hasTimetable = true; 

  List<Course> _allCourses = [];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);
    
    _refreshCourses();
    timetableNotifier.addListener(_onTimetableChanged);

    _timer = Timer.periodic(const Duration(seconds: 15), (timer) {
      if (mounted) setState(() {});
    });
  }

  void _onTimetableChanged() {
    if (mounted) {
      setState(() {
        _refreshCourses();
      });
    }
  }

  void _refreshCourses() {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final Map<String, DateTime> dayToDate = {
      'MON': DateTime(monday.year, monday.month, monday.day),
      'TUE': DateTime(monday.year, monday.month, monday.day + 1),
      'WED': DateTime(monday.year, monday.month, monday.day + 2),
      'THUR': DateTime(monday.year, monday.month, monday.day + 3),
      'FRI': DateTime(monday.year, monday.month, monday.day + 4),
      'SAT': DateTime(monday.year, monday.month, monday.day + 5),
      'SUN': DateTime(monday.year, monday.month, monday.day + 6),
    };

    if (globalTimetable.isEmpty) {
      _hasTimetable = false;
      _allCourses = [];
      return;
    }

    _hasTimetable = true;
    final List<Course> built = [];

    for (int i = 0; i < globalTimetable.length; i++) {
      final entry = globalTimetable[i];
      final targetDate = dayToDate[TimetableEntry.normalizeDay(entry.day)] ?? dayToDate['MON']!;
      final start = entry.startDateTime(targetDate);
      final end = entry.endDateTime(targetDate);

      final color = _hexToColor(entry.colorCode, i);
      final iconColor = _darkenColor(color);
      final icon = _iconForSubject(entry.subject);
      final subtitle = entry.instructor.isNotEmpty ? entry.instructor : (entry.room.isNotEmpty ? entry.room : 'Scheduled Class');

      built.add(Course(
        entry.subject,
        subtitle,
        start,
        end,
        entry.room.isNotEmpty ? entry.room : 'Main Hall',
        color,
        iconColor,
        icon,
      ));
    }

    _allCourses = built;
  }

  @override
  void dispose() {
    timetableNotifier.removeListener(_onTimetableChanged);
    _timer.cancel();
    super.dispose();
  }

  List<Course> get _currentDayCourses {
    return _allCourses.where((c) => 
      c.startTime.year == _selectedDate.year && 
      c.startTime.month == _selectedDate.month && 
      c.startTime.day == _selectedDate.day).toList()..sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  Course? get _currentHappeningCourse {
    final now = DateTime.now();
    final todayCourses = _allCourses.where((c) => 
      c.startTime.year == now.year && 
      c.startTime.month == now.month && 
      c.startTime.day == now.day).toList()..sort((a, b) => a.startTime.compareTo(b.startTime));
      
    for (var course in todayCourses) {
      if (course.isHappeningNow(now)) {
        return course;
      }
    }
    return null;
  }

  Course? get _nextUpcomingCourse {
    final now = DateTime.now();
    final todayCourses = _allCourses.where((c) => 
      c.startTime.year == now.year && 
      c.startTime.month == now.month && 
      c.startTime.day == now.day).toList()..sort((a, b) => a.startTime.compareTo(b.startTime));
      
    for (var course in todayCourses) {
      if (course.isUpcoming(now)) {
        return course;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isToday = _selectedDate.year == now.year && _selectedDate.month == now.month && _selectedDate.day == now.day;
    final todayCourses = _currentDayCourses;
    final currentCourse = _currentHappeningCourse;
    final nextCourse = _nextUpcomingCourse;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFDCD5E6), Color(0xFFF3F0EE), Color(0xFFEEEBE8)],
          stops: [0.0, 0.5, 1.0],
        ),
        borderRadius: BorderRadius.all(Radius.circular(44)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SizedBox(
            height: constraints.maxHeight,
            child: Stack(
              children: [
                // Background blur ellipses
                Positioned(
                  right: -105,
                  top: -170,
                  child: Container(
                    width: 330,
                    height: 420,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFA8A2B2).withOpacity(0.26),
                    ),
                  ),
                ),
                Positioned(
                  right: -80,
                  top: 40,
                  child: Container(
                    width: 200,
                    height: 420,
                    decoration: BoxDecoration(
                      color: const Color(0xFFBDB8C4).withOpacity(0.14),
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                    child: const SizedBox(),
                  ),
                ),
                CustomScrollView(
                  physics: const ClampingScrollPhysics(),
                  slivers: [
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: _HomeHeaderDelegate(
                        selectedDate: _selectedDate,
                        onDateSelected: (date) {
                          setState(() {
                            _selectedDate = date;
                          });
                        },
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.only(top: 24, bottom: 120),
                      sliver: SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (!_hasTimetable)
                              _buildFirstLaunch()
                            else ...[
                              if (isToday) ...[
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 22),
                                  child: _buildHeroPeriodCard(currentCourse, nextCourse, todayCourses),
                                ),
                                const SizedBox(height: 24),
                              ],
                              
                              if (todayCourses.isEmpty)
                                _buildEmptyState()
                              else
                                _buildScheduleList(todayCourses, isToday: isToday),

                              const SizedBox(height: 24),
                              
                              if (isToday)
                                _buildTomorrowPreview(),
                            ],
                            const SizedBox(height: 40),
                            _buildQuickActions(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFirstLaunch() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFFCEC1DE),
          borderRadius: BorderRadius.circular(36),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'No Timetable Yet',
              style: GoogleFonts.urbanist(fontSize: 24, fontWeight: FontWeight.w600, color: const Color(0xFF17141E)),
            ),
            const SizedBox(height: 12),
            Text(
              'Upload your PDF or PNG syllabus to generate your daily schedule instantly.',
              style: GoogleFonts.urbanist(fontSize: 15, color: const Color(0xFF5F5370), height: 1.4),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UploadTimetableScreen(
                            onUpload: () => Navigator.pop(context),
                            onSkip: () => Navigator.pop(context),
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF18151F),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    child: Text('Upload Timetable', style: GoogleFonts.urbanist(fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Center(
              child: TextButton(
                onPressed: () {
                  setState(() => _hasTimetable = true);
                },
                child: Text('Add manually', style: GoogleFonts.urbanist(color: const Color(0xFF4F4362), fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
      child: Center(
        child: Column(
          children: [
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.5), shape: BoxShape.circle),
              child: const Icon(Icons.celebration_rounded, size: 40, color: Color(0xFF6E5A62)),
            ),
            const SizedBox(height: 16),
            Text(
              'No classes!',
              style: GoogleFonts.urbanist(fontSize: 20, fontWeight: FontWeight.w600, color: const Color(0xFF141414)),
            ),
            const SizedBox(height: 8),
            Text(
              'Enjoy your free time.',
              style: GoogleFonts.urbanist(fontSize: 15, color: const Color(0xFF6E5A62)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroPeriodCard(Course? currentCourse, Course? nextCourse, List<Course> todayCourses) {
    final now = DateTime.now();
    if (currentCourse != null) {
      return _CurrentClassExpandedCard(
        course: currentCourse,
        nextCourse: nextCourse,
        now: now,
      );
    } else if (nextCourse != null) {
      return _UpcomingClassCard(
        course: nextCourse,
        now: now,
      );
    } else if (todayCourses.isNotEmpty) {
      return _AllClassesCompletedCard(
        totalCount: todayCourses.length,
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildScheduleList(List<Course> courses, {bool isToday = false}) {
    List<Widget> children = [];
    final now = DateTime.now();
    for (int i = 0; i < courses.length; i++) {
      final isNow = isToday && courses[i].isHappeningNow(now);
      final isPast = isToday && courses[i].isCompleted(now);

      children.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 4),
          child: _CourseRow(
            course: courses[i],
            isCurrent: isNow,
            faded: isPast,
          ),
        ),
      );

      // Check for gaps
      if (i < courses.length - 1) {
        final gap = courses[i+1].startTime.difference(courses[i].endTime);
        if (gap.inMinutes > 0) {
          final h = gap.inHours;
          final m = gap.inMinutes % 60;
          final durationText = '${h > 0 ? '${h}h ' : ''}${m}m'.trim();
          final timeRangeText = '${_formatTime(courses[i].endTime)} - ${_formatTime(courses[i+1].startTime)}';
          
          children.add(
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
              child: _FreeTimeCard(
                title: 'Free Time',
                duration: durationText,
                timeRange: timeRangeText,
                dotColor: const Color(0xFF5BA48B), // Green dot
              ),
            ),
          );
        }
      }
    }
    return Column(children: children);
  }

  Widget _buildTomorrowPreview() {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    final tomorrowCourses = _allCourses.where((c) => 
      c.startTime.year == tomorrow.year && 
      c.startTime.month == tomorrow.month && 
      c.startTime.day == tomorrow.day).toList()..sort((a, b) => a.startTime.compareTo(b.startTime));
      
    if (tomorrowCourses.isEmpty) return const SizedBox();
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFEFCCB8),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tomorrow', style: GoogleFonts.urbanist(fontSize: 14, color: const Color(0xFF704D3F), fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text('${tomorrowCourses.length} classes', style: GoogleFonts.urbanist(fontSize: 20, fontWeight: FontWeight.w600, color: const Color(0xFF141414))),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('First class at', style: GoogleFonts.urbanist(fontSize: 12, color: const Color(0xFF704D3F))),
                const SizedBox(height: 4),
                Text(_formatTime(tomorrowCourses.first.startTime), style: GoogleFonts.urbanist(fontSize: 16, fontWeight: FontWeight.w600, color: const Color(0xFF141414))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _QuickActionBtn(
            icon: Icons.add_rounded, 
            label: 'Add Class', 
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Use the Calendar tab to manage classes.')),
              );
            }
          ),
          _QuickActionBtn(
            icon: Icons.upload_file_rounded, 
            label: 'Upload', 
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UploadTimetableScreen(
                    onUpload: () => Navigator.pop(context),
                    onSkip: () => Navigator.pop(context),
                  ),
                ),
              );
            }
          ),
          _QuickActionBtn(
            icon: Icons.refresh_rounded, 
            label: 'Refresh', 
            onTap: () {
              _onTimetableChanged();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Timetable refreshed.')),
              );
            }
          ),
        ],
      ),
    );
  }
}

// ── Header Delegate ───────────────────────────────────────────────────────

class _HomeHeaderDelegate extends SliverPersistentHeaderDelegate {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;
  
  _HomeHeaderDelegate({required this.selectedDate, required this.onDateSelected});

  final double expandedHeight = 340;
  final double collapsedHeight = 192;

  @override
  double get minExtent => collapsedHeight;
  @override
  double get maxExtent => expandedHeight;

  @override
  bool shouldRebuild(covariant _HomeHeaderDelegate oldDelegate) {
    return oldDelegate.selectedDate != selectedDate;
  }

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final progress = (shrinkOffset / (maxExtent - minExtent)).clamp(0.0, 1.0);

    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final weekDates = List.generate(7, (i) => monday.add(Duration(days: i)));

    return SizedBox.expand(
      child: ClipRRect(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(40 * progress)),
        child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20 * progress, sigmaY: 20 * progress),
        child: Container(
          color: Colors.white.withOpacity(0.6 * progress),
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 10,
            bottom: 20 * progress,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: Row(
                  children: [
                    Container(
                      width: 54, height: 54,
                      decoration: const BoxDecoration(color: Color(0xFFB9C2C7), shape: BoxShape.circle),
                      child: const Icon(Icons.person, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 12),
                    if (progress > 0)
                      Expanded(
                        child: Opacity(
                          opacity: progress,
                          child: Text(
                            'Custom Syllabus',
                            style: GoogleFonts.urbanist(fontSize: 24, fontWeight: FontWeight.w400, color: const Color(0xFF141414)),
                          ),
                        ),
                      )
                    else
                      const Spacer(),
                    const _GlassIconButton(icon: Icons.search_rounded),
                    const SizedBox(width: 8),
                    const _GlassIconButton(child: _ThreeDots(color: Color(0xFF1A1A1A))),
                  ],
                ),
              ),
              if (progress < 1.0)
                Expanded(
                  child: Opacity(
                    opacity: 1 - progress,
                    child: OverflowBox(
                      maxHeight: double.infinity,
                      alignment: Alignment.topLeft,
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 30),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Text(
                              'Hello, Anna',
                              style: GoogleFonts.urbanist(fontSize: 18, fontWeight: FontWeight.w400, color: const Color(0xFF5B5B60)),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Text(
                              _formatDate(DateTime.now()),
                              style: GoogleFonts.urbanist(fontSize: 44, fontWeight: FontWeight.w400, height: 1.1, letterSpacing: -0.96, color: const Color(0xFF141414)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              if (progress == 1.0) const Spacer(),
              // Week Strip
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: Row(
                  children: [
                    Container(
                      width: 38, height: 38,
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      child: const Icon(Icons.calendar_today_rounded, size: 16, color: Color(0xFF1A1A1A)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: weekDates.map((date) {
                            final isSelected = date.year == selectedDate.year && date.month == selectedDate.month && date.day == selectedDate.day;
                            final isToday = date.year == now.year && date.month == now.month && date.day == now.day;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: GestureDetector(
                                onTap: () => onDateSelected(date),
                                child: _DayChip(date: date, isSelected: isSelected, isToday: isToday),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ));
  }
}

// ── Components ────────────────────────────────────────────────────────────

class _DayChip extends StatelessWidget {
  final DateTime date;
  final bool isSelected;
  final bool isToday;

  const _DayChip({required this.date, required this.isSelected, required this.isToday});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF1A1A1A) : Colors.white.withOpacity(0.35),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? Colors.transparent : const Color(0xFF7A7A80).withOpacity(0.55),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _shortWeekday(date.weekday),
            style: GoogleFonts.urbanist(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white70 : const Color(0xFF6B6B70),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${date.day}',
            style: GoogleFonts.urbanist(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: isSelected ? Colors.white : const Color(0xFF1A1A1A),
            ),
          ),
        ],
      ),
    );
  }
}

class _CourseRow extends StatelessWidget {
  final Course course;
  final bool isCurrent;
  final bool faded;

  const _CourseRow({
    required this.course,
    this.isCurrent = false,
    this.faded = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 72,
      decoration: BoxDecoration(
        color: course.color,
        borderRadius: BorderRadius.circular(36),
        border: Border.all(
          color: isCurrent ? const Color(0xFF141414) : Colors.white.withOpacity(0.6),
          width: isCurrent ? 2.0 : 1.0,
        ),
        boxShadow: isCurrent ? [
          BoxShadow(
            color: course.color.withOpacity(0.4),
            blurRadius: 16,
            offset: const Offset(0, 4),
          )
        ] : null,
      ),
      child: Opacity(
        opacity: faded ? 0.55 : 1.0,
        child: Row(
          children: [
            const SizedBox(width: 4),
            Container(
              width: 64, height: 64,
              decoration: BoxDecoration(color: course.iconColor, shape: BoxShape.circle),
              child: Center(
                child: Icon(
                  faded ? Icons.check_circle_outline_rounded : course.icon,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          course.title,
                          style: GoogleFonts.urbanist(fontSize: 15, fontWeight: FontWeight.w600, color: const Color(0xFF141414)),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isCurrent) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF141414),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'NOW',
                            style: GoogleFonts.urbanist(fontSize: 9, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 0.5),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    faded ? 'Completed • ${course.room}' : '${course.room} • ${course.subtitle}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.urbanist(fontSize: 12, color: const Color(0xFF6E5A62)),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 16, left: 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(_formatTime(course.startTime), style: GoogleFonts.urbanist(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF141414))),
                  Text(_formatTime(course.endTime), style: GoogleFonts.urbanist(fontSize: 11, color: const Color(0xFF6E5A62))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CurrentClassExpandedCard extends StatelessWidget {
  final Course course;
  final Course? nextCourse;
  final DateTime now;

  const _CurrentClassExpandedCard({
    required this.course,
    this.nextCourse,
    required this.now,
  });

  @override
  Widget build(BuildContext context) {
    final durHours = course.endTime.difference(course.startTime).inHours;
    final durMins = course.endTime.difference(course.startTime).inMinutes % 60;
    final durText = durMins == 0 ? '${durHours}h' : '${durHours}h ${durMins}m';
    final progress = course.progress(now);
    final minsLeft = course.minutesRemaining(now);

    return Container(
      decoration: BoxDecoration(
        color: course.color,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: const Color(0xFF141414).withOpacity(0.14), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: course.color.withOpacity(0.4),
            blurRadius: 28,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Badge Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF141414),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: const Color(0xFF22C55E),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF22C55E).withOpacity(0.8),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          'HAPPENING NOW',
                          style: GoogleFonts.urbanist(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.65),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.timer_outlined, size: 14, color: Color(0xFF141414)),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          '$minsLeft mins left',
                          style: GoogleFonts.urbanist(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF141414),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Title & Icon Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.title,
                      style: GoogleFonts.urbanist(
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF141414),
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      course.subtitle,
                      style: GoogleFonts.urbanist(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF5B4C52),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: course.iconColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(course.icon, color: Colors.white, size: 26),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Live Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white.withOpacity(0.55),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF141414)),
              minHeight: 7,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatTime(course.startTime),
                style: GoogleFonts.urbanist(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF141414),
                ),
              ),
              Text(
                '${(progress * 100).toInt()}% Elapsed',
                style: GoogleFonts.urbanist(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF6E5A62),
                ),
              ),
              Text(
                _formatTime(course.endTime),
                style: GoogleFonts.urbanist(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF141414),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Room & Duration Meta Row
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 16, color: Color(0xFF141414)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Room ${course.room}',
                          style: GoogleFonts.urbanist(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF141414),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: course.iconColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.schedule_rounded, size: 16, color: Color(0xFF141414)),
                    const SizedBox(width: 6),
                    Text(
                      durText,
                      style: GoogleFonts.urbanist(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF141414),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Next Period Info if available
          if (nextCourse != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF141414).withOpacity(0.06),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.skip_next_rounded, size: 18, color: Color(0xFF141414)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Up next: ${nextCourse!.title} at ${_formatTime(nextCourse!.startTime)}',
                      style: GoogleFonts.urbanist(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF141414),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    'Room ${nextCourse!.room}',
                    style: GoogleFonts.urbanist(
                      fontSize: 11,
                      color: const Color(0xFF6E5A62),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _UpcomingClassCard extends StatelessWidget {
  final Course course;
  final DateTime now;

  const _UpcomingClassCard({
    required this.course,
    required this.now,
  });

  @override
  Widget build(BuildContext context) {
    final durHours = course.endTime.difference(course.startTime).inHours;
    final durMins = course.endTime.difference(course.startTime).inMinutes % 60;
    final durText = durMins == 0 ? '${durHours}h' : '${durHours}h ${durMins}m';
    final startsInMins = course.startTime.difference(now).inMinutes;

    return Container(
      decoration: BoxDecoration(
        color: course.color,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withOpacity(0.6), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: course.color.withOpacity(0.35),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF141414),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: Color(0xFF38BDF8),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'UP NEXT',
                      style: GoogleFonts.urbanist(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.65),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    startsInMins <= 60 
                        ? 'Starts in ${startsInMins.clamp(1, 1440)}m' 
                        : 'Starts ${_formatTime(course.startTime)}',
                    style: GoogleFonts.urbanist(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF141414),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.title,
                      style: GoogleFonts.urbanist(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF141414),
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      course.subtitle,
                      style: GoogleFonts.urbanist(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF5B4C52),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: course.iconColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(course.icon, color: Colors.white, size: 26),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 16, color: Color(0xFF141414)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Room ${course.room}',
                          style: GoogleFonts.urbanist(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF141414),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: course.iconColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '${_formatTime(course.startTime)} – ${_formatTime(course.endTime)} ($durText)',
                    style: GoogleFonts.urbanist(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF141414),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AllClassesCompletedCard extends StatelessWidget {
  final int totalCount;

  const _AllClassesCompletedCard({required this.totalCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFCDE6E2),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withOpacity(0.7), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFCDE6E2).withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(22),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(
              color: Color(0xFF141414),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.done_all_rounded, color: Colors.white, size: 26),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "All classes completed!",
                  style: GoogleFonts.urbanist(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF141414),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "You've completed all $totalCount scheduled periods for today.",
                  style: GoogleFonts.urbanist(
                    fontSize: 13,
                    color: const Color(0xFF4A5568),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionBtn({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.6),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.8), width: 1),
            ),
            child: Icon(icon, color: const Color(0xFF1A1A1A), size: 24),
          ),
          const SizedBox(height: 8),
          Text(label, style: GoogleFonts.urbanist(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF1A1A1A))),
        ],
      ),
    );
  }
}

class _GlassIconButton extends StatelessWidget {
  final IconData? icon;
  final Widget? child;
  const _GlassIconButton({this.icon, this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 54, height: 54,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.55),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(0.8), width: 1),
      ),
      child: Center(
        child: child ?? Icon(icon, color: const Color(0xFF1A1A1A), size: 22),
      ),
    );
  }
}

class _ThreeDots extends StatelessWidget {
  final Color color;
  const _ThreeDots({required this.color});
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        3,
        (i) => Container(
          width: 5, height: 5,
          margin: EdgeInsets.only(right: i < 2 ? 4 : 0),
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
      ),
    );
  }
}


class _FreeTimeCard extends StatelessWidget {
  final String title;
  final String duration;
  final String timeRange;
  final Color dotColor;

  const _FreeTimeCard({
    required this.title,
    required this.duration,
    required this.timeRange,
    required this.dotColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: const Color(0xFFF5F3F0),
        borderRadius: BorderRadius.circular(24),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            right: -20,
            top: -40,
            child: Container(
              width: 120, height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF98CBB4), width: 1.0), // Teal
              ),
            ),
          ),
          Positioned(
            left: -30,
            bottom: -30,
            child: Container(
              width: 100, height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFB4A1D9), width: 1.0), // Purple
              ),
            ),
          ),
          Positioned(
            right: 40,
            bottom: -50,
            child: Container(
              width: 110, height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE29E9E), width: 1.0), // Red
              ),
            ),
          ),
          
          // Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title, style: GoogleFonts.urbanist(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF141414))),
                    Container(width: 8, height: 8, decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle)),
                  ],
                ),
                Text(duration, style: GoogleFonts.urbanist(fontSize: 36, fontWeight: FontWeight.w400, color: const Color(0xFF141414), height: 1.0)),
                Row(
                  children: [
                    const Icon(Icons.access_time_rounded, size: 14, color: Color(0xFF6E5A62)),
                    const SizedBox(width: 4),
                    Text(timeRange, style: GoogleFonts.urbanist(fontSize: 12, color: const Color(0xFF6E5A62))),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
