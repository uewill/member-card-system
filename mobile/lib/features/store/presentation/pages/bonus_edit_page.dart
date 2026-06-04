import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

/// 赠送规则编辑页面 - Mock 数据模式
class BonusEditPage extends StatefulWidget {
  final String? bonusId;

  const BonusEditPage({super.key, this.bonusId});

  @override
  State<BonusEditPage> createState() => _BonusEditPageState();
}

class _BonusEditPageState extends State<BonusEditPage> {
  final _formKey = GlobalKey<FormState>();
  final _thresholdController = TextEditingController();
  final _bonusAmountController = TextEditingController();
  final _validityController = TextEditingController();

  String _bonusType = '固定金额';
  bool _isEnabled = true;

  final List<String> _bonusTypes = ['固定金额', '比例'];

  @override
  void dispose() {
    _thresholdController.dispose();
    _bonusAmountController.dispose();
    _validityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('添加赠送规则'),
        backgroundColor: const Color(0xFF0052D9),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 充值规则
              _buildSectionTitle('充值规则'),
              SizedBox(height: 12.h),
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Column(
                  children: [
                    _buildTextField(
                      label: '充值门槛金额（元）',
                      controller: _thresholdController,
                      hint: '请输入充值门槛金额',
                      keyboardType: TextInputType.number,
                      validator: (v) => v?.isEmpty ?? true ? '请输入充值门槛金额' : null,
                    ),
                    SizedBox(height: 16.h),
                    _buildDropdownField(
                      label: '赠送类型',
                      value: _bonusType,
                      items: _bonusTypes,
                      onChanged: (v) => setState(() => _bonusType = v!),
                    ),
                    SizedBox(height: 16.h),
                    _buildTextField(
                      label: _bonusType == '固定金额' ? '赠送金额（元）' : '赠送比例（%）',
                      controller: _bonusAmountController,
                      hint: _bonusType == '固定金额' ? '请输入赠送金额' : '请输入赠送比例',
                      keyboardType: TextInputType.number,
                      validator: (v) => v?.isEmpty ?? true ? '请输入赠送数值' : null,
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20.h),

              // 有效期与状态
              _buildSectionTitle('有效期与状态'),
              SizedBox(height: 12.h),
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Column(
                  children: [
                    _buildTextField(
                      label: '有效期（天）',
                      controller: _validityController,
                      hint: '请输入有效天数，留空则永久有效',
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 16.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '启用状态',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: const Color(0xFF4E5969),
                          ),
                        ),
                        Switch(
                          value: _isEnabled,
                          activeColor: const Color(0xFF0052D9),
                          onChanged: (v) => setState(() => _isEnabled = v),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 32.h),

              // 保存按钮
              SizedBox(
                width: double.infinity,
                height: 48.h,
                child: ElevatedButton(
                  onPressed: _onSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0052D9),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    '保存',
                    style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF1D2129),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            color: const Color(0xFF4E5969),
          ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: const Color(0xFFC9CDD4), fontSize: 14.sp),
            filled: true,
            fillColor: const Color(0xFFF5F7FA),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide.none,
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
          ),
          keyboardType: keyboardType,
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            color: const Color(0xFF4E5969),
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F7FA),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              items: items.map((e) {
                return DropdownMenuItem<String>(
                  value: e,
                  child: Text(e, style: TextStyle(fontSize: 14.sp, color: const Color(0xFF1D2129))),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('保存成功（Mock）'), backgroundColor: Color(0xFF0052D9)),
    );
    context.pop();
  }
}
