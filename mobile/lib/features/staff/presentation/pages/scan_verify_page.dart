import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:member_card_app/core/utils/responsive_helper.dart';

/// 员工扫码核销页面
class ScanVerifyPage extends StatefulWidget {
  const ScanVerifyPage({super.key});

  @override
  State<ScanVerifyPage> createState() => _ScanVerifyPageState();
}

class _ScanVerifyPageState extends State<ScanVerifyPage> {
  final MobileScannerController _scannerController = MobileScannerController();
  bool _isScanning = true;
  String? _scannedMemberId;

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (!_isScanning) return;
    
    final barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      final barcode = barcodes.first;
      if (barcode.rawValue != null) {
        setState(() {
          _isScanning = false;
          _scannedMemberId = barcode.rawValue!;
        });
        
        // TODO: 解析二维码内容，获取会员信息
        _showMemberInfoDialog();
      }
    }
  }

  void _showMemberInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('会员信息'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('会员ID: $_scannedMemberId'),
            const SizedBox(height: 16),
            const Text('可用卡:'),
            // TODO: 显示会员可用卡列表
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _isScanning = true;
                _scannedMemberId = null;
              });
            },
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: 选择服务项目并核销
              Navigator.pop(context);
            },
            child: const Text('确认核销'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final spacing = ResponsiveHelper.spacing(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('扫码核销'),
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _scannerController,
            onDetect: _onDetect,
          ),
          Positioned(
            bottom: spacing * 2,
            left: spacing,
            right: spacing,
            child: Container(
              padding: EdgeInsets.all(spacing),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Column(
                children: [
                  Text(
                    '请扫描会员二维码',
                    style: TextStyle(fontSize: 16.sp),
                  ),
                  SizedBox(height: spacing),
                  ElevatedButton.icon(
                    onPressed: () {
                      // 手动输入会员手机号
                      _showManualInputDialog();
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('手动输入'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showManualInputDialog() {
    final phoneController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('输入会员手机号'),
        content: TextField(
          controller: phoneController,
          decoration: const InputDecoration(
            labelText: '手机号',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.phone,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: 根据手机号查询会员信息
            },
            child: const Text('查询'),
          ),
        ],
      ),
    );
  }
}