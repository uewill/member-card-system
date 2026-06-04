import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 打印设置页面 - Mock 数据模式
class PrintSettingsPage extends StatefulWidget {
  const PrintSettingsPage({super.key});

  @override
  State<PrintSettingsPage> createState() => _PrintSettingsPageState();
}

class _PrintSettingsPageState extends State<PrintSettingsPage> {
  bool _autoPrint = true;
  bool _printReceipt = true;
  bool _printMemberInfo = true;
  String _paperSize = '80mm';
  int _printCopies = 1;

  final List<String> _paperSizes = ['58mm', '80mm'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('打印设置'),
        backgroundColor: const Color(0xFF0052D9),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 打印开关
            _buildSectionTitle('打印开关'),
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Column(
                children: [
                  _buildSwitchItem('自动打印', '交易完成后自动打印小票', _autoPrint, (v) => setState(() => _autoPrint = v)),
                  Divider(height: 32.h, color: const Color(0xFFF2F3F5)),
                  _buildSwitchItem('打印收据', '在收据中包含交易详情', _printReceipt, (v) => setState(() => _printReceipt = v)),
                  Divider(height: 32.h, color: const Color(0xFFF2F3F5)),
                  _buildSwitchItem('打印会员信息', '在收据中包含会员信息', _printMemberInfo, (v) => setState(() => _printMemberInfo = v)),
                ],
              ),
            ),

            SizedBox(height: 20.h),

            // 打印参数
            _buildSectionTitle('打印参数'),
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Column(
                children: [
                  _buildDropdownField(
                    label: '纸张宽度',
                    value: _paperSize,
                    items: _paperSizes,
                    onChanged: (v) => setState(() => _paperSize = v!),
                  ),
                  Divider(height: 32.h, color: const Color(0xFFF2F3F5)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '打印份数',
                        style: TextStyle(fontSize: 15.sp, color: const Color(0xFF1D2129)),
                      ),
                      Row(
                        children: [
                          _buildCopyButton(Icons.remove, () {
                            if (_printCopies > 1) setState(() => _printCopies--);
                          }),
                          Container(
                            width: 48.w,
                            alignment: Alignment.center,
                            child: Text(
                              '$_printCopies',
                              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: const Color(0xFF0052D9)),
                            ),
                          ),
                          _buildCopyButton(Icons.add, () {
                            if (_printCopies < 5) setState(() => _printCopies++);
                          }),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 20.h),

            // 打印机信息
            _buildSectionTitle('打印机信息'),
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Column(
                children: [
                  _buildInfoRow('打印机状态', '已连接', const Color(0xFF00A870)),
                  Divider(height: 32.h, color: const Color(0xFFF2F3F5)),
                  _buildInfoRow('设备名称', 'POS-Printer-001', const Color(0xFF4E5969)),
                  Divider(height: 32.h, color: const Color(0xFFF2F3F5)),
                  _buildInfoRow('连接方式', '蓝牙', const Color(0xFF4E5969)),
                ],
              ),
            ),

            SizedBox(height: 32.h),

            // 保存按钮
            SizedBox(
              width: double.infinity,
              height: 48.h,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('设置已保存（Mock）'), backgroundColor: Color(0xFF0052D9)),
                  );
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
                  '保存设置',
                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            SizedBox(height: 20.h),
          ],
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

  Widget _buildSwitchItem(String title, String subtitle, bool value, void Function(bool) onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontSize: 15.sp, color: const Color(0xFF1D2129))),
              SizedBox(height: 2.h),
              Text(subtitle, style: TextStyle(fontSize: 12.sp, color: const Color(0xFF86909C))),
            ],
          ),
        ),
        Switch(value: value, activeColor: const Color(0xFF0052D9), onChanged: onChanged),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 15.sp, color: const Color(0xFF1D2129))),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F7FA),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
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

  Widget _buildCopyButton(IconData icon, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 32.r,
        height: 32.r,
        decoration: BoxDecoration(
          color: const Color(0xFFF5F7FA),
          borderRadius: BorderRadius.circular(6.r),
        ),
        child: Icon(icon, size: 18.sp, color: const Color(0xFF0052D9)),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 14.sp, color: const Color(0xFF4E5969))),
        Text(value, style: TextStyle(fontSize: 14.sp, color: valueColor, fontWeight: FontWeight.w500)),
      ],
    );
  }
}
