import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/color_constants.dart';
import '../../../../shared/widgets/web_layout.dart';
import 'package:pure_health/core/utils/responsive_extensions.dart';


class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightCream,
      appBar: AppBar(
        title: Text('Pure Health', style: Theme.of(context).textTheme.headlineSmall),
        elevation: 0,
      ),
      body: WebLayout(
        sidebar: _buildSidebar(context),
        mainContent: _buildMainContent(context),
      ),
    );
  }

  Widget _buildSidebar(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(2.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sidebarItem('Home', context),
            _sidebarItem('Profile', context),
            _sidebarItem('Settings', context),
            _sidebarItem('History', context),
          ],
        ),
      ),
    );
  }

  Widget _sidebarItem(String label, BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.h),
      child: ListTile(
        title: Text(label),
        tileColor: Colors.transparent,
        hoverColor: AppColors.darkCream.withOpacity(0.3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildMainContent(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card
          Card(
            child: Padding(
              padding: EdgeInsets.all(3.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Welcome Back!', style: Theme.of(context).textTheme.headlineMedium),
                  SizedBox(height: 1.h),
                  Text('Track your health metrics and achieve your fitness goals.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 2.h),
          
          // Stats Grid
          GridView.count(
            crossAxisCount: context.isMobile ? 1 : (context.isTablet ? 2 : 3),
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            crossAxisSpacing: 2.w,
            mainAxisSpacing: 2.w,
            children: [
              _statCard('Weight', '72 kg', '▼ 2 kg', context),
              _statCard('Steps', '8,432', '▲ 1,200', context),
              _statCard('Calories', '1,850', '▼ 150', context),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statCard(String title, String value, String change, BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(2.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: Theme.of(context).textTheme.bodySmall),
            Text(value, style: Theme.of(context).textTheme.headlineSmall),
            Text(change, style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.success,
            )),
          ],
        ),
      ),
    );
  }
}
