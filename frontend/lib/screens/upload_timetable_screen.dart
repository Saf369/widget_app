import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import 'package:file_picker/file_picker.dart';
import '../models/schedule.dart';
import '../services/api_service.dart';

class UploadTimetableScreen extends StatefulWidget {
  final VoidCallback onUpload;
  final VoidCallback onSkip;

  const UploadTimetableScreen({
    super.key,
    required this.onUpload,
    required this.onSkip,
  });

  @override
  State<UploadTimetableScreen> createState() => _UploadTimetableScreenState();
}

class _UploadTimetableScreenState extends State<UploadTimetableScreen> {
  PlatformFile? _selectedFile;
  bool _isUploading = false;
  String _uploadStatusMessage = 'Analyzing your timetable with Gemini AI...';

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg', 'webp'],
        withData: true,
      );

      if (result != null) {
        setState(() {
          _selectedFile = result.files.first;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick file: $e')),
        );
      }
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  Future<void> _handleUpload() async {
    if (_selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a PDF or image file first.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isUploading = true;
      _uploadStatusMessage = 'Sending file to backend...';
    });

    try {
      setState(() {
        _uploadStatusMessage = 'Extracting schedule with AI...';
      });

      final data = await ApiService.uploadTimetable(_selectedFile!);
      final bool isTimetable = data['is_timetable'] == true;

      if (isTimetable) {
        final List<dynamic> entriesData = data['entries'] ?? [];
        final entries = entriesData
            .map((e) => TimetableEntry.fromJson(e as Map<String, dynamic>))
            .toList();

        if (entries.isEmpty) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('No class sessions found in the timetable.'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        } else {
          // Save and broadcast to all screens
          await updateGlobalTimetable(entries);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check_circle_rounded, color: Colors.white),
                    const SizedBox(width: 8),
                    Expanded(child: Text('Loaded ${entries.length} classes into your schedule!')),
                  ],
                ),
                backgroundColor: const Color(0xFF1E7E34),
                behavior: SnackBarBehavior.floating,
              ),
            );

            // If this screen was pushed onto the navigation stack, pop back; else continue flow
            if (Navigator.canPop(context)) {
              Navigator.pop(context, true);
            } else {
              widget.onUpload();
            }
          }
        }
      } else {
        final String reason = data['reasoning'] ?? 'The uploaded file does not look like a timetable.';
        if (mounted) {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Color(0xFFE57E24), size: 28),
                  const SizedBox(width: 8),
                  Text('Not a Timetable', style: GoogleFonts.urbanist(fontWeight: FontWeight.w700)),
                ],
              ),
              content: Text(
                reason,
                style: GoogleFonts.urbanist(fontSize: 15, height: 1.4, color: const Color(0xFF333333)),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text('Try Another File', style: GoogleFonts.urbanist(fontWeight: FontWeight.w600, color: const Color(0xFF111111))),
                ),
              ],
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            title: Row(
              children: [
                const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 28),
                const SizedBox(width: 8),
                Text('Upload Failed', style: GoogleFonts.urbanist(fontWeight: FontWeight.w700)),
              ],
            ),
            content: Text(
              e.toString().replaceAll('Exception:', '').trim(),
              style: GoogleFonts.urbanist(fontSize: 15, height: 1.4, color: const Color(0xFF333333)),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  _showServerSettingsDialog();
                },
                child: Text('Server Settings', style: GoogleFonts.urbanist(fontWeight: FontWeight.w600, color: const Color(0xFF5A4E80))),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text('Dismiss', style: GoogleFonts.urbanist(fontWeight: FontWeight.w600, color: const Color(0xFF111111))),
              ),
            ],
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  Future<void> _showServerSettingsDialog() async {
    final currentCustom = await ApiService.getCustomBaseUrl();
    final controller = TextEditingController(text: currentCustom ?? '');

    if (!mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            const Icon(Icons.dns_rounded, color: Color(0xFF5A4E80)),
            const SizedBox(width: 8),
            Text('Backend Server', style: GoogleFonts.urbanist(fontWeight: FontWeight.w700, fontSize: 18)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter your computer\'s IP or custom server URL (default: http://127.0.0.1:8000 via USB or http://192.168.1.39:8000 via Wi-Fi):',
              style: GoogleFonts.urbanist(fontSize: 13, color: const Color(0xFF555555)),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'e.g. http://192.168.1.39:8000',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await ApiService.setCustomBaseUrl('');
              if (ctx.mounted) Navigator.pop(ctx);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Reset to auto-detecting endpoints.')),
                );
              }
            },
            child: Text('Auto Detect', style: GoogleFonts.urbanist(color: Colors.grey[700])),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF141414),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: () async {
              await ApiService.setCustomBaseUrl(controller.text);
              if (ctx.mounted) Navigator.pop(ctx);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Server URL set to: ${controller.text.isEmpty ? "Auto Detect" : controller.text}')),
                );
              }
            },
            child: Text('Save', style: GoogleFonts.urbanist(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasFile = _selectedFile != null;
    final fileName = _selectedFile?.name ?? '';
    final isPdf = fileName.toLowerCase().endsWith('.pdf');

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFE5DEEE), // Soft purple top left
              Color(0xFFF9F5F1), // Soft beige middle
              Color(0xFFE4DCE7), // Soft purple bottom right
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top Navigation Bar
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () {
                              if (Navigator.canPop(context)) {
                                Navigator.pop(context);
                              } else {
                                widget.onSkip();
                              }
                            },
                            child: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.6),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Color(0xFF141414)),
                            ),
                          ),
                          Row(
                            children: [
                              GestureDetector(
                                onTap: _showServerSettingsDialog,
                                child: Container(
                                  width: 44,
                                  height: 44,
                                  margin: const EdgeInsets.only(right: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.6),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.dns_rounded, size: 20, color: Color(0xFF141414)),
                                ),
                              ),
                              GestureDetector(
                                onTap: widget.onSkip,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.6),
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  child: Text(
                                    'Skip',
                                    style: GoogleFonts.urbanist(fontSize: 16, fontWeight: FontWeight.w500, color: const Color(0xFF141414)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Headers
                      Text(
                        'AI Timetable Scanner',
                        style: GoogleFonts.urbanist(fontSize: 18, fontWeight: FontWeight.w400, color: const Color(0xFF6E5A62)),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Upload your\ntimetable',
                        style: GoogleFonts.urbanist(fontSize: 46, fontWeight: FontWeight.w400, color: const Color(0xFF141414), height: 1.1),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Add a PDF, PNG or photo and Gemini AI will\nextract your schedule instantly.',
                        style: GoogleFonts.urbanist(fontSize: 15, fontWeight: FontWeight.w400, color: const Color(0xFF6E5A62), height: 1.4),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Upload Box
                      GestureDetector(
                        onTap: _isUploading ? null : _pickFile,
                        child: CustomPaint(
                          painter: _DashedRectPainter(color: hasFile ? const Color(0xFF7A6B94) : const Color(0xFFAAA3B0)),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
                            decoration: BoxDecoration(
                              color: hasFile ? Colors.white.withOpacity(0.5) : Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(32),
                            ),
                            child: Column(
                              children: [
                                Container(
                                  width: 64,
                                  height: 64,
                                  decoration: BoxDecoration(
                                    color: hasFile ? const Color(0xFFDBD3EE) : const Color(0xFFC7B9DD),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    hasFile
                                        ? (isPdf ? Icons.picture_as_pdf_rounded : Icons.image_rounded)
                                        : Icons.arrow_upward_rounded,
                                    color: const Color(0xFF141414),
                                    size: 30,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  hasFile ? 'File Selected' : 'Tap to select timetable',
                                  style: GoogleFonts.urbanist(fontSize: 22, fontWeight: FontWeight.w600, color: const Color(0xFF141414)),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  hasFile ? fileName : 'Supports PDF, PNG, JPG, or WEBP',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.urbanist(
                                    fontSize: 14,
                                    fontWeight: hasFile ? FontWeight.w600 : FontWeight.w400,
                                    color: hasFile ? const Color(0xFF4A3E5C) : const Color(0xFF6E5A62),
                                  ),
                                ),
                                if (hasFile && _selectedFile!.size > 0) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    _formatFileSize(_selectedFile!.size),
                                    style: GoogleFonts.urbanist(fontSize: 12, color: const Color(0xFF867880)),
                                  ),
                                ],
                                const SizedBox(height: 20),
                                // Format tags
                                const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _FormatTag('PDF'),
                                    SizedBox(width: 8),
                                    _FormatTag('PNG'),
                                    SizedBox(width: 8),
                                    _FormatTag('JPG'),
                                    SizedBox(width: 8),
                                    _FormatTag('WEBP'),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Secondary Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: _isUploading ? null : _pickFile,
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.6),
                                  borderRadius: BorderRadius.circular(32),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 24, height: 24,
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.photo_library_outlined, size: 14, color: Color(0xFF141414)),
                                    ),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: Text(
                                        'Pick image', 
                                        style: GoogleFonts.urbanist(fontSize: 15, fontWeight: FontWeight.w500, color: const Color(0xFF141414)),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: GestureDetector(
                              onTap: _isUploading ? null : _pickFile,
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.6),
                                  borderRadius: BorderRadius.circular(32),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 24, height: 24,
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.picture_as_pdf_outlined, size: 14, color: Color(0xFF141414)),
                                    ),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: Text(
                                        'Pick PDF', 
                                        style: GoogleFonts.urbanist(fontSize: 15, fontWeight: FontWeight.w500, color: const Color(0xFF141414)),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      const Spacer(),

                      if (_isUploading) ...[
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: Center(
                            child: Text(
                              _uploadStatusMessage,
                              style: GoogleFonts.urbanist(fontSize: 14, fontWeight: FontWeight.w500, color: const Color(0xFF4A3E5C)),
                            ),
                          ),
                        ),
                      ],
                      
                      // Primary Action Button
                      GestureDetector(
                        onTap: _isUploading ? null : _handleUpload,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF111111),
                            borderRadius: BorderRadius.circular(40),
                            boxShadow: hasFile 
                                ? [BoxShadow(color: const Color(0xFFC7B9DD).withOpacity(0.5), blurRadius: 20, offset: const Offset(0, 8))]
                                : [],
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 16.0),
                                  child: Text(
                                    _isUploading ? 'Extracting Schedule...' : (hasFile ? 'Process with AI' : 'Upload timetable'),
                                    style: GoogleFonts.urbanist(fontSize: 17, fontWeight: FontWeight.w500, color: Colors.white),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                              Container(
                                width: 48,
                                height: 48,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: _isUploading
                                    ? const Padding(
                                        padding: EdgeInsets.all(12.0),
                                        child: CircularProgressIndicator(color: Color(0xFF141414), strokeWidth: 2),
                                      )
                                    : const Icon(Icons.arrow_forward_rounded, color: Color(0xFF141414)),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Footer Text
                      Center(
                        child: Text(
                          'You can always re-upload later in Settings or Home',
                          style: GoogleFonts.urbanist(fontSize: 14, fontWeight: FontWeight.w400, color: const Color(0xFF867880)),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FormatTag extends StatelessWidget {
  final String text;
  const _FormatTag(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: GoogleFonts.urbanist(fontSize: 12, fontWeight: FontWeight.w500, color: const Color(0xFF141414)),
      ),
    );
  }
}

class _DashedRectPainter extends CustomPainter {
  final Color color;
  static const double strokeWidth = 1.5;
  static const double gap = 5.0;
  static const double dashWidth = 6.0;
  static const double radius = 24.0;

  _DashedRectPainter({
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final RRect rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(radius),
    );

    Path path = Path()..addRRect(rrect);
    Path dashPath = Path();

    for (PathMetric pathMetric in path.computeMetrics()) {
      double distance = 0.0;
      bool draw = true;
      while (distance < pathMetric.length) {
        final double length = draw ? dashWidth : gap;
        if (draw) {
          dashPath.addPath(
            pathMetric.extractPath(distance, distance + length),
            Offset.zero,
          );
        }
        distance += length;
        draw = !draw;
      }
    }

    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
