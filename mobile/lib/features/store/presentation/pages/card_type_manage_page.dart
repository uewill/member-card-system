import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

/// 卡类型管理页面 - Mock 数据模式
class CardTypeManagePage extends StatefulWidget {
  const CardTypeManagePage({super.key});

  @override
  State<CardTypeManagePage> createState() => _CardTypeManagePageState();
}

class _CardTypeManagePageState extends State<CardTypeManagePage> {
  final List<Map<String, dynamic>> _mockCardTypes = [
    {'name': '洗剪吹10次卡', 'type': '次卡', 'times': 10, 'price': 980},
    {'name': '面部护理年卡', 'type': '次卡', 'times': 24, 'price': 3680},
    {'name': '储值1000送100', 'type': '储值卡', 'balance': 1000, 'price': 1000},
    {'name': '尊享混合卡', 'type': '混合卡', 'times': 5, 'balance': 500, 'price': 1280},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('卡类型管理'),
        backgroundColor: const Color(0xFF0052D9),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/card-type-edit'),
          ),
        ],
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16.w),
        itemCount: _mockCardTypes.length,
        itemBuilder: (context, index) {
          final card = _mockCardTypes[index];
          return Container(
            margin: EdgeInsets.only(bottom: 12.h),
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            card['name'] as String,
                            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, color: const Color(0xFF1D2129)),
                          ),
                          SizedBox(width: 8.w),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0052D9).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: Text(
                              card['type'] as String,
                              style: TextStyle(fontSize: 11.sp, color: const Color(0xFF0052D9)),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        card['type'] == '储值卡'
                            ? '储值 ¥${card['balance']}'
                            : card['type'] == '次卡'
                                ? '${card['times']}次'
                                : '${card['times']}次 + 储值¥${card['balance']}',
                        style: TextStyle(fontSize: 13.sp, color: const Color(0xFF86909C)),
                      ),
                    ],
                  ),
                ),
                Text(
                  '¥${card['price']}',
                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: const Color(0xFF0052D9)),
                ),
                SizedBox(width: 8.w),
                IconButton(
                  icon: const Icon(Icons.chevron_right, color: Color(0xFFC9CDD4)),
                  onPressed: () => context.push('/card-type-edit'),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/card-type-edit'),
        backgroundColor: const Color(0xFF0052D9),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
