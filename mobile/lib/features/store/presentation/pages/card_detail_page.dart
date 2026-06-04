import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:member_card_app/core/utils/responsive_helper.dart';

class CardDetailPage extends StatefulWidget {
  final String id;

  const CardDetailPage({super.key, required this.id});

  @override
  State<CardDetailPage> createState() => _CardDetailPageState();
}

class _CardDetailPageState extends State<CardDetailPage> {
  // Mock 卡片数据
  late Map<String, dynamic> _card;

  // Mock 关联服务
  final List<Map<String, dynamic>> _services = [
    {'name': '精剪造型', 'icon': Icons.content_cut},
    {'name': '洗剪吹', 'icon': Icons.face},
    {'name': '头部按摩', 'icon': Icons.spa},
  ];

  // Mock 使用记录
  final List<Map<String, dynamic>> _usageRecords = [
    {
      'time': '2026-06-02 14:30',
      'service': '精剪造型',
      'staff': '张师傅',
    },
    {
      'time': '2026-05-20 10:15',
      'service': '洗剪吹',
      'staff': '李师傅',
    },
    {
      'time': '2026-05-10 16:00',
      'service': '精剪造型',
      'staff': '张师傅',
    },
    {
      'time': '2026-04-28 11:30',
      'service': '头部按摩',
      'staff': '赵师傅',
    },
    {
      'time': '2026-04-15 09:00',
      'service': '精剪造型',
      'staff': '张师傅',
    },
    {
      'time': '2026-03-30 14:45',
      'service': '洗剪吹',
      'staff': '李师傅',
    },
  ];

  @override
  void initState() {
    super.initState();
    // 根据 id 模拟不同卡片数据
    _card = {
      'id': widget.id,
      'cardNo': 'TK2026010001',
      'name': '精剪次卡',
      'type': '次卡',
      'status': '使用中',
      'total': 10,
      'used': 6,
      'remain': 4,
      'startDate': '2026-01-15',
      'endDate': '2026-08-15',
      'price': 680.00,
      'memberName': '李美丽',
      'memberPhone': '138****8888',
    };
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF0052D9),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final spacing = ResponsiveHelper.spacing(context);
    final progress = _card['used'] / _card['total'];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('次卡详情'),
        backgroundColor: const Color(0xFF0052D9),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 卡片信息头部
            _buildCardHeader(spacing),

            // 进度条区域
            _buildProgressSection(spacing, progress),

            // 有效期
            _buildValiditySection(spacing),

            // 关联服务列表
            _buildServicesSection(spacing),

            // 使用记录列表
            _buildUsageRecordsSection(spacing),

            SizedBox(height: 100.h),
          ],
        ),
      ),
      // 底部操作按钮
      bottomNavigationBar: _buildBottomActions(spacing),
    );
  }

  /// 卡片信息头部
  Widget _buildCardHeader(double spacing) {
    return Container(
      margin: EdgeInsets.all(spacing),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0052D9), Color(0xFF266FE8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0052D9).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _card['name'],
                    style: TextStyle(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    '卡号: ${_card['cardNo']}',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Text(
                  _card['type'],
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF00C853),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text(
                  _card['status'],
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                '持卡人: ${_card['memberName']}',
                style: TextStyle(
                  fontSize: 13.sp,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 进度条区域
  Widget _buildProgressSection(double spacing, double progress) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: spacing),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '使用进度',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1D2129),
                ),
              ),
              Text(
                '已用 ${_card['used']} / ${_card['total']} 次',
                style: TextStyle(
                  fontSize: 13.sp,
                  color: const Color(0xFF86909C),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          // 进度条
          ClipRRect(
            borderRadius: BorderRadius.circular(6.r),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10.h,
              backgroundColor: const Color(0xFFF2F3F5),
              valueColor: AlwaysStoppedAnimation<Color>(
                progress > 0.8
                    ? const Color(0xFFF53F3F)
                    : const Color(0xFF0052D9),
              ),
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '剩余 ${_card['remain']} 次',
                style: TextStyle(
                  fontSize: 13.sp,
                  color: const Color(0xFF0052D9),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${(progress * 100).toStringAsFixed(0)}% 已使用',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: const Color(0xFF86909C),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 有效期区域
  Widget _buildValiditySection(double spacing) {
    return Container(
      margin: EdgeInsets.all(spacing),
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
      child: Row(
        children: [
          Icon(
            Icons.calendar_today,
            size: 20.sp,
            color: const Color(0xFF0052D9),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '有效期',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1D2129),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '${_card['startDate']} 至 ${_card['endDate']}',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: const Color(0xFF4E5969),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            size: 20.sp,
            color: const Color(0xFFC9CDD4),
          ),
        ],
      ),
    );
  }

  /// 关联服务列表
  Widget _buildServicesSection(double spacing) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: spacing),
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
          Text(
            '关联服务',
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1D2129),
            ),
          ),
          SizedBox(height: 12.h),
          ..._services.map((service) => Padding(
            padding: EdgeInsets.only(bottom: 10.h),
            child: Row(
              children: [
                Container(
                  width: 36.r,
                  height: 36.r,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0052D9).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    service['icon'],
                    size: 18.sp,
                    color: const Color(0xFF0052D9),
                  ),
                ),
                SizedBox(width: 12.w),
                Text(
                  service['name'],
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: const Color(0xFF1D2129),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  /// 使用记录列表
  Widget _buildUsageRecordsSection(double spacing) {
    return Container(
      margin: EdgeInsets.all(spacing),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '使用记录',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1D2129),
                ),
              ),
              Text(
                '共 ${_usageRecords.length} 条',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: const Color(0xFF86909C),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          ..._usageRecords.map((record) => _buildUsageItem(record)),
        ],
      ),
    );
  }

  Widget _buildUsageItem(Map<String, dynamic> record) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFFF2F3F5),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 8.r,
            height: 8.r,
            decoration: const BoxDecoration(
              color: Color(0xFF0052D9),
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record['service'],
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF1D2129),
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  '${record['staff']} | ${record['time']}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: const Color(0xFF86909C),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            size: 16.sp,
            color: const Color(0xFFC9CDD4),
          ),
        ],
      ),
    );
  }

  /// 底部操作按钮
  Widget _buildBottomActions(double spacing) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: spacing, vertical: 12.h),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  _showFreezeDialog();
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF0052D9),
                  side: const BorderSide(color: Color(0xFF0052D9)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                ),
                child: Text(
                  '冻结',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  context.push('/recharge-confirm');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0052D9),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  elevation: 0,
                ),
                child: Text(
                  '续费',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFreezeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认冻结'),
        content: const Text('冻结后该卡将暂停使用，确认冻结此次卡吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showSnackBar('次卡已冻结');
            },
            child: const Text('确认冻结', style: TextStyle(color: Color(0xFFF53F3F))),
          ),
        ],
      ),
    );
  }
}
