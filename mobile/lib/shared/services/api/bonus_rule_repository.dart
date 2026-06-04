import 'package:member_card_app/shared/services/api_client.dart';

/// 赠金规则仓库 - 处理充值赠金规则 API
class BonusRuleRepository {
  final ApiClient _api = ApiClient.instance;

  /// 获取赠金规则列表
  Future<List<dynamic>> getBonusRules() async {
    final resp = await _api.get('/bonus-rules');
    final data = resp.data;
    if (data['code'] == 200) {
      return data['data'] as List<dynamic>;
    }
    throw Exception(data['message'] ?? '获取赠金规则失败');
  }
}
