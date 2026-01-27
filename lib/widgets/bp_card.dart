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
    final bool isToday = _isToday(record.timestamp);
    final DateFormat timeFormat = DateFormat('h:mm a');
    final DateFormat dateFormat = DateFormat('MMM dd, yyyy');

    final _BpStatus status = _bpStatus(record.systolic, record.diastolic);

    const Color valueColor = Color(0xFF2E9F8D);
    const Color slashGrey = Color(0xFF8F9CA1);
    const Color dateGrey = Color(0xFF607177);
    const Color unitGrey = Color(0xFF7B878E);

    const Color rightPanel = Color(0xFFBFEFE6);
    const Color rightPanelBorder = Color(0xFFB4E8DE);

    // Reduced width so left texts get more space
    const double rightPanelWidth = 155;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      height: 110,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 14,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          children: <Widget>[
            // Right mint panel (SOLID color, no wave)
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              width: rightPanelWidth,
              child: Container(
                decoration: BoxDecoration(
                  color: rightPanel,
                  border: Border(
                    left: BorderSide(color: rightPanelBorder.withOpacity(0.6)),
                  ),
                ),
                child: Stack(
                  children: <Widget>[
                    Positioned(
                      left: 16,
                      top: 40,
                      child: Text(
                        'mmHg',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: unitGrey.withOpacity(0.75),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Left content
            Padding(
              padding: const EdgeInsets.fromLTRB(
                20,
                14,
                rightPanelWidth + 12,
                14,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // Numbers: systolic & diastolic ALWAYS same size (scaled together)
                  Expanded(
                    flex: 4,
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.bottomLeft,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            Text(
                              '${record.systolic}',
                              style: const TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.w800,
                                color: valueColor,
                                height: 1.0,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              '/',
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w300,
                                color: slashGrey,
                                height: 1.0,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${record.diastolic}',
                              style: const TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.w800,
                                color: valueColor,
                                height: 1.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Date/time
                  Expanded(
                    flex: 2,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        isToday
                            ? (languageCode == 'en' ? 'Today, ' : 'Today, ') +
                                  timeFormat.format(record.timestamp)
                            : '${dateFormat.format(record.timestamp)}, ${timeFormat.format(record.timestamp)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        softWrap: false,
                        style: const TextStyle(
                          fontSize: 12,
                          color: dateGrey,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  // Badge (slightly taller pill)
                  Expanded(
                    flex: 2,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: _StatusPill(
                        label: status.label,
                        background: status.bg,
                        foreground: status.fg,
                        icon: status.icon,
                      ),
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
    final DateTime now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
}

class _StatusPill extends StatelessWidget {
  final String label;
  final Color background;
  final Color foreground;
  final IconData icon;

  const _StatusPill({
    Key? key,
    required this.label,
    required this.background,
    required this.foreground,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      // Increased height a bit
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: foreground.withOpacity(0.25), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 15, color: foreground),
          const SizedBox(width: 6),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: foreground,
              height: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}

class _BpStatus {
  final String label;
  final Color bg;
  final Color fg;
  final IconData icon;

  const _BpStatus({
    required this.label,
    required this.bg,
    required this.fg,
    required this.icon,
  });
}

_BpStatus _bpStatus(int sys, int dia) {
  const Color normalFg = Color(0xFF16A34A);
  const Color normalBg = Color(0xFFE9F9EF);

  const Color elevatedFg = Color(0xFFD97706);
  const Color elevatedBg = Color(0xFFFFF3E6);

  const Color highFg = Color(0xFFEA580C);
  const Color highBg = Color(0xFFFFECDD);

  const Color crisisFg = Color(0xFFDC2626);
  const Color crisisBg = Color(0xFFFFE7E7);

  const Color lowFg = Color(0xFF2563EB);
  const Color lowBg = Color(0xFFEAF1FF);

  if (sys >= 180 || dia >= 120) {
    return const _BpStatus(
      label: 'Crisis',
      fg: crisisFg,
      bg: crisisBg,
      icon: Icons.warning_amber_rounded,
    );
  }

  if (sys >= 140 || dia >= 90) {
    return const _BpStatus(
      label: 'High',
      fg: highFg,
      bg: highBg,
      icon: Icons.trending_up_rounded,
    );
  }

  if (sys < 90 || dia < 60) {
    return const _BpStatus(
      label: 'Low',
      fg: lowFg,
      bg: lowBg,
      icon: Icons.trending_down_rounded,
    );
  }

  if (sys <= 129 && dia <= 80) {
    return const _BpStatus(
      label: 'Normal',
      fg: normalFg,
      bg: normalBg,
      icon: Icons.check_circle_rounded,
    );
  }

  return const _BpStatus(
    label: 'Elevated',
    fg: elevatedFg,
    bg: elevatedBg,
    icon: Icons.trending_up_rounded,
  );
}
