import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:member_card_app/core/utils/responsive_helper.dart';

/// 会员卡包页面 - 展示会员名下所有有效卡实例
class CardListPage extends StatefulWidget {
  const CardListPage({super.key});

  @override
  State<CardListPage> createState() => _CardListPageState();
}

class _CardListPageState extends State<CardListPage> {
  List<Map<String, dynamic>> _cards = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  Future<void> _loadCards() async {
    // TODO: 调用实际 API
    await Future.delayed(const Duration(seconds: 1));
    
    setState(() {
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
      ];
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final spacing = ResponsiveHelper.spacing(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的卡包'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: EdgeInsets.all(spacing),
              itemCount: _cards.length,
              itemBuilder: (context, index) {
                final card = _cards[index];
                return _buildCardItem(card, spacing);
              },
            ),
    );
  }

  Widget _buildCardItem(Map<String, dynamic> card, double spacing) {
    final isCountCard = card['type'] == 'COUNT';
    
    return Card(
      margin: EdgeInsets.only(bottom: spacing),
      child: Padding(
        padding: EdgeInsets.all(spacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  card['name'],
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 8.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: card['status'] == 'ACTIVE' 
                        ? Colors.green.shade100 
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Text(
                    card['status'] == 'ACTIVE' ? '正常' : '已过期',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: card['status'] == 'ACTIVE' 
                          ? Colors.green 
                          : Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: spacing / 2),
            Text(
              isCountCard
                  ? '剩余次数: ${card['remaining']} 次'
                  : '余额: ¥${card['balance']}',
              style: TextStyle(fontSize: 14.sp),
            ),
            SizedBox(height: spacing / 2),
            Text(
              '有效期至: ${card['validTo']}',
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}