import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:member_card_app/core/config/app_config.dart';
import 'package:member_card_app/core/utils/responsive_helper.dart';
import 'package:member_card_app/features/staff/data/staff_repository.dart';

/// 员工首页 - 今日业绩概览
class StaffHomePage extends StatefulWidget {
  const StaffHomePage({super.key});

  @override
  State<StaffHomePage> createState() => _StaffHomePageState();
}

class _StaffHomePageState extends State<StaffHomePage> {
  final StaffRepository _staffRepository = StaffRepository();

  Map<String, dynamic>? _overview;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOverview();
  }

  Future<void> _loadOverview() async {
    try {
      final overview = await _staffRepository.getTodayOverview();
      setState(() {
        _overview = overview;
        _isLoading = false;
      });
    } catch (e) {
      // 使用模拟数据
      setState(() {
        _overview = {
          'staffName': '王师傅',
          'storeName': '旗舰店',
          'todayServiceCount': 8,
          'todayRevenue': 1280.0,
          'todayNewMembers': 2,
          'monthServiceCount': 156,
          'monthRevenue': 24560.0,
          'monthTarget': 30000.0,
          'ranking': 3,
          'totalStaff': 12,
          'recentServices': [
            {
              'id': 1,
              'memberName': '张三',
              'serviceName': '精剪造型',
              'amount': 128.0,
              'time': '14:30',
            },
            {
              'id': 2,
              'memberName': '李四',
              'serviceName': '染发',
              'amount': 256.0,
              'time': '13:15',
            },
            {
              'id': 3,
              'memberName': '王五',
              'serviceName': '头皮护理',
              'amount': 68.0,
              'time': '11:00',
            },
          ],
        };
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final spacing = ResponsiveHelper.spacing(context);

    return Scaffold(
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _loadOverview,
                child: ListView(
                  padding: EdgeInsets.all(spacing),
                  children: [
                    _buildStaffHeader(spacing),
                    SizedBox(height: spacing),
                    _buildTodayStats(spacing),
                    SizedBox(height: spacing),
                    _buildMonthProgress(spacing),
                    SizedBox(height: spacing),
                    _buildQuickActions(spacing),
                    SizedBox(height: spacing),
                    _buildRecentServices(spacing),
                  ],
                ),
              ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  /// 员工头部信息
  Widget _buildStaffHeader(double spacing) {
    return Container(
      padding: EdgeInsets.all(spacing),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppConfig.primaryColor,
            AppConfig.primaryColor.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 28.r,
                backgroundColor: Colors.white24,
                child: Icon(
                  Icons.person,
                  size: 32.sp,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: spacing),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _overview?['staffName'] ?? '员工',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      _overview?['storeName'] ?? '',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Text(
                  '排名 ${_overview?['ranking'] ?? '-'}/${_overview?['totalStaff'] ?? '-'}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 今日统计
  Widget _buildTodayStats(double spacing) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            spacing,
            title: '今日服务',
            value: '${_overview?['todayServiceCount'] ?? 0}单',
            icon: Icons.content_cut,
            color: Colors.blue,
          ),
        ),
        SizedBox(width: spacing / 2),
        Expanded(
          child: _buildStatCard(
            spacing,
            title: '今日营收',
            value: '¥${_overview?['todayRevenue'] ?? 0}',
            icon: Icons.payments,
            color: Colors.orange,
          ),
        ),
        SizedBox(width: spacing / 2),
        Expanded(
          child: _buildStatCard(
            spacing,
            title: '新客数',
            value: '${_overview?['todayNewMembers'] ?? 0}人',
            icon: Icons.person_add,
            color: Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    double spacing, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(spacing * 0.75),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24.sp),
          SizedBox(height: 4.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            title,
            style: TextStyle(
              fontSize: 11.sp,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  /// 月度进度
  Widget _buildMonthProgress(double spacing) {
    final monthRevenue = (_overview?['monthRevenue'] ?? 0.0) as num;
    final monthTarget = (_overview?['monthTarget'] ?? 1.0) as num;
    final progress = (monthRevenue / monthTarget).clamp(0.0, 1.0);

    return Container(
      padding: EdgeInsets.all(spacing),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '本月业绩',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              GestureDetector(
                onTap: () => context.push('/staff/performance'),
                child: Text(
                  '查看详情 >',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppConfig.primaryColor,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: spacing),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '¥${monthRevenue.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: AppConfig.primaryColor,
                ),
              ),
              Text(
                '目标 ¥${monthTarget.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          SizedBox(height: spacing / 2),
          ClipRRect(
            borderRadius: BorderRadius.circular(4.r),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8.h,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(AppConfig.primaryColor),
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            '完成 ${(progress * 100).toStringAsFixed(1)}%  |  累计服务 ${_overview?['monthServiceCount'] ?? 0} 单',
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  /// 快捷操作
  Widget _buildQuickActions(double spacing) {
    final actions = [
      {'icon': Icons.qr_code_scanner, 'label': '扫码核销', 'route': '/staff/scan'},
      {'icon': Icons.receipt_long, 'label': '服务历史', 'route': '/staff/service-history'},
      {'icon': Icons.bar_chart, 'label': '业绩详情', 'route': '/staff/performance'},
      {'icon': Icons.people, 'label': '客户列表', 'route': '/staff/customers'},
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: actions.map((item) {
        return GestureDetector(
          onTap: () => context.push(item['route'] as String),
          child: Column(
            children: [
              Container(
                width: 48.r,
                height: 48.r,
                decoration: BoxDecoration(
                  color: AppConfig.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  item['icon'] as IconData,
                  color: AppConfig.primaryColor,
                  size: 24.sp,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                item['label'] as String,
                style: TextStyle(fontSize: 12.sp),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  /// 最近服务记录
  Widget _buildRecentServices(double spacing) {
    final recentServices = List<Map<String, dynamic>>.from(_overview?['recentServices'] ?? []);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '最近服务',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: spacing / 2),
        ...recentServices.map((service) => _buildServiceItem(service, spacing)),
      ],
    );
  }

  Widget _buildServiceItem(Map<String, dynamic> service, double spacing) {
    return Card(
      margin: EdgeInsets.only(bottom: spacing / 2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(spacing),
        child: Row(
          children: [
            Container(
              width: 40.r,
              height: 40.r,
              decoration: BoxDecoration(
                color: AppConfig.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                Icons.content_cut,
                color: AppConfig.primaryColor,
                size: 20.sp,
              ),
            ),
            SizedBox(width: spacing),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service['memberName'],
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    service['serviceName'],
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '¥${service['amount']}',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  service['time'],
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 底部导航栏
  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: 0,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: '首页'),
        BottomNavigationBarItem(icon: Icon(Icons.qr_code_scanner), label: '核销'),
        BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: '业绩'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: '我的'),
      ],
      onTap: (index) {
        switch (index) {
          case 0:
            break;
          case 1:
            context.push('/staff/scan');
            break;
          case 2:
            context.push('/staff/performance');
            break;
          case 3:
            break;
        }
      },
    );
  }
}
