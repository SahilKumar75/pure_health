import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:pure_health/core/constants/color_constants.dart';
import 'package:pure_health/core/theme/text_styles.dart';
import 'package:pure_health/core/theme/government_theme.dart';

class FileUploadSection extends StatelessWidget {
  final VoidCallback onUpload;
  final String? fileName;
  final int? recordCount;
  final bool isLoading;

  const FileUploadSection({
    super.key,
    required this.onUpload,
    this.fileName,
    this.recordCount,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final hasFile = fileName != null;

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.darkBg3,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasFile
              ? GovernmentTheme.governmentBlue.withOpacity(0.5)
              : AppColors.borderLight,
          width: hasFile ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          if (!hasFile) ...[
            // Upload Icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: GovernmentTheme.governmentBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                CupertinoIcons.cloud_upload,
                color: GovernmentTheme.governmentBlue,
                size: 40,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Upload Water Quality Data',
              style: AppTextStyles.heading3.copyWith(
                color: AppColors.lightText,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Upload your data in CSV, Excel, JSON, PDF, or TXT format',
              style: AppTextStyles.body.copyWith(
                color: AppColors.mediumText,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: isLoading ? null : onUpload,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: isLoading
                      ? AppColors.dimText
                      : GovernmentTheme.governmentBlue,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isLoading)
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    else
                      Icon(
                        CupertinoIcons.doc_text,
                        color: Colors.white,
                        size: 20,
                      ),
                    const SizedBox(width: 12),
                    Text(
                      isLoading ? 'Uploading...' : 'Choose File',
                      style: AppTextStyles.button.copyWith(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Supported formats: CSV, XLSX, XLS, JSON, PDF, TXT',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.dimText,
                fontSize: 12,
              ),
            ),
          ] else ...[
            // File uploaded success
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: GovernmentTheme.governmentBlue.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    CupertinoIcons.checkmark_circle_fill,
                    color: GovernmentTheme.governmentBlue,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'File Uploaded Successfully',
                        style: AppTextStyles.heading4.copyWith(
                          color: AppColors.lightText,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        fileName!,
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.mediumText,
                        ),
                      ),
                      if (recordCount != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          '$recordCount records found',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.dimText,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                CupertinoButton(
                  padding: const EdgeInsets.all(8),
                  onPressed: isLoading ? null : onUpload,
                  child: Icon(
                    CupertinoIcons.arrow_2_circlepath,
                    color: AppColors.mediumText,
                    size: 20,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
