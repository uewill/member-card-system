import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:member_card_app/core/config/app_config.dart';
import 'package:member_card_app/core/utils/responsive_helper.dart';
import 'package:member_card_app/features/staff/data/staff_repository.dart';

/// 服务历史页
class ServiceHistoryPage extends StatefulWidget {
  const ServiceHistoryPage({super.key});

  @override
  State<ServiceHistoryPage> createState() => _ServiceHistoryPageState();
}

class _ServiceHistoryPageState extends State<ServiceHistoryPage> {
  final StaffRepository _staffRepository = StaffRepository();

  List<Map<String, dynamic>> _history = [];
  bool _isLoading = true;
  bool _hasMore = true;
  int _currentPage = 1;
  final int _pageSize = 20;

  // 筛选
  String _filterStatus = 'ALL'; // ALL, COMPLETED, CANCELLED
  String? _startDate;
  String? _endDate;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        _currentPage = 1;
        _hasMore = true;
        _isLoading = true;
      });
    }

    try {
      final newRecords = await _staffRepository.getServiceHistory(
        page: _currentPage,
        size: _pageSize,
        startDate: _startDate,
        endDate: _endDate,
        status: _filterStatus == 'ALL' ? null : _filterStatus,
      );

      setState(() {
        if (refresh) {
          _history = newRecords;
        } else {
          _history.addAll(newRecords);
        }
        _hasMore = newRecords.length >= _pageSize;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _history = _generateMockHistory();
        _isLoading = false;
        _hasMore = false;
      });
    }
  }

  List<Map<String, dynamic>> _generateMockHistory() {
    return [
      {
        'id': 1,
        'orderNo': 'CO20260601001',
        'memberName': '张三',
        'memberPhone': '138****8888',
        'serviceName': '精剪造型',
        'amount': 128.0,
        'deductType': 'COUNT',
        'cardName': '洗剪吹10次卡',
        'status': 'COMPLETED',
        'createdAt': '2026-06-01 14:30',
      },
      {
        'id': 2,
        'orderNo': 'CO20260601002',
        'memberName': '李四',
        'memberPhone': '139****6666',
        'serviceName': '染发（棕色）',
        'amount': 256.0,
        'deductType': 'COUNT',
        'cardName': '染烫护理套餐',
        'status': 'COMPLETED',
        'createdAt': '2026-06-01 13:15',
      },
      {
        'id': 3,
        'orderNo': 'CO20260531001',
        'memberName': '王五',
        'memberPhone': '137****5555',
        'serviceName': '头皮护理',
        'amount': 68.0,
        'deductType': 'VALUE',
        'cardName': '储值卡500元',
        'status': 'COMPLETED',
        'createdAt': '2026-05-31 16:00',
      },
      {
        'id': 4,
        'orderNo': 'CO20260531002',
        'memberName': '赵六',
        'memberPhone': '136****4444',
        'serviceName': '烫发（卷发）',
        'amount': 320.0,
        'deductType': 'COUNT',
        'cardName': '染烫护理套餐',
        'status': 'CANCELLED',
        'createdAt': '2026-05-31 10:30',
      },
      {
        'id': 5,
        'orderNo': 'CO20260530001',
        'memberName': '孙七',
        'memberPhone': '135****3333',
        'serviceName': '洗发+剪发',
        'amount': 88.0,
        'deductType': 'VALUE',
        'cardName': '储值卡500元',
        'status': 'COMPLETED',
        'createdAt': '2026-05-30 15:20',
      },
      {
        'id': 6,
        'orderNo': 'CO20260530002',
        'memberName': '周八',
        'memberPhone': '134****2222',
        'serviceName': '精剪造型',
        'amount': 128.0,
        'deductType': 'COUNT',
        'cardName': '洗剪吹10次卡',
        'status': 'COMPLETED',
        'createdAt': '2026-05-30 11:00',
      },
      {
        'id': 7,
        'orderNo': 'CO20260529001',
        'memberName': '吴九',
        'memberPhone': '133****1111',
        'serviceName': '全身SPA',
        'amount': 198.0,
        'deductType': 'COUNT',
        'cardName': '全身SPA套餐',
        'status': 'COMPLETED',
        'createdAt': '2026-05-29 14:00',
      },
      {
        'id': 8,
        'orderNo': 'CO20260529002',
        'memberName': '郑十',
        'memberPhone': '132****0000',
        'serviceName': '护理+造型',
        'amount': 168.0,
        'deductType': 'COUNT',
        'cardName': '染烫护理套餐',
        'status': 'COMPLETED',
        'createdAt': '2026-05-29 09:30',
      },
    ];
  }

  /// 按日期分组
  Map<String, List<Map<String, dynamic>>> _groupByDate() {
    final grouped = <String, List<Map<String, dynamic>>>{};
    for (final item in _history) {
      final dateStr = (item['createdAt'] as String).substring(0, 10);
      grouped.putIfAbsent(dateStr, () => []).add(item);
    }
    return grouped;
  }

  /// 计算某日总营收
  double _calcDayRevenue(List<Map<String, dynamic>> items) {
    return items
        .where((i) => i['status'] == 'COMPLETED')
        .fold(0.0, (sum, i) => sum + ((i['amount'] as num).toDouble()));
  }

  @override
  Widget build(BuildContext context) {
    final spacing = ResponsiveHelper.spacing(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('服务历史'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _history.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: () => _loadHistory(refresh: true),
                  child: ListView.builder(
                    padding: EdgeInsets.all(spacing),
                    itemCount: _groupByDate().keys.length + (_hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      final grouped = _groupByDate();
                      final dateKeys = grouped.keys.toList();

                      if (index == dateKeys.length) {
                        _loadMore();
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      final dateKey = dateKeys[index];
                      final dateItems = grouped[dateKey]!;
                      final dayRevenue = _calcDayRevenue(dateItems);

                      return _buildDateSection(dateKey, dateItems, dayRevenue, spacing);
                    },
                  ),
                ),
    );
  }

  /// 日期分组区域
  Widget _buildDateSection(
    String date,
    List<Map<String, dynamic>> items,
    double dayRevenue,
    double spacing,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: spacing / 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDateLabel(date),
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
              Text(
                '${items.length}单 | ¥${dayRevenue.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
        ...items.map((item) => _buildHistoryItem(item, spacing)),
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

  /// 单条历史记录
  Widget _buildHistoryItem(Map<String, dynamic> item, double spacing) {
    final isCompleted = item['status'] == 'COMPLETED';
    final isCountDeduct = item['deductType'] == 'COUNT';

    return Card(
      margin: EdgeInsets.only(bottom: spacing / 2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(spacing),
        child: Row(
          children: [
            // 状态图标
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
                isCountDeduct ? Icons.event_repeat : Icons.account_balance_wallet,
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
                  Row(
                    children: [
                      Text(
                        item['memberName'],
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        item['memberPhone'],
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    item['serviceName'],
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Row(
                    children: [
                      Icon(Icons.credit_card, size: 12.sp, color: Colors.grey),
                      SizedBox(width: 2.w),
                      Text(
                        item['cardName'] ?? '-',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 金额和时间
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '¥${item['amount']}',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: isCompleted ? Colors.black87 : Colors.grey,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  (item['createdAt'] as String).substring(11),
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 2.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.h),
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
    );
  }

  /// 空状态
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 64.sp, color: Colors.grey.shade300),
          SizedBox(height: 16.h),
          Text(
            '暂无服务记录',
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
      _loadHistory();
    }
  }

  /// 筛选对话框
  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('筛选服务记录'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 状态筛选
            const Text('订单状态'),
            SizedBox(height: 8.h),
            Row(
              children: [
                _buildFilterChip('全部', 'ALL'),
                SizedBox(width: 8.w),
                _buildFilterChip('已完成', 'COMPLETED'),
                SizedBox(width: 8.w),
                _buildFilterChip('已取消', 'CANCELLED'),
              ],
            ),
            const SizedBox(height: 16),
            // 日期筛选
            TextField(
              decoration: const InputDecoration(
                labelText: '开始日期 (YYYY-MM-DD)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.datetime,
            ),
            const SizedBox(height: 12),
            TextField(
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
                _filterStatus = 'ALL';
                _startDate = null;
                _endDate = null;
              });
              Navigator.pop(context);
              _loadHistory(refresh: true);
            },
            child: const Text('重置'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _filterStatus == value;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => _filterStatus = value);
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 8.h),
          decoration: BoxDecoration(
            color: isSelected ? AppConfig.primaryColor : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(6.r),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.sp,
              color: isSelected ? Colors.white : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }
}
