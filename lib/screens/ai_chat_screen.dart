import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AiChatScreen extends StatelessWidget {
  const AiChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF4F2F0), Color(0xFFECE8EE), Color(0xFFE0D8EC)],
          stops: [0.0, 0.6, 1.0],
        ),
        borderRadius: BorderRadius.all(Radius.circular(44)),
      ),
      child: Stack(
        children: [
          // Background glows
          Positioned(
            left: -110,
            bottom: 110,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFB79BE0).withOpacity(0.38),
              ),
            ),
          ),
          Positioned(
            right: -105,
            top: -170,
            child: Container(
              width: 330,
              height: 420,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFA8A2B2).withOpacity(0.24),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // Top bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      // Back
                      _GlassCircleButton(child: const Text('←',
                          style: TextStyle(fontSize: 22, color: Color(0xFF141414)))),
                      const Spacer(),
                      Column(
                        children: [
                          Text('AI Tutor',
                              style: GoogleFonts.urbanist(
                                fontSize: 24,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF141414),
                              )),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                  width: 7,
                                  height: 7,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF4CC38A),
                                    shape: BoxShape.circle,
                                  )),
                              const SizedBox(width: 4),
                              Text('Online · ready to help',
                                  style: GoogleFonts.urbanist(
                                      fontSize: 12,
                                      color: const Color(0xFF6C6580))),
                            ],
                          ),
                        ],
                      ),
                      const Spacer(),
                      // More
                      _GlassCircleButton(child: _ThreeDots(color: const Color(0xFF141414))),
                    ],
                  ),
                ),
                // Context chip
                Padding(
                  padding: const EdgeInsets.only(left: 16, bottom: 12),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(10, 7, 14, 7),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                            color: Colors.white.withOpacity(0.9), width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 18,
                            height: 18,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  Color(0xFFD9A8F0),
                                  Color(0xFF9A5BD0),
                                  Color(0xFF5E2E8A),
                                ],
                                stops: [0.0, 0.6, 1.0],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text('Spatial Aptitude · Lecture',
                              style: GoogleFonts.urbanist(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF3A3350))),
                        ],
                      ),
                    ),
                  ),
                ),
                // Messages
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Time label
                        Center(
                          child: Text('Today, 10:24',
                              style: GoogleFonts.urbanist(
                                  fontSize: 12,
                                  color: const Color(0xFF8A849A))),
                        ),
                        const SizedBox(height: 16),
                        // AI message 1
                        _AiMessage(
                          text: "Hi Anna! I'm your study assistant. Ask me anything about Spatial Aptitude, or I can quiz you.",
                        ),
                        const SizedBox(height: 20),
                        // User message
                        Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            width: 250,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0E0E10),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(24),
                                topRight: Radius.circular(24),
                                bottomLeft: Radius.circular(24),
                                bottomRight: Radius.circular(6),
                              ),
                            ),
                            child: Text(
                              'Can you explain mental folding in simple words?',
                              style: GoogleFonts.urbanist(
                                  fontSize: 15,
                                  height: 21 / 15,
                                  color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // AI message 2
                        _AiMessage(
                          text: "Of course! Mental folding is picturing how a flat shape would look once it's folded into 3D, like turning a paper net into a cube. Try it: which faces would touch?",
                        ),
                        const SizedBox(height: 16),
                        // Suggestion chips
                        Padding(
                          padding: const EdgeInsets.only(left: 38),
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: const [
                              _SuggestionChip(label: 'Quiz me'),
                              _SuggestionChip(label: 'Show an example'),
                              _SuggestionChip(label: 'Summarize'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Quick quiz card
                        Container(
                          height: 68,
                          decoration: BoxDecoration(
                            color: const Color(0xE6D6CBE6),
                            borderRadius: BorderRadius.circular(34),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.7), width: 1),
                          ),
                          child: Stack(
                            children: [
                              // Purple orb
                              Positioned(
                                left: 7,
                                top: 7,
                                child: Container(
                                  width: 54,
                                  height: 54,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: RadialGradient(
                                      colors: [
                                        Color(0xFFD9A8F0),
                                        Color(0xFF6A3496),
                                      ],
                                    ),
                                  ),
                                  child: const Icon(Icons.star_rounded,
                                      color: Colors.white, size: 22),
                                ),
                              ),
                              // Text
                              Positioned(
                                left: 74,
                                top: 14,
                                child: Text('Quick quiz',
                                    style: GoogleFonts.urbanist(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: const Color(0xFF141414))),
                              ),
                              Positioned(
                                left: 74,
                                top: 38,
                                child: Text('5 questions · about 3 min',
                                    style: GoogleFonts.urbanist(
                                        fontSize: 12,
                                        color: const Color(0xFF5A4E80))),
                              ),
                              // Go button
                              Positioned(
                                right: 13,
                                top: 13,
                                child: Container(
                                  width: 42,
                                  height: 42,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF0E0E10),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text('↗',
                                        style: GoogleFonts.urbanist(
                                            fontSize: 17,
                                            color: Colors.white)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
                // Input bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                  child: Container(
                    height: 64,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withOpacity(0.45),
                          Colors.white.withOpacity(0.18),
                          Colors.white.withOpacity(0.35),
                        ],
                        stops: const [0.0, 0.30, 0.80],
                      ),
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(
                          color: Colors.white.withOpacity(0.95), width: 1.2),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4D4073).withOpacity(0.18),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 9),
                        // Attach button
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.35),
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: Colors.white.withOpacity(0.8), width: 1),
                          ),
                          child: const Icon(Icons.attach_file_rounded,
                              color: Color(0xFF5B5B60), size: 20),
                        ),
                        const SizedBox(width: 10),
                        // Placeholder text
                        Expanded(
                          child: Text(
                            'Ask about your syllabus…',
                            style: GoogleFonts.urbanist(
                                fontSize: 15,
                                color: const Color(0xFF6C6580)),
                          ),
                        ),
                        // Send button
                        Container(
                          width: 46,
                          height: 46,
                          margin: const EdgeInsets.only(right: 9),
                          decoration: const BoxDecoration(
                            color: Color(0xFF0E0E10),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text('↑',
                                style: GoogleFonts.urbanist(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white)),
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

class _GlassCircleButton extends StatelessWidget {
  final Widget child;
  const _GlassCircleButton({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(0.8), width: 1),
      ),
      child: Center(child: child),
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

class _AiMessage extends StatelessWidget {
  final String text;
  const _AiMessage({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // AI Avatar
        Container(
          width: 30,
          height: 30,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [Color(0xFFD9A8F0), Color(0xFF9A5BD0), Color(0xFF5E2E8A)],
              stops: [0.0, 0.6, 1.0],
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Bubble
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.82),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(6),
                topRight: Radius.circular(24),
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
              border: Border.all(color: Colors.white, width: 1),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF66598C).withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(text,
                style: GoogleFonts.urbanist(
                    fontSize: 15,
                    height: 21 / 15,
                    color: const Color(0xFF1A1A1A))),
          ),
        ),
      ],
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  final String label;
  const _SuggestionChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.35),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
            color: const Color(0xFF7A7A80).withOpacity(0.45), width: 1),
      ),
      child: Text(label,
          style: GoogleFonts.urbanist(
              fontSize: 13, color: const Color(0xFF1A1A1A))),
    );
  }
}
