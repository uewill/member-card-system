import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:member_card_app/shared/services/api/bonus_rule_repository.dart';

/// 充值赠金管理页面 - 真实 API 数据
class RechargeBonusPage extends StatefulWidget {
  const RechargeBonusPage({super.key});

  @override
  State<RechargeBonusPage> createState() => _RechargeBonusPageState();
}

class _RechargeBonusPageState extends State<RechargeBonusPage> {
  final BonusRuleRepository _bonusRuleRepo = BonusRuleRepository();

  List<dynamic> _bonusRules = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadBonusRules();
  }

  Future<void> _loadBonusRules() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final data = await _bonusRuleRepo.getBonusRules();
      if (mounted) setState(() => _bonusRules = data);
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
                        onPressed: _loadBonusRules,
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
              : _bonusRules.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inbox, size: 48.sp, color: const Color(0xFFC9CDD4)),
                          SizedBox(height: 12.h),
                          Text('暂无赠金规则', style: TextStyle(fontSize: 14.sp, color: const Color(0xFF86909C))),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.all(16.w),
                      itemCount: _bonusRules.length,
                      itemBuilder: (context, index) {
                        final rule = _bonusRules[index] as Map<String, dynamic>;
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
                                  color: (rule['enabled'] as bool? ?? true) ? const Color(0xFF00A870).withOpacity(0.1) : const Color(0xFFE34D59).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4.r),
                                ),
                                child: Text(
                                  (rule['enabled'] as bool? ?? true) ? '启用' : '停用',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: (rule['enabled'] as bool? ?? true) ? const Color(0xFF00A870) : const Color(0xFFE34D59),
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
