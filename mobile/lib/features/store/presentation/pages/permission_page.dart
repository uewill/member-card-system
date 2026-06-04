import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:member_card_app/core/utils/responsive_helper.dart';

/// 权限管理页 - RBAC 角色与权限
class PermissionPage extends StatefulWidget {
  const PermissionPage({super.key});

  @override
  State<PermissionPage> createState() => _PermissionPageState();
}

class _PermissionPageState extends State<PermissionPage> {
  // Mock 角色数据
  final List<Map<String, dynamic>> _roles = [
    {
      'name': '平台超管',
      'icon': Icons.admin_panel_settings,
      'color': const Color(0xFFE34D59),
      'desc': '拥有系统全部权限，包括平台配置、商户管理、数据统计等',
      'permissions': ['全部权限'],
    },
    {
      'name': '商户管理员',
      'icon': Icons.business,
      'color': const Color(0xFF0052D9),
      'desc': '管理门店全部业务，包括员工管理、财务查看、营销配置等',
      'permissions': ['会员管理', '次卡管理', '充值核销', '业绩查看', '营销工具', '系统设置', '员工管理'],
    },
    {
      'name': '门店经理',
      'icon': Icons.store,
      'color': const Color(0xFF00A870),
      'desc': '管理门店日常运营，包括排班、业绩统计、会员服务等',
      'permissions': ['会员管理', '次卡管理', '充值核销', '业绩查看', '报表中心'],
    },
    {
      'name': '收银员',
      'icon': Icons.point_of_sale,
      'color': const Color(0xFFED7B2F),
      'desc': '负责日常收银、充值开卡、消费核销等操作',
      'permissions': ['会员管理', '充值开卡', '消费核销'],
    },
    {
      'name': '服务人员',
      'icon': Icons.spa,
      'color': const Color(0xFF7B61FF),
      'desc': '负责提供服务、核销次卡，可查看自己的服务记录',
      'permissions': ['消费核销', '个人业绩'],
    },
    {
      'name': '会员',
      'icon': Icons.person,
      'color': const Color(0xFF86909C),
      'desc': '普通会员，可查看自己的会员信息、消费记录、余额积分',
      'permissions': ['个人信息', '消费记录', '余额积分'],
    },
  ];

  // Mock 员工角色分配数据
  final List<Map<String, dynamic>> _staffAssignments = [
    {
      'name': '张美容',
      'avatar': 'Z',
      'avatarColor': const Color(0xFF0052D9),
      'currentRole': '门店经理',
      'phone': '138****8888',
    },
    {
      'name': '李小花',
      'avatar': 'L',
      'avatarColor': const Color(0xFF00A870),
      'currentRole': '收银员',
      'phone': '139****6666',
    },
    {
      'name': '王技师',
      'avatar': 'W',
      'avatarColor': const Color(0xFF7B61FF),
      'currentRole': '服务人员',
      'phone': '137****9999',
    },
    {
      'name': '赵前台',
      'avatar': 'Z',
      'avatarColor': const Color(0xFFED7B2F),
      'currentRole': '收银员',
      'phone': '136****1111',
    },
    {
      'name': '陈经理',
      'avatar': 'C',
      'avatarColor': const Color(0xFFE34D59),
      'currentRole': '商户管理员',
      'phone': '135****2222',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final spacing = ResponsiveHelper.spacing(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('权限管理'),
        backgroundColor: const Color(0xFF0052D9),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(spacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 角色列表
            Text('角色列表',
                style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1D2129))),
            SizedBox(height: spacing * 0.75),
            ...List.generate(_roles.length, (index) {
              return _buildRoleCard(_roles[index], spacing);
            }),

            SizedBox(height: spacing * 1.5),

            // 员工角色分配
            Text('员工角色分配',
                style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1D2129))),
            SizedBox(height: spacing * 0.75),
            ...List.generate(_staffAssignments.length, (index) {
              return _buildStaffAssignmentCard(
                  _staffAssignments[index], spacing);
            }),

            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleCard(Map<String, dynamic> role, double spacing) {
    final permissions = role['permissions'] as List<dynamic>;

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 角色头部
          Row(
            children: [
              Container(
                width: 44.r,
                height: 44.r,
                decoration: BoxDecoration(
                  color: (role['color'] as Color).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  role['icon'] as IconData,
                  color: role['color'] as Color,
                  size: 22.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(role['name'],
                        style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1D2129))),
                    SizedBox(height: 2.h),
                    Text(role['desc'],
                        style: TextStyle(
                            fontSize: 12.sp,
                            color: const Color(0xFF86909C))),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          // 权限标签
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: List.generate(permissions.length, (index) {
              return Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: (role['color'] as Color).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: (role['color'] as Color).withOpacity(0.2),
                  ),
                ),
                child: Text(
                  permissions[index] as String,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: role['color'] as Color,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildStaffAssignmentCard(
      Map<String, dynamic> staff, double spacing) {
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
      child: Row(
        children: [
          // 头像
          Container(
            width: 44.r,
            height: 44.r,
            decoration: BoxDecoration(
              color: staff['avatarColor'] as Color,
              borderRadius: BorderRadius.circular(22.r),
            ),
            child: Center(
              child: Text(
                staff['avatar'] as String,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          // 员工信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(staff['name'],
                    style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1D2129))),
                SizedBox(height: 2.h),
                Text(staff['phone'],
                    style: TextStyle(
                        fontSize: 12.sp, color: const Color(0xFF86909C))),
              ],
            ),
          ),
          // 当前角色
          Container(
            padding:
                EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: const Color(0xFF0052D9).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Text(
              staff['currentRole'],
              style: TextStyle(
                fontSize: 12.sp,
                color: const Color(0xFF0052D9),
              ),
            ),
          ),
          SizedBox(width: 8.w),
          // 操作按钮
          GestureDetector(
            onTap: () => _showRoleChangeDialog(staff),
            child: Container(
              padding:
                  EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: const Color(0xFFF2F3F5),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                '变更',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: const Color(0xFF4E5969),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showRoleChangeDialog(Map<String, dynamic> staff) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('变更角色 - ${staff['name']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _roles
              .where((r) => r['name'] != '平台超管' && r['name'] != '会员')
              .map((role) {
            return RadioListTile<String>(
              title: Text(role['name']),
              value: role['name'] as String,
              groupValue: staff['currentRole'] as String,
              onChanged: (val) {
                Navigator.pop(context);
                setState(() {
                  staff['currentRole'] = val;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('已将 ${staff['name']} 角色变更为 $val')),
                );
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
        ],
      ),
    );
  }
}
