import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:member_card_app/core/config/app_config.dart';
import 'package:member_card_app/core/utils/responsive_helper.dart';
import 'package:member_card_app/features/staff/data/staff_repository.dart';

/// 业绩详情页 - 日/周/月切换
class PerformancePage extends StatefulWidget {
  const PerformancePage({super.key});

  @override
  State<PerformancePage> createState() => _PerformancePageState();
}

class _PerformancePageState extends State<PerformancePage> {
  final StaffRepository _staffRepository = StaffRepository();

  String _selectedPeriod = 'day'; // day, week, month
  Map<String, dynamic>? _performance;
  List<Map<String, dynamic>> _rankList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPerformance();
  }

  Future<void> _loadPerformance() async {
    setState(() => _isLoading = true);

    try {
      final results = await Future.wait([
        _staffRepository.getPerformance(period: _selectedPeriod),
        _staffRepository.getPerformanceRank(period: _selectedPeriod),
      ]);

      setState(() {
        _performance = results[0] as Map<String, dynamic>;
        _rankList = List<Map<String, dynamic>>.from(results[1] as List);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _performance = _generateMockPerformance();
        _rankList = _generateMockRankList();
        _isLoading = false;
      });
    }
  }

  Map<String, dynamic> _generateMockPerformance() {
    switch (_selectedPeriod) {
      case 'day':
        return {
          'period': '2026-06-01',
          'totalServiceCount': 8,
          'totalRevenue': 1280.0,
          'cardDeductCount': 5,
          'cashRevenue': 480.0,
          'newMembers': 2,
          'averageAmount': 160.0,
          'hourlyStats': [
            {'hour': '09:00', 'count': 1, 'revenue': 68.0},
            {'hour': '10:00', 'count': 2, 'revenue': 256.0},
            {'hour': '11:00', 'count': 1, 'revenue': 128.0},
            {'hour': '13:00', 'count': 1, 'revenue': 68.0},
            {'hour': '14:00', 'count': 2, 'revenue': 384.0},
            {'hour': '16:00', 'count': 1, 'revenue': 376.0},
          ],
        };
      case 'week':
        return {
          'period': '2026年第22周',
          'totalServiceCount': 42,
          'totalRevenue': 6720.0,
          'cardDeductCount': 28,
          'cashRevenue': 2400.0,
          'newMembers': 8,
          'averageAmount': 160.0,
          'dailyStats': [
            {'day': '周一', 'count': 6, 'revenue': 960.0},
            {'day': '周二', 'count': 5, 'revenue': 800.0},
            {'day': '周三', 'count': 7, 'revenue': 1120.0},
            {'day': '周四', 'count': 6, 'revenue': 960.0},
            {'day': '周五', 'count': 8, 'revenue': 1280.0},
            {'day': '周六', 'count': 7, 'revenue': 1120.0},
            {'day': '周日', 'count': 3, 'revenue': 480.0},
          ],
        };
      case 'month':
        return {
          'period': '2026年6月',
          'totalServiceCount': 156,
          'totalRevenue': 24560.0,
          'cardDeductCount': 98,
          'cashRevenue': 8800.0,
          'newMembers': 32,
          'averageAmount': 157.4,
          'target': 30000.0,
          'weeklyStats': [
            {'week': '第1周', 'count': 38, 'revenue': 6080.0},
            {'week': '第2周', 'count': 42, 'revenue': 6720.0},
            {'week': '第3周', 'count': 40, 'revenue': 6400.0},
            {'week': '第4周', 'count': 36, 'revenue': 5360.0},
          ],
        };
      default:
        return {};
    }
  }

  List<Map<String, dynamic>> _generateMockRankList() {
    return [
      {'rank': 1, 'name': '张师傅', 'revenue': 3580.0, 'count': 22},
      {'rank': 2, 'name': '李师傅', 'revenue': 2960.0, 'count': 18},
      {'rank': 3, 'name': '王师傅', 'revenue': 1280.0, 'count': 8},
      {'rank': 4, 'name': '赵师傅', 'revenue': 960.0, 'count': 6},
      {'rank': 5, 'name': '刘师傅', 'revenue': 640.0, 'count': 4},
    ];
  }

  @override
  Widget build(BuildContext context) {
    final spacing = ResponsiveHelper.spacing(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('业绩详情'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: EdgeInsets.all(spacing),
              children: [
                _buildPeriodSelector(spacing),
                SizedBox(height: spacing),
                _buildRevenueOverview(spacing),
                SizedBox(height: spacing),
                _buildDetailStats(spacing),
                SizedBox(height: spacing),
                _buildChartSection(spacing),
                SizedBox(height: spacing),
                _buildRankSection(spacing),
              ],
            ),
    );
  }

  /// 日/周/月切换
  Widget _buildPeriodSelector(double spacing) {
    final periods = [
      {'value': 'day', 'label': '日'},
      {'value': 'week', 'label': '周'},
      {'value': 'month', 'label': '月'},
    ];

    return Container(
      padding: EdgeInsets.all(4.r),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: periods.map((p) {
          final isSelected = _selectedPeriod == p['value'];
          return Expanded(
            child: GestureDetector(
              onTap: () {
                if (_selectedPeriod != p['value']) {
                  setState(() => _selectedPeriod = p['value'] as String);
                  _loadPerformance();
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(vertical: 8.h),
                decoration: BoxDecoration(
                  color: isSelected ? AppConfig.primaryColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  p['label'] as String,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? Colors.white : Colors.grey,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// 营收概览
  Widget _buildRevenueOverview(double spacing) {
    final totalRevenue = (_performance?['totalRevenue'] ?? 0.0) as num;
    final target = (_performance?['target'] ?? totalRevenue * 1.2) as num;
    final progress = (totalRevenue / target).clamp(0.0, 1.0);

    return Container(
      padding: EdgeInsets.all(spacing * 1.5),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppConfig.primaryColor,
            AppConfig.primaryColor.withOpacity(0.85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          Text(
            _performance?['period'] ?? '',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.white70,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            '¥${totalRevenue.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: 36.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            '总营收',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.white70,
            ),
          ),
          if (_selectedPeriod == 'month') ...[
            SizedBox(height: spacing),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '目标 ¥${target.toStringAsFixed(0)}',
                  style: TextStyle(fontSize: 12.sp, color: Colors.white70),
                ),
                Text(
                  '${(progress * 100).toStringAsFixed(1)}%',
                  style: TextStyle(fontSize: 12.sp, color: Colors.white70),
                ),
              ],
            ),
            SizedBox(height: 4.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(4.r),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6.h,
                backgroundColor: Colors.white24,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 详细统计
  Widget _buildDetailStats(double spacing) {
    final stats = [
      {
        'label': '服务单数',
        'value': '${_performance?['totalServiceCount'] ?? 0}单',
        'icon': Icons.receipt,
        'color': Colors.blue,
      },
      {
        'label': '卡扣单数',
        'value': '${_performance?['cardDeductCount'] ?? 0}单',
        'icon': Icons.credit_card,
        'color': Colors.purple,
      },
      {
        'label': '现金收入',
        'value': '¥${_performance?['cashRevenue'] ?? 0}',
        'icon': Icons.payments,
        'color': Colors.orange,
      },
      {
        'label': '新客数',
        'value': '${_performance?['newMembers'] ?? 0}人',
        'icon': Icons.person_add,
        'color': Colors.green,
      },
      {
        'label': '客单价',
        'value': '¥${_performance?['averageAmount'] ?? 0}',
        'icon': Icons.trending_up,
        'color': Colors.teal,
      },
    ];

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
            '详细统计',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: spacing),
          Wrap(
            spacing: spacing,
            runSpacing: spacing,
            children: stats.map((stat) {
              return SizedBox(
                width: (MediaQuery.of(context).size.width - spacing * 4) / 3,
                child: Column(
                  children: [
                    Icon(stat['icon'] as IconData, color: stat['color'] as Color, size: 24.sp),
                    SizedBox(height: 4.h),
                    Text(
                      stat['value'] as String,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: stat['color'] as Color,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      stat['label'] as String,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  /// 图表区域（简易柱状图）
  Widget _buildChartSection(double spacing) {
    final List<Map<String, dynamic>> chartData;
    String xLabel;

    switch (_selectedPeriod) {
      case 'day':
        chartData = List<Map<String, dynamic>>.from(_performance?['hourlyStats'] ?? []);
        xLabel = '时段';
        break;
      case 'week':
        chartData = List<Map<String, dynamic>>.from(_performance?['dailyStats'] ?? []);
        xLabel = '日期';
        break;
      case 'month':
        chartData = List<Map<String, dynamic>>.from(_performance?['weeklyStats'] ?? []);
        xLabel = '周';
        break;
      default:
        chartData = [];
        xLabel = '';
    }

    if (chartData.isEmpty) return const SizedBox.shrink();

    final maxRevenue = chartData.map((d) => (d['revenue'] as num).toDouble()).reduce((a, b) => a > b ? a : b);

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
            '营收趋势',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: spacing),
          SizedBox(
            height: 150.h,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: chartData.map((data) {
                final revenue = (data['revenue'] as num).toDouble();
                final height = (revenue / maxRevenue * 120).h;
                final label = _selectedPeriod == 'day'
                    ? (data['hour'] as String).substring(0, 2)
                    : (data[_selectedPeriod == 'week' ? 'day' : 'week'] as String);

                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 2.w),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '¥${revenue.toInt()}',
                          style: TextStyle(fontSize: 9.sp, color: Colors.grey),
                        ),
                        SizedBox(height: 2.h),
                        Container(
                          height: height,
                          decoration: BoxDecoration(
                            color: AppConfig.primaryColor,
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(4.r),
                            ),
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          label,
                          style: TextStyle(fontSize: 10.sp, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  /// 排行榜
  Widget _buildRankSection(double spacing) {
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
            '业绩排行',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: spacing / 2),
          ..._rankList.map((item) => _buildRankItem(item, spacing)),
        ],
      ),
    );
  }

  Widget _buildRankItem(Map<String, dynamic> item, double spacing) {
    final rank = item['rank'] as int;
    final isTop3 = rank <= 3;
    final isMe = item['name'] == '王师傅';

    return Container(
      margin: EdgeInsets.only(bottom: spacing / 2),
      padding: EdgeInsets.all(spacing * 0.75),
      decoration: BoxDecoration(
        color: isMe ? AppConfig.primaryColor.withOpacity(0.08) : Colors.transparent,
        borderRadius: BorderRadius.circular(8.r),
        border: isMe ? Border.all(color: AppConfig.primaryColor.withOpacity(0.3)) : null,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 28.r,
            child: Text(
              '$rank',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: isTop3 ? Colors.orange : Colors.grey,
              ),
            ),
          ),
          SizedBox(width: spacing),
          Expanded(
            child: Text(
              '${item['name']}${isMe ? ' (我)' : ''}',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: isMe ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          Text(
            '${item['count']}单',
            style: TextStyle(
              fontSize: 13.sp,
              color: Colors.grey,
            ),
          ),
          SizedBox(width: spacing),
          Text(
            '¥${item['revenue']}',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: AppConfig.primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}
