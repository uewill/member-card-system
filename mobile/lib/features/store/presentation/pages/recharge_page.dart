import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:member_card_app/core/utils/responsive_helper.dart';

/// 充值开卡页 - 商务专业风格
class RechargePage extends StatefulWidget {
  const RechargePage({super.key});

  @override
  State<RechargePage> createState() => _RechargePageState();
}

class _RechargePageState extends State<RechargePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentTab = 0;

  // 充值相关
  final TextEditingController _rechargeSearchController = TextEditingController();
  int? _selectedMemberIndex;
  int? _selectedCardIndex;
  final TextEditingController _amountController = TextEditingController();
  int _selectedPaymentMethod = 0;

  // 开卡相关
  final TextEditingController _openCardSearchController = TextEditingController();
  int? _selectedPackageIndex;
  int _selectedOpenPaymentMethod = 0;

  // Mock 会员数据
  final List<Map<String, dynamic>> _members = [
    {
      'name': '李美丽',
      'phone': '138****5678',
      'avatar': '李',
      'avatarColor': Color(0xFF0052D9),
      'cards': [
        {'cardName': '面部护理10次卡', 'cardNo': 'MC20240601001', 'balance': '剩余8次', 'type': '次卡'},
        {'cardName': 'VIP储值卡', 'cardNo': 'MC20240515002', 'balance': '¥1,280.00', 'type': '储值卡'},
      ],
    },
    {
      'name': '王芳',
      'phone': '139****1234',
      'avatar': '王',
      'avatarColor': Color(0xFF7B61FF),
      'cards': [
        {'cardName': 'VIP储值卡', 'cardNo': 'MC20240515002', 'balance': '¥1,280.00', 'type': '储值卡'},
      ],
    },
    {
      'name': '张婷',
      'phone': '136****9876',
      'avatar': '张',
      'avatarColor': Color(0xFFE34D59),
      'cards': [
        {'cardName': '精油按摩5次卡', 'cardNo': 'MC20240301003', 'balance': '剩余2次', 'type': '次卡'},
      ],
    },
    {
      'name': '刘洋',
      'phone': '137****5555',
      'avatar': '刘',
      'avatarColor': Color(0xFF00A870),
      'cards': [
        {'cardName': '综合护理卡', 'cardNo': 'MC20240401004', 'balance': '5次+¥500', 'type': '混合卡'},
      ],
    },
  ];

  // Mock 套餐数据
  final List<Map<String, dynamic>> _packages = [
    {
      'name': '面部护理套餐',
      'type': '次卡',
      'typeColor': Color(0xFF0052D9),
      'count': '10次',
      'price': 1980.0,
      'originalPrice': 2800.0,
      'description': '含深层清洁、补水保湿、抗衰护理等10次面部护理服务',
      'icon': Icons.face,
      'popular': true,
    },
    {
      'name': 'VIP储值卡',
      'type': '储值',
      'typeColor': Color(0xFF7B61FF),
      'count': '¥2,500',
      'price': 2500.0,
      'originalPrice': 2500.0,
      'description': '充2500元享VIP折扣，全场服务9折优惠',
      'icon': Icons.card_membership,
      'popular': false,
    },
    {
      'name': '综合护理卡',
      'type': '混合',
      'typeColor': Color(0xFF00A870),
      'count': '5次+¥1,000',
      'price': 2880.0,
      'originalPrice': 3800.0,
      'description': '含5次面部护理+1000元储值余额，灵活使用',
      'icon': Icons.auto_awesome,
      'popular': false,
    },
    {
      'name': '体验套餐',
      'type': '次卡',
      'typeColor': Color(0xFFED7B2F),
      'count': '3次',
      'price': 199.0,
      'originalPrice': 580.0,
      'description': '新客专享体验套餐，含3次基础护理服务',
      'icon': Icons.star,
      'popular': true,
    },
  ];

  // 支付方式
  final List<Map<String, dynamic>> _paymentMethods = [
    {'name': '微信支付', 'icon': Icons.wechat_outlined, 'color': Color(0xFF07C160)},
    {'name': '支付宝', 'icon': Icons.account_balance_wallet, 'color': Color(0xFF1677FF)},
    {'name': '现金', 'icon': Icons.payments_outlined, 'color': Color(0xFFED7B2F)},
    {'name': '银行卡', 'icon': Icons.credit_card, 'color': Color(0xFF0052D9)},
  ];

  List<Map<String, dynamic>> get _filteredMembers {
    final keyword = _rechargeSearchController.text.trim().toLowerCase();
    if (keyword.isEmpty) return _members;
    return _members.where((m) {
      final name = (m['name'] as String).toLowerCase();
      final phone = (m['phone'] as String).toLowerCase();
      return name.contains(keyword) || phone.contains(keyword);
    }).toList();
  }

  List<Map<String, dynamic>> get _filteredOpenCardMembers {
    final keyword = _openCardSearchController.text.trim().toLowerCase();
    if (keyword.isEmpty) return _members;
    return _members.where((m) {
      final name = (m['name'] as String).toLowerCase();
      final phone = (m['phone'] as String).toLowerCase();
      return name.contains(keyword) || phone.contains(keyword);
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          _currentTab = _tabController.index;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _rechargeSearchController.dispose();
    _openCardSearchController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF0052D9),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _handleRechargeConfirm() {
    if (_selectedMemberIndex == null) {
      _showToast('请选择会员');
      return;
    }
    if (_amountController.text.trim().isEmpty) {
      _showToast('请输入充值金额');
      return;
    }
    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) {
      _showToast('请输入有效金额');
      return;
    }
    _showToast('充值成功！已充值 ¥${amount.toStringAsFixed(2)}');
    setState(() {
      _selectedMemberIndex = null;
      _selectedCardIndex = null;
      _amountController.clear();
    });
  }

  void _handleOpenCardConfirm() {
    if (_selectedPackageIndex == null) {
      _showToast('请选择套餐');
      return;
    }
    final pkg = _packages[_selectedPackageIndex!];
    _showToast('开卡成功！已购买 ${pkg['name']}');
    setState(() {
      _selectedPackageIndex = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final spacing = ResponsiveHelper.spacing(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          '充值开卡',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1D2129),
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF1D2129)),
          onPressed: () => context.go('/dashboard'),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(44.h),
          child: Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: const Color(0xFF0052D9),
              unselectedLabelColor: const Color(0xFF86909C),
              indicatorColor: const Color(0xFF0052D9),
              indicatorSize: TabBarIndicatorSize.label,
              indicatorWeight: 3,
              labelStyle: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
              unselectedLabelStyle:
                  TextStyle(fontSize: 15.sp, fontWeight: FontWeight.normal),
              tabs: const [
                Tab(text: '充值'),
                Tab(text: '开卡'),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRechargeTab(spacing),
          _buildOpenCardTab(spacing),
        ],
      ),
    );
  }

  // ==================== 充值 Tab ====================

  Widget _buildRechargeTab(double spacing) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(spacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 搜索会员
          _buildSectionTitle('选择会员', Icons.people),
          SizedBox(height: 12.h),
          _buildRechargeSearchBar(spacing),
          SizedBox(height: 12.h),
          _buildMemberList(_filteredMembers, isRecharge: true),
          SizedBox(height: spacing),

          // 选择卡片（会员选中后显示）
          if (_selectedMemberIndex != null) ...[
            _buildSectionTitle('选择充值卡片', Icons.credit_card),
            SizedBox(height: 12.h),
            _buildCardSelection(),
            SizedBox(height: spacing),
          ],

          // 充值金额
          if (_selectedCardIndex != null) ...[
            _buildSectionTitle('充值金额', Icons.paid),
            SizedBox(height: 12.h),
            _buildAmountInput(spacing),
            SizedBox(height: 12.h),
            _buildQuickAmountButtons(spacing),
            SizedBox(height: spacing),
          ],

          // 支付方式
          if (_selectedCardIndex != null) ...[
            _buildSectionTitle('支付方式', Icons.payment),
            SizedBox(height: 12.h),
            _buildPaymentMethodSelection(_selectedPaymentMethod, (index) {
              setState(() => _selectedPaymentMethod = index);
            }),
            SizedBox(height: spacing),
          ],

          // 确认按钮
          if (_selectedCardIndex != null)
            _buildConfirmButton('确认充值', _handleRechargeConfirm),
        ],
      ),
    );
  }

  Widget _buildRechargeSearchBar(double spacing) {
    return Container(
      height: 48.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: TextField(
        controller: _rechargeSearchController,
        onChanged: (_) => setState(() {}),
        style: TextStyle(fontSize: 14.sp, color: const Color(0xFF1D2129)),
        decoration: InputDecoration(
          hintText: '搜索会员姓名或手机号',
          hintStyle: TextStyle(fontSize: 13.sp, color: const Color(0xFFC9CDD4)),
          prefixIcon: Icon(Icons.search, color: const Color(0xFFC9CDD4), size: 20.sp),
          contentPadding: EdgeInsets.symmetric(vertical: 14.h),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildMemberList(List<Map<String, dynamic>> members, {bool isRecharge = false}) {
    if (members.isEmpty) {
      return Container(
        padding: EdgeInsets.symmetric(vertical: 32.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Center(
          child: Text(
            '未找到匹配的会员',
            style: TextStyle(fontSize: 14.sp, color: const Color(0xFF86909C)),
          ),
        ),
      );
    }

    return Column(
      children: members.asMap().entries.map((entry) {
        final index = entry.key;
        final member = entry.value;
        final originalIndex = _members.indexOf(member);
        final isSelected = isRecharge
            ? _selectedMemberIndex == originalIndex
            : false;

        return GestureDetector(
          onTap: () {
            setState(() {
              if (isRecharge) {
                _selectedMemberIndex = originalIndex;
                _selectedCardIndex = null;
              }
            });
          },
          child: Container(
            margin: EdgeInsets.only(bottom: 10.h),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF0052D9)
                    : Colors.transparent,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 42.r,
                  height: 42.r,
                  decoration: BoxDecoration(
                    color: member['avatarColor'] as Color,
                    borderRadius: BorderRadius.circular(21.r),
                  ),
                  child: Center(
                    child: Text(
                      member['avatar'] as String,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        member['name'] as String,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1D2129),
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        member['phone'] as String,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: const Color(0xFF86909C),
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Icon(Icons.check_circle, color: const Color(0xFF0052D9), size: 22.sp),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCardSelection() {
    final member = _members[_selectedMemberIndex!];
    final cards = member['cards'] as List<Map<String, dynamic>>;

    return Column(
      children: cards.asMap().entries.map((entry) {
        final index = entry.key;
        final card = entry.value;
        final isSelected = _selectedCardIndex == index;

        return GestureDetector(
          onTap: () => setState(() => _selectedCardIndex = index),
          child: Container(
            margin: EdgeInsets.only(bottom: 10.h),
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF0052D9)
                    : const Color(0xFFE5E6EB),
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40.r,
                  height: 40.r,
                  decoration: BoxDecoration(
                    color: card['type'] == '次卡'
                        ? const Color(0xFF0052D9).withOpacity(0.1)
                        : card['type'] == '储值卡'
                            ? const Color(0xFF7B61FF).withOpacity(0.1)
                            : const Color(0xFF00A870).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    card['type'] == '次卡'
                        ? Icons.confirmation_number
                        : card['type'] == '储值卡'
                            ? Icons.account_balance_wallet
                            : Icons.auto_awesome,
                    color: card['type'] == '次卡'
                        ? const Color(0xFF0052D9)
                        : card['type'] == '储值卡'
                            ? const Color(0xFF7B61FF)
                            : const Color(0xFF00A870),
                    size: 20.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        card['cardName'] as String,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF1D2129),
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        '${card['cardNo']} | ${card['balance']}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: const Color(0xFF86909C),
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Icon(Icons.check_circle, color: const Color(0xFF0052D9), size: 22.sp),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAmountInput(double spacing) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '¥',
                style: TextStyle(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0052D9),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  style: TextStyle(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1D2129),
                  ),
                  decoration: InputDecoration(
                    hintText: '0.00',
                    hintStyle: TextStyle(
                      fontSize: 28.sp,
                      color: const Color(0xFFC9CDD4),
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAmountButtons(double spacing) {
    final amounts = [100, 200, 500, 1000, 2000, 5000];

    return Wrap(
      spacing: 10.w,
      runSpacing: 10.h,
      children: amounts.map((amount) {
        return GestureDetector(
          onTap: () {
            setState(() {
              _amountController.text = amount.toString();
            });
          },
          child: Container(
            width: (1.sw - spacing * 2 - 50.w) / 3,
            padding: EdgeInsets.symmetric(vertical: 12.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: const Color(0xFFE5E6EB)),
            ),
            child: Center(
              child: Text(
                '¥$amount',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF4E5969),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPaymentMethodSelection(
    int selectedIndex,
    ValueChanged<int> onChanged,
  ) {
    return Column(
      children: _paymentMethods.asMap().entries.map((entry) {
        final index = entry.key;
        final method = entry.value;
        final isSelected = selectedIndex == index;

        return GestureDetector(
          onTap: () => onChanged(index),
          child: Container(
            margin: EdgeInsets.only(bottom: 10.h),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF0052D9)
                    : const Color(0xFFE5E6EB),
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  method['icon'] as IconData,
                  color: method['color'] as Color,
                  size: 22.sp,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    method['name'] as String,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF1D2129),
                    ),
                  ),
                ),
                if (isSelected)
                  Container(
                    width: 22.r,
                    height: 22.r,
                    decoration: const BoxDecoration(
                      color: Color(0xFF0052D9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check, color: Colors.white, size: 14),
                  )
                else
                  Container(
                    width: 22.r,
                    height: 22.r,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFC9CDD4), width: 1.5),
                    ),
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // ==================== 开卡 Tab ====================

  Widget _buildOpenCardTab(double spacing) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(spacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 搜索/新建会员
          _buildSectionTitle('选择会员', Icons.person_add),
          SizedBox(height: 12.h),
          _buildOpenCardSearchBar(spacing),
          SizedBox(height: 12.h),
          _buildMemberList(_filteredOpenCardMembers, isRecharge: false),
          SizedBox(height: spacing),

          // 新建会员按钮
          _buildNewMemberButton(spacing),
          SizedBox(height: spacing),

          // 套餐选择
          _buildSectionTitle('选择套餐', Icons.local_offer),
          SizedBox(height: 12.h),
          ..._packages.asMap().entries.map((entry) {
            return _buildPackageCard(entry.key, entry.value, spacing);
          }),
          SizedBox(height: spacing),

          // 支付方式
          if (_selectedPackageIndex != null) ...[
            _buildSectionTitle('支付方式', Icons.payment),
            SizedBox(height: 12.h),
            _buildPaymentMethodSelection(
              _selectedOpenPaymentMethod,
              (index) {
                setState(() => _selectedOpenPaymentMethod = index);
              },
            ),
            SizedBox(height: spacing),
          ],

          // 确认按钮
          if (_selectedPackageIndex != null)
            _buildConfirmButton('确认开卡', _handleOpenCardConfirm),
        ],
      ),
    );
  }

  Widget _buildOpenCardSearchBar(double spacing) {
    return Container(
      height: 48.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: TextField(
        controller: _openCardSearchController,
        onChanged: (_) => setState(() {}),
        style: TextStyle(fontSize: 14.sp, color: const Color(0xFF1D2129)),
        decoration: InputDecoration(
          hintText: '搜索会员姓名或手机号',
          hintStyle: TextStyle(fontSize: 13.sp, color: const Color(0xFFC9CDD4)),
          prefixIcon: Icon(Icons.search, color: const Color(0xFFC9CDD4), size: 20.sp),
          contentPadding: EdgeInsets.symmetric(vertical: 14.h),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildNewMemberButton(double spacing) {
    return GestureDetector(
      onTap: () => _showToast('新建会员功能'),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 14.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: const Color(0xFF0052D9),
            width: 1,
            style: BorderStyle.solid,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, color: const Color(0xFF0052D9), size: 18.sp),
            SizedBox(width: 6.w),
            Text(
              '新建会员',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF0052D9),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPackageCard(int index, Map<String, dynamic> package, double spacing) {
    final isSelected = _selectedPackageIndex == index;
    final typeColor = package['typeColor'] as Color;
    final hasDiscount = package['originalPrice'] != package['price'];
    final discount = hasDiscount
        ? ((package['price'] / package['originalPrice']) * 10).toStringAsFixed(1)
        : null;

    return GestureDetector(
      onTap: () => setState(() => _selectedPackageIndex = index),
      child: Container(
        margin: EdgeInsets.only(bottom: 14.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF0052D9)
                : const Color(0xFFE5E6EB),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 第一行：图标 + 名称 + 标签
            Row(
              children: [
                Container(
                  width: 44.r,
                  height: 44.r,
                  decoration: BoxDecoration(
                    color: typeColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(
                    package['icon'] as IconData,
                    color: typeColor,
                    size: 22.sp,
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
                            package['name'] as String,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1D2129),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 6.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: typeColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(3.r),
                            ),
                            child: Text(
                              package['type'] as String,
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: typeColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          if (package['popular'] == true) ...[
                            SizedBox(width: 6.w),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 6.w,
                                vertical: 2.h,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE34D59).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(3.r),
                              ),
                              child: Text(
                                '热门',
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: const Color(0xFFE34D59),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        package['description'] as String,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: const Color(0xFF86909C),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 14.h),

            // 分隔线
            Container(height: 1, color: const Color(0xFFF2F3F5)),

            SizedBox(height: 14.h),

            // 第二行：次数/余额 + 价格
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '包含',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: const Color(0xFFC9CDD4),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      package['count'] as String,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1D2129),
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        if (hasDiscount && discount != null) ...[
                          Text(
                            '¥${(package['originalPrice'] as double).toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: const Color(0xFFC9CDD4),
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                          SizedBox(width: 6.w),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 4.w,
                              vertical: 1.h,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE34D59),
                              borderRadius: BorderRadius.circular(3.r),
                            ),
                            child: Text(
                              '${discount}折',
                              style: TextStyle(
                                fontSize: 10.sp,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(width: 8.w),
                        ],
                        Text(
                          '¥${(package['price'] as double).toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFE34D59),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),

            // 选中指示
            if (isSelected)
              Container(
                margin: EdgeInsets.only(top: 12.h),
                padding: EdgeInsets.symmetric(vertical: 8.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF0052D9).withOpacity(0.06),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, color: const Color(0xFF0052D9), size: 16.sp),
                    SizedBox(width: 4.w),
                    Text(
                      '已选择',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: const Color(0xFF0052D9),
                        fontWeight: FontWeight.w500,
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

  // ==================== 通用组件 ====================

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18.sp, color: const Color(0xFF0052D9)),
        SizedBox(width: 6.w),
        Text(
          title,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1D2129),
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmButton(String text, VoidCallback onPressed) {
    return Container(
      width: double.infinity,
      height: 52.h,
      margin: EdgeInsets.only(bottom: 24.h),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0052D9),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
          elevation: 0,
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
