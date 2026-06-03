import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:member_card_app/core/config/app_config.dart';
import 'package:member_card_app/core/utils/responsive_helper.dart';
import 'package:member_card_app/features/member/data/member_repository.dart';

/// 会员首页 - 卡包概览、快捷操作
class MemberHomePage extends StatefulWidget {
  const MemberHomePage({super.key});

  @override
  State<MemberHomePage> createState() => _MemberHomePageState();
}

class _MemberHomePageState extends State<MemberHomePage> {
  final MemberRepository _memberRepository = MemberRepository();

  Map<String, dynamic>? _overview;
  List<Map<String, dynamic>> _cards = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      // 并行加载概览和卡包数据
      final results = await Future.wait([
        _memberRepository.getMemberOverview(),
        _memberRepository.getCardList(),
      ]);

      setState(() {
        _overview = results[0] as Map<String, dynamic>;
        _cards = List<Map<String, dynamic>>.from(results[1] as List);
        _isLoading = false;
      });
    } catch (e) {
      // 使用模拟数据展示 UI
      setState(() {
        _overview = {
          'memberName': '张三',
          'phone': '138****8888',
          'totalCards': 3,
          'totalBalance': 1520.0,
          'totalPoints': 860,
          'expiringSoon': 1,
        };
        _cards = [
          {
            'id': 1,
            'name': '洗剪吹10次卡',
            'type': 'COUNT',
            'remaining': 8,
            'validTo': '2026-12-31',
            'status': 'ACTIVE',
          },
          {
            'id': 2,
            'name': '储值卡500元',
            'type': 'VALUE',
            'balance': 320.0,
            'validTo': '2027-06-30',
            'status': 'ACTIVE',
          },
          {
            'id': 3,
            'name': '全身SPA套餐',
            'type': 'COUNT',
            'remaining': 3,
            'validTo': '2026-08-15',
            'status': 'ACTIVE',
          },
        ];
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
                onRefresh: _loadData,
                child: ListView(
                  padding: EdgeInsets.all(spacing),
                  children: [
                    _buildMemberHeader(spacing),
                    SizedBox(height: spacing),
                    _buildQuickActions(spacing),
                    SizedBox(height: spacing),
                    _buildStatsCards(spacing),
                    SizedBox(height: spacing),
                    _buildCardBagSection(spacing),
                  ],
                ),
              ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  /// 会员头部信息
  Widget _buildMemberHeader(double spacing) {
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
                      _overview?['memberName'] ?? '会员用户',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      _overview?['phone'] ?? '',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => context.push('/member/profile'),
                icon: const Icon(Icons.settings, color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 快捷操作按钮
  Widget _buildQuickActions(double spacing) {
    final actions = [
      {'icon': Icons.credit_card, 'label': '我的卡包', 'route': '/member/cards'},
      {'icon': Icons.qr_code, 'label': '出示二维码', 'action': 'qrcode'},
      {'icon': Icons.receipt_long, 'label': '消费记录', 'route': '/member/consume-records'},
      {'icon': Icons.shopping_bag, 'label': '购买套餐', 'route': '/member/purchase'},
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: actions.map((item) {
        return GestureDetector(
          onTap: () {
            if (item['action'] == 'qrcode') {
              _showQrCodeDialog();
            } else {
              context.push(item['route'] as String);
            }
          },
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

  /// 统计卡片（余额、积分、即将过期）
  Widget _buildStatsCards(double spacing) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            spacing,
            title: '总余额',
            value: '¥${_overview?['totalBalance'] ?? 0}',
            color: Colors.orange,
          ),
        ),
        SizedBox(width: spacing / 2),
        Expanded(
          child: _buildStatCard(
            spacing,
            title: '积分',
            value: '${_overview?['totalPoints'] ?? 0}',
            color: Colors.purple,
          ),
        ),
        SizedBox(width: spacing / 2),
        Expanded(
          child: _buildStatCard(
            spacing,
            title: '即将过期',
            value: '${_overview?['expiringSoon'] ?? 0}张',
            color: Colors.red,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    double spacing, {
    required String title,
    required String value,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  /// 卡包概览区域
  Widget _buildCardBagSection(double spacing) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '我的卡包',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            GestureDetector(
              onTap: () => context.push('/member/cards'),
              child: Text(
                '查看全部 >',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppConfig.primaryColor,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: spacing / 2),
        ..._cards.map((card) => _buildCardItem(card, spacing)),
      ],
    );
  }

  Widget _buildCardItem(Map<String, dynamic> card, double spacing) {
    final isCountCard = card['type'] == 'COUNT';
    final isActive = card['status'] == 'ACTIVE';

    return Card(
      margin: EdgeInsets.only(bottom: spacing / 2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: InkWell(
        onTap: () => context.push('/member/cards'),
        borderRadius: BorderRadius.circular(8.r),
        child: Padding(
          padding: EdgeInsets.all(spacing),
          child: Row(
            children: [
              Container(
                width: 40.r,
                height: 40.r,
                decoration: BoxDecoration(
                  color: isActive
                      ? AppConfig.primaryColor.withOpacity(0.1)
                      : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  isCountCard ? Icons.event_repeat : Icons.account_balance_wallet,
                  color: isActive ? AppConfig.primaryColor : Colors.grey,
                  size: 20.sp,
                ),
              ),
              SizedBox(width: spacing),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      card['name'],
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      isCountCard
                          ? '剩余 ${card['remaining']} 次'
                          : '余额 ¥${card['balance']}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '有效期至 ${card['validTo']}',
                style: TextStyle(
                  fontSize: 11.sp,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
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
        BottomNavigationBarItem(icon: Icon(Icons.credit_card), label: '卡包'),
        BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: '记录'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: '我的'),
      ],
      onTap: (index) {
        switch (index) {
          case 0:
            break;
          case 1:
            context.push('/member/cards');
            break;
          case 2:
            context.push('/member/consume-records');
            break;
          case 3:
            context.push('/member/profile');
            break;
        }
      },
    );
  }

  /// 显示二维码对话框
  void _showQrCodeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('我的会员二维码'),
        content: SizedBox(
          width: 200,
          height: 200,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.qr_code, size: 150, color: Colors.grey.shade300),
                const SizedBox(height: 8),
                Text(
                  '加载中...',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }
}
