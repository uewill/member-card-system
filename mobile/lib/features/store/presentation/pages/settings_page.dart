import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:member_card_app/core/utils/responsive_helper.dart';

/// 设置页 - 商务专业风格
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // Mock 门店信息
  final Map<String, String> _storeInfo = {
    'name': '美丽人生旗舰店',
    'address': '市中心商业广场3楼',
    'phone': '400-888-6666',
    'hours': '09:00 - 21:00',
  };

  // Mock 员工列表
  final List<Map<String, dynamic>> _employees = [
    {'name': '张美容', 'role': '店长', 'phone': '138****1234', 'color': const Color(0xFF0052D9)},
    {'name': '王技师', 'role': '技师', 'phone': '139****5678', 'color': const Color(0xFF00A870)},
    {'name': '李美甲', 'role': '美甲师', 'phone': '137****9012', 'color': const Color(0xFFED7B2F)},
    {'name': '赵前台', 'role': '前台', 'phone': '136****3456', 'color': const Color(0xFF7B61FF)},
  ];

  // Mock 系统设置项
  final List<Map<String, dynamic>> _systemSettings = [
    {'icon': Icons.notifications_outlined, 'label': '通知设置', 'desc': '消息推送与提醒', 'color': const Color(0xFF0052D9)},
    {'icon': Icons.print_outlined, 'label': '打印设置', 'desc': '小票打印机配置', 'color': const Color(0xFF00A870)},
    {'icon': Icons.cloud_upload_outlined, 'label': '数据备份', 'desc': '自动备份与恢复', 'color': const Color(0xFFED7B2F)},
    {'icon': Icons.info_outline, 'label': '关于系统', 'desc': '版本 v1.0.0', 'color': const Color(0xFF86909C)},
  ];

  @override
  Widget build(BuildContext context) {
    final spacing = ResponsiveHelper.spacing(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('系统设置'),
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
            // 门店信息卡片
            _buildStoreInfoCard(spacing),

            SizedBox(height: spacing),

            // 员工管理
            _buildEmployeeSection(spacing),

            SizedBox(height: spacing),

            // 系统设置
            _buildSystemSettings(spacing),

            SizedBox(height: spacing),

            // 退出登录按钮
            _buildLogoutButton(),

            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }

  /// 门店信息卡片
  Widget _buildStoreInfoCard(double spacing) {
    return Container(
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '门店信息',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1D2129),
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: Row(
                  children: [
                    Text(
                      '编辑',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: const Color(0xFF0052D9),
                      ),
                    ),
                    Icon(Icons.chevron_right, size: 16.sp, color: const Color(0xFF0052D9)),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          // 门店名称
          Row(
            children: [
              Container(
                width: 48.r,
                height: 48.r,
                decoration: BoxDecoration(
                  color: const Color(0xFF0052D9).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: const Icon(Icons.store, color: Color(0xFF0052D9)),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _storeInfo['name']!,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1D2129),
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00A870).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        '营业中',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: const Color(0xFF00A870),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Divider(height: 1.h, color: const Color(0xFFF2F3F5)),
          SizedBox(height: 16.h),
          // 详细信息
          _buildInfoRow(Icons.location_on_outlined, '地址', _storeInfo['address']!),
          SizedBox(height: 12.h),
          _buildInfoRow(Icons.phone_outlined, '电话', _storeInfo['phone']!),
          SizedBox(height: 12.h),
          _buildInfoRow(Icons.access_time_outlined, '营业时间', _storeInfo['hours']!),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18.sp, color: const Color(0xFF86909C)),
        SizedBox(width: 8.w),
        Text(
          label,
          style: TextStyle(
            fontSize: 13.sp,
            color: const Color(0xFF86909C),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              color: const Color(0xFF1D2129),
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  /// 员工管理
  Widget _buildEmployeeSection(double spacing) {
    return Container(
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '员工管理',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1D2129),
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: Row(
                  children: [
                    Icon(Icons.add_circle_outline, size: 16.sp, color: const Color(0xFF0052D9)),
                    SizedBox(width: 4.w),
                    Text(
                      '添加员工',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: const Color(0xFF0052D9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          // 员工列表
          ...List.generate(_employees.length, (index) {
            final emp = _employees[index];
            return Column(
              children: [
                _buildEmployeeItem(emp),
                if (index < _employees.length - 1)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    child: Divider(height: 1.h, color: const Color(0xFFF2F3F5)),
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildEmployeeItem(Map<String, dynamic> emp) {
    return Row(
      children: [
        // 头像
        Container(
          width: 40.r,
          height: 40.r,
          decoration: BoxDecoration(
            color: (emp['color'] as Color).withOpacity(0.1),
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Center(
            child: Text(
              (emp['name'] as String).substring(0, 1),
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: emp['color'] as Color,
              ),
            ),
          ),
        ),
        SizedBox(width: 12.w),
        // 姓名 & 角色
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                emp['name'] as String,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF1D2129),
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                emp['role'] as String,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: const Color(0xFF86909C),
                ),
              ),
            ],
          ),
        ),
        // 手机号
        Text(
          emp['phone'] as String,
          style: TextStyle(
            fontSize: 13.sp,
            color: const Color(0xFF4E5969),
          ),
        ),
        SizedBox(width: 8.w),
        Icon(Icons.chevron_right, color: const Color(0xFFC9CDD4), size: 20.sp),
      ],
    );
  }

  /// 系统设置
  Widget _buildSystemSettings(double spacing) {
    return Container(
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
          Text(
            '系统设置',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1D2129),
            ),
          ),
          SizedBox(height: 8.h),
          ...List.generate(_systemSettings.length, (index) {
            final setting = _systemSettings[index];
            return Column(
              children: [
                _buildSettingItem(setting),
                if (index < _systemSettings.length - 1)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    child: Divider(height: 1.h, color: const Color(0xFFF2F3F5)),
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSettingItem(Map<String, dynamic> setting) {
    return GestureDetector(
      onTap: () {},
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          Container(
            width: 36.r,
            height: 36.r,
            decoration: BoxDecoration(
              color: (setting['color'] as Color).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              setting['icon'] as IconData,
              color: setting['color'] as Color,
              size: 20.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  setting['label'] as String,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF1D2129),
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  setting['desc'] as String,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: const Color(0xFF86909C),
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: const Color(0xFFC9CDD4), size: 20.sp),
        ],
      ),
    );
  }

  /// 退出登录按钮
  Widget _buildLogoutButton() {
    return GestureDetector(
      onTap: () {
        _showLogoutDialog();
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 16.h),
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
        child: Center(
          child: Text(
            '退出登录',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFFE34D59),
            ),
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('提示'),
          content: const Text('确定要退出登录吗？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                context.go('/login');
              },
              child: const Text(
                '确定',
                style: TextStyle(color: Color(0xFFE34D59)),
              ),
            ),
          ],
        );
      },
    );
  }
}
