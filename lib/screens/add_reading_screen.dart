import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
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
  bool _isLoading = false;

  @override
  void dispose() {
    _systolicController.dispose();
    _diastolicController.dispose();
    super.dispose();
  }

  Future<void> _saveRecord() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final systolic = int.parse(_systolicController.text);
    final diastolic = int.parse(_diastolicController.text);

    final provider = Provider.of<BPProvider>(context, listen: false);
    await provider.addRecord(systolic, diastolic);

    setState(() => _isLoading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.get('success_add', provider.languageCode)),
          backgroundColor: const Color.fromARGB(255, 8, 35, 66),
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
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              AppStrings.get('add_data', lang),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2C3E50),
              ),
            ),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),

                  // Illustration
                  Center(
                    child: Container(
                      width: 100,
                      height: 100,
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
                        size: 50,
                        color: Color.fromARGB(255, 16, 155, 130),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Systolic Input
                  Text(
                    '${AppStrings.get('systolic', lang)} (${AppStrings.get('mmHg', lang)})',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF2C3E50),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _systolicController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(3),
                    ],
                    style: TextStyle(
                      fontSize: 24,
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
                        vertical: 20,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppStrings.get('validation_error', lang);
                      }
                      final intValue = int.tryParse(value);
                      if (intValue == null || intValue < 70 || intValue > 200) {
                        return 'Enter value between 70-200';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 24),

                  // Diastolic Input
                  Text(
                    '${AppStrings.get('diastolic', lang)} (${AppStrings.get('mmHg', lang)})',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF2C3E50),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _diastolicController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(3),
                    ],
                    style: TextStyle(
                      fontSize: 24,
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
                        vertical: 20,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppStrings.get('validation_error', lang);
                      }
                      final intValue = int.tryParse(value);
                      if (intValue == null || intValue < 40 || intValue > 130) {
                        return 'Enter value between 40-130';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 40),

                  // Save Button
                  ElevatedButton(
                    onPressed: _isLoading ? null : _saveRecord,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 16, 155, 130),
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
                      padding: const EdgeInsets.symmetric(vertical: 18),
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

                  const SizedBox(height: 20),

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
        );
      },
    );
  }
}
