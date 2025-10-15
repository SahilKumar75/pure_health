import 'package:flutter/material.dart';
import 'package:pure_health/widgets/custom_sidebar.dart';
import 'package:pure_health/widgets/glass_container.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _selectedIndex = 1;
  bool _notificationsEnabled = true;
  bool _biometricEnabled = false;

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    Color? iconColor,
  }) {
    return GlassContainer(
      borderRadius: BorderRadius.circular(16),
      blur: 10,
      opacity: 0.15,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (iconColor ?? CupertinoColors.activeBlue).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 24,
              color: iconColor ?? CupertinoColors.activeBlue,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
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
    final buttonColor = color ?? CupertinoColors.activeBlue;
    return GlassContainer(
      borderRadius: BorderRadius.circular(16),
      blur: 10,
      opacity: 0.15,
      padding: EdgeInsets.zero,
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
                  child: Icon(
                    icon,
                    size: 32,
                    color: buttonColor,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: buttonColor,
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
    return GlassContainer(
      borderRadius: BorderRadius.circular(12),
      blur: 8,
      opacity: 0.15,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (iconColor ?? CupertinoColors.activeBlue).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 20,
              color: iconColor ?? CupertinoColors.activeBlue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
          CupertinoSwitch(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
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
            child: SingleChildScrollView(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 1400),
                padding: const EdgeInsets.all(32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Page Title
                    const Text(
                      'My Profile',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Manage your account information and preferences',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Main Content Grid
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left Column - Profile Card
                        Expanded(
                          flex: 1,
                          child: Column(
                            children: [
                              GlassContainer(
                                borderRadius: BorderRadius.circular(20),
                                blur: 12,
                                opacity: 0.15,
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
                                                CupertinoColors.activeBlue,
                                                CupertinoColors.activeBlue.withOpacity(0.6),
                                              ],
                                            ),
                                          ),
                                          child: const CircleAvatar(
                                            radius: 60,
                                            backgroundColor: Colors.white,
                                            child: Icon(
                                              CupertinoIcons.person_fill,
                                              size: 60,
                                              color: CupertinoColors.activeBlue,
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          bottom: 4,
                                          right: 4,
                                          child: GestureDetector(
                                            onTap: () {},
                                            child: Container(
                                              padding: const EdgeInsets.all(10),
                                              decoration: const BoxDecoration(
                                                color: CupertinoColors.activeBlue,
                                                shape: BoxShape.circle,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black26,
                                                    blurRadius: 8,
                                                    offset: Offset(0, 2),
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
                                    const Text(
                                      'Dr. Rajesh Kumar',
                                      style: TextStyle(
                                        fontSize: 26,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    const Text(
                                      'Senior Health Officer',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    const Text(
                                      'Ministry of Health & Family Welfare',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 24),
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: CupertinoColors.activeBlue.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          _buildStatColumn('Employee ID', 'MH2024156'),
                                          Container(
                                            height: 40,
                                            width: 1,
                                            color: Colors.grey.withOpacity(0.3),
                                          ),
                                          _buildStatColumn('Department', 'Delhi NCR'),
                                          Container(
                                            height: 40,
                                            width: 1,
                                            color: Colors.grey.withOpacity(0.3),
                                          ),
                                          _buildStatColumn('Since', '2020'),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                              // Quick Actions
                              GlassContainer(
                                borderRadius: BorderRadius.circular(20),
                                blur: 12,
                                opacity: 0.15,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Quick Actions',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _buildActionCard(
                                            icon: CupertinoIcons.pencil_circle_fill,
                                            title: 'Edit Profile',
                                            onTap: () {},
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: _buildActionCard(
                                            icon: CupertinoIcons.lock_shield_fill,
                                            title: 'Change Password',
                                            onTap: () {},
                                            color: CupertinoColors.systemPurple,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 24),

                        // Right Column - Details
                        Expanded(
                          flex: 1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Contact Information
                              GlassContainer(
                                borderRadius: BorderRadius.circular(20),
                                blur: 12,
                                opacity: 0.15,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Contact Information',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    _buildInfoCard(
                                      icon: CupertinoIcons.mail_solid,
                                      title: 'Email Address',
                                      value: 'rajesh.kumar@mohfw.gov.in',
                                      iconColor: CupertinoColors.systemRed,
                                    ),
                                    const SizedBox(height: 12),
                                    _buildInfoCard(
                                      icon: CupertinoIcons.phone_fill,
                                      title: 'Phone Number',
                                      value: '+91 98765 43210',
                                      iconColor: CupertinoColors.systemGreen,
                                    ),
                                    const SizedBox(height: 12),
                                    _buildInfoCard(
                                      icon: CupertinoIcons.location_solid,
                                      title: 'Office Location',
                                      value: 'Nirman Bhavan, New Delhi - 110011',
                                      iconColor: CupertinoColors.systemOrange,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Preferences
                              GlassContainer(
                                borderRadius: BorderRadius.circular(20),
                                blur: 12,
                                opacity: 0.15,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Preferences',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    _buildSettingRow(
                                      icon: CupertinoIcons.bell_fill,
                                      title: 'Enable Notifications',
                                      value: _notificationsEnabled,
                                      onChanged: (val) {
                                        setState(() {
                                          _notificationsEnabled = val;
                                        });
                                      },
                                      iconColor: CupertinoColors.systemYellow,
                                    ),
                                    const SizedBox(height: 12),
                                    _buildSettingRow(
                                      icon: CupertinoIcons.hand_raised_fill,
                                      title: 'Biometric Authentication',
                                      value: _biometricEnabled,
                                      onChanged: (val) {
                                        setState(() {
                                          _biometricEnabled = val;
                                        });
                                      },
                                      iconColor: CupertinoColors.systemIndigo,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Additional Options
                              GlassContainer(
                                borderRadius: BorderRadius.circular(20),
                                blur: 12,
                                opacity: 0.15,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'More Options',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    _buildLinkButton(
                                      icon: CupertinoIcons.doc_text_fill,
                                      title: 'Terms & Conditions',
                                      onTap: () {},
                                    ),
                                    const SizedBox(height: 8),
                                    _buildLinkButton(
                                      icon: CupertinoIcons.shield_fill,
                                      title: 'Privacy Policy',
                                      onTap: () {},
                                    ),
                                    const SizedBox(height: 8),
                                    _buildLinkButton(
                                      icon: CupertinoIcons.question_circle_fill,
                                      title: 'Help & Support',
                                      onTap: () {},
                                    ),
                                    const SizedBox(height: 8),
                                    _buildLinkButton(
                                      icon: CupertinoIcons.info_circle_fill,
                                      title: 'About (v1.0.0)',
                                      onTap: () {},
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Sign Out Button
                              SizedBox(
                                width: double.infinity,
                                child: GlassContainer(
                                  borderRadius: BorderRadius.circular(12),
                                  blur: 10,
                                  opacity: 0.15,
                                  padding: EdgeInsets.zero,
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(12),
                                      onTap: () {},
                                      child: const Padding(
                                        padding: EdgeInsets.symmetric(vertical: 18),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              CupertinoIcons.square_arrow_right,
                                              color: CupertinoColors.systemRed,
                                              size: 22,
                                            ),
                                            SizedBox(width: 10),
                                            Text(
                                              'Sign Out',
                                              style: TextStyle(
                                                fontSize: 17,
                                                fontWeight: FontWeight.w600,
                                                color: CupertinoColors.systemRed,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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

  Widget _buildStatColumn(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: CupertinoColors.activeBlue,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.grey,
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
              Icon(
                icon,
                size: 20,
                color: CupertinoColors.activeBlue,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ),
              const Icon(
                CupertinoIcons.chevron_right,
                size: 16,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}