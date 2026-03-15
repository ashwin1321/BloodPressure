import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/bp_provider.dart';
import '../utils/localization.dart';

class AddReadingScreen extends StatefulWidget {
  const AddReadingScreen({Key? key}) : super(key: key);

  @override
  State<AddReadingScreen> createState() => _AddReadingScreenState();
}

class _AddReadingScreenState extends State<AddReadingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _systolicController = TextEditingController();
  final _diastolicController = TextEditingController();
  final _dateController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final lang = Provider.of<BPProvider>(context, listen: false).languageCode;
    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    _dateController.text = '${AppStrings.get('today', lang)} ($dateStr)';
  }

  @override
  void dispose() {
    _systolicController.dispose();
    _diastolicController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: const Color.fromARGB(255, 16, 155, 130),
              onPrimary: Colors.white,
              onSurface: const Color(0xFF2C3E50),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        final now = DateTime.now();
        final isToday = DateUtils.isSameDay(picked, now);
        _selectedDate = isToday ? now : picked;

        final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
        final lang = Provider.of<BPProvider>(
          context,
          listen: false,
        ).languageCode;

        if (isToday) {
          _dateController.text = '${AppStrings.get('today', lang)} ($dateStr)';
        } else {
          _dateController.text = dateStr;
        }
      });
    }
  }

  Future<void> _saveRecord() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final systolic = int.parse(_systolicController.text);
    final diastolic = int.parse(_diastolicController.text);

    final provider = Provider.of<BPProvider>(context, listen: false);

    // If it's today, we use the current precise time for better sorting,
    // otherwise we use the selected date (which might be midnight of a past day).
    final now = DateTime.now();
    final isToday = DateUtils.isSameDay(_selectedDate, now);
    final finalDate = isToday ? now : _selectedDate;

    await provider.addRecord(systolic, diastolic, date: finalDate);

    setState(() => _isLoading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.get('success_add', provider.languageCode)),
          backgroundColor: const Color(0xFF4A90E2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BPProvider>(
      builder: (context, provider, child) {
        final lang = provider.languageCode;

        return Scaffold(
          backgroundColor: const Color(0xFFF5F7FA),
          body: SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildTopNavbar(context, AppStrings.get('add_data', lang)),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 10),

                          // Illustration
                          Center(
                            child: Container(
                              width: 90,
                              height: 90,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    const Color.fromARGB(
                                      255,
                                      16,
                                      155,
                                      130,
                                    ).withOpacity(0.2),
                                    const Color(0xFF50E3C2).withOpacity(0.2),
                                  ],
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.favorite,
                                size: 40,
                                color: Color.fromARGB(255, 16, 155, 130),
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Systolic Input
                          Text(
                            '${AppStrings.get('systolic', lang)} (${AppStrings.get('mmHg', lang)})',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF2C3E50),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _systolicController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(3),
                            ],
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF2C3E50),
                            ),
                            decoration: InputDecoration(
                              hintText: '130',
                              hintStyle: TextStyle(
                                color: const Color(0xFF95A5A6).withOpacity(0.5),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade200,
                                  width: 2,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(
                                  color: Color.fromARGB(255, 16, 155, 130),
                                  width: 2,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 14,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return AppStrings.get('validation_error', lang);
                              }
                              final intValue = int.tryParse(value);
                              if (intValue == null ||
                                  intValue < 70 ||
                                  intValue > 200) {
                                return 'Enter value between 70-200';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 16),

                          // Diastolic Input
                          Text(
                            '${AppStrings.get('diastolic', lang)} (${AppStrings.get('mmHg', lang)})',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF2C3E50),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _diastolicController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(3),
                            ],
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF2C3E50),
                            ),
                            decoration: InputDecoration(
                              hintText: '85',
                              hintStyle: TextStyle(
                                color: const Color(0xFF95A5A6).withOpacity(0.5),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade200,
                                  width: 2,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(
                                  color: Color.fromARGB(255, 16, 155, 130),
                                  width: 2,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 14,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return AppStrings.get('validation_error', lang);
                              }
                              final intValue = int.tryParse(value);
                              if (intValue == null ||
                                  intValue < 40 ||
                                  intValue > 130) {
                                return 'Enter value between 40-130';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 16),

                          // Date Input
                          Text(
                            AppStrings.get('date', lang),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF2C3E50),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _dateController,
                            readOnly: true,
                            onTap: () => _selectDate(context),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF2C3E50),
                            ),
                            decoration: InputDecoration(
                              suffixIcon: Icon(
                                Icons.calendar_today,
                                color: Color.fromARGB(255, 16, 155, 130),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade200,
                                  width: 2,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(
                                  color: Color.fromARGB(255, 16, 155, 130),
                                  width: 2,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 14,
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Save Button
                          ElevatedButton(
                            onPressed: _isLoading ? null : _saveRecord,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(
                                255,
                                16,
                                155,
                                130,
                              ),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shadowColor: const Color.fromARGB(
                                255,
                                16,
                                155,
                                130,
                              ).withOpacity(0.3),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: _isLoading
                                ? SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : Text(
                                    AppStrings.get('save_record', lang),
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),

                          const SizedBox(height: 12),

                          // Info text
                          Center(
                            child: Text(
                              'Normal BP: 120/80 mmHg',
                              style: TextStyle(
                                fontSize: 13,
                                color: const Color(0xFF95A5A6),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTopNavbar(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 24, 12),
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
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1E293B),
              letterSpacing: -1,
            ),
          ),
        ],
      ),
    );
  }
}
