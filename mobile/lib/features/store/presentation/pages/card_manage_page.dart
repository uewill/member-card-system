import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:member_card_app/core/utils/responsive_helper.dart';

/// 次卡管理页 - 商务专业风格
class CardManagePage extends StatefulWidget {
  const CardManagePage({super.key});

  @override
  State<CardManagePage> createState() => _CardManagePageState();
}

class _CardManagePageState extends State<CardManagePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedTab = '全部';

  final List<String> _tabs = ['全部', '次卡', '储值卡', '混合卡'];

  // Mock 卡片数据
  final List<Map<String, dynamic>> _allCards = [
    {
      'id': '1',
      'cardNo': 'MC20240601001',
      'memberName': '李美丽',
      'memberPhone': '138****5678',
      'cardType': '次卡',
      'cardTypeName': '面部护理10次卡',
      'remaining': '8次',
      'balance': null,
      'validDate': '2024-12-31',
      'status': 'active',
      'statusText': '正常',
      'statusColor': Color(0xFF00A870),
      'avatar': '李',
      'avatarColor': Color(0xFF0052D9),
    },
    {
      'id': '2',
      'cardNo': 'MC20240515002',
      'memberName': '王芳',
      'memberPhone': '139****1234',
      'cardType': '储值卡',
      'cardTypeName': 'VIP储值卡',
      'remaining': null,
      'balance': '¥1,280.00',
      'validDate': '2025-06-15',
      'status': 'active',
      'statusText': '正常',
      'statusColor': Color(0xFF00A870),
      'avatar': '王',
      'avatarColor': Color(0xFF7B61FF),
    },
    {
      'id': '3',
      'cardNo': 'MC20240301003',
      'memberName': '张婷',
      'memberPhone': '136****9876',
      'cardType': '次卡',
      'cardTypeName': '精油按摩5次卡',
      'remaining': '2次',
      'balance': null,
      'validDate': '2024-06-30',
      'status': 'expiring',
      'statusText': '即将过期',
      'statusColor': Color(0xFFED7B2F),
      'avatar': '张',
      'avatarColor': Color(0xFFE34D59),
    },
    {
      'id': '4',
      'cardNo': 'MC20240401004',
      'memberName': '刘洋',
      'memberPhone': '137****5555',
      'cardType': '混合卡',
      'cardTypeName': '综合护理卡',
      'remaining': '5次',
      'balance': '¥500.00',
      'validDate': '2025-04-01',
      'status': 'active',
      'statusText': '正常',
      'statusColor': Color(0xFF00A870),
      'avatar': '刘',
      'avatarColor': Color(0xFF00A870),
    },
    {
      'id': '5',
      'cardNo': 'MC20240201005',
      'memberName': '陈静',
      'memberPhone': '135****6666',
      'cardType': '储值卡',
      'cardTypeName': '白金储值卡',
      'remaining': null,
      'balance': '¥3,500.00',
      'validDate': '2025-02-01',
      'status': 'active',
      'statusText': '正常',
      'statusColor': Color(0xFF00A870),
      'avatar': '陈',
      'avatarColor': Color(0xFFEBB105),
    },
    {
      'id': '6',
      'cardNo': 'MC20240101006',
      'memberName': '赵敏',
      'memberPhone': '133****7777',
      'cardType': '次卡',
      'cardTypeName': '洗剪吹10次卡',
      'remaining': '0次',
      'balance': null,
      'validDate': '2024-05-01',
      'status': 'expired',
      'statusText': '已过期',
      'statusColor': Color(0xFFE34D59),
      'avatar': '赵',
      'avatarColor': Color(0xFF86909C),
    },
    {
      'id': '7',
      'cardNo': 'MC20240520007',
      'memberName': '孙悦',
      'memberPhone': '132****8888',
      'cardType': '混合卡',
      'cardTypeName': '尊享护理卡',
      'remaining': '12次',
      'balance': '¥1,000.00',
      'validDate': '2025-05-20',
      'status': 'active',
      'statusText': '正常',
      'statusColor': Color(0xFF00A870),
      'avatar': '孙',
      'avatarColor': Color(0xFF5E7AD8),
    },
    {
      'id': '8',
      'cardNo': 'MC20240601008',
      'memberName': '周雪',
      'memberPhone': '131****9999',
      'cardType': '次卡',
      'cardTypeName': '身体SPA 3次卡',
      'remaining': '1次',
      'balance': null,
      'validDate': '2024-07-15',
      'status': 'expiring',
      'statusText': '即将过期',
      'statusColor': Color(0xFFED7B2F),
      'avatar': '周',
      'avatarColor': Color(0xFFE34D59),
    },
  ];

  List<Map<String, dynamic>> get _filteredCards {
    if (_selectedTab == '全部') return _allCards;
    return _allCards.where((card) => card['cardType'] == _selectedTab).toList();
  }

  int get _totalCount => _allCards.length;
  int get _activeCount =>
      _allCards.where((c) => c['status'] == 'active').length;
  int get _expiringCount =>
      _allCards.where((c) => c['status'] == 'expiring').length;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          _selectedTab = _tabs[_tabController.index];
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
          '次卡管理',
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
        actions: [
          IconButton(
            icon: Icon(
              Icons.filter_list,
              color: const Color(0xFF0052D9),
              size: 22.sp,
            ),
            onPressed: () {
              _showFilterBottomSheet(context);
            },
          ),
          SizedBox(width: 8.w),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(44.h),
          child: Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: const Color(0xFF0052D9),
              unselectedLabelColor: const Color(0xFF86909C),
              indicatorColor: const Color(0xFF0052D9),
              indicatorSize: TabBarIndicatorSize.label,
              indicatorWeight: 3,
              labelStyle: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
              unselectedLabelStyle:
                  TextStyle(fontSize: 14.sp, fontWeight: FontWeight.normal),
              tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // 顶部统计卡片
          _buildStatsSection(spacing),

          // 卡片列表
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: _tabs.map((_) => _buildCardList(spacing)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(double spacing) {
    return Container(
      margin: EdgeInsets.all(spacing),
      padding: EdgeInsets.symmetric(horizontal: spacing, vertical: 16.h),
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
          _buildStatItem(
            label: '总卡数',
            value: '$_totalCount',
            icon: Icons.credit_card,
            color: const Color(0xFF0052D9),
          ),
          _buildStatDivider(),
          _buildStatItem(
            label: '活跃卡',
            value: '$_activeCount',
            icon: Icons.check_circle_outline,
            color: const Color(0xFF00A870),
          ),
          _buildStatDivider(),
          _buildStatItem(
            label: '即将过期',
            value: '$_expiringCount',
            icon: Icons.schedule,
            color: const Color(0xFFED7B2F),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Column(
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
          Text(
            value,
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1D2129),
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              color: const Color(0xFF86909C),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatDivider() {
    return Container(
      width: 1,
      height: 50.h,
      color: const Color(0xFFE5E6EB),
    );
  }

  Widget _buildCardList(double spacing) {
    final cards = _filteredCards;

    if (cards.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64.sp, color: const Color(0xFFC9CDD4)),
            SizedBox(height: 16.h),
            Text(
              '暂无相关卡片',
              style: TextStyle(
                fontSize: 14.sp,
                color: const Color(0xFF86909C),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: spacing, vertical: 8.h),
      itemCount: cards.length,
      itemBuilder: (context, index) {
        return _buildCardItem(cards[index], spacing);
      },
    );
  }

  Widget _buildCardItem(Map<String, dynamic> card, double spacing) {
    final statusColor = card['statusColor'] as Color;
    final statusText = card['statusText'] as String;
    final avatarColor = card['avatarColor'] as Color;

    return GestureDetector(
      onTap: () => context.go('/card-detail/${card['id']}'),
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // 第一行：头像 + 基本信息 + 状态
            Row(
              children: [
                // 头像
                Container(
                  width: 44.r,
                  height: 44.r,
                  decoration: BoxDecoration(
                    color: avatarColor,
                    borderRadius: BorderRadius.circular(22.r),
                  ),
                  child: Center(
                    child: Text(
                      card['avatar'] as String,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),

                // 基本信息
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            card['memberName'] as String,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1D2129),
                            ),
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            card['memberPhone'] as String,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: const Color(0xFF86909C),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        card['cardTypeName'] as String,
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: const Color(0xFF4E5969),
                        ),
                      ),
                    ],
                  ),
                ),

                // 状态标签
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: statusColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 12.h),

            // 分隔线
            Container(
              height: 1,
              color: const Color(0xFFF2F3F5),
            ),

            SizedBox(height: 12.h),

            // 第二行：详细信息
            Row(
              children: [
                _buildInfoItem(
                  label: '卡号',
                  value: card['cardNo'] as String,
                  icon: Icons.tag,
                ),
                SizedBox(width: 16.w),
                _buildInfoItem(
                  label: '卡类型',
                  value: card['cardType'] as String,
                  icon: Icons.category,
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Row(
              children: [
                _buildInfoItem(
                  label: card['remaining'] != null ? '剩余次数' : '余额',
                  value: card['remaining'] ?? card['balance'] ?? '-',
                  icon: card['remaining'] != null
                      ? Icons.confirmation_number
                      : Icons.account_balance_wallet,
                  valueColor: card['status'] == 'expired'
                      ? const Color(0xFF86909C)
                      : const Color(0xFF0052D9),
                ),
                SizedBox(width: 16.w),
                _buildInfoItem(
                  label: '有效期至',
                  value: card['validDate'] as String,
                  icon: Icons.event,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required String label,
    required String value,
    required IconData icon,
    Color? valueColor,
  }) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 14.sp, color: const Color(0xFFC9CDD4)),
          SizedBox(width: 4.w),
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 12.sp,
              color: const Color(0xFF86909C),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12.sp,
                color: valueColor ?? const Color(0xFF4E5969),
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          padding: EdgeInsets.all(ResponsiveHelper.spacing(context)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '筛选条件',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1D2129),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Color(0xFF86909C)),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              _buildFilterOption('卡状态', ['全部状态', '正常', '即将过期', '已过期']),
              SizedBox(height: 12.h),
              _buildFilterOption('排序方式', ['默认排序', '到期时间', '余额/次数', '创建时间']),
              SizedBox(height: 24.h),
              SizedBox(
                width: double.infinity,
                height: 48.h,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0052D9),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    '确定',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterOption(String title, List<String> options) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF1D2129),
          ),
        ),
        SizedBox(height: 8.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: options.map((option) {
            final isSelected = option == options[0];
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF0052D9).withOpacity(0.1)
                    : const Color(0xFFF5F7FA),
                borderRadius: BorderRadius.circular(6.r),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF0052D9)
                      : const Color(0xFFE5E6EB),
                ),
              ),
              child: Text(
                option,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: isSelected
                      ? const Color(0xFF0052D9)
                      : const Color(0xFF4E5969),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
