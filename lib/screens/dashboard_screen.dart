import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppStrings.get('app_title', lang),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4A90E2).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    lang.toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF4A90E2),
                    ),
                  ),
                ),
              ],
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.language),
                onPressed: () => provider.toggleLanguage(),
                tooltip: 'Switch Language',
              ),
            ],
          ),
          body: provider.isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    color: const Color(0xFF4A90E2),
                  ),
                )
              : provider.records.isEmpty
              ? _buildEmptyState(lang)
              : _buildRecordsList(provider, lang),
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
      padding: const EdgeInsets.symmetric(vertical: 16),
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
}
