import 'package:flutter/material.dart';
import 'package:pure_health/shared/widgets/custom_sidebar.dart';
import 'package:flutter/cupertino.dart';
import 'package:pure_health/core/constants/color_constants.dart';
import 'package:pure_health/core/theme/text_styles.dart';
import 'package:pure_health/shared/widgets/skeleton_loader.dart';
import 'package:pure_health/shared/widgets/toast_notification.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  int _selectedIndex = 3;
  bool _notificationsEnabled = true;
  bool _biometricEnabled = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveSetting() async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) {
      ToastNotification.success(context, 'Settings saved!');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightCream,
      body: Row(
        children: [
          CustomSidebar(
            selectedIndex: _selectedIndex,
            onItemSelected: (int index) {
              setState(() => _selectedIndex = index);
            },
          ),
          Expanded(
            child: _isLoading ? _buildLoadingState() : _buildSettingsContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return SingleChildScrollView(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1400),
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SkeletonLoader(width: 150, height: 32, borderRadius: BorderRadius.circular(8)),
            const SizedBox(height: 8),
            SkeletonLoader(width: 300, height: 16, borderRadius: BorderRadius.circular(4)),
            const SizedBox(height: 32),
            SkeletonLoader(
              width: double.infinity,
              height: 200,
              borderRadius: BorderRadius.circular(20),
            ),
            const SizedBox(height: 20),
            SkeletonLoader(
              width: double.infinity,
              height: 300,
              borderRadius: BorderRadius.circular(20),
            ),
            const SizedBox(height: 20),
            SkeletonLoader(
              width: double.infinity,
              height: 80,
              borderRadius: BorderRadius.circular(12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsContent() {
    return SingleChildScrollView(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1400),
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Settings',
              style: AppTextStyles.heading1.copyWith(
                color: AppColors.charcoal,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Manage your app settings and preferences',
              style: AppTextStyles.body.copyWith(
                color: AppColors.mediumGray,
              ),
            ),
            const SizedBox(height: 32),
            
            // Preferences
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.darkCream.withOpacity(0.2)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.charcoal.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Preferences',
                    style: AppTextStyles.heading3.copyWith(
                      color: AppColors.charcoal,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildSettingRow(
                    icon: CupertinoIcons.bell_fill,
                    title: 'Enable Notifications',
                    value: _notificationsEnabled,
                    onChanged: (val) {
                      setState(() => _notificationsEnabled = val);
                      _saveSetting();
                    },
                    iconColor: AppColors.warning,
                  ),
                  const SizedBox(height: 12),
                  _buildSettingRow(
                    icon: CupertinoIcons.hand_raised_fill,
                    title: 'Biometric Authentication',
                    value: _biometricEnabled,
                    onChanged: (val) {
                      setState(() => _biometricEnabled = val);
                      _saveSetting();
                    },
                    iconColor: AppColors.accentPurple,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            
            // More Options
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.darkCream.withOpacity(0.2)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.charcoal.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'More Options',
                    style: AppTextStyles.heading3.copyWith(
                      color: AppColors.charcoal,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildLinkButton(
                    icon: CupertinoIcons.doc_text_fill,
                    title: 'Terms & Conditions',
                    onTap: () => ToastNotification.info(context, 'Opening Terms...'),
                  ),
                  const SizedBox(height: 8),
                  _buildLinkButton(
                    icon: CupertinoIcons.shield_fill,
                    title: 'Privacy Policy',
                    onTap: () => ToastNotification.info(context, 'Opening Privacy...'),
                  ),
                  const SizedBox(height: 8),
                  _buildLinkButton(
                    icon: CupertinoIcons.question_circle_fill,
                    title: 'Help & Support',
                    onTap: () => ToastNotification.info(context, 'Opening Help...'),
                  ),
                  const SizedBox(height: 8),
                  _buildLinkButton(
                    icon: CupertinoIcons.info_circle_fill,
                    title: 'About (v1.0.0)',
                    onTap: () => ToastNotification.info(context, 'PureHealth v1.0.0'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            
            // Sign Out Button
            SizedBox(
              width: double.infinity,
              child: CupertinoButton(
                padding: const EdgeInsets.symmetric(vertical: 18),
                color: AppColors.error,
                borderRadius: BorderRadius.circular(12),
                onPressed: () {
                  ToastNotification.warning(context, 'Signing out...');
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(CupertinoIcons.square_arrow_right, color: Colors.white, size: 22),
                    const SizedBox(width: 10),
                    Text(
                      'Sign Out',
                      style: AppTextStyles.button.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingRow({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
    Color? iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.darkBg3,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.darkCream.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (iconColor ?? AppColors.accentPink).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: iconColor ?? AppColors.accentPink),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: AppTextStyles.body.copyWith(
                color: AppColors.charcoal,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          CupertinoSwitch(
            value: value,
            onChanged: onChanged,
            activeColor: iconColor ?? AppColors.accentPink,
          ),
        ],
      ),
    );
  }

  Widget _buildLinkButton({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          child: Row(
            children: [
              Icon(icon, size: 20, color: AppColors.accentPink),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.charcoal,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Icon(
                CupertinoIcons.chevron_right,
                size: 16,
                color: AppColors.mediumGray,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
