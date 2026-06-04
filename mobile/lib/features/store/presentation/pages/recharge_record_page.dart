import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:member_card_app/core/utils/responsive_helper.dart';
import 'package:member_card_app/shared/services/api/recharge_repository.dart';

/// 充值记录页 - 日期筛选 + 搜索 + 记录列表
class RechargeRecordPage extends StatefulWidget {
  const RechargeRecordPage({super.key});

  @override
  State<RechargeRecordPage> createState() => _RechargeRecordPageState();
}

class _RechargeRecordPageState extends State<RechargeRecordPage> {
  final RechargeRepository _rechargeRepo = RechargeRepository();
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = false;
  List<dynamic> _records = [];
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();

  // Mock 数据
  final List<Map<String, dynamic>> _mockRecords = [
    {
      'memberName': '李美丽',
      'amount': 500,
      'bonus': 50,
      'payMethod': '微信支付',
      'operator': '张美容',
      'time': '2024-06-03 14:30',
    },
    {
      'memberName': '王芳',
      'amount': 1000,
      'bonus': 200,
      'payMethod': '支付宝',
      'operator': '李小花',
      'time': '2024-06-03 13:15',
    },
    {
      'memberName': '张婷',
      'amount': 2000,
      'bonus': 500,
      'payMethod': '微信支付',
      'operator': '张美容',
      'time': '2024-06-03 11:00',
    },
    {
      'memberName': '刘洋',
      'amount': 300,
      'bonus': 0,
      'payMethod': '现金',
      'operator': '赵前台',
      'time': '2024-06-02 16:20',
    },
    {
      'memberName': '陈静',
      'amount': 1980,
      'bonus': 380,
      'payMethod': '微信支付',
      'operator': '李小花',
      'time': '2024-06-02 10:00',
    },
    {
      'memberName': '赵敏',
      'amount': 800,
      'bonus': 80,
      'payMethod': '支付宝',
      'operator': '张美容',
      'time': '2024-06-01 15:30',
    },
    {
      'memberName': '孙丽',
      'amount': 5000,
      'bonus': 1500,
      'payMethod': '银行卡',
      'operator': '张美容',
      'time': '2024-06-01 11:00',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadRecords() async {
    setState(() => _isLoading = true);
    try {
      final data = await _rechargeRepo.getRechargeRecords();
      if (mounted) setState(() => _records = data);
    } catch (e) {
      debugPrint('加载充值记录失败，使用 Mock 数据: $e');
      if (mounted) setState(() => _records = _mockRecords);
    }
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      await _loadRecords();
    }
  }

  List<dynamic> get _filteredRecords {
    var records = _records.isNotEmpty ? _records : _mockRecords;
    final query = _searchController.text.trim().toLowerCase();
    if (query.isNotEmpty) {
      records = records.where((r) {
        final item = r as Map<String, dynamic>;
        final name = (item['memberName'] ?? '').toString().toLowerCase();
        return name.contains(query);
      }).toList();
    }
    return records;
  }

  @override
  Widget build(BuildContext context) {
    final spacing = ResponsiveHelper.spacing(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('充值记录'),
        backgroundColor: const Color(0xFF0052D9),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 搜索和筛选栏
          Container(
            padding: EdgeInsets.all(spacing),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 36.h,
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F8FA),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.search,
                            size: 16.sp, color: const Color(0xFFC9CDD4)),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            style: TextStyle(fontSize: 13.sp),
                            decoration: const InputDecoration(
                              hintText: '搜索会员名',
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                GestureDetector(
                  onTap: () => _selectDateRange(context),
                  child: Container(
                    height: 36.h,
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F8FA),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.date_range,
                            size: 16.sp, color: const Color(0xFF0052D9)),
                        SizedBox(width: 4.w),
                        Text(
                          '${_startDate.month}/${_startDate.day}-${_endDate.month}/${_endDate.day}',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: const Color(0xFF0052D9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 记录列表
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredRecords.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.inbox,
                                size: 48.sp, color: const Color(0xFFC9CDD4)),
                            SizedBox(height: 12.h),
                            Text('暂无充值记录',
                                style: TextStyle(
                                    fontSize: 14.sp,
                                    color: const Color(0xFF86909C))),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.all(spacing),
                        itemCount: _filteredRecords.length,
                        itemBuilder: (context, index) {
                          final item =
                              _filteredRecords[index] as Map<String, dynamic>;
                          return _buildRecordCard(item, spacing);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordCard(Map<String, dynamic> item, double spacing) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
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
          // 顶部：会员名 + 金额
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 36.r,
                    height: 36.r,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0052D9).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(18.r),
                    ),
                    child: Center(
                      child: Text(
                        (item['memberName'] as String?)?.substring(0, 1) ?? '',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0052D9),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Text(
                    item['memberName'] ?? '',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1D2129),
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '¥${item['amount'] ?? 0}',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1D2129),
                    ),
                  ),
                  if ((item['bonus'] ?? 0) > 0)
                    Text(
                      '赠送 ¥${item['bonus']}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: const Color(0xFF00A870),
                      ),
                    ),
                ],
              ),
            ],
          ),
          SizedBox(height: 10.h),
          // 底部：支付方式 + 操作人 + 时间
          Row(
            children: [
              Icon(Icons.payment,
                  size: 12.sp, color: const Color(0xFFC9CDD4)),
              SizedBox(width: 4.w),
              Text(item['payMethod'] ?? '',
                  style: TextStyle(
                      fontSize: 12.sp, color: const Color(0xFF86909C))),
              SizedBox(width: 16.w),
              Icon(Icons.person_outline,
                  size: 12.sp, color: const Color(0xFFC9CDD4)),
              SizedBox(width: 4.w),
              Text(item['operator'] ?? '',
                  style: TextStyle(
                      fontSize: 12.sp, color: const Color(0xFF86909C))),
              const Spacer(),
              Text(item['time'] ?? '',
                  style: TextStyle(
                      fontSize: 12.sp, color: const Color(0xFFC9CDD4))),
            ],
          ),
        ],
      ),
    );
  }
}
