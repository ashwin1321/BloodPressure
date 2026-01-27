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
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              AppStrings.get('bp_trends', lang),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2C3E50),
              ),
            ),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
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
                _buildAverages(averages, lang),

                const SizedBox(height: 24),
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
            color: isSelected ? const Color(0xFF4A90E2) : null,
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
    // Take last 7 data points for better visualization
    final displayRecords = records.take(7).toList().reversed.toList();

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
      child: Column(
        children: [
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem('Systolic', const Color(0xFFE57373)),
              const SizedBox(width: 24),
              _buildLegendItem('Diastolic', const Color(0xFF4A90E2)),
            ],
          ),
          const SizedBox(height: 20),

          // Chart
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 20,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(color: Colors.grey.shade200, strokeWidth: 1);
                  },
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      interval: 20,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: TextStyle(
                            color: const Color(0xFF95A5A6),
                            fontSize: 12,
                          ),
                        );
                      },
                    ),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= 0 &&
                            value.toInt() < displayRecords.length) {
                          final record = displayRecords[value.toInt()];
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              DateFormat(
                                'E',
                              ).format(record.timestamp).substring(0, 1),
                              style: TextStyle(
                                color: const Color(0xFF95A5A6),
                                fontSize: 12,
                              ),
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minY: 40,
                maxY: 160,
                lineBarsData: [
                  // Systolic line
                  LineChartBarData(
                    spots: displayRecords.asMap().entries.map((entry) {
                      return FlSpot(
                        entry.key.toDouble(),
                        entry.value.systolic.toDouble(),
                      );
                    }).toList(),
                    isCurved: true,
                    color: const Color(0xFFE57373),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: const Color(0xFFE57373),
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: const Color(0xFFE57373).withOpacity(0.1),
                    ),
                  ),
                  // Diastolic line
                  LineChartBarData(
                    spots: displayRecords.asMap().entries.map((entry) {
                      return FlSpot(
                        entry.key.toDouble(),
                        entry.value.diastolic.toDouble(),
                      );
                    }).toList(),
                    isCurved: true,
                    color: const Color(0xFF4A90E2),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: const Color(0xFF4A90E2),
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: const Color(0xFF4A90E2).withOpacity(0.1),
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

  Widget _buildAverages(Map<String, double> averages, String lang) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildAverageCard(
              label: AppStrings.get('avg_systolic', lang),
              value: averages['systolic']!.toInt(),
              color: const Color(0xFFE57373),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildAverageCard(
              label: AppStrings.get('avg_diastolic', lang),
              value: averages['diastolic']!.toInt(),
              color: const Color(0xFF4A90E2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAverageCard({
    required String label,
    required int value,
    required Color color,
  }) {
    return Container(
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
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: const Color(0xFF95A5A6),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value > 0 ? '$value' : '--',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'mmHg',
            style: TextStyle(fontSize: 12, color: const Color(0xFF95A5A6)),
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
                  ? const Color(0xFF4A90E2)
                  : const Color(0xFF95A5A6),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 11, // 👈 slightly smaller
                color: isActive
                    ? const Color(0xFF4A90E2)
                    : const Color(0xFF95A5A6),
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
          color: const Color(0xFF4A90E2),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4A90E2).withOpacity(0.15),
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
}
