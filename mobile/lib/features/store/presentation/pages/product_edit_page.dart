import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

/// 商品编辑页面 - Mock 数据模式
class ProductEditPage extends StatefulWidget {
  final String? productId;

  const ProductEditPage({super.key, this.productId});

  @override
  State<ProductEditPage> createState() => _ProductEditPageState();
}

class _ProductEditPageState extends State<ProductEditPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _category = '服务项目';
  bool _isOnSale = true;

  final List<String> _categories = ['服务项目', '商品', '套餐'];

  bool get _isEditing => widget.productId != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      // Mock 编辑数据
      _nameController.text = '面部深层清洁';
      _priceController.text = '198';
      _descriptionController.text = '深层清洁面部皮肤，去除老化角质';
      _category = '服务项目';
      _isOnSale = true;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(_isEditing ? '编辑商品' : '添加商品'),
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
                      label: '商品名称',
                      controller: _nameController,
                      hint: '请输入商品名称',
                      validator: (v) => v?.isEmpty ?? true ? '请输入商品名称' : null,
                    ),
                    SizedBox(height: 16.h),
                    _buildDropdownField(
                      label: '分类',
                      value: _category,
                      items: _categories,
                      onChanged: (v) => setState(() => _category = v!),
                    ),
                    SizedBox(height: 16.h),
                    _buildTextField(
                      label: '价格（元）',
                      controller: _priceController,
                      hint: '请输入价格',
                      keyboardType: TextInputType.number,
                      validator: (v) => v?.isEmpty ?? true ? '请输入价格' : null,
                    ),
                    SizedBox(height: 16.h),
                    _buildTextField(
                      label: '描述',
                      controller: _descriptionController,
                      hint: '请输入商品描述',
                      maxLines: 3,
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20.h),

              // 状态设置
              _buildSectionTitle('状态设置'),
              SizedBox(height: 12.h),
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '上架状态',
                      style: TextStyle(
                        fontSize: 15.sp,
                        color: const Color(0xFF1D2129),
                      ),
                    ),
                    Switch(
                      value: _isOnSale,
                      activeColor: const Color(0xFF0052D9),
                      onChanged: (v) => setState(() => _isOnSale = v),
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
    int maxLines = 1,
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
          maxLines: maxLines,
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
