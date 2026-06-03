import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:member_card_app/core/config/app_config.dart';
import 'package:member_card_app/core/utils/responsive_helper.dart';
import 'package:member_card_app/features/member/data/member_repository.dart';

/// 在线购买套餐页 - 套餐列表、支付
class PurchasePage extends StatefulWidget {
  const PurchasePage({super.key});

  @override
  State<PurchasePage> createState() => _PurchasePageState();
}

class _PurchasePageState extends State<PurchasePage> {
  final MemberRepository _memberRepository = MemberRepository();

  List<Map<String, dynamic>> _packages = [];
  bool _isLoading = true;
  int? _selectedPackageIndex;
  bool _isPurchasing = false;

  @override
  void initState() {
    super.initState();
    _loadPackages();
  }

  Future<void> _loadPackages() async {
    try {
      final packages = await _memberRepository.getPackageList();
      setState(() {
        _packages = packages;
        _isLoading = false;
      });
    } catch (e) {
      // 使用模拟数据
      setState(() {
        _packages = _generateMockPackages();
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> _generateMockPackages() {
    return [
      {
        'id': 1,
        'name': '洗剪吹10次卡',
        'type': 'COUNT',
        'salePrice': 680.0,
        'originalPrice': 1000.0,
        'validityDays': 365,
        'config': [
          {'serviceName': '洗剪吹', 'count': 10},
        ],
        'description': '包含洗发、剪发、吹风造型全套服务，有效期一年',
        'tags': ['热销', '超值'],
      },
      {
        'id': 2,
        'name': '储值500送100',
        'type': 'VALUE',
        'salePrice': 500.0,
        'originalPrice': 500.0,
        'validityDays': 730,
        'config': [
          {'serviceName': '储值本金', 'amount': 500},
          {'serviceName': '赠送金额', 'amount': 100},
        ],
        'description': '充值500元到账600元，两年有效',
        'tags': ['推荐'],
      },
      {
        'id': 3,
        'name': '染烫护理套餐',
        'type': 'COUNT',
        'salePrice': 1280.0,
        'originalPrice': 1800.0,
        'validityDays': 180,
        'config': [
          {'serviceName': '染发', 'count': 3},
          {'serviceName': '烫发', 'count': 2},
          {'serviceName': '深层护理', 'count': 5},
        ],
        'description': '染发3次+烫发2次+护理5次，半年有效',
        'tags': ['新品'],
      },
      {
        'id': 4,
        'name': '尊享VIP年卡',
        'type': 'MIXED',
        'salePrice': 2980.0,
        'originalPrice': 4500.0,
        'validityDays': 365,
        'config': [
          {'serviceName': '精剪造型', 'count': 12},
          {'serviceName': '头皮护理', 'count': 6},
          {'serviceName': '储值本金', 'amount': 500},
        ],
        'description': '全年不限次精剪+6次护理+500元储值',
        'tags': ['尊享', '限量'],
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    final spacing = ResponsiveHelper.spacing(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('购买套餐'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: EdgeInsets.all(spacing),
              itemCount: _packages.length,
              itemBuilder: (context, index) {
                return _buildPackageCard(_packages[index], index, spacing);
              },
            ),
    );
  }

  /// 套餐卡片
  Widget _buildPackageCard(Map<String, dynamic> package, int index, double spacing) {
    final isSelected = _selectedPackageIndex == index;
    final tags = List<String>.from(package['tags'] ?? []);
    final config = List<Map<String, dynamic>>.from(package['config'] ?? []);
    final discount = package['originalPrice'] > 0
        ? (package['salePrice'] / package['originalPrice'] * 10).toStringAsFixed(1)
        : null;

    return Card(
      margin: EdgeInsets.only(bottom: spacing),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
        side: isSelected
            ? BorderSide(color: AppConfig.primaryColor, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedPackageIndex = isSelected ? null : index;
          });
        },
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(spacing),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 标题行
              Row(
                children: [
                  Expanded(
                    child: Text(
                      package['name'],
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (discount != null)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        '${discount}折',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),

              SizedBox(height: spacing / 2),

              // 标签
              if (tags.isNotEmpty)
                Wrap(
                  spacing: 6.w,
                  runSpacing: 4.h,
                  children: tags.map((tag) {
                    return Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: AppConfig.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        tag,
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: AppConfig.primaryColor,
                        ),
                      ),
                    );
                  }).toList(),
                ),

              SizedBox(height: spacing / 2),

              // 套餐内容
              Container(
                padding: EdgeInsets.all(spacing * 0.75),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '套餐内容',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    ...config.map((item) => Padding(
                      padding: EdgeInsets.only(bottom: 2.h),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, size: 14.sp, color: Colors.green),
                          SizedBox(width: 4.w),
                          Text(
                            item['count'] != null
                                ? '${item['serviceName']} x${item['count']}次'
                                : '${item['serviceName']} ¥${item['amount']}',
                            style: TextStyle(fontSize: 13.sp),
                          ),
                        ],
                      ),
                    )),
                  ],
                ),
              ),

              SizedBox(height: spacing / 2),

              // 描述
              Text(
                package['description'] ?? '',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey.shade600,
                ),
              ),

              SizedBox(height: spacing / 2),

              // 价格和购买
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '¥${package['salePrice']}',
                        style: TextStyle(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.bold,
                          color: AppConfig.primaryColor,
                        ),
                      ),
                      if (package['originalPrice'] > package['salePrice'])
                        Text(
                          '原价 ¥${package['originalPrice']}',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                    ],
                  ),
                  Text(
                    '有效期 ${package['validityDays']} 天',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),

              SizedBox(height: spacing / 2),

              // 购买按钮
              SizedBox(
                width: double.infinity,
                height: 44.h,
                child: ElevatedButton(
                  onPressed: _isPurchasing ? null : () => _handlePurchase(package),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isSelected ? AppConfig.primaryColor : Colors.grey.shade200,
                    foregroundColor: isSelected ? Colors.white : Colors.grey,
                  ),
                  child: _isPurchasing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          isSelected ? '立即购买' : '选择套餐',
                          style: TextStyle(fontSize: 14.sp),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 处理购买
  Future<void> _handlePurchase(Map<String, dynamic> package) async {
    if (_selectedPackageIndex == null) return;

    // 显示支付方式选择
    final paymentMethod = await _showPaymentSheet(package);

    if (paymentMethod == null) return;

    setState(() => _isPurchasing = true);

    try {
      await _memberRepository.createPurchaseOrder(
        templateId: package['id'],
        storeId: 1, // 默认门店
        paymentMethod: paymentMethod,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('购买成功！')),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('购买失败: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isPurchasing = false);
      }
    }
  }

  /// 显示支付方式选择底部弹窗
  Future<String?> _showPaymentSheet(Map<String, dynamic> package) {
    return showModalBottomSheet<String>(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.all(ResponsiveHelper.spacing(context)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '确认支付',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  '${package['name']}  ¥${package['salePrice']}',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: AppConfig.primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Divider(height: 32),
                _buildPaymentOption(
                  context,
                  icon: Icons.wechat,
                  color: Colors.green,
                  label: '微信支付',
                  value: 'WECHAT',
                ),
                _buildPaymentOption(
                  context,
                  icon: Icons.account_balance_wallet,
                  color: Colors.blue,
                  label: '支付宝',
                  value: 'ALIPAY',
                ),
                SizedBox(height: 16.h),
                SizedBox(
                  width: double.infinity,
                  height: 48.h,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, 'WECHAT'),
                    child: const Text('确认支付'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPaymentOption(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String label,
    required String value,
  }) {
    return ListTile(
      leading: Icon(icon, color: color, size: 28.sp),
      title: Text(label, style: TextStyle(fontSize: 15.sp)),
      trailing: Radio<String>(
        value: value,
        groupValue: 'WECHAT',
        onChanged: (_) {},
      ),
    );
  }
}
