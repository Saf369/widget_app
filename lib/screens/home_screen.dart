import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
            height: constraints.maxHeight.floorToDouble(),
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
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPersistentHeader(
                pinned: true,
                delegate: _HomeHeaderDelegate(),
              ),
              SliverPadding(
                padding: const EdgeInsets.only(top: 44, bottom: 120),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  // Spatial Aptitude Card
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    child: _SpatialAptitudeCard(),
                  ),
                  const SizedBox(height: 16),
                  // Engineering Graphics Row
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    child: _CourseRow(
                      color: const Color(0xFFE8CACF),
                      iconColor: const Color(0xFFDDA9AF),
                      icon: Icons.edit_rounded,
                      title: 'Engineering Graphics',
                      subtitle: 'Application of spatial reasoning to visualize...',
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Visual Communication Row
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    child: _CourseRow(
                      color: const Color(0xFFCDE6E2),
                      iconColor: const Color(0xFFB5D8D4),
                      icon: Icons.brush_rounded,
                      title: 'Visual Communication',
                      subtitle: 'Sketching, rendering and presenting design ideas',
                      faded: true,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Architectural History Row
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 22),
                    child: _CourseRow(
                      color: Color(0xFFDBD3EE),
                      iconColor: Color(0xFFAFA2D5),
                      icon: Icons.edit_rounded,
                      title: 'Architectural History',
                      subtitle: 'Styles and movements that shaped our citi...',
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Housing Design Card
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 22),
                    child: _HousingDesignCard(),
                  ),
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
}

class _HomeHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double expandedHeight = 310;
  final double collapsedHeight = 178;

  @override
  double get minExtent => collapsedHeight;
  @override
  double get maxExtent => expandedHeight;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) => true;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final progress = (shrinkOffset / (maxExtent - minExtent)).clamp(0.0, 1.0);

    return ClipRRect(
      borderRadius: BorderRadius.vertical(
        bottom: Radius.circular(40 * progress),
      ),
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
                    // Avatar
                    Container(
                      width: 54,
                      height: 54,
                      decoration: const BoxDecoration(
                        color: Color(0xFFB9C2C7),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.person, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 12),
                    // Collapsed Title
                    if (progress > 0)
                      Expanded(
                        child: Opacity(
                          opacity: progress,
                          child: Text(
                            'Your Syllabus',
                            style: GoogleFonts.urbanist(
                              fontSize: 24,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF141414),
                            ),
                          ),
                        ),
                      )
                    else
                      const Spacer(),
                    // Search
                    const _GlassIconButton(icon: Icons.search_rounded),
                    const SizedBox(width: 8),
                    // More
                    const _GlassIconButton(child: _ThreeDots(color: Color(0xFF1A1A1A))),
                  ],
                ),
              ),
              // Expanded Text
              if (progress < 1.0)
                Expanded(
                  child: Opacity(
                    opacity: 1 - progress,
                    child: OverflowBox(
                      maxHeight: double.infinity,
                      alignment: Alignment.topCenter,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                        const SizedBox(height: 30),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 36),
                          child: Text(
                            'Hello, Anna',
                            style: GoogleFonts.urbanist(
                              fontSize: 18,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF5B5B60),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 36),
                          child: Text(
                            'Your Custom\nSyllabus',
                            style: GoogleFonts.urbanist(
                              fontSize: 48,
                              fontWeight: FontWeight.w400,
                              height: 50 / 48,
                              letterSpacing: -0.96,
                              color: const Color(0xFF141414),
                            ),
                          ),
                        ),
                      ],
                    ),
                    ),
                  ),
                ),
              if (progress == 1.0) const Spacer(),
              // Filter Row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: Row(
                  children: [
                    // Filter button
                    Container(
                      width: 38,
                      height: 38,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          _FilterLine(width: 14),
                          SizedBox(height: 4),
                          _FilterLine(width: 10),
                          SizedBox(height: 4),
                          _FilterLine(width: 6),
                        ],
                      ),
                    ),
                    const SizedBox(width: 5),
                    // Chips
                    const Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _Chip(label: 'Architecture'),
                            SizedBox(width: 8),
                            _Chip(label: 'Housing Design'),
                            SizedBox(width: 8),
                            _Chip(label: 'Building Tech'),
                          ],
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
    );
  }
}

// ── Helpers ────────────────────────────────────────────────────────────────

class _FilterLine extends StatelessWidget {
  final double width;
  const _FilterLine({required this.width});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 1.6,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(1),
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
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.55),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(0.8), width: 1),
      ),
      child: Center(
        child: child ??
            Icon(icon, color: const Color(0xFF1A1A1A), size: 22),
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
          width: 5,
          height: 5,
          margin: EdgeInsets.only(right: i < 2 ? 4 : 0),
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  const _Chip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 13),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.35),
        borderRadius: BorderRadius.circular(19),
        border: Border.all(
          color: const Color(0xFF7A7A80).withOpacity(0.55),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: GoogleFonts.urbanist(
              fontSize: 14,
              color: const Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(width: 8),
          Text('×',
              style: GoogleFonts.urbanist(
                  fontSize: 17, color: const Color(0xFF6B6B70))),
        ],
      ),
    );
  }
}

// ── Spatial Aptitude Card ──────────────────────────────────────────────────

class _SpatialAptitudeCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFCEC1DE),
        borderRadius: BorderRadius.circular(36),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 12),
          )
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Header ──────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Spatial Aptitude',
                      style: GoogleFonts.urbanist(
                        fontSize: 25,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.5,
                        color: const Color(0xFF17141E),
                        height: 1.1,
                      ),
                    ),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.4),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: _ThreeDots(color: const Color(0xFF2D2936)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Text(
                    'Visualization, transformation, and analysis of shapes in space.',
                    style: GoogleFonts.urbanist(
                      fontSize: 13,
                      height: 1.35,
                      color: const Color(0xFF5F5370),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // ── Bottom Grid ─────────────────────────────────────
          Container(
            height: 142,
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: Color(0xFFBEAFCF), width: 1),
              ),
            ),
            child: Row(
              children: [
                // Metrics Column (Flex 105)
                Expanded(
                  flex: 105,
                  child: Container(
                    decoration: const BoxDecoration(
                      border: Border(
                        right: BorderSide(color: Color(0xFFBEAFCF), width: 1),
                      ),
                    ),
                    child: Row(
                      children: [
                        // Col 1: Pages + Duration
                        Expanded(
                          child: Container(
                            decoration: const BoxDecoration(
                              border: Border(
                                right: BorderSide(color: Color(0xFFBEAFCF), width: 1),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Pages
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.only(left: 20, top: 14, bottom: 14, right: 10),
                                    decoration: const BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(color: Color(0xFFBEAFCF), width: 1),
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Pages',
                                          style: GoogleFonts.urbanist(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: const Color(0xFF6C607E),
                                            height: 1.0,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '24',
                                          style: GoogleFonts.urbanist(
                                            fontSize: 32,
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: -1,
                                            color: const Color(0xFF18151F),
                                            height: 1.0,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                // Duration
                                Container(
                                  padding: const EdgeInsets.only(left: 20, top: 12, bottom: 12, right: 6),
                                  alignment: Alignment.centerLeft,
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.access_time_rounded,
                                          size: 14,
                                          color: Color(0xFF4F4362),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '1.5 Hour',
                                          style: GoogleFonts.urbanist(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w500,
                                            color: const Color(0xFF483D5A),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Col 2: Videos
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 12, bottom: 10, top: 14, right: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  'Videos',
                                  style: GoogleFonts.urbanist(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF6C607E),
                                    height: 1.0,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '10',
                                  style: GoogleFonts.urbanist(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: -1,
                                    color: const Color(0xFF18151F),
                                    height: 1.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Artwork Column (Flex 115)
                Expanded(
                  flex: 115,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _SphereIllustrationPainter(),
                        ),
                      ),
                      Positioned(
                        bottom: 12,
                        right: 12,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            color: Color(0xFF141219),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 8,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.north_east_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                    ],
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

/// Paints the 3D abstract geometric visual with spheres and cylinders.
class _SphereIllustrationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Background Gradient
    final bgPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF7C4883), Color(0xFF683786), Color(0xFF5D2B82)],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), bgPaint);

    void drawSphere(double cx, double cy, double r,
        List<Color> colors, List<double> stops,
        {double dx = 0, double dy = 0, double blur = 0, double opacity = 1.0}) {
      if (blur > 0) {
        final shadowPaint = Paint()
          ..color = Colors.black.withOpacity(opacity)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, blur);
        canvas.drawCircle(Offset(cx + dx, cy + dy), r, shadowPaint);
      }
      final gradPaint = Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.35, -0.30),
          radius: 1.0,
          colors: colors,
          stops: stops,
        ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r));
      canvas.drawCircle(Offset(cx, cy), r, gradPaint);
    }

    // Maroon Sphere: w=105, r=52.5. cx = -12+52.5=40.5, cy = -16+52.5=36.5
    drawSphere(40.5, 36.5, 52.5,
      const [Color(0xFFE06C7C), Color(0xFF9D384C), Color(0xFF4A1523)],
      const [0.0, 0.60, 1.0],
      dx: 4, dy: 6, blur: 7.5, opacity: 0.25,
    );

    // Purple Sphere: w=125, r=62.5. cx = 8+62.5=70.5, cy = h+32-125+62.5=h-30.5
    drawSphere(70.5, h - 30.5, 62.5,
      const [Color(0xFFA453DC), Color(0xFF6E279A), Color(0xFF350B52)],
      const [0.0, 0.65, 1.0],
      dx: 4, dy: 8, blur: 9, opacity: 0.3,
    );

    // Pink Sphere: w=80, r=40. cx = w-8-40=w-48, cy = 4+40=44
    drawSphere(w - 48, 44, 40,
      const [Color(0xFFF089BE), Color(0xFFBC4D8B), Color(0xFF661A48)],
      const [0.0, 0.65, 1.0],
    );

    // Glossy Cylinders
    final cylinderShadow = Paint()
      ..color = const Color(0xFF190528).withOpacity(0.35)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

    void drawCylinder(double x, double y, double cw, double ch, double angleDeg) {
      canvas.save();
      final cx = x + cw / 2;
      final cy = y + ch / 2;
      canvas.translate(cx, cy);
      canvas.rotate(angleDeg * 3.14159265359 / 180);
      canvas.translate(-cx, -cy);

      final rect = Rect.fromLTWH(x, y, cw, ch);
      final rrect = RRect.fromRectAndRadius(rect, Radius.circular(ch / 2));
      
      canvas.drawRRect(rrect.shift(const Offset(0, 4)), cylinderShadow);
      
      final grad = Paint()
        ..shader = const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xFFDCE2EB), Color(0xFFFFFFFF), Color(0xFFF4F6FA), Color(0xFFB5BECC)],
          stops: [0.0, 0.35, 0.65, 1.0],
        ).createShader(rect);
      
      canvas.drawRRect(rrect, grad);
      canvas.restore();
    }

    // Cylinders matching the exact CSS properties
    drawCylinder(-4, 16, 112, 16, 62);
    drawCylinder(32, 20, 96, 14, 7);
    drawCylinder(w - 76, 12, 64, 14, 78);
    drawCylinder(40, 48, 80, 14, 70);
    drawCylinder(64, h - 40, 64, 12, 12);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── Course Row ────────────────────────────────────────────────────────────

class _CourseRow extends StatelessWidget {
  final Color color;
  final Color iconColor;
  final IconData icon;
  final String title;
  final String subtitle;
  final bool faded;

  const _CourseRow({
    required this.color,
    required this.iconColor,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.faded = false,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: faded ? 0.45 : 1.0,
      child: Container(
        height: 62,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(31),
          border: Border.all(color: Colors.white.withOpacity(0.6), width: 1),
        ),
        child: Stack(
          children: [
            Positioned(
              left: 3,
              top: 3,
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: iconColor,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(icon, color: Colors.white, size: 24),
                ),
              ),
            ),
            Positioned(
              left: 68,
              top: 11,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: GoogleFonts.urbanist(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF141414))),
                  const SizedBox(height: 1),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.urbanist(
                        fontSize: 12, color: const Color(0xFF6E5A62)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Housing Design Card ───────────────────────────────────────────────────

class _HousingDesignCard extends StatelessWidget {
  const _HousingDesignCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 260,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: const Color(0xFFEFCCB8),
        borderRadius: BorderRadius.circular(36),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top Section
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Housing Design',
                      style: GoogleFonts.urbanist(
                        fontSize: 24,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF141414),
                      ),
                    ),
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.4),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: _ThreeDots(color: Color(0xFF141414)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Planning homes around people, climate,\nand everyday living.',
                  style: GoogleFonts.urbanist(
                    fontSize: 14,
                    height: 1.4,
                    color: const Color(0xFF704D3F),
                  ),
                ),
              ],
            ),
          ),
          // Bottom Section
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Left Info
                Expanded(
                  flex: 1,
                  child: Stack(
                    children: [
                      // Divider lines
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: Container(height: 1, color: Colors.white.withOpacity(0.3)),
                      ),
                      Positioned(
                        top: 0,
                        bottom: 0,
                        right: 0,
                        child: Container(width: 1, color: Colors.white.withOpacity(0.3)),
                      ),
                      Positioned(
                        top: 60,
                        left: 0,
                        right: 0,
                        child: Container(height: 1, color: Colors.white.withOpacity(0.3)),
                      ),
                      // Content
                      Positioned(
                        top: 10,
                        left: 20,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Pages', style: GoogleFonts.urbanist(fontSize: 12, color: const Color(0xFF886355))),
                            Text('18', style: GoogleFonts.urbanist(fontSize: 32, fontWeight: FontWeight.w400, color: const Color(0xFF141414), height: 1.0)),
                          ],
                        ),
                      ),
                      Positioned(
                        bottom: 16,
                        left: 20,
                        child: Row(
                          children: [
                            const Icon(Icons.access_time_rounded, size: 16, color: Color(0xFF886355)),
                            const SizedBox(width: 4),
                            Text('2 Hour', style: GoogleFonts.urbanist(fontSize: 12, color: const Color(0xFF886355))),
                          ],
                        ),
                      ),
                      Positioned(
                        bottom: 16,
                        right: 16,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('Videos', style: GoogleFonts.urbanist(fontSize: 12, color: const Color(0xFF886355))),
                            Text('6', style: GoogleFonts.urbanist(fontSize: 32, fontWeight: FontWeight.w400, color: const Color(0xFF141414), height: 1.0)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Right Artwork
                Expanded(
                  flex: 1,
                  child: Container(
                    color: const Color(0xFF7EB0A3),
                    child: Stack(
                      children: [
                        // Sun
                        Positioned(
                          top: 10,
                          right: 16,
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: const BoxDecoration(color: Color(0xFFEBD08E), shape: BoxShape.circle),
                          ),
                        ),
                        // Dark Building
                        Positioned(
                          bottom: 0,
                          right: 10,
                          child: Container(
                            width: 36,
                            height: 60,
                            decoration: const BoxDecoration(
                              color: Color(0xFF1B4241),
                              borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
                            ),
                          ),
                        ),
                        // Peach Building
                        Positioned(
                          bottom: 0,
                          right: 30,
                          child: Container(
                            width: 42,
                            height: 100,
                            decoration: const BoxDecoration(
                              color: Color(0xFFEFCCB8),
                              borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [Container(width: 6, height: 6, color: Color(0xFFC09D8B)), Container(width: 6, height: 6, color: Color(0xFFC09D8B))]),
                                Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [Container(width: 6, height: 6, color: Color(0xFFC09D8B)), Container(width: 6, height: 6, color: Color(0xFFC09D8B))]),
                                Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [Container(width: 6, height: 6, color: Color(0xFFC09D8B)), Container(width: 6, height: 6, color: Color(0xFFC09D8B))]),
                                Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [Container(width: 6, height: 6, color: Color(0xFFC09D8B)), Container(width: 6, height: 6, color: Color(0xFFC09D8B))]),
                              ],
                            ),
                          ),
                        ),
                        // White Building
                        Positioned(
                          bottom: 0,
                          left: 20,
                          child: Container(
                            width: 46,
                            height: 80,
                            decoration: const BoxDecoration(
                              color: Color(0xFFEAF5F0),
                              borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [Container(width: 8, height: 8, color: Color(0xFF90C2B6)), Container(width: 8, height: 8, color: Color(0xFF90C2B6))]),
                                Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [Container(width: 8, height: 8, color: Color(0xFF90C2B6)), Container(width: 8, height: 8, color: Color(0xFF90C2B6))]),
                                Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [Container(width: 8, height: 8, color: Color(0xFF90C2B6)), Container(width: 8, height: 8, color: Color(0xFF90C2B6))]),
                              ],
                            ),
                          ),
                        ),
                        // Arrow Button
                        Positioned(
                          bottom: 16,
                          right: 16,
                          child: Container(
                            width: 34,
                            height: 34,
                            decoration: const BoxDecoration(color: Color(0xFF141414), shape: BoxShape.circle),
                            child: const Center(child: Icon(Icons.arrow_outward_rounded, color: Colors.white, size: 16)),
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
