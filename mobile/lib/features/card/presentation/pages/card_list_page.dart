import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:member_card_app/core/utils/responsive_helper.dart';
import 'package:member_card_app/features/member/data/member_repository.dart';

/// 会员卡包页面 - 展示会员名下所有有效卡实例
class CardListPage extends StatefulWidget {
  const CardListPage({super.key});

  @override
  State<CardListPage> createState() => _CardListPageState();
}

class _CardListPageState extends State<CardListPage> {
  List<Map<String, dynamic>> _cards = [];
  bool _isLoading = true;
  String? _error;
  final MemberRepository _repository = MemberRepository();

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  Future<void> _loadCards() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final data = await _repository.getCardList();
      setState(() {
        _cards = List<Map<String, dynamic>>.from(data ?? []);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = '加载失败: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final spacing = ResponsiveHelper.spacing(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('我的卡包'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadCards,
        child: _buildBody(spacing),
      ),
    );
  }

  Widget _buildBody(double spacing) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_error!, style: TextStyle(color: Colors.red, fontSize: 14.sp)),
            SizedBox(height: spacing),
            ElevatedButton(
              onPressed: _loadCards,
              child: const Text('重试'),
            ),
          ],
        ),
      );
    }
    if (_cards.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.credit_card_outlined, size: 64, color: Colors.grey.shade300),
            SizedBox(height: spacing),
            Text('暂无会员卡', style: TextStyle(fontSize: 16.sp, color: Colors.grey)),
          ],
        ),
      );
    }
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
    final type = card['type'] ?? '次数卡';
    final isCountCard = type == '次数卡' || type == 'COUNT';
    final remainCount = card['remain_count'] ?? card['remaining'] ?? 0;
    final balance = card['balance'] ?? 0.0;
    final validEnd = card['valid_end'] ?? card['validTo'] ?? '';
    final status = card['status'] ?? '正常';
    final isActive = status == '正常' || status == 'ACTIVE';

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
                Expanded(
                  child: Text(
                    card['name'] ?? '未知卡',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: isActive ? Colors.green.shade100 : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Text(
                    isActive ? '正常' : status,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: isActive ? Colors.green : Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: spacing / 2),
            Text(
              isCountCard
                  ? '剩余次数: $remainCount 次'
                  : '余额: ¥${balance.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 14.sp),
            ),
            SizedBox(height: spacing / 2),
            Text(
              '有效期至: ${validEnd.toString().split('T').first}',
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
