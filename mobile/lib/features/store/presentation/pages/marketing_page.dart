import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:member_card_app/core/utils/responsive_helper.dart';
import 'package:member_card_app/shared/services/api/coupon_repository.dart';

/// 营销工具页 - 积分管理 / 优惠券 / 消息推送
class MarketingPage extends StatefulWidget {
  const MarketingPage({super.key});

  @override
  State<MarketingPage> createState() => _MarketingPageState();
}

class _MarketingPageState extends State<MarketingPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final CouponRepository _couponRepo = CouponRepository();

  bool _isLoading = false;
  List<dynamic> _coupons = [];

  // 积分规则
  bool _pointsEnabled = true;
  double _pointsPerYuan = 1.0;

  // 消息推送开关
  bool _cardExpiryNotify = true;
  bool _birthdayNotify = true;
  bool _activityNotify = false;

  // Mock 优惠券数据
  final List<Map<String, dynamic>> _mockCoupons = [
    {
      'name': '新客首单8折券',
      'type': '折扣券',
      'value': '8折',
      'validPeriod': '2024-06-01 ~ 2024-06-30',
      'status': '进行中',
      'statusColor': const Color(0xFF00A870),
    },
    {
      'name': '满200减30券',
      'type': '满减券',
      'value': '¥30',
      'validPeriod': '2024-06-01 ~ 2024-07-31',
      'status': '进行中',
      'statusColor': const Color(0xFF00A870),
    },
    {
      'name': '充值赠送券',
      'type': '赠品券',
      'value': '赠面膜1片',
      'validPeriod': '2024-05-01 ~ 2024-05-31',
      'status': '已结束',
      'statusColor': const Color(0xFF86909C),
    },
    {
      'name': '会员日9折券',
      'type': '折扣券',
      'value': '9折',
      'validPeriod': '2024-06-15 ~ 2024-06-15',
      'status': '未开始',
      'statusColor': const Color(0xFFEBB105),
    },
  ];

  // Mock 积分兑换记录
  final List<Map<String, dynamic>> _mockPointsRecords = [
    {'member': '李美丽', 'action': '消费积分', 'points': '+52', 'time': '2024-06-03 14:30'},
    {'member': '王芳', 'action': '兑换面膜', 'points': '-200', 'time': '2024-06-03 13:15'},
    {'member': '张婷', 'action': '消费积分', 'points': '+35', 'time': '2024-06-03 11:00'},
    {'member': '刘洋', 'action': '兑换洗发水', 'points': '-500', 'time': '2024-06-02 16:20'},
    {'member': '陈静', 'action': '消费积分', 'points': '+28', 'time': '2024-06-02 10:00'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadCoupons();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadCoupons() async {
    setState(() => _isLoading = true);
    try {
      final data = await _couponRepo.getCoupons();
      if (mounted) setState(() => _coupons = data);
    } catch (e) {
      debugPrint('加载优惠券失败，使用 Mock 数据: $e');
      if (mounted) setState(() => _coupons = _mockCoupons);
    }
    if (mounted) setState(() => _isLoading = false);
  }

  void _showCreateCouponDialog() {
    final nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('创建优惠券'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: '优惠券名称',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: '优惠券类型',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: '折扣券', child: Text('折扣券')),
                DropdownMenuItem(value: '满减券', child: Text('满减券')),
                DropdownMenuItem(value: '赠品券', child: Text('赠品券')),
              ],
              onChanged: (_) {},
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _couponRepo.createCoupon({
                  'name': nameController.text,
                });
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('优惠券创建成功')),
                  );
                  _loadCoupons();
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('创建失败: $e')),
                  );
                }
              }
            },
            child: const Text('创建'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final spacing = ResponsiveHelper.spacing(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('营销工具'),
        backgroundColor: const Color(0xFF0052D9),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
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
                Tab(text: '积分管理'),
                Tab(text: '优惠券'),
                Tab(text: '消息推送'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildPointsTab(spacing),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _buildCouponTab(spacing),
                _buildPushTab(spacing),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 积分管理 Tab
  Widget _buildPointsTab(double spacing) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(spacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 积分规则配置
          Text('积分规则',
              style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1D2129))),
          SizedBox(height: spacing * 0.75),
          Container(
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
              children: [
                // 积分开关
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('启用积分功能',
                        style: TextStyle(
                            fontSize: 15.sp,
                            color: const Color(0xFF1D2129))),
                    Switch(
                      value: _pointsEnabled,
                      activeColor: const Color(0xFF0052D9),
                      onChanged: (val) {
                        setState(() => _pointsEnabled = val);
                      },
                    ),
                  ],
                ),
                const Divider(height: 24),
                // 积分比例
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('每消费1元积',
                        style: TextStyle(
                            fontSize: 15.sp,
                            color: const Color(0xFF1D2129))),
                    Row(
                      children: [
                        SizedBox(
                          width: 60.w,
                          child: TextField(
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            controller: TextEditingController(
                                text: _pointsPerYuan.toInt().toString()),
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 8.w, vertical: 8.h),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6.r),
                              ),
                              isDense: true,
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text('分',
                            style: TextStyle(
                                fontSize: 15.sp,
                                color: const Color(0xFF1D2129))),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: spacing),

          // 积分兑换记录
          Text('积分兑换记录',
              style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1D2129))),
          SizedBox(height: spacing * 0.75),
          ...List.generate(_mockPointsRecords.length, (index) {
            return _buildPointsRecordCard(_mockPointsRecords[index], spacing);
          }),
        ],
      ),
    );
  }

  Widget _buildPointsRecordCard(Map<String, dynamic> item, double spacing) {
    final isAdd = (item['points'] as String).startsWith('+');
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
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
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(item['member'],
                        style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1D2129))),
                    SizedBox(width: 8.w),
                    Text(item['action'],
                        style: TextStyle(
                            fontSize: 12.sp,
                            color: const Color(0xFF86909C))),
                  ],
                ),
                SizedBox(height: 4.h),
                Text(item['time'],
                    style: TextStyle(
                        fontSize: 12.sp, color: const Color(0xFFC9CDD4))),
              ],
            ),
          ),
          Text(
            item['points'],
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: isAdd ? const Color(0xFF00A870) : const Color(0xFFE34D59),
            ),
          ),
        ],
      ),
    );
  }

  /// 优惠券 Tab
  Widget _buildCouponTab(double spacing) {
    final data = _coupons.isNotEmpty ? _coupons : _mockCoupons;

    return SingleChildScrollView(
      padding: EdgeInsets.all(spacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 创建按钮
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _showCreateCouponDialog,
              icon: const Icon(Icons.add),
              label: const Text('创建优惠券'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0052D9),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
            ),
          ),
          SizedBox(height: spacing),

          // 优惠券列表
          ...List.generate(data.length, (index) {
            final item = data[index] as Map<String, dynamic>;
            return _buildCouponCard(item, spacing);
          }),
        ],
      ),
    );
  }

  Widget _buildCouponCard(Map<String, dynamic> item, double spacing) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
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
          // 左侧金额区域
          Container(
            width: 80.w,
            padding: EdgeInsets.symmetric(vertical: 16.h),
            decoration: BoxDecoration(
              color: const Color(0xFF0052D9).withOpacity(0.08),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12.r),
                bottomLeft: Radius.circular(12.r),
              ),
            ),
            child: Column(
              children: [
                Text(
                  item['value'] ?? '',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0052D9),
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  item['type'] ?? '',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: const Color(0xFF86909C),
                  ),
                ),
              ],
            ),
          ),
          // 右侧信息
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(spacing * 0.75),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item['name'] ?? '',
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1D2129),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 8.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: (item['statusColor'] as Color?)
                                  ?.withOpacity(0.1) ??
                              const Color(0xFF86909C).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Text(
                          item['status'] ?? '',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: item['statusColor'] as Color? ??
                                const Color(0xFF86909C),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    item['validPeriod'] ?? '',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: const Color(0xFF86909C),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 消息推送 Tab
  Widget _buildPushTab(double spacing) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(spacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('推送配置',
              style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1D2129))),
          SizedBox(height: spacing * 0.75),
          Container(
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
              children: [
                _buildPushSettingRow(
                  icon: Icons.credit_card,
                  title: '卡到期提醒',
                  subtitle: '会员卡到期前3天自动推送提醒',
                  value: _cardExpiryNotify,
                  onChanged: (val) =>
                      setState(() => _cardExpiryNotify = val),
                ),
                const Divider(height: 24),
                _buildPushSettingRow(
                  icon: Icons.cake,
                  title: '生日祝福',
                  subtitle: '会员生日当天推送祝福和优惠券',
                  value: _birthdayNotify,
                  onChanged: (val) =>
                      setState(() => _birthdayNotify = val),
                ),
                const Divider(height: 24),
                _buildPushSettingRow(
                  icon: Icons.campaign,
                  title: '活动通知',
                  subtitle: '新活动上线时推送通知给所有会员',
                  value: _activityNotify,
                  onChanged: (val) =>
                      setState(() => _activityNotify = val),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPushSettingRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        Container(
          width: 40.r,
          height: 40.r,
          decoration: BoxDecoration(
            color: const Color(0xFF0052D9).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(icon, color: const Color(0xFF0052D9), size: 20.sp),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1D2129))),
              SizedBox(height: 2.h),
              Text(subtitle,
                  style: TextStyle(
                      fontSize: 12.sp, color: const Color(0xFF86909C))),
            ],
          ),
        ),
        Switch(
          value: value,
          activeColor: const Color(0xFF0052D9),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
