import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/bp_provider.dart';
import '../utils/localization.dart';
import '../widgets/bp_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<BPProvider>(
      builder: (context, provider, child) {
        final lang = provider.languageCode;

        return Scaffold(
          backgroundColor: const Color(0xFFF5F7FA),
          body: SafeArea(
            bottom: false,
            child: provider.isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF4A90E2)),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTopNavbar(),
                      _buildHeader(provider),
                      const SizedBox(height: 12),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          'Recent History',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2C3E50),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: provider.records.isEmpty
                            ? _buildEmptyState(lang)
                            : _buildRecordsList(provider, lang),
                      ),
                    ],
                  ),
          ),
          bottomNavigationBar: _buildBottomNav(context, lang),
        );
      },
    );
  }

  Widget _buildEmptyState(String lang) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border, size: 80, color: const Color(0xFF95A5A6)),
          const SizedBox(height: 16),
          Text(
            'No records yet',
            style: TextStyle(
              fontSize: 18,
              color: const Color(0xFF95A5A6),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap + to add your first reading',
            style: TextStyle(fontSize: 14, color: const Color(0xFF95A5A6)),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordsList(BPProvider provider, String lang) {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 0, bottom: 20),
      itemCount: provider.records.length,
      itemBuilder: (context, index) {
        final record = provider.records[index];
        return BPCard(record: record, languageCode: lang);
      },
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
                isActive: true,
                onTap: () {},
              ),

              // 👇 Pull button upward
              Transform.translate(
                offset: const Offset(0, -20),
                child: _buildAddButton(context),
              ),

              _buildNavItem(
                icon: Icons.analytics_outlined,
                label: AppStrings.get('analytics', lang),
                isActive: false,
                onTap: () => Navigator.pushNamed(context, '/analytics'),
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

  Widget _buildHeader(BPProvider provider) {
    int sys = 0;
    int dia = 0;
    String status = "No Data";
    DateTime? date;

    List<Color> gradientColors = [
      const Color.fromARGB(255, 34, 184, 156),
      const Color.fromARGB(255, 11, 118, 99),
    ];
    Color shadowColor = const Color.fromARGB(
      255,
      16,
      155,
      130,
    ).withOpacity(0.35);
    String adviceMessage = "Your blood pressure is looking great!";

    if (provider.records.isNotEmpty) {
      sys = provider.records.first.systolic;
      dia = provider.records.first.diastolic;
      date = provider.records.first.timestamp;

      if (sys >= 180 || dia >= 120) {
        status = 'Crisis';
        gradientColors = [const Color(0xFFEF4444), const Color(0xFFB91C1C)];
        shadowColor = const Color(0xFFEF4444).withOpacity(0.35);
        adviceMessage = "Emergency! Please seek medical help immediately.";
      } else if (sys >= 140 || dia >= 90) {
        status = 'High';
        gradientColors = [const Color(0xFFF97316), const Color(0xFFC2410C)];
        shadowColor = const Color(0xFFF97316).withOpacity(0.35);
        adviceMessage = "High BP detected. Please visit a doctor soon.";
      } else if (sys > 130 || dia > 85) {
        status = 'Elevated';
        gradientColors = [const Color(0xFFF59E0B), const Color(0xFFB45309)];
        shadowColor = const Color(0xFFF59E0B).withOpacity(0.35);
        adviceMessage = "Elevated BP. Monitor closely and stay hydrated.";
      } else if (sys < 110 || dia < 70) {
        status = 'Low';
        gradientColors = [const Color(0xFF3B82F6), const Color(0xFF1D4ED8)];
        shadowColor = const Color(0xFF3B82F6).withOpacity(0.35);
        adviceMessage = "Low BP detected. Consult a doctor if you feel dizzy.";
      } else {
        status = 'Normal';
        gradientColors = [
          const Color.fromARGB(255, 34, 184, 156),
          const Color.fromARGB(255, 11, 118, 99),
        ];
        shadowColor = const Color.fromARGB(255, 16, 155, 130).withOpacity(0.35);
        adviceMessage = "Your blood pressure is looking great!";
      }
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (provider.records.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: gradientColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: shadowColor,
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Latest Reading',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                          if (date != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                DateFormat(
                                  'MMM dd, yyyy • hh:mm a',
                                ).format(date),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          const SizedBox(height: 12),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '$sys',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 34,
                                  fontWeight: FontWeight.w800,
                                  height: 1,
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 4.0),
                                child: Text(
                                  '/',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                              ),
                              Text(
                                '$dia',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 34,
                                  fontWeight: FontWeight.w800,
                                  height: 1,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Padding(
                                padding: EdgeInsets.only(bottom: 4),
                                child: Text(
                                  'mmHg',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              status,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            adviceMessage,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
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

  Widget _buildTopNavbar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color.fromARGB(255, 34, 184, 156),
                      Color.fromARGB(255, 11, 118, 99),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color.fromARGB(255, 16, 155, 130).withOpacity(0.35),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(Icons.favorite, color: Colors.white, size: 26),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'HeartSync',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1E293B),
                      letterSpacing: -0.5,
                      height: 1.1,
                    ),
                  ),
                  Text(
                    'Stay healthy today',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFF1F5F9), width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.notifications_none_rounded, color: Color(0xFF64748B), size: 24),
          ),
        ],
      ),
    );
  }
}
