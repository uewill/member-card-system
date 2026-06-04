import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

/// 商品管理页面 - Mock 数据模式
class ProductManagePage extends StatefulWidget {
  const ProductManagePage({super.key});

  @override
  State<ProductManagePage> createState() => _ProductManagePageState();
}

class _ProductManagePageState extends State<ProductManagePage> {
  final List<Map<String, dynamic>> _mockProducts = [
    {'name': '面部深层清洁', 'category': '服务项目', 'price': 198, 'status': true},
    {'name': '精油全身按摩', 'category': '服务项目', 'price': 298, 'status': true},
    {'name': '剪发造型', 'category': '服务项目', 'price': 68, 'status': true},
    {'name': '美甲护理套餐', 'category': '套餐', 'price': 388, 'status': true},
    {'name': '洗发护发素', 'category': '商品', 'price': 128, 'status': false},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('商品管理'),
        backgroundColor: const Color(0xFF0052D9),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/product-edit'),
          ),
        ],
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16.w),
        itemCount: _mockProducts.length,
        itemBuilder: (context, index) {
          final product = _mockProducts[index];
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
                      Text(
                        product['name'] as String,
                        style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, color: const Color(0xFF1D2129)),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        '${product['category']} | ¥${product['price']}',
                        style: TextStyle(fontSize: 13.sp, color: const Color(0xFF86909C)),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: (product['status'] as bool) ? const Color(0xFF00A870).withOpacity(0.1) : const Color(0xFFE34D59).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Text(
                    (product['status'] as bool) ? '上架' : '下架',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: (product['status'] as bool) ? const Color(0xFF00A870) : const Color(0xFFE34D59),
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                IconButton(
                  icon: const Icon(Icons.chevron_right, color: Color(0xFFC9CDD4)),
                  onPressed: () => context.push('/product-edit'),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/product-edit'),
        backgroundColor: const Color(0xFF0052D9),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
