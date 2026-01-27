import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/bp_record.dart';

class BPCard extends StatelessWidget {
  final BPRecord record;
  final String languageCode;

  const BPCard({Key? key, required this.record, required this.languageCode})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isToday = _isToday(record.timestamp);
    final timeFormat = DateFormat('h:mm a');
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      height: 90,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Wave background on the right
            Positioned(
              right: -20,
              top: -10,
              bottom: -10,
              child: CustomPaint(
                size: Size(180, 110),
                painter: WavePainter(
                  color: const Color(0xFF50E3C2).withOpacity(0.15),
                ),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Row(
                children: [
                  // BP Values
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            // Systolic
                            Text(
                              '${record.systolic}',
                              style: TextStyle(
                                fontSize: 34,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF50E3C2),
                                height: 1.1,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '/',
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.w300,
                                color: const Color(0xFF95A5A6),
                                height: 1.1,
                              ),
                            ),
                            const SizedBox(width: 6),
                            // Diastolic
                            Text(
                              '${record.diastolic}',
                              style: TextStyle(
                                fontSize: 34,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF50E3C2),
                                height: 1.1,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          isToday
                              ? (languageCode == 'en' ? 'Today, ' : 'आज, ') +
                                    timeFormat.format(record.timestamp)
                              : dateFormat.format(record.timestamp) +
                                    ', ' +
                                    timeFormat.format(record.timestamp),
                          style: TextStyle(
                            fontSize: 13,
                            color: const Color(0xFF95A5A6),
                            fontWeight: FontWeight.w500,
                            height: 1.2,
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
      ),
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
}

// Custom painter for wave background
class WavePainter extends CustomPainter {
  final Color color;

  WavePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();

    // Start from top-left
    path.moveTo(0, size.height * 0.3);

    // Create smooth wave curves
    path.quadraticBezierTo(
      size.width * 0.25,
      size.height * 0.15,
      size.width * 0.5,
      size.height * 0.25,
    );

    path.quadraticBezierTo(
      size.width * 0.75,
      size.height * 0.35,
      size.width,
      size.height * 0.2,
    );

    // Complete the path
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(WavePainter oldDelegate) => color != oldDelegate.color;
}
