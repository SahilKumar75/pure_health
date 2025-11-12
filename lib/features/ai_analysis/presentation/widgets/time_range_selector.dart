import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:pure_health/core/constants/color_constants.dart';
import 'package:pure_health/core/theme/text_styles.dart';

class TimeRangeSelectorWidget extends StatefulWidget {
  final DateTime? startDate;
  final DateTime? endDate;
  final Function(DateTime, DateTime) onRangeSelected;
  final VoidCallback? onClear;

  const TimeRangeSelectorWidget({
    super.key,
    this.startDate,
    this.endDate,
    required this.onRangeSelected,
    this.onClear,
  });

  @override
  State<TimeRangeSelectorWidget> createState() => _TimeRangeSelectorWidgetState();
}

class _TimeRangeSelectorWidgetState extends State<TimeRangeSelectorWidget> {
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _startDate = widget.startDate;
    _endDate = widget.endDate;
  }

  @override
  void didUpdateWidget(TimeRangeSelectorWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.startDate != oldWidget.startDate || widget.endDate != oldWidget.endDate) {
      setState(() {
        _startDate = widget.startDate;
        _endDate = widget.endDate;
      });
    }
  }

  Future<void> _selectStartDate() async {
    final now = DateTime.now();
    final sixtyDaysAgo = now.subtract(const Duration(days: 60));
    
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? sixtyDaysAgo,
      firstDate: sixtyDaysAgo,
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColors.accentPink,
              onPrimary: Colors.white,
              surface: AppColors.darkBg3,
              onSurface: AppColors.lightText,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startDate = picked;
        if (_endDate == null || _endDate!.isBefore(picked)) {
          _endDate = now;
        }
      });

      if (_endDate != null) {
        widget.onRangeSelected(_startDate!, _endDate!);
      }
    }
  }

  Future<void> _selectEndDate() async {
    final now = DateTime.now();
    final sixtyDaysAgo = now.subtract(const Duration(days: 60));
    
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? now,
      firstDate: _startDate ?? sixtyDaysAgo,
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColors.accentPink,
              onPrimary: Colors.white,
              surface: AppColors.darkBg3,
              onSurface: AppColors.lightText,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _endDate = picked;
      });

      if (_startDate != null) {
        widget.onRangeSelected(_startDate!, _endDate!);
      }
    }
  }

  void _selectLast24Hours() {
    final end = DateTime.now();
    final start = end.subtract(const Duration(hours: 24));
    setState(() {
      _startDate = start;
      _endDate = end;
    });
    widget.onRangeSelected(start, end);
  }

  void _selectLast7Days() {
    final end = DateTime.now();
    final start = end.subtract(const Duration(days: 7));
    setState(() {
      _startDate = start;
      _endDate = end;
    });
    widget.onRangeSelected(start, end);
  }

  void _selectLast30Days() {
    final end = DateTime.now();
    final start = end.subtract(const Duration(days: 30));
    setState(() {
      _startDate = start;
      _endDate = end;
    });
    widget.onRangeSelected(start, end);
  }

  void _selectLast60Days() {
    final end = DateTime.now();
    final start = end.subtract(const Duration(days: 60));
    setState(() {
      _startDate = start;
      _endDate = end;
    });
    widget.onRangeSelected(start, end);
  }

  void _clearSelection() {
    setState(() {
      _startDate = null;
      _endDate = null;
    });
    widget.onClear?.call();
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Select';
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.darkBg3,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.borderLight,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.date_range, color: AppColors.accentPink, size: 24),
              const SizedBox(width: 12),
              Text(
                'Select Time Range',
                style: AppTextStyles.heading4.copyWith(
                  color: AppColors.lightText,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildQuickChip('Last 24 Hours', _selectLast24Hours),
              _buildQuickChip('Last 7 Days', _selectLast7Days),
              _buildQuickChip('Last 30 Days', _selectLast30Days),
              _buildQuickChip('Last 60 Days', _selectLast60Days),
            ],
          ),
          const SizedBox(height: 20),
          Divider(color: AppColors.borderLight),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildDateButton(
                  'Start Date',
                  _formatDate(_startDate),
                  _selectStartDate,
                  Icons.calendar_today,
                ),
              ),
              const SizedBox(width: 12),
              Icon(Icons.arrow_forward, color: AppColors.mediumText, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDateButton(
                  'End Date',
                  _formatDate(_endDate),
                  _selectEndDate,
                  Icons.event,
                ),
              ),
            ],
          ),
          if (_startDate != null || _endDate != null) ...[
            const SizedBox(height: 16),
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: _clearSelection,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.darkBg2,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.error.withOpacity(0.5),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.clear, color: AppColors.error, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Clear Selection',
                      style: AppTextStyles.button.copyWith(
                        color: AppColors.error,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickChip(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.darkBg2,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.accentPink.withOpacity(0.3),
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.accentPink,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildDateButton(
    String label,
    String value,
    VoidCallback onTap,
    IconData icon,
  ) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.darkBg2,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.borderLight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.mediumText, size: 16),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.mediumText,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: AppTextStyles.body.copyWith(
                color: AppColors.lightText,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
