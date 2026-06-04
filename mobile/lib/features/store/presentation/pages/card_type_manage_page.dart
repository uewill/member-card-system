import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:member_card_app/shared/services/api/card_type_repository.dart';

/// 卡类型管理页面 - 真实 API 数据
class CardTypeManagePage extends StatefulWidget {
  const CardTypeManagePage({super.key});

  @override
  State<CardTypeManagePage> createState() => _CardTypeManagePageState();
}

class _CardTypeManagePageState extends State<CardTypeManagePage> {
  final CardTypeRepository _cardTypeRepo = CardTypeRepository();

  List<dynamic> _cardTypes = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCardTypes();
  }

  Future<void> _loadCardTypes() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final data = await _cardTypeRepo.getCardTypes();
      if (mounted) setState(() => _cardTypes = data);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    }
    if (mounted) setState(() => _isLoading = false);
  }

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
            onPressed: () async {
              await context.push('/card-type-edit');
              _loadCardTypes();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 48.sp, color: const Color(0xFFE34D59)),
                      SizedBox(height: 12.h),
                      Text('加载失败', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, color: const Color(0xFF1D2129))),
                      SizedBox(height: 4.h),
                      Text(_error!, style: TextStyle(fontSize: 13.sp, color: const Color(0xFF86909C)),
                          textAlign: TextAlign.center).paddingSymmetric(horizontal: 32.w),
                      SizedBox(height: 16.h),
                      ElevatedButton(
                        onPressed: _loadCardTypes,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0052D9),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                        ),
                        child: const Text('重试'),
                      ),
                    ],
                  ),
                )
              : _cardTypes.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inbox, size: 48.sp, color: const Color(0xFFC9CDD4)),
                          SizedBox(height: 12.h),
                          Text('暂无卡类型', style: TextStyle(fontSize: 14.sp, color: const Color(0xFF86909C))),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.all(16.w),
                      itemCount: _cardTypes.length,
                      itemBuilder: (context, index) {
                        final card = _cardTypes[index] as Map<String, dynamic>;
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
                                          card['name'] as String? ?? '',
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
                                            card['type'] as String? ?? '',
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
                                onPressed: () async {
                                  await context.push('/card-type-edit');
                                  _loadCardTypes();
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await context.push('/card-type-edit');
          _loadCardTypes();
        },
        backgroundColor: const Color(0xFF0052D9),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
