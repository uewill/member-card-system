import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

/// 充值赠金管理页面 - Mock 数据模式
class RechargeBonusPage extends StatefulWidget {
  const RechargeBonusPage({super.key});

  @override
  State<RechargeBonusPage> createState() => _RechargeBonusPageState();
}

class _RechargeBonusPageState extends State<RechargeBonusPage> {
  final List<Map<String, dynamic>> _mockBonusRules = [
    {'threshold': 500, 'bonus': 50, 'type': '固定金额', 'enabled': true},
    {'threshold': 1000, 'bonus': 150, 'type': '固定金额', 'enabled': true},
    {'threshold': 2000, 'bonus': '10%', 'type': '比例', 'enabled': true},
    {'threshold': 5000, 'bonus': '15%', 'type': '比例', 'enabled': false},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('充值赠金'),
        backgroundColor: const Color(0xFF0052D9),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/bonus-edit'),
          ),
        ],
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16.w),
        itemCount: _mockBonusRules.length,
        itemBuilder: (context, index) {
          final rule = _mockBonusRules[index];
          return Container(
            margin: EdgeInsets.only(bottom: 12.h),
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              children: [
                Container(
                  width: 48.r,
                  height: 48.r,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE37318).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(Icons.card_giftcard, color: const Color(0xFFE37318), size: 24.sp),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '充${rule['threshold']}送${rule['bonus']}',
                        style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, color: const Color(0xFF1D2129)),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        '${rule['type']}赠送',
                        style: TextStyle(fontSize: 13.sp, color: const Color(0xFF86909C)),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: (rule['enabled'] as bool) ? const Color(0xFF00A870).withOpacity(0.1) : const Color(0xFFE34D59).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Text(
                    (rule['enabled'] as bool) ? '启用' : '停用',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: (rule['enabled'] as bool) ? const Color(0xFF00A870) : const Color(0xFFE34D59),
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                IconButton(
                  icon: const Icon(Icons.chevron_right, color: Color(0xFFC9CDD4)),
                  onPressed: () => context.push('/bonus-edit'),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/bonus-edit'),
        backgroundColor: const Color(0xFF0052D9),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
