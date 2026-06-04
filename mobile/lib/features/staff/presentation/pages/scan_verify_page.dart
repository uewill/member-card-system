import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:member_card_app/core/utils/responsive_helper.dart';
import 'package:member_card_app/features/staff/data/staff_repository.dart';
import 'package:member_card_app/shared/services/api_client.dart';

/// 员工扫码核销页面
class ScanVerifyPage extends StatefulWidget {
  const ScanVerifyPage({super.key});

  @override
  State<ScanVerifyPage> createState() => _ScanVerifyPageState();
}

class _ScanVerifyPageState extends State<ScanVerifyPage> {
  final MobileScannerController _scannerController = MobileScannerController();
  final StaffRepository _repository = StaffRepository();
  bool _isScanning = true;
  bool _isLoading = false;
  String? _scannedMemberId;
  String? _error;

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
        _loadMemberInfo(_scannedMemberId!);
      }
    }
  }

  Future<void> _loadMemberInfo(String memberId) async {
    setState(() => _isLoading = true);
    try {
      // 通过手机号或会员ID查询会员信息
      final members = await _repository.getCustomerList(keyword: memberId, size: 1);
      if (members.isNotEmpty) {
        _showMemberInfoDialog(members.first);
      } else {
        setState(() {
          _error = '未找到会员信息';
          _isLoading = false;
        });
        _showErrorDialog('未找到会员信息');
      }
    } catch (e) {
      setState(() {
        _error = '查询失败: $e';
        _isLoading = false;
      });
      _showErrorDialog('查询失败: $e');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('提示'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _isScanning = true;
                _scannedMemberId = null;
                _error = null;
              });
            },
            child: const Text('重新扫描'),
          ),
        ],
      ),
    );
  }

  void _showMemberInfoDialog(Map<String, dynamic> member) {
    setState(() => _isLoading = false);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('会员: ${member['name'] ?? '未知'}'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('手机号: ${member['phone'] ?? '-'}'),
              const SizedBox(height: 8),
              Text('余额: ¥${member['balance'] ?? 0}'),
              const SizedBox(height: 16),
              const Text('可用卡:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _buildMemberCards(member),
            ],
          ),
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
        ],
      ),
    );
  }

  Widget _buildMemberCards(Map<String, dynamic> member) {
    final cards = member['cards'] ?? [];
    if (cards is! List || cards.isEmpty) {
      return const Text('暂无可用卡', style: TextStyle(color: Colors.grey));
    }
    return SizedBox(
      height: 120,
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: cards.length,
        itemBuilder: (context, index) {
          final card = cards[index];
          final type = card['type'] ?? '次数卡';
          final isCount = type == '次数卡';
          final remain = isCount
              ? '${(card['total_times'] ?? 0) - (card['used_times'] ?? 0)}次'
              : '¥${card['balance'] ?? 0}';
          return ListTile(
            dense: true,
            title: Text(card['name'] ?? '未知卡'),
            subtitle: Text('剩余: $remain'),
            trailing: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _showVerifyConfirmDialog(member, card);
              },
              child: const Text('核销'),
            ),
          );
        },
      ),
    );
  }

  void _showVerifyConfirmDialog(Map<String, dynamic> member, Map<String, dynamic> card) {
    final serviceController = TextEditingController(text: '面部护理');
    final timesController = TextEditingController(text: '1');
    final type = card['type'] ?? '次数卡';
    final isCount = type == '次数卡';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('确认核销'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('会员: ${member['name']}'),
            Text('卡名: ${card['name']}'),
            const SizedBox(height: 16),
            TextField(
              controller: serviceController,
              decoration: const InputDecoration(
                labelText: '服务项目',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: timesController,
              decoration: InputDecoration(
                labelText: isCount ? '扣减次数' : '扣减金额',
                border: const OutlineInputBorder(),
                suffixText: isCount ? '次' : '元',
              ),
              keyboardType: TextInputType.number,
            ),
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
            onPressed: () async {
              Navigator.pop(context);
              await _doVerify(member, card, serviceController.text, timesController.text);
            },
            child: const Text('确认核销'),
          ),
        ],
      ),
    );
  }

  Future<void> _doVerify(Map<String, dynamic> member, Map<String, dynamic> card, String serviceName, String timesStr) async {
    setState(() => _isLoading = true);
    try {
      final times = int.tryParse(timesStr) ?? 1;
      final result = await _repository.verifyConsume({
        'member_id': member['id'],
        'card_id': card['id'],
        'service_name': serviceName,
        'times_used': times,
        'deduction_type': card['type'] == '次数卡' ? '次数' : '余额',
      });
      setState(() => _isLoading = false);
      _showSuccessDialog('核销成功', '服务: $serviceName\n扣减: $times${card['type'] == '次数卡' ? '次' : '元'}');
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorDialog('核销失败: $e');
    }
  }

  void _showSuccessDialog(String title, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _isScanning = true;
                _scannedMemberId = null;
              });
            },
            child: const Text('完成'),
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
              final phone = phoneController.text.trim();
              if (phone.isNotEmpty) {
                setState(() => _isScanning = false);
                _loadMemberInfo(phone);
              }
            },
            child: const Text('查询'),
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
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
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
                    onPressed: _showManualInputDialog,
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
}
