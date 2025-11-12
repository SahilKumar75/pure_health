import 'package:flutter/material.dart';
import 'package:pure_health/core/constants/color_constants.dart';
import 'package:pure_health/core/theme/text_styles.dart';

class FilterChipsWidget extends StatelessWidget {
  final String? selectedDistrict;
  final String? selectedType;
  final List<String> availableDistricts;
  final Function(String?) onDistrictChanged;
  final Function(String?) onTypeChanged;

  const FilterChipsWidget({
    super.key,
    required this.selectedDistrict,
    required this.selectedType,
    required this.availableDistricts,
    required this.onDistrictChanged,
    required this.onTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.end,
      children: [
        // District Filter Chip
        if (selectedDistrict != null)
          _buildActiveChip(
            label: selectedDistrict!,
            onDelete: () => onDistrictChanged(null),
            color: AppColors.primaryBlue,
          )
        else
          _buildInactiveChip(
            label: 'District',
            icon: Icons.location_city,
            onTap: () => _showDistrictPicker(context),
            color: AppColors.primaryBlue,
          ),
        
        // Type Filter Chip
        if (selectedType != null)
          _buildActiveChip(
            label: selectedType!,
            onDelete: () => onTypeChanged(null),
            color: AppColors.accentPink,
          )
        else
          _buildInactiveChip(
            label: 'Type',
            icon: Icons.water,
            onTap: () => _showTypePicker(context),
            color: AppColors.accentPink,
          ),
      ],
    );
  }

  Widget _buildActiveChip({
    required String label,
    required VoidCallback onDelete,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onDelete,
            child: const Icon(
              Icons.close,
              color: Colors.white,
              size: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInactiveChip({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    required Color color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDistrictPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        margin: const EdgeInsets.all(16),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.6,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'Select District',
                style: AppTextStyles.heading3.copyWith(
                  color: AppColors.charcoal,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Divider(height: 1, color: AppColors.darkCream),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: availableDistricts.map((district) {
                  return ListTile(
                    title: Text(district),
                    onTap: () {
                      Navigator.pop(context);
                      onDistrictChanged(district);
                    },
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTypePicker(BuildContext context) {
    final types = ['Surface Water', 'Groundwater'];
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'Select Water Type',
                style: AppTextStyles.heading3.copyWith(
                  color: AppColors.charcoal,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Divider(height: 1, color: AppColors.darkCream),
            ...types.map((type) {
              return ListTile(
                title: Text(type),
                onTap: () {
                  Navigator.pop(context);
                  onTypeChanged(type);
                },
              );
            }),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
