/// App Button Widget
/// Uygulamada kullanılan özelleştirilebilir buton widget'ı
library;

import 'package:flutter/material.dart';
import '../core/theme.dart';

/// Buton türleri
enum AppButtonType {
  primary,
  secondary,
  outlined,
  text,
}

/// Buton boyutları
enum AppButtonSize {
  small,
  medium,
  large,
}

/// Özelleştirilebilir App Button
class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final AppButtonType type;
  final AppButtonSize size;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? icon;
  final bool iconOnRight;
  final Color? backgroundColor;
  final Color? textColor;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = AppButtonType.primary,
    this.size = AppButtonSize.medium,
    this.isLoading = false,
    this.isFullWidth = false,
    this.icon,
    this.iconOnRight = false,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Boyut ayarları
    final EdgeInsetsGeometry padding;
    final double fontSize;
    final double iconSize;
    final double height;

    switch (size) {
      case AppButtonSize.small:
        padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
        fontSize = 14;
        iconSize = 18;
        height = 36;
        break;
      case AppButtonSize.medium:
        padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 12);
        fontSize = 16;
        iconSize = 20;
        height = 48;
        break;
      case AppButtonSize.large:
        padding = const EdgeInsets.symmetric(horizontal: 32, vertical: 16);
        fontSize = 18;
        iconSize = 24;
        height = 56;
        break;
    }

    // İçerik widget'ı
    Widget content = isLoading
        ? SizedBox(
            width: iconSize,
            height: iconSize,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                type == AppButtonType.primary
                    ? colorScheme.onPrimary
                    : colorScheme.primary,
              ),
            ),
          )
        : _buildContent(fontSize, iconSize);

    // Buton widget'ı
    Widget button;
    switch (type) {
      case AppButtonType.primary:
        button = ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor ?? colorScheme.primary,
            foregroundColor: textColor ?? colorScheme.onPrimary,
            padding: padding,
            minimumSize: Size(isFullWidth ? double.infinity : 0, height),
            textStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
            ),
          ),
          child: content,
        );
        break;

      case AppButtonType.secondary:
        button = ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor ?? colorScheme.secondaryContainer,
            foregroundColor: textColor ?? colorScheme.onSecondaryContainer,
            padding: padding,
            minimumSize: Size(isFullWidth ? double.infinity : 0, height),
            elevation: 0,
            textStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
            ),
          ),
          child: content,
        );
        break;

      case AppButtonType.outlined:
        button = OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: textColor ?? colorScheme.primary,
            padding: padding,
            minimumSize: Size(isFullWidth ? double.infinity : 0, height),
            side: BorderSide(color: backgroundColor ?? colorScheme.outline),
            textStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
            ),
          ),
          child: content,
        );
        break;

      case AppButtonType.text:
        button = TextButton(
          onPressed: isLoading ? null : onPressed,
          style: TextButton.styleFrom(
            foregroundColor: textColor ?? colorScheme.primary,
            padding: padding,
            minimumSize: Size(isFullWidth ? double.infinity : 0, height),
            textStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
            ),
          ),
          child: content,
        );
        break;
    }

    return button;
  }

  Widget _buildContent(double fontSize, double iconSize) {
    if (icon == null) {
      return Text(text);
    }

    final iconWidget = Icon(icon, size: iconSize);
    final textWidget = Text(text);
    const spacer = SizedBox(width: AppSpacing.sm);

    if (iconOnRight) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [textWidget, spacer, iconWidget],
      );
    } else {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [iconWidget, spacer, textWidget],
      );
    }
  }
}

/// Gradient Button - Özel gradient buton
class GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isFullWidth;
  final Gradient? gradient;
  final double height;

  const GradientButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isFullWidth = true,
    this.gradient,
    this.height = 52,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: isFullWidth ? double.infinity : null,
      height: height,
      decoration: BoxDecoration(
        gradient: gradient ?? AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(colorScheme.onPrimary),
                ),
              )
            : Text(
                text,
                style: TextStyle(
                  color: colorScheme.onPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}

/// Icon Button with Badge - Rozet içeren icon buton
class IconButtonWithBadge extends StatelessWidget {
  final IconData icon;
  final int badgeCount;
  final VoidCallback? onPressed;
  final Color? iconColor;
  final Color? badgeColor;

  const IconButtonWithBadge({
    super.key,
    required this.icon,
    this.badgeCount = 0,
    this.onPressed,
    this.iconColor,
    this.badgeColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Stack(
      children: [
        IconButton(
          onPressed: onPressed,
          icon: Icon(icon, color: iconColor ?? colorScheme.onSurface),
        ),
        if (badgeCount > 0)
          Positioned(
            right: 4,
            top: 4,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: badgeColor ?? colorScheme.error,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(
                minWidth: 18,
                minHeight: 18,
              ),
              child: Text(
                badgeCount > 99 ? '99+' : badgeCount.toString(),
                style: TextStyle(
                  color: colorScheme.onError,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}
