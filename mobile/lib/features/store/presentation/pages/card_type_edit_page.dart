import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

/// 卡类型编辑页面 - Mock 数据模式
class CardTypeEditPage extends StatefulWidget {
  final String? cardTypeId;

  const CardTypeEditPage({super.key, this.cardTypeId});

  @override
  State<CardTypeEditPage> createState() => _CardTypeEditPageState();
}

class _CardTypeEditPageState extends State<CardTypeEditPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _timesController = TextEditingController();
  final _balanceController = TextEditingController();
  final _priceController = TextEditingController();
  final _validityController = TextEditingController();

  String _cardType = '次卡';
  final List<String> _cardTypes = ['次卡', '储值卡', '混合卡'];
  final List<String> _allServices = ['面部清洁', '精油按摩', '剪发造型', '美甲护理', '脱毛护理', '头皮养护'];
  final Set<String> _selectedServices = {'面部清洁', '精油按摩'};

  bool get _showTimes => _cardType == '次卡' || _cardType == '混合卡';
  bool get _showBalance => _cardType == '储值卡' || _cardType == '混合卡';

  @override
  void dispose() {
    _nameController.dispose();
    _timesController.dispose();
    _balanceController.dispose();
    _priceController.dispose();
    _validityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('新建卡类型'),
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
              // 基本信息
              _buildSectionTitle('基本信息'),
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
                      label: '卡类型名称',
                      controller: _nameController,
                      hint: '请输入卡类型名称',
                      validator: (v) => v?.isEmpty ?? true ? '请输入卡类型名称' : null,
                    ),
                    SizedBox(height: 16.h),
                    _buildDropdownField(
                      label: '类型选择',
                      value: _cardType,
                      items: _cardTypes,
                      onChanged: (v) => setState(() => _cardType = v!),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20.h),

              // 卡属性
              _buildSectionTitle('卡属性'),
              SizedBox(height: 12.h),
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Column(
                  children: [
                    if (_showTimes) ...[
                      _buildTextField(
                        label: '次数',
                        controller: _timesController,
                        hint: '请输入可用次数',
                        keyboardType: TextInputType.number,
                      ),
                      SizedBox(height: 16.h),
                    ],
                    if (_showBalance) ...[
                      _buildTextField(
                        label: '储值金额（元）',
                        controller: _balanceController,
                        hint: '请输入储值金额',
                        keyboardType: TextInputType.number,
                      ),
                      SizedBox(height: 16.h),
                    ],
                    _buildTextField(
                      label: '售价（元）',
                      controller: _priceController,
                      hint: '请输入售价',
                      keyboardType: TextInputType.number,
                      validator: (v) => v?.isEmpty ?? true ? '请输入售价' : null,
                    ),
                    SizedBox(height: 16.h),
                    _buildTextField(
                      label: '有效期（天）',
                      controller: _validityController,
                      hint: '请输入有效天数',
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20.h),

              // 包含服务
              _buildSectionTitle('包含服务'),
              SizedBox(height: 12.h),
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: _allServices.map((service) {
                    final selected = _selectedServices.contains(service);
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (selected) {
                            _selectedServices.remove(service);
                          } else {
                            _selectedServices.add(service);
                          }
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                        decoration: BoxDecoration(
                          color: selected ? const Color(0xFF0052D9).withOpacity(0.1) : const Color(0xFFF5F7FA),
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(
                            color: selected ? const Color(0xFF0052D9) : const Color(0xFFE5E6EB),
                          ),
                        ),
                        child: Text(
                          service,
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: selected ? const Color(0xFF0052D9) : const Color(0xFF4E5969),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
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
