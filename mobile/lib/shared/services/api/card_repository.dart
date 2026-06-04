import 'package:member_card_app/shared/services/api_client.dart';

/// 次卡仓库 - 处理次卡相关 API
class CardRepository {
  final ApiClient _api = ApiClient.instance;

  /// 获取次卡列表
  Future<List<dynamic>> getCards({int? memberId}) async {
    final params = <String, dynamic>{};
    if (memberId != null) params['member_id'] = memberId;
    final resp = await _api.get('/cards', params: params);
    final data = resp.data;
    if (data['code'] == 200) {
      return data['data'] as List<dynamic>;
    }
    throw Exception(data['message'] ?? '获取次卡列表失败');
  }

  /// 核销次卡
  Future<Map<String, dynamic>> verifyCard(int cardId, Map<String, dynamic> data) async {
    final resp = await _api.post('/cards/$cardId/verify', data: data);
    final result = resp.data;
    if (result['code'] == 200) {
      return result['data'] as Map<String, dynamic>;
    }
    throw Exception(result['message'] ?? '核销失败');
  }
}
