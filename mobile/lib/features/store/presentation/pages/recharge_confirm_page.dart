import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:member_card_app/core/utils/responsive_helper.dart';

class RechargeConfirmPage extends StatefulWidget {
  const RechargeConfirmPage({super.key});

  @override
  State<RechargeConfirmPage> createState() => _RechargeConfirmPageState();
}

class _RechargeConfirmPageState extends State<RechargeConfirmPage> {
  // 选中的支付方式
  String _selectedPaymentMethod = '微信支付';

  // Mock 会员信息
  final Map<String, dynamic> _member = {
    'name': '李美丽',
    'phone': '138****8888',
    'level': 'VIP',
    'balance': 1280.50,
  };

  // Mock 充值金额
  final List<Map<String, dynamic>> _amountOptions = [
    {'amount': 500, 'bonus': 0, 'label': '500'},
    {'amount': 1000, 'bonus': 50, 'label': '1,000'},
    {'amount': 2000, 'bonus': 200, 'label': '2,000'},
    {'amount': 5000, 'bonus': 800, 'label': '5,000'},
  ];

  int _selectedAmountIndex = 1; // 默认选中 1000
  bool _isCustomAmount = false;
  final TextEditingController _customAmountController = TextEditingController();

  // 支付方式列表
  final List<Map<String, dynamic>> _paymentMethods = [
    {'name': '微信支付', 'icon': Icons.wechat, 'color': const Color(0xFF07C160)},
    {'name': '支付宝', 'icon': Icons.account_balance_wallet, 'color': const Color(0xFF1677FF)},
    {'name': '现金', 'icon': Icons.money, 'color': const Color(0xFFED7B2F)},
    {'name': '银行卡', 'icon': Icons.credit_card, 'color': const Color(0xFF0052D9)},
  ];

  bool _isProcessing = false;

  int get _currentAmount {
    if (_isCustomAmount) {
      return int.tryParse(_customAmountController.text) ?? 0;
    }
    return _amountOptions[_selectedAmountIndex]['amount'] as int;
  }

  int get _currentBonus {
    if (_isCustomAmount) return 0;
    return _amountOptions[_selectedAmountIndex]['bonus'] as int;
  }

  @override
  void dispose() {
    _customAmountController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF0052D9),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final spacing = ResponsiveHelper.spacing(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('充值确认'),
        backgroundColor: const Color(0xFF0052D9),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: spacing),

            // 会员信息摘要
            _buildMemberSummary(spacing),

            // 充值金额选择
            _buildAmountSection(spacing),

            // 支付方式选择
            _buildPaymentMethodSection(spacing),

            SizedBox(height: 24.h),

            // 充值详情摘要
            _buildRechargeSummary(spacing),

            SizedBox(height: 24.h),

            // 确认支付按钮
            Padding(
              padding: EdgeInsets.symmetric(horizontal: spacing),
              child: SizedBox(
                width: double.infinity,
                height: 48.h,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _onConfirmPayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0052D9),
                    disabledBackgroundColor: const Color(0xFFB8C4D4),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    elevation: 0,
                  ),
                  child: _isProcessing
                      ? SizedBox(
                          width: 20.r,
                          height: 20.r,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          '确认支付',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ),
            SizedBox(height: 32.h),
          ],
        ),
      ),
    );
  }

  /// 会员信息摘要
  Widget _buildMemberSummary(double spacing) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: spacing),
      padding: EdgeInsets.all(16.w),
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
          Container(
            width: 48.r,
            height: 48.r,
            decoration: BoxDecoration(
              color: const Color(0xFF0052D9).withOpacity(0.1),
              borderRadius: BorderRadius.circular(24.r),
            ),
            child: Center(
              child: Text(
                _member['name'].toString().substring(0, 1),
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0052D9),
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
                      _member['name'],
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1D2129),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFC53D),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        _member['level'],
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF7A4100),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Text(
                  _member['phone'],
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
                '当前余额',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: const Color(0xFF86909C),
                ),
              ),
              Text(
                '¥${_member['balance']}',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0052D9),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 充值金额选择
  Widget _buildAmountSection(double spacing) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: spacing, vertical: 8.h),
      padding: EdgeInsets.all(16.w),
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
            '充值金额',
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1D2129),
            ),
          ),
          SizedBox(height: 12.h),
          // 金额选项网格
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10.w,
              mainAxisSpacing: 10.h,
              childAspectRatio: 2.8,
            ),
            itemCount: _amountOptions.length,
            itemBuilder: (context, index) {
              final option = _amountOptions[index];
              final isSelected = !_isCustomAmount && _selectedAmountIndex == index;
              return _buildAmountOption(option, isSelected, index);
            },
          ),
          SizedBox(height: 10.h),
          // 自定义金额
          GestureDetector(
            onTap: () {
              setState(() {
                _isCustomAmount = true;
              });
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: _isCustomAmount
                    ? const Color(0xFF0052D9).withOpacity(0.05)
                    : const Color(0xFFF5F7FA),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                  color: _isCustomAmount
                      ? const Color(0xFF0052D9)
                      : Colors.transparent,
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Text(
                    '¥',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: _isCustomAmount
                          ? const Color(0xFF0052D9)
                          : const Color(0xFF86909C),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: TextField(
                      controller: _customAmountController,
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: const Color(0xFF1D2129),
                      ),
                      decoration: InputDecoration(
                        hintText: '自定义金额',
                        hintStyle: TextStyle(
                          fontSize: 14.sp,
                          color: const Color(0xFFC9CDD4),
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      keyboardType: TextInputType.number,
                      onTap: () {
                        setState(() {
                          _isCustomAmount = true;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountOption(Map<String, dynamic> option, bool isSelected, int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedAmountIndex = index;
          _isCustomAmount = false;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF0052D9).withOpacity(0.08)
              : const Color(0xFFF5F7FA),
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF0052D9)
                : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '¥${option['label']}',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: isSelected
                    ? const Color(0xFF0052D9)
                    : const Color(0xFF1D2129),
              ),
            ),
            if (option['bonus'] > 0)
              Text(
                '赠送 ¥${option['bonus']}',
                style: TextStyle(
                  fontSize: 11.sp,
                  color: const Color(0xFFED7B2F),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// 支付方式选择
  Widget _buildPaymentMethodSection(double spacing) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: spacing, vertical: 8.h),
      padding: EdgeInsets.all(16.w),
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
            '支付方式',
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1D2129),
            ),
          ),
          SizedBox(height: 12.h),
          ..._paymentMethods.map((method) => _buildPaymentMethodItem(method)),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodItem(Map<String, dynamic> method) {
    final isSelected = _selectedPaymentMethod == method['name'];
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = method['name'];
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: const Color(0xFFF2F3F5),
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36.r,
              height: 36.r,
              decoration: BoxDecoration(
                color: method['color'].withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                method['icon'],
                size: 18.sp,
                color: method['color'],
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                method['name'],
                style: TextStyle(
                  fontSize: 15.sp,
                  color: const Color(0xFF1D2129),
                ),
              ),
            ),
            Container(
              width: 22.r,
              height: 22.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF0052D9)
                      : const Color(0xFFDCDCDC),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 12.r,
                        height: 12.r,
                        decoration: const BoxDecoration(
                          color: Color(0xFF0052D9),
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  /// 充值详情摘要
  Widget _buildRechargeSummary(double spacing) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: spacing),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF0),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: const Color(0xFFED7B2F).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 16.sp,
                color: const Color(0xFFED7B2F),
              ),
              SizedBox(width: 6.w),
              Text(
                '充值详情',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFED7B2F),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          _buildSummaryRow('会员', _member['name']),
          _buildSummaryRow('充值金额', '¥${_currentAmount.toString()}'),
          if (_currentBonus > 0)
            _buildSummaryRow('赠送金额', '+¥${_currentBonus.toString()}'),
          _buildSummaryRow('支付方式', _selectedPaymentMethod),
          _buildSummaryRow('到账金额', '¥${(_currentAmount + _currentBonus).toString()}'),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13.sp,
              color: const Color(0xFF86909C),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF1D2129),
            ),
          ),
        ],
      ),
    );
  }

  /// 确认支付
  void _onConfirmPayment() {
    if (_currentAmount <= 0) {
      _showSnackBar('请选择充值金额');
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    // 模拟支付处理
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() {
        _isProcessing = false;
      });

      // 显示支付成功弹窗
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64.r,
                height: 64.r,
                decoration: const BoxDecoration(
                  color: Color(0xFF00A870),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check,
                  size: 32.sp,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                '支付成功',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1D2129),
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                '¥${_currentAmount.toString()} 已充值到 ${_member['name']} 账户',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: const Color(0xFF86909C),
                ),
                textAlign: TextAlign.center,
              ),
              if (_currentBonus > 0) ...[
                SizedBox(height: 6.h),
                Text(
                  '赠送 ¥${_currentBonus.toString()} 已到账',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: const Color(0xFFED7B2F),
                  ),
                ),
              ],
              SizedBox(height: 16.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    context.pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0052D9),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    '完成',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
