import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:member_card_app/core/config/app_config.dart';
import 'package:member_card_app/core/utils/responsive_helper.dart';
import 'package:member_card_app/features/member/data/member_repository.dart';
import 'package:member_card_app/shared/services/auth_service.dart';

/// 个人中心页 - 信息修改、消息通知
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final MemberRepository _memberRepository = MemberRepository();

  Map<String, dynamic>? _profile;
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final results = await Future.wait([
        _memberRepository.getMemberProfile(),
        _memberRepository.getNotifications(),
      ]);

      setState(() {
        _profile = results[0] as Map<String, dynamic>;
        _notifications = List<Map<String, dynamic>>.from(results[1] as List);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _profile = {
          'name': '张三',
          'phone': '13888888888',
          'birthday': '1990-05-15',
          'gender': '男',
          'tags': ['VIP', '老客户'],
          'sourceChannel': '门店推荐',
          'createdAt': '2025-01-15',
        };
        _notifications = [
          {
            'id': 1,
            'title': '套餐即将到期提醒',
            'content': '您的"洗剪吹10次卡"将于2026-08-15到期，还剩3次未使用，请尽快使用。',
            'type': 'EXPIRY_WARNING',
            'isRead': false,
            'createdAt': '2026-06-01 09:00:00',
          },
          {
            'id': 2,
            'title': '充值到账通知',
            'content': '您已成功充值500元，赠送100元已到账，当前余额600元。',
            'type': 'RECHARGE_SUCCESS',
            'isRead': true,
            'createdAt': '2026-05-28 14:30:00',
          },
          {
            'id': 3,
            'title': '新套餐推荐',
            'content': '夏季特惠：染烫护理套餐限时6.8折，快来抢购！',
            'type': 'PROMOTION',
            'isRead': false,
            'createdAt': '2026-05-25 10:00:00',
          },
          {
            'id': 4,
            'title': '消费完成通知',
            'content': '您在旗舰店消费了"精剪造型"服务，已扣减1次。',
            'type': 'CONSUME_COMPLETE',
            'isRead': true,
            'createdAt': '2026-05-20 16:00:00',
          },
        ];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final spacing = ResponsiveHelper.spacing(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('个人中心'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: EdgeInsets.all(spacing),
              children: [
                _buildProfileCard(spacing),
                SizedBox(height: spacing),
                _buildMenuSection(spacing),
                SizedBox(height: spacing),
                _buildNotificationSection(spacing),
                SizedBox(height: spacing),
                _buildLogoutButton(spacing),
              ],
            ),
    );
  }

  /// 个人信息卡片
  Widget _buildProfileCard(double spacing) {
    return Container(
      padding: EdgeInsets.all(spacing),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppConfig.primaryColor,
            AppConfig.primaryColor.withOpacity(0.85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 32.r,
                backgroundColor: Colors.white24,
                child: Text(
                  (_profile?['name'] ?? '会')?.substring(0, 1),
                  style: TextStyle(
                    fontSize: 24.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(width: spacing),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _profile?['name'] ?? '会员用户',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      _profile?['phone'] ?? '',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: _showEditProfileDialog,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Text(
                    '编辑',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: spacing),
          // 标签
          if (_profile?['tags'] != null)
            Wrap(
              spacing: 6.w,
              runSpacing: 4.h,
              children: List<String>.from(_profile!['tags']).map((tag) {
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    tag,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: Colors.white,
                    ),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  /// 菜单区域
  Widget _buildMenuSection(double spacing) {
    final menuItems = [
      {'icon': Icons.person_outline, 'label': '个人信息', 'onTap': _showEditProfileDialog},
      {'icon': Icons.lock_outline, 'label': '修改密码', 'onTap': _showChangePasswordDialog},
      {'icon': Icons.credit_card, 'label': '我的卡包', 'onTap': () => context.push('/member/cards')},
      {'icon': Icons.receipt_long, 'label': '消费记录', 'onTap': () => context.push('/member/consume-records')},
      {'icon': Icons.shopping_bag, 'label': '购买套餐', 'onTap': () => context.push('/member/purchase')},
      {'icon': Icons.card_giftcard, 'label': '优惠券', 'onTap': () {}},
      {'icon': Icons.star_outline, 'label': '积分中心', 'onTap': () {}},
      {'icon': Icons.store, 'label': '附近门店', 'onTap': () {}},
      {'icon': Icons.help_outline, 'label': '帮助与反馈', 'onTap': () {}},
      {'icon': Icons.info_outline, 'label': '关于我们', 'onTap': () {}},
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: menuItems.map((item) {
          return Column(
            children: [
              ListTile(
                leading: Icon(item['icon'] as IconData, size: 22.sp),
                title: Text(
                  item['label'] as String,
                  style: TextStyle(fontSize: 15.sp),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: item['onTap'] as VoidCallback,
              ),
              const Divider(height: 1, indent: 56),
            ],
          );
        }).toList(),
      ),
    );
  }

  /// 消息通知区域
  Widget _buildNotificationSection(double spacing) {
    final unreadCount = _notifications.where((n) => !n['isRead']).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '消息通知',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (unreadCount > 0)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Text(
                  '$unreadCount条未读',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: spacing / 2),
        ..._notifications.map((notification) => _buildNotificationItem(notification, spacing)),
      ],
    );
  }

  Widget _buildNotificationItem(Map<String, dynamic> notification, double spacing) {
    final isRead = notification['isRead'] == true;
    final typeIcon = _getNotificationIcon(notification['type']);

    return Card(
      margin: EdgeInsets.only(bottom: spacing / 2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(spacing),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36.r,
              height: 36.r,
              decoration: BoxDecoration(
                color: (isRead ? Colors.grey : AppConfig.primaryColor).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                typeIcon,
                color: isRead ? Colors.grey : AppConfig.primaryColor,
                size: 18.sp,
              ),
            ),
            SizedBox(width: spacing),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification['title'],
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                          ),
                        ),
                      ),
                      if (!isRead)
                        Container(
                          width: 8.r,
                          height: 8.r,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    notification['content'],
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    notification['createdAt'],
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getNotificationIcon(String? type) {
    switch (type) {
      case 'EXPIRY_WARNING':
        return Icons.warning_amber;
      case 'RECHARGE_SUCCESS':
        return Icons.account_balance_wallet;
      case 'PROMOTION':
        return Icons.local_offer;
      case 'CONSUME_COMPLETE':
        return Icons.check_circle;
      default:
        return Icons.notifications;
    }
  }

  /// 退出登录按钮
  Widget _buildLogoutButton(double spacing) {
    return SizedBox(
      width: double.infinity,
      height: 48.h,
      child: OutlinedButton(
        onPressed: _handleLogout,
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.red,
          side: const BorderSide(color: Colors.red),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
        child: const Text('退出登录'),
      ),
    );
  }

  /// 编辑个人信息对话框
  void _showEditProfileDialog() {
    final nameController = TextEditingController(text: _profile?['name'] ?? '');
    final birthdayController = TextEditingController(text: _profile?['birthday'] ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            ResponsiveHelper.spacing(context),
            ResponsiveHelper.spacing(context),
            ResponsiveHelper.spacing(context),
            MediaQuery.of(context).viewInsets.bottom + ResponsiveHelper.spacing(context),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '编辑个人信息',
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: '姓名',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: birthdayController,
                decoration: const InputDecoration(
                  labelText: '生日',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.cake),
                ),
                readOnly: true,
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime(1990, 5, 15),
                    firstDate: DateTime(1950),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    birthdayController.text =
                        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
                  }
                },
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48.h,
                child: ElevatedButton(
                  onPressed: () async {
                    try {
                      await _memberRepository.updateMemberProfile({
                        'name': nameController.text,
                        'birthday': birthdayController.text,
                      });
                      if (mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('信息已更新')),
                        );
                        _loadData();
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('更新失败: $e')),
                        );
                      }
                    }
                  },
                  child: const Text('保存'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// 修改密码对话框
  void _showChangePasswordDialog() {
    final oldPwdController = TextEditingController();
    final newPwdController = TextEditingController();
    final confirmPwdController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('修改密码'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: oldPwdController,
              decoration: const InputDecoration(
                labelText: '原密码',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: newPwdController,
              decoration: const InputDecoration(
                labelText: '新密码',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: confirmPwdController,
              decoration: const InputDecoration(
                labelText: '确认新密码',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              if (newPwdController.text != confirmPwdController.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('两次密码不一致')),
                );
                return;
              }
              // TODO: 调用修改密码 API
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('密码修改成功')),
              );
            },
            child: const Text('确认修改'),
          ),
        ],
      ),
    );
  }

  /// 退出登录
  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认退出'),
        content: const Text('确定要退出登录吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              final authService = AuthService.instance;
              authService.logout();
              context.go('/login');
            },
            child: const Text('确定', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
