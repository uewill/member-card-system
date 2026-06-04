import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:member_card_app/core/utils/responsive_helper.dart';
import 'package:member_card_app/shared/services/api/report_repository.dart';

/// 报表中心页 - 日报/月报/套餐分析/会员分析
class ReportCenterPage extends StatefulWidget {
  const ReportCenterPage({super.key});

  @override
  State<ReportCenterPage> createState() => _ReportCenterPageState();
}

class _ReportCenterPageState extends State<ReportCenterPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ReportRepository _reportRepo = ReportRepository();

  bool _isLoading = false;

  // 日报数据
  Map<String, dynamic> _dailyData = {};
  // 月报数据
  Map<String, dynamic> _monthlyData = {};
  // 套餐销量数据
  List<dynamic> _packageSales = [];
  // 会员分析数据
  Map<String, dynamic> _memberAnalysis = {};

  // 日期选择
  DateTime _selectedDate = DateTime.now();
  DateTime _selectedMonth = DateTime.now();

  // Mock 数据
  final Map<String, dynamic> _mockDaily = {
    'revenue': 3280,
    'consumeCount': 18,
    'wechatPay': 65,
    'alipayPay': 20,
    'cashPay': 10,
    'cardPay': 5,
    'yesterdayRevenue': 2960,
    'yesterdayConsumeCount': 15,
  };

  final Map<String, dynamic> _mockMonthly = {
    'avgDailyRevenue': 3100,
    'totalConsume': 420,
    'newMembers': 28,
    'totalRevenue': 93000,
  };

  final List<Map<String, dynamic>> _mockPackageSales = [
    {'name': '面部护理10次卡', 'sales': 45, 'revenue': 89100, 'expired': 3},
    {'name': '洗剪吹10次卡', 'sales': 38, 'revenue': 75240, 'expired': 5},
    {'name': '精油按摩5次卡', 'sales': 22, 'revenue': 43890, 'expired': 2},
    {'name': '全身SPA 3次卡', 'sales': 15, 'revenue': 44850, 'expired': 1},
    {'name': '美甲套餐6次卡', 'sales': 12, 'revenue': 23760, 'expired': 4},
  ];

  final Map<String, dynamic> _mockMemberAnalysis = {
    'newTrend': [
      {'month': '1月', 'count': 12},
      {'month': '2月', 'count': 8},
      {'month': '3月', 'count': 15},
      {'month': '4月', 'count': 20},
      {'month': '5月', 'count': 18},
      {'month': '6月', 'count': 28},
    ],
    'churnWarning': [
      {'name': '刘洋', 'phone': '136****1111', 'lastVisit': '2024-04-15', 'days': 49},
      {'name': '赵敏', 'phone': '133****5555', 'lastVisit': '2024-04-20', 'days': 44},
      {'name': '孙丽', 'phone': '131****7777', 'lastVisit': '2024-04-25', 'days': 39},
    ],
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadAllData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAllData() async {
    setState(() => _isLoading = true);

    // 并行加载所有数据
    await Future.wait([
      _loadDailyReport(),
      _loadMonthlyReport(),
      _loadPackageSales(),
      _loadMemberAnalysis(),
    ]);

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadDailyReport() async {
    try {
      final dateStr =
          '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';
      final data = await _reportRepo.getDailyReport(date: dateStr);
      if (mounted) setState(() => _dailyData = data);
    } catch (e) {
      debugPrint('加载日报失败，使用 Mock 数据: $e');
      if (mounted) setState(() => _dailyData = _mockDaily);
    }
  }

  Future<void> _loadMonthlyReport() async {
    try {
      final monthStr =
          '${_selectedMonth.year}-${_selectedMonth.month.toString().padLeft(2, '0')}';
      final data = await _reportRepo.getMonthlyReport(month: monthStr);
      if (mounted) setState(() => _monthlyData = data);
    } catch (e) {
      debugPrint('加载月报失败，使用 Mock 数据: $e');
      if (mounted) setState(() => _monthlyData = _mockMonthly);
    }
  }

  Future<void> _loadPackageSales() async {
    try {
      final data = await _reportRepo.getPackageSales();
      if (mounted) setState(() => _packageSales = data);
    } catch (e) {
      debugPrint('加载套餐销量失败，使用 Mock 数据: $e');
      if (mounted) setState(() => _packageSales = _mockPackageSales);
    }
  }

  Future<void> _loadMemberAnalysis() async {
    try {
      final data = await _reportRepo.getMemberAnalysis();
      if (mounted) setState(() => _memberAnalysis = data);
    } catch (e) {
      debugPrint('加载会员分析失败，使用 Mock 数据: $e');
      if (mounted) setState(() => _memberAnalysis = _mockMemberAnalysis);
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
      await _loadDailyReport();
    }
  }

  Future<void> _selectMonth(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedMonth,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _selectedMonth = picked);
      await _loadMonthlyReport();
    }
  }

  @override
  Widget build(BuildContext context) {
    final spacing = ResponsiveHelper.spacing(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('报表中心'),
        backgroundColor: const Color(0xFF0052D9),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Tab 栏
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: const Color(0xFF0052D9),
              unselectedLabelColor: const Color(0xFF86909C),
              indicatorColor: const Color(0xFF0052D9),
              indicatorSize: TabBarIndicatorSize.label,
              tabs: const [
                Tab(text: '日报'),
                Tab(text: '月报'),
                Tab(text: '套餐分析'),
                Tab(text: '会员分析'),
              ],
            ),
          ),
          // Tab 内容
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildDailyTab(spacing),
                      _buildMonthlyTab(spacing),
                      _buildPackageTab(spacing),
                      _buildMemberAnalysisTab(spacing),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  /// 日报 Tab
  Widget _buildDailyTab(double spacing) {
    final data = _dailyData.isNotEmpty ? _dailyData : _mockDaily;
    final revenue = data['revenue'] ?? 3280;
    final consumeCount = data['consumeCount'] ?? 18;
    final yesterdayRevenue = data['yesterdayRevenue'] ?? 2960;
    final yesterdayConsume = data['yesterdayConsumeCount'] ?? 15;
    final wechat = data['wechatPay'] ?? 65;
    final alipay = data['alipayPay'] ?? 20;
    final cash = data['cashPay'] ?? 10;
    final card = data['cardPay'] ?? 5;

    final revenueDiff = revenue - yesterdayRevenue;
    final consumeDiff = consumeCount - yesterdayConsume;

    return SingleChildScrollView(
      padding: EdgeInsets.all(spacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 日期选择器
          GestureDetector(
            onTap: () => _selectDate(context),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: const Color(0xFFE5E6EB)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.calendar_today,
                      size: 16.sp, color: const Color(0xFF0052D9)),
                  SizedBox(width: 8.w),
                  Text(
                    '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: const Color(0xFF1D2129),
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Icon(Icons.arrow_drop_down,
                      size: 16.sp, color: const Color(0xFF86909C)),
                ],
              ),
            ),
          ),
          SizedBox(height: spacing),

          // 营收卡片
          _buildReportCard(
            spacing,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('今日营收',
                    style: TextStyle(
                        fontSize: 14.sp,
                        color: const Color(0xFF86909C))),
                SizedBox(height: 8.h),
                Text('¥$revenue',
                    style: TextStyle(
                        fontSize: 28.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1D2129))),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Icon(
                      revenueDiff >= 0
                          ? Icons.trending_up
                          : Icons.trending_down,
                      size: 14.sp,
                      color: revenueDiff >= 0
                          ? const Color(0xFF00A870)
                          : const Color(0xFFE34D59),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      '较昨日 ${revenueDiff >= 0 ? '+' : ''}¥$revenueDiff',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: revenueDiff >= 0
                            ? const Color(0xFF00A870)
                            : const Color(0xFFE34D59),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: spacing * 0.75),

          // 消费次数卡片
          _buildReportCard(
            spacing,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('消费次数',
                    style: TextStyle(
                        fontSize: 14.sp,
                        color: const Color(0xFF86909C))),
                SizedBox(height: 8.h),
                Text('$consumeCount 次',
                    style: TextStyle(
                        fontSize: 28.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1D2129))),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Icon(
                      consumeDiff >= 0
                          ? Icons.trending_up
                          : Icons.trending_down,
                      size: 14.sp,
                      color: consumeDiff >= 0
                          ? const Color(0xFF00A870)
                          : const Color(0xFFE34D59),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      '较昨日 ${consumeDiff >= 0 ? '+' : ''}$consumeDiff 次',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: consumeDiff >= 0
                            ? const Color(0xFF00A870)
                            : const Color(0xFFE34D59),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: spacing * 0.75),

          // 支付方式占比
          _buildReportCard(
            spacing,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('支付方式占比',
                    style: TextStyle(
                        fontSize: 14.sp,
                        color: const Color(0xFF86909C))),
                SizedBox(height: 12.h),
                _buildPayMethodRow('微信支付', wechat, const Color(0xFF00A870),
                    spacing),
                SizedBox(height: 8.h),
                _buildPayMethodRow('支付宝', alipay, const Color(0xFF0052D9),
                    spacing),
                SizedBox(height: 8.h),
                _buildPayMethodRow('现金', cash, const Color(0xFFED7B2F),
                    spacing),
                SizedBox(height: 8.h),
                _buildPayMethodRow('会员卡', card, const Color(0xFF7B61FF),
                    spacing),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPayMethodRow(
      String name, double percent, Color color, double spacing) {
    return Row(
      children: [
        SizedBox(
          width: 60.w,
          child: Text(name,
              style:
                  TextStyle(fontSize: 13.sp, color: const Color(0xFF4E5969))),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4.r),
            child: LinearProgressIndicator(
              value: percent / 100,
              backgroundColor: const Color(0xFFF2F3F5),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 8.h,
            ),
          ),
        ),
        SizedBox(width: 8.w),
        SizedBox(
          width: 40.w,
          child: Text('${percent.toInt()}%',
              textAlign: TextAlign.right,
              style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF1D2129))),
        ),
      ],
    );
  }

  /// 月报 Tab
  Widget _buildMonthlyTab(double spacing) {
    final data = _monthlyData.isNotEmpty ? _monthlyData : _mockMonthly;
    final avgDaily = data['avgDailyRevenue'] ?? 3100;
    final totalConsume = data['totalConsume'] ?? 420;
    final newMembers = data['newMembers'] ?? 28;
    final totalRevenue = data['totalRevenue'] ?? 93000;

    return SingleChildScrollView(
      padding: EdgeInsets.all(spacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 月份选择器
          GestureDetector(
            onTap: () => _selectMonth(context),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: const Color(0xFFE5E6EB)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.calendar_today,
                      size: 16.sp, color: const Color(0xFF0052D9)),
                  SizedBox(width: 8.w),
                  Text(
                    '${_selectedMonth.year}年${_selectedMonth.month}月',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: const Color(0xFF1D2129),
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Icon(Icons.arrow_drop_down,
                      size: 16.sp, color: const Color(0xFF86909C)),
                ],
              ),
            ),
          ),
          SizedBox(height: spacing),

          // 月度汇总卡片
          _buildReportCard(
            spacing,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildMonthlyStatItem('日均营收', '¥$avgDaily',
                        Icons.paid, const Color(0xFF0052D9)),
                    _buildMonthlyStatItem('总消费', '$totalConsume次',
                        Icons.receipt_long, const Color(0xFF00A870)),
                    _buildMonthlyStatItem('新增会员', '$newMembers人',
                        Icons.person_add, const Color(0xFFED7B2F)),
                  ],
                ),
                SizedBox(height: 16.h),
                const Divider(height: 1, color: Color(0xFFF2F3F5)),
                SizedBox(height: 16.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('月度总营收',
                        style: TextStyle(
                            fontSize: 14.sp,
                            color: const Color(0xFF86909C))),
                    Text('¥$totalRevenue',
                        style: TextStyle(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1D2129))),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyStatItem(
      String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          width: 40.r,
          height: 40.r,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(icon, color: color, size: 20.sp),
        ),
        SizedBox(height: 8.h),
        Text(value,
            style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1D2129))),
        SizedBox(height: 2.h),
        Text(label,
            style: TextStyle(
                fontSize: 12.sp, color: const Color(0xFF86909C))),
      ],
    );
  }

  /// 套餐分析 Tab
  Widget _buildPackageTab(double spacing) {
    final data = _packageSales.isNotEmpty ? _packageSales : _mockPackageSales;

    return SingleChildScrollView(
      padding: EdgeInsets.all(spacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('销量排行',
              style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1D2129))),
          SizedBox(height: spacing * 0.75),
          ...List.generate(data.length, (index) {
            final item = data[index] as Map<String, dynamic>;
            return _buildPackageSalesCard(item, index + 1, spacing);
          }),
        ],
      ),
    );
  }

  Widget _buildPackageSalesCard(
      Map<String, dynamic> item, int rank, double spacing) {
    final colors = [
      const Color(0xFFE34D59),
      const Color(0xFFED7B2F),
      const Color(0xFFEBB105),
      const Color(0xFF86909C),
      const Color(0xFF86909C),
    ];
    final rankColor = rank <= 3 ? colors[rank - 1] : const Color(0xFF86909C);

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
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
      child: Row(
        children: [
          // 排名
          Container(
            width: 32.r,
            height: 32.r,
            decoration: BoxDecoration(
              color: rankColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Center(
              child: Text(
                '$rank',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: rankColor,
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          // 套餐信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['name'] ?? '',
                    style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1D2129))),
                SizedBox(height: 6.h),
                Row(
                  children: [
                    Text('销量: ${item['sales']}份',
                        style: TextStyle(
                            fontSize: 12.sp,
                            color: const Color(0xFF86909C))),
                    SizedBox(width: 16.w),
                    Text('收入: ¥${item['revenue']}',
                        style: TextStyle(
                            fontSize: 12.sp,
                            color: const Color(0xFF86909C))),
                    SizedBox(width: 16.w),
                    Text('过期: ${item['expired']}次',
                        style: TextStyle(
                            fontSize: 12.sp,
                            color: const Color(0xFFE34D59))),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 会员分析 Tab
  Widget _buildMemberAnalysisTab(double spacing) {
    final data =
        _memberAnalysis.isNotEmpty ? _memberAnalysis : _mockMemberAnalysis;
    final trend = (data['newTrend'] as List<dynamic>?) ?? _mockMemberAnalysis['newTrend'];
    final churn = (data['churnWarning'] as List<dynamic>?) ?? _mockMemberAnalysis['churnWarning'];

    return SingleChildScrollView(
      padding: EdgeInsets.all(spacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 新增趋势
          Text('新增会员趋势',
              style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1D2129))),
          SizedBox(height: spacing * 0.75),
          _buildReportCard(
            spacing,
            child: Column(
              children: [
                SizedBox(
                  height: 120.h,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: List.generate(trend.length, (index) {
                      final item = trend[index] as Map<String, dynamic>;
                      final count = item['count'] as int;
                      final maxCount = trend
                          .map((e) => (e as Map<String, dynamic>)['count'] as int)
                          .reduce((a, b) => a > b ? a : b);
                      final ratio = count / (maxCount > 0 ? maxCount : 1);
                      return Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4.w),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                height: (80.h * ratio).clamp(8.h, 80.h),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0052D9)
                                      .withOpacity(0.8),
                                  borderRadius: BorderRadius.circular(4.r),
                                ),
                              ),
                              SizedBox(height: 6.h),
                              Text(
                                item['month'] ?? '',
                                style: TextStyle(
                                    fontSize: 10.sp,
                                    color: const Color(0xFF86909C)),
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                '${item['count']}',
                                style: TextStyle(
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF1D2129)),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: spacing),

          // 流失预警
          Text('流失预警',
              style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1D2129))),
          SizedBox(height: spacing * 0.75),
          ...List.generate(churn.length, (index) {
            final item = churn[index] as Map<String, dynamic>;
            return _buildChurnWarningCard(item, spacing);
          }),
        ],
      ),
    );
  }

  Widget _buildChurnWarningCard(Map<String, dynamic> item, double spacing) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
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
      child: Row(
        children: [
          Container(
            width: 40.r,
            height: 40.r,
            decoration: BoxDecoration(
              color: const Color(0xFFE34D59).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: const Icon(Icons.warning_amber,
                color: Color(0xFFE34D59)),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(item['name'] ?? '',
                        style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1D2129))),
                    SizedBox(width: 8.w),
                    Text(item['phone'] ?? '',
                        style: TextStyle(
                            fontSize: 12.sp,
                            color: const Color(0xFF86909C))),
                  ],
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Text('上次到店: ${item['lastVisit']}',
                        style: TextStyle(
                            fontSize: 12.sp,
                            color: const Color(0xFF86909C))),
                    SizedBox(width: 16.w),
                    Text('已 ${item['days']} 天未到店',
                        style: TextStyle(
                            fontSize: 12.sp,
                            color: const Color(0xFFE34D59),
                            fontWeight: FontWeight.w500)),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(
            child: TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                padding:
                    EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                backgroundColor: const Color(0xFF0052D9).withOpacity(0.1),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6.r)),
              ),
              child: Text('提醒',
                  style: TextStyle(
                      fontSize: 12.sp,
                      color: const Color(0xFF0052D9))),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportCard(double spacing, {required Widget child}) {
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
      child: child,
    );
  }
}
