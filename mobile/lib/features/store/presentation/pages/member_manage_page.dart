import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:member_card_app/core/utils/responsive_helper.dart';
import 'package:member_card_app/shared/providers/member_provider.dart';

class MemberManagePage extends StatefulWidget {
  const MemberManagePage({super.key});

  @override
  State<MemberManagePage> createState() => _MemberManagePageState();
}

class _MemberManagePageState extends State<MemberManagePage> {
  final TextEditingController _searchController = TextEditingController();

  // Mock 数据（作为 API 失败时的 fallback）
  final List<Map<String, dynamic>> _mockMembers = [
    {'name': '李美丽', 'phone': '138****8888', 'level': 'VIP', 'balance': 1280, 'points': 2580},
    {'name': '王芳', 'phone': '139****6666', 'level': '普通', 'balance': 0, 'points': 580},
    {'name': '张婷', 'phone': '137****9999', 'level': 'VIP', 'balance': 3500, 'points': 4200},
    {'name': '刘洋', 'phone': '136****1111', 'level': '普通', 'balance': 200, 'points': 320},
    {'name': '陈静', 'phone': '135****2222', 'level': 'VIP', 'balance': 2800, 'points': 3600},
  ];

  String _searchQuery = '';
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  /// 加载会员列表（优先使用 API，失败时 fallback 到 Mock）
  Future<void> _loadMembers({String? query}) async {
    try {
      final memberProvider = context.read<MemberProvider>();
      await memberProvider.loadMembers(query: query);
    } catch (e) {
      debugPrint('加载会员列表失败，使用 Mock 数据: $e');
    }
  }

  /// 搜索会员（带防抖）
  void _onSearchChanged(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      setState(() => _searchQuery = value);
      _loadMembers(query: value.isEmpty ? null : value);
    });
  }

  /// 获取当前显示的会员数据（API 数据优先，Mock 作为 fallback）
  List<dynamic> get _displayMembers {
    final memberProvider = context.watch<MemberProvider>();
    if (memberProvider.members.isNotEmpty) {
      return memberProvider.members;
    }
    // 如果有搜索关键词，过滤 Mock 数据
    if (_searchQuery.isNotEmpty) {
      return _mockMembers.where((m) {
        final name = (m['name'] ?? '').toString().toLowerCase();
        final phone = (m['phone'] ?? '').toString().toLowerCase();
        final query = _searchQuery.toLowerCase();
        return name.contains(query) || phone.contains(query);
      }).toList();
    }
    return _mockMembers;
  }

  @override
  Widget build(BuildContext context) {
    final spacing = ResponsiveHelper.spacing(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('会员管理'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // 搜索栏
          Padding(
            padding: EdgeInsets.all(spacing),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: '搜索会员姓名/手机号',
                filled: true,
                fillColor: const Color(0xFFF5F7FA),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // 统计卡片
          Padding(
            padding: EdgeInsets.symmetric(horizontal: spacing),
            child: Row(
              children: [
                Expanded(
                  child: _buildStatCard('总会员', '1,258', const Color(0xFF0052D9)),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _buildStatCard('今日新增', '3', const Color(0xFF00A870)),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _buildStatCard('VIP会员', '286', const Color(0xFFED7B2F)),
                ),
              ],
            ),
          ),
          SizedBox(height: spacing),

          // 会员列表
          Expanded(
            child: Consumer<MemberProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading && provider.members.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0052D9)),
                    ),
                  );
                }
                return ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: spacing),
                  itemCount: _displayMembers.length,
                  itemBuilder: (context, index) {
                    final member = _displayMembers[index];
                    return _buildMemberCard(member, spacing);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              color: const Color(0xFF4E5969),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberCard(dynamic member, double spacing) {
    final data = member is Map<String, dynamic> ? member : (member as Map).cast<String, dynamic>();
    final name = (data['name'] ?? '未知').toString();
    final phone = (data['phone'] ?? '').toString();
    final level = (data['level'] ?? '普通').toString();
    final balance = data['balance'] ?? 0;
    final points = data['points'] ?? 0;
    final isVip = level == 'VIP';

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48.r,
            height: 48.r,
            decoration: BoxDecoration(
              color: isVip ? const Color(0xFF0052D9).withOpacity(0.1) : const Color(0xFFF5F7FA),
              borderRadius: BorderRadius.circular(24.r),
            ),
            child: Center(
              child: Text(
                name.substring(0, 1),
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: isVip ? const Color(0xFF0052D9) : const Color(0xFF86909C),
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF1D2129),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    if (isVip)
                      Chip(
                        label: Text(
                          'VIP',
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: const Color(0xFF0052D9),
                          ),
                        ),
                        backgroundColor: const Color(0xFF0052D9).withOpacity(0.1),
                        padding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                        side: BorderSide.none,
                      ),
                  ],
                ),
                SizedBox(height: 4.h),
                Text(
                  phone,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: const Color(0xFF86909C),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '余额 ¥$balance',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF1D2129),
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                '积分 $points',
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
}
