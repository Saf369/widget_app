import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum TimetableWidgetTab { hour, day, week, month }

class TimetableHomeWidgetUI extends StatefulWidget {
  final TimetableWidgetTab activeTab;

  const TimetableHomeWidgetUI({
    super.key,
    required this.activeTab,
  });

  @override
  State<TimetableHomeWidgetUI> createState() => _TimetableHomeWidgetUIState();
}

class _TimetableHomeWidgetUIState extends State<TimetableHomeWidgetUI> {
  int _monthOffset = 0;
  late TimetableWidgetTab _currentTab;

  @override
  void initState() {
    super.initState();
    _currentTab = widget.activeTab;
  }

  @override
  void didUpdateWidget(covariant TimetableHomeWidgetUI oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.activeTab != widget.activeTab) {
      _currentTab = widget.activeTab;
    }
  }

  String get _dateSubtitle {
    switch (_currentTab) {
      case TimetableWidgetTab.hour:
      case TimetableWidgetTab.day:
        return 'Fri, 14 June 2026';
      case TimetableWidgetTab.week:
        return '8 – 14 June 2026';
      case TimetableWidgetTab.month:
        return 'June 2026';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 360,
      height: 360,
      decoration: BoxDecoration(
        color: const Color(0xFFF3F0EE),
        borderRadius: BorderRadius.circular(32),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Timetable',
                      style: GoogleFonts.urbanist(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                        height: 1.0,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      transitionBuilder: (child, animation) => FadeTransition(
                        opacity: animation,
                        child: child,
                      ),
                      child: Text(
                        _dateSubtitle,
                        key: ValueKey<String>(_dateSubtitle),
                        style: GoogleFonts.urbanist(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _buildTabs(),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTabItem('Hour', TimetableWidgetTab.hour),
          _buildTabItem('Day', TimetableWidgetTab.day),
          _buildTabItem('Week', TimetableWidgetTab.week),
          _buildTabItem('Month', TimetableWidgetTab.month),
        ],
      ),
    );
  }

  Widget _buildTabItem(String text, TimetableWidgetTab tab) {
    final isActive = _currentTab == tab;
    return GestureDetector(
      onTap: () {
        if (_currentTab != tab) {
          setState(() {
            _currentTab = tab;
          });
        }
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
        decoration: BoxDecoration(
          color: isActive ? Colors.black : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 4,
                    offset: const Offset(0, 1.5),
                  ),
                ]
              : null,
        ),
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          style: GoogleFonts.urbanist(
            fontSize: 10,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            color: isActive ? Colors.white : Colors.black87,
          ),
          child: Text(text),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 280),
      reverseDuration: const Duration(milliseconds: 180),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          ),
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.0, 0.04),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            )),
            child: child,
          ),
        );
      },
      child: KeyedSubtree(
        key: ValueKey<TimetableWidgetTab>(_currentTab),
        child: _buildTabView(_currentTab),
      ),
    );
  }

  Widget _buildTabView(TimetableWidgetTab tab) {
    switch (tab) {
      case TimetableWidgetTab.hour:
        return _buildHourView();
      case TimetableWidgetTab.day:
        return _buildDayView();
      case TimetableWidgetTab.week:
        return _buildWeekView();
      case TimetableWidgetTab.month:
        return _buildMonthView();
    }
  }

  Widget _buildHourView() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.black.withOpacity(0.05)),
              child: const Icon(Icons.chevron_left, size: 16),
            ),
            Expanded(
              child: Column(
                children: [
                  Text('10:00 - 11:00 AM', style: GoogleFonts.urbanist(fontWeight: FontWeight.w700, fontSize: 15), maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text('In progress • Theory Test', style: GoogleFonts.urbanist(color: Colors.grey[600], fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.black.withOpacity(0.05)),
              child: const Icon(Icons.chevron_right, size: 16),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: Row(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('10:00', style: GoogleFonts.urbanist(fontSize: 10, color: Colors.grey[600])),
                  Text('10:15', style: GoogleFonts.urbanist(fontSize: 10, color: Colors.grey[600])),
                  Text('10:30', style: GoogleFonts.urbanist(fontSize: 10, color: Colors.grey[600])),
                  Text('10:45', style: GoogleFonts.urbanist(fontSize: 10, color: Colors.grey[600])),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFFDCA7B5),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(child: Text('Theory Test', style: GoogleFonts.urbanist(fontSize: 18, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis)),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(12)),
                                  child: Text('Now', style: GoogleFonts.urbanist(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                            Text('Design Theory • Room 244', style: GoogleFonts.urbanist(color: Colors.black54, fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
                            const Spacer(),
                            Container(
                              height: 4,
                              width: double.infinity,
                              decoration: BoxDecoration(color: Colors.black.withOpacity(0.1), borderRadius: BorderRadius.circular(2)),
                              child: FractionallySizedBox(
                                alignment: Alignment.centerLeft,
                                widthFactor: 0.6,
                                child: Container(decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(2))),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(child: Text('10:00 - 10:45', style: GoogleFonts.urbanist(fontSize: 11, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis)),
                                Text('27 min left', style: GoogleFonts.urbanist(fontSize: 11, fontWeight: FontWeight.bold)),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      flex: 1,
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        padding: const EdgeInsets.all(12),
                        alignment: Alignment.centerLeft,
                        child: Text('Free • 15 min', style: GoogleFonts.urbanist(color: Colors.grey[700], fontSize: 11, fontWeight: FontWeight.w500)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDayView() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Text('10', style: GoogleFonts.urbanist(fontSize: 18, fontWeight: FontWeight.w600)),
            Text('AM', style: GoogleFonts.urbanist(fontSize: 10, color: Colors.grey[600])),
            const SizedBox(height: 40),
            Text('11', style: GoogleFonts.urbanist(fontSize: 18, fontWeight: FontWeight.w600)),
            Text('AM', style: GoogleFonts.urbanist(fontSize: 10, color: Colors.grey[600])),
            const SizedBox(height: 50),
            Text('1', style: GoogleFonts.urbanist(fontSize: 18, fontWeight: FontWeight.w600)),
            Text('PM', style: GoogleFonts.urbanist(fontSize: 10, color: Colors.grey[600])),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            children: [
              Container(
                height: 70,
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(color: const Color(0xFFDCA7B5), borderRadius: BorderRadius.circular(20)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Theory Test', style: GoogleFonts.urbanist(fontSize: 15, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                          Text('10:00 - 11:00 AM • 1 Hour', style: GoogleFonts.urbanist(fontSize: 10.5, color: Colors.black54), maxLines: 1, overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.5), borderRadius: BorderRadius.circular(12)),
                      child: Text('Room 244', style: GoogleFonts.urbanist(fontSize: 9.5, fontWeight: FontWeight.w600)),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                height: 70,
                width: double.infinity,
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.5), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white)),
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('You have 2 hours', style: GoogleFonts.urbanist(fontSize: 11, color: Colors.grey[600])),
                    Text('Free Time', style: GoogleFonts.urbanist(fontSize: 14, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                height: 70,
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(color: const Color(0xFFC7B9E0), borderRadius: BorderRadius.circular(20)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Design Test', style: GoogleFonts.urbanist(fontSize: 15, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                          Text('1:00 - 2:00 PM • 1 Hour', style: GoogleFonts.urbanist(fontSize: 10.5, color: Colors.black54), maxLines: 1, overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.5), borderRadius: BorderRadius.circular(12)),
                      child: Text('Room 244', style: GoogleFonts.urbanist(fontSize: 9.5, fontWeight: FontWeight.w600)),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWeekView() {
    // A simple grid mock of the week view
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: ['Mon\n10', 'Tue\n11', 'Wed\n12', 'Thu\n13', 'Fri\n14', 'Sat\n15', 'Sun\n16'].map((e) {
            bool isToday = e.contains('14');
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
              decoration: BoxDecoration(
                color: isToday ? Colors.black : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                e,
                textAlign: TextAlign.center,
                style: GoogleFonts.urbanist(
                  fontSize: 10,
                  fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                  color: isToday ? Colors.white : Colors.black,
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: ['9a', '10a', '11a', '12p', '1p'].map((e) => Text(e, style: GoogleFonts.urbanist(fontSize: 10, color: Colors.grey[600]))).toList(),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Stack(
                  children: [
                    // Grid lines
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(5, (index) => Container(height: 1, color: Colors.black.withOpacity(0.05))),
                    ),
                    // Blocks
                    Positioned(left: 0, top: 0, width: 35, height: 80, child: Container(decoration: BoxDecoration(color: const Color(0xFFBBE0CE), borderRadius: BorderRadius.circular(8)), alignment: Alignment.topCenter, padding: const EdgeInsets.only(top: 4), child: Text('Studio', style: GoogleFonts.urbanist(fontSize: 8)))),
                    Positioned(left: 45, top: 40, width: 35, height: 40, child: Container(decoration: BoxDecoration(color: const Color(0xFFDCA7B5), borderRadius: BorderRadius.circular(8)), alignment: Alignment.topCenter, padding: const EdgeInsets.only(top: 4), child: Text('Theory', style: GoogleFonts.urbanist(fontSize: 8)))),
                    Positioned(left: 135, top: 0, width: 35, height: 40, child: Container(decoration: BoxDecoration(color: const Color(0xFFBBE0CE), borderRadius: BorderRadius.circular(8)), alignment: Alignment.topCenter, padding: const EdgeInsets.only(top: 4), child: Text('Crit', style: GoogleFonts.urbanist(fontSize: 8)))),
                    Positioned(left: 180, top: 40, width: 35, height: 40, child: Container(decoration: BoxDecoration(color: const Color(0xFFDCA7B5), borderRadius: BorderRadius.circular(8)), alignment: Alignment.topCenter, padding: const EdgeInsets.only(top: 4), child: Text('Theory', style: GoogleFonts.urbanist(fontSize: 8)))),
                    Positioned(left: 90, top: 80, width: 35, height: 80, child: Container(decoration: BoxDecoration(color: const Color(0xFFEED0A4), borderRadius: BorderRadius.circular(8)), alignment: Alignment.topCenter, padding: const EdgeInsets.only(top: 4), child: Text('Lab', style: GoogleFonts.urbanist(fontSize: 8)))),
                    Positioned(left: 135, top: 160, width: 35, height: 40, child: Container(decoration: BoxDecoration(color: const Color(0xFFC7B9E0), borderRadius: BorderRadius.circular(8)), alignment: Alignment.topCenter, padding: const EdgeInsets.only(top: 4), child: Text('Design', style: GoogleFonts.urbanist(fontSize: 8)))),
                  ],
                ),
              )
            ],
          ),
        )
      ],
    );
  }

  Widget _buildMonthView() {
    const monthNames = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    final now = DateTime.now();
    final displayedMonth = DateTime(now.year, now.month + _monthOffset, 1);
    final monthTitle = '${monthNames[displayedMonth.month - 1]} ${displayedMonth.year}';

    // Calendar grid calculation starting on Monday
    final firstWeekday = displayedMonth.weekday; // 1 = Monday, 7 = Sunday
    final startOffset = firstWeekday - 1;
    final startDate = displayedMonth.subtract(Duration(days: startOffset));

    return Column(
      children: [
        // Month navigation row with chevrons
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  _monthOffset--;
                });
              },
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withOpacity(0.05),
                ),
                child: const Icon(Icons.chevron_left, size: 16),
              ),
            ),
            Text(
              monthTitle,
              style: GoogleFonts.urbanist(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  _monthOffset++;
                });
              },
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withOpacity(0.05),
                ),
                child: const Icon(Icons.chevron_right, size: 16),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
              .map((e) => Text(e, style: GoogleFonts.urbanist(fontSize: 10, color: Colors.grey[600])))
              .toList(),
        ),
        const SizedBox(height: 6),
        // Grid
        Expanded(
          child: GridView.count(
            crossAxisCount: 7,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.3,
            children: List.generate(28, (index) {
              final cellDate = startDate.add(Duration(days: index));
              final inMonth = cellDate.month == displayedMonth.month;
              final isToday = cellDate.year == now.year &&
                  cellDate.month == now.month &&
                  cellDate.day == now.day;
              return Container(
                margin: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: isToday ? Colors.black : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${cellDate.day}',
                      style: GoogleFonts.urbanist(
                        fontSize: 11,
                        fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
                        color: isToday
                            ? Colors.white
                            : (inMonth ? Colors.black : Colors.grey[400]),
                      ),
                    ),
                    if (isToday || (inMonth && cellDate.day % 4 == 0))
                      Container(
                        margin: const EdgeInsets.only(top: 1),
                        height: 2.5,
                        width: 10,
                        decoration: BoxDecoration(
                          color: isToday ? Colors.white : const Color(0xFFDCA7B5),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                  ],
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Fri, 14 June', style: GoogleFonts.urbanist(fontWeight: FontWeight.bold)),
            Text('3 items', style: GoogleFonts.urbanist(fontSize: 11, color: Colors.grey[600])),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          height: 54,
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(color: const Color(0xFFDCA7B5), borderRadius: BorderRadius.circular(16)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Theory Test', style: GoogleFonts.urbanist(fontSize: 13, fontWeight: FontWeight.bold)),
                  Text('10:00 - 11:00 AM', style: GoogleFonts.urbanist(fontSize: 10, color: Colors.black54)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.5), borderRadius: BorderRadius.circular(10)),
                child: Text('Room 244', style: GoogleFonts.urbanist(fontSize: 9, fontWeight: FontWeight.w600)),
              )
            ],
          ),
        ),
      ],
    );
  }
}
