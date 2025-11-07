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
                'Profile',
                style: AppTextStyles.heading1.copyWith(
                  color: const Color(0xFF101828),
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Manage your account information and preferences',
                style: AppTextStyles.body.copyWith(
                  color: const Color(0xFF4A5565),
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 32),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left Column - Profile & Security
                  SizedBox(
                    width: 320,
                    child: Column(
                      children: [
                        _buildProfileCard(),
                        const SizedBox(height: 24),
                        _buildSecurityCard(),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  // Right Column - Personal Info, Work Info, Activity
                  Expanded(
                    child: Column(
                      children: [
                        _buildPersonalInfoCard(),
                        const SizedBox(height: 24),
                        _buildWorkInfoCard(),
                        const SizedBox(height: 24),
                        _buildActivitySummaryCard(),
                        const SizedBox(height: 24),
                        _buildActionButtons(),
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
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          // Avatar
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: const Color(0xFF155DFC),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                'JD',
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'John Doe',
            style: TextStyle(
              fontSize: 16,
              color: const Color(0xFF101828),
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Senior Water Quality Officer',
            style: TextStyle(
              fontSize: 14,
              color: const Color(0xFF4A5565),
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFF030213),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Government Employee',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                ToastNotification.info(context, 'Opening photo picker...');
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 17),
                side: BorderSide(color: Colors.black.withOpacity(0.1)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Change Photo',
                style: TextStyle(
                  fontSize: 14,
                  color: const Color(0xFF000000),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            height: 1,
            color: Colors.black.withOpacity(0.1),
          ),
          const SizedBox(height: 24),
          _buildContactRow(Icons.email, 'john.doe@waterauth.gov'),
          const SizedBox(height: 16),
          _buildContactRow(Icons.phone, '+1 (555) 123-4567'),
          const SizedBox(height: 16),
          _buildContactRow(Icons.location_on, 'Washington, DC'),
          const SizedBox(height: 16),
          _buildContactRow(Icons.calendar_today, 'Joined March 2023'),
        ],
      ),
    );
  }

  Widget _buildContactRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF364153)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: const Color(0xFF364153),
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSecurityCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.security, size: 16, color: const Color(0xFF000000)),
              const SizedBox(width: 8),
              Text(
                'Security',
                style: TextStyle(
                  fontSize: 16,
                  color: const Color(0xFF000000),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSecurityButton('Change Password'),
          const SizedBox(height: 12),
          _buildSecurityButton('Enable 2FA'),
          const SizedBox(height: 12),
          _buildSecurityButton('View Login History'),
        ],
      ),
    );
  }

  Widget _buildSecurityButton(String text) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () {
          ToastNotification.info(context, '$text...');
        },
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 8),
          side: BorderSide(color: Colors.black.withOpacity(0.1)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 14,
            color: const Color(0xFF000000),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildPersonalInfoCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.person, size: 20, color: const Color(0xFF000000)),
              const SizedBox(width: 8),
              Text(
                'Personal Information',
                style: TextStyle(
                  fontSize: 16,
                  color: const Color(0xFF000000),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: _buildTextField('First Name', 'John')),
              const SizedBox(width: 16),
              Expanded(child: _buildTextField('Last Name', 'Doe')),
            ],
          ),
          const SizedBox(height: 24),
          _buildTextField('Email Address', 'john.doe@waterauth.gov'),
          const SizedBox(height: 24),
          _buildTextField('Phone Number', '+1 (555) 123-4567'),
          const SizedBox(height: 24),
          _buildTextField('Department', 'Water Resource Management'),
          const SizedBox(height: 24),
          _buildTextField('Employee ID', 'WA-2023-5847', enabled: false),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, String value, {bool enabled = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: const Color(0xFF000000),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F3F5),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.transparent),
          ),
          child: TextField(
            controller: TextEditingController(text: value),
            enabled: enabled,
            style: TextStyle(
              fontSize: 14,
              color: const Color(0xFF000000),
              fontWeight: FontWeight.w400,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: 8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWorkInfoCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.work, size: 20, color: const Color(0xFF000000)),
              const SizedBox(width: 8),
              Text(
                'Work Information',
                style: TextStyle(
                  fontSize: 16,
                  color: const Color(0xFF000000),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildTextField('Position', 'Senior Water Quality Officer'),
          const SizedBox(height: 24),
          _buildTextField('Office Location', 'Main Office - Building A, Floor 3'),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: _buildTextField('Supervisor', 'Jane Smith')),
              const SizedBox(width: 16),
              Expanded(child: _buildTextField('Extension', '3847')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActivitySummaryCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Activity Summary',
            style: TextStyle(
              fontSize: 16,
              color: const Color(0xFF000000),
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildActivityBox('Reports\nGenerated', '47', const Color(0xFFEFF6FF)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildActivityBox('Stations\nMonitored', '12', const Color(0xFFF0FDF4)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildActivityBox('Alerts\nResolved', '156', const Color(0xFFFAF5FF)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActivityBox(String label, String value, Color bgColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: const Color(0xFF4A5565),
              fontWeight: FontWeight.w400,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              color: const Color(0xFF101828),
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        OutlinedButton(
          onPressed: () {
            ToastNotification.info(context, 'Changes cancelled');
          },
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 9),
            side: BorderSide(color: Colors.black.withOpacity(0.1)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            'Cancel',
            style: TextStyle(
              fontSize: 14,
              color: const Color(0xFF000000),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 12),
        ElevatedButton(
          onPressed: () {
            _savePreferences();
          },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            backgroundColor: const Color(0xFF030213),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            'Save Changes',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
