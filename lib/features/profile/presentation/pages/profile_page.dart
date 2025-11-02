import 'package:flutter/material.dart';
import 'package:pure_health/shared/widgets/custom_sidebar.dart';
import 'package:flutter/cupertino.dart';
import 'package:pure_health/core/constants/color_constants.dart';
import 'package:pure_health/core/theme/text_styles.dart';
import 'package:pure_health/shared/widgets/skeleton_loader.dart';
import 'package:pure_health/shared/widgets/toast_notification.dart';
import 'package:pure_health/shared/widgets/refresh_widgets.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _selectedIndex = 6;
  bool _notificationsEnabled = true;
  bool _biometricEnabled = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _refreshProfile() async {
    await Future.delayed(const Duration(milliseconds: 1200));
    if (mounted) {
      ToastNotification.success(context, 'Profile refreshed!');
    }
  }

  Future<void> _savePreferences() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      ToastNotification.success(context, 'Preferences saved successfully!');
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
              setState(() {
                _selectedIndex = index;
              });
            },
          ),
          Expanded(
            child: _isLoading ? _buildLoadingState() : _buildProfileContent(),
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
            SkeletonLoader(width: 200, height: 32, borderRadius: BorderRadius.circular(8)),
            const SizedBox(height: 8),
            SkeletonLoader(width: 300, height: 16, borderRadius: BorderRadius.circular(4)),
            const SizedBox(height: 32),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      SkeletonLoader(
                        width: double.infinity,
                        height: 400,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      const SizedBox(height: 20),
                      SkeletonLoader(
                        width: double.infinity,
                        height: 200,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    children: List.generate(
                      3,
                      (index) => Padding(
                        padding: EdgeInsets.only(bottom: index < 2 ? 20 : 0),
                        child: SkeletonLoader(
                          width: double.infinity,
                          height: 200,
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileContent() {
    return CustomRefreshWrapper(
      onRefresh: _refreshProfile,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1400),
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'My Profile',
                style: AppTextStyles.heading1.copyWith(
                  color: AppColors.charcoal,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Manage your account information and preferences',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.mediumGray,
                ),
              ),
              const SizedBox(height: 32),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: [
                        _buildProfileCard(),
                        const SizedBox(height: 20),
                        _buildQuickActionsCard(),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: [
                        _buildContactCard(),
                        const SizedBox(height: 20),
                        _buildPreferencesCard(),
                        const SizedBox(height: 20),
                        _buildMoreOptionsCard(),
                        const SizedBox(height: 20),
                        _buildSignOutButton(),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(32),
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
        children: [
          Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      AppColors.accentPink,
                      AppColors.accentPink.withOpacity(0.6),
                    ],
                  ),
                ),
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: AppColors.white,
                  child: Icon(
                    CupertinoIcons.person_fill,
                    size: 60,
                    color: AppColors.accentPink,
                  ),
                ),
              ),
              Positioned(
                bottom: 4,
                right: 4,
                child: GestureDetector(
                  onTap: () {
                    ToastNotification.info(context, 'Opening camera/gallery...');
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.accentPink,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.charcoal.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      CupertinoIcons.camera_fill,
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Dr. Rajesh Kumar',
            style: AppTextStyles.heading2.copyWith(
              color: AppColors.charcoal,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Senior Health Officer',
            style: AppTextStyles.body.copyWith(
              color: AppColors.mediumGray,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Ministry of Health & Family Welfare',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.mediumGray,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.accentPink.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatColumn('Employee ID', 'MH2024156'),
                Container(
                  height: 40,
                  width: 1,
                  color: AppColors.mediumGray.withOpacity(0.3),
                ),
                _buildStatColumn('Department', 'Delhi NCR'),
                Container(
                  height: 40,
                  width: 1,
                  color: AppColors.mediumGray.withOpacity(0.3),
                ),
                _buildStatColumn('Since', '2020'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsCard() {
    return Container(
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
            'Quick Actions',
            style: AppTextStyles.heading3.copyWith(
              color: AppColors.charcoal,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildActionCard(
                  icon: CupertinoIcons.pencil_circle_fill,
                  title: 'Edit Profile',
                  onTap: () {
                    ToastNotification.info(context, 'Opening profile editor...');
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionCard(
                  icon: CupertinoIcons.lock_shield_fill,
                  title: 'Change Password',
                  onTap: () {
                    ToastNotification.info(context, 'Opening password change...');
                  },
                  color: AppColors.accentPurple,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard() {
    return Container(
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
            'Contact Information',
            style: AppTextStyles.heading3.copyWith(
              color: AppColors.charcoal,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          _buildInfoCard(
            icon: CupertinoIcons.mail_solid,
            title: 'Email Address',
            value: 'rajesh.kumar@mohfw.gov.in',
            iconColor: AppColors.error,
          ),
          const SizedBox(height: 12),
          _buildInfoCard(
            icon: CupertinoIcons.phone_fill,
            title: 'Phone Number',
            value: '+91 98765 43210',
            iconColor: AppColors.success,
          ),
          const SizedBox(height: 12),
          _buildInfoCard(
            icon: CupertinoIcons.location_solid,
            title: 'Office Location',
            value: 'Nirman Bhavan, New Delhi - 110011',
            iconColor: AppColors.warning,
          ),
        ],
      ),
    );
  }

  Widget _buildPreferencesCard() {
    return Container(
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
              _savePreferences();
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
              _savePreferences();
            },
            iconColor: AppColors.accentPurple,
          ),
        ],
      ),
    );
  }

  Widget _buildMoreOptionsCard() {
    return Container(
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
            onTap: () => ToastNotification.info(context, 'Opening Privacy Policy...'),
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
    );
  }

  Widget _buildSignOutButton() {
    return SizedBox(
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
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    Color? iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkBg3,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.darkCream.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (iconColor ?? AppColors.accentPink).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 24, color: iconColor ?? AppColors.accentPink),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.mediumGray,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.charcoal,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
  }) {
    final buttonColor = color ?? AppColors.accentPink;
    return Container(
      decoration: BoxDecoration(
        color: buttonColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: buttonColor.withOpacity(0.2)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: buttonColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 32, color: buttonColor),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: AppTextStyles.button.copyWith(
                    color: buttonColor,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
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

  Widget _buildStatColumn(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.body.copyWith(
            color: AppColors.accentPink,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.mediumGray,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
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
