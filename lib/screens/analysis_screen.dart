import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../providers/bp_provider.dart';
import '../utils/localization.dart';
import '../models/bp_record.dart';

class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({Key? key}) : super(key: key);

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  String _selectedPeriod = 'week';

  @override
  Widget build(BuildContext context) {
    return Consumer<BPProvider>(
      builder: (context, provider, child) {
        final lang = provider.languageCode;
        final records = provider.getRecordsForPeriod(_selectedPeriod);
        final averages = provider.getAverages(records);

        return Scaffold(
          backgroundColor: const Color(0xFFF5F7FA),
          body: SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildTopNavbar(context, AppStrings.get('bp_trends', lang)),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                const SizedBox(height: 16),

                // Period Selector
                _buildPeriodSelector(lang),

                const SizedBox(height: 24),

                // Chart
                if (records.isNotEmpty)
                  _buildChart(records)
                else
                  _buildEmptyChart(lang),

                const SizedBox(height: 24),

                // Averages
                _buildAverages(averages, records, lang),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: _buildBottomNav(context, lang),
        );
      },
    );
  }

  Widget _buildPeriodSelector(String lang) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(4),
        child: Row(
          children: [
            _buildPeriodButton('week', AppStrings.get('week', lang)),
            _buildPeriodButton('month', AppStrings.get('month', lang)),
            _buildPeriodButton('year', AppStrings.get('year', lang)),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodButton(String period, String label) {
    final isSelected = _selectedPeriod == period;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedPeriod = period),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color.fromARGB(255, 16, 155, 130) : null,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? Colors.white : const Color(0xFF95A5A6),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChart(List<BPRecord> records) {
    if (records.isEmpty) return const SizedBox.shrink();

    final now = DateTime.now();
    DateTime startDate;
    double maxX;

    if (_selectedPeriod == 'week') {
      startDate = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 6));
      maxX = 6;
    } else if (_selectedPeriod == 'month') {
      startDate = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 29));
      maxX = 29;
    } else {
      startDate = DateTime(now.year, now.month - 11, 1);
      maxX = 11;
    }

    Map<int, List<BPRecord>> groupedData = {};
    for (var record in records) {
      if (record.timestamp.isBefore(startDate)) continue;
      
      int index;
      if (_selectedPeriod == 'year') {
        index = (record.timestamp.year - startDate.year) * 12 + record.timestamp.month - startDate.month;
      } else {
        index = DateTime(record.timestamp.year, record.timestamp.month, record.timestamp.day)
            .difference(startDate).inDays;
      }
      
      if (index >= 0 && index <= maxX.toInt()) {
        groupedData.putIfAbsent(index, () => []);
        groupedData[index]!.add(record);
      }
    }

    List<FlSpot> systolicSpots = [];
    List<FlSpot> diastolicSpots = [];

    final sortedKeys = groupedData.keys.toList()..sort();
    for (int i in sortedKeys) {
      final dayRecords = groupedData[i]!;
      final avgSys = dayRecords.map((e) => e.systolic).reduce((a, b) => a + b) / dayRecords.length;
      final avgDia = dayRecords.map((e) => e.diastolic).reduce((a, b) => a + b) / dayRecords.length;
      systolicSpots.add(FlSpot(i.toDouble(), avgSys));
      diastolicSpots.add(FlSpot(i.toDouble(), avgDia));
    }

    if (systolicSpots.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      height: 320,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.fromLTRB(16, 24, 24, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 11, 118, 99).withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem('Systolic', const Color.fromARGB(255, 11, 118, 99)),
              const SizedBox(width: 24),
              _buildLegendItem('Diastolic', const Color(0xFF64748B)),
            ],
          ),
          const SizedBox(height: 30),
          Expanded(
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: maxX,
                lineTouchData: LineTouchData(
                  handleBuiltInTouches: true,
                  getTouchedSpotIndicator: (LineChartBarData barData, List<int> spotIndexes) {
                    return spotIndexes.map((spotIndex) {
                      return TouchedSpotIndicatorData(
                        const FlLine(color: Color(0xFF94A3B8), strokeWidth: 1.5, dashArray: [4, 4]),
                        FlDotData(
                          getDotPainter: (spot, percent, barData, index) {
                            return FlDotCirclePainter(
                              radius: 5,
                              color: Colors.white,
                              strokeWidth: 3,
                              strokeColor: barData.color ?? const Color(0xFF1E293B),
                            );
                          },
                        ),
                      );
                    }).toList();
                  },
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (touchedSpot) => const Color(0xFF0F172A).withOpacity(0.85),
                    tooltipPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                    tooltipMargin: 8,
                    fitInsideHorizontally: true,
                    fitInsideVertically: true,
                    getTooltipItems: (List<LineBarSpot> touchedSpots) {
                      return touchedSpots.map((spot) {
                        final isSystolic = spot.barIndex == 0;
                        
                        DateTime date;
                        if (_selectedPeriod == 'year') {
                          date = DateTime(startDate.year, startDate.month + spot.x.toInt(), 1);
                        } else {
                          date = startDate.add(Duration(days: spot.x.toInt()));
                        }
                        
                        // Only show date on the first item to avoid duplicating it
                        final dateStr = spot == touchedSpots.first 
                            ? (_selectedPeriod == 'year' 
                                ? DateFormat('MMMM yyyy').format(date)
                                : DateFormat('MMM d, yyyy').format(date)) + '\n'
                            : '';

                        if (isSystolic) {
                          return LineTooltipItem(
                            '$dateStr',
                            const TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.w600, fontSize: 12),
                            children: [
                              TextSpan(
                                text: 'Sys: ${spot.y.toInt()}',
                                style: const TextStyle(color: Color(0xFF2DD4BF), fontWeight: FontWeight.w900, fontSize: 15),
                              ),
                            ]
                          );
                        } else {
                          return LineTooltipItem(
                            'Dia: ${spot.y.toInt()}',
                            const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 15),
                          );
                        }
                      }).toList();
                    },
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 20,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: const Color(0xFFF1F5F9), 
                      strokeWidth: 1.5,
                      dashArray: [4, 4],
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 36,
                      interval: 40,
                      getTitlesWidget: (value, meta) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Text(
                            value.toInt().toString(),
                            style: const TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      interval: _selectedPeriod == 'week' ? 1 
                              : _selectedPeriod == 'month' ? 6 
                              : 1,
                      getTitlesWidget: (value, meta) {
                        if (value < 0 || value > maxX) return const SizedBox.shrink();
                        
                        String label = '';
                        if (_selectedPeriod == 'week') {
                          final date = startDate.add(Duration(days: value.toInt()));
                          label = DateFormat('E').format(date); // Mon, Tue
                        } else if (_selectedPeriod == 'month') {
                          final date = startDate.add(Duration(days: value.toInt()));
                          label = DateFormat('MMM d').format(date); // Oct 1, Oct 7
                        } else {
                          final date = DateTime(startDate.year, startDate.month + value.toInt(), 1);
                          label = DateFormat('MMM').format(date)[0]; // J, F, M
                        }
                        
                        return Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Text(
                            label,
                            style: const TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minY: 40,
                maxY: 200,
                lineBarsData: [
                  LineChartBarData(
                    spots: systolicSpots,
                    isCurved: true,
                    curveSmoothness: 0.35,
                    color: const Color.fromARGB(255, 16, 155, 130),
                    barWidth: 2.5,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      checkToShowDot: (spot, barData) => true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 3.5,
                          color: Colors.white,
                          strokeWidth: 2,
                          strokeColor: const Color.fromARGB(255, 16, 155, 130),
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          const Color.fromARGB(255, 16, 155, 130).withOpacity(0.12),
                          const Color.fromARGB(255, 16, 155, 130).withOpacity(0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  LineChartBarData(
                    spots: diastolicSpots,
                    isCurved: true,
                    curveSmoothness: 0.35,
                    color: const Color(0xFF64748B),
                    barWidth: 2.5,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      checkToShowDot: (spot, barData) => true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 3.5,
                          color: Colors.white,
                          strokeWidth: 2,
                          strokeColor: const Color(0xFF64748B),
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF64748B).withOpacity(0.12),
                          const Color(0xFF64748B).withOpacity(0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: const Color(0xFF2C3E50),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyChart(String lang) {
    return Container(
      height: 280,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.show_chart,
              size: 60,
              color: const Color(0xFF95A5A6).withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No data for this period',
              style: TextStyle(fontSize: 16, color: const Color(0xFF95A5A6)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAverages(Map<String, double> averages, List<BPRecord> records, String lang) {
    if (records.isEmpty) return const SizedBox.shrink();
    
    int maxSys = records.map((r) => r.systolic).reduce((a, b) => a > b ? a : b);
    int minSys = records.map((r) => r.systolic).reduce((a, b) => a < b ? a : b);
    int maxDia = records.map((r) => r.diastolic).reduce((a, b) => a > b ? a : b);
    int minDia = records.map((r) => r.diastolic).reduce((a, b) => a < b ? a : b);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 8, bottom: 6),
            child: Text(
              'AVERAGE READINGS',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
                color: Color(0xFF94A3B8),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatTile(
                  label: AppStrings.get('avg_systolic', lang),
                  value: averages['systolic']! > 0 ? averages['systolic']!.toInt().toString() : '--',
                  min: minSys.toString(),
                  max: maxSys.toString(),
                  color: const Color(0xFF109B82),
                  icon: Icons.bloodtype,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatTile(
                  label: AppStrings.get('avg_diastolic', lang),
                  value: averages['diastolic']! > 0 ? averages['diastolic']!.toInt().toString() : '--',
                  min: minDia.toString(),
                  max: maxDia.toString(),
                  color: const Color(0xFF64748B),
                  icon: Icons.favorite_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.analytics_rounded, size: 16, color: Color(0xFF94A3B8)),
                  const SizedBox(width: 8),
                  Text(
                    'Analyzed from ${records.length} readings',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatTile({
    required String label,
    required String value,
    required String min,
    required String max,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withOpacity(0.15), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon & Label
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Large Value
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF1E293B),
                  letterSpacing: -1,
                  height: 1.0,
                ),
              ),
              const SizedBox(width: 4),
              const Text(
                'mmHg',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Compact Min/Max Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text('MIN', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF94A3B8))),
                    const SizedBox(width: 4),
                    Text(min, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF64748B))),
                  ],
                ),
                Container(width: 1, height: 14, color: const Color(0xFFCBD5E1)),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text('MAX', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF94A3B8))),
                    const SizedBox(width: 4),
                    Text(max, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF64748B))),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context, String lang) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 66,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(
                icon: Icons.history,
                label: AppStrings.get('history', lang),
                isActive: false,
                onTap: () => Navigator.pushNamed(context, '/dashboard'),
              ),

              // 👇 Pull button upward
              Transform.translate(
                offset: const Offset(0, -20),
                child: _buildAddButton(context),
              ),

              _buildNavItem(
                icon: Icons.analytics_outlined,
                label: AppStrings.get('analytics', lang),
                isActive: true,
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 6,
        ), // 👈 reduced
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 22, // 👈 slightly smaller
              color: isActive
                  ? Color.fromARGB(255, 16, 155, 130)
                  : Color.fromARGB(255, 150, 182, 176),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 11, // 👈 slightly smaller
                color: isActive
                    ? Color.fromARGB(255, 16, 155, 130)
                    : Color.fromARGB(255, 150, 182, 176),
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddButton(BuildContext context) {
    return SizedBox(
      width: 78,
      height: 78,
      child: Container(
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 16, 155, 130),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Color.fromARGB(255, 16, 155, 130).withOpacity(0.15),
              blurRadius: 14,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          child: InkWell(
            onTap: () => Navigator.pushNamed(context, '/add'),
            customBorder: const CircleBorder(),
            child: const Center(
              child: Icon(Icons.add, color: Colors.white, size: 34),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopNavbar(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.pop(context),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded, 
                color: Color(0xFF1E293B), 
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1E293B),
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }
}

