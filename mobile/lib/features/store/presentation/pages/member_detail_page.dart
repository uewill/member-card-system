import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:member_card_app/core/utils/responsive_helper.dart';

class MemberDetailPage extends StatefulWidget {
  final String id;

  const MemberDetailPage({super.key, required this.id});

  @override
  State<MemberDetailPage> createState() => _MemberDetailPageState();
}

class _MemberDetailPageState extends State<MemberDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Mock 会员数据
  final Map<String, dynamic> _member = {
    'name': '李美丽',
    'phone': '138****8888',
    'level': 'VIP',
    'balance': 1280.50,
    'points': 2580,
    'totalSpent': 15680.00,
    'memberDays': 365,
    'joinDate': '2025-06-01',
  };

  // Mock 次卡数据
  final List<Map<String, dynamic>> _cards = [
    {
      'id': '1',
      'name': '精剪次卡',
      'type': '次卡',
      'total': 10,
      'used': 6,
      'remain': 4,
      'expiry': '2026-08-15',
    },
    {
      'id': '2',
      'name': '烫染套餐卡',
      'type': '次卡',
      'total': 5,
      'used': 2,
      'remain': 3,
      'expiry': '2026-12-31',
    },
    {
      'id': '3',
      'name': '储值金卡',
      'type': '储值卡',
      'total': 5000,
      'used': 3200,
      'remain': 1800,
      'expiry': '2027-06-01',
    },
  ];

  // Mock 消费记录
  final List<Map<String, dynamic>> _consumeRecords = [
    {
      'time': '2026-06-02 14:30',
      'service': '精剪造型',
      'staff': '张师傅',
      'amount': '-¥128.00',
      'type': 'amount',
    },
    {
      'time': '2026-05-28 10:15',
      'service': '精剪次卡核销',
      'staff': '李师傅',
      'amount': '-1次',
      'type': 'times',
    },
    {
      'time': '2026-05-25 16:00',
      'service': '染发服务',
      'staff': '王师傅',
      'amount': '-¥298.00',
      'type': 'amount',
    },
    {
      'time': '2026-05-20 11:30',
      'service': '头皮护理',
      'staff': '赵师傅',
      'amount': '-¥168.00',
      'type': 'amount',
    },
    {
      'time': '2026-05-15 09:00',
      'service': '精剪次卡核销',
      'staff': '张师傅',
      'amount': '-1次',
      'type': 'times',
    },
  ];

  // Mock 充值记录
  final List<Map<String, dynamic>> _rechargeRecords = [
    {
      'time': '2026-05-10 15:20',
      'amount': '+¥2,000.00',
      'method': '微信支付',
      'staff': '前台-小陈',
    },
    {
      'time': '2026-03-15 11:00',
      'amount': '+¥1,000.00',
      'method': '支付宝',
      'staff': '前台-小陈',
    },
    {
      'time': '2026-01-08 14:30',
      'amount': '+¥5,000.00',
      'method': '银行卡',
      'staff': '店长-刘总',
    },
    {
      'time': '2025-11-20 09:45',
      'amount': '+¥500.00',
      'method': '现金',
      'staff': '前台-小李',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final spacing = ResponsiveHelper.spacing(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('会员详情'),
        backgroundColor: const Color(0xFF0052D9),
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: () {
              // TODO: 编辑会员信息
            },
            child: const Text(
              '编辑',
              style: TextStyle(color: Colors.white, fontSize: 15),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 会员信息头部
            _buildMemberHeader(spacing),

            // 统计行
            _buildStatsRow(spacing),

            // Tab 栏
            Container(
              color: Colors.white,
              child: TabBar(
                controller: _tabController,
                labelColor: const Color(0xFF0052D9),
                unselectedLabelColor: const Color(0xFF86909C),
                indicatorColor: const Color(0xFF0052D9),
                indicatorSize: TabBarIndicatorSize.label,
                tabs: const [
                  Tab(text: '次卡'),
                  Tab(text: '消费记录'),
                  Tab(text: '充值记录'),
                ],
              ),
            ),

            // Tab 内容
            SizedBox(
              height: 500.h,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildCardsTab(spacing),
                  _buildConsumeTab(spacing),
                  _buildRechargeTab(spacing),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 会员信息头部
  Widget _buildMemberHeader(double spacing) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0052D9), Color(0xFF266FE8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: spacing, vertical: 24.h),
      child: Column(
        children: [
          // 头像
          Container(
            width: 72.r,
            height: 72.r,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(36.r),
              border: Border.all(color: Colors.white.withOpacity(0.4), width: 2),
            ),
            child: Center(
              child: Text(
                _member['name'].toString().substring(0, 1),
                style: TextStyle(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          SizedBox(height: 12.h),
          // 姓名和 VIP 标签
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _member['name'],
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 8.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFC53D),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star, size: 12.sp, color: const Color(0xFF7A4100)),
                    SizedBox(width: 2.w),
                    Text(
                      _member['level'],
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF7A4100),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          // 手机号
          Text(
            _member['phone'],
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  /// 统计行
  Widget _buildStatsRow(double spacing) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: spacing, vertical: 12.h),
      padding: EdgeInsets.symmetric(vertical: 20.h),
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
      child: Row(
        children: [
          _buildStatItem('余额', '¥${_member['balance']}', const Color(0xFF0052D9)),
          _buildStatDivider(),
          _buildStatItem('积分', '${_member['points']}', const Color(0xFF00A870)),
          _buildStatDivider(),
          _buildStatItem('总消费', '¥${_member['totalSpent']}', const Color(0xFFED7B2F)),
          _buildStatDivider(),
          _buildStatItem('会员天数', '${_member['memberDays']}天', const Color(0xFF86909C)),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              color: const Color(0xFF86909C),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatDivider() {
    return Container(
      width: 1,
      height: 36.h,
      color: const Color(0xFFE5E6EB),
    );
  }

  /// 次卡 Tab
  Widget _buildCardsTab(double spacing) {
    return ListView.builder(
      padding: EdgeInsets.all(spacing),
      itemCount: _cards.length,
      itemBuilder: (context, index) {
        final card = _cards[index];
        return _buildCardItem(card, spacing);
      },
    );
  }

  Widget _buildCardItem(Map<String, dynamic> card, double spacing) {
    final progress = card['used'] / card['total'];
    final isStorage = card['type'] == '储值卡';

    return GestureDetector(
      onTap: () {
        context.push('/card-detail/${card['id']}');
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(16.w),
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
            // 卡名和类型
            Row(
              children: [
                Text(
                  card['name'],
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1D2129),
                  ),
                ),
                SizedBox(width: 8.w),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: isStorage
                        ? const Color(0xFF00A870).withOpacity(0.1)
                        : const Color(0xFF0052D9).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Text(
                    card['type'],
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: isStorage
                          ? const Color(0xFF00A870)
                          : const Color(0xFF0052D9),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            // 剩余/总量
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isStorage
                      ? '剩余 ¥${card['remain']} / ¥${card['total']}'
                      : '剩余 ${card['remain']}次 / 共${card['total']}次',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: const Color(0xFF4E5969),
                  ),
                ),
                Text(
                  '有效期至 ${card['expiry']}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: const Color(0xFF86909C),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            // 进度条
            ClipRRect(
              borderRadius: BorderRadius.circular(4.r),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6.h,
                backgroundColor: const Color(0xFFF2F3F5),
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0052D9)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 消费记录 Tab
  Widget _buildConsumeTab(double spacing) {
    return ListView.builder(
      padding: EdgeInsets.all(spacing),
      itemCount: _consumeRecords.length,
      itemBuilder: (context, index) {
        final record = _consumeRecords[index];
        return _buildConsumeItem(record, spacing);
      },
    );
  }

  Widget _buildConsumeItem(Map<String, dynamic> record, double spacing) {
    return Container(
      margin: EdgeInsets.only(bottom: 1.h),
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 14.h),
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record['service'],
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF1D2129),
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Text(
                      record['staff'],
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: const Color(0xFF86909C),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      record['time'],
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: const Color(0xFFC9CDD4),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Text(
            record['amount'],
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFFF53F3F),
            ),
          ),
        ],
      ),
    );
  }

  /// 充值记录 Tab
  Widget _buildRechargeTab(double spacing) {
    return ListView.builder(
      padding: EdgeInsets.all(spacing),
      itemCount: _rechargeRecords.length,
      itemBuilder: (context, index) {
        final record = _rechargeRecords[index];
        return _buildRechargeItem(record, spacing);
      },
    );
  }

  Widget _buildRechargeItem(Map<String, dynamic> record, double spacing) {
    return Container(
      margin: EdgeInsets.only(bottom: 1.h),
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 14.h),
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record['amount'],
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF00A870),
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Text(
                      record['method'],
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: const Color(0xFF86909C),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      record['staff'],
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: const Color(0xFFC9CDD4),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Text(
            record['time'],
            style: TextStyle(
              fontSize: 12.sp,
              color: const Color(0xFFC9CDD4),
            ),
          ),
        ],
      ),
    );
  }
}
