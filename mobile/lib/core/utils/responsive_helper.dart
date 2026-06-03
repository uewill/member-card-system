import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:member_card_app/core/config/app_config.dart';

/// 响应式布局助手类 - 支持手机和 PAD 尺寸自适应
class ResponsiveHelper {
  /// 判断当前是否为手机尺寸
  static bool isPhone(BuildContext context) {
    return MediaQuery.of(context).size.width < AppConfig.phoneBreakpoint;
  }

  /// 判断当前是否为 PAD 尺寸
  static bool isPad(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= AppConfig.phoneBreakpoint && width < AppConfig.padBreakpoint;
  }

  /// 判断当前是否为大屏 PAD
  static bool isLargePad(BuildContext context) {
    return MediaQuery.of(context).size.width >= AppConfig.padBreakpoint;
  }

  /// 获取当前设备类型
  static DeviceType getDeviceType(BuildContext context) {
    if (isPhone(context)) return DeviceType.phone;
    if (isPad(context)) return DeviceType.pad;
    return DeviceType.largePad;
  }

  /// 根据设备类型返回不同的值
  static T responsive<T>(
    BuildContext context,
    {required T phone, T? pad, T? largePad}
  ) {
    final deviceType = getDeviceType(context);
    switch (deviceType) {
      case DeviceType.phone:
        return phone;
      case DeviceType.pad:
        return pad ?? phone;
      case DeviceType.largePad:
        return largePad ?? pad ?? phone;
    }
  }

  /// 根据设备类型返回不同的间距
  static double spacing(BuildContext context) {
    return responsive(
      context,
      phone: 16.w,
      pad: 24.w,
      largePad: 32.w,
    );
  }

  /// 根据设备类型返回不同的字体大小
  static double fontSize(BuildContext context) {
    return responsive(
      context,
      phone: 14.sp,
      pad: 16.sp,
      largePad: 18.sp,
    );
  }

  /// 响应式包装器
  static Widget wrapWithResponsiveBuilder(BuildContext context, Widget child) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // 根据宽度调整 ScreenUtil 的设计尺寸
        if (constraints.maxWidth >= AppConfig.padBreakpoint) {
          // PAD 尺寸：使用更大的设计基准
          ScreenUtil.init(
            context,
            designSize: const Size(1024, 768),
          );
        } else {
          // 手机尺寸
          ScreenUtil.init(
            context,
            designSize: const Size(375, 812),
          );
        }
        return child;
      },
    );
  }
}

enum DeviceType { phone, pad, largePad }