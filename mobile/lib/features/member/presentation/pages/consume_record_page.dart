import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:member_card_app/core/utils/responsive_helper.dart';
import 'package:member_card_app/features/member/data/member_repository.dart';

/// 消费记录页 - 按时间倒序列表
class ConsumeRecordPage extends StatefulWidget {
  const ConsumeRecordPage({super.key});

  @override
  State<ConsumeRecordPage> createState() => _ConsumeRecordPageState();
}

class _ConsumeRecordPageState extends State<ConsumeRecordPage> {
  final MemberRepository _memberRepository = MemberRepository();

  List<Map<String, dynamic>> _records = [];
  bool _isLoading = true;
  bool _hasMore = true;
  int _currentPage = 1;
  final int _pageSize = 20;

  // 筛选条件
  String? _startDate;
  String? _endDate;

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  Future<void> _loadRecords({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        _currentPage = 1;
        _hasMore = true;
        _isLoading = true;
      });
    }

    try {
      final newRecords = await _memberRepository.getConsumeRecords(
        page: _currentPage,
        size: _pageSize,
        startDate: _startDate,
        endDate: _endDate,
      );

      setState(() {
        if (refresh) {
          _records = newRecords;
        } else {
          _records.addAll(newRecords);
        }
        _hasMore = newRecords.length >= _pageSize;
        _isLoading = false;
      });
    } catch (e) {
      // 使用模拟数据
      if (mounted) {
        setState(() {
          _records = _generateMockRecords();
          _isLoading = false;
          _hasMore = false;
        });
      }
    }
  }

  List<Map<String, dynamic>> _generateMockRecords() {
    return [
      {
        'id': 1,
        'orderNo': 'CO20260601001',
        'storeName': '旗舰店',
        'totalAmount': 128.0,
        'paidAmount': 0.0,
        'status': 'COMPLETED',
        'createdAt': '2026-06-01 14:30:00',
        'details': [
          {'serviceName': '精剪造型', 'staffName': '王师傅', 'deductType': 'COUNT', 'deductBefore': '8', 'deductAfter': '7'},
        ],
      },
      {
        'id': 2,
        'orderNo': 'CO20260530002',
        'storeName': '旗舰店',
        'totalAmount': 68.0,
        'paidAmount': 68.0,
        'status': 'COMPLETED',
        'createdAt': '2026-05-30 10:15:00',
        'details': [
          {'serviceName': '头皮护理', 'staffName': '李师傅', 'deductType': 'VALUE', 'deductBefore': '388.0', 'deductAfter': '320.0'},
        ],
      },
      {
        'id': 3,
        'orderNo': 'CO20260528003',
        'storeName': '分店',
        'totalAmount': 256.0,
        'paidAmount': 0.0,
        'status': 'COMPLETED',
        'createdAt': '2026-05-28 16:45:00',
        'details': [
          {'serviceName': '染发', 'staffName': '张师傅', 'deductType': 'COUNT', 'deductBefore': '4', 'deductAfter': '3'},
          {'serviceName': '护理', 'staffName': '张师傅', 'deductType': 'COUNT', 'deductBefore': '4', 'deductAfter': '3'},
        ],
      },
      {
        'id': 4,
        'orderNo': 'CO20260525004',
        'storeName': '旗舰店',
        'totalAmount': 45.0,
        'paidAmount': 45.0,
        'status': 'CANCELLED',
        'createdAt': '2026-05-25 09:20:00',
        'details': [
          {'serviceName': '洗发', 'staffName': '赵师傅', 'deductType': 'VALUE', 'deductBefore': '433.0', 'deductAfter': '388.0'},
        ],
      },
      {
        'id': 5,
        'orderNo': 'CO20260520005',
        'storeName': '旗舰店',
        'totalAmount': 198.0,
        'paidAmount': 0.0,
        'status': 'COMPLETED',
        'createdAt': '2026-05-20 15:00:00',
        'details': [
          {'serviceName': '全身SPA', 'staffName': '刘师傅', 'deductType': 'COUNT', 'deductBefore': '4', 'deductAfter': '3'},
        ],
      },
    ];
  }

  /// 按日期分组记录
  Map<String, List<Map<String, dynamic>>> _groupRecordsByDate() {
    final grouped = <String, List<Map<String, dynamic>>>{};
    for (final record in _records) {
      final dateStr = (record['createdAt'] as String).substring(0, 10);
      grouped.putIfAbsent(dateStr, () => []).add(record);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final spacing = ResponsiveHelper.spacing(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('消费记录'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _records.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: () => _loadRecords(refresh: true),
                  child: ListView.builder(
                    padding: EdgeInsets.all(spacing),
                    itemCount: _groupRecordsByDate().keys.length + (_hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      final grouped = _groupRecordsByDate();
                      final dateKeys = grouped.keys.toList();

                      if (index == dateKeys.length) {
                        // 加载更多
                        _loadMore();
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      final dateKey = dateKeys[index];
                      final dateRecords = grouped[dateKey]!;

                      return _buildDateSection(dateKey, dateRecords, spacing);
                    },
                  ),
                ),
    );
  }

  /// 按日期分组展示
  Widget _buildDateSection(String date, List<Map<String, dynamic>> records, double spacing) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: spacing / 2),
          child: Text(
            _formatDateLabel(date),
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
        ),
        ...records.map((record) => _buildRecordItem(record, spacing)),
      ],
    );
  }

  String _formatDateLabel(String dateStr) {
    final today = DateTime.now();
    final parts = dateStr.split('-');
    final date = DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
    final todayDate = DateTime(today.year, today.month, today.day);
    final yesterday = todayDate.subtract(const Duration(days: 1));

    if (date == todayDate) return '今天';
    if (date == yesterday) return '昨天';
    return dateStr;
  }

  /// 单条消费记录
  Widget _buildRecordItem(Map<String, dynamic> record, double spacing) {
    final isCompleted = record['status'] == 'COMPLETED';
    final details = List<Map<String, dynamic>>.from(record['details'] ?? []);
    final isCardDeduct = details.isNotEmpty && details.first['deductType'] == 'COUNT';

    return Card(
      margin: EdgeInsets.only(bottom: spacing / 2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: InkWell(
        onTap: () => context.push('/member/consume-records/${record['id']}'),
        borderRadius: BorderRadius.circular(8.r),
        child: Padding(
          padding: EdgeInsets.all(spacing),
          child: Row(
            children: [
              // 图标
              Container(
                width: 40.r,
                height: 40.r,
                decoration: BoxDecoration(
                  color: isCompleted
                      ? Colors.green.withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  isCardDeduct ? Icons.event_repeat : Icons.account_balance_wallet,
                  color: isCompleted ? Colors.green : Colors.red,
                  size: 20.sp,
                ),
              ),
              SizedBox(width: spacing),

              // 信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      details.isNotEmpty
                          ? details.map((d) => d['serviceName']).join(' + ')
                          : '消费服务',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Text(
                          record['storeName'] ?? '',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          (record['createdAt'] as String).substring(11, 16),
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // 金额
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    record['paidAmount'] > 0
                        ? '-¥${record['paidAmount']}'
                        : '卡扣',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: isCompleted ? Colors.black87 : Colors.grey,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? Colors.green.withOpacity(0.1)
                          : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text(
                      isCompleted ? '已完成' : '已取消',
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: isCompleted ? Colors.green : Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 空状态
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long, size: 64.sp, color: Colors.grey.shade300),
          SizedBox(height: 16.h),
          Text(
            '暂无消费记录',
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  /// 加载更多
  void _loadMore() {
    if (_hasMore && !_isLoading) {
      _currentPage++;
      _loadRecords();
    }
  }

  /// 筛选对话框
  void _showFilterDialog() {
    final startDateController = TextEditingController(text: _startDate ?? '');
    final endDateController = TextEditingController(text: _endDate ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('筛选消费记录'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: startDateController,
              decoration: const InputDecoration(
                labelText: '开始日期 (YYYY-MM-DD)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.datetime,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: endDateController,
              decoration: const InputDecoration(
                labelText: '结束日期 (YYYY-MM-DD)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.datetime,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _startDate = null;
                _endDate = null;
              });
              Navigator.pop(context);
              _loadRecords(refresh: true);
            },
            child: const Text('清除筛选'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _startDate = startDateController.text.isNotEmpty ? startDateController.text : null;
                _endDate = endDateController.text.isNotEmpty ? endDateController.text : null;
              });
              Navigator.pop(context);
              _loadRecords(refresh: true);
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}
