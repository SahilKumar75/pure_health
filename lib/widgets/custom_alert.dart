import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomAlert {
  static void show(BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'OK',
    VoidCallback? onConfirm,
    bool isCupertino = true,
  }) {
    if (isCupertino) {
      showCupertinoDialog(
        context: context,
        builder: (ctx) => CupertinoAlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            CupertinoDialogAction(
              child: Text(confirmText),
              onPressed: () {
                Navigator.of(ctx).pop();
                if (onConfirm != null) onConfirm();
              },
            ),
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              child: Text(confirmText),
              onPressed: () {
                Navigator.of(ctx).pop();
                if (onConfirm != null) onConfirm();
              },
            ),
          ],
        ),
      );
    }
  }

  // Show Create Alert Form Modal
  static void showCreateAlertForm(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
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
        return const Color(0xFF4CAF50);
      case 'Medium':
        return const Color(0xFFFFA726);
      case 'High':
        return const Color(0xFFFF7043);
      case 'Critical':
        return const Color(0xFFEF5350);
      default:
        return const Color(0xFF9E9E9E);
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
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: 250,
        color: const Color(0xFF2A2A2A),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: Text(
                      'Cancel',
                      style: TextStyle(color: Colors.white.withOpacity(0.6)),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: const Text(
                      'Done',
                      style: TextStyle(
                        color: Color(0xFF667EEA),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoPicker(
                backgroundColor: const Color(0xFF2A2A2A),
                itemExtent: 40,
                onSelectedItemChanged: (index) {
                  setState(() {
                    _selectedAlertType = _alertTypes[index];
                  });
                },
                scrollController: FixedExtentScrollController(
                  initialItem: _alertTypes.indexOf(_selectedAlertType),
                ),
                children: _alertTypes.map((type) {
                  return Center(
                    child: Text(
                      type,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Color(0xFF2A2A2A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
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
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.white.withOpacity(0.95),
                    fontFamily: 'SF Pro',
                  ),
                ),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => Navigator.of(context).pop(),
                  child: Icon(
                    CupertinoIcons.xmark_circle_fill,
                    color: Colors.white.withOpacity(0.6),
                    size: 28,
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            color: Colors.white.withOpacity(0.1),
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
                    _buildCupertinoPicker(
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
                      child: CupertinoButton(
                        color: const Color(0xFF667EEA),
                        borderRadius: BorderRadius.circular(16),
                        onPressed: _submitAlert,
                        child: const Text(
                          'Publish Alert',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'SF Pro',
                          ),
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
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: Colors.white.withOpacity(0.95),
        fontFamily: 'SF Pro',
      ),
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
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white.withOpacity(0.7),
            fontFamily: 'SF Pro',
          ),
        ),
        const SizedBox(height: 8),
        CupertinoTextFormFieldRow(
          controller: controller,
          placeholder: placeholder,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF3E3E3E),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFF525252).withOpacity(0.3),
              width: 1,
            ),
          ),
          style: const TextStyle(
            fontSize: 16,
            color: Colors.white,
            fontFamily: 'SF Pro',
          ),
          placeholderStyle: TextStyle(
            fontSize: 16,
            color: Colors.white.withOpacity(0.4),
            fontFamily: 'SF Pro',
          ),
        ),
      ],
    );
  }

  Widget _buildCupertinoPicker({
    required String value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF3E3E3E),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF525252).withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontFamily: 'SF Pro',
              ),
            ),
            Icon(
              CupertinoIcons.chevron_down,
              color: Colors.white.withOpacity(0.6),
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
        color: const Color(0xFF3E3E3E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF525252).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: _riskLevels.map((risk) {
          final isSelected = _selectedRiskLevel == risk;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: CupertinoButton(
                padding: const EdgeInsets.symmetric(vertical: 12),
                color: isSelected ? _getRiskColor(risk) : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                onPressed: () {
                  setState(() {
                    _selectedRiskLevel = risk;
                  });
                },
                child: Text(
                  risk,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? Colors.white
                        : Colors.white.withOpacity(0.6),
                    fontFamily: 'SF Pro',
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
