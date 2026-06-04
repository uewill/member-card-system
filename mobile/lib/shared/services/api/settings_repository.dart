import 'package:member_card_app/shared/services/api_client.dart';

/// 设置仓库 - 处理系统设置相关 API
class SettingsRepository {
  final ApiClient _api = ApiClient.instance;

  /// 获取系统设置
  Future<Map<String, dynamic>> getSettings() async {
    final resp = await _api.get('/settings');
    final data = resp.data;
    if (data['code'] == 200) {
      return data['data'] as Map<String, dynamic>;
    }
    throw Exception(data['message'] ?? '获取系统设置失败');
  }

  /// 更新系统设置
  Future<Map<String, dynamic>> updateSettings(Map<String, dynamic> data) async {
    final resp = await _api.put('/settings', data: data);
    final result = resp.data;
    if (result['code'] == 200) {
      return result['data'] as Map<String, dynamic>;
    }
    throw Exception(result['message'] ?? '更新系统设置失败');
  }
}
