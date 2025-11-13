import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class CustomSnackBar {
  static void show({
    required BuildContext context,
    required String message,
    SnackBarType type = SnackBarType.info,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onAction,
    String? actionLabel,
  }) {
    Color backgroundColor;
    IconData icon;
    
    switch (type) {
      case SnackBarType.success:
        backgroundColor = AppTheme.successColor;
        icon = Icons.check_circle_outline;
        break;
      case SnackBarType.error:
        backgroundColor = AppTheme.errorColor;
        icon = Icons.error_outline;
        break;
      case SnackBarType.warning:
        backgroundColor = AppTheme.warningColor;
        icon = Icons.warning_amber_outlined;
        break;
      case SnackBarType.info:
      default:
        backgroundColor = AppTheme.primaryColor;
        icon = Icons.info_outline;
        break;
    }

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              icon,
              color: AppTheme.textLight,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: AppTheme.textLight,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        elevation: 6,
        action: onAction != null && actionLabel != null
            ? SnackBarAction(
                label: actionLabel,
                textColor: AppTheme.textLight,
                onPressed: onAction,
              )
            : null,
      ),
    );
  }

  static void showSuccess({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    show(
      context: context,
      message: message,
      type: SnackBarType.success,
      duration: duration,
    );
  }

  static void showError({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 4),
  }) {
    show(
      context: context,
      message: message,
      type: SnackBarType.error,
      duration: duration,
    );
  }

  static void showWarning({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    show(
      context: context,
      message: message,
      type: SnackBarType.warning,
      duration: duration,
    );
  }

  static void showInfo({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    show(
      context: context,
      message: message,
      type: SnackBarType.info,
      duration: duration,
    );
  }
}

enum SnackBarType {
  success,
  error,
  warning,
  info,
}