import 'package:member_card_app/shared/services/api_client.dart';

/// 业绩仓库 - 处理业绩统计相关 API
class PerformanceRepository {
  final ApiClient _api = ApiClient.instance;

  /// 获取业绩数据
  Future<Map<String, dynamic>> getPerformance({String period = 'today'}) async {
    final resp = await _api.get('/performance', params: {'period': period});
    final data = resp.data;
    if (data['code'] == 200) {
      return data['data'] as Map<String, dynamic>;
    }
    throw Exception(data['message'] ?? '获取业绩数据失败');
  }

  /// 获取员工排名
  Future<List<dynamic>> getStaffRanking() async {
    final resp = await _api.get('/performance/staff');
    final data = resp.data;
    if (data['code'] == 200) {
      return data['data'] as List<dynamic>;
    }
    throw Exception(data['message'] ?? '获取员工排名失败');
  }
}
