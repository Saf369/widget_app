import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum TimetableWidgetTab { hour, day, week, month }

class TimetableHomeWidgetUI extends StatelessWidget {
  final TimetableWidgetTab activeTab;

  const TimetableHomeWidgetUI({
    super.key,
    required this.activeTab,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 360,
      height: 360,
      decoration: BoxDecoration(
        color: const Color(0xFFF3F0EE),
        borderRadius: BorderRadius.circular(32),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Timetable',
                    style: GoogleFonts.urbanist(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Fri, 14 June 2026',
                    style: GoogleFonts.urbanist(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              _buildTabs(),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      padding: const EdgeInsets.all(4),
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
    final isActive = activeTab == tab;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isActive ? Colors.black : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: GoogleFonts.urbanist(
          fontSize: 11,
          fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
          color: isActive ? Colors.white : Colors.black87,
        ),
      ),
    );
  }

  Widget _buildContent() {
    switch (activeTab) {
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
            Column(
              children: [
                Text('10:00 - 11:00 AM', style: GoogleFonts.urbanist(fontWeight: FontWeight.w700, fontSize: 16)),
                Text('In progress • Theory Test', style: GoogleFonts.urbanist(color: Colors.grey[600], fontSize: 12)),
              ],
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
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Theory Test', style: GoogleFonts.urbanist(fontSize: 20, fontWeight: FontWeight.bold)),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(12)),
                                  child: Text('Now', style: GoogleFonts.urbanist(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                            Text('Design Theory • Room 244', style: GoogleFonts.urbanist(color: Colors.black54, fontSize: 12)),
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
                                Text('10:00 - 10:45', style: GoogleFonts.urbanist(fontSize: 11, fontWeight: FontWeight.bold)),
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
                        padding: const EdgeInsets.all(16),
                        alignment: Alignment.centerLeft,
                        child: Text('Free • 15 min', style: GoogleFonts.urbanist(color: Colors.grey[700], fontSize: 12, fontWeight: FontWeight.w500)),
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
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(color: const Color(0xFFDCA7B5), borderRadius: BorderRadius.circular(20)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Theory Test', style: GoogleFonts.urbanist(fontSize: 16, fontWeight: FontWeight.bold)),
                        Text('10:00 - 11:00 AM • 1 Hour', style: GoogleFonts.urbanist(fontSize: 11, color: Colors.black54)),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.5), borderRadius: BorderRadius.circular(12)),
                      child: Text('Room 244', style: GoogleFonts.urbanist(fontSize: 10, fontWeight: FontWeight.w600)),
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
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(color: const Color(0xFFC7B9E0), borderRadius: BorderRadius.circular(20)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Design Test', style: GoogleFonts.urbanist(fontSize: 16, fontWeight: FontWeight.bold)),
                        Text('1:00 - 2:00 PM • 1 Hour', style: GoogleFonts.urbanist(fontSize: 11, color: Colors.black54)),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.5), borderRadius: BorderRadius.circular(12)),
                      child: Text('Room 244', style: GoogleFonts.urbanist(fontSize: 10, fontWeight: FontWeight.w600)),
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
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isToday ? Colors.black : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                e,
                textAlign: TextAlign.center,
                style: GoogleFonts.urbanist(
                  fontSize: 11,
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
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'].map((e) => Text(e, style: GoogleFonts.urbanist(fontSize: 10, color: Colors.grey[600]))).toList(),
        ),
        const SizedBox(height: 8),
        // Grid
        Expanded(
          child: GridView.count(
            crossAxisCount: 7,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.2,
            children: List.generate(35, (index) {
              int day = index - 1; // starts at 26 of prev month
              if (day < 1) return const SizedBox();
              if (day > 30) return const SizedBox();
              bool isToday = day == 14;
              return Container(
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isToday ? Colors.black : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('$day', style: GoogleFonts.urbanist(fontSize: 12, fontWeight: isToday ? FontWeight.bold : FontWeight.w500, color: isToday ? Colors.white : Colors.black)),
                    if (day % 3 == 0 || day == 14) 
                      Container(margin: const EdgeInsets.only(top: 2), height: 3, width: 12, decoration: BoxDecoration(color: isToday ? Colors.white : const Color(0xFFDCA7B5), borderRadius: BorderRadius.circular(2)))
                  ],
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Fri, 14 June', style: GoogleFonts.urbanist(fontWeight: FontWeight.bold)),
            Text('3 items', style: GoogleFonts.urbanist(fontSize: 11, color: Colors.grey[600])),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 60,
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
                  Text('Theory Test', style: GoogleFonts.urbanist(fontSize: 14, fontWeight: FontWeight.bold)),
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
