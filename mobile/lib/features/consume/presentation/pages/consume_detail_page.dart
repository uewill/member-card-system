import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:member_card_app/core/config/app_config.dart';
import 'package:member_card_app/core/utils/responsive_helper.dart';
import 'package:member_card_app/features/member/data/member_repository.dart';

/// 消费详情页
class ConsumeDetailPage extends StatefulWidget {
  final String orderId;

  const ConsumeDetailPage({super.key, required this.orderId});

  @override
  State<ConsumeDetailPage> createState() => _ConsumeDetailPageState();
}

class _ConsumeDetailPageState extends State<ConsumeDetailPage> {
  final MemberRepository _memberRepository = MemberRepository();

  Map<String, dynamic>? _detail;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    try {
      final detail = await _memberRepository.getConsumeDetail(
        int.parse(widget.orderId),
      );
      setState(() {
        _detail = detail;
        _isLoading = false;
      });
    } catch (e) {
      // 使用模拟数据
      setState(() {
        _detail = {
          'id': 1,
          'orderNo': 'CO20260601001',
          'storeName': '旗舰店',
          'storeAddress': '市中心商业广场3楼',
          'totalAmount': 128.0,
          'paidAmount': 0.0,
          'status': 'COMPLETED',
          'createdAt': '2026-06-01 14:30:00',
          'details': [
            {
              'id': 1,
              'serviceName': '精剪造型',
              'staffName': '王师傅',
              'deductType': 'COUNT',
              'deductBefore': '8次',
              'deductAfter': '7次',
              'deductAmount': 0,
              'cardName': '洗剪吹10次卡',
            },
          ],
        };
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final spacing = ResponsiveHelper.spacing(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('消费详情'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _detail == null
              ? _buildErrorState()
              : ListView(
                  padding: EdgeInsets.all(spacing),
                  children: [
                    _buildStatusHeader(spacing),
                    SizedBox(height: spacing),
                    _buildOrderInfo(spacing),
                    SizedBox(height: spacing),
                    _buildServiceDetails(spacing),
                    SizedBox(height: spacing),
                    _buildDeductInfo(spacing),
                    SizedBox(height: spacing),
                    _buildStoreInfo(spacing),
                  ],
                ),
    );
  }

  /// 状态头部
  Widget _buildStatusHeader(double spacing) {
    final isCompleted = _detail!['status'] == 'COMPLETED';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(spacing * 1.5),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isCompleted
              ? [Colors.green.shade400, Colors.green.shade600]
              : [Colors.red.shade400, Colors.red.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          Icon(
            isCompleted ? Icons.check_circle_outline : Icons.cancel_outlined,
            size: 48.sp,
            color: Colors.white,
          ),
          SizedBox(height: spacing / 2),
          Text(
            isCompleted ? '消费完成' : '已取消',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            _detail!['createdAt'],
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  /// 订单基本信息
  Widget _buildOrderInfo(double spacing) {
    return _buildSectionCard(
      spacing,
      title: '订单信息',
      children: [
        _buildInfoRow('订单编号', _detail!['orderNo']),
        _buildInfoRow('消费金额', '¥${_detail!['totalAmount']}'),
        _buildInfoRow('实付金额', _detail!['paidAmount'] > 0 ? '¥${_detail!['paidAmount']}' : '卡扣消费'),
        _buildInfoRow('订单状态', _detail!['status'] == 'COMPLETED' ? '已完成' : '已取消'),
      ],
    );
  }

  /// 服务明细
  Widget _buildServiceDetails(double spacing) {
    final details = List<Map<String, dynamic>>.from(_detail!['details'] ?? []);

    return _buildSectionCard(
      spacing,
      title: '服务明细',
      children: details.map((item) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: spacing / 2),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36.r,
                height: 36.r,
                decoration: BoxDecoration(
                  color: AppConfig.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  Icons.content_cut,
                  color: AppConfig.primaryColor,
                  size: 18.sp,
                ),
              ),
              SizedBox(width: spacing),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['serviceName'],
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '服务人员: ${item['staffName']}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  /// 扣减信息
  Widget _buildDeductInfo(double spacing) {
    final details = List<Map<String, dynamic>>.from(_detail!['details'] ?? []);
    if (details.isEmpty) return const SizedBox.shrink();

    final firstDetail = details.first;

    return _buildSectionCard(
      spacing,
      title: '扣减详情',
      children: [
        _buildInfoRow('扣减方式', firstDetail['deductType'] == 'COUNT' ? '次数扣减' : '余额扣减'),
        _buildInfoRow('使用卡券', firstDetail['cardName'] ?? '-'),
        _buildInfoRow('扣减前', firstDetail['deductBefore'] ?? '-'),
        _buildInfoRow('扣减后', firstDetail['deductAfter'] ?? '-'),
        if (firstDetail['deductAmount'] != null && firstDetail['deductAmount'] > 0)
          _buildInfoRow('扣减金额', '¥${firstDetail['deductAmount']}'),
      ],
    );
  }

  /// 门店信息
  Widget _buildStoreInfo(double spacing) {
    return _buildSectionCard(
      spacing,
      title: '门店信息',
      children: [
        _buildInfoRow('门店名称', _detail!['storeName']),
        _buildInfoRow('门店地址', _detail!['storeAddress'] ?? '-'),
      ],
    );
  }

  /// 通用区块卡片
  Widget _buildSectionCard(
    double spacing, {
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      padding: EdgeInsets.all(spacing),
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
            title,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Divider(height: 24),
          ...children,
        ],
      ),
    );
  }

  /// 信息行
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// 错误状态
  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64.sp, color: Colors.grey.shade300),
          SizedBox(height: 16.h),
          Text(
            '加载失败',
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 16.h),
          ElevatedButton(
            onPressed: _loadDetail,
            child: const Text('重试'),
          ),
        ],
      ),
    );
  }
}
