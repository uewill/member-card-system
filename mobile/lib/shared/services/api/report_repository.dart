import 'package:member_card_app/shared/services/api_client.dart';

/// 报表仓库 - 处理报表相关 API
class ReportRepository {
  final ApiClient _api = ApiClient.instance;

  /// 获取日报数据
  Future<Map<String, dynamic>> getDailyReport({String? date}) async {
    final params = <String, dynamic>{};
    if (date != null) params['date'] = date;
    final resp = await _api.get('/reports/daily', params: params);
    final data = resp.data;
    if (data['code'] == 200) {
      return data['data'] as Map<String, dynamic>;
    }
    throw Exception(data['message'] ?? '获取日报数据失败');
  }

  /// 获取月报数据
  Future<Map<String, dynamic>> getMonthlyReport({String? month}) async {
    final params = <String, dynamic>{};
    if (month != null) params['month'] = month;
    final resp = await _api.get('/reports/monthly', params: params);
    final data = resp.data;
    if (data['code'] == 200) {
      return data['data'] as Map<String, dynamic>;
    }
    throw Exception(data['message'] ?? '获取月报数据失败');
  }

  /// 获取套餐销量数据
  Future<List<dynamic>> getPackageSales() async {
    final resp = await _api.get('/reports/package-sales');
    final data = resp.data;
    if (data['code'] == 200) {
      return data['data'] as List<dynamic>;
    }
    throw Exception(data['message'] ?? '获取套餐销量数据失败');
  }

  /// 获取会员分析数据
  Future<Map<String, dynamic>> getMemberAnalysis() async {
    final resp = await _api.get('/reports/member-analysis');
    final data = resp.data;
    if (data['code'] == 200) {
      return data['data'] as Map<String, dynamic>;
    }
    throw Exception(data['message'] ?? '获取会员分析数据失败');
  }
}
