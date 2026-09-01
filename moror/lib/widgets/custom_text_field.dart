import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String label;
  final String? hint;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final int maxLines;
  final bool readOnly;
  final VoidCallback? onTap;
  final Color? textColor;
  final Color? labelColor;
  final Color? fillColor;

  const CustomTextField({
    super.key,
    this.controller,
    required this.label,
    this.hint,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.onChanged,
    this.maxLines = 1,
    this.readOnly = false,
    this.onTap,
    this.textColor,
    this.labelColor,
    this.fillColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = textColor ?? (isDark ? AppColors.textPrimary : AppColors.lightTextPrimary);
    final primaryLabelColor = labelColor ?? textColor ?? (isDark ? AppColors.textPrimary : AppColors.lightTextPrimary);
    final secondaryTextColor = isDark ? AppColors.textSecondary : AppColors.lightTextSecondary;
    final fieldBg = fillColor ?? (isDark ? AppColors.inputBackground : AppColors.lightInputBackground);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.titleSmall.copyWith(
            color: primaryLabelColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          onChanged: onChanged,
          maxLines: maxLines,
          readOnly: readOnly,
          onTap: onTap,
          style: AppTypography.bodyLarge.copyWith(color: primaryTextColor),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: secondaryTextColor.withValues(alpha: 0.5), fontSize: 13),
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, color: AppColors.goldPrimary, size: 20)
                : null,
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: fieldBg,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            errorStyle: const TextStyle(
              fontSize: 11,
              height: 1.1,
              color: AppColors.error,
              fontWeight: FontWeight.w500,
            ),
            errorMaxLines: 2,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: isDark ? AppColors.cardBorder : AppColors.lightCardBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: isDark ? AppColors.cardBorder : AppColors.lightCardBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.goldPrimary, width: 1.8),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.error, width: 1.2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.error, width: 1.8),
            ),
          ),
        ),
      ],
    );
  }
}
