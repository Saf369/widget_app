import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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

  late List<Course> _allCourses;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);
    
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final tuesday = monday.add(const Duration(days: 1));
    final wednesday = monday.add(const Duration(days: 2));
    final thursday = monday.add(const Duration(days: 3));
    final friday = monday.add(const Duration(days: 4));
    final saturday = monday.add(const Duration(days: 5));
    final sunday = monday.add(const Duration(days: 6));

    // Comprehensive mock data for the week
    _allCourses = [
      // Monday
      Course('Engineering Graphics', 'Spatial reasoning', DateTime(monday.year, monday.month, monday.day, 9, 0), DateTime(monday.year, monday.month, monday.day, 10, 30), 'Room 302', const Color(0xFFE8CACF), const Color(0xFFDDA9AF), Icons.edit_rounded),
      Course('Visual Communication', 'Sketching & rendering', DateTime(monday.year, monday.month, monday.day, 11, 0), DateTime(monday.year, monday.month, monday.day, 12, 30), 'Studio A', const Color(0xFFCDE6E2), const Color(0xFFB5D8D4), Icons.brush_rounded),
      Course('Design Theory', 'Fundamentals of design', DateTime(monday.year, monday.month, monday.day, 13, 30), DateTime(monday.year, monday.month, monday.day, 15, 0), 'Hall 2', const Color(0xFFDBD3EE), const Color(0xFFAFA2D5), Icons.lightbulb_rounded),
      Course('Art History', 'Renaissance to Modern', DateTime(monday.year, monday.month, monday.day, 15, 30), DateTime(monday.year, monday.month, monday.day, 17, 0), 'Lecture Hall B', const Color(0xFFEFCCB8), const Color(0xFFC09D8B), Icons.museum_rounded),
      
      // Tuesday
      Course('Architectural History', 'Styles and movements', DateTime(tuesday.year, tuesday.month, tuesday.day, 9, 0), DateTime(tuesday.year, tuesday.month, tuesday.day, 10, 30), 'Hall 1', const Color(0xFFDBD3EE), const Color(0xFFAFA2D5), Icons.history_rounded),
      Course('Building Technology', 'Materials and methods', DateTime(tuesday.year, tuesday.month, tuesday.day, 11, 0), DateTime(tuesday.year, tuesday.month, tuesday.day, 13, 0), 'Lab B', const Color(0xFFEFCCB8), const Color(0xFFC09D8B), Icons.construction_rounded),
      Course('Environmental Science', 'Sustainability basics', DateTime(tuesday.year, tuesday.month, tuesday.day, 14, 0), DateTime(tuesday.year, tuesday.month, tuesday.day, 15, 30), 'Room 105', const Color(0xFFCDE6E2), const Color(0xFFB5D8D4), Icons.eco_rounded),
      Course('Studio Practice', 'Hands-on project work', DateTime(tuesday.year, tuesday.month, tuesday.day, 16, 0), DateTime(tuesday.year, tuesday.month, tuesday.day, 18, 0), 'Main Studio', const Color(0xFFE8CACF), const Color(0xFFDDA9AF), Icons.architecture_rounded),

      // Wednesday
      Course('Housing Design', 'Urban living concepts', DateTime(wednesday.year, wednesday.month, wednesday.day, 9, 30), DateTime(wednesday.year, wednesday.month, wednesday.day, 11, 30), 'Studio C', const Color(0xFFE8CACF), const Color(0xFFDDA9AF), Icons.home_work_rounded),
      Course('Structural Mechanics', 'Forces and loads', DateTime(wednesday.year, wednesday.month, wednesday.day, 12, 30), DateTime(wednesday.year, wednesday.month, wednesday.day, 14, 0), 'Room 201', const Color(0xFFDBD3EE), const Color(0xFFAFA2D5), Icons.foundation_rounded),
      Course('Model Making', 'Physical prototyping', DateTime(wednesday.year, wednesday.month, wednesday.day, 14, 30), DateTime(wednesday.year, wednesday.month, wednesday.day, 16, 30), 'Workshop', const Color(0xFFEFCCB8), const Color(0xFFC09D8B), Icons.cut_rounded),
      Course('CAD Basics', 'AutoCAD intro', DateTime(wednesday.year, wednesday.month, wednesday.day, 17, 0), DateTime(wednesday.year, wednesday.month, wednesday.day, 18, 30), 'Computer Lab', const Color(0xFFCDE6E2), const Color(0xFFB5D8D4), Icons.computer_rounded),

      // Thursday
      Course('Digital Modeling', '3D software tools', DateTime(thursday.year, thursday.month, thursday.day, 9, 0), DateTime(thursday.year, thursday.month, thursday.day, 11, 0), 'Computer Lab', const Color(0xFFCDE6E2), const Color(0xFFB5D8D4), Icons.mouse_rounded),
      Course('Urban Planning', 'City infrastructure', DateTime(thursday.year, thursday.month, thursday.day, 11, 30), DateTime(thursday.year, thursday.month, thursday.day, 13, 0), 'Hall 3', const Color(0xFFEFCCB8), const Color(0xFFC09D8B), Icons.map_rounded),
      Course('Landscape Architecture', 'Outdoor spaces', DateTime(thursday.year, thursday.month, thursday.day, 14, 0), DateTime(thursday.year, thursday.month, thursday.day, 15, 30), 'Room 112', const Color(0xFFE8CACF), const Color(0xFFDDA9AF), Icons.park_rounded),
      Course('Elective: Photography', 'Architectural photography', DateTime(thursday.year, thursday.month, thursday.day, 16, 0), DateTime(thursday.year, thursday.month, thursday.day, 17, 30), 'Media Lab', const Color(0xFFDBD3EE), const Color(0xFFAFA2D5), Icons.camera_alt_rounded),
      
      // Friday
      Course('Portfolio Workshop', 'Presentation skills', DateTime(friday.year, friday.month, friday.day, 9, 30), DateTime(friday.year, friday.month, friday.day, 11, 30), 'Studio A', const Color(0xFFE8CACF), const Color(0xFFDDA9AF), Icons.work_rounded),
      Course('Building Regulations', 'Codes & standards', DateTime(friday.year, friday.month, friday.day, 12, 30), DateTime(friday.year, friday.month, friday.day, 14, 0), 'Lecture Hall B', const Color(0xFFDBD3EE), const Color(0xFFAFA2D5), Icons.gavel_rounded),
      Course('Guest Lecture', 'Industry insights', DateTime(friday.year, friday.month, friday.day, 14, 30), DateTime(friday.year, friday.month, friday.day, 16, 0), 'Auditorium', const Color(0xFFEFCCB8), const Color(0xFFC09D8B), Icons.mic_rounded),
      
      // Saturday (Half day)
      Course('Site Visit', 'Field study & analysis', DateTime(saturday.year, saturday.month, saturday.day, 10, 0), DateTime(saturday.year, saturday.month, saturday.day, 13, 0), 'Downtown Project', const Color(0xFFCDE6E2), const Color(0xFFB5D8D4), Icons.explore_rounded),
      
      // Sunday (Review)
      Course('Weekly Review', 'Group critique session', DateTime(sunday.year, sunday.month, sunday.day, 14, 0), DateTime(sunday.year, sunday.month, sunday.day, 16, 0), 'Main Studio', const Color(0xFFE8CACF), const Color(0xFFDDA9AF), Icons.people_rounded),
    ];

    // Ensure we have an ongoing/next class for TODAY so the 'Now/Next' card always shows up nicely in demo
    // The user specifically requested to test what the card looks like when "Structural Mechanics" is ongoing!
    final structMechOriginal = _allCourses.firstWhere((c) => c.title == 'Structural Mechanics');
    
    // Remove it from its original day to avoid duplicates if today happens to be that day
    _allCourses.removeWhere((c) => c.title == 'Structural Mechanics');
    
    // Add it back, but scheduled for exactly right now so it triggers the ongoing state
    _allCourses.add(
      Course(
        structMechOriginal.title, 
        structMechOriginal.subtitle, 
        DateTime(now.year, now.month, now.day, now.hour, now.minute - 10), 
        DateTime(now.year, now.month, now.day, now.hour + 1, now.minute + 20), 
        structMechOriginal.room, 
        structMechOriginal.color, 
        structMechOriginal.iconColor, 
        structMechOriginal.icon
      )
    );

    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  List<Course> get _currentDayCourses {
    return _allCourses.where((c) => 
      c.startTime.year == _selectedDate.year && 
      c.startTime.month == _selectedDate.month && 
      c.startTime.day == _selectedDate.day).toList()..sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  Course? get _nowOrNextCourse {
    final now = DateTime.now();
    final todayCourses = _allCourses.where((c) => 
      c.startTime.year == now.year && 
      c.startTime.month == now.month && 
      c.startTime.day == now.day).toList()..sort((a, b) => a.startTime.compareTo(b.startTime));
      
    for (var course in todayCourses) {
      if (now.isBefore(course.endTime)) {
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
    final nowOrNext = _nowOrNextCourse;

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
                              if (isToday && nowOrNext != null) ...[
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 22),
                                  child: _NowNextClassCard(course: nowOrNext),
                                ),
                                const SizedBox(height: 24),
                              ],
                              
                              if (todayCourses.isEmpty)
                                _buildEmptyState()
                              else
                                _buildScheduleList(todayCourses),

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
                      setState(() => _hasTimetable = true);
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

  Widget _buildScheduleList(List<Course> courses) {
    List<Widget> children = [];
    for (int i = 0; i < courses.length; i++) {
      children.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 4),
          child: _CourseRow(
            course: courses[i],
            faded: courses[i].endTime.isBefore(DateTime.now()),
          ),
        )
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
            )
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
          _QuickActionBtn(icon: Icons.add_rounded, label: 'Add Class', onTap: () {}),
          _QuickActionBtn(icon: Icons.upload_file_rounded, label: 'Upload', onTap: () {}),
          _QuickActionBtn(icon: Icons.edit_calendar_rounded, label: 'Edit', onTap: () {}),
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
  final bool faded;

  const _CourseRow({required this.course, this.faded = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: course.color,
        borderRadius: BorderRadius.circular(36),
        border: Border.all(color: Colors.white.withOpacity(0.6), width: 1),
      ),
      child: Row(
        children: [
          const SizedBox(width: 4),
          Container(
            width: 64, height: 64,
            decoration: BoxDecoration(color: course.iconColor, shape: BoxShape.circle),
            child: Center(child: Icon(course.icon, color: Colors.white, size: 28)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(course.title, style: GoogleFonts.urbanist(fontSize: 15, fontWeight: FontWeight.w600, color: const Color(0xFF141414))),
                const SizedBox(height: 2),
                Text('${course.room} • ${course.subtitle}', maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.urbanist(fontSize: 12, color: const Color(0xFF6E5A62))),
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
    );
  }
}

class _NowNextClassCard extends StatelessWidget {
  final Course course;
  const _NowNextClassCard({required this.course});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isOngoing = now.isAfter(course.startTime) && now.isBefore(course.endTime);
    
    final topColor = course.color;
    final bottomRightColor = course.iconColor;

    final durHours = course.endTime.difference(course.startTime).inHours;
    final durMins = course.endTime.difference(course.startTime).inMinutes % 60;
    final durText = durMins == 0 ? '${durHours}h' : '${durHours}h ${durMins}m';

    return Container(
      height: 230,
      decoration: BoxDecoration(
        color: topColor, // Top and Left sections share this background
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 8))
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Top Half
          Expanded(
            flex: 12,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          course.title,
                          style: GoogleFonts.urbanist(fontSize: 24, fontWeight: FontWeight.w400, color: const Color(0xFF141414), height: 1.1),
                        ),
                      ),
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.more_horiz, color: Color(0xFF141414), size: 20),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    course.subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.urbanist(fontSize: 13, color: const Color(0xFF5B4C52), height: 1.3),
                  ),
                ],
              ),
            ),
          ),
          // Bottom Half
          Expanded(
            flex: 11,
            child: Row(
              children: [
                // Bottom Left (Room and Time)
                Expanded(
                  flex: 4,
                  child: Container(
                    padding: const EdgeInsets.only(left: 20, top: 16, bottom: 16, right: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Room', style: GoogleFonts.urbanist(fontSize: 11, color: const Color(0xFF6E5A62))),
                            Text(
                              course.room.split(' ').last, 
                              style: GoogleFonts.urbanist(fontSize: 28, fontWeight: FontWeight.w300, color: const Color(0xFF141414), height: 1.1)
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(Icons.access_time_rounded, size: 12, color: Color(0xFF6E5A62)),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                isOngoing ? 'Ongoing now' : 'Starts ${_formatTime(course.startTime)}', 
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.urbanist(fontSize: 10, color: const Color(0xFF6E5A62))
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                // Bottom Right (Duration and Action)
                Expanded(
                  flex: 5,
                  child: Container(
                    color: bottomRightColor,
                    child: Stack(
                      children: [
                        Positioned(
                          left: 20,
                          top: 16,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Duration', style: GoogleFonts.urbanist(fontSize: 11, color: const Color(0xFF6E5A62))),
                              Text(
                                durText, 
                                style: GoogleFonts.urbanist(fontSize: 28, fontWeight: FontWeight.w300, color: const Color(0xFF141414), height: 1.1)
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          right: 12,
                          bottom: 12,
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: const BoxDecoration(
                              color: Color(0xFF141414),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.arrow_outward_rounded, color: Colors.white, size: 18),
                          ),
                        ),
                      ],
                    ),
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
