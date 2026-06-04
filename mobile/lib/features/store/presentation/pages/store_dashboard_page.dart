import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:member_card_app/core/utils/responsive_helper.dart';
import 'package:member_card_app/shared/providers/auth_provider.dart';
import 'package:member_card_app/shared/providers/member_provider.dart';
import 'package:member_card_app/shared/services/api/performance_repository.dart';

/// 门店仪表盘首页 - 商务专业风格
class StoreDashboardPage extends StatefulWidget {
  const StoreDashboardPage({super.key});

  @override
  State<StoreDashboardPage> createState() => _StoreDashboardPageState();
}

class _StoreDashboardPageState extends State<StoreDashboardPage> {
  int _currentIndex = 0;

  // API 加载的数据
  List<dynamic> _apiMembers = [];
  Map<String, dynamic>? _apiPerformance;
  bool _isLoading = true;
  String? _error;

  final List<Map<String, dynamic>> _menuItems = [
    {'icon': Icons.people_outline, 'label': '会员管理', 'route': '/members', 'color': Color(0xFF0052D9)},
    {'icon': Icons.card_membership, 'label': '次卡管理', 'route': '/cards', 'color': Color(0xFF00A870)},
    {'icon': Icons.qr_code_scanner, 'label': '消费核销', 'route': '/verify', 'color': Color(0xFFEBB105)},
    {'icon': Icons.add_card, 'label': '充值开卡', 'route': '/recharge', 'color': Color(0xFFED7B2F)},
    {'icon': Icons.bar_chart, 'label': '业绩统计', 'route': '/performance', 'color': Color(0xFF7B61FF)},
    {'icon': Icons.inventory_2_outlined, 'label': '商品管理', 'route': '/products', 'color': Color(0xFF0594FA)},
    {'icon': Icons.style_outlined, 'label': '卡类型管理', 'route': '/card-types', 'color': Color(0xFFD54941)},
    {'icon': Icons.card_giftcard, 'label': '充值赠金', 'route': '/recharge-bonus', 'color': Color(0xFFE37318)},
    {'icon': Icons.print_outlined, 'label': '打印设置', 'route': '/print-settings', 'color': Color(0xFF2BA471)},
    {'icon': Icons.local_offer, 'label': '营销工具', 'route': '/marketing', 'color': Color(0xFFE34D59)},
    {'icon': Icons.settings, 'label': '系统设置', 'route': '/settings', 'color': Color(0xFF86909C)},
    {'icon': Icons.help_outline, 'label': '帮助中心', 'route': '/settings', 'color': Color(0xFF5E7AD8)},
    {'icon': Icons.assessment_outlined, 'label': '报表中心', 'route': '/reports', 'color': Color(0xFF0FC6C2)},
    {'icon': Icons.admin_panel_settings_outlined, 'label': '权限管理', 'route': '/permissions', 'color': Color(0xFFF77234)},
    {'icon': Icons.receipt_long_outlined, 'label': '充值记录', 'route': '/recharge-records', 'color': Color(0xFF9FDB1D)},
    {'icon': Icons.fact_check_outlined, 'label': '核销记录', 'route': '/verify-records', 'color': Color(0xFFF53F3F)},
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    _error = null;

    // 并行加载会员列表和业绩数据
    try {
      final memberProvider = context.read<MemberProvider>();
      await memberProvider.loadMembers();
      _apiMembers = memberProvider.members;
    } catch (e) {
      debugPrint('加载会员列表失败: $e');
      _error = '加载会员列表失败';
    }

    try {
      final perfRepo = PerformanceRepository();
      _apiPerformance = await perfRepo.getPerformance(period: 'today');
    } catch (e) {
      debugPrint('加载业绩数据失败: $e');
      if (_error == null) _error = '加载业绩数据失败';
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  /// 获取当前显示的会员数据
  List<dynamic> get _displayMembers => _apiMembers;

  /// 获取今日营收
  String get _todayRevenue {
    if (_apiPerformance != null) {
      try {
        final stats = _apiPerformance!['todayStats'] ?? _apiPerformance;
        return '¥${(stats['serviceAmount'] ?? 0).toString()}';
      } catch (_) {}
    }
    return '¥0';
  }

  /// 获取服务人次
  String get _serviceCount {
    if (_apiPerformance != null) {
      try {
        final stats = _apiPerformance!['todayStats'] ?? _apiPerformance;
        return '${stats['serviceCount'] ?? 0}人';
      } catch (_) {}
    }
    return '0人';
  }

  /// 获取新增会员
  String get _newMembers {
    if (_apiPerformance != null) {
      try {
        final stats = _apiPerformance!['todayStats'] ?? _apiPerformance;
        return '${stats['newMembers'] ?? 0}人';
      } catch (_) {}
    }
    return '0人';
  }

  /// 获取次卡核销
  String get _cardVerify {
    if (_apiPerformance != null) {
      try {
        final stats = _apiPerformance!['todayStats'] ?? _apiPerformance;
        return '${stats['cardVerify'] ?? 0}次';
      } catch (_) {}
    }
    return '0次';
  }

  /// 获取当前员工信息
  String get _staffInfo {
    final authProvider = context.read<AuthProvider>();
    final staff = authProvider.staff;
    if (staff != null) {
      final name = staff['realName'] ?? staff['username'] ?? '未知';
      final now = DateTime.now();
      final dateStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      return '店员: $name | $dateStr';
    }
    return '店员: 张美容 | 2024-06-03';
  }

  @override
  Widget build(BuildContext context) {
    final spacing = ResponsiveHelper.spacing(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // 顶部蓝色头部
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0052D9), Color(0xFF003CAB)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.all(spacing),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 门店信息行
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '美丽人生旗舰店',
                                style: TextStyle(
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                _staffInfo,
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  color: Colors.white.withOpacity(0.8),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.circle, size: 8.sp, color: const Color(0xFF00A870)),
                                SizedBox(width: 4.w),
                                Text(
                                  '营业中',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: spacing * 1.5),

                      // 今日数据卡片
                      Container(
                        padding: EdgeInsets.all(spacing),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatItem('今日营收', _todayRevenue, Icons.paid),
                            _buildDivider(),
                            _buildStatItem('服务人次', _serviceCount, Icons.people),
                            _buildDivider(),
                            _buildStatItem('新增会员', _newMembers, Icons.person_add),
                            _buildDivider(),
                            _buildStatItem('次卡核销', _cardVerify, Icons.check_circle),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 快捷功能区
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(spacing),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '快捷功能',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1D2129),
                    ),
                  ),
                  SizedBox(height: spacing),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: ResponsiveHelper.responsive(context, phone: 4, pad: 4, largePad: 4) as int,
                      childAspectRatio: 0.85,
                      crossAxisSpacing: 12.w,
                      mainAxisSpacing: 12.h,
                    ),
                    itemCount: _menuItems.length,
                    itemBuilder: (context, index) {
                      final item = _menuItems[index];
                      return _buildMenuCard(item, spacing);
                    },
                  ),
                ],
              ),
            ),
          ),

          // 今日动态
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: spacing),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '今日动态',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1D2129),
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Text('查看全部'),
                      ),
                    ],
                  ),
                  SizedBox(height: spacing * 0.5),
                  _buildActivityCard(
                    '14:30',
                    '会员 李美丽 核销了 面部护理次卡',
                    '剩余 5 次',
                    const Color(0xFF0052D9),
                  ),
                  _buildActivityCard(
                    '13:15',
                    '新会员 王芳 办理了 洗剪吹10次卡',
                    '¥1,980',
                    const Color(0xFF00A870),
                  ),
                  _buildActivityCard(
                    '11:00',
                    '会员 张婷 充值了 ¥500',
                    '余额 ¥1,280',
                    const Color(0xFFED7B2F),
                  ),
                  _buildActivityCard(
                    '10:20',
                    '会员 刘洋 核销了 精油按摩次卡',
                    '剩余 2 次',
                    const Color(0xFF0052D9),
                  ),
                ],
              ),
            ),
          ),

          SliverPadding(padding: EdgeInsets.only(bottom: 100.h)),
        ],
      ),

      // 底部导航
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
          switch (index) {
            case 0:
              context.go('/dashboard');
              break;
            case 1:
              context.go('/members');
              break;
            case 2:
              context.go('/verify');
              break;
            case 3:
              context.go('/performance');
              break;
            case 4:
              context.go('/settings');
              break;
          }
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF0052D9),
        unselectedItemColor: const Color(0xFF86909C),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '首页'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: '会员'),
          BottomNavigationBarItem(icon: Icon(Icons.qr_code_scanner), label: '核销'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: '业绩'),
          BottomNavigationBarItem(icon: Icon(Icons.more_horiz), label: '更多'),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white.withOpacity(0.8), size: 20.sp),
        SizedBox(height: 6.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 40.h,
      color: Colors.white.withOpacity(0.15),
    );
  }

  Widget _buildMenuCard(Map<String, dynamic> item, double spacing) {
    return GestureDetector(
      onTap: () => context.go(item['route'] as String),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48.r,
              height: 48.r,
              decoration: BoxDecoration(
                color: (item['color'] as Color).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                item['icon'] as IconData,
                color: item['color'] as Color,
                size: 24.sp,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              item['label'] as String,
              style: TextStyle(
                fontSize: 13.sp,
                color: const Color(0xFF4E5969),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityCard(String time, String title, String subtitle, Color color) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Center(
              child: Text(
                time,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: const Color(0xFF1D2129),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: const Color(0xFF86909C),
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: const Color(0xFFC9CDD4), size: 20.sp),
        ],
      ),
    );
  }
}
