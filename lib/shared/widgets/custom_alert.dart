import 'package:flutter/material.dart';
import '../../../../core/constants/color_constants.dart';
import '../../../../core/theme/text_styles.dart';
import 'cupertino_button.dart';

class CustomAlert {
  static void show(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'OK',
    String? cancelText,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          title,
          style: AppTextStyles.heading3.copyWith(color: AppColors.charcoal),
        ),
        content: Text(
          message,
          style: AppTextStyles.body.copyWith(color: AppColors.mediumGray),
        ),
        actions: [
          if (cancelText != null)
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                if (onCancel != null) onCancel();
              },
              child: Text(
                cancelText,
                style: AppTextStyles.button.copyWith(color: AppColors.mediumGray),
              ),
            ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              if (onConfirm != null) onConfirm();
            },
            child: Text(
              confirmText,
              style: AppTextStyles.button.copyWith(color: AppColors.darkVanilla),
            ),
          ),
        ],
      ),
    );
  }

  // Show Create Alert Form Modal
  static void showCreateAlertForm(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CreateAlertForm(),
    );
  }
}

// Create Alert Form Modal
class CreateAlertForm extends StatefulWidget {
  const CreateAlertForm({Key? key}) : super(key: key);

  @override
  State<CreateAlertForm> createState() => _CreateAlertFormState();
}

class _CreateAlertFormState extends State<CreateAlertForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _rangeController = TextEditingController();

  String _selectedRiskLevel = 'Low';
  final List<String> _riskLevels = ['Low', 'Medium', 'High', 'Critical'];

  String _selectedAlertType = 'Water Quality';
  final List<String> _alertTypes = [
    'Water Quality',
    'Contamination',
    'Infrastructure',
    'Supply Issue',
    'Health Advisory',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _rangeController.dispose();
    super.dispose();
  }

  Color _getRiskColor(String risk) {
    switch (risk) {
      case 'Low':
        return AppColors.success;
      case 'Medium':
        return AppColors.warning;
      case 'High':
        return const Color(0xFFC17A6B);
      case 'Critical':
        return AppColors.error;
      default:
        return AppColors.mediumGray;
    }
  }

  void _submitAlert() {
    if (_formKey.currentState!.validate()) {
      final alertData = {
        'title': _titleController.text,
        'description': _descriptionController.text,
        'type': _selectedAlertType,
        'riskLevel': _selectedRiskLevel,
        'location': _locationController.text,
        'range': double.parse(_rangeController.text),
        'timestamp': DateTime.now().toIso8601String(),
      };

      print('Alert Data: $alertData');

      Navigator.of(context).pop();
      CustomAlert.show(
        context,
        title: 'Success',
        message: 'Alert created successfully and published to the public!',
      );
    }
  }

  void _showAlertTypePicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Select Alert Type',
          style: AppTextStyles.heading3.copyWith(color: AppColors.charcoal),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: _alertTypes.map((type) {
              return ListTile(
                title: Text(
                  type,
                  style: AppTextStyles.body.copyWith(color: AppColors.charcoal),
                ),
                onTap: () {
                  setState(() {
                    _selectedAlertType = type;
                  });
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.darkCream.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Create Public Alert',
                  style: AppTextStyles.heading2.copyWith(
                    color: AppColors.charcoal,
                  ),
                ),
                InkWell(
                  onTap: () => Navigator.of(context).pop(),
                  child: Icon(
                    Icons.close,
                    color: AppColors.mediumGray,
                    size: 28,
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            color: AppColors.darkCream.withOpacity(0.2),
          ),
          // Form content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Alert Information'),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _titleController,
                      label: 'Alert Title',
                      placeholder: 'Enter alert title',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Title is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _descriptionController,
                      label: 'Description',
                      placeholder: 'Describe the alert details',
                      maxLines: 4,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Description is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Alert Type'),
                    const SizedBox(height: 16),
                    _buildDropdown(
                      value: _selectedAlertType,
                      onTap: _showAlertTypePicker,
                    ),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Risk Level'),
                    const SizedBox(height: 16),
                    _buildRiskSelector(),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Location & Range'),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _locationController,
                      label: 'Location',
                      placeholder: 'Enter location or address',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Location is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _rangeController,
                      label: 'Affected Range (km)',
                      placeholder: 'Enter range in kilometers',
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Range is required';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Enter a valid number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),
                    // Submit button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: CupertinoButtonWidget(
                        text: 'Publish Alert',
                        onPressed: _submitAlert,
                        backgroundColor: AppColors.darkVanilla,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.heading4.copyWith(color: AppColors.charcoal),
    );
  }

Widget _buildTextField({
  required TextEditingController controller,
  required String label,
  required String placeholder,
  int maxLines = 1,
  TextInputType? keyboardType,
  String? Function(String?)? validator,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: AppTextStyles.caption.copyWith(color: AppColors.mediumGray),
      ),
      const SizedBox(height: 8),
      TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          hintText: placeholder,
          filled: true,
          fillColor: AppColors.darkCream.withOpacity(0.1),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: AppColors.darkCream.withOpacity(0.2),
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: AppColors.darkVanilla,
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.error, width: 2),
          ),
          hintStyle: AppTextStyles.body.copyWith(
            color: AppColors.mediumGray.withOpacity(0.5),
          ),
        ),
        style: AppTextStyles.body.copyWith(color: AppColors.charcoal),
      ),
    ],
  );
}


  Widget _buildDropdown({
    required String value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.darkCream.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.darkCream.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              value,
              style: AppTextStyles.body.copyWith(color: AppColors.charcoal),
            ),
            Icon(
              Icons.expand_more,
              color: AppColors.mediumGray,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRiskSelector() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.darkCream.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.darkCream.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: _riskLevels.map((risk) {
          final isSelected = _selectedRiskLevel == risk;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _selectedRiskLevel = risk;
                    });
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? _getRiskColor(risk)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        risk,
                        style: AppTextStyles.button.copyWith(
                          color: isSelected
                              ? AppColors.white
                              : AppColors.mediumGray,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
