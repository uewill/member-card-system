import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:member_card_app/core/utils/responsive_helper.dart';

/// 业绩统计页 - 商务专业风格
class PerformancePage extends StatefulWidget {
  const PerformancePage({super.key});

  @override
  State<PerformancePage> createState() => _PerformancePageState();
}

class _PerformancePageState extends State<PerformancePage> {
  int _selectedPeriod = 0; // 0:今日 1:本周 2:本月 3:自定义

  final List<String> _periods = ['今日', '本周', '本月', '自定义'];

  // Mock 数据 - 各时段业绩
  final Map<int, Map<String, dynamic>> _periodData = {
    0: {'revenue': '¥3,280', 'service': '18', 'newMember': '3', 'recharge': '¥5,000'},
    1: {'revenue': '¥18,650', 'service': '96', 'newMember': '15', 'recharge': '¥22,000'},
    2: {'revenue': '¥72,400', 'service': '386', 'newMember': '58', 'recharge': '¥85,000'},
    3: {'revenue': '¥0', 'service': '0', 'newMember': '0', 'recharge': '¥0'},
  };

  // Mock 柱状图数据（近7天营收，单位：元）
  final List<Map<String, dynamic>> _chartData = [
    {'label': '周一', 'value': 2800, 'height': 0.56},
    {'label': '周二', 'value': 3200, 'height': 0.64},
    {'label': '周三', 'value': 2500, 'height': 0.50},
    {'label': '周四', 'value': 3800, 'height': 0.76},
    {'label': '周五', 'value': 4200, 'height': 0.84},
    {'label': '周六', 'value': 5000, 'height': 1.00},
    {'label': '周日', 'value': 3280, 'height': 0.66},
  ];

  // Mock 员工业绩排行
  final List<Map<String, dynamic>> _rankList = [
    {'name': '张美容', 'avatar': 'ZM', 'color': const Color(0xFF0052D9), 'orders': 8, 'revenue': '¥1,680', 'commission': '¥336'},
    {'name': '王技师', 'avatar': 'WJ', 'color': const Color(0xFF00A870), 'orders': 6, 'revenue': '¥980', 'commission': '¥196'},
    {'name': '李美甲', 'avatar': 'LM', 'color': const Color(0xFFED7B2F), 'orders': 4, 'revenue': '¥620', 'commission': '¥124'},
  ];

  @override
  Widget build(BuildContext context) {
    final spacing = ResponsiveHelper.spacing(context);
    final currentData = _periodData[_selectedPeriod]!;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('业绩统计'),
        backgroundColor: const Color(0xFF0052D9),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(spacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 时间段切换
            _buildPeriodSelector(spacing),

            SizedBox(height: spacing),

            // 核心指标卡片
            _buildMetricCards(currentData, spacing),

            SizedBox(height: spacing),

            // 业绩趋势图
            _buildTrendChart(spacing),

            SizedBox(height: spacing),

            // 员工业绩排行
            _buildRankList(spacing),

            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }

  /// 时间段切换
  Widget _buildPeriodSelector(double spacing) {
    return Container(
      padding: EdgeInsets.all(4.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: List.generate(_periods.length, (index) {
          final isSelected = _selectedPeriod == index;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() => _selectedPeriod = index);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(vertical: 10.h),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF0052D9) : Colors.transparent,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  _periods[index],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: isSelected ? Colors.white : const Color(0xFF4E5969),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  /// 核心指标卡片
  Widget _buildMetricCards(Map<String, dynamic> data, double spacing) {
    final cards = [
      {'label': '总营收', 'value': data['revenue'], 'icon': Icons.paid, 'color': const Color(0xFF0052D9)},
      {'label': '服务人次', 'value': '${data['service']}人', 'icon': Icons.people, 'color': const Color(0xFF00A870)},
      {'label': '新增会员', 'value': '${data['newMember']}人', 'icon': Icons.person_add, 'color': const Color(0xFFED7B2F)},
      {'label': '充值金额', 'value': data['recharge'], 'icon': Icons.account_balance_wallet, 'color': const Color(0xFF7B61FF)},
    ];

    return Row(
      children: List.generate(cards.length, (index) {
        final card = cards[index];
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: index < 3 ? 8.w : 0),
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 16.h),
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
                Container(
                  width: 36.r,
                  height: 36.r,
                  decoration: BoxDecoration(
                    color: (card['color'] as Color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(
                    card['icon'] as IconData,
                    color: card['color'] as Color,
                    size: 20.sp,
                  ),
                ),
                SizedBox(height: 10.h),
                Text(
                  card['value'] as String,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1D2129),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  card['label'] as String,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: const Color(0xFF86909C),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  /// 业绩趋势柱状图
  Widget _buildTrendChart(double spacing) {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '业绩趋势',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1D2129),
                ),
              ),
              Text(
                '近7天',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: const Color(0xFF86909C),
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          // 柱状图区域
          SizedBox(
            height: 160.h,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: _chartData.map((item) {
                return _buildChartBar(item);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartBar(Map<String, dynamic> item) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          '¥${(item['value'] as int).toString()}',
          style: TextStyle(
            fontSize: 10.sp,
            color: const Color(0xFF86909C),
          ),
        ),
        SizedBox(height: 6.h),
        Container(
          width: 28.w,
          height: (item['height'] as double) * 100.h,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0052D9), Color(0xFF3D7AFF)],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
            borderRadius: BorderRadius.circular(6.r),
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          item['label'] as String,
          style: TextStyle(
            fontSize: 11.sp,
            color: const Color(0xFF86909C),
          ),
        ),
      ],
    );
  }

  /// 员工业绩排行
  Widget _buildRankList(double spacing) {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '员工业绩排行',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1D2129),
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: Text(
                  '查看全部',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: const Color(0xFF0052D9),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          // 表头
          Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 8.h),
            child: Row(
              children: [
                SizedBox(width: 48.w),
                SizedBox(width: 60.w, child: Text('姓名', style: TextStyle(fontSize: 12.sp, color: const Color(0xFF86909C)))),
                const Spacer(),
                SizedBox(width: 50.w, child: Text('服务数', style: TextStyle(fontSize: 12.sp, color: const Color(0xFF86909C)), textAlign: TextAlign.center)),
                SizedBox(width: 60.w, child: Text('营收', style: TextStyle(fontSize: 12.sp, color: const Color(0xFF86909C)), textAlign: TextAlign.center)),
                SizedBox(width: 60.w, child: Text('提成', style: TextStyle(fontSize: 12.sp, color: const Color(0xFF86909C)), textAlign: TextAlign.center)),
              ],
            ),
          ),
          Divider(height: 1.h, color: const Color(0xFFF2F3F5)),
          // 排行列表
          ...List.generate(_rankList.length, (index) {
            final item = _rankList[index];
            return _buildRankItem(item, index);
          }),
        ],
      ),
    );
  }

  Widget _buildRankItem(Map<String, dynamic> item, int index) {
    return Container(
      margin: EdgeInsets.only(top: 12.h),
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 8.h),
      child: Row(
        children: [
          // 排名头像
          SizedBox(
            width: 48.w,
            child: Row(
              children: [
                // 排名序号
                Container(
                  width: 20.r,
                  height: 20.r,
                  decoration: BoxDecoration(
                    color: index == 0
                        ? const Color(0xFFFFBA00)
                        : index == 1
                            ? const Color(0xFFC0C0C0)
                            : const Color(0xFFCD7F32),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                // 头像
                Container(
                  width: 32.r,
                  height: 32.r,
                  decoration: BoxDecoration(
                    color: (item['color'] as Color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Center(
                    child: Text(
                      item['avatar'] as String,
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.bold,
                        color: item['color'] as Color,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // 姓名
          SizedBox(
            width: 60.w,
            child: Text(
              item['name'] as String,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF1D2129),
              ),
            ),
          ),
          const Spacer(),
          // 服务数
          SizedBox(
            width: 50.w,
            child: Text(
              '${item['orders']}单',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.sp,
                color: const Color(0xFF4E5969),
              ),
            ),
          ),
          // 营收
          SizedBox(
            width: 60.w,
            child: Text(
              item['revenue'] as String,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF0052D9),
              ),
            ),
          ),
          // 提成
          SizedBox(
            width: 60.w,
            child: Text(
              item['commission'] as String,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.sp,
                color: const Color(0xFF00A870),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
