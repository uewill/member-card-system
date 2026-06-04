import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:member_card_app/core/utils/responsive_helper.dart';

/// 消费核销页 - 商务专业风格
class ConsumeVerifyPage extends StatefulWidget {
  const ConsumeVerifyPage({super.key});

  @override
  State<ConsumeVerifyPage> createState() => _ConsumeVerifyPageState();
}

class _ConsumeVerifyPageState extends State<ConsumeVerifyPage> {
  final TextEditingController _codeController = TextEditingController();
  bool _isQuerying = false;
  bool _showResult = false;

  // Mock 核销结果数据
  Map<String, dynamic>? _verifyResult;

  // Mock 今日核销记录
  final List<Map<String, dynamic>> _todayRecords = [
    {
      'time': '14:30',
      'memberName': '李美丽',
      'service': '面部护理',
      'count': '1次',
      'cardNo': 'MC20240601001',
      'status': 'success',
    },
    {
      'time': '13:15',
      'memberName': '张婷',
      'service': '精油按摩',
      'count': '1次',
      'cardNo': 'MC20240301003',
      'status': 'success',
    },
    {
      'time': '11:00',
      'memberName': '刘洋',
      'service': '综合护理',
      'count': '1次',
      'cardNo': 'MC20240401004',
      'status': 'success',
    },
    {
      'time': '10:20',
      'memberName': '孙悦',
      'service': '身体SPA',
      'count': '1次',
      'cardNo': 'MC20240520007',
      'status': 'success',
    },
    {
      'time': '09:30',
      'memberName': '周雪',
      'service': '面部护理',
      'count': '1次',
      'cardNo': 'MC20240601008',
      'status': 'success',
    },
  ];

  // Mock 核销码对应的模拟结果
  final Map<String, Map<String, dynamic>> _mockResults = {
    'VERIFY001': {
      'memberName': '李美丽',
      'memberPhone': '138****5678',
      'cardNo': 'MC20240601001',
      'cardType': '次卡',
      'cardName': '面部护理10次卡',
      'service': '面部护理',
      'totalCount': 10,
      'usedCount': 2,
      'remainingCount': 8,
      'validDate': '2024-12-31',
      'avatar': '李',
      'avatarColor': Color(0xFF0052D9),
    },
    'VERIFY002': {
      'memberName': '王芳',
      'memberPhone': '139****1234',
      'cardNo': 'MC20240515002',
      'cardType': '储值卡',
      'cardName': 'VIP储值卡',
      'service': '精油按摩',
      'balance': 1280.00,
      'servicePrice': 198.00,
      'validDate': '2025-06-15',
      'avatar': '王',
      'avatarColor': Color(0xFF7B61FF),
    },
  };

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _handleScan() {
    // 模拟扫码结果
    _codeController.text = 'VERIFY001';
    _handleQuery();
  }

  void _handleQuery() {
    if (_codeController.text.trim().isEmpty) {
      _showToast('请输入核销码');
      return;
    }

    setState(() {
      _isQuerying = true;
      _showResult = false;
    });

    // 模拟查询延迟
    Future.delayed(const Duration(milliseconds: 800), () {
      final code = _codeController.text.trim();
      final result = _mockResults[code];

      setState(() {
        _isQuerying = false;
        if (result != null) {
          _verifyResult = result;
          _showResult = true;
        } else {
          _showResult = false;
          _showToast('未找到对应核销码信息');
        }
      });
    });
  }

  void _handleConfirmVerify() {
    if (_verifyResult == null) return;

    // 模拟确认核销
    _showToast('核销成功！');

    setState(() {
      _todayRecords.insert(0, {
        'time': '${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}',
        'memberName': _verifyResult!['memberName'],
        'service': _verifyResult!['service'],
        'count': '1次',
        'cardNo': _verifyResult!['cardNo'],
        'status': 'success',
      });
      _showResult = false;
      _verifyResult = null;
      _codeController.clear();
    });
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

  @override
  Widget build(BuildContext context) {
    final spacing = ResponsiveHelper.spacing(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          '消费核销',
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
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(spacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 扫码区域
            _buildScanSection(spacing),
            SizedBox(height: spacing),

            // 手动输入区域
            _buildManualInputSection(spacing),
            SizedBox(height: spacing),

            // 核销结果卡片
            if (_isQuerying) _buildLoadingIndicator(),
            if (_showResult && _verifyResult != null)
              _buildVerifyResultCard(spacing),
            if (_showResult && _verifyResult != null) SizedBox(height: spacing),

            // 今日核销记录
            _buildTodayRecordsSection(spacing),
          ],
        ),
      ),
    );
  }

  Widget _buildScanSection(double spacing) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 24.h),
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
          // 扫码大按钮
          GestureDetector(
            onTap: _handleScan,
            child: Container(
              width: 120.r,
              height: 120.r,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0052D9), Color(0xFF003CAB)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24.r),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0052D9).withOpacity(0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.qr_code_scanner,
                    color: Colors.white,
                    size: 48.sp,
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    '扫码核销',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            '点击上方按钮扫描会员卡二维码',
            style: TextStyle(
              fontSize: 13.sp,
              color: const Color(0xFF86909C),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManualInputSection(double spacing) {
    return Container(
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
          Row(
            children: [
              Icon(Icons.keyboard, size: 18.sp, color: const Color(0xFF0052D9)),
              SizedBox(width: 6.w),
              Text(
                '手动输入核销码',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1D2129),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 48.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F7FA),
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: const Color(0xFFE5E6EB)),
                  ),
                  child: TextField(
                    controller: _codeController,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: const Color(0xFF1D2129),
                    ),
                    decoration: InputDecoration(
                      hintText: '请输入核销码，如 VERIFY001',
                      hintStyle: TextStyle(
                        fontSize: 13.sp,
                        color: const Color(0xFFC9CDD4),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16.w),
                      border: InputBorder.none,
                    ),
                    onSubmitted: (_) => _handleQuery(),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              SizedBox(
                width: 88.w,
                height: 48.h,
                child: ElevatedButton(
                  onPressed: _isQuerying ? null : _handleQuery,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0052D9),
                    disabledBackgroundColor: const Color(0xFFB8C4D4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    elevation: 0,
                  ),
                  child: _isQuerying
                      ? SizedBox(
                          width: 20.r,
                          height: 20.r,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          '查询',
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0052D9)),
        ),
      ),
    );
  }

  Widget _buildVerifyResultCard(double spacing) {
    final result = _verifyResult!;
    final isTimesCard = result['cardType'] == '次卡';
    final avatarColor = result['avatarColor'] as Color;

    return Container(
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
          // 顶部标题
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: const BoxDecoration(
              color: Color(0xFF0052D9),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 20.sp),
                SizedBox(width: 8.w),
                Text(
                  '核销信息确认',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          // 会员信息
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              children: [
                // 会员基本信息
                Row(
                  children: [
                    Container(
                      width: 48.r,
                      height: 48.r,
                      decoration: BoxDecoration(
                        color: avatarColor,
                        borderRadius: BorderRadius.circular(24.r),
                      ),
                      child: Center(
                        child: Text(
                          result['avatar'] as String,
                          style: TextStyle(
                            fontSize: 18.sp,
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
                            result['memberName'] as String,
                            style: TextStyle(
                              fontSize: 17.sp,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1D2129),
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            result['memberPhone'] as String,
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: const Color(0xFF86909C),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0052D9).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        result['cardType'] as String,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: const Color(0xFF0052D9),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 16.h),

                // 详细信息网格
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F7FA),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Column(
                    children: [
                      _buildResultRow('卡号', result['cardNo'] as String),
                      SizedBox(height: 10.h),
                      _buildResultRow('卡名称', result['cardName'] as String),
                      SizedBox(height: 10.h),
                      _buildResultRow('服务项目', result['service'] as String),
                      SizedBox(height: 10.h),
                      if (isTimesCard) ...[
                        _buildResultRow(
                          '剩余次数',
                          '${result['remainingCount']}次',
                          valueColor: const Color(0xFF0052D9),
                          showProgress: true,
                          used: result['usedCount'] as int,
                          total: result['totalCount'] as int,
                        ),
                      ] else ...[
                        _buildResultRow(
                          '当前余额',
                          '¥${(result['balance'] as double).toStringAsFixed(2)}',
                          valueColor: const Color(0xFF0052D9),
                        ),
                        SizedBox(height: 10.h),
                        _buildResultRow(
                          '本次消费',
                          '¥${(result['servicePrice'] as double).toStringAsFixed(2)}',
                          valueColor: const Color(0xFFE34D59),
                        ),
                      ],
                      SizedBox(height: 10.h),
                      _buildResultRow('有效期至', result['validDate'] as String),
                    ],
                  ),
                ),

                SizedBox(height: 20.h),

                // 确认核销按钮
                SizedBox(
                  width: double.infinity,
                  height: 52.h,
                  child: ElevatedButton(
                    onPressed: _handleConfirmVerify,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0052D9),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_outline,
                            color: Colors.white, size: 20.sp),
                        SizedBox(width: 8.w),
                        Text(
                          '确认核销',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultRow(
    String label,
    String value, {
    Color? valueColor,
    bool showProgress = false,
    int? used,
    int? total,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13.sp,
            color: const Color(0xFF86909C),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: valueColor ?? const Color(0xFF1D2129),
              ),
            ),
            if (showProgress && used != null && total != null) ...[
              SizedBox(height: 4.h),
              SizedBox(
                width: 120.w,
                height: 4.h,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(2.r),
                  child: LinearProgressIndicator(
                    value: used / total,
                    backgroundColor: const Color(0xFFE5E6EB),
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Color(0xFF0052D9)),
                  ),
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                '已使用 $used/$total 次',
                style: TextStyle(
                  fontSize: 11.sp,
                  color: const Color(0xFFC9CDD4),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildTodayRecordsSection(double spacing) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.history, size: 18.sp, color: const Color(0xFF0052D9)),
                SizedBox(width: 6.w),
                Text(
                  '今日核销记录',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1D2129),
                  ),
                ),
              ],
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: const Color(0xFF0052D9).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                '共${_todayRecords.length}条',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: const Color(0xFF0052D9),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        ..._todayRecords.map((record) => _buildRecordItem(record)),
      ],
    );
  }

  Widget _buildRecordItem(Map<String, dynamic> record) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
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
          // 时间
          Container(
            width: 52.w,
            child: Text(
              record['time'] as String,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1D2129),
              ),
            ),
          ),
          // 分隔线
          Container(
            width: 1,
            height: 36.h,
            color: const Color(0xFFE5E6EB),
          ),
          SizedBox(width: 12.w),
          // 信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      record['memberName'] as String,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
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
                        color: const Color(0xFF00A870).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(3.r),
                      ),
                      child: Text(
                        record['service'] as String,
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: const Color(0xFF00A870),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Text(
                  '卡号: ${record['cardNo']}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: const Color(0xFFC9CDD4),
                  ),
                ),
              ],
            ),
          ),
          // 次数
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F7FA),
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Text(
              record['count'] as String,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF0052D9),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
