import 'package:drive_or_drunk_app/core/constants/app_sizes.dart';
import 'package:drive_or_drunk_app/core/constants/device_info.dart';
import 'package:flutter/material.dart';

class ResponsiveDesign {
  static DeviceType getDeviceType(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= Breakpoints.desktop) return DeviceType.desktop;
    if (width >= Breakpoints.tablet) return DeviceType.tablet;
    return DeviceType.mobile;
  }

  static double getSpacing(DeviceType deviceType) {
    return switch (deviceType) {
      DeviceType.desktop => AppSizes.xl, // 32.0
      DeviceType.tablet => AppSizes.lg, // 24.0
      DeviceType.mobile => AppSizes.md, // 16.0
    };
  }

  static double getSectionSpacing(DeviceType deviceType) {
    return switch (deviceType) {
      DeviceType.desktop => AppSizes.spaceBtwSections * 1.25, // 40.0
      DeviceType.tablet => AppSizes.spaceBtwSections, // 32.0
      DeviceType.mobile => AppSizes.lg, // 24.0
    };
  }

  static double getItemSpacing(DeviceType deviceType) {
    return switch (deviceType) {
      DeviceType.desktop => AppSizes.spaceBtwInputFields, // 16.0
      DeviceType.tablet => AppSizes.spaceBtwItems, // 12.0
      DeviceType.mobile => AppSizes.spaceBtwItems, // 12.0
    };
  }

  static double getFontSize(DeviceType deviceType, {required String variant}) {
    return switch (variant) {
      'small' => switch (deviceType) {
          DeviceType.desktop => AppSizes.fontSizeSm + 2, // 14.0
          DeviceType.tablet => AppSizes.fontSizeSm + 1, // 13.0
          DeviceType.mobile => AppSizes.fontSizeSm, // 12.0
        },
      'medium' => switch (deviceType) {
          DeviceType.desktop => AppSizes.fontSizeMd + 2, // 18.0
          DeviceType.tablet => AppSizes.fontSizeMd + 1, // 17.0
          DeviceType.mobile => AppSizes.fontSizeMd, // 16.0
        },
      'large' => switch (deviceType) {
          DeviceType.desktop => AppSizes.fontSizeLg, // 20.0
          DeviceType.tablet => AppSizes.fontSizeMd + 3, // 19.0
          DeviceType.mobile => AppSizes.fontSizeMd + 2, // 18.0
        },
      _ => AppSizes.fontSizeMd,
    };
  }

  static double getIconSize(DeviceType deviceType) {
    return switch (deviceType) {
      DeviceType.desktop => AppSizes.iconLg, // 32.0
      DeviceType.tablet => AppSizes.iconMd, // 24.0
      DeviceType.mobile => AppSizes.iconSm, // 16.0
    };
  }

  static double getMaxFormWidth(DeviceType deviceType) {
    return switch (deviceType) {
      DeviceType.desktop => 400.0,
      DeviceType.tablet => 350.0,
      DeviceType.mobile => double.infinity,
    };
  }

  static EdgeInsets getFormPadding(BuildContext context) {
    final deviceType = getDeviceType(context);
    final spacing = getSpacing(deviceType);
    return EdgeInsets.symmetric(horizontal: spacing);
  }

  static EdgeInsets getButtonPadding(DeviceType deviceType) {
    final spacing = getSpacing(deviceType);
    return EdgeInsets.symmetric(
      vertical: spacing * 0.75,
      horizontal: spacing * 1.25,
    );
  }
}
