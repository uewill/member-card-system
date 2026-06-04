import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:member_card_app/core/config/app_config.dart';
import 'package:member_card_app/core/router/app_router.dart';
import 'package:member_card_app/core/utils/responsive_helper.dart';
import 'package:member_card_app/shared/services/api_client.dart';
import 'package:member_card_app/shared/services/auth_service.dart';
import 'package:member_card_app/shared/providers/auth_provider.dart';
import 'package:member_card_app/shared/providers/member_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化 API 客户端
  ApiClient.instance.init();

  // 初始化认证服务（恢复本地存储的 Token）
  await AuthService.instance.init();

  runApp(const StoreApp());
}

class StoreApp extends StatelessWidget {
  const StoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => MemberProvider()),
      ],
      child: ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return MaterialApp.router(
            title: '门店管理系统',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF0052D9),
                brightness: Brightness.light,
              ),
              useMaterial3: true,
              scaffoldBackgroundColor: const Color(0xFFF5F7FA),
              appBarTheme: const AppBarTheme(
                backgroundColor: Color(0xFF0052D9),
                foregroundColor: Colors.white,
                elevation: 0,
                centerTitle: true,
              ),
            ),
            routerConfig: AppRouter.router,
            builder: (context, widget) {
              return ResponsiveHelper.wrapWithResponsiveBuilder(
                context,
                widget ?? const SizedBox(),
              );
            },
          );
        },
      ),
    );
  }
}
