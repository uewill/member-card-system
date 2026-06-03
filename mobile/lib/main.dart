import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:member_card_app/core/config/app_config.dart';
import 'package:member_card_app/core/utils/responsive_helper.dart';
import 'package:member_card_app/features/auth/presentation/pages/login_page.dart';
import 'package:member_card_app/shared/services/auth_service.dart';

void main() {
  runApp(const MemberCardApp());
}

class MemberCardApp extends StatelessWidget {
  const MemberCardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812), // 手机基准尺寸
      minTextAdapt: true,
      splitScreenMode: true, // 支持 PAD 分屏
      builder: (context, child) {
        return MultiProvider(
          providers: [
            Provider<AuthService>(create: (_) => AuthService()),
          ],
          child: MaterialApp(
            title: AppConfig.appName,
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: AppConfig.primaryColor,
              ),
              useMaterial3: true,
              fontFamily: 'NotoSansSC',
            ),
            home: const LoginPage(),
            builder: (context, widget) {
              // 响应式布局适配
              return ResponsiveHelper.wrapWithResponsiveBuilder(
                context,
                widget ?? const SizedBox(),
              );
            },
          ),
        );
      },
    );
  }
}