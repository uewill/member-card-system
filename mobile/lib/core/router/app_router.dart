import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:member_card_app/features/auth/presentation/pages/login_page.dart';
import 'package:member_card_app/features/store/presentation/pages/store_dashboard_page.dart';
import 'package:member_card_app/features/store/presentation/pages/member_manage_page.dart';
import 'package:member_card_app/features/store/presentation/pages/card_manage_page.dart';
import 'package:member_card_app/features/store/presentation/pages/consume_verify_page.dart';
import 'package:member_card_app/features/store/presentation/pages/recharge_page.dart';
import 'package:member_card_app/features/store/presentation/pages/performance_page.dart';
import 'package:member_card_app/features/store/presentation/pages/marketing_page.dart';
import 'package:member_card_app/features/store/presentation/pages/settings_page.dart';
import 'package:member_card_app/features/store/presentation/pages/member_detail_page.dart';
import 'package:member_card_app/features/store/presentation/pages/card_detail_page.dart';
import 'package:member_card_app/features/store/presentation/pages/create_card_page.dart';
import 'package:member_card_app/features/store/presentation/pages/recharge_confirm_page.dart';
import 'package:member_card_app/features/store/presentation/pages/product_manage_page.dart';
import 'package:member_card_app/features/store/presentation/pages/card_type_manage_page.dart';
import 'package:member_card_app/features/store/presentation/pages/recharge_bonus_page.dart';
import 'package:member_card_app/features/store/presentation/pages/print_settings_page.dart';
import 'package:member_card_app/features/store/presentation/pages/product_edit_page.dart';
import 'package:member_card_app/features/store/presentation/pages/card_type_edit_page.dart';
import 'package:member_card_app/features/store/presentation/pages/bonus_edit_page.dart';
import 'package:member_card_app/features/store/presentation/pages/report_center_page.dart';
import 'package:member_card_app/features/store/presentation/pages/permission_page.dart';
import 'package:member_card_app/features/store/presentation/pages/recharge_record_page.dart';
import 'package:member_card_app/features/store/presentation/pages/verify_record_page.dart';

/// 门店端路由配置
class AppRouter {
  static final GlobalKey<NavigatorState> _rootNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'root');

  static GoRouter get router => _router;

  static final GoRouter _router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/login',
    debugLogDiagnostics: true,
    routes: [
      // 登录页
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),

      // 门店首页（仪表盘）
      GoRoute(
        path: '/dashboard',
        name: 'dashboard',
        builder: (context, state) => const StoreDashboardPage(),
      ),

      // 会员管理
      GoRoute(
        path: '/members',
        name: 'members',
        builder: (context, state) => const MemberManagePage(),
      ),

      // 次卡管理
      GoRoute(
        path: '/cards',
        name: 'cards',
        builder: (context, state) => const CardManagePage(),
      ),

      // 消费核销
      GoRoute(
        path: '/verify',
        name: 'verify',
        builder: (context, state) => const ConsumeVerifyPage(),
      ),

      // 充值开卡
      GoRoute(
        path: '/recharge',
        name: 'recharge',
        builder: (context, state) => const RechargePage(),
      ),

      // 业绩统计
      GoRoute(
        path: '/performance',
        name: 'performance',
        builder: (context, state) => const PerformancePage(),
      ),

      // 营销工具
      GoRoute(
        path: '/marketing',
        name: 'marketing',
        builder: (context, state) => const MarketingPage(),
      ),

      // 设置
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsPage(),
      ),

      // 会员详情
      GoRoute(
        path: '/member-detail/:id',
        name: 'memberDetail',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return MemberDetailPage(id: id);
        },
      ),

      // 次卡详情
      GoRoute(
        path: '/card-detail/:id',
        name: 'cardDetail',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return CardDetailPage(id: id);
        },
      ),

      // 创建次卡
      GoRoute(
        path: '/create-card',
        name: 'createCard',
        builder: (context, state) => const CreateCardPage(),
      ),

      // 充值确认
      GoRoute(
        path: '/recharge-confirm',
        name: 'rechargeConfirm',
        builder: (context, state) => const RechargeConfirmPage(),
      ),

      // 商品管理
      GoRoute(
        path: '/products',
        name: 'products',
        builder: (context, state) => const ProductManagePage(),
      ),

      // 卡类型管理
      GoRoute(
        path: '/card-types',
        name: 'cardTypes',
        builder: (context, state) => const CardTypeManagePage(),
      ),

      // 充值赠金
      GoRoute(
        path: '/recharge-bonus',
        name: 'rechargeBonus',
        builder: (context, state) => const RechargeBonusPage(),
      ),

      // 打印设置
      GoRoute(
        path: '/print-settings',
        name: 'printSettings',
        builder: (context, state) => const PrintSettingsPage(),
      ),

      // 商品编辑
      GoRoute(
        path: '/product-edit',
        name: 'productEdit',
        builder: (context, state) => const ProductEditPage(),
      ),

      // 卡类型编辑
      GoRoute(
        path: '/card-type-edit',
        name: 'cardTypeEdit',
        builder: (context, state) => const CardTypeEditPage(),
      ),

      // 赠送规则编辑
      GoRoute(
        path: '/bonus-edit',
        name: 'bonusEdit',
        builder: (context, state) => const BonusEditPage(),
      ),

      // 报表中心
      GoRoute(
        path: '/reports',
        name: 'reports',
        builder: (context, state) => const ReportCenterPage(),
      ),

      // 权限管理
      GoRoute(
        path: '/permissions',
        name: 'permissions',
        builder: (context, state) => const PermissionPage(),
      ),

      // 充值记录
      GoRoute(
        path: '/recharge-records',
        name: 'rechargeRecords',
        builder: (context, state) => const RechargeRecordPage(),
      ),

      // 核销记录
      GoRoute(
        path: '/verify-records',
        name: 'verifyRecords',
        builder: (context, state) => const VerifyRecordPage(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text('页面未找到: ${state.uri.path}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/login'),
              child: const Text('返回登录'),
            ),
          ],
        ),
      ),
    ),
  );
}
