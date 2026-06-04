import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:member_card_app/core/utils/responsive_helper.dart';

class CreateCardPage extends StatefulWidget {
  const CreateCardPage({super.key});

  @override
  State<CreateCardPage> createState() => _CreateCardPageState();
}

class _CreateCardPageState extends State<CreateCardPage> {
  String _searchKeyword = '';
  Map<String, dynamic>? _selectedMember;
  String _selectedCardType = '次卡';

  final TextEditingController _cardNameController = TextEditingController();
  final TextEditingController _timesController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _expiryController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  final List<Map<String, dynamic>> _allMembers = [
    {'id': '1', 'name': '李美丽', 'phone': '138****8888', 'level': 'VIP'},
    {'id': '2', 'name': '王芳', 'phone': '139****6666', 'level': '普通'},
    {'id': '3', 'name': '张婷', 'phone': '137****9999', 'level': 'VIP'},
    {'id': '4', 'name': '刘洋', 'phone': '136****1111', 'level': '普通'},
    {'id': '5', 'name': '陈静', 'phone': '135****2222', 'level': 'VIP'},
    {'id': '6', 'name': '赵敏', 'phone': '133****3333', 'level': '普通'},
    {'id': '7', 'name': '孙丽', 'phone': '132****4444', 'level': 'VIP'},
  ];

  final List<String> _cardTypes = ['次卡', '储值卡', '混合卡'];
  bool _showMemberList = false;

  List<Map<String, dynamic>> get _filteredMembers {
    if (_searchKeyword.isEmpty) return _allMembers;
    return _allMembers.where((m) {
      return m['name'].toString().contains(_searchKeyword) ||
          m['phone'].toString().contains(_searchKeyword);
    }).toList();
  }

  @override
  void dispose() {
    _cardNameController.dispose();
    _timesController.dispose();
    _amountController.dispose();
    _expiryController.dispose();
    _priceController.dispose();
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
        title: const Text('创建次卡'),
        backgroundColor: const Color(0xFF0052D9),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: spacing),
            _buildSectionTitle('选择会员', spacing),
            _buildMemberSelector(spacing),
            _buildSectionTitle('卡类型', spacing),
            _buildCardTypeSelector(spacing),
            _buildSectionTitle('卡信息', spacing),
            _buildCardInfoForm(spacing),
            SizedBox(height: 24.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: spacing),
              child: SizedBox(
                width: double.infinity,
                height: 48.h,
                child: ElevatedButton(
                  onPressed: _onCreateCard,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0052D9),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    '确认创建',
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

  Widget _buildSectionTitle(String title, double spacing) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: spacing, vertical: 8.h),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF1D2129),
        ),
      ),
    );
  }

  Widget _buildMemberSelector(double spacing) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: spacing),
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
        children: [
          Padding(
            padding: EdgeInsets.all(12.w),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _showMemberList = true;
                });
              },
              child: TextField(
                controller: TextEditingController(text: _searchKeyword),
                onChanged: (value) {
                  setState(() {
                    _searchKeyword = value;
                    _showMemberList = true;
                  });
                },
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
          ),
          if (_selectedMember != null)
            Container(
              margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: const Color(0xFF0052D9).withOpacity(0.05),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: const Color(0xFF0052D9).withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36.r,
                    height: 36.r,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0052D9).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(18.r),
                    ),
                    child: Center(
                      child: Text(
                        _selectedMember!['name'].toString().substring(0, 1),
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0052D9),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedMember!['name'],
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF1D2129),
                          ),
                        ),
                        Text(
                          _selectedMember!['phone'],
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: const Color(0xFF86909C),
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedMember = null;
                      });
                    },
                    child: Icon(
                      Icons.close,
                      size: 18.sp,
                      color: const Color(0xFF86909C),
                    ),
                  ),
                ],
              ),
            ),
          if (_showMemberList && _selectedMember == null)
            Container(
              constraints: BoxConstraints(maxHeight: 240.h),
              child: ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                itemCount: _filteredMembers.length,
                itemBuilder: (context, index) {
                  final member = _filteredMembers[index];
                  return _buildMemberItem(member);
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMemberItem(Map<String, dynamic> member) {
    final isVip = member['level'] == 'VIP';
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMember = member;
          _showMemberList = false;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10.h),
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
                color: isVip
                    ? const Color(0xFF0052D9).withOpacity(0.1)
                    : const Color(0xFFF5F7FA),
                borderRadius: BorderRadius.circular(18.r),
              ),
              child: Center(
                child: Text(
                  member['name'].toString().substring(0, 1),
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: isVip
                        ? const Color(0xFF0052D9)
                        : const Color(0xFF86909C),
                  ),
                ),
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                member['name'],
                style: TextStyle(
                  fontSize: 14.sp,
                  color: const Color(0xFF1D2129),
                ),
              ),
            ),
            Text(
              member['phone'],
              style: TextStyle(
                fontSize: 13.sp,
                color: const Color(0xFF86909C),
              ),
            ),
            SizedBox(width: 8.w),
            if (isVip)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFC53D),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text(
                  'VIP',
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF7A4100),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardTypeSelector(double spacing) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: spacing),
      padding: EdgeInsets.all(12.w),
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
        children: _cardTypes.map((type) {
          final isSelected = _selectedCardType == type;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedCardType = type;
                });
              },
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 4.w),
                padding: EdgeInsets.symmetric(vertical: 10.h),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF0052D9)
                      : const Color(0xFFF5F7FA),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Center(
                  child: Text(
                    type,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected ? Colors.white : const Color(0xFF4E5969),
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCardInfoForm(double spacing) {
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
      child: Column(
        children: [
          _buildFormRow('卡名称', TextField(
            controller: _cardNameController,
            decoration: InputDecoration(
              hintText: '请输入卡名称',
              filled: true,
              fillColor: const Color(0xFFF5F7FA),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide.none,
              ),
            ),
          )),
          if (_selectedCardType == '次卡')
            _buildFormRow('次数', TextField(
              controller: _timesController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: '请输入总次数',
                filled: true,
                fillColor: const Color(0xFFF5F7FA),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: BorderSide.none,
                ),
              ),
            ))
          else if (_selectedCardType == '储值卡')
            _buildFormRow('储值金额', _buildMoneyInput(_amountController, '请输入储值金额'))
          else
            _buildFormRow('次数', TextField(
              controller: _timesController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: '请输入总次数',
                filled: true,
                fillColor: const Color(0xFFF5F7FA),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: BorderSide.none,
                ),
              ),
            )),
          if (_selectedCardType == '混合卡')
            _buildFormRow('储值金额', _buildMoneyInput(_amountController, '请输入储值金额')),
          _buildFormRow('有效期', TextField(
            controller: _expiryController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: '请选择有效期（天）',
              filled: true,
              fillColor: const Color(0xFFF5F7FA),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide.none,
              ),
              suffixIcon: GestureDetector(
                onTap: () {},
                child: Padding(
                  padding: EdgeInsets.only(right: 12.w),
                  child: Icon(
                    Icons.calendar_today,
                    size: 18.sp,
                    color: const Color(0xFF86909C),
                  ),
                ),
              ),
            ),
          )),
          _buildFormRow('售价', _buildMoneyInput(_priceController, '请输入售价')),
        ],
      ),
    );
  }

  Widget _buildMoneyInput(TextEditingController controller, String hint) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F7FA),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(8.r),
              bottomLeft: Radius.circular(8.r),
            ),
          ),
          child: Text(
            '¥',
            style: TextStyle(
              fontSize: 16.sp,
              color: const Color(0xFF1D2129),
            ),
          ),
        ),
        Expanded(
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: hint,
              filled: true,
              fillColor: const Color(0xFFF5F7FA),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(8.r),
                  bottomRight: Radius.circular(8.r),
                ),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFormRow(String label, Widget input) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 6.h),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13.sp,
              color: const Color(0xFF4E5969),
            ),
          ),
        ),
        input,
        SizedBox(height: 12.h),
      ],
    );
  }

  void _onCreateCard() {
    if (_selectedMember == null) {
      _showSnackBar('请选择会员');
      return;
    }
    if (_cardNameController.text.isEmpty) {
      _showSnackBar('请输入卡名称');
      return;
    }
    if (_selectedCardType == '次卡' && _timesController.text.isEmpty) {
      _showSnackBar('请输入次数');
      return;
    }
    if (_priceController.text.isEmpty) {
      _showSnackBar('请输入售价');
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle,
              size: 48.sp,
              color: const Color(0xFF00A870),
            ),
            SizedBox(height: 12.h),
            Text(
              '创建成功',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1D2129),
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              '已为 ${_selectedMember!['name']} 成功创建 ${_cardNameController.text}',
              style: TextStyle(
                fontSize: 14.sp,
                color: const Color(0xFF86909C),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
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
                '确定',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
